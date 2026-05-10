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
final Provider<int> brandHeatPercentProvider =
    Provider<int>((Ref<int> ref) {
  return ref.watch(
    hqBrandStreamProvider.select(
      (AsyncValue<Brand> async) => async.value?.hypeScore.toInt() ?? 0,
    ),
  );
});

/// Sovereign multipliers only — for bonus calculation
final Provider<int> sovereignMultipliersProvider =
    Provider<int>((Ref<int> ref) {
  return ref.watch(
    hqPlayerStreamProvider.select(
      (AsyncValue<Player> async) => async.value?.sovereignMultipliers ?? 0,
    ),
  );
});

/// Career path only — for view switching (Artisan vs Architect)
final Provider<CareerPath?> careerPathProvider =
    Provider<CareerPath?>((Ref<CareerPath?> ref) {
  return ref.watch(
    hqPlayerStreamProvider.select(
      (AsyncValue<Player> async) => async.value?.path,
    ),
  );
});

/// Joint venture status only — for Command Floor unlock
final Provider<bool> jointVentureUnlockedProvider =
    Provider<bool>((Ref<bool> ref) {
  return ref.watch(
    hqPlayerStreamProvider.select(
      (AsyncValue<Player> async) => async.value?.isJointVenture ?? false,
    ),
  );
});

/// Idle income ticker — optimized for cash flow ribbon
/// Only updates when integer dollar amount changes (not every cent tick)
/// Kode Addendum #2: Returns 0 when in lockdown (tarnish >= 100)
final Provider<int> idleIncomeTickerProvider =
    Provider<int>((Ref<int> ref) {
  return ref.watch(
    hqBrandStreamProvider.select((AsyncValue<Brand> async) {
      final Brand? brand = async.value;
      if (brand == null) return 0;
      final bool isLockdown = brand.currentTarnish >= 100;
      return isLockdown ? 0 : brand.totalRevenue.toInt();
    }),
  );
});

// =============================================================================
// Crisis State Providers — Directive H (Tarnish & Kintsugi)
// =============================================================================

/// Current tarnish level only (0-100)
final Provider<int> tarnishLevelProvider =
    Provider<int>((Ref<int> ref) {
  return ref.watch(
    hqBrandStreamProvider.select(
      (AsyncValue<Brand> async) => async.value?.currentTarnish ?? 0,
    ),
  );
});

/// Kintsugi level (permanent gold veins count)
final Provider<int> kintsugiLevelProvider =
    Provider<int>((Ref<int> ref) {
  return ref.watch(
    hqBrandStreamProvider.select(
      (AsyncValue<Brand> async) => async.value?.kintsugiLevel ?? 0,
    ),
  );
});

/// Lockdown state (tarnish >= 100)
final Provider<bool> isLockdownProvider =
    Provider<bool>((Ref<bool> ref) {
  return ref.watch(tarnishLevelProvider) >= 100;
});
