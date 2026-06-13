import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String username,
    required String email,
    String? displayName,
    String? avatarUrl,
    String? bio,
    @Default(1) int level,
    @Default(0) int xp,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default(0.0) double totalWaterMl,
    @Default(2500) int dailyGoalMl,
    @Default(0) int prestigeStars,
    @Default(0) int seasonalRank,
    String? seasonId,
    @Default(0) int friendCount,
    String? coupleId,
    required DateTime createdAt,
    DateTime? lastActiveAt,
    String? fcmToken,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
