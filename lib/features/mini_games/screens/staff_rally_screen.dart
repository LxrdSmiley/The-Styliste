// GDD §5.7 — Staff Rally mini-game (tap-rhythm morale builder, Luxe dialogue)
// Directive O: The Zero-Stub Mandate — Full implementation with economic wiring

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/aurelian_theme.dart';
import '../../../features/talent/providers/talent_notifier.dart';

/// Staff Rally — Expanding pulse rhythm mini-game
/// Tap expanding rings when at max size to restore morale
class StaffRallyScreen extends ConsumerStatefulWidget {
  const StaffRallyScreen({super.key});

  @override
  ConsumerState<StaffRallyScreen> createState() => _StaffRallyScreenState();
}

class _StaffRallyScreenState extends ConsumerState<StaffRallyScreen>
    with TickerProviderStateMixin {
  late AnimationController _gameTimer;
  double _morale = 40.0;
  bool _gameOver = false;
  bool _won = false;

  @override
  void initState() {
    super.initState();
    _gameTimer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..forward().then((_) => _endGame());
  }

  void _onStaffTap(bool hit) {
    if (_gameOver) return;
    setState(() {
      if (hit) {
        _morale += 15.0;
        HapticFeedback.lightImpact();
      } else {
        _morale -= 5.0;
        HapticFeedback.vibrate();
      }
      if (_morale >= 100.0) {
        _morale = 100.0;
        _won = true;
        _endGame();
      }
    });
  }

  void _endGame() {
    if (_gameOver) return;
    setState(() => _gameOver = true);
    _gameTimer.stop();

    if (_won) {
      HapticFeedback.heavyImpact();
    }

    // Wire to TalentProvider for economic impact
    ref.read(talentProvider.notifier).applyStaffRallyResult(won: _won);

    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.pop();
      }
    });
  }

  @override
  void dispose() {
    _gameTimer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AurelianPalette.textPrimary,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 40),
            const Text(
              'RESTORE MORALE',
              style: TextStyle(
                color: AurelianPalette.ivory,
                fontSize: 20,
                letterSpacing: 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: LinearProgressIndicator(
                value: _morale / 100,
                backgroundColor: Colors.grey[900],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AurelianPalette.champagneGold,
                ),
              ),
            ),
            Expanded(
              child: _gameOver
                  ? Center(
                      child: Text(
                        _won ? 'TEAM RALLIED' : 'WALK-OFF IMMINENT',
                        style: TextStyle(
                          color: _won
                              ? AurelianPalette.champagneGold
                              : AurelianPalette.danger,
                          fontSize: 24,
                        ),
                      ),
                    )
                  : Stack(
                      children: <Widget>[
                        Positioned(
                          top: 100,
                          left: 60,
                          child: _PulseIcon(
                            onTap: _onStaffTap,
                            delay: 0,
                          ),
                        ),
                        Positioned(
                          top: 250,
                          right: 80,
                          child: _PulseIcon(
                            onTap: _onStaffTap,
                            delay: 500,
                          ),
                        ),
                        Positioned(
                          top: 400,
                          left: 120,
                          child: _PulseIcon(
                            onTap: _onStaffTap,
                            delay: 1000,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseIcon extends StatefulWidget {
  final void Function(bool) onTap;
  final int delay;

  const _PulseIcon({required this.onTap, required this.delay});

  @override
  State<_PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<_PulseIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    Future<void>.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _anim.repeat();
      }
    });
  }

  void _handleTap() {
    // Hit window is when ring is near max expansion (0.8 to 1.0)
    final bool isHit = _anim.value > 0.8;
    widget.onTap(isHit);
    _anim.forward(from: 0.0); // reset ring
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (BuildContext context, Widget? child) {
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: 80 * _anim.value,
                height: 80 * _anim.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AurelianPalette.champagneGold.withValues(
                      alpha: 1 - _anim.value,
                    ),
                    width: 2,
                  ),
                ),
              ),
              const CircleAvatar(
                backgroundColor: AurelianPalette.champagneGold,
                child: Icon(Icons.person, color: Colors.black),
              ),
            ],
          );
        },
      ),
    );
  }
}
