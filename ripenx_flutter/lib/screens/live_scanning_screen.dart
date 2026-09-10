import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/camera_chamber.dart';
import '../widgets/premium_button.dart';
import '../services/ripenx_api_service.dart';
import '../models/inference_result.dart';
import 'analyzing_screen.dart';
import 'result_screen.dart';

class LiveScanningScreen extends StatefulWidget {
  const LiveScanningScreen({Key? key}) : super(key: key);

  @override
  State<LiveScanningScreen> createState() => _LiveScanningScreenState();
}

class _LiveScanningScreenState extends State<LiveScanningScreen> {
  final RipenxApiService _api = RipenxApiService();
  bool _isScanning = true;
  String _statusText = 'Analyzing';

  @override
  void initState() {
    super.initState();
    _startInferencePipeline();
  }

  Future<void> _startInferencePipeline() async {
    // 1. Trigger scanning simulation / backend REST request
    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;

    // Route through Analyzing Transition Screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (ctx) => const AnalyzingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header Back Button
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.deepCharcoal),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('LIVE SCANNING', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.deepCharcoal)),
                ],
              ),

              const SizedBox(height: 20),

              // Live Scanning Chamber Viewport
              Expanded(
                child: Center(
                  child: CameraChamber(
                    imagePath: '',
                    status: _statusText,
                    isScanning: _isScanning,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Cancel Button
              PremiumButton(
                text: 'CANCEL SCAN',
                isSecondary: true,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
