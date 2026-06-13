import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:water_habit_app/features/auth/domain/user_model.dart';
import 'package:water_habit_app/features/auth/providers/auth_providers.dart';
import 'package:water_habit_app/features/profile/data/profile_repository.dart';
import 'package:water_habit_app/features/profile/domain/profile_model.dart';

part 'profile_providers.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepository();
}

@riverpod
Stream<UserModel?> profile(ProfileRef ref, String userId) {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getProfile(userId);
}

@riverpod
Future<ProfileStats> profileStats(ProfileStatsRef ref, String userId) {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getProfileStats(userId);
}

@riverpod
UserModel? myProfile(MyProfileRef ref) {
  final currentUserAsync = ref.watch(currentUserProvider);
  return currentUserAsync.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
}

@riverpod
Stream<List<Achievement>> achievements(AchievementsRef ref, String userId) {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getAchievements(userId);
}

@riverpod
Future<List<WeeklyWaterData>> weeklyWaterData(
  WeeklyWaterDataRef ref,
  String userId,
) {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getWeeklyWaterData(userId);
}

@riverpod
class ProfileEditor extends _$ProfileEditor {
  @override
  FutureOr<void> build() {}

  Future<void> updateProfile(
    String userId, {
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      await repo.updateProfile(
        userId,
        displayName: displayName,
        bio: bio,
        avatarUrl: avatarUrl,
      );
    });
  }

  Future<void> updateDailyGoal(String userId, int goalMl) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      await repo.updateDailyGoal(userId, goalMl);
    });
  }
}
