import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_app_bar.dart';
import '../services/ripenx_api_service.dart';

class CameraSettingsScreen extends StatefulWidget {
  const CameraSettingsScreen({Key? key}) : super(key: key);

  @override
  State<CameraSettingsScreen> createState() => _CameraSettingsScreenState();
}

class _CameraSettingsScreenState extends State<CameraSettingsScreen> {
  final RipenxApiService _api = RipenxApiService();
  bool _autoScan = false;
  double _confThreshold = 0.65;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _api.getSettings();
    if (mounted) {
      setState(() {
        _autoScan = settings['auto_scan'] == 'true';
        _confThreshold = double.tryParse(settings['fruit_confidence_threshold'] ?? '0.65') ?? 0.65;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(title: 'CAMERA SETTINGS'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: const Text('Auto Scan Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text('Automatically trigger inference when fruit stabilizes', style: TextStyle(fontSize: 10, color: AppColors.slate)),
              value: _autoScan,
              activeColor: AppColors.deepSage,
              onChanged: (val) {
                setState(() => _autoScan = val);
                _api.updateSettings({'auto_scan': val.toString()});
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Fruit Confidence Threshold', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('${(_confThreshold * 100).toInt()}% (Rejects predictions below this value)', style: const TextStyle(fontSize: 10, color: AppColors.slate)),
            ),
            Slider(
              value: _confThreshold,
              min: 0.40,
              max: 0.90,
              divisions: 10,
              activeColor: AppColors.deepSage,
              onChanged: (val) {
                setState(() => _confThreshold = val);
                _api.updateSettings({'fruit_confidence_threshold': val.toStringAsFixed(2)});
              },
            ),
          ],
        ),
      ),
    );
  }
}
