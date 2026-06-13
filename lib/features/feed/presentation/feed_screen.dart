import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';
import 'package:water_habit_app/core/widgets/empty_state_widget.dart';
import 'package:water_habit_app/core/localization/app_localizations.dart';
import 'package:water_habit_app/core/utils/extensions.dart';
import 'package:water_habit_app/features/feed/presentation/widgets/feed_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedItems = [
      {'user': 'Hương Giang', 'event': 0, 'time': DateTime.now().subtract(const Duration(minutes: 5)), 'reactions': {'❤️': 3, '🌱': 1}},
      {'user': 'Minh Tuấn', 'event': 1, 'time': DateTime.now().subtract(const Duration(minutes: 15)), 'reactions': {'🔥': 2}},
      {'user': 'Lan Anh', 'event': 2, 'time': DateTime.now().subtract(const Duration(hours: 1)), 'reactions': {'❤️': 5, '🔥': 8, '💧': 2}},
      {'user': 'Đức Huy', 'event': 3, 'time': DateTime.now().subtract(const Duration(hours: 2)), 'reactions': {'💧': 1}},
      {'user': 'Thanh Mai', 'event': 4, 'time': DateTime.now().subtract(const Duration(hours: 3)), 'reactions': {'❤️': 2, '🌱': 3}},
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.tr('feed.title')),
        centerTitle: false,
      ),
      body: feedItems.isEmpty
          ? EmptyStateWidget(
              icon: Icons.dynamic_feed_outlined,
              title: context.tr('feed.emptyFeed'),
              subtitle: context.tr('feed.emptyFeedSubtitle'),
              actionLabel: context.tr('feed.findFriends'),
            )
          : RefreshIndicator(
              onRefresh: () async {},
              color: AppColors.primary500,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                itemCount: feedItems.length,
                itemBuilder: (context, index) {
                  final item = feedItems[index];
                  return FeedCard(
                    username: item['user'] as String,
                    eventType: item['event'] as int,
                    message: context.tr('feed.event${item['event']}'),
                    timeAgo: (item['time'] as DateTime).timeAgo(context),
                    reactions: item['reactions'] as Map<String, int>,
                    index: index,
                  );
                },
              ),
            ),
    );
  }
}
