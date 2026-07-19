// Directive 26 — Functional Talent Casting quarantine
// GDD v7 §§2.5, 8.3, 10.2, 15.1, 15.2, 17, 19.2, 19.3, and 22

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/talent.dart';

const String kCastingUnavailableMessage =
    'Casting is temporarily unavailable while Talent acquisition is being '
    'redesigned. No currency, pity, or roster changes are being made.';

enum CastingAvailability {
  unavailable,
}

class CastingState {
  const CastingState({
    this.availability = CastingAvailability.unavailable,
    this.message = kCastingUnavailableMessage,
  });

  final CastingAvailability availability;
  final String message;

  bool get isUnavailable => availability == CastingAvailability.unavailable;
}

class CastingNotifier extends StateNotifier<CastingState> {
  CastingNotifier() : super(const CastingState());

  /// Preserve the notifier contract for callers compiled against this release,
  /// but never invoke the quarantined RPC or begin an optimistic presentation.
  Future<void> executePull({bool isTenPull = false}) {
    state = const CastingState();
    return Future<void>.value();
  }
}

final StateNotifierProvider<CastingNotifier, CastingState> castingProvider =
    StateNotifierProvider<CastingNotifier, CastingState>(
  (Ref<CastingState> ref) => CastingNotifier(),
);

/// Read-only stream of historically owned Talent.
final StreamProvider<List<RosterTalent>> playerRosterProvider =
    StreamProvider<List<RosterTalent>>(
  (Ref<AsyncValue<List<RosterTalent>>> ref) {
    final SupabaseClient supabase = Supabase.instance.client;
    final String? userId = supabase.auth.currentUser?.id;

    if (userId == null) return const Stream<List<RosterTalent>>.empty();

    return Stream<int>.periodic(const Duration(seconds: 5), (int i) => i)
        .asyncMap((int _) async {
      final List<Object?> result = await supabase.rpc<List<Object?>>(
        'get_player_roster',
        params: <String, dynamic>{'p_player_id': userId},
      );
      return result
          .whereType<Map<String, dynamic>>()
          .map((Map<String, dynamic> json) => RosterTalent.fromJson(json))
          .toList();
    });
  },
);

/// Compatibility alias for existing read-only roster consumers.
final StreamProvider<List<RosterTalent>> rosterProvider = playerRosterProvider;
