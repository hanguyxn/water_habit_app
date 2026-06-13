import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:water_habit_app/core/theme/app_colors.dart';

// ─── LoadingWidget ───────────────────────────────────────────────────────────

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({
    super.key,
    this.message,
    this.size = 60,
  });

  final String? message;
  final double size;

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with TickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final AnimationController _rippleController;
  late final Animation<double> _bounceAnim;
  late final Animation<double> _rippleAnim;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnim = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _rippleAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.size * 1.6,
            height: widget.size * 1.6,
            child: AnimatedBuilder(
              animation: Listenable.merge([_bounceAnim, _rippleAnim]),
              builder: (context, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ripple rings
                    ..._buildRipples(),
                    // Water drop
                    Transform.translate(
                      offset: Offset(0, _bounceAnim.value),
                      child: _buildWaterDrop(),
                    ),
                  ],
                );
              },
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 20),
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 500),
              child: Text(
                widget.message!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Quicksand',
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildRipples() {
    return List.generate(3, (index) {
      final delay = index * 0.3;
      final progress = (_rippleAnim.value + delay) % 1.0;
      final size = widget.size * 0.5 + (widget.size * 0.8 * progress);
      final opacity = (1.0 - progress).clamp(0.0, 0.4);

      return Positioned(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.accent.withValues(alpha: opacity),
              width: 2,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildWaterDrop() {
    final dropSize = widget.size * 0.45;
    return Container(
      width: dropSize,
      height: dropSize,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF42A5F5), Color(0xFF90CAF9)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        Icons.water_drop_rounded,
        size: dropSize * 0.55,
        color: Colors.white,
      ),
    );
  }
}

// ─── ShimmerLoading ──────────────────────────────────────────────────────────

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.enabled = true,
  });

  /// Creates a shimmer card placeholder
  const factory ShimmerLoading.card({
    Key? key,
    double height,
    double? width,
    double borderRadius,
    EdgeInsetsGeometry? margin,
  }) = _ShimmerCard;

  /// Creates a shimmer text line placeholder
  const factory ShimmerLoading.text({
    Key? key,
    double width,
    double height,
    EdgeInsetsGeometry? margin,
  }) = _ShimmerText;

  /// Creates a shimmer circle placeholder (avatar)
  const factory ShimmerLoading.circle({
    Key? key,
    double size,
    EdgeInsetsGeometry? margin,
  }) = _ShimmerCircle;

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final bool enabled;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final base = widget.baseColor ?? AppColors.shimmerBase;
    final highlight = widget.highlightColor ?? AppColors.shimmerHighlight;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.centerRight,
              colors: [base, highlight, base],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
              tileMode: TileMode.clamp,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ─── Shimmer Primitives ──────────────────────────────────────────────────────

class _ShimmerCard extends ShimmerLoading {
  const _ShimmerCard({
    super.key,
    this.height = 120,
    this.width,
    this.borderRadius = 16,
    this.margin,
  }) : super(child: const SizedBox.shrink());

  final double height;
  final double? width;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  State<ShimmerLoading> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends _ShimmerLoadingState {
  @override
  Widget build(BuildContext context) {
    final w = widget as _ShimmerCard;
    return ShimmerLoading(
      child: Container(
        height: w.height,
        width: w.width ?? double.infinity,
        margin: w.margin,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(w.borderRadius),
        ),
      ),
    );
  }
}

class _ShimmerText extends ShimmerLoading {
  const _ShimmerText({
    super.key,
    this.width = 200,
    this.height = 14,
    this.margin,
  }) : super(child: const SizedBox.shrink());

  final double width;
  final double height;
  final EdgeInsetsGeometry? margin;

  @override
  State<ShimmerLoading> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends _ShimmerLoadingState {
  @override
  Widget build(BuildContext context) {
    final w = widget as _ShimmerText;
    return ShimmerLoading(
      child: Container(
        height: w.height,
        width: w.width,
        margin: w.margin,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(w.height / 2),
        ),
      ),
    );
  }
}

class _ShimmerCircle extends ShimmerLoading {
  const _ShimmerCircle({
    super.key,
    this.size = 48,
    this.margin,
  }) : super(child: const SizedBox.shrink());

  final double size;
  final EdgeInsetsGeometry? margin;

  @override
  State<ShimmerLoading> createState() => _ShimmerCircleState();
}

class _ShimmerCircleState extends _ShimmerLoadingState {
  @override
  Widget build(BuildContext context) {
    final w = widget as _ShimmerCircle;
    return ShimmerLoading(
      child: Container(
        width: w.size,
        height: w.size,
        margin: w.margin,
        decoration: const BoxDecoration(
          color: AppColors.shimmerBase,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
