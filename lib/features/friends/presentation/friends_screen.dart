import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';
import 'package:water_habit_app/core/widgets/app_avatar.dart';
import 'package:water_habit_app/core/widgets/empty_state_widget.dart';
import 'package:water_habit_app/core/localization/app_localizations.dart';
import 'package:water_habit_app/features/friends/presentation/widgets/friend_card.dart';
import 'package:water_habit_app/features/friends/presentation/widgets/friend_request_card.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data
  final List<Map<String, dynamic>> _friends = [
    {'name': 'Hương Giang', 'username': '@huonggiang', 'level': 12, 'streak': 15, 'progress': 0.8, 'status': 2},
    {'name': 'Minh Tuấn', 'username': '@minhtuan', 'level': 8, 'streak': 7, 'progress': 0.45, 'status': 1},
    {'name': 'Lan Anh', 'username': '@lananh', 'level': 5, 'streak': 3, 'progress': 0.0, 'status': 0},
    {'name': 'Đức Huy', 'username': '@duchuy', 'level': 20, 'streak': 30, 'progress': 1.0, 'status': 2},
  ];

  final List<Map<String, dynamic>> _requests = [
    {'name': 'Thanh Mai', 'username': '@thanhmai', 'level': 6, 'isIncoming': true},
    {'name': 'Quốc Bảo', 'username': '@quocbao', 'level': 3, 'isIncoming': false},
  ];

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
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.tr('friends.title')),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: () => context.push('/friends/search'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary500,
          labelColor: AppColors.primary700,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: context.tr('friends.tabFriends')),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.tr('friends.tabRequests')),
                  if (_requests.where((r) => r['isIncoming'] == true).isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary500,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_requests.where((r) => r['isIncoming'] == true).length}',
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Friends Tab
          _friends.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.people_outline,
                  title: context.tr('friends.noFriends'),
                  subtitle: context.tr('friends.noFriendsSubtitle'),
                  actionLabel: context.tr('feed.findFriends'),
                )
              : RefreshIndicator(
                  onRefresh: () async {},
                  color: AppColors.primary500,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _friends.length,
                    itemBuilder: (context, index) {
                      final f = _friends[index];
                      return FriendCard(
                        name: f['name'],
                        username: f['username'],
                        level: f['level'],
                        streak: f['streak'],
                        progress: f['progress'],
                        status: f['status'],
                        index: index,
                      );
                    },
                  ),
                ),

          // Requests Tab
          _requests.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.mail_outline,
                  title: context.tr('friends.noRequestsTitle'),
                  subtitle: context.tr('friends.noRequestsSubtitle'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final r = _requests[index];
                    return FriendRequestCard(
                      name: r['name'],
                      username: r['username'],
                      level: r['level'],
                      isIncoming: r['isIncoming'],
                      index: index,
                    );
                  },
                ),
        ],
      ),
    );
  }
}
