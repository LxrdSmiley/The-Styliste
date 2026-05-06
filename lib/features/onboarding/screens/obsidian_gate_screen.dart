// GDD §1.1 Screen 1 — Obsidian Gate
// Full-bleed #0A0A0A background, GLSL gold particle scan beam (vantablack.frag),
// haptic heartbeat, flutter_animate title reveal. Auto-advances to Origin Script.
// PROJECT_RULES §1 — 60fps via Impeller FragmentShader; no CPU physics.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../painters/obsidian_gate_painter.dart';

// ---------------------------------------------------------------------------
// Phase state machine
// ---------------------------------------------------------------------------
enum _GatePhase { loading, scanning, scanned, transitioning }

class ObsidianGateScreen extends ConsumerStatefulWidget {
  const ObsidianGateScreen({super.key});

  @override
  ConsumerState<ObsidianGateScreen> createState() => _ObsidianGateScreenState();
}

class _ObsidianGateScreenState extends ConsumerState<ObsidianGateScreen>
    with TickerProviderStateMixin {
  // Scan beam sweeps from top (0.0) to bottom (1.0) over 2800ms.
  static const Duration _scanDuration = Duration(milliseconds: 2800);
  // Delay before auto-advancing after title reveal.
  static const Duration _advanceDelay = Duration(milliseconds: 600);
  // Haptic beats at 0ms, 700ms, 1400ms, 2100ms during scan phase.
  static const List<int> _hapticBeatsMs = <int>[0, 700, 1400, 2100];

  _GatePhase _phase = _GatePhase.loading;
  ui.FragmentProgram? _program;
  ui.Image? _blackTexture;
  late final AnimationController _scanController;
  final List<Timer> _timers = <Timer>[];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: _scanDuration,
    );
    _loadShader();
  }

  Future<void> _loadShader() async {
    final ({ui.FragmentProgram program, ui.Image blackTexture}) result =
        await loadObsidianShader();

    if (!mounted) return;

    setState(() {
      _program = result.program;
      _blackTexture = result.blackTexture;
      _phase = _GatePhase.scanning;
    });

    // Shader is bound and ready — start animation and haptics together.
    unawaited(_scanController.forward());
    _fireHapticHeartbeat();

    // Transition to scanned phase when beam completes.
    _addTimer(Timer(_scanDuration, () {
      if (!mounted) return;
      setState(() => _phase = _GatePhase.scanned);
      _scheduleAdvance();
    }),);
  }

  void _fireHapticHeartbeat() {
    for (final int ms in _hapticBeatsMs) {
      _addTimer(Timer(Duration(milliseconds: ms), () {
        if (!mounted) return;
        HapticFeedback.heavyImpact();
      }),);
    }
  }

  void _scheduleAdvance() {
    _addTimer(Timer(_advanceDelay, () {
      if (!mounted) return;
      setState(() => _phase = _GatePhase.transitioning);
      context.go(AppRouter.onboardingOriginScript);
    }),);
  }

  void _addTimer(Timer timer) => _timers.add(timer);

  @override
  void dispose() {
    _scanController.dispose();
    for (final Timer t in _timers) {
      t.cancel();
    }
    _blackTexture?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Stack(
        children: <Widget>[
          // --- GLSL scan beam (hidden while shader is loading) ---
          if (_phase != _GatePhase.loading &&
              _program != null &&
              _blackTexture != null)
            AnimatedBuilder(
              animation: _scanController,
              builder: (BuildContext ctx, Widget? _) {
                return CustomPaint(
                  size: size,
                  painter: ObsidianGatePainter(
                    shader: _program!.fragmentShader(),
                    blackTexture: _blackTexture!,
                    time: _scanController.value * _scanDuration.inSeconds,
                    scanPosition: _scanController.value,
                  ),
                );
              },
            ),

          // --- Title: visible only in scanned / transitioning phases ---
          if (_phase == _GatePhase.scanned ||
              _phase == _GatePhase.transitioning)
            Center(
              child: const Text(
                'THE STYLISTE',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 32.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 8.0,
                  fontFamily: 'Roboto',
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
        ],
      ),
    );
  }
}
