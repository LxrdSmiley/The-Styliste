// GDD §5.7 — Hostile Takeover mini-game (tug-of-war ownership, Rank 60+)
// Directive O: The Zero-Stub Mandate — Full implementation with economic wiring

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/mini_game_service.dart';
import '../../../core/theme/aurelian_theme.dart';
import '../../../features/ledger/providers/equity_provider.dart';
import '../widgets/mini_game_rewards_unavailable.dart';

/// Hostile Takeover — High-stakes corporate tug-of-war
/// 30-second timer, rival pushes back constantly, player taps to acquire shares
class HostileTakeoverScreen extends ConsumerStatefulWidget {
  const HostileTakeoverScreen({super.key});

  @override
  ConsumerState<HostileTakeoverScreen> createState() =>
      _HostileTakeoverScreenState();
}

class _HostileTakeoverScreenState extends ConsumerState<HostileTakeoverScreen>
    with TickerProviderStateMixin {
  late AnimationController _gameTimer;
  late AnimationController _rivalForce;

  double _ownershipPct = 50.0; // Starts at 50%
  int _round = 1;
  bool _gameOver = false;
  bool _won = false;
  String? _attemptId;
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    if (!MiniGameService.rewardsAreAvailable) return;
    _prepareAttempt();

    // 30 Second global timer
    _gameTimer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )
      ..forward()
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _endGame();
        }
      });

    // Rival pushes back constantly, accelerating based on round
    _rivalForce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )
      ..repeat()
      ..addListener(() {
        if (_gameOver) return;
        setState(() {
          // Rival pushes back 0.5% to 2.5% per tick based on round
          _ownershipPct -= (0.5 + (_round * 0.4));
          if (_ownershipPct <= 20.0) {
            _ownershipPct = 20.0;
            _endGame(); // Player loses if pushed to 20%
          }
        });
      });
  }

  Future<void> _prepareAttempt() async {
    try {
      final MiniGameAttempt attempt =
          await MiniGameService.start('hostile_takeover');
      if (mounted) setState(() => _attemptId = attempt.id);
    } catch (_) {
      if (mounted) _endGame();
    }
  }

  @override
  void dispose() {
    if (!MiniGameService.rewardsAreAvailable) {
      super.dispose();
      return;
    }
    _gameTimer.dispose();
    _rivalForce.dispose();
    super.dispose();
  }

  void _onPlayerTap() {
    if (_gameOver || _attemptId == null) return;

    HapticFeedback.lightImpact();
    _tapCount++;
    setState(() {
      _ownershipPct += 2.5; // Player pushes back

      // Advance rounds based on ownership milestones to increase rival difficulty
      if (_ownershipPct > 60 && _round == 1) _round = 2;
      if (_ownershipPct > 70 && _round == 2) _round = 3;
      if (_ownershipPct > 80 && _round == 3) _round = 4;
      if (_ownershipPct > 90 && _round == 4) _round = 5;

      if (_ownershipPct >= 100.0) {
        _ownershipPct = 100.0;
        _won = true;
        _endGame();
      }
    });
  }

  void _endGame() {
    if (_gameOver) return;
    setState(() => _gameOver = true);

    _gameTimer.stop();
    _rivalForce.stop();

    if (_won) {
      HapticFeedback.heavyImpact();
      Future<void>.delayed(const Duration(milliseconds: 200), () {
        HapticFeedback.heavyImpact();
      });

      // Wire to EquityProvider for economic impact
    } else {
      HapticFeedback.vibrate();
    }
    final String? attemptId = _attemptId;
    if (attemptId != null) {
      ref.read(equityProvider.notifier).applyTakeoverResult(
            attemptId: attemptId,
            tapCount: _tapCount,
          );
    }

    // Pop the modal after showing the result
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!MiniGameService.rewardsAreAvailable) {
      return const MiniGameRewardsUnavailableScreen();
    }
    return Scaffold(
      backgroundColor: AurelianPalette.textPrimary, // Obsidian
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onPlayerTap,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Timer & Round Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'ROUND $_round/5',
                      style: const TextStyle(
                        color: AurelianPalette.champagneGold,
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _gameTimer,
                      builder: (BuildContext context, Widget? child) {
                        final int secondsLeft =
                            (30 - (_gameTimer.value * 30)).ceil();
                        return Text(
                          '00:${secondsLeft.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: AurelianPalette.ivory,
                            fontFamily: 'JetBrainsMono',
                            fontSize: 18,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Live Share Price Ticker (Visual flair)
              Text(
                '\$${(145.00 * (_ownershipPct / 50)).toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AurelianPalette.champagneGold,
                  fontSize: 48,
                  fontFamily: 'JetBrainsMono',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _gameOver
                    ? (_won ? 'TAKEOVER SUCCESSFUL' : 'TAKEOVER FAILED')
                    : 'TAP TO ACQUIRE SHARES',
                style: TextStyle(
                  color: _gameOver
                      ? (_won
                          ? AurelianPalette.champagneGold
                          : AurelianPalette.danger)
                      : AurelianPalette.ivory,
                  letterSpacing: 2.0,
                ),
              ),

              const SizedBox(height: 40),

              // The Tug-Of-War Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 20,
                    child: LinearProgressIndicator(
                      value: _ownershipPct / 100,
                      backgroundColor: const Color(0xFFB71C1C), // Rival color
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AurelianPalette.champagneGold, // Player color
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
