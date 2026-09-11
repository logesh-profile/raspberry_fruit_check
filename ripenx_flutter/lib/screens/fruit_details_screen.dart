import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/inference_result.dart';
import '../widgets/premium_app_bar.dart';

class FruitDetailsScreen extends StatelessWidget {
  final InferenceResult result;

  const FruitDetailsScreen({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fruit = result.fruitName.toUpperCase();
    final stage = result.ripenessStage.toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumAppBar(title: '$fruit DETAILS'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailCard(
                title: 'STORAGE RECOMMENDATION',
                icon: Icons.kitchen_rounded,
                content: stage.contains('RIPE')
                    ? 'Store in a cool dry area (13-15°C) or refrigerate to extend shelf life.'
                    : 'Keep at ambient room temperature (20-25°C). Do not refrigerate while unripe.',
              ),
              const SizedBox(height: 14),
              _buildDetailCard(
                title: 'GAS SENSITIVITY & ETHYLENE RISK',
                icon: Icons.bubble_chart_rounded,
                content: 'Fruit releases natural ethylene gas as it ripens. Keep away from sensitive produce.',
              ),
              const SizedBox(height: 14),
              _buildDetailCard(
                title: 'MODEL INFERENCE SPECS',
                icon: Icons.memory_rounded,
                content: 'Backbone: EfficientNetV2-S\nDays Model: 7-Feature MLP\nLatency: ${result.latencyMs.toStringAsFixed(1)} ms',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard({required String title, required IconData icon, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.deepSage),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.slate)),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 13, color: AppColors.deepCharcoal, height: 1.4)),
        ],
      ),
    );
  }
}
