import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';

// ─── AppCard ─────────────────────────────────────────────────────────────────

class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.gradient,
    this.elevation = 1,
    this.borderRadius,
    this.border,
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  final double elevation;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;
  final Color? color;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<BoxShadow> get _shadow {
    if (widget.elevation <= 0) return [];
    if (widget.elevation <= 1) return AppColors.natureShadowLight;
    if (widget.elevation <= 2) return AppColors.natureShadowMedium;
    return AppColors.natureShadowHeavy;
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(16);

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
        onTapUp: widget.onTap != null
            ? (_) {
                _controller.reverse();
                widget.onTap?.call();
              }
            : null,
        onTapCancel:
            widget.onTap != null ? () => _controller.reverse() : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: widget.margin,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            color: widget.gradient == null
                ? (widget.color ?? AppColors.cardLight)
                : null,
            borderRadius: borderRadius,
            border: widget.border,
            boxShadow: _shadow,
          ),
          child: ClipRRect(
            borderRadius: borderRadius as BorderRadius,
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(16),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── GlassCard ───────────────────────────────────────────────────────────────

class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 12,
    this.opacity = 0.15,
    this.tintColor,
    this.border,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final double blur;
  final double opacity;
  final Color? tintColor;
  final BoxBorder? border;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(16);
    final tint = widget.tintColor ?? Colors.white;

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
        onTapUp: widget.onTap != null
            ? (_) {
                _controller.reverse();
                widget.onTap?.call();
              }
            : null,
        onTapCancel:
            widget.onTap != null ? () => _controller.reverse() : null,
        child: Container(
          margin: widget.margin,
          child: ClipRRect(
            borderRadius: borderRadius as BorderRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.blur,
                sigmaY: widget.blur,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: widget.opacity),
                  borderRadius: borderRadius,
                  border: widget.border ??
                      Border.all(
                        color: tint.withValues(alpha: 0.2),
                        width: 1,
                      ),
                ),
                padding: widget.padding ?? const EdgeInsets.all(16),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
