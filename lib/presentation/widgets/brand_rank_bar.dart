// GDD §3.1 — Brand Rank progress bar widget (shared, both paths)
// Phase 1: flutter_animate shimmer on fill; gold glow at rank-up threshold

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/aurelian_theme.dart';

class BrandRankBar extends StatelessWidget {
  const BrandRankBar({
    required this.currentRank,
    required this.xpProgress,
    super.key,
  });

  final int currentRank;
  final double xpProgress; // 0.0–1.0

  @override
  Widget build(BuildContext context) {
    final bool isNearRankUp = xpProgress >= 0.9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'RANK $currentRank',
              style: const TextStyle(
                color: AurelianPalette.champagneGold,
                fontFamily: 'SpaceGrotesk',
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
            Text(
              '${(xpProgress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: isNearRankUp
                    ? AurelianPalette.champagneGold
                    : AurelianPalette.textTertiary,
                fontFamily: 'SpaceGrotesk',
                fontSize: 11.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(4.0)),
          child: LinearProgressIndicator(
            value: xpProgress,
            backgroundColor: AurelianPalette.textTertiary.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              isNearRankUp
                  ? AurelianPalette.champagneGold
                  : AurelianPalette.champagneGold.withValues(alpha: 0.65),
            ),
            minHeight: 4.0,
          ),
        )
        // Shimmer sweep animates on every build when value changes
        .animate(key: ValueKey<double>(xpProgress))
        .shimmer(
          duration: const Duration(milliseconds: 900),
          color: AurelianPalette.champagneGold.withValues(alpha: 0.4),
          size: 0.5,
        ),
      ],
    );
  }
}
