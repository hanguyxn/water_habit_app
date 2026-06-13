import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';
import 'package:water_habit_app/core/constants/app_constants.dart';
import 'package:water_habit_app/core/utils/extensions.dart';
import 'package:water_habit_app/core/widgets/streak_badge.dart';
import 'package:water_habit_app/core/localization/app_localizations.dart';
import 'package:water_habit_app/features/water_tracking/presentation/widgets/water_progress_ring.dart';
import 'package:water_habit_app/features/water_tracking/presentation/widgets/quick_add_button.dart';
import 'package:water_habit_app/features/water_tracking/presentation/widgets/mam_character.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  int _consumedMl = 0;
  final int _goalMl = AppConstants.defaultDailyGoalMl;
  final List<_WaterLogEntry> _todayLogs = [];
  late AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _addWater(int ml) {
    setState(() {
      _consumedMl += ml;
      _todayLogs.insert(0, _WaterLogEntry(ml: ml, time: DateTime.now()));
      if (_consumedMl >= _goalMl) {
        _celebrationController.forward(from: 0);
      }
    });
  }

  double get _progress => (_consumedMl / _goalMl).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCompleted = _consumedMl >= _goalMl;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: now.hour < 17
                ? [AppColors.primary50, AppColors.backgroundLight]
                : [const Color(0xFF1A2E35), const Color(0xFF0D1F22)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${now.greeting(context)} ${now.greetingEmoji}',
                              style: TextStyle(
                                fontSize: 14,
                                color: now.hour < 17 ? AppColors.textSecondary : Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.tr('home.hey'),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: now.hour < 17 ? AppColors.textPrimary : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const StreakBadge(streak: 7),
                    ],
                  ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),
                ),
              ),

              // Water Progress Ring
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: WaterProgressRing(
                      progress: _progress,
                      consumedMl: _consumedMl,
                      goalMl: _goalMl,
                      size: 220,
                    ),
                  ).animate().scale(begin: const Offset(0.8, 0.8), duration: 800.ms, curve: Curves.elasticOut),
                ),
              ),

              // Quick Add Buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          context.tr('home.quickAddTitle') + ' 💧',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: now.hour < 17 ? AppColors.textPrimary : Colors.white,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: AppConstants.defaultGlassSizes.asMap().entries.map((entry) {
                          return QuickAddButton(
                            amount: entry.value,
                            onTap: () => _addWater(entry.value),
                          ).animate().fadeIn(delay: (200 + entry.key * 100).ms).scale(
                                begin: const Offset(0.8, 0.8),
                                delay: (200 + entry.key * 100).ms,
                              );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              // Mầm Character
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: MamCharacter(progress: _progress, isCompleted: isCompleted),
                ),
              ),

              // Today's Log
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    context.tr('home.dailyLog') + ' 📋',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: now.hour < 17 ? AppColors.textPrimary : Colors.white,
                    ),
                  ),
                ),
              ),
              if (_todayLogs.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.water_drop_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            context.tr('home.dailyLogEmpty'),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final log = _todayLogs[index];
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.accent100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.water_drop, color: AppColors.accent400, size: 22),
                        ),
                        title: Text('${log.ml}ml', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(log.time.formatTime, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.grey.shade400, size: 20),
                          onPressed: () {
                            setState(() {
                              _consumedMl -= log.ml;
                              _todayLogs.removeAt(index);
                            });
                          },
                        ),
                      )
                          .animate()
                          .fadeIn(delay: (index * 50).ms)
                          .slideX(begin: 0.1, end: 0, delay: (index * 50).ms);
                    },
                    childCount: _todayLogs.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaterLogEntry {
  final int ml;
  final DateTime time;
  const _WaterLogEntry({required this.ml, required this.time});
}
