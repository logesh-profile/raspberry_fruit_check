import sqlite3
import json
from pathlib import Path
from typing import Dict, List, Any, Optional
from datetime import datetime

class RIPENXDatabaseManager:
    """
    SQLite database manager for RIPENX local storage.
    Handles:
      - Scan History
      - Verified Feedback / User Corrections
      - Visual Memory Embeddings
      - Application Settings
    """

    def __init__(self, db_path: Optional[Path] = None):
        if db_path is None:
            project_root = Path(__file__).resolve().parents[1]
            data_dir = project_root / "data"
            data_dir.mkdir(parents=True, exist_ok=True)
            db_path = data_dir / "ripenx.db"
        
        self.db_path = db_path
        self._init_db()

    def _get_connection(self) -> sqlite3.Connection:
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        return conn

    def _init_db(self):
        with self._get_connection() as conn:
            cursor = conn.cursor()
            
            # 1. Scan History Table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS scan_history (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    fruit_name TEXT NOT NULL,
                    fruit_confidence REAL NOT NULL,
                    ripeness_stage TEXT NOT NULL,
                    ripeness_confidence REAL NOT NULL,
                    days_remaining REAL,
                    days_range_formatted TEXT,
                    temperature REAL,
                    humidity REAL,
                    gas_response INTEGER,
                    image_path TEXT,
                    timestamp TEXT NOT NULL,
                    is_verified INTEGER DEFAULT 0
                )
            """)

            # 2. Verified Feedback / Training Data Table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS verified_feedback (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    scan_id INTEGER,
                    image_path TEXT NOT NULL,
                    ai_fruit TEXT NOT NULL,
                    ai_ripeness TEXT NOT NULL,
                    ai_confidence REAL NOT NULL,
                    user_fruit TEXT NOT NULL,
                    user_ripeness TEXT NOT NULL,
                    temperature REAL,
                    humidity REAL,
                    gas_response INTEGER,
                    timestamp TEXT NOT NULL,
                    status TEXT DEFAULT 'verified',
                    FOREIGN KEY (scan_id) REFERENCES scan_history (id)
                )
            """)

            # 3. Visual Memory Table (Visual Embeddings)
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS visual_memory (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    image_path TEXT NOT NULL,
                    fruit_name TEXT NOT NULL,
                    ripeness_stage TEXT NOT NULL,
                    embedding_json TEXT NOT NULL,
                    timestamp TEXT NOT NULL
                )
            """)

            # 4. Settings Table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS settings (
                    key TEXT PRIMARY KEY,
                    value TEXT NOT NULL
                )
            """)

            # Insert default settings if empty
            defaults = {
                "fruit_confidence_threshold": "0.65",
                "yolo_confidence_threshold": "0.40",
                "auto_scan": "false",
                "temporal_stabilization_frames": "3",
                "temperature_default": "28.0",
                "humidity_default": "65.0",
                "camera_fps": "30",
                "sound_enabled": "true"
            }
            for k, v in defaults.items():
                cursor.execute("INSERT OR IGNORE INTO settings (key, value) VALUES (?, ?)", (k, v))
            
            conn.commit()

    # =========================================================
    # SCAN HISTORY METHODS
    # =========================================================

    def add_scan(self, scan_data: Dict[str, Any]) -> int:
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO scan_history (
                    fruit_name, fruit_confidence, ripeness_stage, ripeness_confidence,
                    days_remaining, days_range_formatted, temperature, humidity,
                    gas_response, image_path, timestamp, is_verified
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                scan_data.get("fruit_name", "unknown"),
                float(scan_data.get("fruit_confidence", 0.0)),
                scan_data.get("ripeness_stage", "unknown"),
                float(scan_data.get("ripeness_confidence", 0.0)),
                scan_data.get("days_remaining"),
                scan_data.get("days_range_formatted", "N/A"),
                scan_data.get("temperature", 28.0),
                scan_data.get("humidity", 65.0),
                scan_data.get("gas_response", 120),
                scan_data.get("image_path", ""),
                scan_data.get("timestamp", datetime.now().isoformat()),
                1 if scan_data.get("is_verified") else 0
            ))
            conn.commit()
            return cursor.lastrowid

    def get_history(self, limit: int = 50, offset: int = 0) -> List[Dict[str, Any]]:
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                SELECT * FROM scan_history 
                ORDER BY id DESC 
                LIMIT ? OFFSET ?
            """, (limit, offset))
            return [dict(row) for row in cursor.fetchall()]

    def delete_scan(self, scan_id: int) -> bool:
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM scan_history WHERE id = ?", (scan_id,))
            conn.commit()
            return cursor.rowcount > 0

    def clear_history(self) -> bool:
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM scan_history")
            conn.commit()
            return True

    # =========================================================
    # FEEDBACK & TRAINING DATA METHODS
    # =========================================================

    def add_feedback(self, feedback_data: Dict[str, Any]) -> int:
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO verified_feedback (
                    scan_id, image_path, ai_fruit, ai_ripeness, ai_confidence,
                    user_fruit, user_ripeness, temperature, humidity, gas_response, timestamp, status
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                feedback_data.get("scan_id"),
                feedback_data.get("image_path", ""),
                feedback_data.get("ai_fruit", "unknown"),
                feedback_data.get("ai_ripeness", "unknown"),
                float(feedback_data.get("ai_confidence", 0.0)),
                feedback_data.get("user_fruit", "unknown"),
                feedback_data.get("user_ripeness", "unknown"),
                feedback_data.get("temperature", 28.0),
                feedback_data.get("humidity", 65.0),
                feedback_data.get("gas_response", 120),
                feedback_data.get("timestamp", datetime.now().isoformat()),
                feedback_data.get("status", "verified")
            ))
            feedback_id = cursor.lastrowid

            if feedback_data.get("scan_id"):
                cursor.execute("UPDATE scan_history SET is_verified = 1 WHERE id = ?", (feedback_data["scan_id"],))

            conn.commit()
            return feedback_id

    def get_feedback_list(self, limit: int = 100) -> List[Dict[str, Any]]:
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM verified_feedback ORDER BY id DESC LIMIT ?", (limit,))
            return [dict(row) for row in cursor.fetchall()]

    def delete_feedback(self, feedback_id: int) -> bool:
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM verified_feedback WHERE id = ?", (feedback_id,))
            conn.commit()
            return cursor.rowcount > 0

    # =========================================================
    # VISUAL MEMORY METHODS
    # =========================================================

    def add_visual_memory(self, image_path: str, fruit_name: str, ripeness_stage: str, embedding: List[float]) -> int:
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO visual_memory (image_path, fruit_name, ripeness_stage, embedding_json, timestamp)
                VALUES (?, ?, ?, ?, ?)
            """, (
                image_path,
                fruit_name,
                ripeness_stage,
                json.dumps(embedding),
                datetime.now().isoformat()
            ))
            conn.commit()
            return cursor.lastrowid

    def get_all_visual_memories(self) -> List[Dict[str, Any]]:
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM visual_memory ORDER BY id DESC")
            rows = cursor.fetchall()
            result = []
            for r in rows:
                item = dict(r)
                item["embedding"] = json.loads(item["embedding_json"])
                result.append(item)
            return result

    # =========================================================
    # SETTINGS METHODS
    # =========================================================

    def get_settings(self) -> Dict[str, str]:
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT key, value FROM settings")
            return {row["key"]: row["value"] for row in cursor.fetchall()}

    def update_settings(self, settings_dict: Dict[str, str]) -> bool:
        with self._get_connection() as conn:
            cursor = conn.cursor()
            for k, v in settings_dict.items():
                cursor.execute("""
                    INSERT INTO settings (key, value) VALUES (?, ?)
                    ON CONFLICT(key) DO UPDATE SET value = excluded.value
                """, (str(k), str(v)))
            conn.commit()
            return True
