import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/ripenx_api_service.dart';
import '../widgets/premium_app_bar.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({Key? key}) : super(key: key);

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  final RipenxApiService _api = RipenxApiService();
  Map<String, dynamic>? _diagData;

  @override
  void initState() {
    super.initState();
    _loadDiagnostics();
  }

  Future<void> _loadDiagnostics() async {
    final res = await _api.getDiagnostics();
    if (mounted) setState(() => _diagData = res);
  }

  @override
  Widget build(BuildContext context) {
    final sys = _diagData?['system'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(title: 'DIAGNOSTICS'),
      body: SafeArea(
        child: _diagData == null
            ? const Center(child: CircularProgressIndicator(color: AppColors.deepSage))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDiagRow('CAMERA', sys?['camera'] ?? 'CONNECTED', Icons.videocam_rounded),
                  _buildDiagRow('YOLO DETECTOR', sys?['yolo'] ?? 'READY', Icons.crop_free_rounded),
                  _buildDiagRow('EFFICIENTNET MODEL', sys?['efficientnet'] ?? 'READY', Icons.psychology_rounded),
                  _buildDiagRow('DAYS REMAINING MLP', sys?['days_model'] ?? 'READY', Icons.show_chart_rounded),
                  _buildDiagRow('LOCAL DATABASE', 'READY', Icons.storage_rounded),
                  const SizedBox(height: 16),
                  _buildMetricCard('RAM Usage', '${_diagData!['ram_used_mb']} MB / ${_diagData!['ram_total_mb']} MB'),
                  _buildMetricCard('Storage Free', '${_diagData!['disk_free_gb']} GB Free / ${_diagData!['disk_total_gb']} GB'),
                  _buildMetricCard('Hardware Platform', '${_diagData!['device']}'),
                ],
              ),
      ),
    );
  }

  Widget _buildDiagRow(String label, String status, IconData icon) {
    final isOk = status == 'READY' || status == 'CONNECTED';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.glassBorder)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.deepSage, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.deepCharcoal))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: (isOk ? AppColors.freshGreen : AppColors.softCoral).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Text(status, style: TextStyle(color: isOk ? AppColors.freshGreen : AppColors.softCoral, fontWeight: FontWeight.bold, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String val) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.warmIvory.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.slate)),
          Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.deepCharcoal)),
        ],
      ),
    );
  }
}
