// GDD §3.0 (Artisan HQ view) — Hype meter: animated gauge, pulses gold at peak
// Phase 1: flutter_animate shimmer sweep + gold pulse glow when hype >= 90

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/aurelian_theme.dart';

class HypeMeter extends StatelessWidget {
  const HypeMeter({required this.hypeValue, super.key});

  final double hypeValue; // 0.0–100.0

  @override
  Widget build(BuildContext context) {
    final double normalised = (hypeValue / 100.0).clamp(0.0, 1.0);
    final bool isPeak = normalised >= 0.9;
    final Color meterColor = isPeak
        ? AurelianPalette.champagneGold
        : AurelianPalette.softRose;

    final Widget bar = ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      child: LinearProgressIndicator(
        value: normalised,
        backgroundColor: AurelianPalette.textTertiary.withValues(alpha: 0.2),
        valueColor: AlwaysStoppedAnimation<Color>(meterColor),
        minHeight: 6.0,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'HYPE',
              style: TextStyle(
                color: isPeak
                    ? AurelianPalette.champagneGold
                    : AurelianPalette.textTertiary,
                fontFamily: 'SpaceGrotesk',
                fontSize: 10.0,
                letterSpacing: 2.0,
                fontWeight: isPeak ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
            Text(
              hypeValue.toStringAsFixed(0),
              style: TextStyle(
                color: isPeak
                    ? AurelianPalette.champagneGold
                    : AurelianPalette.textTertiary,
                fontFamily: 'JetBrainsMono',
                fontSize: 10.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        // Peak hype: continuous shimmer pulse; otherwise one-shot sweep on change
        isPeak
            ? bar
                .animate(onPlay: (AnimationController c) => c.repeat())
                .shimmer(
                  duration: const Duration(milliseconds: 1200),
                  color: AurelianPalette.champagneGold.withValues(alpha: 0.6),
                  size: 0.6,
                )
            : bar
                .animate(key: ValueKey<double>(hypeValue))
                .shimmer(
                  duration: const Duration(milliseconds: 700),
                  color: AurelianPalette.softRose.withValues(alpha: 0.3),
                  size: 0.4,
                ),
      ],
    );
  }
}
