class AppConstants {
  AppConstants._();

  // Water Tracking
  static const int defaultDailyGoalMl = 2500;
  static const int leaderboardCapMl = 3000;
  static const int minDailyGoalMl = 1000;
  static const int maxDailyGoalMl = 5000;
  static const int maxWaterEntryMl = 1000;

  // Social
  static const int maxFriendRequests = 100;
  static const int waterSupportCooldownHours = 24;
  static const int maxFriends = 500;

  // XP & Gamification
  static const int xpPerGoalComplete = 50;
  static const int xpPerStreakDay = 10;
  static const int xpPerWaterSupportSent = 5;
  static const int xpPerWaterSupportReceived = 10;
  static const int xpPerAchievement = 25;
  static const int maxStreakXpBonus = 100;
  static const int prestigeResetLevel = 100;

  // Seasons
  static const int seasonDurationDays = 30;

  // Notifications
  static const int waterReminderIntervalMinutes = 120;

  // Default Glass Sizes (ml)
  static const List<int> defaultGlassSizes = [100, 200, 250, 300, 500];

  // Level formula: level = sqrt(totalXP / 100) + 1
  static int calculateLevel(int xp) {
    return (xp / 100).sqrt().floor() + 1;
  }

  static int xpForLevel(int level) {
    return ((level - 1) * (level - 1)) * 100;
  }

  static int xpForNextLevel(int currentLevel) {
    return xpForLevel(currentLevel + 1);
  }

  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animVerySlow = Duration(milliseconds: 800);
  static const Duration splashDuration = Duration(seconds: 2);

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusRound = 100.0;

  // Padding
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Feed
  static const int feedPageSize = 20;

  // Leaderboard
  static const int leaderboardPageSize = 50;
}

extension _NumSqrt on num {
  double sqrt() => this < 0 ? 0 : double.parse(toString()).sqrtImpl();
}

extension _DoubleSqrt on double {
  double sqrtImpl() {
    if (this <= 0) return 0;
    double x = this;
    double y = (x + 1) / 2;
    while (y < x) {
      x = y;
      y = (x + this / x) / 2;
    }
    return x;
  }
}
