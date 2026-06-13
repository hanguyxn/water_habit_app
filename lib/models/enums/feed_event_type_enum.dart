enum FeedEventTypeEnum {
  goalCompleted(0),
  newBow(1),
  streakMilestone(2),
  waterSupport(3),
  levelUp(4),
  achievementUnlocked(5),
  seasonRankUp(6);

  const FeedEventTypeEnum(this.value);
  final int value;

  String get icon {
    switch (this) {
      case FeedEventTypeEnum.goalCompleted: return '🎯';
      case FeedEventTypeEnum.newBow: return '🎀';
      case FeedEventTypeEnum.streakMilestone: return '🔥';
      case FeedEventTypeEnum.waterSupport: return '💧';
      case FeedEventTypeEnum.levelUp: return '⬆️';
      case FeedEventTypeEnum.achievementUnlocked: return '🏆';
      case FeedEventTypeEnum.seasonRankUp: return '🌿';
    }
  }

  static FeedEventTypeEnum fromValue(int value) {
    return FeedEventTypeEnum.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FeedEventTypeEnum.goalCompleted,
    );
  }
}
