import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:water_habit_app/features/auth/domain/user_model.dart';
import 'package:water_habit_app/features/friends/data/friend_repository.dart';
import 'package:water_habit_app/features/friends/domain/friend_model.dart';
import 'package:water_habit_app/features/friends/domain/friend_request_model.dart';

part 'friends_providers.g.dart';

@Riverpod(keepAlive: true)
FriendRepository friendRepository(FriendRepositoryRef ref) {
  return FriendRepository();
}

@riverpod
Stream<List<FriendModel>> friendsList(FriendsListRef ref, String userId) {
  final repo = ref.watch(friendRepositoryProvider);
  return repo.getFriends(userId);
}

@riverpod
Stream<List<FriendRequestModel>> incomingRequests(IncomingRequestsRef ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);
  final repo = ref.watch(friendRepositoryProvider);
  return repo.getIncomingRequests(user.uid);
}

@riverpod
Stream<List<FriendRequestModel>> outgoingRequests(OutgoingRequestsRef ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);
  final repo = ref.watch(friendRepositoryProvider);
  return repo.getOutgoingRequests(user.uid);
}

@riverpod
Future<List<UserModel>> userSearch(UserSearchRef ref, String query) async {
  if (query.trim().length < 2) return [];
  final user = FirebaseAuth.instance.currentUser;
  final repo = ref.watch(friendRepositoryProvider);
  return repo.searchUsers(query, excludeUserId: user?.uid);
}

@riverpod
Future<bool> waterSupportCooldown(
  WaterSupportCooldownRef ref,
  String friendId,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;
  final repo = ref.watch(friendRepositoryProvider);
  return repo.canSendWaterSupport(user.uid, friendId);
}

@riverpod
class FriendActions extends _$FriendActions {
  @override
  FutureOr<void> build() {}

  Future<void> sendRequest(String targetUserId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(friendRepositoryProvider);
      await repo.sendFriendRequest(user.uid, targetUserId);
    });
  }

  Future<void> acceptRequest(String requestId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(friendRepositoryProvider);
      await repo.acceptFriendRequest(requestId);
    });
  }

  Future<void> rejectRequest(String requestId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(friendRepositoryProvider);
      await repo.rejectFriendRequest(requestId);
    });
  }

  Future<void> cancelRequest(String requestId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(friendRepositoryProvider);
      await repo.cancelFriendRequest(requestId);
    });
  }

  Future<void> removeFriend(String friendId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(friendRepositoryProvider);
      await repo.removeFriend(user.uid, friendId);
    });
  }

  Future<void> sendWaterSupport(String friendId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(friendRepositoryProvider);
      await repo.sendWaterSupport(user.uid, friendId);
    });
  }
}
