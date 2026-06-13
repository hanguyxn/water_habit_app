enum FriendStatusEnum {
  inactive(0),
  drinking(1),
  completed(2);

  const FriendStatusEnum(this.value);
  final int value;

  String get label {
    switch (this) {
      case FriendStatusEnum.inactive:
        return '😴 Chưa hoạt động';
      case FriendStatusEnum.drinking:
        return '🌱 Đang uống';
      case FriendStatusEnum.completed:
        return '🌸 Đã hoàn thành';
    }
  }

  String get emoji {
    switch (this) {
      case FriendStatusEnum.inactive:
        return '😴';
      case FriendStatusEnum.drinking:
        return '🌱';
      case FriendStatusEnum.completed:
        return '🌸';
    }
  }

  static FriendStatusEnum fromValue(int value) {
    return FriendStatusEnum.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FriendStatusEnum.inactive,
    );
  }
}
