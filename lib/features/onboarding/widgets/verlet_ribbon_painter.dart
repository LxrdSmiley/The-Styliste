// GDD v6 §1.1 Screen 1 — Matte Silk Ribbon (Verlet Physics)
// Aurelian Sanctuary: Drifting ribbon driven by Verlet integration
// PROJECT_RULES §4 — Physics at 60fps, decoupled from render thread

import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/aurelian_theme.dart';

// -----------------------------------------------------------------------------
// Verlet Physics Primitives
// -----------------------------------------------------------------------------

/// A point in Verlet space with position and previous position
class VerletPoint {
  VerletPoint(this.x, this.y, {this.pinned = false})
      : oldX = x,
        oldY = y;

  double x;
  double y;
  double oldX;
  double oldY;
  final bool pinned;

  void update() {
    if (pinned) return;
    final double velX = x - oldX;
    final double velY = y - oldY;
    oldX = x;
    oldY = y;
    x += velX;
    y += velY;
  }

  void applyForce(double fx, double fy) {
    if (pinned) return;
    x += fx;
    y += fy;
  }

  void constrain(double minX, double minY, double maxX, double maxY) {
    if (x < minX) x = minX;
    if (x > maxX) x = maxX;
    if (y < minY) y = minY;
    if (y > maxY) y = maxY;
  }
}

/// A stick constraint connecting two VerletPoints
class VerletStick {
  VerletPoint p1;
  VerletPoint p2;
  double length;

  VerletStick(this.p1, this.p2) : length = _distance(p1, p2);

  static double _distance(VerletPoint a, VerletPoint b) {
    final double dx = a.x - b.x;
    final double dy = a.y - b.y;
    return sqrt(dx * dx + dy * dy);
  }

  void update() {
    final double dx = p2.x - p1.x;
    final double dy = p2.y - p1.y;
    final double dist = sqrt(dx * dx + dy * dy);
    if (dist == 0) return;

    final double diff = length - dist;
    final double percent = diff / dist / 2.0;
    final double offsetX = dx * percent;
    final double offsetY = dy * percent;

    if (!p1.pinned) {
      p1.x -= offsetX;
      p1.y -= offsetY;
    }
    if (!p2.pinned) {
      p2.x += offsetX;
      p2.y += offsetY;
    }
  }
}

// -----------------------------------------------------------------------------
// Verlet Ribbon Physics Engine
// -----------------------------------------------------------------------------

class VerletRibbon {
  final int pointCount;
  final List<VerletPoint> points = <VerletPoint>[];
  final List<VerletStick> sticks = <VerletStick>[];

  // Physics constants
  static const double gravity = 0.15;
  static const double windBase = 0.08;
  static const double windVariation = 0.04;
  static const int constraintIterations = 3;

  double _windPhase = 0.0;
  double _time = 0.0;

  VerletRibbon({this.pointCount = 18});

  void initialize(double startX, double startY, double spacing) {
    points.clear();
    sticks.clear();

    for (int i = 0; i < pointCount; i++) {
      final bool pinned = i == 0;
      final double y = startY + (i * spacing * 0.3);
      final double x = startX + (i * spacing * 0.1);
      points.add(VerletPoint(x, y, pinned: pinned));
    }

    for (int i = 0; i < pointCount - 1; i++) {
      sticks.add(VerletStick(points[i], points[i + 1]));
    }
  }

  void update(double dt, Size bounds) {
    _time += dt;
    _windPhase += dt * 1.5;

    // Apply forces to all points
    for (int i = 0; i < points.length; i++) {
      final VerletPoint p = points[i];

      // Gravity (gentle, like silk)
      p.applyForce(0.0, gravity);

      // Wind — varies by height and time for organic movement
      final double windNoise = sin(_windPhase + i * 0.3) * 0.5 + 0.5;
      final double windForce = windBase + windVariation * windNoise;
      // Horizontal drift with slight vertical undulation
      p.applyForce(windForce, sin(_time + i * 0.2) * 0.02);

      // Update position based on velocity
      p.update();

      // Constrain to screen bounds with padding
      p.constrain(
        -50.0,
        -50.0,
        bounds.width + 50.0,
        bounds.height + 100.0,
      );
    }

    // Solve constraints multiple times for stability
    for (int iteration = 0; iteration < constraintIterations; iteration++) {
      for (final VerletStick stick in sticks) {
        stick.update();
      }
    }
  }
}

// -----------------------------------------------------------------------------
// Matte Silk Ribbon Painter
// -----------------------------------------------------------------------------

/// CustomPainter that renders a Verlet physics ribbon with smooth bezier curves
class VerletRibbonPainter extends CustomPainter {
  VerletRibbonPainter({
    required this.ribbon,
    required this.animation,
  }) : super(repaint: animation);

  final VerletRibbon ribbon;
  final Animation<double> animation;

  static const double _strokeWidth = 4.0;
  static const double _shadowBlur = 8.0;
  static const double _shadowOffset = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (ribbon.points.isEmpty) return;

    // Build smooth path through ribbon points using cubic bezier
    final Path path = Path();
    final List<VerletPoint> pts = ribbon.points;

    if (pts.length < 2) return;

    path.moveTo(pts[0].x, pts[0].y);

    for (int i = 0; i < pts.length - 1; i++) {
      final VerletPoint p0 = i > 0 ? pts[i - 1] : pts[i];
      final VerletPoint p1 = pts[i];
      final VerletPoint p2 = pts[i + 1];
      final VerletPoint p3 = i + 2 < pts.length ? pts[i + 2] : p2;

      // Catmull-Rom to cubic bezier conversion for smooth curves
      final double cp1x = p1.x + (p2.x - p0.x) / 6.0;
      final double cp1y = p1.y + (p2.y - p0.y) / 6.0;
      final double cp2x = p2.x - (p3.x - p1.x) / 6.0;
      final double cp2y = p2.y - (p3.y - p1.y) / 6.0;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.x, p2.y);
    }

    // Draw subtle shadow for depth
    final Paint shadowPaint = Paint()
      ..color = AurelianPalette.softRose.withValues(alpha: 0.2)
      ..strokeWidth = _strokeWidth + 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _shadowBlur);

    canvas
      ..save()
      ..translate(_shadowOffset, _shadowOffset)
      ..drawPath(path, shadowPaint)
      ..restore();

    // Draw main ribbon stroke
    final Paint ribbonPaint = Paint()
      ..color = AurelianPalette.softRose
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, ribbonPaint);

    // Add subtle highlight along center
    final Paint highlightPaint = Paint()
      ..color = AurelianPalette.ivory.withValues(alpha: 0.4)
      ..strokeWidth = _strokeWidth * 0.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant VerletRibbonPainter oldDelegate) => true;
}

// -----------------------------------------------------------------------------
// Animated Verlet Ribbon Widget
// -----------------------------------------------------------------------------

/// Stateful widget that runs Verlet physics ticker and renders the ribbon
class AnimatedVerletRibbon extends StatefulWidget {
  const AnimatedVerletRibbon({
    super.key,
    this.pointCount = 18,
    this.startX = 50.0,
    this.startY = 100.0,
    this.pointSpacing = 25.0,
  });

  final int pointCount;
  final double startX;
  final double startY;
  final double pointSpacing;

  @override
  State<AnimatedVerletRibbon> createState() => _AnimatedVerletRibbonState();
}

class _AnimatedVerletRibbonState extends State<AnimatedVerletRibbon>
    with SingleTickerProviderStateMixin {
  late final VerletRibbon _ribbon;
  late final AnimationController _controller;
  Duration? _lastTime;

  @override
  void initState() {
    super.initState();
    _ribbon = VerletRibbon(pointCount: widget.pointCount);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.repeat();
    _controller.addListener(_onTick);
  }

  void _onTick() {
    final Duration now = Duration(
      milliseconds: DateTime.now().millisecondsSinceEpoch,
    );
    if (_lastTime != null) {
      final double dt = (now - _lastTime!).inMilliseconds / 1000.0;
      final Size size = MediaQuery.sizeOf(context);
      _ribbon.update(dt.clamp(0.0, 0.05), size);
    } else {
      // First frame — initialize ribbon
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ribbon.initialize(
          widget.startX,
          widget.startY,
          widget.pointSpacing,
        );
      });
    }
    _lastTime = now;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: VerletRibbonPainter(
        ribbon: _ribbon,
        animation: _controller,
      ),
    );
  }
}
