import argparse
from pathlib import Path

import onnx
import onnxruntime as ort
import torch
from torch import nn
from torchvision.models import efficientnet_v2_s


class BestModel(nn.Module):
    def __init__(self):
        super().__init__()
        backbone = efficientnet_v2_s(weights=None)
        self.features = backbone.features
        self.fruit_head = nn.Linear(1280, 2)
        self.ripeness_head = nn.Linear(1280, 3)
        self.sensor_branch = nn.Sequential(
            nn.Linear(2, 32),
            nn.ReLU(),
            nn.Linear(32, 32),
            nn.ReLU(),
        )
        self.regression_head = nn.Sequential(
            nn.Linear(1312, 128),
            nn.ReLU(),
            nn.Dropout(0.2),
            nn.Linear(128, 1),
        )

    def forward(self, image, sensors):
        features = self.features(image)
        pooled = torch.nn.functional.adaptive_avg_pool2d(features, 1).flatten(1)
        fruit = self.fruit_head(pooled)
        ripeness = self.ripeness_head(pooled)
        sensor_features = self.sensor_branch(sensors)
        regression = self.regression_head(torch.cat((pooled, sensor_features), dim=1))
        return fruit, ripeness, regression


class DaysModel(nn.Module):
    def __init__(self):
        super().__init__()
        self.network = nn.Sequential(
            nn.Linear(7, 64),
            nn.ReLU(),
            nn.Linear(64, 128),
            nn.ReLU(),
            nn.Dropout(0.2),
            nn.Linear(128, 64),
            nn.ReLU(),
            nn.Linear(64, 32),
            nn.ReLU(),
            nn.Linear(32, 1),
        )

    def forward(self, features):
        return self.network(features)


def load_state(model, checkpoint_path):
    checkpoint = torch.load(checkpoint_path, map_location="cpu", weights_only=False)
    model.load_state_dict(checkpoint["model_state"], strict=True)
    model.eval()
    return checkpoint


def check_onnx_output(path, inputs, expected):
    session = ort.InferenceSession(str(path), providers=["CPUExecutionProvider"])
    actual = session.run(None, {name: value.numpy() for name, value in inputs.items()})
    for result, reference in zip(actual, expected):
        torch.testing.assert_close(torch.from_numpy(result), reference, rtol=1e-4, atol=1e-5)


def export_best(directory):
    model = BestModel()
    load_state(model, directory / "best_model.pth")
    image = torch.randn(1, 3, 224, 224)
    sensors = torch.randn(1, 2)
    with torch.inference_mode():
        expected = model(image, sensors)
    output_path = directory / "best_model.onnx"
    torch.onnx.export(
        model,
        (image, sensors),
        output_path,
        input_names=["image", "sensors"],
        output_names=["fruit_logits", "ripeness_logits", "days"],
        dynamic_axes={
            "image": {0: "batch", 2: "height", 3: "width"},
            "sensors": {0: "batch"},
            "fruit_logits": {0: "batch"},
            "ripeness_logits": {0: "batch"},
            "days": {0: "batch"},
        },
        opset_version=18,
    )
    onnx.checker.check_model(onnx.load(output_path))
    check_onnx_output(output_path, {"image": image, "sensors": sensors}, expected)


def export_days(directory):
    model = DaysModel()
    checkpoint = load_state(model, directory / "days_model.pth")
    features = torch.randn(1, checkpoint["input_dim"])
    with torch.inference_mode():
        expected = (model(features),)
    output_path = directory / "days_model.onnx"
    torch.onnx.export(
        model,
        features,
        output_path,
        input_names=["features"],
        output_names=["days"],
        dynamic_axes={"features": {0: "batch"}, "days": {0: "batch"}},
        opset_version=18,
    )
    onnx.checker.check_model(onnx.load(output_path))
    check_onnx_output(output_path, {"features": features}, expected)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--directory", type=Path, default=Path(__file__).parent)
    args = parser.parse_args()
    export_best(args.directory)
    export_days(args.directory)
    print("Exported and validated best_model.onnx and days_model.onnx")


if __name__ == "__main__":
    main()