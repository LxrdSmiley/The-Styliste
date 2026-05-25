// Directive F — Sun-Dial Hype Meter (CustomPainter)
// Kode Addendum: Reject fl_chart. Circular dial with solar sweep.
// GDD §3.0 Artisan View — "Circular dial that fills with pure white light tipping into Champagne Gold"

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sun-Dial Hype Meter — Circular dial with solar sweep animation
///
/// Features:
/// - Circular dial (no pulse, slow solar sweep)
/// - Fills with white → champagne-gold as hype rises
/// - Haptic feedback at milestone thresholds
/// - No axes, no tooltips — pure elegance
class SunDialHypeMeter extends StatefulWidget {
  const SunDialHypeMeter({
    required this.hypeScore,
    required this.maxHype,
    super.key,
    this.size = 200.0,
    this.onThresholdCrossed,
  });

  final double hypeScore;
  final double maxHype;
  final double size;
  final VoidCallback? onThresholdCrossed;

  @override
  State<SunDialHypeMeter> createState() => _SunDialHypeMeterState();
}

class _SunDialHypeMeterState extends State<SunDialHypeMeter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweepController;
  late final Animation<double> _sweepAnimation;
  double _previousPercent = 0.0;

  @override
  void initState() {
    super.initState();

    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _sweepAnimation = CurvedAnimation(
      parent: _sweepController,
      curve: Curves.easeOutCubic,
    );

    _animateToValue();
  }

  @override
  void didUpdateWidget(SunDialHypeMeter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hypeScore != widget.hypeScore) {
      _animateToValue();
    }
  }

  void _animateToValue() {
    final double targetPercent =
        (widget.hypeScore / widget.maxHype).clamp(0.0, 1.0);

    // Check for threshold crossing (25%, 50%, 75%, 100%)
    final int previousThreshold = (_previousPercent * 4).floor();
    final int newThreshold = (targetPercent * 4).floor();

    if (newThreshold > previousThreshold && widget.onThresholdCrossed != null) {
      HapticFeedback.heavyImpact();
      widget.onThresholdCrossed!();
    }

    _previousPercent = targetPercent;

    _sweepController.animateTo(targetPercent);
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sweepAnimation,
      builder: (BuildContext context, Widget? child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _SunDialPainter(
            progress: _sweepAnimation.value,
            hypeScore: widget.hypeScore,
            maxHype: widget.maxHype,
          ),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${(widget.hypeScore / 1000).toStringAsFixed(1)}K',
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 28.0,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF2A2A2A),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'HYPE',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 10.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3.0,
                      color: const Color(0xFF666666).withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for the sun-dial
class _SunDialPainter extends CustomPainter {
  _SunDialPainter({
    required this.progress,
    required this.hypeScore,
    required this.maxHype,
  });

  final double progress;
  final double hypeScore;
  final double maxHype;

  @override
  void paint(Canvas canvas, Size size) {
    final double safeProgress = progress.isFinite
        ? progress.clamp(0.0, 1.0).toDouble()
        : 0.0;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = (size.width / 2) - 20.0;
    final Offset center = Offset(centerX, centerY);

    // Background track (subtle grey)
    final Paint trackPaint = Paint()
      ..color = const Color(0xFFE8E8E8)
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, trackPaint);

    // Determine color based on progress
    // 0-50%: White → Light champagne
    // 50-100%: Light champagne → Deep gold
    final Color fillColor = _interpolateColor(safeProgress);
    const double startAngle = -math.pi / 2; // 12 o'clock
    final double sweepAngle = safeProgress * 2 * math.pi;

    // Filled arc (the solar sweep)
    final Paint fillPaint = Paint()
      ..color = fillColor
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (sweepAngle > 0.0) {
      fillPaint.shader = ui.Gradient.sweep(
        center,
        <Color>[
          Colors.white,
          const Color(0xFFF7E7CE),
          fillColor,
        ],
        <double>[0.0, 0.5, 1.0],
        TileMode.clamp,
        startAngle,
        startAngle + sweepAngle,
      );
    }

    // Draw the sweep arc
    if (sweepAngle > 0.0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        fillPaint,
      );
    }

    // Glow effect at the leading edge
    if (safeProgress > 0) {
      final double endAngle = startAngle + sweepAngle;
      final Offset glowCenter = Offset(
        centerX + math.cos(endAngle) * radius,
        centerY + math.sin(endAngle) * radius,
      );

      final Paint glowPaint = Paint()
        ..color = fillColor.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

      canvas.drawCircle(glowCenter, 12.0, glowPaint);
    }

    // Tick marks (hour markers)
    final Paint tickPaint = Paint()
      ..color = const Color(0xFFD0D0D0)
      ..strokeWidth = 2.0;

    for (int i = 0; i < 12; i++) {
      final double angle = (i * 30) * (math.pi / 180) - (math.pi / 2);
      final Offset start = Offset(
        centerX + math.cos(angle) * (radius - 8),
        centerY + math.sin(angle) * (radius - 8),
      );
      final Offset end = Offset(
        centerX + math.cos(angle) * (radius - 4),
        centerY + math.sin(angle) * (radius - 4),
      );
      canvas.drawLine(start, end, tickPaint);
    }

    // Center glow
    final Paint centerGlowPaint = Paint()
      ..color = fillColor.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20.0);

    canvas.drawCircle(center, radius * 0.6, centerGlowPaint);
  }

  Color _interpolateColor(double t) {
    // t: 0.0 → 1.0
    if (t <= 0.5) {
      // White → Light champagne
      return Color.lerp(
        Colors.white,
        const Color(0xFFF7E7CE),
        t * 2,
      )!;
    } else {
      // Light champagne → Deep gold
      return Color.lerp(
        const Color(0xFFF7E7CE),
        const Color(0xFFE8D4B8),
        (t - 0.5) * 2,
      )!;
    }
  }

  @override
  bool shouldRepaint(covariant _SunDialPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Compact version for small spaces
class SunDialCompact extends StatelessWidget {
  const SunDialCompact({
    required this.hypeScore,
    required this.maxHype,
    super.key,
    this.size = 80.0,
  });

  final double hypeScore;
  final double maxHype;
  final double size;

  @override
  Widget build(BuildContext context) {
    final double progress = (hypeScore / maxHype).clamp(0.0, 1.0);

    return CustomPaint(
      size: Size(size, size),
      painter: _SunDialCompactPainter(progress: progress),
    );
  }
}

class _SunDialCompactPainter extends CustomPainter {
  _SunDialCompactPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width / 2) - 6.0;

    // Background
    final Paint bgPaint = Paint()
      ..color = const Color(0xFFE8E8E8)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    // Fill
    final Color fillColor = progress > 0.75
        ? const Color(0xFFF7E7CE)
        : progress > 0.5
            ? const Color(0xFFE8D4B8)
            : const Color(0xFFFFF8F0);

    final Paint fillPaint = Paint()
      ..color = fillColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress * 2 * math.pi,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
