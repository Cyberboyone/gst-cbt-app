import 'package:flutter/material.dart';

class AppColors {
  // Brand Anchors
  static const Color navy = Color(0xFF0B1E3F); // Primary navy
  static const Color orange = Color(0xFFFF7A33); // Signature orange
  static const Color cream = Color(0xFFFBF7F2); // Base background
  static const Color inkSoft = Color(0xFF5B6472); // Soft body text
  static const Color white = Colors.white;

  // Course Pastel Tints
  static const Color peach = Color(0xFFFFE8D6); // GST 101
  static const Color sky = Color(0xFFDCEEFF); // GST 102
  static const Color mint = Color(0xFFDFF5E4); // GST 111
  static const Color lavender = Color(0xFFEAE2FA); // GST 112

  // Additional design tokens
  static const Color cardShadow = Color(0x0A0B1E3F);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.cream,
      primaryColor: AppColors.navy,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.orange,
        primary: AppColors.navy,
        secondary: AppColors.orange,
        background: AppColors.cream,
      ),
      fontFamily: 'Segoe UI', // Fallback to system fonts Segoe UI/Helvetica
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.w800,
          color: AppColors.navy,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w800,
          color: AppColors.navy,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w800,
          color: AppColors.navy,
        ),
        titleMedium: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
        ),
        bodyLarge: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
          color: AppColors.navy,
        ),
        bodyMedium: TextStyle(
          fontSize: 13.0,
          fontWeight: FontWeight.w500,
          color: AppColors.inkSoft,
        ),
        labelLarge: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w700,
          color: AppColors.orange,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }
}
