// GDD §1.1 Screen 1 — ObsidianGatePainter
// Binds vantablack.frag FragmentShader to drive the gold particle scan beam.
// PROJECT_RULES §1 — GPU path via Impeller; never run physics on Dart thread.
//
// vantablack.frag uniform declaration order (determines setFloat slot index):
//   uniform sampler2D uTexture;   → setImageSampler(0, ...)
//   uniform float uTime;          → setFloat(0, ...)
//   uniform vec2 uResolution;     → setFloat(1, width) setFloat(2, height)
//   uniform float uAbsorption;    → setFloat(3, ...)
//   uniform vec3 uAccentColor;    → setFloat(4, r) setFloat(5, g) setFloat(6, b)
//   uniform float uScanPosition;  → setFloat(7, ...)

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ObsidianGatePainter extends CustomPainter {
  const ObsidianGatePainter({
    required this.shader,
    required this.blackTexture,
    required this.time,
    required this.scanPosition,
  });

  final ui.FragmentShader shader;

  /// 1×1 opaque black image bound to uTexture sampler slot 0.
  final ui.Image blackTexture;

  /// Elapsed seconds since scan started — drives uTime uniform.
  final double time;

  /// Vertical scan beam position 0.0 (top) → 1.0 (bottom).
  final double scanPosition;

  // Gold accent color from GDD/AppColors: #C9A84C → (0.788, 0.659, 0.298)
  static const double _goldR = 0.788;
  static const double _goldG = 0.659;
  static const double _goldB = 0.298;
  static const double _absorption = 0.92;

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setImageSampler(0, blackTexture)
      ..setFloat(0, time)
      ..setFloat(1, size.width)
      ..setFloat(2, size.height)
      ..setFloat(3, _absorption)
      ..setFloat(4, _goldR)
      ..setFloat(5, _goldG)
      ..setFloat(6, _goldB)
      ..setFloat(7, scanPosition);

    canvas.drawRect(
      Rect.fromLTWH(0.0, 0.0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(ObsidianGatePainter oldDelegate) {
    return oldDelegate.scanPosition != scanPosition ||
        oldDelegate.time != time;
  }
}

/// Async factory: loads FragmentProgram and creates a 1×1 black Image.
/// Call once from initState; do not re-call on every frame.
Future<({ui.FragmentProgram program, ui.Image blackTexture})>
    loadObsidianShader() async {
  final ui.FragmentProgram program = await ui.FragmentProgram.fromAsset(
    'lib/shaders/vantablack.frag',
  );

  // Create 1×1 opaque black image for uTexture sampler.
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  canvas.drawRect(
    const Rect.fromLTWH(0.0, 0.0, 1.0, 1.0),
    Paint()..color = const Color(0xFF0A0A0A),
  );
  final ui.Picture picture = recorder.endRecording();
  final ui.Image blackTexture = await picture.toImage(1, 1);

  return (program: program, blackTexture: blackTexture);
}
