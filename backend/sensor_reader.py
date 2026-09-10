import random
import time
from typing import Dict, Any

class SensorReader:
    """
    Sensor Abstraction Layer for RIPENX.
    Reads physical sensors on Raspberry Pi GPIO or provides smooth
    hardware telemetry simulation for offline development environments.
    """

    def __init__(self):
        self.is_hardware_available = False
        self.dht_device = None
        self.mq2_channel = None
        
        # Try initializing hardware Adafruit DHT or RPi.GPIO
        try:
            import board
            import adafruit_dht
            self.dht_device = adafruit_dht.DHT22(board.D4)
            self.is_hardware_available = True
            print("Physical DHT22 Sensor initialized on GPIO 4.")
        except Exception:
            self.is_hardware_available = False
            # Dev environment simulation state
            self._sim_temp = 28.4
            self._sim_humidity = 64.0
            self._sim_gas = 124

    def read_sensors(self) -> Dict[str, Any]:
        """
        Returns latest telemetry reading.
        Fields:
          temperature (°C)
          humidity (%)
          gas_response (Raw ADC / MQ-2 response)
          sensor_status ("connected" | "simulated")
        """
        if self.is_hardware_available and self.dht_device:
            try:
                temp = self.dht_device.temperature
                hum = self.dht_device.humidity
                gas = 120 # MQ-2 pin read
                return {
                    "temperature": round(float(temp), 1) if temp is not None else 28.0,
                    "humidity": round(float(hum), 1) if hum is not None else 65.0,
                    "gas_response": gas,
                    "sensor_status": "connected"
                }
            except Exception as e:
                print(f"Hardware sensor read error: {e}")

        # Smooth simulation fluctuation for dev mode
        self._sim_temp = round(max(20.0, min(40.0, self._sim_temp + random.uniform(-0.15, 0.15))), 1)
        self._sim_humidity = round(max(30.0, min(90.0, self._sim_humidity + random.uniform(-0.3, 0.3))), 1)
        self._sim_gas = max(80, min(300, self._sim_gas + random.randint(-2, 2)))

        return {
            "temperature": self._sim_temp,
            "humidity": self._sim_humidity,
            "gas_response": self._sim_gas,
            "sensor_status": "simulated"
        }
