#!/bin/bash
# ====================================================================
# RIPENX™ Raspberry Pi 4B Automated Runtime Setup Script
# Target: Raspberry Pi OS 64-bit (Debian 12 Bookworm, PEP 668)
# ====================================================================

set -e

echo "================================================="
echo "       RIPENX™ Raspberry Pi Runtime Setup        "
echo "================================================="

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

echo "1. Installing system dependencies via apt..."
sudo apt update
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-opencv \
    libcamera-dev \
    libgtk-3-0 \
    libglib2.0-0 \
    liblzma5

VENV_PATH="/opt/ripenx_env"

echo "2. Setting up dedicated Python virtual environment at $VENV_PATH..."
if [ ! -d "$VENV_PATH" ]; then
    sudo python3 -m venv --system-site-packages "$VENV_PATH"
    sudo chown -R "$USER":"$USER" "$VENV_PATH"
    echo "Virtual environment created."
else
    echo "Virtual environment already exists. Reusing $VENV_PATH."
fi

echo "3. Upgrading pip inside virtual environment..."
"$VENV_PATH/bin/pip" install --upgrade pip

echo "4. Installing production requirements in virtual environment..."
"$VENV_PATH/bin/pip" install -r "$PROJECT_ROOT/requirements.txt"

echo "5. Verifying runtime package imports..."
"$VENV_PATH/bin/python" -c "
import onnxruntime
import numpy
import cv2
import PIL
import flask
import flask_cors
import psutil
print('Core runtime packages verified successfully.')
"

"$VENV_PATH/bin/python" -c "
try:
    import adafruit_dht
    print('adafruit_dht verified successfully.')
except Exception as e:
    print(f'NOTE: adafruit_dht notice: {e} (Fallback simulation active).')
"

echo "6. Verifying production ONNX models..."
REQUIRED_MODELS=(
    "models/yolov8n.onnx"
    "models/best_model.onnx"
    "models/best_model.onnx.data"
    "models/days_model.onnx"
    "models/days_model.onnx.data"
)

for model_file in "${REQUIRED_MODELS[@]}"; do
    if [ ! -f "$PROJECT_ROOT/$model_file" ]; then
        echo "ERROR: Required model file not found: $model_file" >&2
        exit 1
    fi
done
echo "All production ONNX model and data files verified."

echo "7. Verifying final_prediction.py pipeline..."
export PYTHONPATH="$PROJECT_ROOT/src:$PROJECT_ROOT:${PYTHONPATH:-}"
"$VENV_PATH/bin/python" -c "
import sys
import final_prediction

disallowed = ['torch', 'torchvision', 'ultralytics']
loaded = [m for m in disallowed if m in sys.modules]
if loaded:
    raise RuntimeError(f'Disallowed PyTorch packages loaded: {loaded}')

print('final_prediction.py verified successfully (PyTorch-free).')
"

echo "8. Verifying backend/ripenx_server.py compilation..."
"$VENV_PATH/bin/python" -m py_compile "$PROJECT_ROOT/backend/ripenx_server.py"
echo "Backend server compilation verified."

echo "================================================="
echo "RIPENX Python runtime setup complete."
echo ""
echo "Python environment:"
echo "  /opt/ripenx_env"
echo ""
echo "Runtime packages:"
echo "  verified"
echo ""
echo "ONNX models:"
echo "  verified"
echo ""
echo "final_prediction.py:"
echo "  verified"
echo ""
echo "Backend:"
echo "  verified"
echo ""
echo "Flutter:"
echo "  NOT configured in this step"
echo "================================================="
