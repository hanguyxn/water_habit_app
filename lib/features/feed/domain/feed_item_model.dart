import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_item_model.freezed.dart';
part 'feed_item_model.g.dart';

@freezed
class FeedItemModel with _$FeedItemModel {
  const factory FeedItemModel({
    required String id,
    required String userId,
    required String username,
    String? userAvatarUrl,
    required int userLevel,
    required int eventType, // FeedEventTypeEnum: goalCompleted(0), streakMilestone(1), levelUp(2), waterSupport(3), newFriend(4)
    required String message,
    String? extraData, // JSON string for event-specific data
    @Default({}) Map<String, int> reactions, // userId -> reactionType
    required DateTime createdAt,
  }) = _FeedItemModel;

  factory FeedItemModel.fromJson(Map<String, dynamic> json) =>
      _$FeedItemModelFromJson(json);
}
