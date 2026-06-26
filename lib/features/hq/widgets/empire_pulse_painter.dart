// Directive F — Empire Pulse Graph (CustomPainter)
// Kode Addendum: Reject fl_chart. Pure data. Pure elegance.
// GDD §3.0 Architect View — "Animated 7-day revenue curve as champagne-gold arc"

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Empire Pulse Graph — CustomPainter cubic bezier curve
///
/// Features:
/// - Single glowing anti-aliased champagne-gold (#F7E7CE) curve
/// - 7-day revenue data visualization
/// - Breathing animation (live, responsive)
/// - Minimalist: no axes, no tooltips, no padding baggage
class EmpirePulseGraph extends StatefulWidget {
  const EmpirePulseGraph({
    required this.dataPoints, // 7 values for 7 days
    super.key,
    this.height = 120.0,
    this.animate = true,
  });

  final List<double> dataPoints;
  final double height;
  final bool animate;

  @override
  State<EmpirePulseGraph> createState() => _EmpirePulseGraphState();
}

class _EmpirePulseGraphState extends State<EmpirePulseGraph>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    if (widget.animate) {
      _breathingController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (BuildContext context, Widget? child) {
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: _EmpirePulsePainter(
            dataPoints: widget.dataPoints,
            breathingValue: _breathingController.value,
          ),
        );
      },
    );
  }
}

/// Custom painter for the empire pulse curve
class _EmpirePulsePainter extends CustomPainter {
  _EmpirePulsePainter({
    required this.dataPoints,
    required this.breathingValue,
  });

  final List<double> dataPoints;
  final double breathingValue;

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    // Normalize data to canvas height (with padding)
    final double maxValue = dataPoints.reduce(math.max);
    final double minValue = dataPoints.reduce(math.min);
    final double range = maxValue - minValue;

    // Champagne-gold color with breathing opacity
    final double baseOpacity = 0.7 + (breathingValue * 0.3); // 0.7 → 1.0
    final Color champagneGold = Color.fromRGBO(
      247, // 0xF7
      231, // 0xE7
      206, // 0xCE
      baseOpacity,
    );

    // Glow paint for outer shadow
    final Paint glowPaint = Paint()
      ..color = champagneGold.withValues(alpha: 0.3)
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    // Main curve paint
    final Paint curvePaint = Paint()
      ..color = champagneGold
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..shader = ui.Gradient.linear(
        Offset(0.0, size.height),
        const Offset(0.0, 0.0),
        <Color>[
          const Color(0xFFE8D4B8), // Darker gold at bottom
          champagneGold,
          const Color(0xFFFFF8F0), // Bright at top
        ],
        <double>[0.0, 0.55, 1.0],
      );

    // Generate smooth curve through data points
    final List<Offset> points =
        _generatePoints(size, maxValue, minValue, range);
    final Path curvePath = _generateSmoothPath(points);

    // Draw glow beneath
    canvas.drawPath(curvePath, glowPaint);

    // Draw main curve
    canvas.drawPath(curvePath, curvePaint);

    // Draw subtle fill beneath curve (gradient)
    final Path fillPath = Path.from(curvePath)
      ..lineTo(size.width, size.height)
      ..lineTo(0.0, size.height)
      ..close();

    final Paint fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0.0, 0.0),
        Offset(0.0, size.height),
        <Color>[
          champagneGold.withValues(alpha: 0.2),
          champagneGold.withValues(alpha: 0.0),
        ],
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
  }

  List<Offset> _generatePoints(
    Size size,
    double max,
    double min,
    double range,
  ) {
    final List<Offset> points = <Offset>[];
    final double effectiveRange = range > 0 ? range : 1.0;

    // Padding from edges
    final double paddingX = size.width * 0.05;
    final double paddingY = size.height * 0.15;
    final double graphWidth = size.width - (paddingX * 2);
    final double graphHeight = size.height - (paddingY * 2);

    for (int i = 0; i < dataPoints.length; i++) {
      final double x = paddingX + (i / (dataPoints.length - 1)) * graphWidth;
      final double normalizedY = (dataPoints[i] - min) / effectiveRange;
      final double y = size.height - paddingY - (normalizedY * graphHeight);
      points.add(Offset(x, y));
    }

    return points;
  }

  Path _generateSmoothPath(List<Offset> points) {
    if (points.length < 2) return Path();

    final Path path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    // Cubic bezier curve through all points
    for (int i = 0; i < points.length - 1; i++) {
      final Offset current = points[i];
      final Offset next = points[i + 1];

      // Control points for smooth curve
      final double controlX1 = current.dx + (next.dx - current.dx) * 0.5;
      final double controlY1 = current.dy;
      final double controlX2 = next.dx - (next.dx - current.dx) * 0.5;
      final double controlY2 = next.dy;

      path.cubicTo(
        controlX1,
        controlY1,
        controlX2,
        controlY2,
        next.dx,
        next.dy,
      );
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant _EmpirePulsePainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.breathingValue != breathingValue;
  }
}

/// Simplified static version for non-animated use
class EmpirePulseStatic extends StatelessWidget {
  const EmpirePulseStatic({
    required this.dataPoints,
    super.key,
    this.height = 80.0,
  });

  final List<double> dataPoints;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _EmpirePulseStaticPainter(dataPoints: dataPoints),
    );
  }
}

class _EmpirePulseStaticPainter extends CustomPainter {
  _EmpirePulseStaticPainter({required this.dataPoints});

  final List<double> dataPoints;

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final double maxValue = dataPoints.reduce(math.max);
    final double minValue = dataPoints.reduce(math.min);
    final double range = maxValue - minValue;

    const Color champagneGold = Color(0xFFF7E7CE);

    final Paint curvePaint = Paint()
      ..color = champagneGold
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final List<Offset> points =
        _generatePoints(size, maxValue, minValue, range);
    final Path curvePath = _generateSmoothPath(points);

    canvas.drawPath(curvePath, curvePaint);
  }

  List<Offset> _generatePoints(
    Size size,
    double max,
    double min,
    double range,
  ) {
    final List<Offset> points = <Offset>[];
    final double effectiveRange = range > 0 ? range : 1.0;
    final double paddingX = size.width * 0.05;
    final double paddingY = size.height * 0.15;
    final double graphWidth = size.width - (paddingX * 2);
    final double graphHeight = size.height - (paddingY * 2);

    for (int i = 0; i < dataPoints.length; i++) {
      final double x = paddingX + (i / (dataPoints.length - 1)) * graphWidth;
      final double normalizedY = (dataPoints[i] - min) / effectiveRange;
      final double y = size.height - paddingY - (normalizedY * graphHeight);
      points.add(Offset(x, y));
    }

    return points;
  }

  Path _generateSmoothPath(List<Offset> points) {
    if (points.length < 2) return Path();

    final Path path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final Offset current = points[i];
      final Offset next = points[i + 1];
      final double controlX1 = current.dx + (next.dx - current.dx) * 0.5;
      final double controlY1 = current.dy;
      final double controlX2 = next.dx - (next.dx - current.dx) * 0.5;
      final double controlY2 = next.dy;

      path.cubicTo(
        controlX1,
        controlY1,
        controlX2,
        controlY2,
        next.dx,
        next.dy,
      );
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
