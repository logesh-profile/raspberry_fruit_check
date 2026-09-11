import random
import time
import math
from typing import Dict, Any

class SensorReader:
    """
    Sensor Abstraction Layer for RIPENX.
    Reads physical sensors on Raspberry Pi GrovePi or provides smooth
    hardware telemetry simulation for offline development environments.
    """

    def __init__(self):
        self.is_hardware_available = False
        self.grovepi = None
        
        self.dht_pin = 8    # GrovePi D8
        self.dht_type = 1   # DHT22 (0 for DHT11)
        self.gas_pin = 0    # GrovePi A0
        
        # Try initializing hardware GrovePi
        try:
            import grovepi
            self.grovepi = grovepi
            self.is_hardware_available = True
            print("Physical GrovePi initialized (DHT22 on D8, Gas on A0).")
        except Exception as e:
            self.is_hardware_available = False
            print(f"Warning: Failed to initialize physical GrovePi sensors: {e}")
            
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
        if self.is_hardware_available and self.grovepi:
            try:
                # Read DHT22 from GrovePi D8
                [t, h] = self.grovepi.dht(self.dht_pin, self.dht_type)
                
                # Read Analog Gas Sensor from GrovePi A0
                g = self.grovepi.analogRead(self.gas_pin)
                
                # Verify read validity (grovepi sometimes returns nan on error)
                if (t is not None and h is not None and g is not None and
                    not math.isnan(t) and not math.isnan(h) and not math.isnan(g) and
                    not math.isinf(t) and not math.isinf(h) and not math.isinf(g) and
                    -100 < t < 100 and 0 <= h <= 100 and g >= 0):
                    return {
                        "temperature": round(float(t), 1),
                        "humidity": round(float(h), 1),
                        "gas_response": int(g),
                        "sensor_status": "connected"
                    }
                else:
                    print("GrovePi returned invalid nan/out-of-bounds sensor values.")
            except Exception as e:
                print(f"Hardware sensor read error: {e}")

        # Smooth simulation fluctuation for dev mode or fallback
        self._sim_temp = round(max(20.0, min(40.0, self._sim_temp + random.uniform(-0.15, 0.15))), 1)
        self._sim_humidity = round(max(30.0, min(90.0, self._sim_humidity + random.uniform(-0.3, 0.3))), 1)
        self._sim_gas = max(80, min(300, self._sim_gas + random.randint(-2, 2)))

        return {
            "temperature": self._sim_temp,
            "humidity": self._sim_humidity,
            "gas_response": self._sim_gas,
            "sensor_status": "simulated"
        }
