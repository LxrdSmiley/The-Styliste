// GDD §3.0 Artisan (Designer) HQ View
// Gold palette. Slots: Brand Rank bar, Hype Meter, Atelier nav hook,
// Quick Sketch button, Trend Pulse widget.
// Full implementation: Phase 2b (Designer loop).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/brand.dart';
import '../../../domain/models/player.dart';
import '../../../presentation/widgets/brand_rank_bar.dart';
import '../../../presentation/widgets/hype_meter.dart';
import '../providers/hq_provider.dart';

class HqArtisanView extends ConsumerWidget {
  const HqArtisanView({required this.player, super.key});

  final Player player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Brand> brandAsync = ref.watch(hqBrandStreamProvider);

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
                      'THE ARTISAN',
                      style: TextStyle(
                        color: AppColors.gold,
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

                    // --- Hype Meter slot (GDD §3.0 Artisan view) ---
                    brandAsync.maybeWhen(
                      data: (Brand brand) => HypeMeter(
                        hypeValue: brand.hypoScore,
                      ),
                      orElse: () => const SizedBox(height: 48.0),
                    ),

                    const Spacer(),

                    // --- Atelier nav hook (GDD §4.1) ---
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context.push(AppRouter.atelier),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.gold,
                          side: const BorderSide(color: AppColors.gold),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: const Text(
                          'ENTER ATELIER',
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
