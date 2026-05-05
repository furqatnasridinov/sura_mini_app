// lib/theme/app_theme.dart
// Centralized theme: colors, text styles, decorations

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Core palette
  static const Color background   = Color(0xFF0D1117);
  static const Color surface      = Color(0xFF161B22);
  static const Color surfaceAlt   = Color(0xFF1F2937);

  // Gold accent
  static const Color gold         = Color(0xFFC9A84C);
  static const Color goldLight    = Color(0xFFE8C97A);

  // Text
  static const Color textPrimary  = Color(0xFFE8E0D0);
  static const Color textMuted    = Color(0xFF8B7D6B);

  // States
  static const Color success      = Color(0xFF52B788);
  static const Color successBg    = Color(0xFF0D1F15);
  static const Color error        = Color(0xFFE07070);
  static const Color errorBg      = Color(0xFF2D0D0D);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      surface: AppColors.surface,
    ),
    textTheme: GoogleFonts.montserratTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: AppColors.textPrimary),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.gold.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.gold),
      ),
      hintStyle: const TextStyle(color: AppColors.textMuted),
    ),
  );
}

// Reusable text style helpers
class AppTextStyles {
  // Arabic text using Amiri font
  static TextStyle arabic({double size = 28, Color color = AppColors.goldLight}) =>
      GoogleFonts.amiri(fontSize: size, color: color, fontWeight: FontWeight.w400);

  static TextStyle heading({double size = 16}) =>
      GoogleFonts.montserrat(fontSize: size, fontWeight: FontWeight.w700, color: AppColors.textPrimary);

  static TextStyle body({double size = 13, Color color = AppColors.textPrimary}) =>
      GoogleFonts.montserrat(fontSize: size, color: color);

  static TextStyle muted({double size = 12}) =>
      GoogleFonts.montserrat(fontSize: size, color: AppColors.textMuted);

  static TextStyle label({double size = 10}) =>
      GoogleFonts.montserrat(fontSize: size, color: AppColors.textMuted, letterSpacing: 1.5);
}
