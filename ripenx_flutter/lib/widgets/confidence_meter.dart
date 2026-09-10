import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ConfidenceMeter extends StatelessWidget {
  final double confidence;
  final String label;

  const ConfidenceMeter({
    Key? key,
    required this.confidence,
    this.label = 'AI CONFIDENCE',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = (confidence * 100).clamp(0, 100).toInt();
    final barColor = confidence >= 0.75
        ? AppColors.freshGreen
        : confidence >= 0.50
            ? AppColors.warmGold
            : AppColors.softCoral;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.slate),
              ),
              Text(
                '$percentage%',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: barColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: confidence.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.mist,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
