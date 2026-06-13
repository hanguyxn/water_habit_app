import 'dart:math' as math;

import 'package:flutter/material.dart';

class WaterProgressRing extends StatefulWidget {
  const WaterProgressRing({
    super.key,
    required this.consumedMl,
    required this.goalMl,
    this.size = 260,
    this.strokeWidth = 14,
  });

  final int consumedMl;
  final int goalMl;
  final double size;
  final double strokeWidth;

  @override
  State<WaterProgressRing> createState() => _WaterProgressRingState();
}

class _WaterProgressRingState extends State<WaterProgressRing>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _waveController;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _animateProgress();
  }

  @override
  void didUpdateWidget(WaterProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.consumedMl != widget.consumedMl ||
        oldWidget.goalMl != widget.goalMl) {
      _animateProgress();
    }
  }

  void _animateProgress() {
    final newProgress = widget.goalMl > 0
        ? (widget.consumedMl / widget.goalMl).clamp(0.0, 1.0)
        : 0.0;

    _progressAnimation = Tween<double>(
      begin: _previousProgress,
      end: newProgress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _previousProgress = newProgress;
    _progressController.forward(from: 0);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) {
      return Color.lerp(
        const Color(0xFF90CAF9),
        const Color(0xFF42A5F5),
        progress / 0.3,
      )!;
    } else if (progress < 0.7) {
      return Color.lerp(
        const Color(0xFF42A5F5),
        const Color(0xFF52B788),
        (progress - 0.3) / 0.4,
      )!;
    } else {
      return Color.lerp(
        const Color(0xFF52B788),
        const Color(0xFF2D6A4F),
        (progress - 0.7) / 0.3,
      )!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_progressController, _waveController]),
      builder: (context, _) {
        final progress = _progressAnimation.value;
        final progressColor = _getProgressColor(progress);

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingBackgroundPainter(
                  strokeWidth: widget.strokeWidth,
                  color: progressColor.withOpacity(0.12),
                ),
              ),
              // Water wave fill
              ClipOval(
                child: SizedBox(
                  width: widget.size - widget.strokeWidth * 2 - 12,
                  height: widget.size - widget.strokeWidth * 2 - 12,
                  child: CustomPaint(
                    size: Size(
                      widget.size - widget.strokeWidth * 2 - 12,
                      widget.size - widget.strokeWidth * 2 - 12,
                    ),
                    painter: _WavePainter(
                      progress: progress,
                      wavePhase: _waveController.value,
                      color: progressColor,
                    ),
                  ),
                ),
              ),
              // Progress ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _ProgressRingPainter(
                  progress: progress,
                  strokeWidth: widget.strokeWidth,
                  color: progressColor,
                ),
              ),
              // Center text
              _buildCenterText(progress, progressColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCenterText(double progress, Color color) {
    final percentage = (progress * 100).round();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${widget.consumedMl}',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w800,
            fontFamily: 'Nunito',
            color: color,
            height: 1.1,
          ),
        ),
        Container(
          width: 60,
          height: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        Text(
          '${widget.goalMl} ml',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Quicksand',
            color: color.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFamily: 'Quicksand',
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _RingBackgroundPainter extends CustomPainter {
  const _RingBackgroundPainter({
    required this.strokeWidth,
    required this.color,
  });

  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      (size.width - strokeWidth) / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingBackgroundPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  final double progress;
  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + 2 * math.pi * progress,
      colors: [
        color.withOpacity(0.6),
        color,
      ],
      transform: const GradientRotation(-math.pi / 2),
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      paint,
    );

    // Draw end dot
    if (progress > 0.02) {
      final angle = -math.pi / 2 + 2 * math.pi * progress.clamp(0.0, 1.0);
      final dotCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(dotCenter, strokeWidth / 3, dotPaint);

      final dotOuterPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(dotCenter, strokeWidth / 4, dotOuterPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _WavePainter extends CustomPainter {
  const _WavePainter({
    required this.progress,
    required this.wavePhase,
    required this.color,
  });

  final double progress;
  final double wavePhase;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final waterHeight = size.height * (1 - progress);

    // Wave 1 (main)
    _drawWave(
      canvas,
      size,
      waterHeight: waterHeight,
      amplitude: 8.0,
      frequency: 2.0,
      phaseOffset: wavePhase * 2 * math.pi,
      color: color.withOpacity(0.4),
    );

    // Wave 2 (overlay)
    _drawWave(
      canvas,
      size,
      waterHeight: waterHeight + 4,
      amplitude: 5.0,
      frequency: 3.0,
      phaseOffset: wavePhase * 2 * math.pi + math.pi,
      color: color.withOpacity(0.25),
    );

    // Wave 3 (subtle)
    _drawWave(
      canvas,
      size,
      waterHeight: waterHeight + 8,
      amplitude: 3.0,
      frequency: 4.0,
      phaseOffset: wavePhase * 2 * math.pi + math.pi / 3,
      color: color.withOpacity(0.15),
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size, {
    required double waterHeight,
    required double amplitude,
    required double frequency,
    required double phaseOffset,
    required Color color,
  }) {
    final path = Path();
    path.moveTo(0, waterHeight);

    for (double x = 0; x <= size.width; x++) {
      final y = waterHeight +
          amplitude *
              math.sin((x / size.width) * frequency * 2 * math.pi + phaseOffset);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => true;
}
