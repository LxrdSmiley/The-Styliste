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
          ),
          error: (_, __) => AurelianStatePanel(
            kind: AurelianStateKind.retryableError,
            title: 'House identity is temporarily unavailable',
            message:
                'No profile value was changed. Retry the owner-safe projection.',
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
        Semantics(
          header: true,
          label: '${player.brandName}. Kingston House. $lens lead lens.',
          child: AurelianCard(
            emphasized: true,
            padding: const EdgeInsets.all(StylisteSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'KINGSTON HOUSE',
                  style: StylisteText.labelCaps.copyWith(
                    color: StylisteColors.deepGold,
                  ),
                ),
                const SizedBox(height: StylisteSpacing.sm),
                Text(
                  player.brandName,
                  style: StylisteText.displayEditorial,
                ),
                const SizedBox(height: StylisteSpacing.md),
                Wrap(
                  spacing: StylisteSpacing.sm,
                  runSpacing: StylisteSpacing.sm,
                  children: <Widget>[
                    AurelianStatusChip(
                      label: '$lens lead lens',
                      icon: artisan
                          ? Icons.draw_outlined
                          : Icons.account_tree_outlined,
                    ),
                    const AurelianStatusChip(
                      label: 'Equal gameplay ceiling',
                      icon: Icons.balance_outlined,
                      tone: AurelianStatusTone.positive,
                    ),
                  ],
                ),
              ],
            ),
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
