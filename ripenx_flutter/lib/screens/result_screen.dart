import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/inference_result.dart';
import '../widgets/maturity_spectrum.dart';
import '../widgets/confidence_meter.dart';
import '../widgets/sensor_card.dart';
import '../widgets/premium_button.dart';
import '../services/ripenx_api_service.dart';
import 'fruit_details_screen.dart';
import 'feedback_screen.dart';

class ResultScreen extends StatefulWidget {
  final InferenceResult result;

  const ResultScreen({Key? key, required this.result}) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final RipenxApiService _api = RipenxApiService();
  bool _feedbackSubmitted = false;

  @override
  Widget build(BuildContext context) {
    final baseUrl = 'http://localhost:5000';
    final isUnknown = widget.result.status == 'low_confidence' || widget.result.fruitName == 'unknown';
    final fruitDisplay = widget.result.fruitName.toUpperCase();
    final stageDisplay = widget.result.ripenessStage.toUpperCase();

    final stageColor = _getStageColor(widget.result.ripenessStage);
    final recommendation = _getRecommendation(widget.result.ripenessStage);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('RIPENX™ RESULT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.deepCharcoal),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAlignment.center,
            children: [
              // 1. Captured Fruit ROI Image Card
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.glassBorder, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: AppColors.shadowColor, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: widget.result.imagePath.isNotEmpty
                      ? Image.network(
                          '$baseUrl${widget.result.imagePath}',
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => _buildFruitPlaceholder(fruitDisplay),
                        )
                      : _buildFruitPlaceholder(fruitDisplay),
                ),
              ),

              const SizedBox(height: 14),

              // 2. Fruit Name & Stage Badge
              Text(
                isUnknown ? 'UNKNOWN FRUIT' : fruitDisplay,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: AppColors.deepCharcoal),
              ),

              const SizedBox(height: 6),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: stageColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: stageColor.withOpacity(0.4), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: stageColor, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(
                      stageDisplay,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: stageColor),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Text(
                recommendation,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate),
              ),

              const SizedBox(height: 16),

              // 3. Animated Maturity Spectrum
              MaturitySpectrum(currentStage: widget.result.ripenessStage),

              const SizedBox(height: 12),

              // 4. AI Confidence Meter
              ConfidenceMeter(confidence: widget.result.fruitConfidence, label: 'AI Detection Confidence'),

              const SizedBox(height: 12),

              // 5. Environmental Sensor Cards (Temp, Humidity, Gas Response)
              Row(
                children: [
                  Expanded(
                    child: SensorCard(
                      icon: Icons.thermostat_rounded,
                      label: 'Temperature',
                      value: widget.result.temperature.toStringAsFixed(1),
                      unit: '°C',
                      accentColor: AppColors.softCoral,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SensorCard(
                      icon: Icons.water_drop_rounded,
                      label: 'Humidity',
                      value: widget.result.humidity.toStringAsFixed(0),
                      unit: '%',
                      accentColor: AppColors.sandalBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SensorCard(
                      icon: Icons.air_rounded,
                      label: 'Gas Response',
                      value: widget.result.gasResponse.toString(),
                      unit: 'raw',
                      accentColor: AppColors.warmGold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 6. Days Remaining Prediction Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cloudBlue.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Column(
                  children: [
                    const Text('ESTIMATED DAYS TO RIPENESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.slate)),
                    const SizedBox(height: 4),
                    Text(
                      widget.result.daysRangeFormatted,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.deepCharcoal),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '* AI estimation based on current MLP and environmental conditions.',
                      style: TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: AppColors.slate),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 7. Feedback Prompt: "Is this result correct?"
              if (!_feedbackSubmitted)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warmIvory.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Is this result correct?',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.deepCharcoal),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _feedbackSubmitted = true);
                          _api.submitFeedback({
                            'scan_id': widget.result.id,
                            'image_path': widget.result.imagePath,
                            'ai_fruit': widget.result.fruitName,
                            'ai_ripeness': widget.result.ripenessStage,
                            'ai_confidence': widget.result.fruitConfidence,
                            'user_fruit': widget.result.fruitName,
                            'user_ripeness': widget.result.ripenessStage,
                            'temperature': widget.result.temperature,
                            'humidity': widget.result.humidity,
                            'gas_response': widget.result.gasResponse,
                            'status': 'verified_correct'
                          });
                        },
                        child: const Text('✓ YES', style: TextStyle(color: AppColors.freshGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (ctx) => FeedbackScreen(result: widget.result)),
                          );
                        },
                        child: const Text('✎ CORRECT', style: TextStyle(color: AppColors.softCoral, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Primary Action Buttons
              Row(
                children: [
                  Expanded(
                    child: PremiumButton(
                      text: 'SCAN AGAIN',
                      icon: Icons.refresh_rounded,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PremiumButton(
                      text: 'DETAILS',
                      icon: Icons.info_outline_rounded,
                      isSecondary: true,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => FruitDetailsScreen(result: widget.result)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFruitPlaceholder(String fruitDisplay) {
    final isBanana = fruitDisplay.contains('BANANA');
    return Container(
      color: AppColors.warmIvory,
      child: Center(
        child: Icon(
          isBanana ? Icons.eco_rounded : Icons.local_florist_rounded,
          size: 48,
          color: isBanana ? AppColors.warmGold : AppColors.freshGreen,
        ),
      ),
    );
  }

  Color _getStageColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'unripe':
        return AppColors.unripe;
      case 'semiripe':
        return AppColors.semiripe;
      case 'ripe':
        return AppColors.ripe;
      case 'overripe':
        return AppColors.overripe;
      case 'perished':
        return AppColors.perished;
      default:
        return AppColors.unknown;
    }
  }

  String _getRecommendation(String stage) {
    switch (stage.toLowerCase()) {
      case 'unripe':
        return 'Needs more time to ripen. Keep at room temperature.';
      case 'semiripe':
        return 'Approaching peak ripeness in 1-2 days.';
      case 'ripe':
        return '● READY TO EAT - Best time for consumption!';
      case 'overripe':
        return 'Consume soon or use for smoothies / baking.';
      case 'perished':
        return 'Past consumption timeframe.';
      default:
        return 'Place fruit clearly inside camera scan area.';
    }
  }
}
