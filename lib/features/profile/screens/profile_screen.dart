// GDD v8 §§18, 21, 22 — current House identity and deliberate Archive boundary.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/styliste_colors.dart';
import '../../../core/theme/styliste_spacing.dart';
import '../../../core/theme/styliste_typography.dart';
import '../../../core/theme/styliste_visual_mode.dart';
import '../../../core/widgets/aurelian_components.dart';
import '../../../core/widgets/styliste_buttons.dart';
import '../../../core/widgets/styliste_scaffold.dart';
import '../../../domain/models/player.dart';
import '../../hq/providers/hq_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Player> player = ref.watch(hqPlayerStreamProvider);
    return AurelianScaffold(
      mode: StylisteVisualMode.editorialLight,
      appBar: AurelianContextualAppBar(
        eyebrow: 'Kingston',
        title: 'House Identity',
        actions: <Widget>[
          IconButton(
            tooltip: 'Open settings',
            onPressed: () => context.push(AppRouter.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: AurelianResponsiveBody(
        maxWidth: 620,
        child: player.when(
          loading: () => const AurelianStatePanel(
            kind: AurelianStateKind.loading,
            title: 'Restoring your House identity',
            message: 'Reading the authenticated House projection.',
            authorityLabel: 'Authenticated owner-safe projection',
            preservationLabel: 'No House field is editable here',
            retrySafetyLabel: 'Wait for the read to finish',
          ),
          error: (_, __) => AurelianStatePanel(
            kind: AurelianStateKind.retryableError,
            title: 'House identity is temporarily unavailable',
            message:
                'No profile value was changed. Retry the owner-safe projection.',
            authorityLabel: 'Authenticated owner-safe projection',
            preservationLabel: 'Verified House identity remains unchanged',
            retrySafetyLabel: 'Safe read-only refresh',
            actionLabel: 'Retry House identity',
            onAction: () => ref.invalidate(hqPlayerStreamProvider),
          ),
          data: (Player value) => _HouseIdentity(player: value),
        ),
      ),
    );
  }
}

class _HouseIdentity extends StatelessWidget {
  const _HouseIdentity({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) {
    final bool artisan = player.path == CareerPath.designer;
    final String lens = artisan ? 'Artisan' : 'Architect';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AurelianEditorialHero(
          eyebrow: 'Verified Kingston House',
          title: player.brandName,
          detail:
              '$lens is your lead lens. It changes how Luxe frames decisions, never what your House can ultimately achieve.',
          visual: const AurelianCutLineFrame(
            padding: EdgeInsets.all(StylisteSpacing.md),
            emphasis: 0.62,
            child: _HouseFacts(),
          ),
          status: AurelianStatusChip(
            label: '$lens lead lens',
            icon: artisan ? Icons.draw_outlined : Icons.account_tree_outlined,
            tone: AurelianStatusTone.positive,
          ),
        ),
        const SizedBox(height: StylisteSpacing.lg),
        const AurelianSectionHeader(
          eyebrow: 'House code',
          title: 'Craft, sound, and resourceful ambition',
          detail:
              'Kingston is presented as a center of tailoring, music, streetwear, community validation, and global creative authority.',
        ),
        const SizedBox(height: StylisteSpacing.md),
        const AurelianCard(
          child: Column(
            children: <Widget>[
              _IdentityRow(
                icon: Icons.content_cut_outlined,
                label: 'Tailoring',
                detail: 'Construction and garment clarity',
              ),
              Divider(height: StylisteSpacing.lg),
              _IdentityRow(
                icon: Icons.graphic_eq_outlined,
                label: 'Sound and streetwear',
                detail: 'Rhythm, movement, and local relevance',
              ),
              Divider(height: StylisteSpacing.lg),
              _IdentityRow(
                icon: Icons.groups_outlined,
                label: 'Community proof',
                detail: 'Validation without caricature or shorthand',
              ),
            ],
          ),
        ),
        const SizedBox(height: StylisteSpacing.lg),
        const AurelianStatePanel(
          kind: AurelianStateKind.unavailable,
          title: 'The Archive is held',
          message:
              'Launch history, Vex records, provenance chapters, and Archive settlement remain outside Gate A.',
          authorityLabel: 'Current verified House identity only',
          preservationLabel: 'House name, city, and Founder Path',
          retrySafetyLabel: 'No Archive request is available',
          compact: true,
        ),
        const SizedBox(height: StylisteSpacing.md),
        IvorySecondaryButton(
          label: 'Open settings and legal',
          icon: Icons.settings_outlined,
          onPressed: () => context.push(AppRouter.settings),
        ),
      ],
    );
  }
}

class _HouseFacts extends StatelessWidget {
  const _HouseFacts();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool stacked = constraints.maxWidth < 300 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.3;
        const List<_HouseFact> facts = <_HouseFact>[
          _HouseFact(
            label: 'City',
            value: 'Kingston',
            icon: Icons.location_city_outlined,
          ),
          _HouseFact(
            label: 'Ceiling',
            value: 'Equal',
            icon: Icons.balance_outlined,
          ),
          _HouseFact(
            label: 'Identity',
            value: 'Verified',
            icon: Icons.verified_user_outlined,
          ),
        ];
        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (int index = 0; index < facts.length; index++) ...<Widget>[
                _HouseFact(
                  label: facts[index].label,
                  value: facts[index].value,
                  icon: facts[index].icon,
                  horizontal: true,
                ),
                if (index != facts.length - 1)
                  const SizedBox(height: StylisteSpacing.sm),
              ],
            ],
          );
        }
        return const Row(
          children: <Widget>[
            Expanded(
                child: _HouseFact(
              label: 'City',
              value: 'Kingston',
              icon: Icons.location_city_outlined,
            )),
            SizedBox(width: StylisteSpacing.sm),
            Expanded(
                child: _HouseFact(
              label: 'Ceiling',
              value: 'Equal',
              icon: Icons.balance_outlined,
            )),
            SizedBox(width: StylisteSpacing.sm),
            Expanded(
                child: _HouseFact(
              label: 'Identity',
              value: 'Verified',
              icon: Icons.verified_user_outlined,
            )),
          ],
        );
      },
    );
  }
}

class _HouseFact extends StatelessWidget {
  const _HouseFact({
    required this.label,
    required this.value,
    required this.icon,
    this.horizontal = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    if (horizontal) {
      return Semantics(
        label: '$label. $value',
        child: Row(
          children: <Widget>[
            Icon(icon, color: StylisteColors.deepGold),
            const SizedBox(width: StylisteSpacing.sm),
            Expanded(
              child: Text(
                '$label · $value',
                style: StylisteText.bodySmall,
              ),
            ),
          ],
        ),
      );
    }
    return Semantics(
      label: '$label. $value',
      child: Column(
        children: <Widget>[
          Icon(icon, color: StylisteColors.deepGold),
          const SizedBox(height: StylisteSpacing.xs),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: StylisteText.labelCaps,
          ),
          const SizedBox(height: StylisteSpacing.xxs),
          Text(
            value,
            textAlign: TextAlign.center,
            style: StylisteText.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _IdentityRow extends StatelessWidget {
  const _IdentityRow({
    required this.icon,
    required this.label,
    required this.detail,
  });

  final IconData icon;
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          icon,
          color: StylisteColors.deepGold,
          semanticLabel: label,
        ),
        const SizedBox(width: StylisteSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: StylisteText.title),
              const SizedBox(height: StylisteSpacing.xxs),
              Text(detail, style: StylisteText.body),
            ],
          ),
        ),
      ],
    );
  }
}
