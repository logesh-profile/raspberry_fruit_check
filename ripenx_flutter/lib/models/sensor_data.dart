class SensorData {
  final double temperature;
  final double humidity;
  final int gasResponse;
  final String status;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.gasResponse,
    required this.status,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: (json['temperature'] ?? 28.0).toDouble(),
      humidity: (json['humidity'] ?? 65.0).toDouble(),
      gasResponse: (json['gas_response'] ?? 120) as int,
      status: (json['sensor_status'] ?? 'simulated').toString(),
    );
  }
}
