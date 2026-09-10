import 'inference_result.dart';

class ScanRecord {
  final int id;
  final String fruitName;
  final double fruitConfidence;
  final String ripenessStage;
  final double ripenessConfidence;
  final double? daysRemaining;
  final String daysRangeFormatted;
  final double temperature;
  final double humidity;
  final int gasResponse;
  final String imagePath;
  final String timestamp;
  final bool isVerified;

  ScanRecord({
    required this.id,
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
    this.isVerified = false,
  });

  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    return ScanRecord(
      id: json['id'] as int,
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
      timestamp: (json['timestamp'] ?? '').toString(),
      isVerified: (json['is_verified'] ?? 0) == 1,
    );
  }
}
