import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Mầm character - a cute virtual plant that grows with hydration progress.
/// States: 0-25% seed, 25-50% sprout, 50-75% small plant, 75-100% bloom, 100%+ celebration
class MamCharacter extends StatefulWidget {
  const MamCharacter({
    super.key,
    required this.progress,
    this.size = 120,
    this.onWaterAdded = false,
  });

  /// Progress from 0.0 to 1.0+
  final double progress;

  /// Widget size
  final double size;

  /// Triggers happy animation when water is added
  final bool onWaterAdded;

  @override
  State<MamCharacter> createState() => _MamCharacterState();
}

class _MamCharacterState extends State<MamCharacter>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _happyController;
  late AnimationController _celebrateController;
  late Animation<double> _swayAnimation;
  late Animation<double> _happyBounce;
  late Animation<double> _celebrateScale;

  bool _wasCelebrating = false;

  @override
  void initState() {
    super.initState();

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _swayAnimation = Tween<double>(begin: -0.04, end: 0.04).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    _happyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _happyBounce = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -12.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -12.0, end: 0.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 70,
      ),
    ]).animate(_happyController);

    _celebrateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _celebrateScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 0.95)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.95, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
    ]).animate(_celebrateController);
  }

  @override
  void didUpdateWidget(MamCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.onWaterAdded && !oldWidget.onWaterAdded) {
      _happyController.forward(from: 0);
    }

    final nowCelebrating = widget.progress >= 1.0;
    if (nowCelebrating && !_wasCelebrating) {
      _celebrateController.forward(from: 0);
    }
    _wasCelebrating = nowCelebrating;
  }

  @override
  void dispose() {
    _idleController.dispose();
    _happyController.dispose();
    _celebrateController.dispose();
    super.dispose();
  }

  int get _stage {
    if (widget.progress >= 1.0) return 4; // celebration / blooming
    if (widget.progress >= 0.75) return 3; // blooming flower
    if (widget.progress >= 0.50) return 2; // small plant
    if (widget.progress >= 0.25) return 1; // sprout
    return 0; // seed
  }

  String get _statusText {
    switch (_stage) {
      case 0:
        return 'Mầm đang ngủ... 💤';
      case 1:
        return 'Mầm nảy mầm! 🌱';
      case 2:
        return 'Mầm đang lớn! 🌿';
      case 3:
        return 'Sắp nở hoa rồi! 🌸';
      case 4:
        return 'Tuyệt vời! 🎉🌺';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _idleController,
        _happyController,
        _celebrateController,
      ]),
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: Offset(0, _happyBounce.value),
              child: Transform.scale(
                scale: _celebrateScale.value,
                child: Transform.rotate(
                  angle: _swayAnimation.value,
                  child: SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: CustomPaint(
                      painter: _MamPainter(
                        stage: _stage,
                        progress: widget.progress,
                        swayValue: _swayAnimation.value,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _statusText,
                key: ValueKey(_stage),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Quicksand',
                  color: Color(0xFF2D6A4F),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MamPainter extends CustomPainter {
  const _MamPainter({
    required this.stage,
    required this.progress,
    required this.swayValue,
  });

  final int stage;
  final double progress;
  final double swayValue;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height;

    // Draw ground/soil
    _drawSoil(canvas, size, cx, cy);

    switch (stage) {
      case 0:
        _drawSeed(canvas, cx, cy);
        break;
      case 1:
        _drawSprout(canvas, cx, cy);
        break;
      case 2:
        _drawSmallPlant(canvas, cx, cy);
        break;
      case 3:
        _drawBloomingFlower(canvas, size, cx, cy);
        break;
      case 4:
        _drawCelebration(canvas, size, cx, cy);
        break;
    }
  }

  void _drawSoil(Canvas canvas, Size size, double cx, double cy) {
    final soilPaint = Paint()
      ..color = const Color(0xFF8B6914).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final soilPath = Path();
    soilPath.moveTo(cx - 40, cy);
    soilPath.quadraticBezierTo(cx, cy - 12, cx + 40, cy);
    soilPath.close();

    canvas.drawPath(soilPath, soilPaint);

    // Little grass blades
    final grassPaint = Paint()
      ..color = const Color(0xFF52B788).withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(cx - 25, cy - 2),
      Offset(cx - 30, cy - 10),
      grassPaint,
    );
    canvas.drawLine(
      Offset(cx + 25, cy - 2),
      Offset(cx + 28, cy - 8),
      grassPaint,
    );
  }

  void _drawSeed(Canvas canvas, double cx, double cy) {
    // Seed body
    final seedPaint = Paint()
      ..color = const Color(0xFFD4A76A)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy - 10),
        width: 18,
        height: 14,
      ),
      seedPaint,
    );

    // Seed highlight
    final highlightPaint = Paint()
      ..color = const Color(0xFFE8C88A)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 3, cy - 12),
        width: 6,
        height: 4,
      ),
      highlightPaint,
    );

    // Tiny eyes (sleeping)
    final eyePaint = Paint()
      ..color = const Color(0xFF5D4E37)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(cx - 4, cy - 10),
      Offset(cx - 2, cy - 10),
      eyePaint,
    );
    canvas.drawLine(
      Offset(cx + 2, cy - 10),
      Offset(cx + 4, cy - 10),
      eyePaint,
    );

    // Z z z
    final zzPaint = Paint()
      ..color = const Color(0xFF2D6A4F).withOpacity(0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    _drawZ(canvas, Offset(cx + 14, cy - 20), 5, zzPaint);
    _drawZ(canvas, Offset(cx + 20, cy - 28), 4, zzPaint);
  }

  void _drawZ(Canvas canvas, Offset pos, double size, Paint paint) {
    final path = Path()
      ..moveTo(pos.dx, pos.dy)
      ..lineTo(pos.dx + size, pos.dy)
      ..lineTo(pos.dx, pos.dy + size)
      ..lineTo(pos.dx + size, pos.dy + size);
    canvas.drawPath(path, paint);
  }

  void _drawSprout(Canvas canvas, double cx, double cy) {
    // Stem
    final stemPaint = Paint()
      ..color = const Color(0xFF52B788)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final stemPath = Path();
    stemPath.moveTo(cx, cy - 5);
    stemPath.quadraticBezierTo(cx + 2, cy - 25, cx, cy - 40);
    canvas.drawPath(stemPath, stemPaint);

    // Left leaf
    final leafPaint = Paint()
      ..color = const Color(0xFF52B788)
      ..style = PaintingStyle.fill;

    final leftLeaf = Path();
    leftLeaf.moveTo(cx, cy - 35);
    leftLeaf.quadraticBezierTo(cx - 18, cy - 50, cx - 5, cy - 55);
    leftLeaf.quadraticBezierTo(cx - 2, cy - 42, cx, cy - 35);
    canvas.drawPath(leftLeaf, leafPaint);

    // Right leaf
    final rightLeaf = Path();
    rightLeaf.moveTo(cx, cy - 35);
    rightLeaf.quadraticBezierTo(cx + 18, cy - 50, cx + 5, cy - 55);
    rightLeaf.quadraticBezierTo(cx + 2, cy - 42, cx, cy - 35);
    canvas.drawPath(rightLeaf, leafPaint);

    // Face
    _drawCuteFace(canvas, cx, cy - 20, isHappy: false);
  }

  void _drawSmallPlant(Canvas canvas, double cx, double cy) {
    // Main stem
    final stemPaint = Paint()
      ..color = const Color(0xFF2D6A4F)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final stemPath = Path();
    stemPath.moveTo(cx, cy - 5);
    stemPath.cubicTo(cx - 3, cy - 25, cx + 3, cy - 45, cx, cy - 65);
    canvas.drawPath(stemPath, stemPaint);

    // Leaves
    final leafPaint = Paint()
      ..color = const Color(0xFF52B788)
      ..style = PaintingStyle.fill;

    // Lower left leaf
    _drawLeaf(canvas, Offset(cx - 2, cy - 30), -0.5, 20, 12, leafPaint);
    // Lower right leaf
    _drawLeaf(canvas, Offset(cx + 2, cy - 25), 0.5, 18, 10, leafPaint);
    // Upper left leaf
    final upperLeafPaint = Paint()
      ..color = const Color(0xFF74D4A0)
      ..style = PaintingStyle.fill;
    _drawLeaf(
        canvas, Offset(cx - 1, cy - 50), -0.4, 15, 9, upperLeafPaint);
    // Upper right leaf
    _drawLeaf(
        canvas, Offset(cx + 1, cy - 45), 0.6, 14, 8, upperLeafPaint);

    // Face on stem
    _drawCuteFace(canvas, cx, cy - 25, isHappy: true);
  }

  void _drawLeaf(Canvas canvas, Offset base, double angle, double length,
      double width, Paint paint) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(angle);

    final leafPath = Path();
    leafPath.moveTo(0, 0);
    leafPath.quadraticBezierTo(-width, -length / 2, 0, -length);
    leafPath.quadraticBezierTo(width, -length / 2, 0, 0);

    canvas.drawPath(leafPath, paint);

    // Leaf vein
    final veinPaint = Paint()
      ..color = const Color(0xFF2D6A4F).withOpacity(0.3)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(0, -length * 0.8), veinPaint);

    canvas.restore();
  }

  void _drawBloomingFlower(
      Canvas canvas, Size size, double cx, double cy) {
    // Stem
    final stemPaint = Paint()
      ..color = const Color(0xFF2D6A4F)
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final stemPath = Path();
    stemPath.moveTo(cx, cy - 5);
    stemPath.cubicTo(cx - 4, cy - 30, cx + 4, cy - 55, cx, cy - 80);
    canvas.drawPath(stemPath, stemPaint);

    // Leaves along stem
    final leafPaint = Paint()
      ..color = const Color(0xFF52B788)
      ..style = PaintingStyle.fill;
    _drawLeaf(canvas, Offset(cx - 2, cy - 25), -0.6, 22, 13, leafPaint);
    _drawLeaf(canvas, Offset(cx + 2, cy - 40), 0.5, 20, 12, leafPaint);
    _drawLeaf(canvas, Offset(cx - 1, cy - 55), -0.4, 16, 10, leafPaint);

    // Flower bud at top
    _drawFlower(canvas, Offset(cx, cy - 80), 12, isFull: false);

    // Face
    _drawCuteFace(canvas, cx, cy - 30, isHappy: true, size: 1.2);
  }

  void _drawCelebration(
      Canvas canvas, Size size, double cx, double cy) {
    // Main stem (thicker, stronger)
    final stemPaint = Paint()
      ..color = const Color(0xFF2D6A4F)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final stemPath = Path();
    stemPath.moveTo(cx, cy - 5);
    stemPath.cubicTo(cx - 5, cy - 30, cx + 5, cy - 55, cx, cy - 85);
    canvas.drawPath(stemPath, stemPaint);

    // Beautiful leaves
    final leafPaint = Paint()
      ..color = const Color(0xFF52B788)
      ..style = PaintingStyle.fill;
    _drawLeaf(canvas, Offset(cx - 2, cy - 20), -0.7, 25, 15, leafPaint);
    _drawLeaf(canvas, Offset(cx + 2, cy - 35), 0.6, 23, 14, leafPaint);
    _drawLeaf(canvas, Offset(cx - 1, cy - 50), -0.5, 20, 12, leafPaint);
    _drawLeaf(canvas, Offset(cx + 1, cy - 65), 0.4, 18, 11, leafPaint);

    // Full bloom flower at top
    _drawFlower(canvas, Offset(cx, cy - 85), 16, isFull: true);

    // Sparkles
    _drawSparkle(canvas, Offset(cx - 30, cy - 70), 4);
    _drawSparkle(canvas, Offset(cx + 28, cy - 60), 3);
    _drawSparkle(canvas, Offset(cx - 20, cy - 90), 3.5);
    _drawSparkle(canvas, Offset(cx + 22, cy - 85), 3);

    // Face - very happy!
    _drawCuteFace(canvas, cx, cy - 30, isHappy: true, size: 1.3);
  }

  void _drawFlower(Canvas canvas, Offset center, double petalSize,
      {required bool isFull}) {
    final petalCount = isFull ? 8 : 5;
    final petalPaint = Paint()
      ..color = isFull ? const Color(0xFFFF8FAB) : const Color(0xFFFFB3C6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < petalCount; i++) {
      final angle = (i / petalCount) * 2 * math.pi - math.pi / 2;
      final petalCenter = Offset(
        center.dx + math.cos(angle) * petalSize * 0.6,
        center.dy + math.sin(angle) * petalSize * 0.6,
      );

      canvas.drawOval(
        Rect.fromCenter(
          center: petalCenter,
          width: petalSize,
          height: petalSize * 0.65,
        ),
        petalPaint,
      );
    }

    // Flower center
    final centerPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, petalSize * 0.35, centerPaint);

    // Center highlight
    final highlightPaint = Paint()
      ..color = const Color(0xFFFFE44D)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx - 1, center.dy - 1),
      petalSize * 0.15,
      highlightPaint,
    );
  }

  void _drawSparkle(Canvas canvas, Offset center, double size) {
    final sparklePaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // +  shape
    canvas.drawLine(
      Offset(center.dx - size, center.dy),
      Offset(center.dx + size, center.dy),
      sparklePaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size),
      Offset(center.dx, center.dy + size),
      sparklePaint,
    );
    // X shape (smaller)
    final smallSize = size * 0.6;
    canvas.drawLine(
      Offset(center.dx - smallSize, center.dy - smallSize),
      Offset(center.dx + smallSize, center.dy + smallSize),
      sparklePaint,
    );
    canvas.drawLine(
      Offset(center.dx + smallSize, center.dy - smallSize),
      Offset(center.dx - smallSize, center.dy + smallSize),
      sparklePaint,
    );
  }

  void _drawCuteFace(Canvas canvas, double cx, double cy,
      {required bool isHappy, double size = 1.0}) {
    final eyePaint = Paint()
      ..color = const Color(0xFF2D3436)
      ..style = PaintingStyle.fill;

    // Eyes
    if (isHappy) {
      // Happy arc eyes
      final arcPaint = Paint()
        ..color = const Color(0xFF2D3436)
        ..strokeWidth = 2 * size
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx - 5 * size, cy),
          width: 6 * size,
          height: 5 * size,
        ),
        math.pi,
        math.pi,
        false,
        arcPaint,
      );
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx + 5 * size, cy),
          width: 6 * size,
          height: 5 * size,
        ),
        math.pi,
        math.pi,
        false,
        arcPaint,
      );
    } else {
      // Dot eyes
      canvas.drawCircle(Offset(cx - 5 * size, cy), 2 * size, eyePaint);
      canvas.drawCircle(Offset(cx + 5 * size, cy), 2 * size, eyePaint);
    }

    // Blush
    final blushPaint = Paint()
      ..color = const Color(0xFFFFB3C6).withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 9 * size, cy + 4 * size),
        width: 6 * size,
        height: 3 * size,
      ),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 9 * size, cy + 4 * size),
        width: 6 * size,
        height: 3 * size,
      ),
      blushPaint,
    );

    // Mouth
    if (isHappy) {
      final mouthPaint = Paint()
        ..color = const Color(0xFF2D3436)
        ..strokeWidth = 1.5 * size
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx, cy + 5 * size),
          width: 8 * size,
          height: 6 * size,
        ),
        0,
        math.pi,
        false,
        mouthPaint,
      );
    } else {
      // Neutral small mouth
      final mouthPaint = Paint()
        ..color = const Color(0xFF2D3436)
        ..strokeWidth = 1.5 * size
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cx - 3 * size, cy + 5 * size),
        Offset(cx + 3 * size, cy + 5 * size),
        mouthPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MamPainter oldDelegate) =>
      oldDelegate.stage != stage ||
      oldDelegate.progress != progress ||
      oldDelegate.swayValue != swayValue;
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
