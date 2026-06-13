import 'package:flutter/material.dart';

// ─── Animation Direction ─────────────────────────────────────────────────────

enum SlideDirection {
  fromBottom,
  fromLeft,
  fromRight,
  fromTop,
}

// ─── AnimatedListItem ────────────────────────────────────────────────────────

class AnimatedListItem extends StatefulWidget {
  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.direction = SlideDirection.fromBottom,
    this.duration = const Duration(milliseconds: 400),
    this.delayPerItem = const Duration(milliseconds: 60),
    this.maxDelay = const Duration(milliseconds: 600),
    this.slideOffset = 30.0,
    this.curve = Curves.easeOutCubic,
  });

  final int index;
  final Widget child;
  final SlideDirection direction;
  final Duration duration;
  final Duration delayPerItem;
  final Duration maxDelay;
  final double slideOffset;
  final Curve curve;

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _slideAnim = Tween<Offset>(
      begin: _startOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    // Calculate staggered delay based on index, capped at maxDelay
    final delay = Duration(
      milliseconds: (widget.delayPerItem.inMilliseconds * widget.index)
          .clamp(0, widget.maxDelay.inMilliseconds),
    );

    Future.delayed(delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  Offset get _startOffset {
    switch (widget.direction) {
      case SlideDirection.fromBottom:
        return Offset(0, widget.slideOffset);
      case SlideDirection.fromTop:
        return Offset(0, -widget.slideOffset);
      case SlideDirection.fromLeft:
        return Offset(-widget.slideOffset, 0);
      case SlideDirection.fromRight:
        return Offset(widget.slideOffset, 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: Transform.translate(
            offset: _slideAnim.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
