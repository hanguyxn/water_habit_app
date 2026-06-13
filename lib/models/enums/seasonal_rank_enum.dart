enum SeasonalRankEnum {
  seed(0),
  sprout(1),
  leaf(2),
  flower(3),
  tree(4),
  ancientTree(5),
  legendaryForest(6);

  const SeasonalRankEnum(this.value);
  final int value;

  String get label {
    switch (this) {
      case SeasonalRankEnum.seed: return '🌰 Hạt giống';
      case SeasonalRankEnum.sprout: return '🌱 Mầm non';
      case SeasonalRankEnum.leaf: return '🍃 Lá xanh';
      case SeasonalRankEnum.flower: return '🌸 Hoa nở';
      case SeasonalRankEnum.tree: return '🌳 Cây lớn';
      case SeasonalRankEnum.ancientTree: return '🌲 Cổ thụ';
      case SeasonalRankEnum.legendaryForest: return '🏔️ Rừng huyền thoại';
    }
  }

  String get emoji {
    switch (this) {
      case SeasonalRankEnum.seed: return '🌰';
      case SeasonalRankEnum.sprout: return '🌱';
      case SeasonalRankEnum.leaf: return '🍃';
      case SeasonalRankEnum.flower: return '🌸';
      case SeasonalRankEnum.tree: return '🌳';
      case SeasonalRankEnum.ancientTree: return '🌲';
      case SeasonalRankEnum.legendaryForest: return '🏔️';
    }
  }

  static SeasonalRankEnum fromValue(int value) {
    return SeasonalRankEnum.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SeasonalRankEnum.seed,
    );
  }
}
