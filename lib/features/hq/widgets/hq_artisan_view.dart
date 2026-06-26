// Directive F — Golden Hour HQ: Artisan (Designer) View
// GDD §3.0 — Sun-Dial Hype Meter, Native Garment Preview, Recent Drops, Quick Sketch
// Kode Addendum: CustomPainter charts, .select() optimization

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/styliste_visual_mode.dart';
import '../../../core/widgets/glass_metric_card.dart';
import '../../../core/widgets/gold_primary_button.dart';
import '../../../core/widgets/pill_badge.dart';
import '../../../core/widgets/styliste_scaffold.dart';
import '../../../domain/models/brand.dart';
import '../../../domain/models/player.dart';
import '../../ftue/widgets/first_objective_card.dart';
import '../providers/hq_provider.dart';
import '../theme/aurelian_hq_theme.dart';
import '../widgets/brand_heat_meter.dart';
import '../widgets/glass_walled_penthouse.dart';
import '../widgets/latest_alpha_drop_module.dart';
import '../widgets/sun_dial_hype_meter.dart';

/// Golden Hour HQ: Artisan View
///
/// Features:
/// - Glass-Walled Penthouse parallax background (rank-evolving)
/// - Sun-Dial Hype Meter (CustomPainter, no fl_chart)
/// - Native Garment Preview (no WebView asset dependency)
/// - Brand Heat Meter (.select() optimized)
/// - Quick Sketch CTA
/// - Recent Drops grid
class HqArtisanView extends ConsumerStatefulWidget {
  const HqArtisanView({required this.player, super.key});

  final Player player;

  @override
  ConsumerState<HqArtisanView> createState() => _HqArtisanViewState();
}

class _HqArtisanViewState extends ConsumerState<HqArtisanView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Preserve state when switching tabs

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Kode Addendum: Use .select() for optimized rebuilds
    final int heat = ref.watch(brandHeatPercentProvider);
    final int multipliers = ref.watch(sovereignMultipliersProvider);
    final int tarnish = ref.watch(tarnishLevelProvider);
    final int kintsugi = ref.watch(kintsugiLevelProvider);
    final AsyncValue<Brand> brandAsync = ref.watch(hqBrandStreamProvider);

    return StylisteScaffold(
      mode: StylisteVisualMode.editorialLight,
      useSafeArea: false,
      body: GlassWalledPenthouse(
        rank: widget.player.brandRank,
        playerId: widget.player.id,
        tarnishLevel: tarnish,
        kintsugiLevel: kintsugi,
        onKintsugiRequest: () =>
            unawaited(context.push(AppRouter.crisisKintsugi)),
        onApologyRequest: () => _applyApology(context),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              // --- Header: Brand + Rank ---
              _ArtisanHeader(player: widget.player),

              // --- Brand Heat Meter (.select() optimized) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: BrandHeatMeter(
                  heatPercent: heat.clamp(0, 100),
                  onTap: () => _showHeatBreakdown(context, heat),
                ),
              ),

              const SizedBox(height: 24.0),

              // --- Main Content ---
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FirstObjectiveCard(player: widget.player),

                      _HqMetricStrip(
                        player: widget.player,
                        brandAsync: brandAsync,
                        mode: StylisteVisualMode.editorialLight,
                      ),

                      const SizedBox(height: 32.0),

                      // --- Sun-Dial Hype Meter (CustomPainter) ---
                      const _SectionTitle('HYPE SOLARIS'),
                      const SizedBox(height: 16.0),
                      Center(
                        child: brandAsync.when(
                          data: (Brand brand) => SunDialHypeMeter(
                            hypeScore: brand.hypeScore,
                            maxHype: 100000.0, // 100K max for dial
                            onThresholdCrossed: () =>
                                HapticFeedback.heavyImpact(),
                          ),
                          loading: () => const SizedBox(height: 200.0),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ),

                      const SizedBox(height: 32.0),

                      const LatestAlphaDropModule(),

                      const SizedBox(height: 32.0),

                      // --- Native Garment Preview ---
                      const _SectionTitle('LATEST CREATION'),
                      const SizedBox(height: 16.0),
                      _GarmentPreviewCard(
                        onTap: () {
                          unawaited(context.push(AppRouter.atelier));
                        },
                      ),

                      const SizedBox(height: 32.0),

                      // --- Quick Sketch CTA ---
                      _QuickSketchButton(
                        onTap: () {
                          unawaited(context.push(AppRouter.atelier));
                        },
                      ),

                      const SizedBox(height: 32.0),

                      // --- Sovereign Multiplier Badge ---
                      if (multipliers > 0) _SovereignBadge(count: multipliers),

                      const SizedBox(height: 24.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHeatBreakdown(BuildContext context, int heat) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) => BrandHeatBreakdownPanel(
        heatPercent: heat,
        decayRate: 2.5,
        activeInputs: const <HeatInput>[
          HeatInput(name: 'Recent Drops', contribution: 15.0, isPositive: true),
          HeatInput(
            name: 'Trend Alignment',
            contribution: 8.0,
            isPositive: true,
          ),
          HeatInput(name: 'Time Decay', contribution: -5.0, isPositive: false),
        ],
      ),
    );
  }

  Future<void> _applyApology(BuildContext context) async {
    unawaited(HapticFeedback.heavyImpact());
    final Map<String, dynamic> result =
        await Supabase.instance.client.rpc<Map<String, dynamic>>(
      'execute_power_move',
      params: <String, dynamic>{
        'p_move_key': 'public_apology',
        'p_player_id': Supabase.instance.client.auth.currentUser!.id,
      },
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(result['message'] as String? ?? 'Public apology issued'),
          backgroundColor: const Color(0xFFF7E7CE),
        ),
      );
    }
  }
}

// =============================================================================
// Private Widget Components
// =============================================================================

class _ArtisanHeader extends StatelessWidget {
  const _ArtisanHeader({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) {
    final MaterialTier tier = AurelianHQTheme.materialTier(player.brandRank);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'THE ARTISAN',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 10.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3.0,
                  color: Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                player.brandName.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                  color: Color(0xFF2A2A2A),
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                tier.displayName.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 9.0,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2.0,
                  color: const Color(0xFF888888).withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          PillBadge(
            label: 'R${player.brandRank}',
            icon: Icons.workspace_premium,
          ),
        ],
      ),
    );
  }
}

class _HqMetricStrip extends StatelessWidget {
  const _HqMetricStrip({
    required this.player,
    required this.brandAsync,
    required this.mode,
  });

  final Player player;
  final AsyncValue<Brand> brandAsync;
  final StylisteVisualMode mode;

  @override
  Widget build(BuildContext context) {
    final Brand? brand = brandAsync.value;
    final bool isLoading = brandAsync.isLoading && brand == null;
    final Object? error = brandAsync.error;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: GlassMetricCard(
                label: 'Brand Rank',
                value: 'R${player.brandRank}',
                mode: mode,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: GlassMetricCard(
                label: 'Followers',
                value: _formatCompactNumber(brand?.followers ?? 0),
                mode: mode,
                isLoading: isLoading,
                error: error == null ? null : 'Followers unavailable',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        GlassMetricCard(
          label: 'Idle Revenue',
          value:
              '${_formatCompactCurrency(brand?.idleRevenuePerHour ?? 0)} / hr',
          mode: mode,
          isLoading: isLoading,
          error: error == null ? null : 'Idle revenue unavailable',
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 11.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 3.0,
        color: Color(0xFF888888),
      ),
    );
  }
}

class _GarmentPreviewCard extends StatelessWidget {
  const _GarmentPreviewCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180.0,
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F0),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: const Color(0xFFE8D4B8).withValues(alpha: 0.3),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFFF7E7CE).withValues(alpha: 0.2),
              blurRadius: 16.0,
              spreadRadius: 2.0,
              offset: const Offset(0.0, 8.0),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Stack(
            children: <Widget>[
              const Positioned.fill(
                child: CustomPaint(
                  painter: _NativeGarmentPreviewPainter(),
                ),
              ),

              // Enter Atelier prompt
              Positioned(
                bottom: 16.0,
                left: 16.0,
                right: 16.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7E7CE).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'ENTER ATELIER',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.0,
                          color: Color(0xFF2A2A2A),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Icon(
                        Icons.arrow_forward,
                        size: 16.0,
                        color: Color(0xFF2A2A2A),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NativeGarmentPreviewPainter extends CustomPainter {
  const _NativeGarmentPreviewPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;
    final Paint backdrop = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFFFEFBF5),
          Color(0xFFF3E7D2),
          Color(0xFFE9DDC8),
        ],
      ).createShader(bounds);

    canvas.drawRect(bounds, backdrop);

    final Paint haloPaint = Paint()
      ..color = const Color(0xFFF7E7CE).withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.48),
        width: size.width * 0.42,
        height: size.height * 0.64,
      ),
      haloPaint,
    );

    final Path dressPath = Path()
      ..moveTo(size.width * 0.46, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.23,
        size.width * 0.54,
        size.height * 0.18,
      )
      ..lineTo(size.width * 0.66, size.height * 0.36)
      ..quadraticBezierTo(
        size.width * 0.61,
        size.height * 0.60,
        size.width * 0.63,
        size.height * 0.82,
      )
      ..lineTo(size.width * 0.37, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.39,
        size.height * 0.60,
        size.width * 0.34,
        size.height * 0.36,
      )
      ..close();

    final Paint dressFill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFFFFFFFF),
          Color(0xFFF7E7CE),
          Color(0xFFE8D4B8),
        ],
      ).createShader(bounds)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dressPath, dressFill);

    final Paint outlinePaint = Paint()
      ..color = const Color(0xFF2A2A2A).withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(dressPath, outlinePaint);

    final Paint highlightPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final Path highlightPath = Path()
      ..moveTo(size.width * 0.43, size.height * 0.34)
      ..quadraticBezierTo(
        size.width * 0.51,
        size.height * 0.52,
        size.width * 0.57,
        size.height * 0.72,
      );
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _NativeGarmentPreviewPainter oldDelegate) {
    return false;
  }
}

class _QuickSketchButton extends StatelessWidget {
  const _QuickSketchButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GoldPrimaryButton(
        label: 'Quick Sketch',
        icon: Icons.brush,
        onPressed: onTap,
      ),
    );
  }
}

class _SovereignBadge extends StatelessWidget {
  const _SovereignBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PillBadge(
        label: '+${(count * 25)}% Sovereign Bonus',
        icon: Icons.auto_graph,
      ),
    );
  }
}

String _formatCompactNumber(num value) {
  final double absValue = value.abs().toDouble();
  final String sign = value < 0 ? '-' : '';
  final String suffix;
  final double displayValue;

  if (absValue >= 1000000000.0) {
    suffix = 'B';
    displayValue = absValue / 1000000000.0;
  } else if (absValue >= 1000000.0) {
    suffix = 'M';
    displayValue = absValue / 1000000.0;
  } else if (absValue >= 1000.0) {
    suffix = 'K';
    displayValue = absValue / 1000.0;
  } else {
    suffix = '';
    displayValue = absValue;
  }

  final int decimals = displayValue >= 100.0 || suffix.isEmpty ? 0 : 1;
  return '$sign${displayValue.toStringAsFixed(decimals)}$suffix';
}

String _formatCompactCurrency(num value) {
  return '\$${_formatCompactNumber(value)}';
}
