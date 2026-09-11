import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class RipenxLogo extends StatelessWidget {
  final double fontSize;
  final bool showTagline;

  const RipenxLogo({
    Key? key,
    this.fontSize = 24,
    this.showTagline = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RIPENX',
              style: AppTypography.titleBrand.copyWith(fontSize: fontSize),
            ),
            Text(
              '™',
              style: TextStyle(
                fontSize: fontSize * 0.45,
                fontWeight: FontWeight.bold,
                color: AppColors.sandalBlue,
              ),
            ),
          ],
        ),
        if (showTagline) ...[
          const SizedBox(height: 2),
          const Text(
            'Sense. Predict. Know When It’s Ready.',
            style: AppTypography.tagline,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
