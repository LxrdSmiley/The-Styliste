import 'package:flutter/material.dart';

import '../../../core/theme/styliste_colors.dart';
import '../../../core/theme/styliste_radii.dart';
import '../../../core/theme/styliste_spacing.dart';
import '../../../core/theme/styliste_typography.dart';
import '../models/vex_review.dart';

class VexVerdictBadge extends StatelessWidget {
  const VexVerdictBadge({
    required this.tier,
    super.key,
  });

  final VexVerdictVisualTier tier;

  @override
  Widget build(BuildContext context) {
    final Color color = _tierColor(tier);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(StylisteRadii.pill),
        border: Border.all(color: color.withValues(alpha: 0.64)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: StylisteSpacing.gutter,
          vertical: StylisteSpacing.stackSm,
        ),
        child: Text(
          tier.displayName.toUpperCase(),
          style: StylisteText.labelCaps.copyWith(color: color),
        ),
      ),
    );
  }

  static Color _tierColor(VexVerdictVisualTier tier) {
    return switch (tier) {
      VexVerdictVisualTier.quiet => StylisteColors.textSecondary,
      VexVerdictVisualTier.watched => StylisteColors.warmGrey,
      VexVerdictVisualTier.rising => StylisteColors.deepGold,
      VexVerdictVisualTier.trendSurge => StylisteColors.roseAccent,
      VexVerdictVisualTier.waveRider => StylisteColors.champagneGold,
      VexVerdictVisualTier.iconic => StylisteColors.champagneGold,
    };
  }
}
