import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_habit_app/core/providers/auth_provider.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';
import 'package:water_habit_app/core/widgets/loading_widget.dart';
import 'package:water_habit_app/core/widgets/app_error_widget.dart';
import 'package:water_habit_app/core/widgets/empty_state_widget.dart';
import 'package:water_habit_app/core/localization/app_localizations.dart';
import 'package:water_habit_app/features/profile/providers/profile_providers.dart';
import 'package:water_habit_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:water_habit_app/features/profile/presentation/widgets/stats_card.dart';
import 'package:water_habit_app/features/profile/presentation/widgets/weekly_chart.dart';
import 'package:water_habit_app/features/profile/domain/profile_model.dart';
import 'package:water_habit_app/features/auth/domain/user_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({
    super.key,
    this.userId,
  });

  final String? userId;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return authState.when(
      loading: () => const Scaffold(body: LoadingWidget()),
      error: (error, stack) => Scaffold(
        body: AppErrorWidget(
          errorMessage: '${context.tr('profile.errorUserLoad')}: $error',
          onRetry: () => ref.invalidate(authStateProvider),
        ),
      ),
      data: (currentUser) {
        if (currentUser == null) {
          return Scaffold(
            body: EmptyStateWidget(
              icon: Icons.lock_outline,
              title: context.tr('profile.notLoggedIn'),
              subtitle: context.tr('profile.pleaseLogin'),
            ),
          );
        }

        final targetUserId = widget.userId ?? currentUser.uid;
        final isOwnProfile = targetUserId == currentUser.uid;

        final profileAsync = ref.watch(profileProvider(targetUserId));

        return profileAsync.when(
          loading: () => const Scaffold(body: LoadingWidget()),
          error: (error, stack) => Scaffold(
            body: AppErrorWidget(
              errorMessage: '${context.tr('profile.errorUserLoad')}: $error',
              onRetry: () => ref.invalidate(profileProvider(targetUserId)),
            ),
          ),
          data: (userModel) {
            if (userModel == null) {
              return Scaffold(
                body: EmptyStateWidget(
                  icon: Icons.person_off_outlined,
                  title: context.tr('friends.notFound'),
                  subtitle: context.tr('profile.userDeleted'),
                ),
              );
            }

            final statsAsync = ref.watch(profileStatsProvider(targetUserId));
            final weeklyDataAsync = ref.watch(weeklyWaterDataProvider(targetUserId));
            final achievementsAsync = ref.watch(achievementsProvider(targetUserId));

            return Scaffold(
              backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              body: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: statsAsync.when(
                        loading: () => Container(
                          height: 300,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        ),
                        error: (err, _) => Container(
                          height: 300,
                          alignment: Alignment.center,
                          child: Text('${context.tr('profile.errorStats')}: $err'),
                        ),
                        data: (stats) => ProfileHeader(
                          user: userModel,
                          stats: stats,
                          isOwnProfile: isOwnProfile,
                          onEditPressed: () {
                            context.push('/profile/edit');
                          },
                          onAddFriendPressed: () {
                            // Friend request logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(context.tr('profile.friendRequestSent'))),
                            );
                          },
                          onSendSupportPressed: () {
                            // Support wave logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(context.tr('profile.cheered'))),
                            );
                          },
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          controller: _tabController,
                          indicatorColor: AppColors.primary500,
                          labelColor: isDark ? Colors.white : AppColors.textPrimary,
                          unselectedLabelColor: isDark
                              ? Colors.white.withOpacity(0.5)
                              : AppColors.textTertiary,
                          labelStyle: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          tabs: [
                            Tab(text: context.tr('profile.tabStats')),
                            Tab(text: context.tr('profile.tabAchievements')),
                          ],
                        ),
                        isDark: isDark,
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStatsTab(statsAsync, weeklyDataAsync, isDark),
                    _buildAchievementsTab(achievementsAsync, isDark),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatsTab(
    AsyncValue<ProfileStats> statsAsync,
    AsyncValue<List<WeeklyWaterData>> weeklyAsync,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        weeklyAsync.when(
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => SizedBox(
            height: 200,
            child: Center(child: Text('${context.tr('profile.errorChart')}: $err')),
          ),
          data: (weeklyData) => WeeklyChart(data: weeklyData),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            context.tr('profile.statsDetailed'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'Nunito',
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('${context.tr('profile.errorStats')}: $err')),
          data: (stats) => GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              StatsCard(
                icon: '📅',
                label: context.tr('profile.daysTracked'),
                value: stats.totalDaysTracked.toString(),
                suffix: ' ${context.tr('profile.daysSuffix')}',
                iconColor: Colors.purple,
              ),
              StatsCard(
                icon: '🎯',
                label: context.tr('profile.goalsCompleted'),
                value: stats.goalsCompleted.toString(),
                suffix: ' ${context.tr('profile.timesSuffix')}',
                iconColor: Colors.amber,
              ),
              StatsCard(
                icon: '💧',
                label: context.tr('profile.avgDaily'),
                value: stats.averageDailyMl.round().toString(),
                suffix: ' ml',
                iconColor: Colors.blue,
              ),
              StatsCard(
                icon: '🔥',
                label: context.tr('profile.longestStreak'),
                value: stats.longestStreak.toString(),
                suffix: ' ${context.tr('profile.daysSuffix')}',
                iconColor: Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsTab(
    AsyncValue<List<Achievement>> achievementsAsync,
    bool isDark,
  ) {
    return achievementsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('${context.tr('profile.errorAchievements')}: $err')),
      data: (achievements) {
        if (achievements.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.emoji_events_outlined,
            title: context.tr('profile.noAchievements'),
            subtitle: context.tr('profile.noAchievementsSubtitle'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final ach = achievements[index];
            final tierColor = _getTierColor(ach.tier);

            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: tierColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        ach.iconName,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ach.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ach.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      color: isDark
                          ? Colors.white.withOpacity(0.6)
                          : AppColors.textTertiary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getTierColor(int tier) {
    switch (tier) {
      case 1:
        return const Color(0xFFC0C0C0); // Silver
      case 2:
        return const Color(0xFFFFD700); // Gold
      case 3:
        return const Color(0xFFB9F2FF); // Diamond
      default:
        return const Color(0xFFCD7F32); // Bronze
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, {required this.isDark});

  final TabBar _tabBar;
  final bool isDark;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: isDark ? AppColors.surfaceDark : Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
