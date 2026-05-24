// GDD v6 — Hold To Confirm Widget
// Reusable biometric confirmation pattern from Aurelian Gate
// Alabaster Standard: Haptic heartbeat + liquid gold ripple + 3s hold

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/aurelian_theme.dart';
import '../../onboarding/painters/aurelian_gate_painter.dart';

/// Callbacks for hold state changes
typedef OnHoldComplete = void Function();
typedef OnHoldCancel = void Function();
typedef OnHoldProgress = void Function(double progress);

/// HoldToConfirmWidget — Biometric-style confirmation button
///
/// Usage:
/// ```dart
/// HoldToConfirmWidget(
///   label: 'HOLD TO ASCEND',
///   onComplete: () => print('Confirmed!'),
///   onCancel: () => print('Cancelled'),
/// )
/// ```
class HoldToConfirmWidget extends StatefulWidget {
  const HoldToConfirmWidget({
    required this.label,
    super.key,
    this.subLabel,
    this.onComplete,
    this.onCancel,
    this.onProgress,
    this.duration = const Duration(milliseconds: 3000),
    this.hapticInterval = const Duration(milliseconds: 1000),
    this.backgroundColor,
    this.foregroundColor,
    this.icon = Icons.fingerprint,
  });

  final String label;
  final String? subLabel;
  final OnHoldComplete? onComplete;
  final OnHoldCancel? onCancel;
  final OnHoldProgress? onProgress;
  final Duration duration;
  final Duration hapticInterval;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData icon;

  @override
  State<HoldToConfirmWidget> createState() => _HoldToConfirmWidgetState();
}

class _HoldToConfirmWidgetState extends State<HoldToConfirmWidget>
    with TickerProviderStateMixin {
  Timer? _timer;
  DateTime? _startTime;
  double _progress = 0.0;
  bool _isHolding = false;
  ui.FragmentProgram? _shaderProgram;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _loadShader();
  }

  Future<void> _loadShader() async {
    _shaderProgram = await loadLiquidGoldShader();
    if (mounted) setState(() {});
  }

  void _onPressStart() {
    if (_isHolding) return;

    setState(() {
      _isHolding = true;
      _startTime = DateTime.now();
      _progress = 0.0;
    });

    _pulseController.repeat();
    HapticFeedback.heavyImpact();

    _timer = Timer.periodic(
      const Duration(milliseconds: 50),
      (Timer timer) {
        if (_startTime == null) return;

        final Duration elapsed = DateTime.now().difference(_startTime!);
        final double newProgress =
            elapsed.inMilliseconds / widget.duration.inMilliseconds;

        // Haptic heartbeat
        if (elapsed.inMilliseconds % widget.hapticInterval.inMilliseconds <
            50) {
          HapticFeedback.heavyImpact();
        }

        setState(() => _progress = newProgress.clamp(0.0, 1.0));
        widget.onProgress?.call(_progress);

        if (_progress >= 1.0) {
          _onComplete();
        }
      },
    );
  }

  void _onPressEnd() {
    if (!_isHolding) return;

    _timer?.cancel();
    _timer = null;
    _pulseController.stop();

    if (_progress < 1.0) {
      widget.onCancel?.call();
    }

    setState(() {
      _isHolding = false;
      _progress = 0.0;
      _startTime = null;
    });
  }

  void _onComplete() {
    _timer?.cancel();
    _timer = null;
    _pulseController.stop();

    widget.onComplete?.call();

    setState(() {
      _isHolding = false;
      _progress = 1.0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        widget.backgroundColor ?? AurelianPalette.champagneGold;
    final Color fgColor = widget.foregroundColor ?? AurelianPalette.textPrimary;
    final double opacity = 0.3 + (_progress * 0.7);

    return GestureDetector(
      onTapDown: (_) => _onPressStart(),
      onTapUp: (_) => _onPressEnd(),
      onTapCancel: () => _onPressEnd(),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (BuildContext context, Widget? child) {
          final double scale =
              _isHolding ? 1.0 + (_pulseController.value * 0.05) : 1.0;

          return Transform.scale(
            scale: scale,
            child: Container(
              height: 80.0,
              decoration: BoxDecoration(
                color: bgColor.withValues(alpha: _isHolding ? 0.9 : 1.0),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: bgColor.withValues(alpha: _isHolding ? 0.4 : 0.2),
                    blurRadius: _isHolding ? 24.0 : 12.0,
                    spreadRadius: _isHolding ? 4.0 : 2.0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Stack(
                  children: <Widget>[
                    // Liquid gold ripple shader
                    if (_isHolding && _shaderProgram != null)
                      CustomPaint(
                        size: Size.infinite,
                        painter: AurelianGatePainter(
                          shader: _shaderProgram!.fragmentShader(),
                          time: DateTime.now().millisecondsSinceEpoch / 1000.0,
                          touchPosition: const Offset(0.5, 0.5),
                          charge: _progress,
                        ),
                      ),

                    // Progress indicator
                    if (_isHolding)
                      Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            fgColor.withValues(alpha: 0.3),
                          ),
                          minHeight: 4.0,
                        ),
                      ),

                    // Content
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          AnimatedOpacity(
                            opacity: opacity,
                            duration: const Duration(milliseconds: 100),
                            child: Icon(
                              widget.icon,
                              size: 32.0,
                              color: fgColor,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                widget.label,
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.0,
                                  color: fgColor,
                                ),
                              ),
                              if (widget.subLabel != null) ...<Widget>[
                                const SizedBox(height: 4.0),
                                Text(
                                  widget.subLabel!,
                                  style: TextStyle(
                                    fontFamily: 'SpaceGrotesk',
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w400,
                                    color: fgColor.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Percentage indicator
                    if (_isHolding)
                      Positioned(
                        top: 12.0,
                        right: 16.0,
                        child: Text(
                          '${(_progress * 100).toInt()}%',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: fgColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
                .animate(target: _progress >= 1.0 ? 1.0 : 0.0)
                .shake(duration: const Duration(milliseconds: 500)),
          );
        },
      ),
    );
  }
}
