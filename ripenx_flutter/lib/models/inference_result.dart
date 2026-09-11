class InferenceResult {
  final int? id;
  final String status; // 'result_ready' | 'low_confidence' | 'no_fruit' | 'error'
  final String fruitName;
  final double fruitConfidence;
  final String ripenessStage; // 'unripe' | 'semiripe' | 'ripe' | 'overripe' | 'perished' | 'unknown'
  final double ripenessConfidence;
  final double? daysRemaining;
  final String daysRangeFormatted;
  final double temperature;
  final double humidity;
  final int gasResponse;
  final String imagePath;
  final String timestamp;
  final double latencyMs;

  InferenceResult({
    this.id,
    required this.status,
    required this.fruitName,
    required this.fruitConfidence,
    required this.ripenessStage,
    required this.ripenessConfidence,
    this.daysRemaining,
    required this.daysRangeFormatted,
    required this.temperature,
    required this.humidity,
    required this.gasResponse,
    required this.imagePath,
    required this.timestamp,
    this.latencyMs = 0.0,
  });

  factory InferenceResult.fromJson(Map<String, dynamic> json) {
    return InferenceResult(
      id: json['id'] as int?,
      status: (json['status'] ?? 'error').toString(),
      fruitName: (json['fruit_name'] ?? 'unknown').toString(),
      fruitConfidence: (json['fruit_confidence'] ?? 0.0).toDouble(),
      ripenessStage: (json['ripeness_stage'] ?? 'unknown').toString(),
      ripenessConfidence: (json['ripeness_confidence'] ?? 0.0).toDouble(),
      daysRemaining: json['days_remaining'] != null ? (json['days_remaining'] as num).toDouble() : null,
      daysRangeFormatted: (json['days_range_formatted'] ?? 'N/A').toString(),
      temperature: (json['temperature'] ?? 28.0).toDouble(),
      humidity: (json['humidity'] ?? 65.0).toDouble(),
      gasResponse: (json['gas_response'] ?? 120) as int,
      imagePath: (json['image_path'] ?? '').toString(),
      timestamp: (json['timestamp'] ?? DateTime.now().toIso8601String()).toString(),
      latencyMs: (json['latency_ms'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'fruit_name': fruitName,
      'fruit_confidence': fruitConfidence,
      'ripeness_stage': ripenessStage,
      'ripeness_confidence': ripenessConfidence,
      'days_remaining': daysRemaining,
      'days_range_formatted': daysRangeFormatted,
      'temperature': temperature,
      'humidity': humidity,
      'gas_response': gasResponse,
      'image_path': imagePath,
      'timestamp': timestamp,
      'latency_ms': latencyMs,
    };
  }
}
