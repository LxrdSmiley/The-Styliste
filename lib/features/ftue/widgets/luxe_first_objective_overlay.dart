import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/aurelian_theme.dart';
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

  final String route =
      player.path == CareerPath.designer ? AppRouter.atelier : AppRouter.ledger;
  unawaited(context.push(route));
}

class _LuxeFirstObjectiveDialog extends StatelessWidget {
  const _LuxeFirstObjectiveDialog({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) {
    final bool isDesigner = player.path == CareerPath.designer;
    final String body = isDesigner
        ? 'Open the Atelier. Mint your first Alpha. Drop it to Feed, then return HQ.'
        : 'Open the Ledger. Launch your first store, then return HQ.';
    final String cta = isDesigner ? 'Open Atelier' : 'Open Ledger';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22.0),
        decoration: BoxDecoration(
          color: AurelianPalette.alabaster,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: AurelianPalette.champagneGold),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AurelianPalette.champagneGoldDark.withValues(alpha: 0.20),
              blurRadius: 32.0,
              offset: const Offset(0.0, 18.0),
            ),
          ],
        ),
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
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 11.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.8,
                      color: AurelianPalette.champagneGoldDark,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32.0,
                    minHeight: 32.0,
                  ),
                  icon: const Icon(
                    Icons.close,
                    size: 18.0,
                    color: AurelianPalette.textSecondary,
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            const SizedBox(height: 14.0),
            Text(
              body,
              style: const TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                height: 1.18,
                color: AurelianPalette.textPrimary,
              ),
            ),
            const SizedBox(height: 22.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AurelianPalette.textSecondary,
                      side: BorderSide(
                        color: AurelianPalette.textTertiary.withValues(
                          alpha: 0.32,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'NOT NOW',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(Icons.arrow_forward, size: 16.0),
                    label: Text(
                      cta.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AurelianPalette.champagneGold,
                      foregroundColor: AurelianPalette.textPrimary,
                      elevation: 0.0,
                      padding: const EdgeInsets.symmetric(vertical: 13.0),
                      textStyle: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
