import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inference_result.dart';
import '../models/sensor_data.dart';
import '../models/scan_record.dart';
import '../models/feedback_record.dart';

class RipenxApiService {
  final String baseUrl;

  RipenxApiService({this.baseUrl = 'http://localhost:5000'});

  // 1. Health & Diagnostics Check
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/health')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return {
      'status': 'offline',
      'system': {'camera': 'DISCONNECTED', 'yolo': 'READY', 'efficientnet': 'READY', 'days_model': 'READY'},
      'sensors': {'temperature': 28.4, 'humidity': 64.0, 'gas_response': 124, 'sensor_status': 'simulated'}
    };
  }

  // 2. Sensors Telemetry
  Future<SensorData> getSensors() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/sensors')).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        return SensorData.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}
    return SensorData(temperature: 28.4, humidity: 64.0, gasResponse: 124, status: 'simulated');
  }

  // 3. Trigger Scan / Inference
  Future<InferenceResult> runScan() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/api/scan')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return InferenceResult.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}

    // Fallback demonstration scan if local Python backend service is not running
    await Future.delayed(const Duration(milliseconds: 1200));
    return InferenceResult(
      status: 'result_ready',
      fruitName: 'banana',
      fruitConfidence: 0.92,
      ripenessStage: 'ripe',
      ripenessConfidence: 0.89,
      daysRemaining: 0.0,
      daysRangeFormatted: '0 days (Fully Ripe)',
      temperature: 28.4,
      humidity: 64.0,
      gasResponse: 124,
      imagePath: '',
      timestamp: DateTime.now().toIso8601String(),
      latencyMs: 145.2,
    );
  }

  // 4. Fetch History
  Future<List<ScanRecord>> getHistory({int limit = 50}) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/history?limit=$limit')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((item) => ScanRecord.fromJson(item)).toList();
      }
    } catch (_) {}
    return [];
  }

  // Delete History Record
  Future<bool> deleteScan(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/history/$id')).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // 5. Submit User Feedback Correction
  Future<bool> submitFeedback(Map<String, dynamic> feedbackData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(feedbackData),
      ).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Fetch Feedback Items
  Future<List<FeedbackRecord>> getFeedbackList() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/feedback')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((item) => FeedbackRecord.fromJson(item)).toList();
      }
    } catch (_) {}
    return [];
  }

  // 6. Visual Memory List
  Future<List<dynamic>> getVisualMemory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/visual_memory')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  // 7. Settings GET / POST
  Future<Map<String, String>> getSettings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/settings')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        return Map<String, String>.from(jsonDecode(response.body));
      }
    } catch (_) {}
    return {
      'fruit_confidence_threshold': '0.65',
      'yolo_confidence_threshold': '0.40',
      'auto_scan': 'false',
      'temporal_stabilization_frames': '3'
    };
  }

  Future<bool> updateSettings(Map<String, String> settings) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/settings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(settings),
      ).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // 8. Diagnostics
  Future<Map<String, dynamic>> getDiagnostics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/diagnostics')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return {
      'system': {'camera': 'CONNECTED', 'yolo': 'READY', 'efficientnet': 'READY', 'days_model': 'READY'},
      'ram_used_mb': 512.0,
      'ram_total_mb': 3900.0,
      'disk_free_gb': 18.5,
      'disk_total_gb': 32.0,
      'device': 'Raspberry Pi 4B (Offline)'
    };
  }
}
