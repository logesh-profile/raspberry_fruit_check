#!/bin/bash
# ====================================================================
# RIPENX™ Raspberry Pi 4B Automated Deployment & Setup Script
# Target: Raspberry Pi OS 64-bit (480x800 4-inch Touchscreen)
# ====================================================================

echo "================================================="
echo "       RIPENX™ Raspberry Pi 4B Installer         "
echo "================================================="

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"
export PYTHONPATH="$PROJECT_ROOT/src:$PROJECT_ROOT:${PYTHONPATH:-}"

sudo apt update && sudo apt install -y python3-pip python3-opencv libcamera-dev flutter

pip3 install flask flask-cors torch torchvision ultralytics pillow psutil adafruit-circuitpython-dht

mkdir -p ~/.config/autostart

cat <<EOT > ~/.config/autostart/ripenx.desktop
[Desktop Entry]
Type=Application
Name=RIPENX
Exec=bash -c "cd $PROJECT_ROOT && export PYTHONPATH=$PROJECT_ROOT/src:$PROJECT_ROOT:\${PYTHONPATH:-} && python3 backend/ripenx_server.py & cd $PROJECT_ROOT/ripenx_flutter && flutter run -d linux"
X-GNOME-Autostart-enabled=true
EOT

echo "RIPENX deployment complete. Reboot Raspberry Pi to auto-launch."
