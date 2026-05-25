// GDD §6.3 + §7.2 — Maison Hub: guild treasury, members, city dominance (Phase 7 + 8).
// Palette: Ivory (#FAF7F0) on Obsidian — exclusive high-society ledger aesthetic.
// Phase 8: CONTRIBUTE CAPITAL button → _TreasuryDonateSheet (Slider + presets).
//   Optimistic UI deduction mirrors Ledger UpgradeStore pattern.
//   Slider value is floor()-rounded to whole numbers before submission.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/providers/active_player_provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/brand.dart';
import '../../../features/hq/providers/hq_provider.dart';
import '../providers/maison_provider.dart';

class MaisonScreen extends ConsumerWidget {
  const MaisonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String uid = ref.watch(activeUidProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            // ── Header ─────────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'MAISON HUB',
                      style: TextStyle(
                        color: AppColors.ivory,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4.0,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      'GDD §6.3 — GUILD SYNDICATE SYSTEM',
                      style: TextStyle(
                        color: Color(0x4DFAF7F0), // ivory 30%
                        fontSize: 8.0,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Divider ─────────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Divider(color: Color(0x1AFAF7F0), height: 1.0),
              ),
            ),

            // ── Your Maison card ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _PlayerMaisonCard(uid: uid),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28.0)),

            // ── Trending Maisons header ──────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'TRENDING MAISONS',
                  style: TextStyle(
                    color: Color(0x4DFAF7F0), // ivory 30%
                    fontSize: 9.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3.0,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12.0)),

            // ── Trending Maisons list ────────────────────────────────────
            _TrendingMaisonSliver(),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 40.0)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Player's current Maison affiliation card — streamed from maison_members.
// ---------------------------------------------------------------------------
class _PlayerMaisonCard extends StatelessWidget {
  const _PlayerMaisonCard({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    // Stream maison_members for this player joined with maisons.
    final Stream<List<Map<String, dynamic>>> stream = SupabaseService.client
        .from(SupabaseConstants.tableMaisonMembers)
        .stream(primaryKey: <String>['maison_id', 'player_id']).eq(
      'player_id',
      uid,
    );

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
      ) {
        final bool loading =
            snapshot.connectionState == ConnectionState.waiting;
        final List<Map<String, dynamic>> rows =
            snapshot.data ?? <Map<String, dynamic>>[];
        final bool affiliated = rows.isNotEmpty;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: const Color(0x0DFAF7F0), // ivory 5%
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: affiliated
                  ? AppColors.ivory.withValues(alpha: 0.3)
                  : AppColors.ivory.withValues(alpha: 0.1),
            ),
          ),
          child: loading
              ? const Center(
                  child: SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: CircularProgressIndicator(
                      color: AppColors.ivory,
                      strokeWidth: 1.0,
                    ),
                  ),
                )
              : affiliated
                  ? _AffiliatedBody(row: rows.first)
                  : const _UnaffiliatedBody(),
        );
      },
    );
  }
}

class _AffiliatedBody extends ConsumerWidget {
  const _AffiliatedBody({required this.row});

  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String role = ((row['role'] as String?) ?? 'member').toUpperCase();
    final String maisonId = row['maison_id']?.toString() ?? '—';
    final MaisonDonateState donateState = ref.watch(maisonDonateProvider);

    // Show error SnackBar then clear state.
    ref.listen<MaisonDonateState>(
      maisonDonateProvider,
      (MaisonDonateState? prev, MaisonDonateState next) {
        if (next.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                next.errorMessage!,
                style:
                    const TextStyle(color: AppColors.ivory, letterSpacing: 1.5),
              ),
              backgroundColor: AppColors.obsidianCard,
            ),
          );
          ref.read(maisonDonateProvider.notifier).clearError();
        }
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'YOUR AFFILIATION',
          style: TextStyle(
            color: AppColors.ivory.withValues(alpha: 0.4),
            fontSize: 8.0,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          maisonId,
          style: const TextStyle(
            color: AppColors.ivory,
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          role,
          style: TextStyle(
            color: AppColors.ivory.withValues(alpha: 0.5),
            fontSize: 9.0,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 16.0),
        // ── CONTRIBUTE CAPITAL button ───────────────────────────────
        GestureDetector(
          onTap: donateState.isDonating
              ? null
              : () => showModalBottomSheet<void>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (BuildContext ctx) => const _TreasuryDonateSheet(),
                  ),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 9.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.ivory.withValues(
                  alpha: donateState.isDonating ? 0.15 : 0.35,
                ),
              ),
              borderRadius: BorderRadius.circular(2.0),
            ),
            child: donateState.isDonating
                ? const SizedBox(
                    width: 14.0,
                    height: 14.0,
                    child: CircularProgressIndicator(
                      color: AppColors.ivory,
                      strokeWidth: 1.0,
                    ),
                  )
                : Text(
                    'CONTRIBUTE CAPITAL',
                    style: TextStyle(
                      color: AppColors.ivory.withValues(alpha: 0.85),
                      fontSize: 9.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _UnaffiliatedBody extends StatelessWidget {
  const _UnaffiliatedBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'NO AFFILIATION',
          style: TextStyle(
            color: AppColors.ivory.withValues(alpha: 0.4),
            fontSize: 8.0,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 12.0),
        Text(
          'You operate independently.\nFound or join a Maison to pool capital\nand achieve global dominance.',
          style: TextStyle(
            color: AppColors.ivory.withValues(alpha: 0.6),
            fontSize: 11.0,
            height: 1.7,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 16.0),
        const Row(
          children: <Widget>[
            _IvoryButton(label: 'FOUND', onTap: null),
            SizedBox(width: 10.0),
            _IvoryButton(label: 'JOIN', onTap: null, outlined: true),
          ],
        ),
      ],
    );
  }
}

class _IvoryButton extends StatelessWidget {
  const _IvoryButton({
    required this.label,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: outlined
              ? Colors.transparent
              : AppColors.ivory.withValues(alpha: 0.08),
          border: Border.all(
            color: AppColors.ivory.withValues(alpha: outlined ? 0.25 : 0.0),
          ),
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.ivory.withValues(alpha: onTap != null ? 0.9 : 0.3),
            fontSize: 9.0,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Trending Maisons sliver — bounded list inside CustomScrollView.
// ---------------------------------------------------------------------------
class _TrendingMaisonSliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Stream<List<Map<String, dynamic>>> stream = SupabaseService.client
        .from(SupabaseConstants.tableMaisons)
        .stream(primaryKey: <String>['id']).limit(10);

    return SliverToBoxAdapter(
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: stream,
        builder: (
          BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: SizedBox(
                  width: 16.0,
                  height: 16.0,
                  child: CircularProgressIndicator(
                    color: AppColors.ivory,
                    strokeWidth: 1.0,
                  ),
                ),
              ),
            );
          }
          final List<Map<String, dynamic>> maisons =
              snapshot.data ?? <Map<String, dynamic>>[];
          if (maisons.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'NO MAISONS YET',
                style: TextStyle(
                  color: AppColors.ivory.withValues(alpha: 0.2),
                  fontSize: 10.0,
                  letterSpacing: 2.0,
                ),
              ),
            );
          }
          return Column(
            children: maisons.map((Map<String, dynamic> m) {
              final String name = (m['name'] as String?) ?? '—';
              final bool recruiting = (m['is_recruiting'] as bool?) ?? false;
              return Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 8.0),
                child: _MaisonRow(name: name, recruiting: recruiting),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _MaisonRow extends StatelessWidget {
  const _MaisonRow({required this.name, required this.recruiting});

  final String name;
  final bool recruiting;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0x0DFAF7F0),
        borderRadius: BorderRadius.circular(2.0),
        border: Border.all(color: AppColors.ivory.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              name.toUpperCase(),
              style: const TextStyle(
                color: AppColors.ivory,
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ),
          if (recruiting)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              decoration: BoxDecoration(
                border:
                    Border.all(color: AppColors.ivory.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(2.0),
              ),
              child: Text(
                'OPEN',
                style: TextStyle(
                  color: AppColors.ivory.withValues(alpha: 0.5),
                  fontSize: 7.0,
                  letterSpacing: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Treasury Donate Sheet — slide to select donation; 25/50/MAX presets.
// Slider value is floor()-rounded to whole numbers (no fractional cents).
// ---------------------------------------------------------------------------
class _TreasuryDonateSheet extends ConsumerStatefulWidget {
  const _TreasuryDonateSheet();

  @override
  ConsumerState<_TreasuryDonateSheet> createState() =>
      _TreasuryDonateSheetState();
}

class _TreasuryDonateSheetState extends ConsumerState<_TreasuryDonateSheet> {
  double _sliderValue = 0.0;

  String _formatAmount(double v) {
    if (v >= 1000000.0) {
      return '\$${(v / 1000000.0).toStringAsFixed(1)}M';
    }
    if (v >= 1000.0) {
      return '\$${(v / 1000.0).toStringAsFixed(1)}K';
    }
    return '\$${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Brand> brandAsync = ref.watch(hqBrandStreamProvider);
    final MaisonDonateState donateState = ref.watch(maisonDonateProvider);

    final double rawBalance = brandAsync.maybeWhen(
      data: (Brand b) => b.totalRevenue,
      orElse: () => 0.0,
    );
    final double displayBalance =
        (rawBalance - donateState.optimisticDeduction).clamp(0.0, rawBalance);
    final double maxSlider = displayBalance.floorToDouble();
    // Clamp slider in case optimistic deduction reduces max.
    final double clampedSlider = _sliderValue.clamp(0.0, maxSlider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.obsidianCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      padding: EdgeInsets.fromLTRB(
        24.0,
        20.0,
        24.0,
        MediaQuery.of(context).viewInsets.bottom + 32.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Sheet handle ───────────────────────────────────────────────
          Center(
            child: Container(
              width: 32.0,
              height: 3.0,
              decoration: BoxDecoration(
                color: AppColors.ivory.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          const SizedBox(height: 20.0),

          // ── Title ──────────────────────────────────────────────────────
          const Text(
            'CONTRIBUTE CAPITAL',
            style: TextStyle(
              color: AppColors.ivory,
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.5,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Available: ${_formatAmount(displayBalance)}',
            style: TextStyle(
              color: AppColors.ivory.withValues(alpha: 0.4),
              fontSize: 9.0,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24.0),

          // ── Amount display ─────────────────────────────────────────────
          Center(
            child: Text(
              _formatAmount(clampedSlider.floorToDouble()),
              style: TextStyle(
                color: clampedSlider > 0
                    ? AppColors.ivory
                    : AppColors.ivory.withValues(alpha: 0.2),
                fontSize: 32.0,
                fontWeight: FontWeight.w300,
                letterSpacing: 2.0,
              ),
            ),
          ),
          const SizedBox(height: 12.0),

          // ── Slider ─────────────────────────────────────────────────────
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.ivory.withValues(alpha: 0.6),
              inactiveTrackColor: AppColors.ivory.withValues(alpha: 0.1),
              thumbColor: AppColors.ivory,
              overlayColor: AppColors.ivory.withValues(alpha: 0.08),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
              trackHeight: 1.5,
            ),
            child: Slider(
              value: clampedSlider,
              max: maxSlider > 0 ? maxSlider : 1.0,
              // Divide into at most 1000 steps for precise but not fractal control.
              divisions: maxSlider > 0 ? (maxSlider.toInt().clamp(1, 1000)) : 1,
              onChanged: maxSlider > 0
                  ? (double v) =>
                      setState(() => _sliderValue = v.floorToDouble())
                  : null,
            ),
          ),
          const SizedBox(height: 12.0),

          // ── Quick-amount presets: 25% | 50% | MAX ─────────────────────
          Row(
            children: <Widget>[
              _PresetButton(
                label: '25%',
                onTap: maxSlider > 0
                    ? () => setState(
                          () =>
                              _sliderValue = (maxSlider * 0.25).floorToDouble(),
                        )
                    : null,
              ),
              const SizedBox(width: 8.0),
              _PresetButton(
                label: '50%',
                onTap: maxSlider > 0
                    ? () => setState(
                          () =>
                              _sliderValue = (maxSlider * 0.50).floorToDouble(),
                        )
                    : null,
              ),
              const SizedBox(width: 8.0),
              _PresetButton(
                label: 'MAX',
                onTap: maxSlider > 0
                    ? () => setState(() => _sliderValue = maxSlider)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 24.0),

          // ── Submit button ──────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: (clampedSlider > 0 && !donateState.isDonating)
                  ? () async {
                      await ref
                          .read(maisonDonateProvider.notifier)
                          .donate(clampedSlider);
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                decoration: BoxDecoration(
                  color: clampedSlider > 0
                      ? AppColors.ivory.withValues(alpha: 0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: AppColors.ivory.withValues(
                      alpha: clampedSlider > 0 ? 0.35 : 0.1,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(2.0),
                ),
                child: Center(
                  child: donateState.isDonating
                      ? const SizedBox(
                          width: 16.0,
                          height: 16.0,
                          child: CircularProgressIndicator(
                            color: AppColors.ivory,
                            strokeWidth: 1.0,
                          ),
                        )
                      : Text(
                          'CONTRIBUTE',
                          style: TextStyle(
                            color: AppColors.ivory.withValues(
                              alpha: clampedSlider > 0 ? 0.9 : 0.25,
                            ),
                            fontSize: 10.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3.0,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.ivory.withValues(alpha: enabled ? 0.2 : 0.07),
            ),
            borderRadius: BorderRadius.circular(2.0),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.ivory.withValues(alpha: enabled ? 0.6 : 0.2),
                fontSize: 9.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
