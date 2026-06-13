import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';
import 'package:water_habit_app/features/friends/domain/friend_request_model.dart';
import 'package:water_habit_app/features/friends/providers/friends_providers.dart';

class FriendRequestCard extends ConsumerStatefulWidget {
  const FriendRequestCard({
    super.key,
    required this.request,
    required this.isIncoming,
    required this.index,
  });

  final FriendRequestModel request;
  final bool isIncoming;
  final int index;

  @override
  ConsumerState<FriendRequestCard> createState() => _FriendRequestCardState();
}

class _FriendRequestCardState extends ConsumerState<FriendRequestCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardLight,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColors.natureShadowLight,
            border: Border.all(
              color: widget.isIncoming
                  ? AppColors.primaryLight.withValues(alpha: 0.3)
                  : AppColors.border.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(),
              const SizedBox(width: 12),

              // Info
              Expanded(child: _buildInfo()),

              const SizedBox(width: 8),

              // Actions
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: widget.isIncoming
            ? AppColors.primaryGradient
            : AppColors.secondaryGradient,
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: CircleAvatar(
          backgroundColor: AppColors.backgroundLight,
          backgroundImage: widget.request.senderAvatarUrl != null
              ? NetworkImage(widget.request.senderAvatarUrl!)
              : null,
          child: widget.request.senderAvatarUrl == null
              ? Text(
                  widget.request.senderUsername
                      .substring(0, 1)
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontFamily: 'Nunito',
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildInfo() {
    final username = widget.isIncoming
        ? widget.request.senderUsername
        : widget.request.receiverUsername;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          username,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: 'Nunito',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.getLevelColor(widget.request.senderLevel)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Lv.${widget.request.senderLevel}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.getLevelColor(widget.request.senderLevel),
                  fontFamily: 'Quicksand',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _timeAgo(widget.request.createdAt),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
                fontFamily: 'Quicksand',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions() {
    if (widget.isIncoming) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Accept button
          _ActionButton(
            icon: Icons.check_rounded,
            color: AppColors.success,
            tooltip: 'Chấp nhận',
            onTap: () {
              ref
                  .read(friendActionsProvider.notifier)
                  .acceptRequest(widget.request.id);
            },
          ),
          const SizedBox(width: 8),
          // Reject button
          _ActionButton(
            icon: Icons.close_rounded,
            color: AppColors.textTertiary,
            tooltip: 'Từ chối',
            onTap: () {
              ref
                  .read(friendActionsProvider.notifier)
                  .rejectRequest(widget.request.id);
            },
          ),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Đang chờ...',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
                fontFamily: 'Quicksand',
              ),
            ),
          ),
          const SizedBox(width: 8),
          _ActionButton(
            icon: Icons.close_rounded,
            color: AppColors.textTertiary,
            tooltip: 'Hủy',
            onTap: () {
              ref
                  .read(friendActionsProvider.notifier)
                  .cancelRequest(widget.request.id);
            },
          ),
        ],
      );
    }
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${(diff.inDays / 7).floor()} tuần trước';
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) {
          _scaleController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _scaleController.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.icon,
              size: 20,
              color: widget.color,
            ),
          ),
        ),
      ),
    );
  }
}
