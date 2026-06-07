import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/aurelian_theme.dart';
import '../../../domain/models/player.dart';
import '../providers/first_objective_provider.dart';

class FirstObjectiveCard extends ConsumerWidget {
  const FirstObjectiveCard({required this.player, super.key});

  final Player player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<FirstObjectiveState> objectiveAsync =
        ref.watch(firstObjectiveProvider(player));

    return objectiveAsync.maybeWhen(
      data: (FirstObjectiveState objective) {
        if (objective.isComplete) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: _FirstObjectiveCardContent(objective: objective),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _FirstObjectiveCardContent extends StatelessWidget {
  const _FirstObjectiveCardContent({required this.objective});

  final FirstObjectiveState objective;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AurelianPalette.alabaster,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: AurelianPalette.champagneGold.withValues(alpha: 0.52),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AurelianPalette.champagneGoldDark.withValues(alpha: 0.10),
            blurRadius: 18.0,
            offset: const Offset(0.0, 8.0),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        'FIRST OBJECTIVE',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 10.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                          color: AurelianPalette.textTertiary,
                        ),
                      ),
                    ),
                    Text(
                      objective.progressLabel,
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w800,
                        color: AurelianPalette.champagneGoldDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Text(
                  objective.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 15.0,
                    fontWeight: FontWeight.w800,
                    color: AurelianPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  objective.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                    color: AurelianPalette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          SizedBox(
            height: 38.0,
            child: ElevatedButton.icon(
              onPressed: () => _openObjectiveRoute(context, objective.ctaRoute),
              icon: const Icon(Icons.arrow_forward, size: 15.0),
              label: Text(
                objective.ctaLabel.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AurelianPalette.champagneGold,
                foregroundColor: AurelianPalette.textPrimary,
                elevation: 0.0,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                textStyle: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 10.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _openObjectiveRoute(BuildContext context, String route) {
  if (route == AppRouter.feed || route == AppRouter.hq) {
    context.go(route);
    return;
  }

  unawaited(context.push(route));
}
