enum ReactionTypeEnum {
  heart(0),
  plant(1),
  fire(2),
  water(3);

  const ReactionTypeEnum(this.value);
  final int value;

  String get emoji {
    switch (this) {
      case ReactionTypeEnum.heart: return '❤️';
      case ReactionTypeEnum.plant: return '🌱';
      case ReactionTypeEnum.fire: return '🔥';
      case ReactionTypeEnum.water: return '💧';
    }
  }

  static ReactionTypeEnum fromValue(int value) {
    return ReactionTypeEnum.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReactionTypeEnum.heart,
    );
  }
}
