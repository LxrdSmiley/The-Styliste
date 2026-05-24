// GDD §5.7 — Supplier Raid mini-game (drag-and-drop resource cards)
// Directive O: The Zero-Stub Mandate — Full implementation with economic wiring

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/aurelian_theme.dart';
import '../../../features/supply_chain/providers/supply_chain_provider.dart';

/// Supplier Raid — Competitive drag-and-drop resource mini-game
/// Drag cards to center before rival claims them; win = 15% logistics discount
class SupplierRaidScreen extends ConsumerStatefulWidget {
  const SupplierRaidScreen({super.key});

  @override
  ConsumerState<SupplierRaidScreen> createState() => _SupplierRaidScreenState();
}

class _SupplierRaidScreenState extends ConsumerState<SupplierRaidScreen>
    with TickerProviderStateMixin {
  late AnimationController _gameTimer;
  final List<_ResourceCard> _playerCards = <_ResourceCard>[];
  final List<_ResourceCard> _rivalCards = <_ResourceCard>[];
  int _playerScore = 0;
  int _rivalScore = 0;
  bool _gameOver = false;
  bool _won = false;

  @override
  void initState() {
    super.initState();
    _gameTimer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..forward().then((_) => _endGame());

    // Spawn cards periodically
    _spawnCards();
  }

  void _spawnCards() {
    Future<void>.delayed(const Duration(milliseconds: 2000), () {
      if (!_gameOver && mounted) {
        setState(() {
          // Add to player side
          _playerCards.add(
            _ResourceCard(
              id: 'p_${DateTime.now().millisecondsSinceEpoch}',
              type: math.Random().nextInt(4),
              side: 'player',
            ),
          );

          // Add to rival side (after delay)
          Future<void>.delayed(const Duration(milliseconds: 800), () {
            if (!_gameOver && mounted) {
              setState(() {
                _rivalCards.add(
                  _ResourceCard(
                    id: 'r_${DateTime.now().millisecondsSinceEpoch}',
                    type: math.Random().nextInt(4),
                    side: 'rival',
                  ),
                );

                // Rival auto-claims after 3 seconds
                Future<void>.delayed(const Duration(milliseconds: 3000), () {
                  if (!_gameOver && mounted) {
                    setState(() {
                      _rivalScore++;
                      _rivalCards.removeWhere(
                        (_ResourceCard c) =>
                            c.id == _rivalCards.firstOrNull?.id,
                      );
                    });
                  }
                });
              });
            }
          });
        });
        _spawnCards();
      }
    });
  }

  void _onPlayerClaim(String cardId) {
    HapticFeedback.lightImpact();
    setState(() {
      _playerScore++;
      _playerCards.removeWhere((_ResourceCard c) => c.id == cardId);
    });
  }

  void _endGame() {
    if (_gameOver) return;
    setState(() {
      _gameOver = true;
      _won = _playerScore > _rivalScore;
    });
    _gameTimer.stop();

    if (_won) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.vibrate();
    }

    // Wire to SupplyChainProvider for economic impact
    ref
        .read(logisticsUpgradeProvider.notifier)
        .applySupplierRaidResult(won: _won);

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
            const SizedBox(height: 20),
            // Header
            const Text(
              'SUPPLIER RAID',
              style: TextStyle(
                color: AurelianPalette.champagneGold,
                fontFamily: 'SpaceGrotesk',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Score display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  'YOU: $_playerScore',
                  style: const TextStyle(
                    color: AurelianPalette.champagneGold,
                    fontFamily: 'JetBrainsMono',
                    fontSize: 18,
                  ),
                ),
                Text(
                  'RIVAL: $_rivalScore',
                  style: const TextStyle(
                    color: AurelianPalette.danger,
                    fontFamily: 'JetBrainsMono',
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Timer bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: AnimatedBuilder(
                animation: _gameTimer,
                builder: (BuildContext context, Widget? child) {
                  return LinearProgressIndicator(
                    value: 1.0 - _gameTimer.value,
                    backgroundColor: Colors.grey[800],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AurelianPalette.champagneGold,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Central progress indicator
            SizedBox(
              width: 200,
              height: 20,
              child: LinearProgressIndicator(
                value: (_playerScore + _rivalScore) > 0
                    ? _playerScore / (_playerScore + _rivalScore)
                    : 0.5,
                backgroundColor: AurelianPalette.danger,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AurelianPalette.champagneGold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Game area
            Expanded(
              child: Row(
                children: <Widget>[
                  // Player column (left)
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        const Text(
                          'DRAG TO CENTER',
                          style: TextStyle(
                            color: AurelianPalette.ivory,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _playerCards.length,
                            itemBuilder: (BuildContext context, int index) {
                              final _ResourceCard card = _playerCards[index];
                              return Draggable<String>(
                                data: card.id,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: _buildCard(card, isPlayer: true),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: _buildCard(card, isPlayer: true),
                                ),
                                child: _buildCard(card, isPlayer: true),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Center drop zone
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color:
                          AurelianPalette.champagneGold.withValues(alpha: 0.1),
                      border: Border.all(
                        color: AurelianPalette.champagneGold,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DragTarget<String>(
                      onAcceptWithDetails: (DragTargetDetails<String> details) {
                        _onPlayerClaim(details.data);
                      },
                      builder: (
                        BuildContext context,
                        List<String?> candidateData,
                        List<dynamic> rejectedData,
                      ) {
                        return const Center(
                          child: Icon(
                            Icons.add_business,
                            color: AurelianPalette.champagneGold,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                  // Rival column (right)
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        const Text(
                          'RIVAL CLAIMS',
                          style: TextStyle(
                            color: AurelianPalette.danger,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _rivalCards.length,
                            itemBuilder: (BuildContext context, int index) {
                              return _buildCard(
                                _rivalCards[index],
                                isPlayer: false,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Game over message
            if (_gameOver)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  _won ? 'SUPPLIERS SECURED!' : 'RIVAL DOMINANCE',
                  style: TextStyle(
                    color: _won
                        ? AurelianPalette.champagneGold
                        : AurelianPalette.danger,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(_ResourceCard card, {required bool isPlayer}) {
    final List<IconData> icons = <IconData>[
      Icons.texture,
      Icons.precision_manufacturing,
      Icons.local_shipping,
      Icons.warehouse,
    ];
    final List<Color> colors = <Color>[
      AurelianPalette.softRose,
      AurelianPalette.info,
      AurelianPalette.warning,
      AurelianPalette.success,
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors[card.type].withValues(alpha: 0.2),
        border: Border.all(color: colors[card.type], width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icons[card.type],
        color: colors[card.type],
        size: 24,
      ),
    );
  }
}

class _ResourceCard {
  const _ResourceCard({
    required this.id,
    required this.type,
    required this.side,
  });

  final String id;
  final int type; // 0-3: fabric, manufacturing, shipping, warehouse
  final String side; // 'player' or 'rival'
}
