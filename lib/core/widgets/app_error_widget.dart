import 'package:flutter/material.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';
import 'package:water_habit_app/core/widgets/app_button.dart';

// ─── AppErrorWidget ──────────────────────────────────────────────────────────

class AppErrorWidget extends StatefulWidget {
  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.compact = false,
    this.icon,
  });

  final String message;
  final VoidCallback? onRetry;
  final bool compact;
  final IconData? icon;

  @override
  State<AppErrorWidget> createState() => _AppErrorWidgetState();
}

class _AppErrorWidgetState extends State<AppErrorWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: -4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4, end: 3), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 3, end: 0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) return _buildCompact();
    return _buildFull();
  }

  Widget _buildFull() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnim.value, 0),
                  child: child,
                );
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.errorLight.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon ?? Icons.cloud_off_rounded,
                  size: 36,
                  color: AppColors.error.withValues(alpha: 0.7),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Friendly title
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Nunito',
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Error message
            Text(
              widget.message,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Quicksand',
                color: AppColors.textTertiary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            if (widget.onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton.primary(
                label: 'Try Again',
                icon: Icons.refresh_rounded,
                onPressed: () {
                  // Reset and replay shake animation on retry
                  _controller.reset();
                  _controller.forward();
                  widget.onRetry?.call();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompact() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.errorLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            widget.icon ?? Icons.error_outline_rounded,
            size: 20,
            color: AppColors.error.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.message,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Quicksand',
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (widget.onRetry != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Quicksand',
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
