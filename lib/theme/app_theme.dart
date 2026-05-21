import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFFFDF8EE);
  static const Color primary = Color(0xFFFF6B00);
  static const Color gold = Color(0xFFF5C518);
  static const Color darkBrown = Color(0xFF3D2B1F);
  static const Color warmGrey = Color(0xFF8B7355);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color saffronLight = Color(0xFFFFE4B5);
  static const Color border = Color(0xFFE8D5B0);
  static const Color cream = Color(0xFFFFF8F0);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        surface: AppColors.background,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.darkBrown,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: AppColors.darkBrown,
        ),
        displaySmall: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.darkBrown,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.darkBrown,
        ),
        bodyLarge: GoogleFonts.lato(
          fontSize: 16,
          color: AppColors.darkBrown,
        ),
        bodyMedium: GoogleFonts.lato(
          fontSize: 14,
          color: AppColors.warmGrey,
        ),
        bodySmall: GoogleFonts.lato(
          fontSize: 12,
          color: AppColors.warmGrey,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkBrown),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.darkBrown,
        ),
      ),
    );
  }
}
