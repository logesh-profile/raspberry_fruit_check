import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_app_bar.dart';

class AiSettingsScreen extends StatelessWidget {
  const AiSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(title: 'AI & DETECTION SETTINGS'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildModelTile('YOLOv8 Nano (yolov8n.pt)', 'Object Detection & Bounding Box ROI Crop', 'READY'),
            _buildModelTile('EfficientNetV2-S (best_model.pth)', 'Dual-Head Fruit & Ripeness Classification', 'READY'),
            _buildModelTile('DaysRemainingMLP (days_model.pth)', 'Environmental Degradation Regression', 'READY'),
            const SizedBox(height: 16),
            const Text('Supported Fruit Classes: BANANA, MANGO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.slate)),
            const Text('Supported Ripeness Classes: UNRIPE, RIPE, OVERRIPE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.slate)),
          ],
        ),
      ),
    );
  }

  Widget _buildModelTile(String name, String role, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.glassBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.deepCharcoal)),
              Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.freshGreen)),
            ],
          ),
          const SizedBox(height: 4),
          Text(role, style: const TextStyle(fontSize: 10, color: AppColors.slate)),
        ],
      ),
    );
  }
}
