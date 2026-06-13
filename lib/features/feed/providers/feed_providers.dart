import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:water_habit_app/features/feed/data/feed_repository.dart';
import 'package:water_habit_app/features/feed/domain/feed_item_model.dart';

part 'feed_providers.g.dart';

@Riverpod(keepAlive: true)
FeedRepository feedRepository(FeedRepositoryRef ref) {
  return FeedRepository();
}

@riverpod
Stream<List<FeedItemModel>> feed(FeedRef ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);
  final repo = ref.watch(feedRepositoryProvider);
  return repo.getFeed(user.uid);
}

@riverpod
class FeedReaction extends _$FeedReaction {
  @override
  FutureOr<void> build() {}

  Future<void> toggleReaction(
    String feedItemId,
    String userId,
    int reactionType,
    Map<String, int> currentReactions,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(feedRepositoryProvider);
      final existingReaction = currentReactions[userId];

      if (existingReaction == reactionType) {
        // Remove reaction if same type
        await repo.removeReaction(feedItemId, userId);
      } else {
        // Add or change reaction
        await repo.addReaction(feedItemId, userId, reactionType);
      }
    });
  }
}

@riverpod
class FeedPoster extends _$FeedPoster {
  @override
  FutureOr<void> build() {}

  Future<void> postEvent(
    int eventType,
    String message, {
    String? extraData,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(feedRepositoryProvider);
      await repo.postFeedEvent(user.uid, eventType, message, extraData: extraData);
    });
  }
}
