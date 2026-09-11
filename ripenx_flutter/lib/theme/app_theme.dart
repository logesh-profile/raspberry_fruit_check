import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.deepSage,
      colorScheme: ColorScheme.light(
        primary: AppColors.deepSage,
        secondary: AppColors.sandalBlue,
        surface: AppColors.surfaceCard,
        background: AppColors.background,
        error: AppColors.softCoral,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.deepCharcoal),
        titleTextStyle: AppTypography.h2,
      ),
    );
  }
}
