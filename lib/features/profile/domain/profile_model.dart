import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
class ProfileStats with _$ProfileStats {
  const factory ProfileStats({
    required int totalDaysTracked,
    required int goalsCompleted,
    required double averageDailyMl,
    required int currentStreak,
    required int longestStreak,
    required double totalWaterLiters,
    required int achievementCount,
    required int friendCount,
    required int level,
    required int xp,
    required int xpForNextLevel,
    required int seasonalRank,
    required int prestigeStars,
  }) = _ProfileStats;

  factory ProfileStats.fromJson(Map<String, dynamic> json) =>
      _$ProfileStatsFromJson(json);

  factory ProfileStats.empty() => const ProfileStats(
        totalDaysTracked: 0,
        goalsCompleted: 0,
        averageDailyMl: 0,
        currentStreak: 0,
        longestStreak: 0,
        totalWaterLiters: 0,
        achievementCount: 0,
        friendCount: 0,
        level: 1,
        xp: 0,
        xpForNextLevel: 100,
        seasonalRank: 0,
        prestigeStars: 0,
      );
}

@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    required String id,
    required String name,
    required String description,
    required String iconName,
    required int category, // 0=water, 1=streak, 2=social, 3=seasonal, 4=special
    required int tier, // 0=bronze, 1=silver, 2=gold, 3=diamond
    DateTime? earnedAt,
    @Default(false) bool isUnlocked,
    @Default(0) int progress,
    @Default(100) int maxProgress,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}

@freezed
class WeeklyWaterData with _$WeeklyWaterData {
  const factory WeeklyWaterData({
    required String dayLabel,
    required double amountMl,
    required double goalMl,
    required DateTime date,
  }) = _WeeklyWaterData;

  factory WeeklyWaterData.fromJson(Map<String, dynamic> json) =>
      _$WeeklyWaterDataFromJson(json);
}
