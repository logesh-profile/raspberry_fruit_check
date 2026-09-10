import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SensorCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final String status;
  final Color accentColor;

  const SensorCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    this.status = 'NORMAL',
    this.accentColor = AppColors.oceanSlate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: accentColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: AppColors.slate),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.deepCharcoal),
                    ),
                    if (unit.isNotEmpty) ...[
                      const SizedBox(width: 2),
                      Text(
                        unit,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.slate),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
