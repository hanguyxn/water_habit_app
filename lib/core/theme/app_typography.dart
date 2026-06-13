import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography system for the Water Habit Social App.
///
/// - **Nunito**: Used for headings – rounded, friendly, high legibility.
/// - **Quicksand**: Used for body text – light, modern, easy on the eyes.
abstract final class AppTypography {
  // ═════════════════════════════════════════════
  // DISPLAY STYLES (Nunito)
  // ═════════════════════════════════════════════

  static TextStyle get displayLarge => GoogleFonts.nunito(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.12,
    color: AppColors.textPrimary,
  );

  static TextStyle get displayMedium => GoogleFonts.nunito(
    fontSize: 45,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.16,
    color: AppColors.textPrimary,
  );

  static TextStyle get displaySmall => GoogleFonts.nunito(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.22,
    color: AppColors.textPrimary,
  );

  // ═════════════════════════════════════════════
  // HEADLINE STYLES (Nunito)
  // ═════════════════════════════════════════════

  static TextStyle get headlineLarge => GoogleFonts.nunito(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineMedium => GoogleFonts.nunito(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineSmall => GoogleFonts.nunito(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
    color: AppColors.textPrimary,
  );

  // ═════════════════════════════════════════════
  // TITLE STYLES (Nunito)
  // ═════════════════════════════════════════════

  static TextStyle get titleLarge => GoogleFonts.nunito(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleMedium => GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.50,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleSmall => GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColors.textPrimary,
  );

  // ═════════════════════════════════════════════
  // BODY STYLES (Quicksand)
  // ═════════════════════════════════════════════

  static TextStyle get bodyLarge => GoogleFonts.quicksand(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.50,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.quicksand(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodySmall => GoogleFonts.quicksand(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    color: AppColors.textTertiary,
  );

  // ═════════════════════════════════════════════
  // LABEL STYLES (Quicksand)
  // ═════════════════════════════════════════════

  static TextStyle get labelLarge => GoogleFonts.quicksand(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelMedium => GoogleFonts.quicksand(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelSmall => GoogleFonts.quicksand(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
    color: AppColors.textTertiary,
  );

  // ═════════════════════════════════════════════
  // THEME DATA TEXT THEME
  // ═════════════════════════════════════════════

  /// Returns a complete [TextTheme] for use in [ThemeData].
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );

  /// Returns a dark-mode [TextTheme] with adjusted colors.
  static TextTheme get textThemeDark => TextTheme(
    displayLarge: displayLarge.copyWith(color: AppColors.textPrimaryDark),
    displayMedium: displayMedium.copyWith(color: AppColors.textPrimaryDark),
    displaySmall: displaySmall.copyWith(color: AppColors.textPrimaryDark),
    headlineLarge: headlineLarge.copyWith(color: AppColors.textPrimaryDark),
    headlineMedium: headlineMedium.copyWith(color: AppColors.textPrimaryDark),
    headlineSmall: headlineSmall.copyWith(color: AppColors.textPrimaryDark),
    titleLarge: titleLarge.copyWith(color: AppColors.textPrimaryDark),
    titleMedium: titleMedium.copyWith(color: AppColors.textPrimaryDark),
    titleSmall: titleSmall.copyWith(color: AppColors.textPrimaryDark),
    bodyLarge: bodyLarge.copyWith(color: AppColors.textPrimaryDark),
    bodyMedium: bodyMedium.copyWith(color: AppColors.textSecondaryDark),
    bodySmall: bodySmall.copyWith(color: AppColors.textTertiaryDark),
    labelLarge: labelLarge.copyWith(color: AppColors.textPrimaryDark),
    labelMedium: labelMedium.copyWith(color: AppColors.textSecondaryDark),
    labelSmall: labelSmall.copyWith(color: AppColors.textTertiaryDark),
  );
}
