// GDD v6 §1.1 Screen 1 — Aurelian Gate Painter
// Binds liquid_gold.frag FragmentShader for biometric touch ripple
// PROJECT_RULES §1 — GPU path via Impeller; never run physics on Dart thread
//
// liquid_gold.frag uniform declaration order (determines setFloat slot index):
//   uniform float uTime;          → setFloat(0, ...)
//   uniform vec2 uResolution;     → setFloat(1, width) setFloat(2, height)
//   uniform vec2 uTouch;          → setFloat(3, x) setFloat(4, y)
//   uniform float uCharge;        → setFloat(5, ...)

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// CustomPainter that binds the Liquid Gold FragmentShader
class AurelianGatePainter extends CustomPainter {
  const AurelianGatePainter({
    required this.shader,
    required this.time,
    required this.touchPosition,
    required this.charge,
  });

  final ui.FragmentShader shader;

  /// Elapsed seconds — drives uTime uniform
  final double time;

  /// Normalized touch position (0.0-1.0) — drives uTouch uniform
  final Offset touchPosition;

  /// Charge progress 0.0 (start) to 1.0 (full) — drives uCharge uniform
  final double charge;

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, time)
      ..setFloat(1, size.width)
      ..setFloat(2, size.height)
      ..setFloat(3, touchPosition.dx.clamp(0.0, 1.0))
      ..setFloat(4, touchPosition.dy.clamp(0.0, 1.0))
      ..setFloat(5, charge.clamp(0.0, 1.0));

    canvas.drawRect(
      Rect.fromLTWH(0.0, 0.0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant AurelianGatePainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.touchPosition != touchPosition ||
        oldDelegate.charge != charge;
  }
}

/// Async factory: loads FragmentProgram from asset
/// Call once from initState; do not re-call on every frame
Future<ui.FragmentProgram> loadLiquidGoldShader() async {
  return ui.FragmentProgram.fromAsset(
    'lib/shaders/liquid_gold.frag',
  );
}
