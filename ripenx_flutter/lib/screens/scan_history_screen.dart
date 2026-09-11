import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/scan_record.dart';
import '../services/ripenx_api_service.dart';
import '../widgets/premium_app_bar.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  final RipenxApiService _api = RipenxApiService();
  List<ScanRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final list = await _api.getHistory();
    if (mounted) {
      setState(() {
        _records = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = 'http://localhost:5000';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(title: 'SCAN HISTORY'),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.deepSage))
            : _records.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _records.length,
                    itemBuilder: (ctx, i) {
                      final item = _records[i];
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
                              decoration: BoxDecoration(
                                color: AppColors.warmIvory,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: item.imagePath.isNotEmpty
                                    ? Image.network('$baseUrl${item.imagePath}', fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.eco_rounded, color: AppColors.freshGreen))
                                    : const Icon(Icons.eco_rounded, color: AppColors.freshGreen),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.fruitName.toUpperCase(),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.deepCharcoal),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.ripenessStage.toUpperCase()} • ${item.daysRangeFormatted}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.slate),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.timestamp,
                                    style: const TextStyle(fontSize: 9, color: AppColors.mistText),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.softCoral, size: 20),
                              onPressed: () async {
                                await _api.deleteScan(item.id);
                                _loadHistory();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.history_rounded, size: 48, color: AppColors.slate),
          SizedBox(height: 12),
          Text('No scan history records found', style: TextStyle(color: AppColors.slate, fontSize: 13)),
        ],
      ),
    );
  }
}
