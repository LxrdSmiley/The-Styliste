// GDD §4.2 — GarmentCanvas: GPU cloth physics via cloth_physics.frag
// PROJECT_RULES §1 — All Verlet physics on GPU; Dart only feeds uniforms.
//
// Touch interpolation strategy (Phase 4 directive):
//   Pointer events (~60Hz) update _targetTouch only.
//   AnimationController Ticker fires every vsync frame (90–120Hz) and lerps
//   _smoothTouch toward _targetTouch with factor 0.18 — eliminates snapping.
//   The CustomPainter always receives the smooth value, never the raw event.
//
// Shader slot map mirrors cloth_physics.frag uniform declaration order exactly.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class GarmentCanvas extends StatefulWidget {
  const GarmentCanvas({
    required this.dyeColor,
    this.onInteractionActive,
    super.key,
  });

  /// Currently selected fabric dye — passed directly to uDyeColor uniform.
  final Color dyeColor;

  /// Called with true while a touch is active, false when lifted.
  /// Used by AtelierScreen to gate the _interactionSeconds counter.
  final ValueChanged<bool>? onInteractionActive;

  @override
  State<GarmentCanvas> createState() => _GarmentCanvasState();
}

class _GarmentCanvasState extends State<GarmentCanvas>
    with SingleTickerProviderStateMixin {
  // --- Shader state ---
  ui.FragmentShader? _shader;
  ui.Image? _fabricTexture;
  bool _shaderReady = false;

  // --- Time ---
  final Stopwatch _stopwatch = Stopwatch()..start();

  // --- Touch interpolation ---
  static const Offset _kOffScreen = Offset(-1.0, -1.0);
  Offset _targetTouch = _kOffScreen;
  Offset _smoothTouch = _kOffScreen;
  bool _touchActive = false;

  // --- Ticker ---
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _loadShader();
  }

  Future<void> _loadShader() async {
    final ui.FragmentProgram program = await ui.FragmentProgram.fromAsset(
      'lib/shaders/cloth_physics.frag',
    );

    // 1×1 ivory placeholder texture — blended with uDyeColor via mix() in shader.
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas c = Canvas(recorder);
    c.drawRect(
      const Rect.fromLTWH(0.0, 0.0, 1.0, 1.0),
      Paint()..color = const Color(0xFFFAF7F0),
    );
    final ui.Picture picture = recorder.endRecording();
    final ui.Image texture = await picture.toImage(1, 1);

    if (!mounted) return;
    setState(() {
      _shader = program.fragmentShader();
      _fabricTexture = texture;
      _shaderReady = true;
    });
  }

  void _onTick(Duration elapsed) {
    // Lerp smooth touch toward target every vsync frame.
    // When touch is off-screen, glide there instead of hard-cutting.
    if (_smoothTouch != _targetTouch) {
      const double lerpFactor = 0.18;
      _smoothTouch = Offset.lerp(_smoothTouch, _targetTouch, lerpFactor)!;
      // Snap to sentinel once close enough to avoid infinite drift.
      if ((_smoothTouch - _targetTouch).distanceSquared < 0.000001) {
        _smoothTouch = _targetTouch;
      }
    }
    if (_shaderReady) setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details, Size canvasSize) {
    final Offset normalized = Offset(
      (details.localPosition.dx / canvasSize.width).clamp(0.0, 1.0),
      (details.localPosition.dy / canvasSize.height).clamp(0.0, 1.0),
    );
    _targetTouch = normalized;
    if (!_touchActive) {
      _touchActive = true;
      widget.onInteractionActive?.call(true);
    }
  }

  void _onPanEnd(DragEndDetails _) {
    _targetTouch = _kOffScreen;
    _touchActive = false;
    widget.onInteractionActive?.call(false);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _fabricTexture?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size canvasSize = Size(
          constraints.maxWidth,
          constraints.maxHeight,
        );
        return GestureDetector(
          onPanUpdate: (DragUpdateDetails d) => _onPanUpdate(d, canvasSize),
          onPanEnd: _onPanEnd,
          child: CustomPaint(
            size: canvasSize,
            painter: _shaderReady
                ? _GarmentPainter(
                    shader: _shader!,
                    fabricTexture: _fabricTexture!,
                    time: _stopwatch.elapsed.inMilliseconds / 1000.0,
                    smoothTouch: _smoothTouch,
                    dyeColor: widget.dyeColor,
                  )
                : null,
            child: _shaderReady
                ? null
                : const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFC9A84C),
                      strokeWidth: 1.5,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Painter — sets all 16 float slots in declaration order.
// ---------------------------------------------------------------------------
class _GarmentPainter extends CustomPainter {
  const _GarmentPainter({
    required this.shader,
    required this.fabricTexture,
    required this.time,
    required this.smoothTouch,
    required this.dyeColor,
  });

  final ui.FragmentShader shader;
  final ui.Image fabricTexture;
  final double time;
  final Offset smoothTouch;
  final Color dyeColor;

  // Fabric defaults — can be exposed as params in Phase 4b.
  static const double _density = 0.4;
  static const double _stiffness = 0.3;
  static const double _elasticity = 0.6;
  static const double _friction = 0.25;
  static const double _drapeCoeff = 0.7;
  static const double _bendResistance = 0.2;

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setImageSampler(0, fabricTexture)           // uFabricTexture
      ..setFloat(0, time)                           // uTime
      ..setFloat(1, _density)                       // uDensity
      ..setFloat(2, _stiffness)                     // uStiffness
      ..setFloat(3, _elasticity)                    // uElasticity
      ..setFloat(4, _friction)                      // uFriction
      ..setFloat(5, _drapeCoeff)                    // uDrapeCoeff
      ..setFloat(6, _bendResistance)                // uBendResistance
      ..setFloat(7, size.width)                     // uResolution.x
      ..setFloat(8, size.height)                    // uResolution.y
      ..setFloat(9, 0.0)                            // uGravity.x
      ..setFloat(10, -1.0)                          // uGravity.y (downward)
      ..setFloat(11, smoothTouch.dx)                // uTouchPos.x
      ..setFloat(12, smoothTouch.dy)                // uTouchPos.y
      ..setFloat(13, dyeColor.r)                   // uDyeColor.r
      ..setFloat(14, dyeColor.g)                   // uDyeColor.g
      ..setFloat(15, dyeColor.b);                  // uDyeColor.b

    canvas.drawRect(
      Rect.fromLTWH(0.0, 0.0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(_GarmentPainter old) => true; // Ticker drives every frame.
}
