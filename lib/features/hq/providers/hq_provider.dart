// GDD §3.0 — HQ Riverpod providers: stream Player and Brand state
// PROJECT_RULES §3 — Server is source of truth; client reads via real-time streams.
// Both providers derive their UID from activeUidProvider (real Firebase UID post-Phase 2).

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/mock_auth_provider.dart';
import '../../../data/repositories/supabase_economy_repository.dart';
import '../../../data/repositories/supabase_player_repository.dart';
import '../../../domain/models/brand.dart';
import '../../../domain/models/player.dart';

/// Streams the authenticated player's Player row from Supabase.
/// Rebuilds HQ when brand_rank, xp, or onboarding_complete changes.
final StreamProvider<Player> hqPlayerStreamProvider =
    StreamProvider<Player>((Ref<AsyncValue<Player>> ref) {
  final String uid = ref.watch(activeUidProvider);
  // Guard: if uid is empty the auth gate hasn't resolved yet — emit nothing.
  if (uid.isEmpty) return const Stream<Player>.empty();

  return const SupabasePlayerRepository().watchPlayer(uid);
});

/// Streams the authenticated player's Brand (brand_state) row from Supabase.
/// Real-time updates drive the HQ idle ticker and heat display.
final StreamProvider<Brand> hqBrandStreamProvider =
    StreamProvider<Brand>((Ref<AsyncValue<Brand>> ref) {
  final String uid = ref.watch(activeUidProvider);
  if (uid.isEmpty) return const Stream<Brand>.empty();

  return const SupabaseEconomyRepository().watchBrandState(uid);
});

// =============================================================================
// Optimized .select() providers — Kode Addendum: Aggressive Riverpod optimization
// Only rebuild when explicit data points change, not on every engine tick
// =============================================================================

/// Brand heat percent only — for BrandHeatMeter widget
/// Rebuilds only when heat integer changes (not on every decimal tick)
final Provider<AsyncValue<int>> brandHeatPercentProvider =
    Provider<AsyncValue<int>>((Ref<AsyncValue<int>> ref) {
  final AsyncValue<Brand> brandAsync = ref.watch(
    hqBrandStreamProvider.select((AsyncValue<Brand> async) {
      return async.when(
        data: (Brand brand) => AsyncValue.data(brand.hypeScore.toInt()),
        loading: () => const AsyncValue.loading(),
        error: (Object e, StackTrace s) => AsyncValue.error(e, s),
      );
    }),
  );
  return brandAsync;
});

/// Sovereign multipliers only — for bonus calculation
final Provider<AsyncValue<int>> sovereignMultipliersProvider =
    Provider<AsyncValue<int>>((Ref<AsyncValue<int>> ref) {
  final AsyncValue<Player> playerAsync = ref.watch(
    hqPlayerStreamProvider.select((AsyncValue<Player> async) {
      return async.when(
        data: (Player player) => AsyncValue.data(player.sovereignMultipliers),
        loading: () => const AsyncValue.loading(),
        error: (Object e, StackTrace s) => AsyncValue.error(e, s),
      );
    }),
  );
  return playerAsync;
});

/// Career path only — for view switching (Artisan vs Architect)
final Provider<AsyncValue<CareerPath>> careerPathProvider =
    Provider<AsyncValue<CareerPath>>((Ref<AsyncValue<CareerPath>> ref) {
  final AsyncValue<Player> playerAsync = ref.watch(
    hqPlayerStreamProvider.select((AsyncValue<Player> async) {
      return async.when(
        data: (Player player) => AsyncValue.data(player.path),
        loading: () => const AsyncValue.loading(),
        error: (Object e, StackTrace s) => AsyncValue.error(e, s),
      );
    }),
  );
  return playerAsync;
});

/// Joint venture status only — for Command Floor unlock
final Provider<AsyncValue<bool>> jointVentureUnlockedProvider =
    Provider<AsyncValue<bool>>((Ref<AsyncValue<bool>> ref) {
  final AsyncValue<Player> playerAsync = ref.watch(
    hqPlayerStreamProvider.select((AsyncValue<Player> async) {
      return async.when(
        data: (Player player) => AsyncValue.data(player.isJointVenture),
        loading: () => const AsyncValue.loading(),
        error: (Object e, StackTrace s) => AsyncValue.error(e, s),
      );
    }),
  );
  return playerAsync;
});

/// Idle income ticker — optimized for cash flow ribbon
/// Only updates when integer dollar amount changes (not every cent tick)
/// Kode Addendum #2: Returns 0 when in lockdown (tarnish >= 100)
final Provider<AsyncValue<int>> idleIncomeTickerProvider =
    Provider<AsyncValue<int>>((Ref<AsyncValue<int>> ref) {
  final AsyncValue<Brand> brandAsync = ref.watch(
    hqBrandStreamProvider.select((AsyncValue<Brand> async) {
      return async.when(
        data: (Brand brand) {
          // Lockdown check: tarnish >= 100 halts all idle income
          final bool isLockdown = brand.currentTarnish >= 100;
          return AsyncValue.data(
            isLockdown ? 0 : brand.totalRevenue.toInt(),
          );
        },
        loading: () => const AsyncValue.loading(),
        error: (Object e, StackTrace s) => AsyncValue.error(e, s),
      );
    }),
  );
  return brandAsync;
});

// =============================================================================
// Crisis State Providers — Directive H (Tarnish & Kintsugi)
// =============================================================================

/// Current tarnish level only (0-100)
final Provider<AsyncValue<int>> tarnishLevelProvider =
    Provider<AsyncValue<int>>((Ref<AsyncValue<int>> ref) {
  final AsyncValue<Brand> brandAsync = ref.watch(
    hqBrandStreamProvider.select((AsyncValue<Brand> async) {
      return async.when(
        data: (Brand brand) => AsyncValue.data(brand.currentTarnish),
        loading: () => const AsyncValue.loading(),
        error: (Object e, StackTrace s) => AsyncValue.error(e, s),
      );
    }),
  );
  return brandAsync;
});

/// Kintsugi level (permanent gold veins count)
final Provider<AsyncValue<int>> kintsugiLevelProvider =
    Provider<AsyncValue<int>>((Ref<AsyncValue<int>> ref) {
  final AsyncValue<Brand> brandAsync = ref.watch(
    hqBrandStreamProvider.select((AsyncValue<Brand> async) {
      return async.when(
        data: (Brand brand) => AsyncValue.data(brand.kintsugiLevel),
        loading: () => const AsyncValue.loading(),
        error: (Object e, StackTrace s) => AsyncValue.error(e, s),
      );
    }),
  );
  return brandAsync;
});

/// Lockdown state (tarnish >= 100)
final Provider<bool> isLockdownProvider =
    Provider<bool>((Ref<bool> ref) {
  final AsyncValue<int> tarnishAsync = ref.watch(tarnishLevelProvider);
  return tarnishAsync.when(
    data: (int tarnish) => tarnish >= 100,
    loading: () => false,
    error: (_, __) => false,
  );
});
