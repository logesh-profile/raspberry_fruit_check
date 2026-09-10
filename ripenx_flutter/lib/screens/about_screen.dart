import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/ripenx_logo.dart';
import '../widgets/premium_app_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(title: 'ABOUT RIPENX™'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const RipenxLogo(fontSize: 26, showTagline: true),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.glassBorder)),
                child: const Text(
                  'RIPENX™ is an AI-powered fruit ripeness detection and shelf-life prediction device. Designed for 100% local offline execution on Raspberry Pi 4B hardware, combining YOLOv8 Nano object localization, PyTorch EfficientNetV2-S species and stage classification, and DaysRemainingMLP environmental degradation modeling.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.deepCharcoal, height: 1.5),
                ),
              ),
              const Spacer(),
              const Text('SOFTWARE VERSION 1.0.0 (BUILD 1)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.slate)),
              const SizedBox(height: 4),
              const Text('OFFLINE-FIRST AGRI-TECH HARDWARE PLATFORM', style: TextStyle(fontSize: 9, color: AppColors.mistText)),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
