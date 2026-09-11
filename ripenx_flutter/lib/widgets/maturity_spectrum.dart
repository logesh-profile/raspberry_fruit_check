import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MaturitySpectrum extends StatelessWidget {
  final String currentStage;

  const MaturitySpectrum({Key? key, required this.currentStage}) : super(key: key);

  static const stages = ['unripe', 'semiripe', 'ripe', 'overripe'];

  @override
  Widget build(BuildContext context) {
    final normalizedStage = currentStage.toLowerCase();
    final activeIndex = stages.indexOf(normalizedStage).clamp(0, stages.length - 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.warmIvory.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MATURITY SPECTRUM',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.slate),
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              // Connecting Spectrum Line
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.unripe,
                      AppColors.semiripe,
                      AppColors.ripe,
                      AppColors.overripe,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Stage Nodes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(stages.length, (index) {
                  final isCurrent = index == activeIndex;
                  final stageColor = _getStageColor(stages[index]);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: isCurrent ? 14 : 8,
                        height: isCurrent ? 14 : 8,
                        decoration: BoxDecoration(
                          color: isCurrent ? stageColor : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: stageColor,
                            width: isCurrent ? 3 : 2,
                          ),
                          boxShadow: isCurrent
                              ? [BoxShadow(color: stageColor.withOpacity(0.5), blurRadius: 6, spreadRadius: 1)]
                              : [],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        stages[index].toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? AppColors.deepCharcoal : AppColors.slate,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStageColor(String stage) {
    switch (stage) {
      case 'unripe':
        return AppColors.unripe;
      case 'semiripe':
        return AppColors.semiripe;
      case 'ripe':
        return AppColors.ripe;
      case 'overripe':
        return AppColors.overripe;
      default:
        return AppColors.slate;
    }
  }
}
