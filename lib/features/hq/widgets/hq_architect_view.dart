// GDD §3.0 Architect (Mogul) HQ View
// Lime palette. Slots: Brand Rank bar, Idle Ticker, Ledger nav hook,
// Power Move buttons, Cash Flow summary.
// Full implementation: Phase 3 (Mogul loop).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/idle_engine_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/brand.dart';
import '../../../domain/models/player.dart';
import '../../../presentation/widgets/brand_rank_bar.dart';
import '../../../presentation/widgets/idle_ticker.dart';
import '../providers/hq_provider.dart';

class HqArchitectView extends ConsumerWidget {
  const HqArchitectView({required this.player, super.key});

  final Player player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Brand> brandAsync = ref.watch(hqBrandStreamProvider);
    // Watch idleEngineProvider to activate the lifecycle observer and
    // keep the periodic timer running while this view is mounted.
    ref.watch(idleEngineProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // --- Brand Rank bar (shared element, GDD §3.0) ---
            BrandRankBar(
              currentRank: player.brandRank,
              xpProgress: (player.totalXp % 1000) / 1000.0,
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // --- Path badge ---
                    const Text(
                      'THE ARCHITECT',
                      style: TextStyle(
                        color: AppColors.lime,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4.0,
                      ),
                    ),

                    const SizedBox(height: 6.0),

                    Text(
                      player.brandName,
                      style: const TextStyle(
                        color: AppColors.ivory,
                        fontSize: 28.0,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2.0,
                      ),
                    ),

                    const SizedBox(height: 40.0),

                    // --- Idle Ticker slot (GDD §3.0 Architect view) ---
                    brandAsync.maybeWhen(
                      data: (Brand brand) => IdleTicker(
                        incomePerHour: brand.idleRevenuePerHour,
                        totalRevenue: brand.totalRevenue,
                      ),
                      orElse: () => const SizedBox(height: 48.0),
                    ),

                    const Spacer(),

                    // --- Ledger nav hook (GDD §5.1) ---
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context.push(AppRouter.ledger),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.lime,
                          side: const BorderSide(color: AppColors.lime),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: const Text(
                          'OPEN LEDGER',
                          style: TextStyle(letterSpacing: 3.0),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
