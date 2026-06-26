import 'package:flutter/material.dart';

import '../../../core/theme/styliste_colors.dart';
import '../../../core/theme/styliste_radii.dart';
import '../../../core/theme/styliste_spacing.dart';
import '../../../core/theme/styliste_typography.dart';
import '../../../core/widgets/styliste_buttons.dart';

class LuxeRecoveryCard extends StatelessWidget {
  const LuxeRecoveryCard({
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.title,
    this.secondaryLabel,
    this.onSecondary,
    this.isLoading = false,
    this.icon,
    super.key,
  });

  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? title;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: StylisteColors.alabaster,
        borderRadius: BorderRadius.circular(StylisteRadii.card),
        border: Border.all(
          color: StylisteColors.champagneGold.withValues(alpha: 0.34),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: StylisteColors.roseAccent.withValues(alpha: 0.18),
            blurRadius: 28.0,
            offset: const Offset(0.0, 16.0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(StylisteSpacing.safeMargin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: StylisteColors.roseAccent.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(StylisteRadii.pill),
                  ),
                  child: SizedBox.square(
                    dimension: 42.0,
                    child: Icon(
                      icon ?? Icons.auto_awesome,
                      color: StylisteColors.deepGold,
                      size: 19.0,
                    ),
                  ),
                ),
                const SizedBox(width: StylisteSpacing.stackMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        (title ?? 'Luxe Recovery').toUpperCase(),
                        style: StylisteText.labelCaps.copyWith(
                          color: StylisteColors.deepGold,
                        ),
                      ),
                      const SizedBox(height: StylisteSpacing.stackSm),
                      Text(
                        message,
                        style: StylisteText.body.copyWith(
                          color: StylisteColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: StylisteSpacing.stackLg),
            GoldPrimaryButton(
              label: primaryLabel,
              isLoading: isLoading,
              onPressed: onPrimary,
            ),
            if (secondaryLabel != null && onSecondary != null) ...<Widget>[
              const SizedBox(height: StylisteSpacing.stackSm),
              IvorySecondaryButton(
                label: secondaryLabel!,
                onPressed: onSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
