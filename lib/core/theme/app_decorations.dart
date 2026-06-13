import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Reusable decoration presets for the Water Habit Social App.
///
/// Provides nature-themed box decorations, shadow presets,
/// glassmorphism effects, and input decoration helpers.
abstract final class AppDecorations {
  // ═════════════════════════════════════════════
  // SHADOW PRESETS
  // ═════════════════════════════════════════════

  static List<BoxShadow> get shadowLight => [
    BoxShadow(
      color: AppColors.primary600.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: AppColors.primary600.withValues(alpha: 0.10),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: AppColors.primary600.withValues(alpha: 0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowHeavy => [
    BoxShadow(
      color: AppColors.primary600.withValues(alpha: 0.16),
      blurRadius: 28,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: AppColors.primary600.withValues(alpha: 0.08),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowColoredPrimary => [
    BoxShadow(
      color: AppColors.primary400.withValues(alpha: 0.30),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get shadowColoredAccent => [
    BoxShadow(
      color: AppColors.accent400.withValues(alpha: 0.30),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  // ═════════════════════════════════════════════
  // GLASSMORPHISM
  // ═════════════════════════════════════════════

  /// Creates a glassmorphism decoration with blur and semi-transparent bg.
  static BoxDecoration glassMorphism({
    Color? backgroundColor,
    double borderRadius = 20,
    double opacity = 0.15,
    Color borderColor = Colors.white,
    double borderOpacity = 0.2,
  }) {
    return BoxDecoration(
      color: (backgroundColor ?? Colors.white).withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor.withValues(alpha: borderOpacity),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Creates a dark glassmorphism decoration for dark mode.
  static BoxDecoration glassMorphismDark({
    double borderRadius = 20,
    double opacity = 0.20,
  }) {
    return glassMorphism(
      backgroundColor: const Color(0xFF1A2E1A),
      borderRadius: borderRadius,
      opacity: opacity,
      borderColor: AppColors.primary400,
      borderOpacity: 0.15,
    );
  }

  /// A [BackdropFilter] + container widget shortcut.
  /// Wrap your child in this to get the full glass effect.
  static Widget glassContainer({
    required Widget child,
    double borderRadius = 20,
    double sigmaX = 10,
    double sigmaY = 10,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    Color? backgroundColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: Container(
          padding: padding,
          decoration: glassMorphism(
            backgroundColor: backgroundColor,
            borderRadius: borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════
  // CARD DECORATIONS
  // ═════════════════════════════════════════════

  /// Standard card decoration with nature-themed shadow.
  static BoxDecoration cardDecoration({
    Color? color,
    double borderRadius = 16,
    List<BoxShadow>? boxShadow,
    Border? border,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.cardLight,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border,
      boxShadow: boxShadow ?? shadowLight,
    );
  }

  /// Dark-mode card decoration.
  static BoxDecoration cardDecorationDark({
    Color? color,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.cardDark,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: AppColors.borderDark.withValues(alpha: 0.3),
      ),
    );
  }

  /// Elevated card with stronger shadow.
  static BoxDecoration elevatedCardDecoration({
    Color? color,
    double borderRadius = 20,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.cardLight,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: shadowMedium,
    );
  }

  // ═════════════════════════════════════════════
  // GRADIENT DECORATIONS
  // ═════════════════════════════════════════════

  /// Gradient-filled container decoration.
  static BoxDecoration gradientDecoration({
    required Gradient gradient,
    double borderRadius = 16,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: boxShadow,
    );
  }

  /// Primary gradient card.
  static BoxDecoration primaryGradientCard({double borderRadius = 16}) {
    return BoxDecoration(
      gradient: AppColors.primaryGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: shadowColoredPrimary,
    );
  }

  /// Water / accent gradient card.
  static BoxDecoration waterGradientCard({double borderRadius = 16}) {
    return BoxDecoration(
      gradient: AppColors.waterGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: shadowColoredAccent,
    );
  }

  // ═════════════════════════════════════════════
  // ROUNDED CONTAINERS
  // ═════════════════════════════════════════════

  /// Pill-shaped container (fully rounded).
  static BoxDecoration pillDecoration({
    Color? color,
    Gradient? gradient,
    Border? border,
  }) {
    return BoxDecoration(
      color: gradient == null ? (color ?? AppColors.primary50) : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(100),
      border: border,
    );
  }

  /// Circular avatar/icon container.
  static BoxDecoration circleDecoration({
    Color? color,
    Gradient? gradient,
    List<BoxShadow>? boxShadow,
    Border? border,
  }) {
    return BoxDecoration(
      color: gradient == null ? (color ?? AppColors.primary50) : null,
      gradient: gradient,
      shape: BoxShape.circle,
      boxShadow: boxShadow,
      border: border,
    );
  }

  /// Rounded container with a subtle border.
  static BoxDecoration outlinedDecoration({
    double borderRadius = 12,
    Color? borderColor,
    double borderWidth = 1.0,
    Color? fillColor,
  }) {
    return BoxDecoration(
      color: fillColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? AppColors.border,
        width: borderWidth,
      ),
    );
  }

  // ═════════════════════════════════════════════
  // INPUT DECORATION HELPER
  // ═════════════════════════════════════════════

  /// Creates a nature-themed [InputDecoration].
  static InputDecoration inputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isDense = false,
    bool filled = true,
    Color? fillColor,
    String? errorText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      isDense: isDense,
      filled: filled,
      fillColor: fillColor ?? AppColors.primary50.withValues(alpha: 0.5),
      labelStyle: TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(color: AppColors.textHint),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.border,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primary400,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.disabled,
          width: 1,
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════
  // SPECIAL DECORATIONS
  // ═════════════════════════════════════════════

  /// Bottom sheet top decoration with drag handle area.
  static BoxDecoration bottomSheetDecoration({bool isDark = false}) {
    return BoxDecoration(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ],
    );
  }

  /// Status badge decoration (drinking, completed, etc.).
  static BoxDecoration statusBadge(Color color) {
    return BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: color.withValues(alpha: 0.3),
        width: 1,
      ),
    );
  }

  /// XP / progress bar track decoration.
  static BoxDecoration progressTrack({
    double borderRadius = 10,
    bool isDark = false,
  }) {
    return BoxDecoration(
      color: isDark ? AppColors.xpBarBackground.withValues(alpha: 0.2) : AppColors.xpBarBackground,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  /// XP / progress bar fill decoration.
  static BoxDecoration progressFill({
    Gradient? gradient,
    double borderRadius = 10,
  }) {
    return BoxDecoration(
      gradient: gradient ?? AppColors.xpGradient,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }
}
