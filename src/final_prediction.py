from pathlib import Path
import math
from typing import Any

import cv2
import numpy as np
import onnxruntime as ort
from PIL import Image


_pipeline: dict[str, Any] | None = None
_DEFAULT_FRUIT_INDEX = {"banana": 0, "mango": 1}
_DEFAULT_RIPENESS_INDEX = {"overripe": 0, "ripe": 1, "unripe": 2}
_DEFAULT_DAYS_STATS = {
    "fruit_to_index": _DEFAULT_FRUIT_INDEX,
    "stage_to_index": _DEFAULT_RIPENESS_INDEX,
    "temperature_mean": 28.0,
    "humidity_mean": 65.0,
    "temperature_scale": 10.0,
    "humidity_scale": 30.0,
}

_IMAGENET_MEAN = np.array([0.485, 0.456, 0.406], dtype=np.float32)
_IMAGENET_STD = np.array([0.229, 0.224, 0.225], dtype=np.float32)


def normalize_text(value: str) -> str:
    return value.strip().lower().replace("_", " ").replace("-", " ")


def format_days_range(days: float) -> str:
    if days <= 0.5:
        return "0 days (Fully Ripe)"
    lower = int(days)
    return f"{lower}-{lower + 1} days"


def letterbox(
    im: np.ndarray,
    new_shape: tuple[int, int] = (640, 640),
    color: tuple[int, int, int] = (114, 114, 114),
) -> tuple[np.ndarray, float, tuple[float, float]]:
    """Resize image to new_shape with padding, maintaining aspect ratio."""
    shape = im.shape[:2]
    r = min(new_shape[0] / shape[0], new_shape[1] / shape[1])
    new_unpad = int(round(shape[1] * r)), int(round(shape[0] * r))
    dw, dh = new_shape[1] - new_unpad[0], new_shape[0] - new_unpad[1]
    dw /= 2
    dh /= 2

    if shape[::-1] != new_unpad:
        im = cv2.resize(im, new_unpad, interpolation=cv2.INTER_LINEAR)
    top, bottom = int(round(dh - 0.1)), int(round(dh + 0.1))
    left, right = int(round(dw - 0.1)), int(round(dw + 0.1))
    im = cv2.copyMakeBorder(im, top, bottom, left, right, cv2.BORDER_CONSTANT, value=color)
    return im, r, (dw, dh)


def detect_fruits_yolo(
    session: ort.InferenceSession,
    input_name: str,
    output_name: str,
    frame: np.ndarray,
    conf_thresh: float = 0.40,
    classes: list[int] | None = None,
    iou_thresh: float = 0.45,
) -> list[dict[str, Any]]:
    """Run YOLOv8 ONNX inference, decode [1, 84, 8400] output, and apply NMS."""
    if classes is None:
        classes = [46, 47, 49]
    h0, w0 = frame.shape[:2]
    img, ratio, (dw, dh) = letterbox(frame, (640, 640))
    blob = cv2.cvtColor(img, cv2.COLOR_BGR2RGB).astype(np.float32) / 255.0
    blob = np.transpose(blob, (2, 0, 1))
    blob = np.expand_dims(blob, axis=0)

    preds = session.run([output_name], {input_name: blob})[0][0]
    boxes = preds[:4, :]
    scores = preds[4:, :]

    boxes_list: list[list[int]] = []
    scores_list: list[float] = []
    class_ids: list[int] = []

    for c in classes:
        cls_scores = scores[c, :]
        mask = cls_scores >= conf_thresh
        if np.any(mask):
            selected_boxes = boxes[:, mask]
            selected_scores = cls_scores[mask]
            for i in range(selected_boxes.shape[1]):
                cx, cy, w, h = selected_boxes[:, i]
                x1 = (cx - w / 2 - dw) / ratio
                y1 = (cy - h / 2 - dh) / ratio
                x2 = (cx + w / 2 - dw) / ratio
                y2 = (cy + h / 2 - dh) / ratio

                x1 = max(0, min(w0, int(round(x1))))
                y1 = max(0, min(h0, int(round(y1))))
                x2 = max(0, min(w0, int(round(x2))))
                y2 = max(0, min(h0, int(round(y2))))

                if x2 > x1 and y2 > y1:
                    boxes_list.append([x1, y1, x2 - x1, y2 - y1])
                    scores_list.append(float(selected_scores[i]))
                    class_ids.append(c)

    if not boxes_list:
        return []

    indices = cv2.dnn.NMSBoxes(boxes_list, scores_list, conf_thresh, iou_thresh)
    results: list[dict[str, Any]] = []
    if len(indices) > 0:
        for idx in indices.flatten():
            bx, by, bw, bh = boxes_list[idx]
            results.append(
                {
                    "class_id": class_ids[idx],
                    "confidence": scores_list[idx],
                    "bbox": [bx, by, bx + bw, by + bh],
                }
            )
    return results


def preprocess_classifier_crop(crop_rgb: np.ndarray) -> np.ndarray:
    """Preprocess cropped RGB image for EfficientNetV2-S ONNX model.
    
    Resize to 224x224 with Pillow BILINEAR, scale to [0, 1], normalize
    with ImageNet mean and std, transpose HWC -> CHW, add batch dimension.
    Returns float32 array of shape [1, 3, 224, 224].
    """
    pil_img = Image.fromarray(crop_rgb)
    pil_resized = pil_img.resize((224, 224), Image.Resampling.BILINEAR)
    arr = np.array(pil_resized, dtype=np.float32) / 255.0
    arr = (arr - _IMAGENET_MEAN) / _IMAGENET_STD
    return np.expand_dims(np.transpose(arr, (2, 0, 1)), axis=0).astype(np.float32)


def create_mlp_input(
    fruit_name: str,
    stage_name: str,
    temperature: float,
    humidity: float,
    days_checkpoint: dict[str, Any],
) -> np.ndarray:
    fruit = normalize_text(fruit_name)
    stage = normalize_text(stage_name)
    fruit_to_index = days_checkpoint.get("fruit_to_index", _DEFAULT_FRUIT_INDEX)
    stage_to_index = days_checkpoint.get("stage_to_index", _DEFAULT_RIPENESS_INDEX)

    if fruit not in fruit_to_index:
        raise ValueError(f"Fruit '{fruit}' is not present in the Days Remaining model.")
    if stage not in stage_to_index:
        raise ValueError(f"Stage '{stage}' is not present in the Days Remaining model.")

    fruit_features = [0.0] * len(fruit_to_index)
    fruit_features[fruit_to_index[fruit]] = 1.0
    stage_features = [0.0] * len(stage_to_index)
    stage_features[stage_to_index[stage]] = 1.0

    temperature_mean = days_checkpoint.get("temperature_mean", 28.0)
    humidity_mean = days_checkpoint.get("humidity_mean", 65.0)
    temperature_scale = days_checkpoint.get("temperature_scale") or 10.0
    humidity_scale = days_checkpoint.get("humidity_scale") or 30.0

    features = fruit_features + stage_features + [
        (temperature - temperature_mean) / temperature_scale,
        (humidity - humidity_mean) / humidity_scale,
    ]
    return np.array([features], dtype=np.float32)


def load_models() -> dict[str, Any]:
    """Load and cache the ONNX inference sessions for YOLO, Classifier, and Days model."""
    global _pipeline
    if _pipeline is not None:
        return _pipeline

    project_root = Path(__file__).resolve().parents[1]
    image_model_path = project_root / "models" / "best_model.onnx"
    days_model_path = project_root / "models" / "days_model.onnx"
    yolo_path = project_root / "models" / "yolov8n.onnx"

    for model_path in (image_model_path, days_model_path, yolo_path):
        if not model_path.exists():
            raise FileNotFoundError(f"Required model file not found:\n{model_path}")

    image_session = ort.InferenceSession(
        str(image_model_path),
        providers=["CPUExecutionProvider"],
    )
    days_session = ort.InferenceSession(
        str(days_model_path),
        providers=["CPUExecutionProvider"],
    )
    yolo_session = ort.InferenceSession(
        str(yolo_path),
        providers=["CPUExecutionProvider"],
    )

    image_input_names = [item.name for item in image_session.get_inputs()]
    image_output_names = [item.name for item in image_session.get_outputs()]
    days_input_name = days_session.get_inputs()[0].name
    days_output_name = days_session.get_outputs()[0].name
    yolo_input_name = yolo_session.get_inputs()[0].name
    yolo_output_name = yolo_session.get_outputs()[0].name

    image_input_name = image_input_names[0]
    sensor_input_name = image_input_names[1] if len(image_input_names) > 1 else image_input_names[0]
    fruit_output_name = next((name for name in image_output_names if "fruit" in name.lower()), image_output_names[0])
    ripeness_output_name = next(
        (name for name in image_output_names if "ripeness" in name.lower() or "stage" in name.lower()),
        image_output_names[1] if len(image_output_names) > 1 else image_output_names[0],
    )
    image_days_output_name = next((name for name in image_output_names if "day" in name.lower()), image_output_names[-1])

    _pipeline = {
        "classifier_session": image_session,
        "days_model": days_session,
        "days_checkpoint": _DEFAULT_DAYS_STATS.copy(),
        "yolo_session": yolo_session,
        "yolo_input_name": yolo_input_name,
        "yolo_output_name": yolo_output_name,
        "index_to_fruit": {v: k for k, v in _DEFAULT_FRUIT_INDEX.items()},
        "index_to_ripeness": {v: k for k, v in _DEFAULT_RIPENESS_INDEX.items()},
        "image_input_name": image_input_name,
        "sensor_input_name": sensor_input_name,
        "fruit_output_name": fruit_output_name,
        "ripeness_output_name": ripeness_output_name,
        "image_days_output_name": image_days_output_name,
        "days_input_name": days_input_name,
        "days_output_name": days_output_name,
    }
    return _pipeline


def predict_frame(
    frame: Any,
    temperature: float,
    humidity: float,
) -> dict[str, Any]:
    """Run YOLO ONNX, EfficientNet ONNX, and DaysRemainingMLP ONNX on one BGR frame."""
    if frame is None or not hasattr(frame, "shape") or frame.size == 0:
        return {
            "status": "no_frame",
            "temperature": temperature,
            "humidity": humidity,
            "detections": [],
            "error": "A non-empty OpenCV BGR frame is required.",
        }

    try:
        temperature = float(temperature)
        humidity = float(humidity)
    except (TypeError, ValueError):
        return {
            "status": "invalid_sensor_values",
            "temperature": temperature,
            "humidity": humidity,
            "detections": [],
            "error": "Temperature and humidity must be numeric.",
        }

    if not math.isfinite(temperature) or not math.isfinite(humidity):
        return {
            "status": "invalid_sensor_values",
            "temperature": temperature,
            "humidity": humidity,
            "detections": [],
            "error": "Temperature and humidity must be finite.",
        }
    if not 0.0 <= humidity <= 100.0:
        return {
            "status": "invalid_sensor_values",
            "temperature": temperature,
            "humidity": humidity,
            "detections": [],
            "error": "Humidity must be between 0 and 100.",
        }

    models = load_models()
    yolo_detections = detect_fruits_yolo(
        models["yolo_session"],
        models["yolo_input_name"],
        models["yolo_output_name"],
        frame,
        conf_thresh=0.40,
        classes=[46, 47, 49],
    )
    detections: list[dict[str, Any]] = []

    for det in yolo_detections:
        x1, y1, x2, y2 = det["bbox"]
        crop = frame[y1:y2, x1:x2]
        if crop is None or crop.size == 0:
            continue
        crop_rgb = cv2.cvtColor(crop, cv2.COLOR_BGR2RGB)
        image_tensor = preprocess_classifier_crop(crop_rgb)
        sensor_array = np.array([[temperature, humidity]], dtype=np.float32)

        image_outputs = models["classifier_session"].run(
            [models["fruit_output_name"], models["ripeness_output_name"], models["image_days_output_name"]],
            {
                models["image_input_name"]: image_tensor,
                models["sensor_input_name"]: sensor_array,
            },
        )

        fruit_logits = image_outputs[0]
        ripeness_logits = image_outputs[1]
        fruit_probs = np.exp(fruit_logits[0] - np.max(fruit_logits[0]))
        fruit_probs = fruit_probs / np.sum(fruit_probs)
        ripeness_probs = np.exp(ripeness_logits[0] - np.max(ripeness_logits[0]))
        ripeness_probs = ripeness_probs / np.sum(ripeness_probs)

        fruit_idx = int(np.argmax(fruit_logits[0]))
        fruit_name = models["index_to_fruit"][fruit_idx]
        fruit_confidence = float(fruit_probs[fruit_idx])

        ripeness_idx = int(np.argmax(ripeness_logits[0]))
        ripeness_name = models["index_to_ripeness"][ripeness_idx]
        ripeness_confidence = float(ripeness_probs[ripeness_idx])

        low_confidence = fruit_confidence < 0.65
        raw_days: float | None = None
        days_range = "Unavailable"
        if not low_confidence:
            try:
                mlp_input = create_mlp_input(
                    fruit_name,
                    ripeness_name,
                    temperature,
                    humidity,
                    models["days_checkpoint"],
                )
                days_output = models["days_model"].run(
                    [models["days_output_name"]],
                    {models["days_input_name"]: mlp_input},
                )[0]
                raw_days = max(0.0, float(np.asarray(days_output).reshape(-1)[0]))
                days_range = format_days_range(raw_days)
            except Exception:
                days_range = "Unavailable"

        detections.append(
            {
                "fruit": "unknown" if low_confidence else normalize_text(fruit_name),
                "ripeness": normalize_text(ripeness_name),
                "fruit_confidence": fruit_confidence,
                "ripeness_confidence": ripeness_confidence,
                "temperature": temperature,
                "humidity": humidity,
                "days_remaining": raw_days,
                "days_range": days_range,
                "days_range_formatted": days_range,
                "bbox": [x1, y1, x2, y2],
                "accepted": not low_confidence,
                "is_unknown": low_confidence,
                "low_confidence": low_confidence,
            }
        )

    return {
        "status": "result_ready" if detections else "no_fruit",
        "temperature": temperature,
        "humidity": humidity,
        "detections": detections,
    }
