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

    final result = await _api.runScan();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (ctx) => ResultScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    BoxShadow(color: AppColors.shadowColor, blurRadius: 16, offset: Offset(0, 4)),
                  ],
                ),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.deepSage),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'AI ANALYSIS IN PROGRESS',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.deepCharcoal),
              ),
              const SizedBox(height: 10),
              Text(
                _stepMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: AppColors.slate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
