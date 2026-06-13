import 'package:flutter/material.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';
import 'package:water_habit_app/core/widgets/app_button.dart';

// ─── EmptyStateWidget ────────────────────────────────────────────────────────

class EmptyStateWidget extends StatefulWidget {
  const EmptyStateWidget({
    super.key,
    this.icon,
    this.emoji,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData? icon;
  final String? emoji;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _floatAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 32,
              vertical: widget.compact ? 16 : 48,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon / Emoji
                _buildIcon(),

                SizedBox(height: widget.compact ? 12 : 20),

                // Title
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: widget.compact ? 16 : 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Nunito',
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (widget.subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      fontSize: widget.compact ? 13 : 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Quicksand',
                      color: AppColors.textTertiary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                if (widget.actionLabel != null && widget.onAction != null) ...[
                  SizedBox(height: widget.compact ? 16 : 24),
                  FadeTransition(
                    opacity: _floatAnim,
                    child: AppButton.primary(
                      label: widget.actionLabel!,
                      onPressed: widget.onAction,
                      size: widget.compact
                          ? AppButtonSize.small
                          : AppButtonSize.medium,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final iconSize = widget.compact ? 56.0 : 80.0;

    if (widget.emoji != null) {
      return _FloatingEmoji(
        emoji: widget.emoji!,
        size: iconSize,
      );
    }

    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primarySurface,
            AppColors.accentSurface,
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        widget.icon ?? Icons.inbox_rounded,
        size: iconSize * 0.45,
        color: AppColors.primary,
      ),
    );
  }
}

// ─── Floating Emoji Animation ────────────────────────────────────────────────

class _FloatingEmoji extends StatefulWidget {
  const _FloatingEmoji({
    required this.emoji,
    required this.size,
  });

  final String emoji;
  final double size;

  @override
  State<_FloatingEmoji> createState() => _FloatingEmojiState();
}

class _FloatingEmojiState extends State<_FloatingEmoji>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnim.value),
          child: child,
        );
      },
      child: Text(
        widget.emoji,
        style: TextStyle(fontSize: widget.size * 0.55),
      ),
    );
  }
}
