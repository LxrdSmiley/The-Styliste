// GDD §5.7 — Power Move Combo mini-game (sequence drag, 72h cooldown)
// Directive O: The Zero-Stub Mandate — Full implementation with economic wiring

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/aurelian_theme.dart';
import '../../../features/ledger/providers/ledger_provider.dart';

/// Power Move Combo — Sequence memorization and drag mini-game
/// Memorize 4-icon sequence, then drag scrambled icons to match
class PowerMoveComboScreen extends ConsumerStatefulWidget {
  const PowerMoveComboScreen({super.key});

  @override
  ConsumerState<PowerMoveComboScreen> createState() =>
      _PowerMoveComboScreenState();
}

class _PowerMoveComboScreenState extends ConsumerState<PowerMoveComboScreen>
    with TickerProviderStateMixin {
  final List<IconData> _targetSequence = <IconData>[
    Icons.trending_up,
    Icons.security,
    Icons.bolt,
    Icons.star,
  ];
  List<IconData> _scrambled = <IconData>[];
  int _currentIndex = 0;
  bool _showingSequence = true;
  bool _gameOver = false;
  bool _won = false;
  double _achievedMultiplier = 1.0;
  late AnimationController _timer;

  @override
  void initState() {
    super.initState();
    _scrambled = List<IconData>.from(_targetSequence)..shuffle();
    _timer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    // Show sequence for 3 seconds, then hide and start game timer
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showingSequence = false);
        _timer.forward().then((_) {
          if (!_gameOver) {
            _endGame(false);
          }
        });
      }
    });
  }

  void _onAccept(IconData data) {
    if (data == _targetSequence[_currentIndex]) {
      HapticFeedback.lightImpact();
      setState(() => _currentIndex++);

      if (_currentIndex == 4) {
        // Calculate multiplier based on remaining time
        final double timeRatio = 1.0 - _timer.value;
        _achievedMultiplier = 1.2 + (timeRatio * 0.8); // 1.2x to 2.0x
        _endGame(true);
      }
    } else {
      HapticFeedback.vibrate();
      _endGame(false);
    }
  }

  void _endGame(bool won) {
    if (_gameOver) return;
    setState(() {
      _gameOver = true;
      _won = won;
    });
    _timer.stop();

    if (won) {
      HapticFeedback.heavyImpact();
      // Wire to LedgerProvider for economic impact
      ref.read(upgradeStoreProvider.notifier).applyPowerMoveCombo(
            multiplier: _achievedMultiplier,
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
    _timer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AurelianPalette.textPrimary,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _showingSequence ? 'MEMORIZE THE STRIKE' : 'EXECUTE SEQUENCE',
              style: const TextStyle(
                color: AurelianPalette.champagneGold,
                fontSize: 20,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 40),

            // Target Slots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List<Widget>.generate(4, (int index) {
                return DragTarget<IconData>(
                  onWillAcceptWithDetails: (_) =>
                      !_gameOver && !_showingSequence,
                  onAcceptWithDetails: (DragTargetDetails<IconData> details) {
                    _onAccept(details.data);
                  },
                  builder: (
                    BuildContext context,
                    List<IconData?> candidateData,
                    List<dynamic> rejectedData,
                  ) {
                    final bool isFilled = index < _currentIndex;
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isFilled
                              ? AurelianPalette.champagneGold
                              : Colors.grey[800]!,
                        ),
                        color: isFilled
                            ? AurelianPalette.champagneGold
                                .withValues(alpha: 0.2)
                            : Colors.transparent,
                      ),
                      child: Icon(
                        _showingSequence
                            ? _targetSequence[index]
                            : (isFilled
                                ? _targetSequence[index]
                                : Icons.lock_outline),
                        color: isFilled || _showingSequence
                            ? AurelianPalette.champagneGold
                            : Colors.grey[800],
                      ),
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 80),

            // Draggable Items
            if (!_showingSequence && !_gameOver)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _scrambled.map((IconData icon) {
                  return Draggable<IconData>(
                    data: icon,
                    feedback:
                        Icon(icon, color: AurelianPalette.ivory, size: 40),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: Icon(icon, color: AurelianPalette.champagneGold),
                    ),
                    child: Icon(
                      icon,
                      color: AurelianPalette.champagneGold,
                      size: 40,
                    ),
                  );
                }).toList(),
              ),

            if (_gameOver)
              Text(
                _won
                    ? 'SYNERGY: ${(_achievedMultiplier).toStringAsFixed(1)}x'
                    : 'COMBO BROKEN',
                style: TextStyle(
                  color: _won
                      ? AurelianPalette.champagneGold
                      : AurelianPalette.danger,
                  fontSize: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
