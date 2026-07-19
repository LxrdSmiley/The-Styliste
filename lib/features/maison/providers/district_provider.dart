// GDD v6 — Maison District Warfare Providers
// Real-time turf war state with optimistic siege UI
// Alabaster Standard: Capital + Hype = Effective Power

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/providers/active_player_provider.dart';
import '../models/fashion_district.dart';

part 'district_provider.g.dart';

const String kDistrictSiegesUnavailableMessage =
    'District sieges are temporarily unavailable while authoritative '
    'settlement is being strengthened. No capital or control changed.';

/// Real-time stream of all 9 fashion districts
///
/// Updates automatically when:
/// - Takeover occurs
/// - Control changes
/// - Hype values update
@riverpod
Stream<List<FashionDistrict>> globalDistricts(Ref ref) {
  final SupabaseClient supabase = Supabase.instance.client;

  return supabase
      .from(SupabaseConstants.tableFashionDistricts)
      .stream(primaryKey: const <String>['id'])
      .order('city')
      .order('name')
      .map((List<Map<String, dynamic>> data) {
        return data
            .map((Map<String, dynamic> json) => FashionDistrict.fromJson(json))
            .toList();
      });
}

/// Single district by ID
@riverpod
Stream<FashionDistrict?> districtById(Ref ref, String districtId) {
  final SupabaseClient supabase = Supabase.instance.client;

  return supabase
      .from(SupabaseConstants.tableFashionDistricts)
      .stream(primaryKey: const <String>['id'])
      .eq('id', districtId)
      .map((List<Map<String, dynamic>> data) {
        if (data.isEmpty) return null;
        return FashionDistrict.fromJson(data.first);
      });
}

/// Districts controlled by a specific maison
@riverpod
Stream<List<FashionDistrict>> districtsByMaison(Ref ref, String maisonId) {
  final SupabaseClient supabase = Supabase.instance.client;

  return supabase
      .from(SupabaseConstants.tableFashionDistricts)
      .stream(primaryKey: const <String>['id'])
      .eq('controlling_maison_id', maisonId)
      .map((List<Map<String, dynamic>> data) {
        return data
            .map((Map<String, dynamic> json) => FashionDistrict.fromJson(json))
            .toList();
      });
}

/// Legacy watermarks for a maison (permanent 30-day achievements)
@riverpod
Stream<List<DistrictWatermark>> maisonWatermarks(Ref ref, String maisonId) {
  final SupabaseClient supabase = Supabase.instance.client;

  return supabase
      .from(SupabaseConstants.tableDistrictLegacyWatermarks)
      .stream(primaryKey: const <String>['id'])
      .eq('maison_id', maisonId)
      .map((List<Map<String, dynamic>> data) {
        return data
            .map(
              (Map<String, dynamic> json) => DistrictWatermark.fromJson(json),
            )
            .toList();
      });
}

/// All legacy watermarks (for map rendering)
@riverpod
Stream<List<DistrictWatermark>> allWatermarks(Ref ref) {
  final SupabaseClient supabase = Supabase.instance.client;

  return supabase.from(SupabaseConstants.tableDistrictLegacyWatermarks).stream(
    primaryKey: const <String>['id'],
  ).map((List<Map<String, dynamic>> data) {
    return data
        .map((Map<String, dynamic> json) => DistrictWatermark.fromJson(json))
        .toList();
  });
}

/// Siege operation state
class DistrictSiegeState {
  const DistrictSiegeState({
    this.isSieging = false,
    this.targetDistrictId,
    this.bidAmount = 0,
    this.result,
    this.errorMessage,
  });

  final bool isSieging;
  final String? targetDistrictId;
  final int bidAmount;
  final TakeoverResult? result;
  final String? errorMessage;

  DistrictSiegeState copyWith({
    bool? isSieging,
    String? targetDistrictId,
    int? bidAmount,
    TakeoverResult? result,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return DistrictSiegeState(
      isSieging: isSieging ?? this.isSieging,
      targetDistrictId: targetDistrictId ?? this.targetDistrictId,
      bidAmount: bidAmount ?? this.bidAmount,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Notifier for district siege operations
class DistrictSiegeNotifier extends StateNotifier<DistrictSiegeState> {
  DistrictSiegeNotifier() : super(const DistrictSiegeState());

  /// Initiate a siege on a district
  ///
  /// [maisonId] — Attacking maison
  /// [districtId] — Target district
  /// [capitalBid] — Capital to commit (must have treasury >= bid)
  Future<void> initiateSiege({
    required String maisonId,
    required String districtId,
    required int capitalBid,
  }) {
    if (state.isSieging) return Future<void>.value();
    assert(maisonId.isNotEmpty);

    // The former client-callable RPC remains quarantined until its bid and
    // settlement rules can be made authoritative. Do not send a speculative
    // client mutation that could affect Maison control or capital.
    state = state.copyWith(
      isSieging: false,
      targetDistrictId: districtId,
      bidAmount: capitalBid,
      errorMessage: kDistrictSiegesUnavailableMessage,
      clearResult: true,
    );
    return Future<void>.value();
  }

  /// Clear siege state after user acknowledges
  void clear() {
    state = const DistrictSiegeState();
  }

  /// Clear only error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for siege operations
final StateNotifierProvider<DistrictSiegeNotifier, DistrictSiegeState>
    districtSiegeProvider =
    StateNotifierProvider<DistrictSiegeNotifier, DistrictSiegeState>(
  (Ref<DistrictSiegeState> ref) => DistrictSiegeNotifier(),
);

/// Provider for the current player's maison ID
final FutureProvider<String?> playerMaisonIdProvider =
    FutureProvider<String?>((Ref<AsyncValue<String?>> ref) async {
  final String uid = ref.watch(activeUidProvider);

  // First get the player's maison membership
  final PostgrestMap? maisonsResult = await Supabase.instance.client
      .from(SupabaseConstants.tableMaisonMembers)
      .select('maison_id')
      .eq('player_id', uid)
      .maybeSingle();

  return maisonsResult?['maison_id'] as String?;
});

/// Computed: Total districts controlled by a maison
final Provider<AsyncValue<int>> maisonDistrictCountProvider =
    Provider<AsyncValue<int>>((Ref<AsyncValue<int>> ref) {
  final AsyncValue<List<FashionDistrict>> districtsAsync =
      ref.watch(globalDistrictsProvider);
  final AsyncValue<String?> maisonIdAsync = ref.watch(playerMaisonIdProvider);

  return districtsAsync.when(
    data: (List<FashionDistrict> districts) => maisonIdAsync.when(
      data: (String? maisonId) {
        if (maisonId != null) {
          return AsyncValue<int>.data(
            districts
                .where((FashionDistrict d) => d.controllingMaisonId == maisonId)
                .length,
          );
        } else {
          // Solo player fallback
          return const AsyncValue<int>.data(0);
        }
      },
      loading: () => const AsyncValue<int>.loading(),
      error: (Object err, StackTrace stack) =>
          AsyncValue<int>.error(err, stack),
    ),
    loading: () => const AsyncValue<int>.loading(),
    error: (Object err, StackTrace stack) => AsyncValue<int>.error(err, stack),
  );
});

/// Computed: City dominance percentages
final Provider<AsyncValue<Map<String, double>>> cityDominanceProvider =
    Provider<AsyncValue<Map<String, double>>>(
  (Ref<AsyncValue<Map<String, double>>> ref) {
    final AsyncValue<List<FashionDistrict>> districtsAsync =
        ref.watch(globalDistrictsProvider);

    return districtsAsync.when(
      data: (List<FashionDistrict> districts) {
        final Map<String, List<FashionDistrict>> byCity = districts.byCityGroup;
        final Map<String, double> dominance = <String, double>{};

        byCity.forEach((String city, List<FashionDistrict> cityDistricts) {
          final int controlled =
              cityDistricts.where((FashionDistrict d) => d.isControlled).length;
          dominance[city] =
              cityDistricts.isEmpty ? 0.0 : controlled / cityDistricts.length;
        });

        return AsyncValue<Map<String, double>>.data(dominance);
      },
      loading: () => const AsyncValue<Map<String, double>>.loading(),
      error: (Object err, StackTrace stack) =>
          AsyncValue<Map<String, double>>.error(err, stack),
    );
  },
);

/// Helper to calculate required bid to takeover a district
///
/// Returns the minimum capital needed (considering defender power + defense multiplier)
int calculateRequiredBid({
  required int defenderTreasury,
  required int defenderHype,
  required int attackerHype,
  required int daysDefenderHeld,
}) {
  // Defense multiplier: +5% per day, max 2.5x
  final double defenseMultiplier =
      (1.0 + (daysDefenderHeld * 0.05)).clamp(1.0, 2.5);

  // Defender effective power
  final double defenderPower =
      defenderTreasury * defenseMultiplier * (1.0 + defenderHype / 1000);

  // Attacker needs bid where: bid * (1 + attackerHype/1000) > defenderPower
  // Solving for bid: bid > defenderPower / (1 + attackerHype/1000)
  final double attackerMultiplier = 1.0 + (attackerHype / 1000);
  final double requiredBid =
      (defenderPower / attackerMultiplier) + 1; // +1 to ensure victory

  return requiredBid.ceil();
}
