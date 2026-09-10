import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/inference_result.dart';
import '../services/ripenx_api_service.dart';
import '../widgets/premium_app_bar.dart';
import '../widgets/premium_button.dart';

class FeedbackScreen extends StatefulWidget {
  final InferenceResult result;

  const FeedbackScreen({Key? key, required this.result}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final RipenxApiService _api = RipenxApiService();
  final TextEditingController _customFruitCtrl = TextEditingController();

  String _selectedFruit = 'banana';
  String _selectedStage = 'ripe';
  bool _isOtherFruit = false;
  bool _isSaving = false;

  final fruits = ['banana', 'mango', 'other'];
  final stages = ['unripe', 'semiripe', 'ripe', 'overripe', 'perished'];

  @override
  void initState() {
    super.initState();
    _selectedFruit = widget.result.fruitName != 'unknown' ? widget.result.fruitName : 'banana';
    _selectedStage = widget.result.ripenessStage != 'unknown' ? widget.result.ripenessStage : 'ripe';
  }

  Future<void> _submitCorrection() async {
    setState(() => _isSaving = true);
    final userFruitName = _isOtherFruit ? _customFruitCtrl.text.trim() : _selectedFruit;

    await _api.submitFeedback({
      'scan_id': widget.result.id,
      'image_path': widget.result.imagePath,
      'ai_fruit': widget.result.fruitName,
      'ai_ripeness': widget.result.ripenessStage,
      'ai_confidence': widget.result.fruitConfidence,
      'user_fruit': userFruitName.isNotEmpty ? userFruitName : 'other',
      'user_ripeness': _selectedStage,
      'temperature': widget.result.temperature,
      'humidity': widget.result.humidity,
      'gas_response': widget.result.gasResponse,
      'status': 'user_corrected'
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Correction saved to local verified feedback dataset!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(title: 'CORRECT RESULT'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAlignment.start,
            children: [
              const Text('What fruit is this?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.deepCharcoal)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: fruits.map((f) {
                  final isSel = (f == 'other' && _isOtherFruit) || (!_isOtherFruit && _selectedFruit == f);
                  return ChoiceChip(
                    label: Text(f.toUpperCase()),
                    selected: isSel,
                    selectedColor: AppColors.deepSage,
                    labelStyle: TextStyle(color: isSel ? Colors.white : AppColors.deepCharcoal, fontWeight: FontWeight.bold, fontSize: 11),
                    onSelected: (val) {
                      setState(() {
                        if (f == 'other') {
                          _isOtherFruit = true;
                        } else {
                          _isOtherFruit = false;
                          _selectedFruit = f;
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              if (_isOtherFruit) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: _customFruitCtrl,
                  decoration: InputDecoration(
                    labelText: 'Enter fruit name (e.g. Apple, Papaya)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Text('What is its condition?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.deepCharcoal)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: stages.map((s) {
                  final isSel = _selectedStage == s;
                  return ChoiceChip(
                    label: Text(s.toUpperCase()),
                    selected: isSel,
                    selectedColor: AppColors.sandalBlue,
                    labelStyle: TextStyle(color: isSel ? Colors.white : AppColors.deepCharcoal, fontWeight: FontWeight.bold, fontSize: 11),
                    onSelected: (val) {
                      setState(() => _selectedStage = s);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              PremiumButton(
                text: 'SAVE CORRECTION',
                isLoading: _isSaving,
                onPressed: _submitCorrection,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
