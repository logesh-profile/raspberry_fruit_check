import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AiStatusPill extends StatelessWidget {
  final String status;

  const AiStatusPill({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusMap = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: statusMap['bg'] as Color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (statusMap['color'] as Color).withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: statusMap['color'] as Color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            (statusMap['text'] as String).toUpperCase(),
            style: TextStyle(
              color: statusMap['color'] as Color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'searching':
      case 'camera ready':
        return {'text': 'Camera Ready', 'color': AppColors.sandalBlue, 'bg': const Color(0xFF1E2A2E)};
      case 'analyzing':
      case 'fruit detected':
        return {'text': 'Analyzing...', 'color': AppColors.warmGold, 'bg': const Color(0xFF2E2B1E)};
      case 'result_ready':
      case 'result ready':
        return {'text': 'Result Ready', 'color': AppColors.freshGreen, 'bg': const Color(0xFF1E2E21)};
      case 'low_confidence':
      case 'low confidence':
        return {'text': 'Low Confidence', 'color': AppColors.softCoral, 'bg': const Color(0xFF2E1E1E)};
      default:
        return {'text': status, 'color': AppColors.slate, 'bg': const Color(0xFF222627)};
    }
  }
}
