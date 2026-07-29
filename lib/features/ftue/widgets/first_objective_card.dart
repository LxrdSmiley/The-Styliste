import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/styliste_colors.dart';
import '../../../core/theme/styliste_spacing.dart';
import '../../../core/theme/styliste_typography.dart';
import '../../../core/widgets/aurelian_components.dart';
import '../../../core/widgets/styliste_buttons.dart';
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
        return Padding(
          padding: const EdgeInsets.only(bottom: StylisteSpacing.lg),
          child: _FirstObjectiveCardContent(objective: objective),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: StylisteSpacing.lg),
        child: AurelianStatePanel(
          kind: AurelianStateKind.loading,
          title: 'Reading the Kingston capsule',
          message: 'Restoring the current server-confirmed objective.',
          authorityLabel: 'Authenticated House projection',
        ),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: StylisteSpacing.lg),
        child: AurelianStatePanel(
          kind: AurelianStateKind.retryableError,
          title: 'The next objective is temporarily unavailable',
          message: 'Your House and capsule records have not been changed.',
          preservationLabel: 'All confirmed House progress',
          retrySafetyLabel: 'Reloads the projection without submitting intent.',
          actionLabel: 'Retry objective',
          onAction: () => ref.invalidate(firstObjectiveProvider(player)),
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _FirstObjectiveCardContent extends StatelessWidget {
  const _FirstObjectiveCardContent({required this.objective});

  final FirstObjectiveState objective;

  @override
  Widget build(BuildContext context) {
    return AurelianCard(
      semanticLabel:
          'First objective. ${objective.title}. ${objective.progressLabel}.',
      emphasized: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'FIRST OBJECTIVE',
                  style: StylisteText.labelCaps.copyWith(
                    color: StylisteColors.deepGold,
                  ),
                ),
              ),
              const SizedBox(width: StylisteSpacing.sm),
              Text(
                objective.progressLabel,
                style: StylisteText.metricSmall.copyWith(
                  color: StylisteColors.deepGold,
                ),
              ),
            ],
          ),
          if (objective.isComplete) ...<Widget>[
            const SizedBox(height: StylisteSpacing.sm),
            const Align(
              alignment: Alignment.centerLeft,
              child: AurelianStatusChip(
                label: 'Server-confirmed readiness',
                icon: Icons.verified_outlined,
                tone: AurelianStatusTone.positive,
              ),
            ),
          ],
          const SizedBox(height: StylisteSpacing.sm),
          Text(objective.title, style: StylisteText.title),
          const SizedBox(height: StylisteSpacing.xs),
          Text(objective.description, style: StylisteText.body),
          const SizedBox(height: StylisteSpacing.md),
          GoldPrimaryButton(
            label: objective.ctaLabel,
            icon: Icons.arrow_forward,
            onPressed: () => _openObjectiveRoute(context, objective.ctaRoute),
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
