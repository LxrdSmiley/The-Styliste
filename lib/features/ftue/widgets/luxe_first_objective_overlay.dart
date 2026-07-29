import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/styliste_colors.dart';
import '../../../core/theme/styliste_spacing.dart';
import '../../../core/theme/styliste_typography.dart';
import '../../../core/widgets/aurelian_components.dart';
import '../../../core/widgets/styliste_buttons.dart';
import '../../../domain/models/player.dart';

Future<void> showLuxeFirstObjectiveOverlay({
  required BuildContext context,
  required Player player,
}) async {
  final bool? openObjective = await showDialog<bool>(
    context: context,
    builder: (BuildContext _) => _LuxeFirstObjectiveDialog(player: player),
  );

  if (!context.mounted || openObjective != true) return;

  unawaited(context.push(AppRouter.atelierCapsule));
}

class _LuxeFirstObjectiveDialog extends StatelessWidget {
  const _LuxeFirstObjectiveDialog({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) {
    final bool isDesigner = player.path == CareerPath.designer;
    final String body = isDesigner
        ? 'Author the Collection Brief, then shape a Hero Piece, Commercial Anchor, and Experimental Piece.'
        : 'Position the Collection Brief, then shape a Hero Piece, Commercial Anchor, and Experimental Piece.';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22.0),
      child: AurelianCard(
        emphasized: true,
        padding: const EdgeInsets.all(StylisteSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'LUXE SAYS',
                    style: TextStyle(
                      fontFamily: StylisteText.displayFamily,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                      color: StylisteColors.deepGold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close Luxe guidance',
                  icon: const Icon(
                    Icons.close,
                    color: StylisteColors.textSecondary,
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            const SizedBox(height: 14.0),
            Text(
              body,
              style: StylisteText.title.copyWith(
                color: StylisteColors.textPrimary,
              ),
            ),
            const SizedBox(height: StylisteSpacing.sm),
            AurelianStatusChip(
              label: isDesigner
                  ? 'Artisan authorship · equal ceiling'
                  : 'Architect positioning · equal ceiling',
              icon: isDesigner ? Icons.draw_outlined : Icons.account_tree,
            ),
            const SizedBox(height: StylisteSpacing.lg),
            GoldPrimaryButton(
              label: 'Open capsule',
              icon: Icons.arrow_forward,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: StylisteSpacing.sm),
            IvorySecondaryButton(
              label: 'Not now',
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}
