import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';

class FeedCard extends StatefulWidget {
  const FeedCard({
    super.key,
    required this.username,
    required this.eventType,
    required this.message,
    required this.timeAgo,
    required this.reactions,
    required this.index,
  });

  final String username;
  final int eventType;
  final String message;
  final String timeAgo;
  final Map<String, int> reactions;
  final int index;

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  late Map<String, int> _reactions;
  final List<String> _emojiOptions = ['❤️', '🌱', '🔥', '💧'];
  String? _myReaction;

  @override
  void initState() {
    super.initState();
    _reactions = Map.from(widget.reactions);
  }

  void _handleReaction(String emoji) {
    setState(() {
      if (_myReaction == emoji) {
        // Remove reaction
        _reactions[emoji] = (_reactions[emoji] ?? 1) - 1;
        if (_reactions[emoji] == 0) {
          _reactions.remove(emoji);
        }
        _myReaction = null;
      } else {
        // If changing reaction, decrement old one
        if (_myReaction != null) {
          _reactions[_myReaction!] = (_reactions[_myReaction!] ?? 1) - 1;
          if (_reactions[_myReaction!] == 0) {
            _reactions.remove(_myReaction!);
          }
        }
        // Add new reaction
        _reactions[emoji] = (_reactions[emoji] ?? 0) + 1;
        _myReaction = emoji;
      }
    });
  }

  String _getEventIcon() {
    switch (widget.eventType) {
      case 0:
        return '🎯'; // goalCompleted
      case 1:
        return '🎀'; // newBow
      case 2:
        return '🔥'; // streakMilestone
      case 3:
        return '💧'; // waterSupport
      case 4:
        return '⬆️'; // levelUp
      default:
        return '🌿';
    }
  }

  Color _getEventColor() {
    switch (widget.eventType) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.pink;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.purple;
      default:
        return AppColors.primary500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: isDark ? null : AppColors.natureShadowLight,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event indicator circle
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _getEventColor().withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _getEventIcon(),
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: widget.username,
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                              const TextSpan(text: ' '),
                              TextSpan(
                                text: widget.message,
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.8)
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.timeAgo,
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: isDark
                                ? Colors.white.withOpacity(0.4)
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            // Interaction/Reaction Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDark
                  ? Colors.white.withOpacity(0.02)
                  : Colors.black.withOpacity(0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Reaction counts
                  Row(
                    children: _reactions.entries.map((entry) {
                      final isMine = _myReaction == entry.key;
                      return Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isMine
                              ? AppColors.primary500.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isMine
                                ? AppColors.primary500.withOpacity(0.3)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${entry.value}',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: isMine
                                    ? AppColors.primary500
                                    : (isDark ? Colors.white : AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  // Emoji selection popover button
                  PopupMenuButton<String>(
                    onSelected: _handleReaction,
                    icon: Icon(
                      Icons.add_reaction_outlined,
                      size: 20,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                    itemBuilder: (context) {
                      return _emojiOptions.map((emoji) {
                        final isSelected = _myReaction == emoji;
                        return PopupMenuItem<String>(
                          value: emoji,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary500.withOpacity(0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        );
                      }).toList();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fade(duration: 400.ms, delay: (widget.index * 100).ms)
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOutQuad);
  }
}
