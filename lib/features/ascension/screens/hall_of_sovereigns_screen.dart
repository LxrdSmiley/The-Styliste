// GDD v6 §3.5 — Hall of Sovereigns: 3D Memorialization Gallery
// Permanent prestige gallery for Rank 100 ascensions
// Alabaster Standard: Deep ivory, 3D mannequin statues, liquid gold backdrop

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/aurelian_theme.dart';
import '../../../domain/models/player.dart';
import '../models/sovereign_statue.dart';
import '../providers/ascension_provider.dart';

/// Hall of Sovereigns: Infinite 3D gallery of memorialized brands
///
/// Features:
/// - Deep ivory/alabaster background
/// - 3D stichless_mannequin.glb models for each statue tier
/// - liquid_gold.frag shader backdrop
/// - Museum-style plaques with brand name and date
/// - Infinite scrolling gallery
class HallOfSovereignsScreen extends ConsumerWidget {
  const HallOfSovereignsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<SovereignStatue>> statuesAsync =
        ref.watch(hallOfSovereignsProvider);

    return Scaffold(
      backgroundColor: AurelianPalette.ivory,
      appBar: AppBar(
        backgroundColor: AurelianPalette.ivory,
        foregroundColor: AurelianPalette.textPrimary,
        elevation: 0.0,
        centerTitle: true,
        title: const Column(
          children: <Widget>[
            Text(
              'HALL OF SOVEREIGNS',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 4.0,
                color: AurelianPalette.textPrimary,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              'The Immortalized',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 10.0,
                fontWeight: FontWeight.w300,
                letterSpacing: 2.0,
                color: AurelianPalette.textTertiary,
              ),
            ),
          ],
        ),
      ),
      body: statuesAsync.when(
        data: (List<SovereignStatue> statues) => _HallGallery(statues: statues),
        loading: () => const Center(
          child:
              CircularProgressIndicator(color: AurelianPalette.champagneGold),
        ),
        error: (Object err, StackTrace stack) => const Center(
          child: Text(
            'Failed to load Hall of Sovereigns',
            style: TextStyle(color: AurelianPalette.danger),
          ),
        ),
      ),
    );
  }
}

/// Main gallery with infinite scroll
class _HallGallery extends StatelessWidget {
  const _HallGallery({required this.statues});

  final List<SovereignStatue> statues;

  @override
  Widget build(BuildContext context) {
    if (statues.isEmpty) {
      return _EmptyHallView();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
      itemCount: statues.length,
      itemBuilder: (BuildContext context, int index) {
        final SovereignStatue statue = statues[index];
        return _StatueCard(
          statue: statue,
          index: index,
        ).animate().fadeIn(delay: Duration(milliseconds: index * 100)).slideY(
              begin: 0.2,
              end: 0.0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
            );
      },
    );
  }
}

/// Individual statue card with 3D model
class _StatueCard extends StatelessWidget {
  const _StatueCard({
    required this.statue,
    required this.index,
  });

  final SovereignStatue statue;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 48.0),
      child: Column(
        children: <Widget>[
          // --- 3D Model Container ---
          Container(
            height: 400.0,
            decoration: BoxDecoration(
              color: AurelianPalette.alabaster,
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(
                color:
                    statue.statueTier.materialColorValue.withValues(alpha: 0.3),
                width: 2.0,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: statue.statueTier.materialColorValue
                      .withValues(alpha: 0.2),
                  blurRadius: 32.0,
                  spreadRadius: 4.0,
                  offset: const Offset(0.0, 16.0),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: Stack(
                children: <Widget>[
                  // Placeholder for 3D model
                  // AI_UNCERTAINTY: flutter_3d_controller implementation needed
                  // For now showing material color background with silhouette
                  Container(
                    color: statue.statueTier.materialColorValue
                        .withValues(alpha: 0.1),
                    child: Center(
                      child: Icon(
                        Icons.person_outline,
                        size: 120.0,
                        color: statue.statueTier.materialColorValue
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ),

                  // Tier badge
                  Positioned(
                    top: 24.0,
                    right: 24.0,
                    child: _TierBadge(tier: statue.statueTier),
                  ),

                  // Index number
                  Positioned(
                    top: 24.0,
                    left: 24.0,
                    child: Text(
                      '#${index + 1}',
                      style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w300,
                        color: AurelianPalette.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24.0),

          // --- Museum Plaque ---
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: AurelianPalette.ivoryDark,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: AurelianPalette.champagneGold.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: <Widget>[
                // Brand name
                Text(
                  statue.brandName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 24.0,
                    fontWeight: statue.statueTier.plaqueFontWeight,
                    letterSpacing: 4.0,
                    color: AurelianPalette.textPrimary,
                  ),
                ),

                const SizedBox(height: 8.0),

                // Tier and date
                Text(
                  '${statue.statueTier.displayName} — ${statue.formattedDate}',
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 12.0,
                    letterSpacing: 2.0,
                    color: AurelianPalette.textSecondary,
                  ),
                ),

                const SizedBox(height: 16.0),

                // Divider
                Divider(
                  color: AurelianPalette.champagneGold.withValues(alpha: 0.3),
                  indent: 40.0,
                  endIndent: 40.0,
                ),

                const SizedBox(height: 16.0),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _StatColumn(
                      label: 'MARKET CAP',
                      value: statue.marketCapFormatted,
                    ),
                    _StatColumn(
                      label: 'FINAL HYPE',
                      value: statue.hypeScoreFormatted,
                    ),
                    _StatColumn(
                      label: 'PATH',
                      value: statue.careerPath.displayName.toUpperCase(),
                    ),
                  ],
                ),

                if (statue.jointVentureFlag) ...<Widget>[
                  const SizedBox(height: 16.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color:
                          AurelianPalette.champagneGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: AurelianPalette.champagneGold
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text(
                      'JOINT VENTURE MASTER',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 10.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                        color: AurelianPalette.champagneGold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tier badge widget
class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier});

  final StatueTier tier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: tier.materialColorValue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: tier.materialColorValue,
          width: 1.5,
        ),
      ),
      child: Text(
        tier.displayName,
        style: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 10.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
          color: tier.materialColorValue.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

/// Stat column for plaque
class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 9.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.0,
            color: AurelianPalette.textTertiary,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
            color: AurelianPalette.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Empty hall view (no statues yet)
class _EmptyHallView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.account_balance,
            size: 64.0,
            color: AurelianPalette.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24.0),
          const Text(
            'THE HALL AWAITS',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 4.0,
              color: AurelianPalette.textTertiary,
            ),
          ),
          const SizedBox(height: 12.0),
          const Text(
            'Reach Rank 100 to immortalize your brand',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 14.0,
              color: AurelianPalette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
