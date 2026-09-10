import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'scanning_beam.dart';
import 'ai_status_pill.dart';

class CameraChamber extends StatelessWidget {
  final String imagePath;
  final String status;
  final bool isScanning;

  const CameraChamber({
    Key? key,
    required this.imagePath,
    required this.status,
    this.isScanning = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseUrl = 'http://localhost:5000';
    final hasImage = imagePath.isNotEmpty;

    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2629),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Live Preview or Placeholder Image
            if (hasImage)
              Image.network(
                '$baseUrl$imagePath',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (ctx, err, stack) => _buildPlaceholder(),
              )
            else
              _buildPlaceholder(),

            // Four Corner Frame Markers
            Positioned.fill(
              child: CustomPaint(
                painter: _CornerMarkersPainter(color: AppColors.sandalBlue),
              ),
            ),

            // Scanning Beam Overlay
            if (isScanning) const ScanningBeam(),

            // Top AI Status Pill
            Positioned(
              top: 12,
              child: AiStatusPill(status: status),
            ),

            // Bottom Frame Text Prompt
            Positioned(
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isScanning ? 'Analyzing fruit characteristics...' : 'Place fruit inside scan area',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF1B2326),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.camera_alt_outlined, color: AppColors.sandalBlue, size: 44),
            SizedBox(height: 8),
            Text(
              'CAMERA READY',
              style: TextStyle(color: AppColors.sandalBlue, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerMarkersPainter extends CustomPainter {
  final Color color;
  _CornerMarkersPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const len = 20.0;

    // Top Left
    canvas.drawPath(Path()..moveTo(16, 16 + len)..lineTo(16, 16)..lineTo(16 + len, 16), paint);
    // Top Right
    canvas.drawPath(Path()..moveTo(size.width - 16 - len, 16)..lineTo(size.width - 16, 16)..lineTo(size.width - 16, 16 + len), paint);
    // Bottom Left
    canvas.drawPath(Path()..moveTo(16, size.height - 16 - len)..lineTo(16, size.height - 16)..lineTo(16 + len, size.height - 16), paint);
    // Bottom Right
    canvas.drawPath(Path()..moveTo(size.width - 16 - len, size.height - 16)..lineTo(size.width - 16, size.height - 16)..lineTo(size.width - 16, size.height - 16 - len), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
