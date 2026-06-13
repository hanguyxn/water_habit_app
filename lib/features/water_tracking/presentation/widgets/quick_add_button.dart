import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuickAddButton extends StatefulWidget {
  const QuickAddButton({
    super.key,
    required this.amountMl,
    required this.onTap,
    this.size = 64,
  });

  final int amountMl;
  final VoidCallback onTap;
  final double size;

  @override
  State<QuickAddButton> createState() => _QuickAddButtonState();
}

class _QuickAddButtonState extends State<QuickAddButton>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _splashController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _splashAnimation;
  late Animation<double> _splashOpacity;

  final List<_SplashDrop> _splashDrops = [];

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.85)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.85, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_bounceController);

    _splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _splashAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _splashController, curve: Curves.easeOut),
    );
    _splashOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _generateSplashDrops();
  }

  void _generateSplashDrops() {
    final random = math.Random();
    _splashDrops.clear();
    for (int i = 0; i < 8; i++) {
      _splashDrops.add(_SplashDrop(
        angle: (i / 8) * 2 * math.pi + random.nextDouble() * 0.5,
        distance: 20.0 + random.nextDouble() * 25,
        size: 3.0 + random.nextDouble() * 4,
      ));
    }
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _generateSplashDrops();
    _bounceController.forward(from: 0);
    _splashController.forward(from: 0);
    widget.onTap();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _splashController.dispose();
    super.dispose();
  }

  Color get _dropColor {
    if (widget.amountMl <= 150) return const Color(0xFF90CAF9);
    if (widget.amountMl <= 250) return const Color(0xFF42A5F5);
    if (widget.amountMl <= 350) return const Color(0xFF52B788);
    return const Color(0xFF2D6A4F);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_bounceController, _splashController]),
        builder: (context, child) {
          return SizedBox(
            width: widget.size + 40,
            height: widget.size + 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Splash drops
                ..._splashDrops.map((drop) {
                  final dx = math.cos(drop.angle) *
                      drop.distance *
                      _splashAnimation.value;
                  final dy = math.sin(drop.angle) *
                      drop.distance *
                      _splashAnimation.value;
                  return Positioned(
                    left: (widget.size + 40) / 2 + dx - drop.size / 2,
                    top: (widget.size + 40) / 2 + dy - drop.size / 2,
                    child: Opacity(
                      opacity: _splashOpacity.value,
                      child: Container(
                        width: drop.size,
                        height: drop.size,
                        decoration: BoxDecoration(
                          color: _dropColor.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
                // Water drop button
                Transform.scale(
                  scale: _bounceAnimation.value,
                  child: child,
                ),
              ],
            ),
          );
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _dropColor.withOpacity(0.9),
                _dropColor,
              ],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(widget.size * 0.5),
              topRight: Radius.circular(widget.size * 0.5),
              bottomLeft: Radius.circular(widget.size * 0.5),
              bottomRight: Radius.circular(widget.size * 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: _dropColor.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shine effect
              Positioned(
                top: widget.size * 0.15,
                left: widget.size * 0.2,
                child: Container(
                  width: widget.size * 0.2,
                  height: widget.size * 0.12,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // Amount text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.amountMl}',
                    style: TextStyle(
                      fontSize: widget.size * 0.28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Nunito',
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'ml',
                    style: TextStyle(
                      fontSize: widget.size * 0.16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.85),
                      fontFamily: 'Quicksand',
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashDrop {
  const _SplashDrop({
    required this.angle,
    required this.distance,
    required this.size,
  });

  final double angle;
  final double distance;
  final double size;
}

class AnimatedBuilder extends AnimatedWidget {
  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) => builder(context, child);
}
