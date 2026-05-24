// GDD v6 §1.1 Screen 1 — Aurelian Gate
// Biometric fingerprint scan with haptic heartbeat and liquid gold ripple
// Replaces ObsidianGateScreen — Alabaster Standard onboarding entry point
// PROJECT_RULES §1 — 60fps via Impeller FragmentShader; no CPU physics

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/aurelian_theme.dart';
import '../painters/aurelian_gate_painter.dart';
import '../widgets/verlet_ribbon_painter.dart';

// -----------------------------------------------------------------------------
// Phase State Machine
// -----------------------------------------------------------------------------
enum _GatePhase { idle, pressing, charging, complete }

// -----------------------------------------------------------------------------
// Aurelian Gate Screen
// -----------------------------------------------------------------------------

class AurelianGateScreen extends ConsumerStatefulWidget {
  const AurelianGateScreen({super.key});

  @override
  ConsumerState<AurelianGateScreen> createState() => _AurelianGateScreenState();
}

class _AurelianGateScreenState extends ConsumerState<AurelianGateScreen>
    with TickerProviderStateMixin {
  // Biometric scan timing
  static const Duration _chargeDuration = Duration(milliseconds: 3000);
  static const Duration _hapticInterval = Duration(milliseconds: 1000);

  _GatePhase _phase = _GatePhase.idle;
  ui.FragmentProgram? _shaderProgram;
  late final AnimationController _chargeController;
  late final AnimationController _fadeController;
  late final VerletRibbon _ribbon;
  Timer? _hapticTimer;

  // Touch tracking for shader
  Offset _touchPosition = const Offset(0.5, 0.5);

  @override
  void initState() {
    super.initState();
    _chargeController = AnimationController(
      vsync: this,
      duration: _chargeDuration,
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _ribbon = VerletRibbon();
<<<<<<< HEAD
    unawaited(_loadShader());

    // GDD §10.1 — Age-gate mechanism at onboarding
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_checkAgeGate(context));
=======
    _loadShader();

    // GDD §10.1 — Age-gate mechanism at onboarding
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_checkAgeGate());
>>>>>>> b82f5aa0df7cf605d44fb4b2ee0b34ca518f7b9e
    });
  }

  Future<void> _checkAgeGate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('age_gate_passed') ?? false) return;

    if (!context.mounted) return;

    final bool? passed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => const _AgeGateDialog(),
    );

    if (passed ?? false) {
      await prefs.setBool('age_gate_passed', true);
    } else {
      // App exit for under-13
      unawaited(SystemNavigator.pop());
    }
  }

  Future<void> _loadShader() async {
    final ui.FragmentProgram program = await loadLiquidGoldShader();
    if (!mounted) return;

    setState(() {
      _shaderProgram = program;
    });

    // Initialize ribbon after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Size size = MediaQuery.sizeOf(context);
      _ribbon.initialize(
        size.width * 0.1,
        size.height * 0.2,
        25.0,
      );
    });
  }

  // -----------------------------------------------------------------------------
  // Haptic Heartbeat
  // -----------------------------------------------------------------------------

  void _startHapticHeartbeat() {
    // Initial beat immediately
    HapticFeedback.heavyImpact();

    // Repeating heartbeat every 1000ms
    _hapticTimer = Timer.periodic(_hapticInterval, (Timer timer) {
      if (!mounted || _phase == _GatePhase.idle) {
        timer.cancel();
        return;
      }
      HapticFeedback.heavyImpact();
    });
  }

  void _stopHapticHeartbeat() {
    _hapticTimer?.cancel();
    _hapticTimer = null;
  }

  // -----------------------------------------------------------------------------
  // Biometric Interaction
  // -----------------------------------------------------------------------------

  void _onPressStart(LongPressStartDetails details) {
    if (_phase != _GatePhase.idle || _shaderProgram == null) return;

    final Size size = MediaQuery.sizeOf(context);
    setState(() {
      _phase = _GatePhase.pressing;
      _touchPosition = Offset(
        details.globalPosition.dx / size.width,
        details.globalPosition.dy / size.height,
      );
    });

    _startHapticHeartbeat();
    unawaited(_chargeController.forward(from: 0.0));

    // Monitor charge progress
    _chargeController.addStatusListener(_onChargeStatusChanged);
  }

  void _onPressEnd(LongPressEndDetails details) {
    if (_phase != _GatePhase.charging && _phase != _GatePhase.pressing) return;

    _stopHapticHeartbeat();
    _chargeController.removeStatusListener(_onChargeStatusChanged);

    if (_phase != _GatePhase.complete) {
      // Charge interrupted — animate back to idle
<<<<<<< HEAD
      unawaited(
        _chargeController.animateBack(
          0.0,
          duration: const Duration(milliseconds: 300),
        ),
=======
      _chargeController.animateBack(
        0.0,
        duration: const Duration(milliseconds: 300),
>>>>>>> b82f5aa0df7cf605d44fb4b2ee0b34ca518f7b9e
      );
      setState(() => _phase = _GatePhase.idle);
    }
  }

  void _onChargeStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() => _phase = _GatePhase.complete);
      _stopHapticHeartbeat();
      _performTransition();
    } else if (status == AnimationStatus.forward &&
        _phase == _GatePhase.pressing) {
      setState(() => _phase = _GatePhase.charging);
    }
  }

  void _performTransition() {
    // Fade to white
    unawaited(_fadeController.forward().then((_) {
      if (mounted) {
        context.go(AppRouter.onboardingOriginScript);
      }
    }));
  }

  // -----------------------------------------------------------------------------
  // Ribbon Physics Tick
  // -----------------------------------------------------------------------------

  void _onRibbonTick(Duration elapsed) {
    if (!mounted || _ribbon.points.isEmpty) return;

    final Size size = MediaQuery.sizeOf(context);
    const double dt = 1.0 / 60.0; // Fixed timestep for stable physics
    _ribbon.update(dt, size);
  }

  @override
  void dispose() {
    _stopHapticHeartbeat();
    _chargeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AurelianPalette.ivory,
      body: TickerMode(
        enabled: true,
        child: Stack(
          children: <Widget>[
            // --- Layer 1: Verlet Ribbon (drifts behind everything) ---
            if (_shaderProgram != null)
              TickerBuilder(
                onTick: _onRibbonTick,
                child: CustomPaint(
                  size: size,
                  painter: VerletRibbonPainter(
                    ribbon: _ribbon,
                    animation: _chargeController,
                  ),
                ),
              ),

            // --- Layer 2: Liquid Gold Shader Background ---
            if (_shaderProgram != null)
              AnimatedBuilder(
                animation: _chargeController,
                builder: (BuildContext ctx, Widget? _) {
                  return CustomPaint(
                    size: size,
                    painter: AurelianGatePainter(
                      shader: _shaderProgram!.fragmentShader(),
                      time: DateTime.now().millisecondsSinceEpoch / 1000.0,
                      touchPosition: _touchPosition,
                      charge: _chargeController.value,
                    ),
                  );
                },
              ),

            // --- Layer 3: Fingerprint Interaction Zone ---
            GestureDetector(
              onLongPressStart: _onPressStart,
              onLongPressEnd: _onPressEnd,
              child: Container(
                width: size.width,
                height: size.height,
                color: Colors.transparent,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _chargeController,
                    builder: (BuildContext ctx, Widget? _) {
                      final double scale = 1.0 + _chargeController.value * 0.2;
                      final double opacity = _phase == _GatePhase.idle
                          ? 0.6
                          : 0.3 + _chargeController.value * 0.7;

                      return Transform.scale(
                        scale: scale,
                        child: Icon(
                          Icons.fingerprint,
                          size: 80.0,
                          color: AurelianPalette.champagneGold
                              .withValues(alpha: opacity),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // --- Layer 4: Title (appears at full charge) ---
            if (_phase == _GatePhase.complete)
              Center(
                child: const Text(
                  'THE STYLISTE',
                  style: TextStyle(
                    color: AurelianPalette.champagneGold,
                    fontSize: 32.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 8.0,
                    fontFamily: 'SpaceGrotesk',
                  ),
                )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 400))
                    .slideY(
                      begin: 0.1,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                    ),
              ),

            // --- Layer 5: White Fade Overlay (for transition) ---
            IgnorePointer(
              ignoring: _fadeController.value == 0.0,
              child: AnimatedBuilder(
                animation: _fadeController,
                builder: (BuildContext ctx, Widget? _) {
                  return Opacity(
                    opacity: _fadeController.value,
                    child: Container(
                      width: size.width,
                      height: size.height,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TickerBuilder Helper Widget
// -----------------------------------------------------------------------------

class TickerBuilder extends StatefulWidget {
  const TickerBuilder({
    required this.onTick,
    required this.child,
    super.key,
  });

  final void Function(Duration elapsed) onTick;
  final Widget child;

  @override
  State<TickerBuilder> createState() => _TickerBuilderState();
}

class _TickerBuilderState extends State<TickerBuilder>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(widget.onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _AgeGateDialog extends StatelessWidget {
  const _AgeGateDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AurelianPalette.ivory,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AurelianPalette.champagneGold),
      ),
      title: const Text(
        'AGE VERIFICATION',
        style: TextStyle(
          color: AurelianPalette.textPrimary,
          fontFamily: 'SpaceGrotesk',
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
        ),
      ),
      content: const Text(
        'The Styliste is designed for players aged 13 and older.\n\n'
        'Are you 13 years of age or older?',
        style: TextStyle(
          color: AurelianPalette.textPrimary,
          fontFamily: 'SpaceGrotesk',
          height: 1.5,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'NO — EXIT',
            style: TextStyle(
              color: AurelianPalette.textTertiary,
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'YES — CONTINUE',
            style: TextStyle(
              color: AurelianPalette.champagneGold,
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
