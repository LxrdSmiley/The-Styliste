// GDD §5.7 — Price War Blitz mini-game (8–15s, tap-rhythm)
// Directive O: The Zero-Stub Mandate — Full implementation with economic wiring

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/mini_game_service.dart';
import '../../../core/theme/aurelian_theme.dart';
import '../../../features/ledger/providers/ledger_provider.dart';
import '../widgets/mini_game_rewards_unavailable.dart';

/// Price War Blitz — Rhythm-based price alignment mini-game
/// Tap when gold slider aligns with target zone
class PriceWarScreen extends ConsumerStatefulWidget {
  const PriceWarScreen({super.key});

  @override
  ConsumerState<PriceWarScreen> createState() => _PriceWarScreenState();
}

class _PriceWarScreenState extends ConsumerState<PriceWarScreen>
    with TickerProviderStateMixin {
  late AnimationController _sliderAnim;
  int _round = 1;
  int _score = 0;
  bool _gameOver = false;
  bool _won = false;
  Color _flashColor = Colors.transparent;
  String? _attemptId;
  final List<double> _tapValues = <double>[];

  @override
  void initState() {
    super.initState();
    if (!MiniGameService.rewardsAreAvailable) return;
    _startRound();
    _prepareAttempt();
  }

  Future<void> _prepareAttempt() async {
    try {
      final MiniGameAttempt attempt = await MiniGameService.start('price_war');
      if (mounted) setState(() => _attemptId = attempt.id);
    } catch (_) {
      if (mounted) setState(() => _gameOver = true);
    }
  }

  void _startRound() {
    final int duration = 1200 - (_round * 200); // Speeds up each round
    _sliderAnim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: duration),
    )..repeat(reverse: true);
  }

  void _onTap() {
    if (_gameOver || _attemptId == null) return;
    _tapValues.add(_sliderAnim.value);

    // Target zone is between 0.4 and 0.6
    if (_sliderAnim.value >= 0.4 && _sliderAnim.value <= 0.6) {
      HapticFeedback.mediumImpact();
      _score++;
      _flash(AurelianPalette.champagneGold);
      _sliderAnim.dispose();

      if (_round < 3) {
        _round++;
        _startRound();
      } else {
        _won = true;
        _endGame();
      }
    } else {
      HapticFeedback.vibrate();
      _flash(AurelianPalette.danger);
      _endGame();
    }
  }

  void _flash(Color color) {
    setState(() => _flashColor = color);
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _flashColor = Colors.transparent);
      }
    });
  }

  void _endGame() {
    setState(() => _gameOver = true);
    _sliderAnim.dispose();

    if (_won) {
      HapticFeedback.heavyImpact();
    }

    // Wire to LedgerProvider for economic impact
    final String? attemptId = _attemptId;
    if (attemptId != null) {
      ref.read(upgradeStoreProvider.notifier).applyPriceWarResult(
            attemptId: attemptId,
            tapValues: _tapValues,
          );
    }

    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.pop();
      }
    });
  }

  @override
  void dispose() {
    if (!MiniGameService.rewardsAreAvailable) {
      super.dispose();
      return;
    }
    if (!_gameOver) {
      _sliderAnim.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!MiniGameService.rewardsAreAvailable) {
      return const MiniGameRewardsUnavailableScreen();
    }
    return Scaffold(
      backgroundColor: AurelianPalette.textPrimary,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: _flashColor == Colors.transparent
              ? AurelianPalette.textPrimary
              : _flashColor.withValues(alpha: 0.3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'PRICE WAR: ROUND $_round/3',
                style: const TextStyle(
                  color: AurelianPalette.champagneGold,
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 40),
              if (!_gameOver) ...<Widget>[
                const Text(
                  'TAP WHEN GOLD ALIGNS',
                  style: TextStyle(
                    color: AurelianPalette.ivory,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(height: 4, color: Colors.grey[800]),
                      Container(
                        width: 60,
                        height: 20,
                        color: Colors.white24,
                      ), // Target Zone
                      AnimatedBuilder(
                        animation: _sliderAnim,
                        builder: (BuildContext context, Widget? child) {
                          return Align(
                            alignment:
                                Alignment(-1.0 + (_sliderAnim.value * 2), 0),
                            child: Container(
                              width: 4,
                              height: 40,
                              color: AurelianPalette.champagneGold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ] else ...<Widget>[
                Text(
                  _score >= 3 ? 'MARKET CAPTURED' : 'UNDERCUT BY RIVAL',
                  style: TextStyle(
                    color: _score >= 3
                        ? AurelianPalette.champagneGold
                        : AurelianPalette.danger,
                    fontSize: 28,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
