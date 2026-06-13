import 'package:flutter/material.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';

class StatsCard extends StatefulWidget {
  const StatsCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.suffix = '',
    this.iconColor,
    this.delay = Duration.zero,
  });

  final String icon;
  final String label;
  final String value;
  final String suffix;
  final Color? iconColor;
  final Duration delay;

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? AppColors.borderDark
                : AppColors.border,
            width: 1,
          ),
          boxShadow: isDark ? null : AppColors.natureShadowLight,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (widget.iconColor ?? AppColors.primary)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  widget.icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Value with animated counter
            _AnimatedValue(
              value: widget.value,
              suffix: widget.suffix,
              isDark: isDark,
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              widget.label,
              style: TextStyle(
                color: isDark
                    ? AppColors.textOnDark.withValues(alpha: 0.7)
                    : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Quicksand',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedValue extends StatelessWidget {
  const _AnimatedValue({
    required this.value,
    required this.suffix,
    required this.isDark,
  });

  final String value;
  final String suffix;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Try to parse as number for animated counter
    final numValue = double.tryParse(value);

    if (numValue != null) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: numValue),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (context, animValue, _) {
          String displayValue;
          if (numValue == numValue.roundToDouble()) {
            displayValue = animValue.round().toString();
          } else {
            displayValue = animValue.toStringAsFixed(1);
          }
          return RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: displayValue,
                  style: TextStyle(
                    color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Nunito',
                  ),
                ),
                if (suffix.isNotEmpty)
                  TextSpan(
                    text: suffix,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textOnDark.withValues(alpha: 0.7)
                          : AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Quicksand',
                    ),
                  ),
              ],
            ),
          );
        },
      );
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: value,
            style: TextStyle(
              color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              fontFamily: 'Nunito',
            ),
          ),
          if (suffix.isNotEmpty)
            TextSpan(
              text: suffix,
              style: TextStyle(
                color: isDark
                    ? AppColors.textOnDark.withValues(alpha: 0.7)
                    : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Quicksand',
              ),
            ),
        ],
      ),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) => builder(context, child);
}
