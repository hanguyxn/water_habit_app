import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:water_habit_app/features/auth/providers/auth_providers.dart';
import 'package:water_habit_app/features/water_tracking/data/water_repository.dart';
import 'package:water_habit_app/features/water_tracking/domain/daily_goal_model.dart';
import 'package:water_habit_app/features/water_tracking/domain/water_entry_model.dart';

part 'water_providers.g.dart';

@Riverpod(keepAlive: true)
WaterRepository waterRepository(WaterRepositoryRef ref) {
  return WaterRepository();
}

@riverpod
Stream<DailyGoal> todayGoal(TodayGoalRef ref) {
  final authState = ref.watch(authStateProvider);
  final repo = ref.watch(waterRepositoryProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value(
          DailyGoal(
            date: repo.getTodayDate(),
            goalMl: 2500,
            consumedMl: 0,
            entries: const [],
            completed: false,
          ),
        );
      }
      return repo.getDailyGoal(user.uid, repo.getTodayDate());
    },
    loading: () => Stream.value(
      DailyGoal(
        date: repo.getTodayDate(),
        goalMl: 2500,
        consumedMl: 0,
        entries: const [],
        completed: false,
      ),
    ),
    error: (_, __) => Stream.value(
      DailyGoal(
        date: repo.getTodayDate(),
        goalMl: 2500,
        consumedMl: 0,
        entries: const [],
        completed: false,
      ),
    ),
  );
}

@riverpod
double waterPercentage(WaterPercentageRef ref) {
  final todayGoalAsync = ref.watch(todayGoalProvider);
  return todayGoalAsync.when(
    data: (goal) {
      if (goal.goalMl == 0) return 0.0;
      return (goal.consumedMl / goal.goalMl).clamp(0.0, 1.5);
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
}

@riverpod
Future<List<DailyGoal>> weeklyData(WeeklyDataRef ref) async {
  final authState = ref.watch(authStateProvider);
  final repo = ref.watch(waterRepositoryProvider);

  return authState.when(
    data: (user) {
      if (user == null) return <DailyGoal>[];
      return repo.getWeeklyData(user.uid);
    },
    loading: () => <DailyGoal>[],
    error: (_, __) => <DailyGoal>[],
  );
}

@riverpod
class WaterActions extends _$WaterActions {
  @override
  FutureOr<void> build() {}

  Future<void> addWater(int amountMl, {String? note, int glassSize = 2}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authStateProvider);
      final user = authState.valueOrNull;
      if (user == null) return;

      final repo = ref.read(waterRepositoryProvider);
      final entry = WaterEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amountMl: amountMl,
        timestamp: DateTime.now(),
        note: note,
        glassSize: glassSize,
      );

      await repo.addWaterEntry(user.uid, entry);
      ref.invalidate(todayGoalProvider);
      ref.invalidate(weeklyDataProvider);
    });
  }

  Future<void> removeEntry(String entryId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authStateProvider);
      final user = authState.valueOrNull;
      if (user == null) return;

      final repo = ref.read(waterRepositoryProvider);
      await repo.removeWaterEntry(user.uid, repo.getTodayDate(), entryId);
      ref.invalidate(todayGoalProvider);
      ref.invalidate(weeklyDataProvider);
    });
  }

  Future<void> updateGoal(int goalMl) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authStateProvider);
      final user = authState.valueOrNull;
      if (user == null) return;

      final repo = ref.read(waterRepositoryProvider);
      await repo.updateDailyGoal(user.uid, goalMl);
      ref.invalidate(todayGoalProvider);
    });
  }
}
