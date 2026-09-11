import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/feedback_record.dart';
import '../services/ripenx_api_service.dart';
import '../widgets/premium_app_bar.dart';

class TrainingDataScreen extends StatefulWidget {
  const TrainingDataScreen({Key? key}) : super(key: key);

  @override
  State<TrainingDataScreen> createState() => _TrainingDataScreenState();
}

class _TrainingDataScreenState extends State<TrainingDataScreen> {
  final RipenxApiService _api = RipenxApiService();
  List<FeedbackRecord> _feedbackList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  Future<void> _loadFeedback() async {
    final list = await _api.getFeedbackList();
    if (mounted) {
      setState(() {
        _feedbackList = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(title: 'FEEDBACK DATASET'),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.deepSage))
            : _feedbackList.isEmpty
                ? const Center(child: Text('No verified user feedback data stored yet.', style: TextStyle(color: AppColors.slate)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _feedbackList.length,
                    itemBuilder: (ctx, i) {
                      final item = _feedbackList[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('VERIFIED TARGET: ${item.userFruit.toUpperCase()} (${item.userRipeness.toUpperCase()})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.deepSage)),
                                Text(item.status, style: const TextStyle(fontSize: 10, color: AppColors.sandalBlue, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Original AI Prediction: ${item.aiFruit} / ${item.aiRipeness} (${(item.aiConfidence * 100).toStringAsFixed(0)}%)', style: const TextStyle(fontSize: 11, color: AppColors.slate)),
                            Text('Timestamp: ${item.timestamp}', style: const TextStyle(fontSize: 9, color: AppColors.mistText)),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
