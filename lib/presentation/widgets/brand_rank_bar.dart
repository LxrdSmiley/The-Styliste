// GDD §3.1 — Brand Rank progress bar widget (shared, both paths)
// Phase 1: flutter_animate shimmer on fill; gold glow at rank-up threshold
// DIR-015: Shimmer fires specifically on rank-up event

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/aurelian_theme.dart';

class BrandRankBar extends StatefulWidget {
  const BrandRankBar({
    required this.currentRank,
    required this.xpProgress,
    super.key,
  });

  final int currentRank;
  final double xpProgress; // 0.0–1.0

  @override
  State<BrandRankBar> createState() => _BrandRankBarState();
}

class _BrandRankBarState extends State<BrandRankBar> {
  bool _rankUpTriggered = false;

  @override
  void didUpdateWidget(BrandRankBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentRank > oldWidget.currentRank) {
      setState(() => _rankUpTriggered = true);
      // Reset trigger after animation completes
      Future<void>.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _rankUpTriggered = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isNearRankUp = widget.xpProgress >= 0.9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'RANK ${widget.currentRank}',
              style: const TextStyle(
                color: AurelianPalette.champagneGold,
                fontFamily: 'SpaceGrotesk',
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
            Text(
              '${(widget.xpProgress * 100).toStringAsFixed(0)}%',
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
            value: widget.xpProgress,
            backgroundColor:
                AurelianPalette.textTertiary.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              isNearRankUp
                  ? AurelianPalette.champagneGold
                  : AurelianPalette.champagneGold.withValues(alpha: 0.65),
            ),
            minHeight: 4.0,
          ),
        )
            // Shimmer sweep animates on every build when value changes
            .animate(
              key: ValueKey<double>(widget.xpProgress),
            )
            .shimmer(
              duration: const Duration(milliseconds: 900),
              color: AurelianPalette.champagneGold.withValues(alpha: 0.4),
              size: 0.5,
            )
            // Additional high-intensity shimmer specifically on rank-up (DIR-015)
            .animate(target: _rankUpTriggered ? 1.0 : 0.0)
            .shimmer(
              duration: const Duration(milliseconds: 1200),
              color: Colors.white.withValues(alpha: 0.8),
              size: 0.8,
            )
            .boxShadow(
              begin: const BoxShadow(color: Colors.transparent),
              end: const BoxShadow(
                color: AurelianPalette.champagneGold,
                blurRadius: 12,
                spreadRadius: 2,
              ),
              curve: Curves.elasticOut,
            ),
      ],
    );
  }
}
