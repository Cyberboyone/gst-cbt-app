import 'package:flutter/material.dart';

class AppColors {
  // ── Primary (Cyan) ──
  static const Color primary = Color(0xFF00D4FF);
  static const Color primaryLight = Color(0xFF5CE1FF);
  static const Color primaryDark = Color(0xFF0091B3);
  static const Color onPrimary = Color(0xFF0A1628);

  // ── Secondary (Pink) ──
  static const Color secondary = Color(0xFFFF6B9D);
  static const Color secondaryLight = Color(0xFFFF9DC2);

  // ── Accent (Gold) ──
  static const Color accent = Color(0xFFFFD700);
  static const Color accentLight = Color(0xFFFFE566);

  // ── Backgrounds ──
  static const Color background = Color(0xFF0A1628);
  static const Color surface = Color(0xFF111D35);
  static const Color card = Color(0xFF162040);

  // ── Glass ──
  static const Color glassBg = Color(0x331A2A50);
  static const Color glassBorder = Color(0x3300D4FF);

  // ── Text ──
  static const Color foreground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8899BB);
  static const Color textMuted = Color(0xFF556688);

  // ── Muted / Borders ──
  static const Color muted = Color(0xFF1A2A50);
  static const Color border = Color(0xFF1E3060);
  static const Color divider = Color(0xFF1A2A50);

  // ── Semantic States ──
  static const Color correct = Color(0xFF00E676);
  static const Color correctLight = Color(0x3300E676);
  static const Color incorrect = Color(0xFFFF5252);
  static const Color incorrectLight = Color(0x33FF5252);
  static const Color warning = Color(0xFFFFAB40);
  static const Color warningLight = Color(0x33FFAB40);
  static const Color destructive = Color(0xFFFF5252);

  // ── Gamification ──
  static const Color gold = Color(0xFFFFD700);
  static const Color goldLight = Color(0x33FFD700);
  static const Color xp = Color(0xFFBB86FC);
  static const Color xpLight = Color(0x33BB86FC);
  static const Color streak = Color(0xFFFF6B9D);
  static const Color streakLight = Color(0x33FF6B9D);
  static const Color coins = Color(0xFFFFD700);
  static const Color coinsLight = Color(0x33FFD700);

  // ── Legacy aliases ──
  static const Color navy = Color(0xFF0A1628);
  static const Color orange = accent;
  static const Color cream = background;
  static const Color inkSoft = textSecondary;
  static const Color white = textPrimary;
  static const Color peach = Color(0x33FF6B9D);
  static const Color sky = Color(0x3300D4FF);
  static const Color mint = Color(0x3300E676);
  static const Color lavender = Color(0x33BB86FC);
  static const Color cardShadow = Color(0x1A00D4FF);

  // ── Shadows ──
  static final List<BoxShadow> clayShadow = [
    BoxShadow(
      offset: const Offset(0, 4),
      blurRadius: 20,
      color: Colors.black.withOpacity(0.3),
    ),
    BoxShadow(
      offset: const Offset(0, 0),
      blurRadius: 1,
      color: AppColors.primary.withOpacity(0.05),
    ),
  ];

  static final List<BoxShadow> clayShadowSmall = [
    BoxShadow(
      offset: const Offset(0, 2),
      blurRadius: 12,
      color: Colors.black.withOpacity(0.2),
    ),
  ];

  static final List<BoxShadow> clayShadowLarge = [
    BoxShadow(
      offset: const Offset(0, 8),
      blurRadius: 30,
      color: Colors.black.withOpacity(0.4),
    ),
  ];

  static final List<BoxShadow> glowShadow = [
    BoxShadow(
      offset: const Offset(0, 0),
      blurRadius: 20,
      color: AppColors.primary.withOpacity(0.3),
    ),
  ];

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF0091B3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFAB40)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient correctGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00C853)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incorrectGradient = LinearGradient(
    colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFAB40)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient xpGradient = LinearGradient(
    colors: [Color(0xFFBB86FC), Color(0xFF9C64FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0A1628), Color(0xFF111D35)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x1A00D4FF), Color(0x0DFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static final ThemeData darkTheme = _buildTheme();
  static ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.destructive,
        onPrimary: AppColors.onPrimary,
        onSurface: AppColors.textPrimary,
      ),
      fontFamily: 'Nunito',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48.0,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          letterSpacing: -1.5,
          height: 1.1,
        ),
        headlineLarge: TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.3,
        ),
        labelMedium: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 20.0,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
      ),
    );
  }
}
