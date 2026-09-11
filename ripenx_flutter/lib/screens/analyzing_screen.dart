import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/ripenx_api_service.dart';
import '../models/inference_result.dart';
import 'result_screen.dart';

class AnalyzingScreen extends StatefulWidget {
  const AnalyzingScreen({Key? key}) : super(key: key);

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  final RipenxApiService _api = RipenxApiService();
  String _stepMessage = 'Extracting Visual Features (EfficientNetV2-S)...';
  String? _errorMessage;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _processInference();
  }

  Future<void> _processInference() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _stepMessage = 'Evaluating Environmental Sensors & MLP...');
    }

    InferenceResult result;
    try {
      result = await _api.runScan();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage =
            'Unable to complete scan.\nPlease check the camera, backend, or sensor connection.\n\nDetail: $e';
      });
      return;
    }

    if (!mounted) return;

    // Backend returned a non-result status (no_fruit, no_frame, error, etc.)
    if (result.status != 'result_ready' && result.status != 'low_confidence') {
      setState(() {
        _hasError = true;
        _errorMessage =
            'Unable to complete scan. ${_statusMessage(result.status)}\n\n'
            'Please check the camera, backend, or sensor connection.';
      });
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (ctx) => ResultScreen(result: result)),
    );
  }

  String _statusMessage(String status) {
    switch (status) {
      case 'no_fruit':
        return 'No fruit was detected in the camera frame.';
      case 'no_frame':
        return 'No camera frame was available.';
      case 'invalid_sensor_values':
        return 'Sensor values are invalid or unavailable.';
      default:
        return 'Backend returned status: $status.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        backgroundColor: AppColors.pearlWhite,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 56, color: AppColors.softCoral),
                const SizedBox(height: 24),
                const Text(
                  'SCAN FAILED',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.deepCharcoal),
                ),
                const SizedBox(height: 14),
                Text(
                  _errorMessage ?? 'An unexpected error occurred.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.slate, height: 1.6),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.popUntil(context, (r) => r.isFirst),
                      icon: const Icon(Icons.home_rounded, size: 16),
                      label: const Text('GO BACK'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                          _errorMessage = null;
                          _stepMessage =
                              'Extracting Visual Features (EfficientNetV2-S)...';
                        });
                        _processInference();
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('RETRY'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepSage,
                          foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.pearlWhite,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.glassBorder, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 16,
                        offset: Offset(0, 4)),
                  ],
                ),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                      strokeWidth: 3, color: AppColors.deepSage),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'AI ANALYSIS IN PROGRESS',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.deepCharcoal),
              ),
              const SizedBox(height: 10),
              Text(
                _stepMessage,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 11, color: AppColors.slate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

