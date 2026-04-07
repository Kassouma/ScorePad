import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF0F0F0F);
  static const surface = Color(0xFF1A1A1A);
  static const surface2 = Color(0xFF222222);
  static const border = Color(0xFF2A2A2A);
  static const accent = Color(0xFFE8FF47);
  static const accentDim = Color(0xFFB8CC30);
  static const textPrimary = Color(0xFFF0F0F0);
  static const textMuted = Color(0xFF666666);
  static const danger = Color(0xFFFF4747);
  static const coffee = Color(0xFFF5A623);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.accent,
        error: AppColors.danger,
      ),
      textTheme: GoogleFonts.syneTextTheme(
        const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textPrimary),
        ),
      ).apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.bg,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        elevation: 0,
      ),
    );
  }
}
