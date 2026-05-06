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
