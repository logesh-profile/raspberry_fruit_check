# RIPENX™ System Setup & Deployment Guide

**Tagline**: *“Sense. Predict. Know When It’s Ready.”*

This document describes how to launch the **RIPENX™** commercial hardware frontend application and local Python backend service on Windows development machines and deploy it to a Raspberry Pi 4B with a 4-inch 480×800 portrait touchscreen.

---

## 1. System Architecture

* **Frontend**: Native Flutter application ([`ripenx_flutter/`](file:///c:/Users/dhanu/Desktop/Elite%20Check/fruit_check-main/ripenx_flutter/)) optimized for 480×800 portrait touchscreen interaction.
* **Backend**: Python Flask/REST API bridge ([`backend/ripenx_server.py`](file:///c:/Users/dhanu/Desktop/Elite%20Check/fruit_check-main/backend/ripenx_server.py)) running locally on `http://localhost:5000`.
* **AI Models**:
  * **YOLOv8 Nano** ([`src/yolov8n.pt`](file:///c:/Users/dhanu/Desktop/Elite%20Check/fruit_check-main/src/yolov8n.pt)) — Object detection & ROI bounding box crop.
  * **EfficientNetV2-S** ([`src/model.py`](file:///c:/Users/dhanu/Desktop/Elite%20Check/fruit_check-main/src/model.py), [`models/best_model.pth`](file:///c:/Users/dhanu/Desktop/Elite%20Check/fruit_check-main/models/best_model.pth)) — Species and ripeness classification.
  * **DaysRemainingMLP** ([`src/days_model.py`](file:///c:/Users/dhanu/Desktop/Elite%20Check/fruit_check-main/src/days_model.py), [`models/days_model.pth`](file:///c:/Users/dhanu/Desktop/Elite%20Check/fruit_check-main/models/days_model.pth)) — Environmental shelf-life regression model.
* **Local Storage**: SQLite database ([`backend/db_manager.py`](file:///c:/Users/dhanu/Desktop/Elite%20Check/fruit_check-main/backend/db_manager.py)) storing scan history, verified user corrections, and visual memory embeddings.
* **Sensors**: [`backend/sensor_reader.py`](file:///c:/Users/dhanu/Desktop/Elite%20Check/fruit_check-main/backend/sensor_reader.py) reading physical DHT22 / MQ-2 GPIO sensors or providing realistic hardware simulation.

---

## 2. Running on Windows (Development Preview)

### Step 1: Start the Python Backend Service
Open a terminal inside the project root and run:
```powershell
.\run_ripenx_backend.bat
```
The launcher sets `PYTHONPATH` for the project root and `src`. The server will start on `http://localhost:5000`.

### Step 2: Launch the Flutter Application
In a second terminal:
```powershell
cd ripenx_flutter
flutter pub get
flutter run -d chrome --web-renderer canvaskit
# OR for desktop window:
flutter run -d windows
```

---

## 3. Deploying to Raspberry Pi 4B (Final Hardware Device)

### Hardware Specs:
* Raspberry Pi 4B (4GB or 8GB RAM)
* 4-inch Touchscreen LCD (480 × 800 portrait orientation)
* USB / Ribbon Camera
* DHT22 (Temperature & Humidity on GPIO 4) & MQ-2 Gas sensor

### Deployment Command:
Run the deployment script on the Raspberry Pi:
```bash
chmod +x deploy_raspberry_pi.sh
./deploy_raspberry_pi.sh
```
The deployment script starts the backend from the project root with `src` and the project root in `PYTHONPATH`.

---

## 4. Key Navigation Routes Overview

| Route | Description |
| :--- | :--- |
| **SplashScreen** | Animated RIPENX logo intro (1.8s) |
| **HomeScreen** | Camera viewport, status pills, SCAN FRUIT trigger |
| **LiveScanningScreen** | Scanning beam overlay & YOLO detection |
| **AnalyzingScreen** | AI feature extraction telemetry transition |
| **ResultScreen** | Signature result card, maturity spectrum, confidence, sensor cards, days remaining prediction, feedback options |
| **FruitDetailsScreen** | Storage guidelines & gas sensitivity notes |
| **ScanHistoryScreen** | SQLite local scan logs with image thumbnails |
| **FeedbackScreen** | User correction & retraining dataset workflow |
| **VisualMemoryScreen** | Visual similarity embedding records |
| **SettingsScreen** | Grouped settings cards |
| **DiagnosticsScreen** | Real system memory, latency, and model stats |
