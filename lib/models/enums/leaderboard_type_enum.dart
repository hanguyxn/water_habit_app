enum LeaderboardTypeEnum {
  daily(0),
  weekly(1),
  monthly(2),
  friends(3);

  const LeaderboardTypeEnum(this.value);
  final int value;

  String get label {
    switch (this) {
      case LeaderboardTypeEnum.daily: return 'Hôm nay';
      case LeaderboardTypeEnum.weekly: return 'Tuần này';
      case LeaderboardTypeEnum.monthly: return 'Tháng này';
      case LeaderboardTypeEnum.friends: return 'Bạn bè';
    }
  }

  static LeaderboardTypeEnum fromValue(int value) {
    return LeaderboardTypeEnum.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LeaderboardTypeEnum.daily,
    );
  }
}

enum FriendRequestStatusEnum {
  pending(0),
  accepted(1),
  rejected(2),
  cancelled(3);

  const FriendRequestStatusEnum(this.value);
  final int value;

  static FriendRequestStatusEnum fromValue(int value) {
    return FriendRequestStatusEnum.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FriendRequestStatusEnum.pending,
    );
  }
}

enum WaterGlassSizeEnum {
  small100(0, 100, '100ml'),
  medium200(1, 200, '200ml'),
  standard250(2, 250, '250ml'),
  large300(3, 300, '300ml'),
  bottle500(4, 500, '500ml');

  const WaterGlassSizeEnum(this.value, this.ml, this.label);
  final int value;
  final int ml;
  final String label;

  String get icon {
    switch (this) {
      case WaterGlassSizeEnum.small100: return '🥃';
      case WaterGlassSizeEnum.medium200: return '🥤';
      case WaterGlassSizeEnum.standard250: return '🫗';
      case WaterGlassSizeEnum.large300: return '🍶';
      case WaterGlassSizeEnum.bottle500: return '🧴';
    }
  }

  static WaterGlassSizeEnum fromValue(int value) {
    return WaterGlassSizeEnum.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WaterGlassSizeEnum.standard250,
    );
  }
}
