class FeedbackRecord {
  final int id;
  final int? scanId;
  final String imagePath;
  final String aiFruit;
  final String aiRipeness;
  final double aiConfidence;
  final String userFruit;
  final String userRipeness;
  final double temperature;
  final double humidity;
  final int gasResponse;
  final String timestamp;
  final String status;

  FeedbackRecord({
    required this.id,
    this.scanId,
    required this.imagePath,
    required this.aiFruit,
    required this.aiRipeness,
    required this.aiConfidence,
    required this.userFruit,
    required this.userRipeness,
    required this.temperature,
    required this.humidity,
    required this.gasResponse,
    required this.timestamp,
    required this.status,
  });

  factory FeedbackRecord.fromJson(Map<String, dynamic> json) {
    return FeedbackRecord(
      id: json['id'] as int,
      scanId: json['scan_id'] as int?,
      imagePath: (json['image_path'] ?? '').toString(),
      aiFruit: (json['ai_fruit'] ?? '').toString(),
      aiRipeness: (json['ai_ripeness'] ?? '').toString(),
      aiConfidence: (json['ai_confidence'] ?? 0.0).toDouble(),
      userFruit: (json['user_fruit'] ?? '').toString(),
      userRipeness: (json['user_ripeness'] ?? '').toString(),
      temperature: (json['temperature'] ?? 28.0).toDouble(),
      humidity: (json['humidity'] ?? 65.0).toDouble(),
      gasResponse: (json['gas_response'] ?? 120) as int,
      timestamp: (json['timestamp'] ?? '').toString(),
      status: (json['status'] ?? 'verified').toString(),
    );
  }
}
