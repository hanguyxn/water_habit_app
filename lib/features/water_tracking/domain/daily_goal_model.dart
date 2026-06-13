import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:water_habit_app/features/water_tracking/domain/water_entry_model.dart';

part 'daily_goal_model.freezed.dart';
part 'daily_goal_model.g.dart';

@freezed
class DailyGoal with _$DailyGoal {
  const factory DailyGoal({
    required String date, // yyyy-MM-dd
    required int goalMl,
    @Default(0) int consumedMl,
    @Default([]) List<WaterEntry> entries,
    @Default(false) bool completed,
    DateTime? completedAt,
  }) = _DailyGoal;

  factory DailyGoal.fromJson(Map<String, dynamic> json) =>
      _$DailyGoalFromJson(json);
}
