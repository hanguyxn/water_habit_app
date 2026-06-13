import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_request_model.freezed.dart';
part 'friend_request_model.g.dart';

@freezed
class FriendRequestModel with _$FriendRequestModel {
  const factory FriendRequestModel({
    required String id,
    required String senderId,
    required String senderUsername,
    String? senderAvatarUrl,
    required int senderLevel,
    required String receiverId,
    required String receiverUsername,
    @Default(0) int status, // FriendRequestStatusEnum: pending(0), accepted(1), rejected(2), cancelled(3)
    required DateTime createdAt,
    DateTime? respondedAt,
  }) = _FriendRequestModel;

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) =>
      _$FriendRequestModelFromJson(json);
}
