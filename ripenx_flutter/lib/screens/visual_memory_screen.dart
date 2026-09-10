import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/ripenx_api_service.dart';
import '../widgets/premium_app_bar.dart';

class VisualMemoryScreen extends StatefulWidget {
  const VisualMemoryScreen({Key? key}) : super(key: key);

  @override
  State<VisualMemoryScreen> createState() => _VisualMemoryScreenState();
}

class _VisualMemoryScreenState extends State<VisualMemoryScreen> {
  final RipenxApiService _api = RipenxApiService();
  List<dynamic> _memories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMemory();
  }

  Future<void> _loadMemory() async {
    final list = await _api.getVisualMemory();
    if (mounted) {
      setState(() {
        _memories = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = 'http://localhost:5000';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(title: 'VISUAL MEMORY'),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.deepSage))
            : _memories.isEmpty
                ? const Center(child: Text('No visual memory samples recorded yet.', style: TextStyle(color: AppColors.slate)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _memories.length,
                    itemBuilder: (ctx, i) {
                      final item = _memories[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(color: AppColors.warmIvory, borderRadius: BorderRadius.circular(12)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network('$baseUrl${item['image_path']}', fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.memory_rounded, color: AppColors.sandalBlue)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAlignment.start,
                                children: [
                                  Text('${item['fruit_name'].toString().toUpperCase()} (${item['ripeness_stage'].toString().toUpperCase()})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.deepCharcoal)),
                                  const SizedBox(height: 2),
                                  Text('Visual Embedding: 64-dim vector', style: const TextStyle(fontSize: 10, color: AppColors.slate)),
                                  Text(item['timestamp'] ?? '', style: const TextStyle(fontSize: 9, color: AppColors.mistText)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
