import 'package:flutter/material.dart';

import '../theme/styliste_radii.dart';
import '../theme/styliste_spacing.dart';
import '../theme/styliste_visual_mode.dart';

class PillBadge extends StatelessWidget {
  const PillBadge({
    required this.label,
    this.icon,
    this.mode = StylisteVisualMode.editorialLight,
    super.key,
  });

  final String label;
  final IconData? icon;
  final StylisteVisualMode mode;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: mode.accent,
        borderRadius: BorderRadius.circular(StylisteRadii.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 7.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 13.0, color: mode.background),
              const SizedBox(width: StylisteSpacing.stackSm),
            ],
            Flexible(
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: mode.background,
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 10.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
