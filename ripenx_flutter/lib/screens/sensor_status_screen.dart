import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/sensor_data.dart';
import '../services/ripenx_api_service.dart';
import '../widgets/premium_app_bar.dart';

class SensorStatusScreen extends StatefulWidget {
  const SensorStatusScreen({Key? key}) : super(key: key);

  @override
  State<SensorStatusScreen> createState() => _SensorStatusScreenState();
}

class _SensorStatusScreenState extends State<SensorStatusScreen> {
  final RipenxApiService _api = RipenxApiService();
  SensorData? _sensorData;

  @override
  void initState() {
    super.initState();
    _fetchSensors();
  }

  Future<void> _fetchSensors() async {
    final data = await _api.getSensors();
    if (mounted) setState(() => _sensorData = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(title: 'SENSOR TELEMETRY'),
      body: SafeArea(
        child: _sensorData == null
            ? const Center(child: CircularProgressIndicator(color: AppColors.deepSage))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSensorRow('DHT22 Ambient Temperature', '${_sensorData!.temperature.toStringAsFixed(1)} °C', Icons.thermostat_rounded, AppColors.softCoral),
                  _buildSensorRow('DHT22 Relative Humidity', '${_sensorData!.humidity.toStringAsFixed(1)} %', Icons.water_drop_rounded, AppColors.sandalBlue),
                  _buildSensorRow('MQ-2 Gas Response (Raw)', '${_sensorData!.gasResponse} ADC', Icons.air_rounded, AppColors.warmGold),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.cloudBlue.withOpacity(0.3), borderRadius: BorderRadius.circular(14)),
                    child: Text('Hardware Connection: ${_sensorData!.status.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.deepCharcoal)),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSensorRow(String title, String val, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.glassBorder)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.deepCharcoal)),
        ],
      ),
    );
  }
}
