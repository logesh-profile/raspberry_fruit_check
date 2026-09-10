import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_app_bar.dart';
import 'camera_settings_screen.dart';
import 'sensor_status_screen.dart';
import 'ai_settings_screen.dart';
import 'training_data_screen.dart';
import 'scan_history_screen.dart';
import 'visual_memory_screen.dart';
import 'diagnostics_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(title: 'SETTINGS'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSettingTile(
              icon: Icons.camera_alt_outlined,
              title: 'Camera Settings',
              subtitle: 'Resolution, FPS, Auto-Scan, thresholds',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const CameraSettingsScreen())),
            ),
            _buildSettingTile(
              icon: Icons.sensors_rounded,
              title: 'Sensor Status & Telemetry',
              subtitle: 'DHT22 Temperature, Humidity, MQ-2 Gas',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const SensorStatusScreen())),
            ),
            _buildSettingTile(
              icon: Icons.psychology_outlined,
              title: 'AI & Detection Settings',
              subtitle: 'Confidence thresholds, PyTorch / YOLO stats',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const AiSettingsScreen())),
            ),
            _buildSettingTile(
              icon: Icons.dataset_outlined,
              title: 'Feedback & Training Data',
              subtitle: 'Manage verified corrections dataset',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const TrainingDataScreen())),
            ),
            _buildSettingTile(
              icon: Icons.history_rounded,
              title: 'Scan History',
              subtitle: 'View and clear local scan logs',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const ScanHistoryScreen())),
            ),
            _buildSettingTile(
              icon: Icons.memory_rounded,
              title: 'Visual Memory',
              subtitle: 'Visual embedding similarity records',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const VisualMemoryScreen())),
            ),
            _buildSettingTile(
              icon: Icons.monitor_heart_outlined,
              title: 'Diagnostics',
              subtitle: 'System memory, latency, hardware status',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const DiagnosticsScreen())),
            ),
            _buildSettingTile(
              icon: Icons.info_outline_rounded,
              title: 'About RIPENX™',
              subtitle: 'Product vision, specs, offline commitment',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const AboutScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.cloudBlue.withOpacity(0.4), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.deepCharcoal, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.deepCharcoal)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.slate)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.slate),
        onTap: onTap,
      ),
    );
  }
}
