import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static const TextStyle titleBrand = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 2.0,
    color: AppColors.deepCharcoal,
  );

  static const TextStyle tagline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.slate,
  );

  static const TextStyle h1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.deepCharcoal,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.deepCharcoal,
  );

  static const TextStyle body = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.deepCharcoal,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.slate,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.mistText,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: Colors.white,
  );
}
