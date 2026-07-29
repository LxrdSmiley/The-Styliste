import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/styliste_spacing.dart';
import '../../../core/theme/styliste_typography.dart';
import '../../../core/theme/styliste_visual_mode.dart';
import '../../../core/widgets/aurelian_components.dart';
import '../../../core/widgets/glass_metric_card.dart';
import '../../../core/widgets/styliste_buttons.dart';
import '../../../core/widgets/styliste_scaffold.dart';
import '../../../domain/models/brand.dart';
import '../../../domain/models/player.dart';
import '../../ftue/widgets/first_objective_card.dart';
import '../providers/hq_provider.dart';

class HqFoundationView extends ConsumerWidget {
  const HqFoundationView({
    required this.player,
    required this.mode,
    required this.lens,
    required this.lensDetail,
    super.key,
  });

  final Player player;
  final StylisteVisualMode mode;
  final String lens;
  final String lensDetail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Brand> brand = ref.watch(hqBrandStreamProvider);
    return AurelianScaffold(
      mode: mode,
      body: AurelianResponsiveBody(
        maxWidth: 680,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _HouseHeader(
              player: player,
              lens: lens,
              detail: lensDetail,
              mode: mode,
            ),
            const SizedBox(height: StylisteSpacing.lg),
            FirstObjectiveCard(player: player),
            _HqGarmentSignal(mode: mode, lens: lens),
            const SizedBox(height: StylisteSpacing.lg),
            AurelianEvidenceBand(
              label: 'Recent confirmed evidence',
              value: 'Founder Trial recorded',
              detail:
                  '${player.brandName} is established in Kingston with the ${lens.toLowerCase()} lead lens. No reward or market result is implied.',
              icon: Icons.receipt_long_outlined,
              tone: AurelianStatusTone.positive,
            ),
            const SizedBox(height: StylisteSpacing.lg),
            const AurelianSectionHeader(
              eyebrow: 'House pulse',
              title: 'A visual read of server-owned state',
              detail:
                  'These values are projections only. This screen cannot mutate Hype, rank, audience, rewards, or balances.',
            ),
            const SizedBox(height: StylisteSpacing.md),
            _HouseMetrics(brand: brand, player: player, mode: mode),
            const SizedBox(height: StylisteSpacing.lg),
            LuxeGuidanceCard(
              mode: mode,
              message:
                  'Build the three-look Kingston capsule first. Sampling, launch, Vex results, and rewards remain behind later gates.',
            ),
            const SizedBox(height: StylisteSpacing.sm),
            IvorySecondaryButton(
              label: 'Enter Atelier',
              icon: Icons.design_services_outlined,
              onPressed: () => context.go(AppRouter.atelier),
            ),
            const SizedBox(height: StylisteSpacing.md),
            const AurelianStatePanel(
              kind: AurelianStateKind.unavailable,
              title: 'Launch outcomes are held',
              message:
                  'No drop, Vex review, territory, Gala, contract, or reward action is reachable from HQ in Gate A.',
              authorityLabel: 'Gate A feature registry',
              preservationLabel:
                  'Your House, capsule draft, and confirmed receipts remain available.',
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _HouseHeader extends StatelessWidget {
  const _HouseHeader({
    required this.player,
    required this.lens,
    required this.detail,
    required this.mode,
  });

  final Player player;
  final String lens;
  final String detail;
  final StylisteVisualMode mode;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label:
          '${player.brandName}. Kingston House. $lens lens. Equal gameplay ceiling.',
      child: AurelianCard(
        emphasized: true,
        padding: const EdgeInsets.all(StylisteSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'KINGSTON • $lens'.toUpperCase(),
                        style: StylisteText.labelCaps.copyWith(
                          color: mode.accent,
                        ),
                      ),
                      const SizedBox(height: StylisteSpacing.xs),
                      Text(
                        player.brandName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: StylisteText.displayEditorial.copyWith(
                          color: mode.text,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: StylisteSpacing.sm),
                AurelianStatusChip(
                  label: 'Rank ${player.brandRank}',
                  icon: Icons.workspace_premium_outlined,
                ),
              ],
            ),
            const SizedBox(height: StylisteSpacing.md),
            Text(
              detail,
              style: StylisteText.body.copyWith(color: mode.secondaryText),
            ),
            const SizedBox(height: StylisteSpacing.sm),
            const AurelianStatusChip(
              label: 'Equal gameplay ceiling',
              icon: Icons.balance_outlined,
              tone: AurelianStatusTone.positive,
            ),
          ],
        ),
      ),
    );
  }
}

class _HouseMetrics extends StatelessWidget {
  const _HouseMetrics({
    required this.brand,
    required this.player,
    required this.mode,
  });

  final AsyncValue<Brand> brand;
  final Player player;
  final StylisteVisualMode mode;

  @override
  Widget build(BuildContext context) {
    final Brand? value = brand.asData?.value;
    final List<Widget> cards = <Widget>[
      GlassMetricCard(
        label: 'Brand rank',
        value: 'R${player.brandRank}',
        mode: mode,
      ),
      GlassMetricCard(
        label: 'House heat',
        value: value == null ? '—' : '${value.heat}',
        mode: mode,
        isLoading: brand.isLoading && value == null,
        error: brand.hasError ? 'Projection unavailable' : null,
      ),
      GlassMetricCard(
        label: 'Audience',
        value: value == null ? '—' : _compact(value.followers),
        mode: mode,
        isLoading: brand.isLoading && value == null,
        error: brand.hasError ? 'Projection unavailable' : null,
      ),
      GlassMetricCard(
        label: 'Hype',
        value: value == null ? '—' : _compact(value.hypeScore.round()),
        mode: mode,
        isLoading: brand.isLoading && value == null,
        error: brand.hasError ? 'Projection unavailable' : null,
      ),
    ];
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool twoColumns = constraints.maxWidth >= 360;
        final double cardWidth = twoColumns
            ? (constraints.maxWidth - StylisteSpacing.sm) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: StylisteSpacing.sm,
          runSpacing: StylisteSpacing.sm,
          children: cards
              .map(
                (Widget card) => SizedBox(width: cardWidth, child: card),
              )
              .toList(growable: false),
        );
      },
    );
  }

  String _compact(num value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }
}

class _HqGarmentSignal extends StatelessWidget {
  const _HqGarmentSignal({required this.mode, required this.lens});

  final StylisteVisualMode mode;
  final String lens;

  @override
  Widget build(BuildContext context) {
    return AurelianCard(
      semanticLabel:
          '$lens House signal. Garment drafting linework with Kingston studio rhythm.',
      child: SizedBox(
        height: 240,
        child: CustomPaint(
          painter: _HqGarmentPainter(mode: mode),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(StylisteSpacing.md),
              child: Text(
                'TAILORING • SOUND • STREETWEAR • COMMUNITY',
                style: StylisteText.labelCaps.copyWith(color: mode.accent),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HqGarmentPainter extends CustomPainter {
  const _HqGarmentPainter({required this.mode});

  final StylisteVisualMode mode;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint grid = Paint()
      ..color = mode.accent.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (double x = 24; x < size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    final Paint outline = Paint()
      ..color = mode.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final Offset center = Offset(size.width * 0.55, size.height * 0.42);
    final Path garment = Path()
      ..moveTo(center.dx - 22, center.dy - 76)
      ..quadraticBezierTo(
          center.dx, center.dy - 92, center.dx + 22, center.dy - 76)
      ..lineTo(center.dx + 72, center.dy - 36)
      ..lineTo(center.dx + 48, center.dy)
      ..lineTo(center.dx + 68, center.dy + 74)
      ..lineTo(center.dx - 68, center.dy + 74)
      ..lineTo(center.dx - 48, center.dy)
      ..lineTo(center.dx - 72, center.dy - 36)
      ..close();
    canvas.drawPath(garment, outline);
    canvas.drawLine(
      Offset(center.dx, center.dy - 84),
      Offset(center.dx, center.dy + 74),
      grid,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.7,
        height: size.height * 0.7,
      ),
      -0.7,
      1.4,
      false,
      grid,
    );
  }

  @override
  bool shouldRepaint(covariant _HqGarmentPainter oldDelegate) {
    return oldDelegate.mode != mode;
  }
}
