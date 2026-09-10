import sys
import time
import uuid
from pathlib import Path
from typing import Dict, Any, List, Optional

from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import cv2
import numpy as np

project_root = Path(__file__).resolve().parents[1]
sys.path.append(str(project_root))

from src.final_prediction import load_models, predict_frame
from db_manager import RIPENXDatabaseManager
from sensor_reader import SensorReader

app = Flask(__name__)
CORS(app)

# Initialize Database & Sensors
db = RIPENXDatabaseManager()
sensors = SensorReader()

captures_dir = project_root / "data" / "captures"
captures_dir.mkdir(parents=True, exist_ok=True)

# System State
system_status = {
    "camera": "DISCONNECTED",
    "yolo": "NOT_LOADED",
    "efficientnet": "NOT_LOADED",
    "days_model": "NOT_LOADED",
    "database": "READY"
}

try:
    load_models()
    system_status["efficientnet"] = "READY"
    system_status["days_model"] = "READY"
    system_status["yolo"] = "READY"
except Exception as error:
    print(f"Error loading RIPENX AI models: {error}")
    system_status["efficientnet"] = "ERROR"
    system_status["days_model"] = "ERROR"
    system_status["yolo"] = "ERROR"

# Global camera instance
cap = None

def get_camera():
    global cap, system_status
    if cap is None or not cap.isOpened():
        cap = cv2.VideoCapture(0)
        if cap.isOpened():
            system_status["camera"] = "CONNECTED"
        else:
            system_status["camera"] = "DISCONNECTED"
    return cap

# =========================================================
# REST API ENDPOINTS
# =========================================================

@app.route("/api/health", methods=["GET"])
def health_check():
    camera_active = get_camera().isOpened()
    telemetry = sensors.read_sensors()
    return jsonify({
        "status": "online",
        "system": system_status,
        "camera_active": camera_active,
        "sensors": telemetry,
        "timestamp": time.time()
    })

@app.route("/api/sensors", methods=["GET"])
def get_sensor_data():
    return jsonify(sensors.read_sensors())

@app.route("/api/scan", methods=["POST"])
def run_scan():
    start_time = time.time()
    sensor_data = sensors.read_sensors()
    temp_input = sensor_data["temperature"]
    hum_input = sensor_data["humidity"]

    camera = get_camera()
    frame = None

    # Check if image uploaded or camera frame captured
    if "image" in request.files:
        file = request.files["image"]
        np_img = np.frombuffer(file.read(), np.uint8)
        frame = cv2.imdecode(np_img, cv2.IMREAD_COLOR)
    elif camera.isOpened():
        ret, frame = camera.read()
        if not ret:
            frame = None

    if frame is None:
        return jsonify({
            "status": "no_frame",
            "message": "No camera frame was available.",
            "temperature": temp_input,
            "humidity": hum_input,
            "gas_response": sensor_data["gas_response"],
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "latency_ms": round((time.time() - start_time) * 1000, 1),
        })

    # Save the captured frame locally before inference.
    filename = f"capture_{uuid.uuid4().hex[:8]}.jpg"
    capture_path = captures_dir / filename
    cv2.imwrite(str(capture_path), frame)

    prediction = predict_frame(frame, temp_input, hum_input)
    detections = prediction.get("detections", [])
    primary = detections[0] if detections else {}
    status = prediction.get("status", "error")
    image_path = f"/captures/{filename}"
    common_payload = {
        "status": status,
        "temperature": temp_input,
        "humidity": hum_input,
        "gas_response": sensor_data["gas_response"],
        "image_path": image_path,
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
        "latency_ms": round((time.time() - start_time) * 1000, 1),
        "detections": detections,
    }

    if status != "result_ready" or not primary:
        common_payload["message"] = prediction.get(
            "error",
            "No fruit detection was available.",
        )
        return jsonify(common_payload)

    result_payload = {
        **common_payload,
        "status": "low_confidence" if not primary["accepted"] else "result_ready",
        "message": (
            "Low confidence prediction. Is this a valid fruit?"
            if not primary["accepted"]
            else None
        ),
        "fruit_name": primary["fruit"],
        "fruit_confidence": primary["fruit_confidence"],
        "ripeness_stage": primary["ripeness"],
        "ripeness_confidence": primary["ripeness_confidence"],
        "days_remaining": (
            round(primary["days_remaining"], 1)
            if primary["days_remaining"] is not None
            else None
        ),
        "days_range_formatted": primary["days_range"],
        "bbox": primary["bbox"],
    }

    if not primary["accepted"]:
        return jsonify(result_payload)

    # Save automatically to SQLite database history
    scan_id = db.add_scan(result_payload)
    result_payload["id"] = scan_id

    return jsonify(result_payload)

@app.route("/captures/<path:filename>", methods=["GET"])
def get_capture_image(filename):
    return send_from_directory(captures_dir, filename)

@app.route("/api/history", methods=["GET", "DELETE"])
def handle_history():
    if request.method == "DELETE":
        db.clear_history()
        return jsonify({"status": "cleared"})
    limit = int(request.args.get("limit", 50))
    return jsonify(db.get_history(limit=limit))

@app.route("/api/history/<int:scan_id>", methods=["DELETE"])
def delete_history_item(scan_id):
    success = db.delete_scan(scan_id)
    return jsonify({"status": "deleted" if success else "not_found"})

@app.route("/api/feedback", methods=["GET", "POST", "DELETE"])
def handle_feedback():
    if request.method == "POST":
        data = request.json
        feedback_id = db.add_feedback(data)
        return jsonify({"status": "saved", "id": feedback_id})
    elif request.method == "DELETE":
        feedback_id = int(request.args.get("id", 0))
        db.delete_feedback(feedback_id)
        return jsonify({"status": "deleted"})
    return jsonify(db.get_feedback_list())

@app.route("/api/visual_memory", methods=["GET"])
def get_visual_memory():
    return jsonify(db.get_all_visual_memories())

@app.route("/api/settings", methods=["GET", "POST"])
def handle_settings():
    if request.method == "POST":
        data = request.json
        db.update_settings(data)
        return jsonify({"status": "updated"})
    return jsonify(db.get_settings())

@app.route("/api/diagnostics", methods=["GET"])
def get_diagnostics():
    import psutil
    mem = psutil.virtual_memory()
    disk = psutil.disk_usage("/")
    return jsonify({
        "system": system_status,
        "ram_used_mb": round((mem.total - mem.available) / (1024 * 1024), 1),
        "ram_total_mb": round(mem.total / (1024 * 1024), 1),
        "disk_free_gb": round(disk.free / (1024 * 1024 * 1024), 1),
        "disk_total_gb": round(disk.total / (1024 * 1024 * 1024), 1),
        "python_version": sys.version.split()[0],
        "device": "Raspberry Pi 4B (Simulated/Physical)"
    })

if __name__ == "__main__":
    print("Starting RIPENX Python API Server on http://0.0.0.0:5000 ...")
    app.run(host="0.0.0.0", port=5000, debug=False, threaded=True)
