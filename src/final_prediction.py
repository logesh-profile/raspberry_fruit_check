from pathlib import Path
import math
from typing import Any

import cv2
import torch
from PIL import Image
from torchvision import transforms
from ultralytics import YOLO

from model import FruitRipenessModel
from days_model import DaysRemainingMLP


_pipeline: dict[str, Any] | None = None


def normalize_text(value: str) -> str:
    return value.strip().lower().replace("_", " ").replace("-", " ")


def format_days_range(days: float) -> str:
    if days <= 0.5:
        return "0 days (Fully Ripe)"
    lower = int(days)
    return f"{lower}-{lower + 1} days"


def create_mlp_input(
    fruit_name: str,
    stage_name: str,
    temperature: float,
    humidity: float,
    days_checkpoint: dict[str, Any],
) -> torch.Tensor:
    fruit = normalize_text(fruit_name)
    stage = normalize_text(stage_name)
    fruit_to_index = days_checkpoint["fruit_to_index"]
    stage_to_index = days_checkpoint["stage_to_index"]

    if fruit not in fruit_to_index:
        raise ValueError(f"Fruit '{fruit}' is not present in the Days Remaining model.")
    if stage not in stage_to_index:
        raise ValueError(f"Stage '{stage}' is not present in the Days Remaining model.")

    fruit_features = [0.0] * len(fruit_to_index)
    fruit_features[fruit_to_index[fruit]] = 1.0
    stage_features = [0.0] * len(stage_to_index)
    stage_features[stage_to_index[stage]] = 1.0

    temperature_scale = days_checkpoint["temperature_scale"] or 1.0
    humidity_scale = days_checkpoint["humidity_scale"] or 1.0
    features = fruit_features + stage_features + [
        (temperature - days_checkpoint["temperature_mean"]) / temperature_scale,
        (humidity - days_checkpoint["humidity_mean"]) / humidity_scale,
    ]
    return torch.tensor([features], dtype=torch.float32)


def load_models() -> dict[str, Any]:
    """Load and cache the existing detector, classifiers, and MLP."""
    global _pipeline
    if _pipeline is not None:
        return _pipeline

    project_root = Path(__file__).resolve().parents[1]
    image_checkpoint_path = project_root / "models" / "best_model.pth"
    days_checkpoint_path = project_root / "models" / "days_model.pth"
    yolo_path = project_root / "yolov8n.pt"

    for checkpoint_path in (image_checkpoint_path, days_checkpoint_path, yolo_path):
        if not checkpoint_path.exists():
            raise FileNotFoundError(f"Required model file not found:\n{checkpoint_path}")

    image_checkpoint = torch.load(
        image_checkpoint_path,
        map_location=torch.device("cpu"),
        weights_only=False,
    )
    fruit_to_index = image_checkpoint["fruit_to_index"]
    ripeness_to_index = image_checkpoint["ripeness_to_index"]

    classifier = FruitRipenessModel(
        num_ripeness_classes=image_checkpoint.get(
            "num_ripeness_classes", len(ripeness_to_index)
        ),
        num_fruit_classes=image_checkpoint.get(
            "num_fruit_classes", len(fruit_to_index)
        ),
        pretrained=False,
    )
    classifier.load_state_dict(image_checkpoint["model_state"])
    classifier.eval()

    days_checkpoint = torch.load(
        days_checkpoint_path,
        map_location=torch.device("cpu"),
        weights_only=False,
    )
    days_model = DaysRemainingMLP(input_dim=days_checkpoint["input_dim"])
    days_model.load_state_dict(days_checkpoint["model_state"])
    days_model.eval()

    _pipeline = {
        "classifier": classifier,
        "days_model": days_model,
        "days_checkpoint": days_checkpoint,
        "yolo_model": YOLO(str(yolo_path)),
        "transform": transforms.Compose(
            [
                transforms.Resize(
                    (image_checkpoint["image_size"], image_checkpoint["image_size"])
                ),
                transforms.ToTensor(),
                transforms.Normalize(
                    image_checkpoint["normalization"]["mean"],
                    image_checkpoint["normalization"]["std"],
                ),
            ]
        ),
        "index_to_fruit": {v: k for k, v in fruit_to_index.items()},
        "index_to_ripeness": {v: k for k, v in ripeness_to_index.items()},
    }
    return _pipeline


def predict_frame(
    frame: Any,
    temperature: float,
    humidity: float,
) -> dict[str, Any]:
    """Run YOLO, EfficientNet, and DaysRemainingMLP on one BGR frame."""
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
    yolo_result = models["yolo_model"](
        frame,
        verbose=False,
        conf=0.40,
        classes=[46, 47, 49],
    )[0]
    detections: list[dict[str, Any]] = []

    for box in yolo_result.boxes:
        x1, y1, x2, y2 = map(int, box.xyxy[0].tolist())
        x1 = max(0, x1)
        y1 = max(0, y1)
        x2 = min(frame.shape[1], x2)
        y2 = min(frame.shape[0], y2)
        if x2 <= x1 or y2 <= y1:
            continue

        crop = frame[y1:y2, x1:x2]
        if crop is None or crop.size == 0:
            continue
        crop_rgb = cv2.cvtColor(crop, cv2.COLOR_BGR2RGB)
        image_tensor = models["transform"](Image.fromarray(crop_rgb)).unsqueeze(0)

        with torch.no_grad():
            features = models["classifier"].encode_image(image_tensor)
            fruit_logits = models["classifier"].fruit_head(features)
            fruit_probs = torch.softmax(fruit_logits, dim=1)
            fruit_idx = fruit_logits.argmax(dim=1).item()
            fruit_name = models["index_to_fruit"][fruit_idx]
            fruit_confidence = float(fruit_probs[0, fruit_idx].item())

            ripeness_logits = models["classifier"].ripeness_head(features)
            ripeness_probs = torch.softmax(ripeness_logits, dim=1)
            ripeness_idx = ripeness_logits.argmax(dim=1).item()
            ripeness_name = models["index_to_ripeness"][ripeness_idx]
            ripeness_confidence = float(ripeness_probs[0, ripeness_idx].item())

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
                with torch.no_grad():
                    raw_days = max(
                        0.0,
                        float(models["days_model"](mlp_input).item()),
                    )
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
