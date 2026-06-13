import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';
import 'package:water_habit_app/features/friends/domain/friend_model.dart';
import 'package:water_habit_app/features/friends/providers/friends_providers.dart';
import 'package:water_habit_app/features/friends/presentation/widgets/water_support_dialog.dart';

class FriendCard extends ConsumerStatefulWidget {
  const FriendCard({
    super.key,
    required this.friend,
    required this.index,
    this.onTap,
  });

  final FriendModel friend;
  final int index;
  final VoidCallback? onTap;

  @override
  ConsumerState<FriendCard> createState() => _FriendCardState();
}

class _FriendCardState extends ConsumerState<FriendCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    // Staggered delay based on index
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _getStatusEmoji() {
    switch (widget.friend.friendStatus) {
      case 1:
        return '🌱';
      case 2:
        return '🌸';
      default:
        return '😴';
    }
  }

  String _getStatusText() {
    switch (widget.friend.friendStatus) {
      case 1:
        return 'Đang uống';
      case 2:
        return 'Đã hoàn thành';
      default:
        return 'Chưa hoạt động';
    }
  }

  Color _getStatusColor() {
    switch (widget.friend.friendStatus) {
      case 1:
        return AppColors.statusDrinking;
      case 2:
        return AppColors.statusCompleted;
      default:
        return AppColors.statusInactive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cooldownAsync = ref.watch(
      waterSupportCooldownProvider(widget.friend.id),
    );

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardLight,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.natureShadowLight,
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // Avatar with status indicator
              _buildAvatar(),
              const SizedBox(width: 12),

              // Info column
              Expanded(child: _buildInfoColumn()),

              const SizedBox(width: 8),

              // Progress + Actions column
              _buildProgressAndActions(cooldownAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: _getStatusColor().withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              backgroundColor: AppColors.backgroundLight,
              backgroundImage: widget.friend.avatarUrl != null
                  ? NetworkImage(widget.friend.avatarUrl!)
                  : null,
              child: widget.friend.avatarUrl == null
                  ? Text(
                      (widget.friend.displayName ?? widget.friend.username)
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontFamily: 'Nunito',
                      ),
                    )
                  : null,
            ),
          ),
        ),
        // Status dot
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.cardLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardLight, width: 2),
            ),
            child: Center(
              child: Text(
                _getStatusEmoji(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Username
        Text(
          widget.friend.displayName ?? widget.friend.username,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: 'Nunito',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),

        // Level badge + Streak
        Row(
          children: [
            // Level badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.getLevelColor(widget.friend.level)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Lv.${widget.friend.level}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.getLevelColor(widget.friend.level),
                  fontFamily: 'Quicksand',
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Streak fire
            if (widget.friend.currentStreak > 0) ...[
              Icon(
                Icons.local_fire_department_rounded,
                size: 14,
                color: AppColors.getStreakColor(widget.friend.currentStreak),
              ),
              const SizedBox(width: 2),
              Text(
                '${widget.friend.currentStreak}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.getStreakColor(widget.friend.currentStreak),
                  fontFamily: 'Quicksand',
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),

        // Status text
        Text(
          '${_getStatusEmoji()} ${_getStatusText()}',
          style: TextStyle(
            fontSize: 11,
            color: _getStatusColor(),
            fontWeight: FontWeight.w600,
            fontFamily: 'Quicksand',
          ),
        ),
      ],
    );
  }

  Widget _buildProgressAndActions(AsyncValue<bool> cooldownAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Today's water progress
        SizedBox(
          width: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${widget.friend.todayConsumedMl}/${widget.friend.todayGoalMl}ml',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Quicksand',
                ),
              ),
              const SizedBox(height: 4),
              // Mini progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: widget.friend.todayProgressPercent.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: AppColors.accentSurface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.friend.todayProgressPercent >= 1.0
                        ? AppColors.success
                        : AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Water support button
        cooldownAsync.when(
          data: (canSend) => _buildSupportButton(canSend),
          loading: () => const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          ),
          error: (_, __) => _buildSupportButton(false),
        ),
      ],
    );
  }

  Widget _buildSupportButton(bool canSend) {
    return GestureDetector(
      onTap: canSend
          ? () async {
              final friendActions = ref.read(friendActionsProvider.notifier);
              await friendActions.sendWaterSupport(widget.friend.id);

              if (mounted) {
                showDialog(
                  context: context,
                  builder: (context) => WaterSupportDialog(
                    friendName:
                        widget.friend.displayName ?? widget.friend.username,
                  ),
                );
                // Refresh cooldown state
                ref.invalidate(waterSupportCooldownProvider(widget.friend.id));
              }
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: canSend ? AppColors.accentGradient : null,
          color: canSend ? null : AppColors.disabledBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: canSend
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          canSend ? '💧 Gửi hỗ trợ' : '✓ Đã gửi',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: canSend ? Colors.white : AppColors.textTertiary,
            fontFamily: 'Quicksand',
          ),
        ),
      ),
    );
  }
}
