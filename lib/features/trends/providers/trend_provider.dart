// GDD v6 §3 — Trend Tsunami Provider
// Real-time Riverpod stream of active trend waves
// Alabaster Standard: Champagne Gold UI integration ready

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../models/trend_tsunami.dart';

part 'trend_provider.g.dart';

/// Stream of active Trend Tsunamis from Supabase Realtime
///
/// Emits a list of currently active (non-expired) trend waves.
/// Each tsunami represents a style tag with a multiplier (2.5x for Crest, 1.5x for Surge)
///
/// Usage in UI:
/// ```dart
/// final tsunamis = ref.watch(activeTsunamiProvider);
/// tsunamis.when(
///   data: (waves) => TsunamiIndicator(waves: waves),
///   loading: () => ChampagneGoldPulse(),
///   error: (err, stack) => ErrorView(err),
/// );
/// ```
@riverpod
Stream<List<TrendTsunami>> activeTsunami(Ref ref) {
  final SupabaseClient supabase = Supabase.instance.client;

  // Subscribe to trend_tsunamis table with realtime
  return supabase.from(SupabaseConstants.tableTrendTsunamis).stream(
    primaryKey: const <String>['id'],
  ).map((List<Map<String, dynamic>> data) {
    final DateTime now = DateTime.now().toUtc();

    return data
        .map((Map<String, dynamic> json) => TrendTsunami.fromJson(json))
        .where((TrendTsunami tsunami) {
      // Filter out expired tsunamis client-side as safety
      return tsunami.expiresAt.isAfter(now);
    }).toList()
      // Sort by rank (Crest first)
      ..sort((TrendTsunami a, TrendTsunami b) => a.rank.compareTo(b.rank));
  });
}

/// Provider for just the Crest tag (rank 1, 2.5x multiplier)
@riverpod
AsyncValue<TrendTsunami?> crestTag(Ref ref) {
  final AsyncValue<List<TrendTsunami>> tsunamis =
      ref.watch(activeTsunamiProvider);

  return tsunamis.when(
    data: (List<TrendTsunami> waves) {
      try {
        return AsyncValue<TrendTsunami?>.data(
          waves.firstWhere((TrendTsunami t) => t.isCrest),
        );
      } on StateError {
        return const AsyncValue<TrendTsunami?>.data(null);
      }
    },
    loading: () => const AsyncValue<TrendTsunami?>.loading(),
    error: (Object err, StackTrace stack) =>
        AsyncValue<TrendTsunami?>.error(err, stack),
  );
}

/// Provider for Surge tags (rank 2-3, 1.5x multiplier)
@riverpod
AsyncValue<List<TrendTsunami>> surgeTags(Ref ref) {
  final AsyncValue<List<TrendTsunami>> tsunamis =
      ref.watch(activeTsunamiProvider);

  return tsunamis.when(
    data: (List<TrendTsunami> waves) => AsyncValue<List<TrendTsunami>>.data(
      waves.where((TrendTsunami t) => t.isSurge).toList(),
    ),
    loading: () => const AsyncValue<List<TrendTsunami>>.loading(),
    error: (Object err, StackTrace stack) =>
        AsyncValue<List<TrendTsunami>>.error(err, stack),
  );
}

/// Provider that calculates the tsunami multiplier for a specific design's tags
///
/// Usage:
/// ```dart
/// final multiplier = ref.watch(tsunamiMultiplierProvider(['minimalist', 'ivory']));
/// // Returns 2.5 if 'minimalist' is the Crest tag
/// // Returns 1.5 if 'ivory' is a Surge tag
/// // Returns 1.0 if no match
/// ```
@riverpod
double tsunamiMultiplier(Ref ref, List<String> designTags) {
  final AsyncValue<List<TrendTsunami>> tsunamis =
      ref.watch(activeTsunamiProvider);

  return tsunamis.when(
    data: (List<TrendTsunami> waves) => waves.getMultiplierForTags(designTags),
    loading: () => 1.0,
    error: (_, __) => 1.0,
  );
}

/// Provider for checking if a specific tag is part of the active tsunami
@riverpod
bool isTagInTsunami(Ref ref, String tag) {
  final AsyncValue<List<TrendTsunami>> tsunamis =
      ref.watch(activeTsunamiProvider);

  return tsunamis.when(
    data: (List<TrendTsunami> waves) => waves.hasMatchingTag(tag),
    loading: () => false,
    error: (_, __) => false,
  );
}

/// Provider for getting the matching tsunami details for a specific tag
@riverpod
TrendTsunami? matchingTsunamiForTag(Ref ref, String tag) {
  final AsyncValue<List<TrendTsunami>> tsunamis =
      ref.watch(activeTsunamiProvider);

  return tsunamis.when(
    data: (List<TrendTsunami> waves) => waves.getMatchingTsunami(tag),
    loading: () => null,
    error: (_, __) => null,
  );
}

/// Provider for the time remaining until the current tsunami expires
/// Returns the shortest time remaining (closest to expiration)
@riverpod
Duration timeUntilNextTsunami(Ref ref) {
  final AsyncValue<List<TrendTsunami>> tsunamis =
      ref.watch(activeTsunamiProvider);

  return tsunamis.when(
    data: (List<TrendTsunami> waves) {
      if (waves.isEmpty) return Duration.zero;

      // Find the tsunami expiring soonest
      final TrendTsunami soonest = waves.reduce(
        (TrendTsunami a, TrendTsunami b) =>
            a.expiresAt.isBefore(b.expiresAt) ? a : b,
      );

      return soonest.timeRemaining;
    },
    loading: () => Duration.zero,
    error: (_, __) => Duration.zero,
  );
}

/// Provider for formatted time remaining string (HH:MM:SS)
@riverpod
String timeUntilNextTsunamiFormatted(Ref ref) {
  final Duration remaining = ref.watch(timeUntilNextTsunamiProvider);

  if (remaining.isNegative || remaining.inSeconds == 0) {
    return '00:00:00';
  }

  final int hours = remaining.inHours;
  final int minutes = remaining.inMinutes.remainder(60);
  final int seconds = remaining.inSeconds.remainder(60);

  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}
