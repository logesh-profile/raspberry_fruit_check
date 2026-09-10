import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ScanningBeam extends StatefulWidget {
  const ScanningBeam({Key? key}) : super(key: key);

  @override
  State<ScanningBeam> createState() => _ScanningBeamState();
}

class _ScanningBeamState extends State<ScanningBeam> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Align(
          alignment: Alignment(0, (_controller.value * 2.0) - 1.0),
          child: Container(
            height: 3,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.sandalBlue.withOpacity(0.1),
                  AppColors.freshGreen,
                  AppColors.sandalBlue.withOpacity(0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.freshGreen.withOpacity(0.8),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
