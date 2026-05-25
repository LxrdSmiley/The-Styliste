// GDD §5.7 — Flash Sale Frenzy mini-game (60s sprint, swipe mechanic)
// Directive O: The Zero-Stub Mandate — Full implementation with economic wiring

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/aurelian_theme.dart';
import '../../../features/supply_chain/providers/supply_chain_provider.dart';

/// Flash Sale Frenzy — Falling garment drag mini-game
/// Drag falling garment cards to tier bins before they fall off screen
class FlashSaleScreen extends ConsumerStatefulWidget {
  const FlashSaleScreen({super.key});

  @override
  ConsumerState<FlashSaleScreen> createState() => _FlashSaleScreenState();
}

class _FlashSaleScreenState extends ConsumerState<FlashSaleScreen>
    with TickerProviderStateMixin {
  late AnimationController _gameTimer;
  final List<_FallingGarment> _garments = <_FallingGarment>[];
  int _matchCount = 0;
  int _missCount = 0;
  bool _gameOver = false;
  bool _won = false;

  // Tier bins at bottom
  final List<_TierBin> _tierBins = <_TierBin>[
    const _TierBin(
      label: 'TIER 1',
      color: Color(0xFFB87333),
      tier: 1,
    ), // Bronze
    const _TierBin(
      label: 'TIER 2',
      color: AurelianPalette.champagneGold,
      tier: 2,
    ), // Gold
    const _TierBin(
      label: 'TIER 3',
      color: Color(0xFF9966CC),
      tier: 3,
    ), // Violet
  ];

  @override
  void initState() {
    super.initState();
    _gameTimer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..forward().then((_) => _endGame());

    // Spawn garments periodically
    _spawnGarments();
  }

  void _spawnGarments() {
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (!_gameOver && mounted) {
        setState(() {
          _garments.add(
            _FallingGarment(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              tier: math.Random().nextInt(3) + 1,
              xPosition: math.Random().nextDouble() * 0.8 + 0.1,
            ),
          );
        });
        _spawnGarments();
      }
    });
  }

  void _onDrop(String garmentId, int tier) {
    final _FallingGarment garment = _garments.firstWhere(
      (_FallingGarment g) => g.id == garmentId,
    );

    if (garment.tier == tier) {
      HapticFeedback.lightImpact();
      setState(() {
        _matchCount++;
        _garments.removeWhere((_FallingGarment g) => g.id == garmentId);
      });
    } else {
      HapticFeedback.vibrate();
      setState(() {
        _missCount++;
      });
    }
  }

  void _onMiss() {
    setState(() => _missCount++);
  }

  void _endGame() {
    if (_gameOver) return;
    setState(() {
      _gameOver = true;
      _won = _matchCount >= 10; // Need at least 10 matches to win
    });
    _gameTimer.stop();

    if (_won) {
      HapticFeedback.heavyImpact();
    }

    // Wire to SupplyChainProvider for economic impact
    ref.read(liquidationProvider.notifier).liquidateStock(
          matchCount: _matchCount,
        );

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
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AurelianPalette.textPrimary,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            // Header
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Column(
                children: <Widget>[
                  const Text(
                    'FLASH SALE FRENZY',
                    style: TextStyle(
                      color: AurelianPalette.champagneGold,
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'MATCHES: $_matchCount  MISSES: $_missCount',
                    style: const TextStyle(
                      color: AurelianPalette.ivory,
                      fontFamily: 'JetBrainsMono',
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Timer bar
            Positioned(
              top: 80,
              left: 40,
              right: 40,
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

            // Falling garments
            ..._garments.map((_FallingGarment garment) {
              return _FallingGarmentWidget(
                key: ValueKey<String>(garment.id),
                garment: garment,
                screenHeight: screenSize.height,
                onComplete: _onMiss,
              );
            }),

            // Tier bins at bottom
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _tierBins.map((_TierBin bin) {
                  return DragTarget<String>(
                    onAcceptWithDetails: (DragTargetDetails<String> details) {
                      _onDrop(details.data, bin.tier);
                    },
                    builder: (
                      BuildContext context,
                      List<String?> candidateData,
                      List<dynamic> rejectedData,
                    ) {
                      return Container(
                        width: 100,
                        height: 80,
                        decoration: BoxDecoration(
                          color: bin.color.withValues(alpha: 0.3),
                          border: Border.all(
                            color: bin.color,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            bin.label,
                            style: TextStyle(
                              color: bin.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),

            // Game over overlay
            if (_gameOver)
              Center(
                child: Text(
                  _won ? 'SALE CLEARED!' : 'INVENTORY BACKUP',
                  style: TextStyle(
                    color: _won
                        ? AurelianPalette.champagneGold
                        : AurelianPalette.danger,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FallingGarment {
  const _FallingGarment({
    required this.id,
    required this.tier,
    required this.xPosition,
  });

  final String id;
  final int tier;
  final double xPosition;
}

class _TierBin {
  const _TierBin({
    required this.label,
    required this.color,
    required this.tier,
  });

  final String label;
  final Color color;
  final int tier;
}

class _FallingGarmentWidget extends StatefulWidget {
  const _FallingGarmentWidget({
    required super.key,
    required this.garment,
    required this.screenHeight,
    required this.onComplete,
  });

  final _FallingGarment garment;
  final double screenHeight;
  final VoidCallback onComplete;

  @override
  State<_FallingGarmentWidget> createState() => _FallingGarmentWidgetState();
}

class _FallingGarmentWidgetState extends State<_FallingGarmentWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _fallController;
  late Animation<double> _fallAnimation;

  @override
  void initState() {
    super.initState();
    _fallController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _fallAnimation = Tween<double>(
      begin: 120, // Start below header
      end: widget.screenHeight - 150, // End above bins
    ).animate(_fallController);

    _fallController.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _fallController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _fallAnimation,
      builder: (BuildContext context, Widget? child) {
        return Positioned(
          top: _fallAnimation.value,
          left: widget.garment.xPosition * screenSize.width - 30,
          child: Draggable<String>(
            data: widget.garment.id,
            feedback: Material(
              color: Colors.transparent,
              child: _buildGarmentCard(),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: _buildGarmentCard(),
            ),
            child: _buildGarmentCard(),
          ),
        );
      },
    );
  }

  Widget _buildGarmentCard() {
    Color tierColor;
    switch (widget.garment.tier) {
      case 1:
        tierColor = const Color(0xFFB87333); // Bronze
      case 2:
        tierColor = AurelianPalette.champagneGold;
      case 3:
        tierColor = const Color(0xFF9966CC); // Violet
      default:
        tierColor = AurelianPalette.ivory;
    }

    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        color: tierColor.withValues(alpha: 0.2),
        border: Border.all(color: tierColor, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Icon(
          Icons.checkroom,
          color: tierColor,
          size: 32,
        ),
      ),
    );
  }
}
