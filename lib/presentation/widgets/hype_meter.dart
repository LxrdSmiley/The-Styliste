// GDD §3.0 (Artisan HQ view) — Hype meter: animated gauge, pulses gold at peak
// TODO: Add pulse animation with flutter_animate in Phase 1

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class HypeMeter extends StatelessWidget {
  const HypeMeter({required this.hypeValue, super.key});

  final double hypeValue; // 0.0–100.0

  @override
  Widget build(BuildContext context) {
    final double normalised = (hypeValue / 100.0).clamp(0.0, 1.0);
    final Color meterColor = normalised >= 0.9 ? AppColors.gold : AppColors.hype;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'HYPE',
          style: TextStyle(
            color: AppColors.grey400,
            fontSize: 10.0,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 4.0),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(4.0)),
          child: LinearProgressIndicator(
            value: normalised,
            backgroundColor: AppColors.grey800,
            valueColor: AlwaysStoppedAnimation<Color>(meterColor),
            minHeight: 6.0,
          ),
        ),
      ],
    );
  }
}
