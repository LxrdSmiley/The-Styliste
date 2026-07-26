// GDD §3.0 — HQ Riverpod providers: stream Player and Brand state
// PROJECT_RULES §3 — Server is source of truth; client reads via real-time streams.
// Both providers derive their UID from activeUidProvider (Supabase auth UUID).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/active_player_provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../data/repositories/supabase_economy_repository.dart';
import '../../../data/repositories/supabase_player_repository.dart';
import '../../../domain/models/brand.dart';
import '../../../domain/models/player.dart';

/// Streams the authenticated player's Player row from Supabase.
/// Rebuilds HQ when brand_rank, xp, or onboarding_complete changes.
final StreamProvider<Player> hqPlayerStreamProvider =
    StreamProvider<Player>((Ref<AsyncValue<Player>> ref) {
  final AsyncValue<Session> session =
      ref.watch(supabaseRealtimeSessionProvider);
  if (session.isLoading) return const Stream<Player>.empty();
  if (session.hasError) {
    return Stream<Player>.error(_safeSessionError(session.error!));
  }

  final String uid = ref.watch(activeUidProvider);
  // Guard: if uid is empty the auth gate hasn't resolved yet — emit nothing.
  if (uid.isEmpty) return const Stream<Player>.empty();

  return SupabaseService.guardRealtimeStream(
    const SupabasePlayerRepository().watchPlayer(uid),
  );
});

/// Streams the authenticated player's Brand (brand_state) row from Supabase.
/// Real-time updates drive the HQ idle ticker and heat display.
final StreamProvider<Brand> hqBrandStreamProvider =
    StreamProvider<Brand>((Ref<AsyncValue<Brand>> ref) {
  final AsyncValue<Session> session =
      ref.watch(supabaseRealtimeSessionProvider);
  if (session.isLoading) return const Stream<Brand>.empty();
  if (session.hasError) {
    return Stream<Brand>.error(_safeSessionError(session.error!));
  }

  final String uid = ref.watch(activeUidProvider);
  if (uid.isEmpty) return const Stream<Brand>.empty();

  return SupabaseService.guardRealtimeStream(
    const SupabaseEconomyRepository().watchBrandState(uid),
  );
});

class LatestAlphaDropSummary {
  const LatestAlphaDropSummary({
    required this.feedPostId,
    required this.designName,
    required this.hypeScore,
    this.marketReaction,
    this.nextObjective,
    this.vexVerdict,
    this.vexHeadline,
    this.vexQuote,
    this.followersDelta,
    this.brandHeatDelta,
    this.xpDelta,
    this.rankProgressDelta,
    this.currentRank,
    this.rankProgressPercent,
    this.rankUpOccurred,
    this.idleRevenueDelta,
  });

  final String feedPostId;
  final String designName;
  final double hypeScore;
  final String? marketReaction;
  final String? nextObjective;
  final String? vexVerdict;
  final String? vexHeadline;
  final String? vexQuote;
  final int? followersDelta;
  final int? brandHeatDelta;
  final int? xpDelta;
  final double? rankProgressDelta;
  final int? currentRank;
  final double? rankProgressPercent;
  final bool? rankUpOccurred;
  final double? idleRevenueDelta;

  factory LatestAlphaDropSummary.fromFeedRow(Map<String, dynamic> row) {
    final Map<String, dynamic> content =
        _mapValue(row['content']) ?? <String, dynamic>{};
    final Map<String, dynamic> result =
        _mapValue(content['post_drop_result']) ?? <String, dynamic>{};

    return LatestAlphaDropSummary(
      feedPostId: _stringValue(row['id']) ?? '',
      designName: _stringValue(content['design_name']) ?? 'Alpha Drop',
      hypeScore: _doubleValue(
        content['hype_score'],
        fallback: _doubleValue(row['hype']),
      ),
      marketReaction: _stringValue(result['market_reaction']),
      nextObjective: _stringValue(result['next_objective']),
      vexVerdict: _stringValue(content['vex_verdict']),
      vexHeadline: _stringValue(content['vex_headline']),
      vexQuote: _stringValue(content['vex_quote']),
      followersDelta: _intValue(result['followers_delta']),
      brandHeatDelta: _intValue(result['brand_heat_delta']),
      xpDelta: _intValue(result['xp_delta']),
      rankProgressDelta: _doubleValueOrNull(result['rank_progress_delta']),
      currentRank: _intValue(result['current_rank']),
      rankProgressPercent: _doubleValueOrNull(result['rank_progress_percent']),
      rankUpOccurred: result['rank_up_occurred'] as bool?,
      idleRevenueDelta: _doubleValueOrNull(result['idle_revenue_delta']),
    );
  }
}

final FutureProvider<LatestAlphaDropSummary?> latestAlphaDropProvider =
    FutureProvider<LatestAlphaDropSummary?>(
        (Ref<AsyncValue<LatestAlphaDropSummary?>> ref) async {
  ref.watch(supabaseAuthRevisionProvider);
  final String uid = ref.watch(activeUidProvider);
  if (uid.isEmpty) return null;

  await SupabaseService.ensureFreshSession();
  final Map<String, dynamic>? row = await SupabaseService.client
      .schema('api')
      .from('feed_projection')
      .select('id, content, hype, created_at')
      .eq('player_id', uid)
      .inFilter('type', <String>['design_flex', 'design_drop'])
      .filter('content->>event', 'eq', 'alpha_dropped')
      .order('created_at', ascending: false)
      .limit(1)
      .maybeSingle();

  if (row == null) return null;
  return LatestAlphaDropSummary.fromFeedRow(row);
});

// =============================================================================
// Optimized .select() providers — Kode Addendum: Aggressive Riverpod optimization
// Only rebuild when explicit data points change, not on every engine tick
// =============================================================================

/// Brand heat percent only — for BrandHeatMeter widget
/// Rebuilds only when heat integer changes (not on every decimal tick)
final Provider<int> brandHeatPercentProvider = Provider<int>((Ref<int> ref) {
  return ref.watch(
    hqBrandStreamProvider.select(
      (AsyncValue<Brand> async) => async.value?.heat ?? 0,
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
final Provider<int> idleIncomeTickerProvider = Provider<int>((Ref<int> ref) {
  return ref.watch(
    hqBrandStreamProvider.select((AsyncValue<Brand> async) {
      final Brand? brand = async.value;
      if (brand == null) return 0;
      final bool isLockdown = brand.currentTarnish >= 100;
      return isLockdown ? 0 : brand.idleRevenuePerHour.toInt();
    }),
  );
});

// =============================================================================
// Crisis State Providers — Directive H (Tarnish & Kintsugi)
// =============================================================================

/// Current tarnish level only (0-100)
final Provider<int> tarnishLevelProvider = Provider<int>((Ref<int> ref) {
  return ref.watch(
    hqBrandStreamProvider.select(
      (AsyncValue<Brand> async) => async.value?.currentTarnish ?? 0,
    ),
  );
});

/// Kintsugi level (permanent gold veins count)
final Provider<int> kintsugiLevelProvider = Provider<int>((Ref<int> ref) {
  return ref.watch(
    hqBrandStreamProvider.select(
      (AsyncValue<Brand> async) => async.value?.kintsugiLevel ?? 0,
    ),
  );
});

/// Lockdown state (tarnish >= 100)
final Provider<bool> isLockdownProvider = Provider<bool>((Ref<bool> ref) {
  return ref.watch(tarnishLevelProvider) >= 100;
});

Object _safeSessionError(Object error) {
  return SupabaseService.isRecoverableAuthError(error)
      ? const SupabaseSessionExpiredException()
      : error;
}

Map<String, dynamic>? _mapValue(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String? _stringValue(Object? value) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  return null;
}

int? _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double _doubleValue(Object? value, {double fallback = 0.0}) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

double? _doubleValueOrNull(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
