import 'package:flutter/material.dart';

/// Complete color palette for the Water Habit Social App.
///
/// Uses a Nature/Garden theme with Forest Green as primary,
/// Earth/Wood tones as secondary, and Water Blue as accent.
abstract final class AppColors {
  // ─────────────────────────────────────────────
  // PRIMARY: Forest Green (50 → 900)
  // ─────────────────────────────────────────────
  static const Color primary50 = Color(0xFFE8F5E9);
  static const Color primary100 = Color(0xFFC8E6C9);
  static const Color primary200 = Color(0xFFA5D6A7);
  static const Color primary300 = Color(0xFF81C784);
  static const Color primary400 = Color(0xFF52B788);
  static const Color primary500 = Color(0xFF40916C);
  static const Color primary600 = Color(0xFF2D6A4F);
  static const Color primary700 = Color(0xFF1B4332);
  static const Color primary800 = Color(0xFF0D2818);
  static const Color primary900 = Color(0xFF061A0F);

  static const Color primary = primary500;
  static const Color primaryLight = primary400;
  static const Color primaryDark = primary600;
  static const Color primarySurface = Color(0xFFD8F3DC);

  static const MaterialColor primarySwatch = MaterialColor(
    0xFF40916C,
    <int, Color>{
      50: primary50,
      100: primary100,
      200: primary200,
      300: primary300,
      400: primary400,
      500: primary500,
      600: primary600,
      700: primary700,
      800: primary800,
      900: primary900,
    },
  );

  // ─────────────────────────────────────────────
  // SECONDARY: Earth / Wood (50 → 900)
  // ─────────────────────────────────────────────
  static const Color secondary50 = Color(0xFFFFF8E1);
  static const Color secondary100 = Color(0xFFFFECB3);
  static const Color secondary200 = Color(0xFFE8D5A3);
  static const Color secondary300 = Color(0xFFD4A76A);
  static const Color secondary400 = Color(0xFFC49A5C);
  static const Color secondary500 = Color(0xFFB08D4E);
  static const Color secondary600 = Color(0xFF8B6914);
  static const Color secondary700 = Color(0xFF7A5C10);
  static const Color secondary800 = Color(0xFF5C4308);
  static const Color secondary900 = Color(0xFF3E2C04);

  static const Color secondary = secondary500;
  static const Color secondaryLight = secondary300;
  static const Color secondaryDark = secondary600;
  static const Color secondarySurface = Color(0xFFFFF3E0);

  static const MaterialColor secondarySwatch = MaterialColor(
    0xFFB08D4E,
    <int, Color>{
      50: secondary50,
      100: secondary100,
      200: secondary200,
      300: secondary300,
      400: secondary400,
      500: secondary500,
      600: secondary600,
      700: secondary700,
      800: secondary800,
      900: secondary900,
    },
  );

  // ─────────────────────────────────────────────
  // ACCENT: Water Blue (50 → 900)
  // ─────────────────────────────────────────────
  static const Color accent50 = Color(0xFFE3F2FD);
  static const Color accent100 = Color(0xFFBBDEFB);
  static const Color accent200 = Color(0xFF90CAF9);
  static const Color accent300 = Color(0xFF64B5F6);
  static const Color accent400 = Color(0xFF42A5F5);
  static const Color accent500 = Color(0xFF2196F3);
  static const Color accent600 = Color(0xFF1E88E5);
  static const Color accent700 = Color(0xFF1565C0);
  static const Color accent800 = Color(0xFF0D47A1);
  static const Color accent900 = Color(0xFF0A3070);

  static const Color accent = accent400;
  static const Color accentLight = accent200;
  static const Color accentDark = accent700;
  static const Color accentSurface = Color(0xFFE3F2FD);

  static const MaterialColor accentSwatch = MaterialColor(
    0xFF42A5F5,
    <int, Color>{
      50: accent50,
      100: accent100,
      200: accent200,
      300: accent300,
      400: accent400,
      500: accent500,
      600: accent600,
      700: accent700,
      800: accent800,
      900: accent900,
    },
  );

  // ─────────────────────────────────────────────
  // BACKGROUNDS
  // ─────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFFFF8E1);
  static const Color backgroundLightSecondary = Color(0xFFF5F0E1);
  static const Color backgroundLightTertiary = Color(0xFFFAF6ED);

  static const Color backgroundDark = Color(0xFF1A2E1A);
  static const Color backgroundDarkSecondary = Color(0xFF0D1F0D);
  static const Color backgroundDarkTertiary = Color(0xFF243824);

  static const Color surfaceLight = Color(0xFFFFFDF7);
  static const Color surfaceDark = Color(0xFF1E331E);

  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF243324);

  // ─────────────────────────────────────────────
  // TEXT COLORS
  // ─────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1B2E1B);
  static const Color textSecondary = Color(0xFF4A6741);
  static const Color textTertiary = Color(0xFF7A9B70);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFE8F5E9);
  static const Color textHint = Color(0xFFADBEA8);
  static const Color textDisabled = Color(0xFFB0BEC5);

  static const Color textPrimaryDark = Color(0xFFF1F8E9);
  static const Color textSecondaryDark = Color(0xFFAED581);
  static const Color textTertiaryDark = Color(0xFF81C784);
  static const Color textDisabledDark = Color(0xFF5A6B5A);

  // ─────────────────────────────────────────────
  // STATUS COLORS (Friend / Drinking Status)
  // ─────────────────────────────────────────────
  static const Color statusDrinking = Color(0xFF4CAF50);
  static const Color statusDrinkingLight = Color(0xFFE8F5E9);
  static const Color statusCompleted = Color(0xFFE91E63);
  static const Color statusCompletedLight = Color(0xFFFCE4EC);
  static const Color statusInactive = Color(0xFF9E9E9E);
  static const Color statusInactiveLight = Color(0xFFF5F5F5);
  static const Color statusOnline = Color(0xFF66BB6A);
  static const Color statusOffline = Color(0xFFBDBDBD);

  // ─────────────────────────────────────────────
  // REACTION COLORS
  // ─────────────────────────────────────────────
  static const Color reactionHeart = Color(0xFFE53935);
  static const Color reactionHeartLight = Color(0xFFFFCDD2);
  static const Color reactionPlant = Color(0xFF43A047);
  static const Color reactionPlantLight = Color(0xFFC8E6C9);
  static const Color reactionFire = Color(0xFFFF9800);
  static const Color reactionFireLight = Color(0xFFFFE0B2);
  static const Color reactionWater = Color(0xFF42A5F5);
  static const Color reactionWaterLight = Color(0xFFBBDEFB);

  // ─────────────────────────────────────────────
  // LEVEL / XP COLORS
  // ─────────────────────────────────────────────
  static const Color gold = Color(0xFFFFD700);
  static const Color goldLight = Color(0xFFFFF8DC);
  static const Color goldDark = Color(0xFFB8860B);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color silverLight = Color(0xFFE8E8E8);
  static const Color silverDark = Color(0xFF808080);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color bronzeLight = Color(0xFFEED9B5);
  static const Color bronzeDark = Color(0xFF8B5A2B);

  static const Color xpBar = Color(0xFF7C4DFF);
  static const Color xpBarBackground = Color(0xFFE0D6FF);
  static const Color levelBadge = Color(0xFFFFAB00);

  // Extended tier colors
  static const Color levelBronze = Color(0xFFCD7F32);
  static const Color levelSilver = Color(0xFFC0C0C0);
  static const Color levelGold = Color(0xFFFFD700);
  static const Color levelPlatinum = Color(0xFF00BCD4);
  static const Color levelDiamond = Color(0xFF7C4DFF);
  static const Color levelMaster = Color(0xFFD32F2F);

  // ─────────────────────────────────────────────
  // SEMANTIC / FEEDBACK
  // ─────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color successDark = Color(0xFF2E7D32);

  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color warningDark = Color(0xFFF57F17);

  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color errorDark = Color(0xFFC62828);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);
  static const Color infoDark = Color(0xFF1565C0);

  // ─────────────────────────────────────────────
  // NEUTRAL / BORDER / DIVIDER
  // ─────────────────────────────────────────────
  static const Color border = Color(0xFFD5E0D0);
  static const Color borderDark = Color(0xFF3D5A3D);
  static const Color divider = Color(0xFFE8EDE6);
  static const Color dividerDark = Color(0xFF3A4F3A);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color disabledBackground = Color(0xFFF0F0EC);

  // ─────────────────────────────────────────────
  // SHIMMER
  // ─────────────────────────────────────────────
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF2A3E2A);
  static const Color shimmerHighlightDark = Color(0xFF3A4F3A);

  // ─────────────────────────────────────────────
  // STREAK FIRE COLORS
  // ─────────────────────────────────────────────
  static const Color streakLow = Color(0xFFFF9800);
  static const Color streakMedium = Color(0xFFFF5722);
  static const Color streakHigh = Color(0xFFD32F2F);
  static const Color streakEpic = Color(0xFFAA00FF);

  // ─────────────────────────────────────────────
  // SEASONAL RANK COLORS
  // ─────────────────────────────────────────────
  static const Color rankSeed = Color(0xFF8D6E63);
  static const Color rankSprout = Color(0xFFA5D6A7);
  static const Color rankLeaf = Color(0xFF66BB6A);
  static const Color rankFlower = Color(0xFFEC407A);
  static const Color rankTree = Color(0xFF2D6A4F);
  static const Color rankAncientTree = Color(0xFFFFD700);
  static const Color rankLegendaryForest = Color(0xFFAB47BC);

  // ═════════════════════════════════════════════
  // GRADIENTS
  // ═════════════════════════════════════════════

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary400, primary600],
  );

  static const LinearGradient primaryVerticalGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary400, primary600],
  );

  static const LinearGradient waterGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [accent200, accent400, accent100],
  );

  static const LinearGradient waterHorizontalGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [accent300, accent500],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9A8B), Color(0xFFFF6B6B), Color(0xFFFF5E62)],
  );

  static const LinearGradient forestGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary300, primary600, primary700],
  );

  static const LinearGradient earthGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary200, secondary500],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary400, secondary600],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
  );

  static const LinearGradient silverGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE0E0E0), Color(0xFF9E9E9E)],
  );

  static const LinearGradient bronzeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFCD7F32), Color(0xFF8B5A2B)],
  );

  static const LinearGradient xpGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF7C4DFF), Color(0xFFB388FF)],
  );

  static const LinearGradient fireGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Color(0xFFFF9800), Color(0xFFFF5722), Color(0xFFD32F2F)],
  );

  static const LinearGradient darkOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0x99000000)],
  );

  static const LinearGradient lightOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x33FFFFFF), Colors.transparent],
  );

  static const LinearGradient backgroundLightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundLight, backgroundLightSecondary],
  );

  static const LinearGradient backgroundDarkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDark, backgroundDarkSecondary],
  );

  // ─────────────────────────────────────────────
  // NATURE SHADOWS
  // ─────────────────────────────────────────────
  static List<BoxShadow> get natureShadowLight => [
    BoxShadow(
      color: const Color(0xFF2D6A4F).withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF2D6A4F).withValues(alpha: 0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get natureShadowMedium => [
    BoxShadow(
      color: const Color(0xFF2D6A4F).withValues(alpha: 0.12),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: const Color(0xFF2D6A4F).withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 3),
    ),
  ];

  static List<BoxShadow> get natureShadowHeavy => [
    BoxShadow(
      color: const Color(0xFF2D6A4F).withValues(alpha: 0.18),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: const Color(0xFF2D6A4F).withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ─────────────────────────────────────────────
  // UTILITY METHODS
  // ─────────────────────────────────────────────

  /// Creates a radial gradient for water ripple effects.
  static RadialGradient waterRippleGradient({double radius = 0.8}) {
    return RadialGradient(
      radius: radius,
      colors: const [
        Color(0x4042A5F5),
        Color(0x2042A5F5),
        Color(0x0042A5F5),
      ],
    );
  }

  /// Creates a sweep gradient for circular progress indicators.
  static SweepGradient progressSweepGradient({
    double startAngle = 0.0,
    double endAngle = 6.28,
  }) {
    return SweepGradient(
      startAngle: startAngle,
      endAngle: endAngle,
      colors: const [accent300, primary400, accent400],
    );
  }

  /// Get level tier color based on level number.
  static Color getLevelColor(int level) {
    if (level < 5) return levelBronze;
    if (level < 10) return levelSilver;
    if (level < 20) return levelGold;
    if (level < 35) return levelPlatinum;
    if (level < 50) return levelDiamond;
    return levelMaster;
  }

  /// Get streak color based on streak count.
  static Color getStreakColor(int streak) {
    if (streak < 3) return streakLow;
    if (streak < 7) return streakMedium;
    if (streak < 14) return streakHigh;
    return streakEpic;
  }

  /// Get gradient for a seasonal rank index.
  static LinearGradient getRankGradient(int rankIndex) {
    const rankColors = [
      [Color(0xFF8D6E63), Color(0xFFA1887F)], // seed
      [Color(0xFFA5D6A7), Color(0xFF81C784)], // sprout
      [Color(0xFF66BB6A), Color(0xFF43A047)], // leaf
      [Color(0xFFEC407A), Color(0xFFAD1457)], // flower
      [Color(0xFF2D6A4F), Color(0xFF1B4332)], // tree
      [Color(0xFFFFD700), Color(0xFFFFA000)], // ancient tree
      [Color(0xFFAB47BC), Color(0xFF7B1FA2)], // legendary forest
    ];
    final colors = rankColors[rankIndex.clamp(0, rankColors.length - 1)];
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
  }
}
