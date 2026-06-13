import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_model.freezed.dart';
part 'friend_model.g.dart';

@freezed
class FriendModel with _$FriendModel {
  const factory FriendModel({
    required String id,
    required String username,
    String? displayName,
    String? avatarUrl,
    required int level,
    required int currentStreak,
    required double todayProgressPercent, // 0.0 - 1.0
    required int todayConsumedMl,
    required int todayGoalMl,
    @Default(0) int friendStatus, // FriendStatusEnum: inactive(0), drinking(1), completed(2)
    DateTime? lastActiveAt,
    required DateTime friendsSince,
  }) = _FriendModel;

  factory FriendModel.fromJson(Map<String, dynamic> json) =>
      _$FriendModelFromJson(json);
}
