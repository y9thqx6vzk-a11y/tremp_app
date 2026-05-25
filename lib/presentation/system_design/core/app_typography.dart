import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextTheme get textTheme => GoogleFonts.rubikTextTheme().copyWith(
    displayLarge: GoogleFonts.rubik(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    titleLarge: GoogleFonts.rubik(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyLarge: GoogleFonts.rubik(
      fontSize: 16,
      color: AppColors.textPrimary,
    ),
    bodyMedium: GoogleFonts.rubik(
      fontSize: 14,
      color: AppColors.textSecondary,
    ),
  );
}
