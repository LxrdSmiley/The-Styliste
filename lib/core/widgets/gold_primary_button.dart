import 'package:flutter/material.dart';

import '../theme/styliste_colors.dart';
import '../theme/styliste_motion.dart';
import '../theme/styliste_radii.dart';
import '../theme/styliste_spacing.dart';

class GoldPrimaryButton extends StatelessWidget {
  const GoldPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;

    return AnimatedOpacity(
      duration: StylisteMotion.micro,
      curve: StylisteMotion.standardCurve,
      opacity: enabled ? 1.0 : 0.56,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: StylisteSpacing.minTapTarget,
          minWidth: StylisteSpacing.minTapTarget,
        ),
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: StylisteColors.champagneGold,
            disabledBackgroundColor: StylisteColors.alabaster,
            foregroundColor: StylisteColors.textPrimary,
            disabledForegroundColor: StylisteColors.textSecondary,
            elevation: 0.0,
            padding: const EdgeInsets.symmetric(
              horizontal: StylisteSpacing.gutter,
              vertical: 14.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(StylisteRadii.card),
            ),
            textStyle: const TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 13.0,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          child: AnimatedSwitcher(
            duration: StylisteMotion.micro,
            child: isLoading
                ? const SizedBox.square(
                    key: ValueKey<String>('gold-primary-button-loading'),
                    dimension: 18.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: StylisteColors.deepGold,
                    ),
                  )
                : _GoldPrimaryButtonLabel(
                    key: const ValueKey<String>('gold-primary-button-label'),
                    label: label,
                    icon: icon,
                  ),
          ),
        ),
      ),
    );
  }
}

class _GoldPrimaryButtonLabel extends StatelessWidget {
  const _GoldPrimaryButtonLabel({
    required this.label,
    this.icon,
    super.key,
  });

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Widget text = Text(
      label.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (icon == null) return text;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, size: 17.0),
        const SizedBox(width: StylisteSpacing.stackSm),
        Flexible(child: text),
      ],
    );
  }
}
