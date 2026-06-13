import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';

// ─── Streak Size ─────────────────────────────────────────────────────────────

enum StreakBadgeSize {
  small,
  medium,
  large,
}

// ─── StreakBadge ──────────────────────────────────────────────────────────────

class StreakBadge extends StatefulWidget {
  const StreakBadge({
    super.key,
    required this.streak,
    this.size = StreakBadgeSize.medium,
    this.showLabel = false,
  });

  final int streak;
  final StreakBadgeSize size;
  final bool showLabel;

  @override
  State<StreakBadge> createState() => _StreakBadgeState();
}

class _StreakBadgeState extends State<StreakBadge>
    with TickerProviderStateMixin {
  late final AnimationController _fireController;
  late final AnimationController _pulseController;
  late final Animation<double> _fireAnim;
  late final Animation<double> _pulseAnim;

  bool get _isEpicStreak => widget.streak >= 7;

  @override
  void initState() {
    super.initState();

    _fireController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fireAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fireController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (_isEpicStreak) {
      _fireController.repeat(reverse: true);
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StreakBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isEpicStreak && !_fireController.isAnimating) {
      _fireController.repeat(reverse: true);
      _pulseController.repeat(reverse: true);
    } else if (!_isEpicStreak && _fireController.isAnimating) {
      _fireController.stop();
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _fireController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  double get _containerHeight {
    switch (widget.size) {
      case StreakBadgeSize.small:
        return 28;
      case StreakBadgeSize.medium:
        return 34;
      case StreakBadgeSize.large:
        return 42;
    }
  }

  double get _emojiSize {
    switch (widget.size) {
      case StreakBadgeSize.small:
        return 13;
      case StreakBadgeSize.medium:
        return 16;
      case StreakBadgeSize.large:
        return 22;
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case StreakBadgeSize.small:
        return 12;
      case StreakBadgeSize.medium:
        return 14;
      case StreakBadgeSize.large:
        return 18;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case StreakBadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case StreakBadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 5);
      case StreakBadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 14, vertical: 7);
    }
  }

  Color get _streakColor => AppColors.getStreakColor(widget.streak);

  @override
  Widget build(BuildContext context) {
    if (widget.streak <= 0) return const SizedBox.shrink();

    Widget badge = _buildBadge();

    if (_isEpicStreak) {
      badge = AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnim.value,
            child: child,
          );
        },
        child: badge,
      );
    }

    if (widget.showLabel) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          badge,
          const SizedBox(height: 4),
          Text(
            '${widget.streak} day streak',
            style: TextStyle(
              fontSize: _fontSize * 0.75,
              fontWeight: FontWeight.w600,
              fontFamily: 'Quicksand',
              color: _streakColor,
            ),
          ),
        ],
      );
    }

    return badge;
  }

  Widget _buildBadge() {
    // Calculate intensity: the higher the streak, the more opaque background
    final intensity = (widget.streak / 30.0).clamp(0.15, 0.35);

    return Container(
      height: _containerHeight,
      padding: _padding,
      decoration: BoxDecoration(
        color: _streakColor.withValues(alpha: intensity),
        borderRadius: BorderRadius.circular(_containerHeight / 2),
        border: Border.all(
          color: _streakColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: _isEpicStreak
            ? [
                BoxShadow(
                  color: _streakColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFireEmoji(),
          const SizedBox(width: 4),
          Text(
            '${widget.streak}',
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: FontWeight.w800,
              fontFamily: 'Nunito',
              color: _streakColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFireEmoji() {
    final emoji = Text(
      '🔥',
      style: TextStyle(fontSize: _emojiSize),
    );

    if (!_isEpicStreak) return emoji;

    return AnimatedBuilder(
      animation: _fireAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_fireAnim.value * 2),
          child: Transform.rotate(
            angle: math.sin(_fireAnim.value * math.pi * 2) * 0.1,
            child: child,
          ),
        );
      },
      child: emoji,
    );
  }
}
