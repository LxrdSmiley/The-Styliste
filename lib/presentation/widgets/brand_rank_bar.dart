// GDD §3.1 — Brand Rank progress bar widget (shared, both paths)
// TODO: Animate with flutter_animate in Phase 1

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'RANK $currentRank',
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
            Text(
              '${(xpProgress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(color: AppColors.grey400, fontSize: 11.0),
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(4.0)),
          child: LinearProgressIndicator(
            value: xpProgress,
            backgroundColor: AppColors.grey800,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
            minHeight: 4.0,
          ),
        ),
      ],
    );
  }
}
