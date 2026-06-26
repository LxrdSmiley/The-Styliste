import 'package:flutter/material.dart';

import '../../../core/theme/styliste_colors.dart';
import '../../../core/theme/styliste_radii.dart';
import '../../../core/theme/styliste_spacing.dart';
import '../../../core/theme/styliste_typography.dart';
import '../../../core/widgets/styliste_buttons.dart';

class FaceVexPanel extends StatelessWidget {
  const FaceVexPanel({
    required this.vexOptedIn,
    required this.onFaceVex,
    required this.onDropWithoutCritique,
    super.key,
  });

  final bool vexOptedIn;
  final VoidCallback onFaceVex;
  final VoidCallback onDropWithoutCritique;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: StylisteColors.surfaceNoir,
        borderRadius: BorderRadius.circular(StylisteRadii.card),
        border: Border.all(
          color: StylisteColors.champagneGold.withValues(alpha: 0.36),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: StylisteColors.obsidian.withValues(alpha: 0.22),
            blurRadius: 24.0,
            offset: const Offset(0.0, 14.0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(StylisteSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: StylisteColors.champagneGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(StylisteRadii.pill),
                  ),
                  child: const SizedBox.square(
                    dimension: 44.0,
                    child: Icon(
                      Icons.visibility_outlined,
                      color: StylisteColors.champagneGold,
                      size: 22.0,
                    ),
                  ),
                ),
                const SizedBox(width: StylisteSpacing.stackMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'FACE VEX',
                        style: StylisteText.headline.copyWith(
                          color: StylisteColors.ivory,
                        ),
                      ),
                      const SizedBox(height: StylisteSpacing.stackSm),
                      Text(
                        'Let the critic frame your drop before the Feed sees it.',
                        style: StylisteText.body.copyWith(
                          color: StylisteColors.ivory.withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: StylisteSpacing.stackMd),
            Text(
              vexOptedIn
                  ? 'VEX WILL FRAME THIS DROP'
                  : 'DROP WILL SKIP CRITIQUE',
              style: StylisteText.labelCaps.copyWith(
                color: vexOptedIn
                    ? StylisteColors.champagneGold
                    : StylisteColors.roseAccent,
              ),
            ),
            const SizedBox(height: StylisteSpacing.stackMd),
            GoldPrimaryButton(
              label: 'FACE VEX',
              icon: vexOptedIn ? Icons.check : Icons.visibility_outlined,
              onPressed: onFaceVex,
            ),
            const SizedBox(height: StylisteSpacing.stackSm),
            IvorySecondaryButton(
              label: 'DROP WITHOUT CRITIQUE',
              icon: Icons.close,
              onPressed: onDropWithoutCritique,
            ),
          ],
        ),
      ),
    );
  }
}
