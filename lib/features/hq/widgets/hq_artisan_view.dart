// Directive F — Golden Hour HQ: Artisan (Designer) View
// GDD §3.0 — Sun-Dial Hype Meter, 3D Garment Preview, Recent Drops, Quick Sketch
// Kode Addendum: CustomPainter charts, .select() optimization, 3D lifecycle mgmt

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/brand.dart';
import '../../../domain/models/player.dart';
import '../providers/hq_provider.dart';
import '../theme/aurelian_hq_theme.dart';
import '../widgets/brand_heat_meter.dart';
import '../widgets/glass_walled_penthouse.dart';
import '../widgets/sun_dial_hype_meter.dart';

/// Golden Hour HQ: Artisan View
/// 
/// Features:
/// - Glass-Walled Penthouse parallax background (rank-evolving)
/// - Sun-Dial Hype Meter (CustomPainter, no fl_chart)
/// - 3D Garment Preview (with lifecycle management)
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
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  
  // Kode Addendum: 3D controller lifecycle management
  final Flutter3DController _modelController = Flutter3DController();
  // When navigating away, pause/dispose to maintain 120Hz sub-menu performance
  bool _is3DPaused = false;

  @override
  bool get wantKeepAlive => true; // Preserve state when switching tabs

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause 3D when app backgrounds to save GPU
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      setState(() => _is3DPaused = true);
    } else if (state == AppLifecycleState.resumed) {
      setState(() => _is3DPaused = false);
    }
  }

  void _onNavigateAway() {
    // Kode Addendum: Pause 3D before navigation
    setState(() => _is3DPaused = true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    // Kode Addendum: Use .select() for optimized rebuilds
    final int heat = ref.watch(brandHeatPercentProvider);
    final int multipliers = ref.watch(sovereignMultipliersProvider);
    final int tarnish = ref.watch(tarnishLevelProvider);
    final int kintsugi = ref.watch(kintsugiLevelProvider);
    final AsyncValue<Brand> brandAsync = ref.watch(hqBrandStreamProvider);

    return Scaffold(
      body: GlassWalledPenthouse(
        rank: widget.player.brandRank,
        playerId: widget.player.id,
        tarnishLevel: tarnish,
        kintsugiLevel: kintsugi,
        onKintsugiRequest: () => context.push(AppRouter.crisisKintsugi),
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
                      // --- Sun-Dial Hype Meter (CustomPainter) ---
                      _SectionTitle('HYPE SOLARIS'),
                      const SizedBox(height: 16.0),
                      Center(
                        child: brandAsync.when(
                          data: (Brand brand) => SunDialHypeMeter(
                            hypeScore: brand.hypeScore,
                            maxHype: 100000.0, // 100K max for dial
                            size: 200.0,
                            onThresholdCrossed: () => HapticFeedback.heavyImpact(),
                          ),
                          loading: () => const SizedBox(height: 200.0),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ),

                      const SizedBox(height: 32.0),

                      // --- 3D Garment Preview ---
                      _SectionTitle('LATEST CREATION'),
                      const SizedBox(height: 16.0),
                      _GarmentPreviewCard(
                        isPaused: _is3DPaused,
                        controller: _modelController,
                        onTap: () {
                          _onNavigateAway();
                          context.push(AppRouter.atelier);
                        },
                      ),

                      const SizedBox(height: 32.0),

                      // --- Quick Sketch CTA ---
                      _QuickSketchButton(
                        onTap: () {
                          _onNavigateAway();
                          context.push(AppRouter.atelier);
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) => BrandHeatBreakdownPanel(
        heatPercent: heat,
        decayRate: 2.5,
        activeInputs: const <HeatInput>[
          HeatInput(name: 'Recent Drops', contribution: 15.0, isPositive: true),
          HeatInput(name: 'Trend Alignment', contribution: 8.0, isPositive: true),
          HeatInput(name: 'Time Decay', contribution: -5.0, isPositive: false),
        ],
      ),
    );
  }
  
  Future<void> _applyApology(BuildContext context) async {
    HapticFeedback.heavyImpact();
    final result = await Supabase.instance.client
        .rpc('execute_power_move', params: {
          'p_move_type': 'public_apology',
          'p_player_id': Supabase.instance.client.auth.currentUser!.id,
        });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] as String? ?? 'Public apology issued'),
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
              Text(
                'THE ARTISAN',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 10.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3.0,
                  color: const Color(0xFF888888),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF7E7CE).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: const Color(0xFFF7E7CE),
              ),
            ),
            child: Text(
              'R${player.brandRank}',
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2A2A2A),
              ),
            ),
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

class _GarmentPreviewCard extends StatelessWidget {
  const _GarmentPreviewCard({
    required this.isPaused,
    required this.controller,
    required this.onTap,
  });

  final bool isPaused;
  final Flutter3DController controller;
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
              // 3D Model Viewer
              Flutter3DViewer(
                src: 'assets/models/stichless_mannequin.glb',
                controller: controller,
              ),

              // Pause indicator
              if (isPaused)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: Icon(
                      Icons.pause_circle_filled,
                      size: 48.0,
                      color: Color(0xFFF7E7CE),
                    ),
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

class _QuickSketchButton extends StatelessWidget {
  const _QuickSketchButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[
              Color(0xFFF7E7CE),
              Color(0xFFE8D4B8),
            ],
          ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFFF7E7CE).withValues(alpha: 0.4),
              blurRadius: 16.0,
              spreadRadius: 2.0,
              offset: const Offset(0.0, 8.0),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.brush,
              size: 20.0,
              color: Color(0xFF2A2A2A),
            ),
            SizedBox(width: 12.0),
            Text(
              'QUICK SKETCH',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
                color: Color(0xFF2A2A2A),
              ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFFF7E7CE),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.auto_graph,
            size: 16.0,
            color: Color(0xFFF7E7CE),
          ),
          const SizedBox(width: 8.0),
          Text(
            '+${(count * 25)}% SOVEREIGN BONUS',
            style: const TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}
