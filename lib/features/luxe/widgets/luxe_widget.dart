// GDD §8.12 - Luxe mentor: 2D animated concierge, daily check-ins, quest prompts
// Directive O: Luxe Identity with Trust Score and contextual dialogue

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/aurelian_theme.dart';
import '../../../domain/models/player.dart';
import '../../hq/providers/hq_provider.dart';

/// LuxeWidget — Luxury concierge with Trust Score and contextual dialogue
/// GDD §8.12: Trust Score is a relationship meter, not a wealth meter.
/// Gates dialogue on luxeTrustScore from player stream (default 50 = warm).
class LuxeWidget extends ConsumerWidget {
  const LuxeWidget({super.key});

  /// GDD §8.12: Dialogue tiers keyed to Trust Score, not capital
  /// 0–25 Cold · 26–60 Warm · 61–85 Trusted · 86–100 Sovereign
  String _getDialogueForTrust(int trustScore) {
    if (trustScore <= 25) {
      return 'Every empire starts with a stitch, darling. Your first design is your foundation.';
    } else if (trustScore <= 60) {
      return 'The atelier is warm. Your reputation is beginning to ripple through the districts.';
    } else if (trustScore <= 85) {
      return 'Your name is whispered in high places. Time to expand the Maison influence.';
    } else {
      return 'Sovereign. Your legacy will echo through the Hall for generations.';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Player> playerAsync = ref.watch(hqPlayerStreamProvider);

    return playerAsync.when(
      data: (Player player) => _LuxeContent(
        trustScore: player.luxeTrustScore.toDouble(),
        dialogue: _getDialogueForTrust(player.luxeTrustScore),
      ),
      loading: () => const _LuxeLoading(),
      error: (Object _, StackTrace __) => const _LuxeError(),
    );
  }
}

class _LuxeContent extends StatelessWidget {
  const _LuxeContent({
    required this.trustScore,
    required this.dialogue,
  });

  final double trustScore;
  final String dialogue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AurelianPalette.ivory.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        border: Border.all(
          color: AurelianPalette.champagneGold,
        ),
      ),
      child: Row(
        children: <Widget>[
          _LuxeSigil(),
          const SizedBox(width: 16),

          // Content area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Trust Score bar
                Row(
                  children: <Widget>[
                    const Text(
                      'TRUST',
                      style: TextStyle(
                        color: AurelianPalette.textTertiary,
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: trustScore / 100,
                          backgroundColor:
                              AurelianPalette.softRose.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AurelianPalette.champagneGold,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${trustScore.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: AurelianPalette.champagneGold,
                        fontFamily: 'JetBrainsMono',
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Dialogue
                Text(
                  dialogue,
                  style: const TextStyle(
                    color: AurelianPalette.ivory,
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LuxeSigil extends StatefulWidget {
  @override
  State<_LuxeSigil> createState() => _LuxeSigilState();
}

class _LuxeSigilState extends State<_LuxeSigil>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (BuildContext context, Widget? child) {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AurelianPalette.champagneGold.withValues(
              alpha: 0.2 * _pulseAnimation.value,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AurelianPalette.champagneGold.withValues(
                alpha: 0.5 * _pulseAnimation.value,
              ),
              width: 2,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.auto_awesome,
              color: AurelianPalette.champagneGold,
              size: 28,
            ),
          ),
        );
      },
    );
  }
}

class _LuxeLoading extends StatelessWidget {
  const _LuxeLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AurelianPalette.ivory.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        border: Border.all(
          color: AurelianPalette.champagneGold.withValues(alpha: 0.3),
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AurelianPalette.champagneGold,
          ),
        ),
      ),
    );
  }
}

class _LuxeError extends StatelessWidget {
  const _LuxeError();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AurelianPalette.danger.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        border: Border.all(
          color: AurelianPalette.danger,
        ),
      ),
      child: const Row(
        children: <Widget>[
          Icon(
            Icons.error_outline,
            color: AurelianPalette.danger,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Luxe connection lost. Tap to reconnect.',
              style: TextStyle(
                color: AurelianPalette.danger,
                fontFamily: 'SpaceGrotesk',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
