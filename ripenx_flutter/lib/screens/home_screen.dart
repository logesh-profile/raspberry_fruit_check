import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/ripenx_logo.dart';
import '../widgets/camera_chamber.dart';
import '../widgets/premium_button.dart';
import '../services/ripenx_api_service.dart';
import 'live_scanning_screen.dart';
import 'scan_history_screen.dart';
import 'settings_screen.dart';
import 'diagnostics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RipenxApiService _api = RipenxApiService();
  String _cameraStatus = 'Camera Ready';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final health = await _api.checkHealth();
    if (mounted) {
      setState(() {
        _cameraStatus = health['camera_active'] == true ? 'Camera Ready' : 'Searching';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Top Bar with Brand & Quick Diagnostics Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const RipenxLogo(fontSize: 20, showTagline: false),
                  IconButton(
                    icon: const Icon(Icons.tune_rounded, color: AppColors.deepCharcoal, size: 22),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) => const DiagnosticsScreen()));
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Camera Preview Chamber
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CameraChamber(
                        imagePath: '',
                        status: _cameraStatus,
                        isScanning: false,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Sense. Predict. Know When It’s Ready.',
                        style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.slate),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Primary Touch Button: SCAN FRUIT
              PremiumButton(
                text: 'SCAN FRUIT',
                icon: Icons.qr_code_scanner_rounded,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => const LiveScanningScreen()),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Secondary Touch Actions: History & Settings
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: const BorderSide(color: AppColors.glassBorder),
                      ),
                      icon: const Icon(Icons.history_rounded, size: 18, color: AppColors.deepCharcoal),
                      label: const Text('HISTORY', style: TextStyle(color: AppColors.deepCharcoal, fontWeight: FontWeight.bold, fontSize: 12)),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (ctx) => const ScanHistoryScreen()));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: const BorderSide(color: AppColors.glassBorder),
                      ),
                      icon: const Icon(Icons.settings_outlined, size: 18, color: AppColors.deepCharcoal),
                      label: const Text('SETTINGS', style: TextStyle(color: AppColors.deepCharcoal, fontWeight: FontWeight.bold, fontSize: 12)),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (ctx) => const SettingsScreen()));
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
}
