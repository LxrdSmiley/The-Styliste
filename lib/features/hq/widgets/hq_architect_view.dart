// Directive F — Golden Hour HQ: Architect (Mogul) View
// GDD §3.0 — Empire Pulse Graph, Power Move Slots, Territory Heatmap
// Kode Addendum: CustomPainter charts, .select() optimization, no fl_chart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/idle_engine_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/styliste_visual_mode.dart';
import '../../../core/widgets/glass_metric_card.dart';
import '../../../core/widgets/gold_primary_button.dart';
import '../../../core/widgets/pill_badge.dart';
import '../../../core/widgets/styliste_scaffold.dart';
import '../../../domain/models/brand.dart';
import '../../../domain/models/player.dart';
import '../../ftue/widgets/first_objective_card.dart';
import '../../supply_chain/models/supply_chain_models.dart';
import '../../supply_chain/providers/supply_chain_provider.dart';
import '../../supply_chain/widgets/buffer_stock_monitor.dart';
import '../providers/hq_provider.dart';
import '../theme/aurelian_hq_theme.dart';
import '../widgets/brand_heat_meter.dart';
import '../widgets/empire_pulse_painter.dart';
import '../widgets/glass_walled_penthouse.dart';
import '../widgets/latest_alpha_drop_module.dart';

/// Golden Hour HQ: Architect View
///
/// Features:
/// - Glass-Walled Penthouse parallax background
/// - Empire Pulse Graph (CustomPainter cubic bezier, no fl_chart)
/// - Power Move Slots (3 contextual actions)
/// - Cash Flow Ribbon
/// - Brand Heat Meter (.select() optimized)
/// - Territory heatmap preview
class HqArchitectView extends ConsumerStatefulWidget {
  const HqArchitectView({required this.player, super.key});

  final Player player;

  @override
  ConsumerState<HqArchitectView> createState() => _HqArchitectViewState();
}

class _HqArchitectViewState extends ConsumerState<HqArchitectView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Activate idle engine lifecycle observer
    ref.read(idleEngineProvider);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Kode Addendum: Use .select() for optimized rebuilds
    final int heat = ref.watch(brandHeatPercentProvider);
    final int multipliers = ref.watch(sovereignMultipliersProvider);
    final int idleIncomeTick = ref.watch(idleIncomeTickerProvider);
    final int tarnish = ref.watch(tarnishLevelProvider);
    final int kintsugi = ref.watch(kintsugiLevelProvider);
    final AsyncValue<Brand> brandAsync = ref.watch(hqBrandStreamProvider);
    // Directive L: Supply Chain monitoring
    final AsyncValue<SupplyChainState> supplyChainAsync =
        ref.watch(supplyChainProvider);

    return StylisteScaffold(
      mode: StylisteVisualMode.executiveObsidian,
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
              // --- Header ---
              _ArchitectHeader(player: widget.player),

              // --- Brand Heat Meter ---
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

                      const SizedBox(height: 16.0),
                      _HqMetricStrip(
                        player: widget.player,
                        brandAsync: brandAsync,
                        idleIncomeTick: idleIncomeTick,
                        mode: StylisteVisualMode.executiveObsidian,
                      ),

                      const SizedBox(height: 32.0),

                      // --- Empire Pulse Graph (CustomPainter) ---
                      const _SectionTitle('EMPIRE PULSE'),
                      const SizedBox(height: 16.0),
                      _EmpirePulseCard(
                        brandAsync: brandAsync,
                        onTap: () => unawaited(context.push(AppRouter.ledger)),
                      ),

                      const SizedBox(height: 32.0),

                      const LatestAlphaDropModule(
                        mode: StylisteVisualMode.executiveObsidian,
                      ),

                      const SizedBox(height: 32.0),

                      // --- Buffer Stock Monitor (Directive L) ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const _SectionTitle('BUFFER STOCK'),
                          // Logistics upgrade button
                          supplyChainAsync.when(
                            data: (SupplyChainState state) => InkWell(
                              borderRadius: BorderRadius.circular(999.0),
                              onTap: () =>
                                  _showLogisticsUpgrade(context, state),
                              child: PillBadge(
                                label: 'LV.${state.logisticsLevel}',
                                icon: Icons.upgrade,
                                mode: StylisteVisualMode.executiveObsidian,
                              ),
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      const BufferStockMonitor(),

                      const SizedBox(height: 32.0),

                      // --- Power Move Slots ---
                      const _SectionTitle('POWER MOVES'),
                      const SizedBox(height: 16.0),
                      _PowerMovesGrid(
                        onPublicApology: () =>
                            unawaited(_applyApology(context)),
                      ),

                      const SizedBox(height: 32.0),

                      // --- Territory Preview ---
                      const _SectionTitle('TERRITORY'),
                      const SizedBox(height: 16.0),
                      _TerritoryPreviewCard(
                        onTap: () =>
                            unawaited(context.push(AppRouter.districtMap)),
                      ),

                      const SizedBox(height: 32.0),

                      // --- Sovereign Badge ---
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
          HeatInput(
            name: 'District Control',
            contribution: 12.0,
            isPositive: true,
          ),
          HeatInput(name: 'Revenue Flow', contribution: 10.0, isPositive: true),
          HeatInput(
            name: 'Market Saturation',
            contribution: -3.0,
            isPositive: false,
          ),
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

  void _showLogisticsUpgrade(BuildContext context, SupplyChainState state) {
    final int upgradeCost =
        SupplyChainState.calculateUpgradeCost(state.logisticsLevel);
    final int newCapacity =
        SupplyChainState.calculateNewCapacity(state.warehouseCapacity);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext ctx) => Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'UPGRADE LOGISTICS',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _upgradeInfoItem('Current Level', 'LV.${state.logisticsLevel}'),
                const Icon(Icons.arrow_forward, size: 16.0),
                _upgradeInfoItem('New Level', 'LV.${state.logisticsLevel + 1}'),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _upgradeInfoItem(
                  'Current Capacity',
                  '${state.warehouseCapacity}',
                ),
                const Icon(Icons.arrow_forward, size: 16.0),
                _upgradeInfoItem('New Capacity', '$newCapacity'),
              ],
            ),
            const SizedBox(height: 24.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF7E7CE).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'UPGRADE COST',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '\$$upgradeCost',
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            GoldPrimaryButton(
              label: 'Confirm Upgrade',
              onPressed: () {
                ref.read(logisticsUpgradeProvider.notifier).upgrade();
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _upgradeInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 10.0,
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _HqMetricStrip extends StatefulWidget {
  const _HqMetricStrip({
    required this.player,
    required this.brandAsync,
    required this.idleIncomeTick,
    required this.mode,
  });

  final Player player;
  final AsyncValue<Brand> brandAsync;
  final int idleIncomeTick;
  final StylisteVisualMode mode;

  @override
  State<_HqMetricStrip> createState() => _HqMetricStripState();
}

class _HqMetricStripState extends State<_HqMetricStrip> {
  Timer? _pulseTimer;
  int _pulseTick = 0;

  @override
  void initState() {
    super.initState();
    _pulseTimer = Timer.periodic(
      const Duration(seconds: 2),
      (Timer timer) {
        if (!mounted) return;
        setState(() {
          _pulseTick++;
        });
      },
    );
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Brand? brand = widget.brandAsync.value;
    final bool isLoading = widget.brandAsync.isLoading && brand == null;
    final Object? error = widget.brandAsync.error;
    final double incomePerHour = brand?.idleRevenuePerHour ?? 0.0;
    final double totalRevenue = brand?.totalRevenue ?? 0.0;
    final bool hasRevenue = incomePerHour > 0.0;
    final double incomePerSecond = incomePerHour / 3600.0;
    final String pulseStatus = hasRevenue && _pulseTick.isEven
        ? '+${_formatCompactCurrency(incomePerSecond)} / sec'
        : hasRevenue
            ? 'Empire still earning'
            : 'No active revenue stream yet';

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: GlassMetricCard(
                label: 'Capital',
                value: _formatCompactCurrency(totalRevenue),
                mode: widget.mode,
                isLoading: isLoading,
                error: error == null ? null : 'Capital unavailable',
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: GlassMetricCard(
                label: 'Idle Revenue',
                value: '${_formatCompactCurrency(incomePerHour)} / hr',
                delta: pulseStatus,
                mode: widget.mode,
                isLoading: isLoading,
                error: error == null ? null : 'Idle revenue unavailable',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        Row(
          children: <Widget>[
            Expanded(
              child: GlassMetricCard(
                label: 'Brand Rank',
                value: 'R${widget.player.brandRank}',
                mode: widget.mode,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: GlassMetricCard(
                label: 'Followers',
                value: _formatCompactNumber(brand?.followers ?? 0),
                mode: widget.mode,
                isLoading: isLoading,
                error: error == null ? null : 'Followers unavailable',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String _formatCompactCurrency(double value) {
  final double absValue = value.abs();
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

  final int decimals = displayValue >= 100.0
      ? 0
      : displayValue >= 10.0
          ? 1
          : 2;

  return '$sign\$${displayValue.toStringAsFixed(decimals)}$suffix';
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

// =============================================================================
// Private Widget Components
// =============================================================================

class _ArchitectHeader extends StatelessWidget {
  const _ArchitectHeader({required this.player});

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
                'THE ARCHITECT',
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
            mode: StylisteVisualMode.executiveObsidian,
          ),
        ],
      ),
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

class _EmpirePulseCard extends StatelessWidget {
  const _EmpirePulseCard({
    required this.brandAsync,
    required this.onTap,
  });

  final AsyncValue<Brand> brandAsync;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Recent 7-day pulse data
    final List<double> pulseData = <double>[
      12500.0,
      13200.0,
      14800.0,
      14100.0,
      15900.0,
      17200.0,
      18500.0,
    ];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140.0,
        padding: const EdgeInsets.all(16.0),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  '7-DAY REVENUE',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 9.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.0,
                    color: Color(0xFF888888),
                  ),
                ),
                brandAsync.when(
                  data: (Brand brand) => Text(
                    '\$${(brand.totalRevenue / 1000).toStringAsFixed(1)}K',
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2A2A2A),
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Expanded(
              child: EmpirePulseGraph(
                dataPoints: pulseData,
                height: 80.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PowerMovesGrid extends StatelessWidget {
  const _PowerMovesGrid({
    required this.onPublicApology,
  });

  final VoidCallback onPublicApology;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GoldPrimaryButton(
        label: 'PUBLIC APOLOGY',
        icon: Icons.campaign,
        onPressed: onPublicApology,
      ),
    );
  }
}

class _TerritoryPreviewCard extends StatelessWidget {
  const _TerritoryPreviewCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100.0,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F0),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: const Color(0xFFE8D4B8).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: <Widget>[
            // Mini heatmap visualization
            Container(
              width: 60.0,
              height: 60.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF7E7CE).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Center(
                child: Icon(
                  Icons.location_city,
                  size: 32.0,
                  color: Color(0xFFE8D4B8),
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'DISTRICT CONTROL',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                      color: Color(0xFF888888),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  const Text(
                    '0 of 9 districts controlled',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2A2A2A),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Tap to expand empire',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 10.0,
                      color: const Color(0xFF888888).withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16.0,
              color: Color(0xFF888888),
            ),
          ],
        ),
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
        mode: StylisteVisualMode.executiveObsidian,
      ),
    );
  }
}
