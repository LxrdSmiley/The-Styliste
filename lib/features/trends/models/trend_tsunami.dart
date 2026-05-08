// GDD v6 §3 — Trend Tsunami Domain Model
// 48-hour live player-driven trend meta
// Alabaster Standard implementation

import 'package:freezed_annotation/freezed_annotation.dart';

part 'trend_tsunami.freezed.dart';
part 'trend_tsunami.g.dart';

/// Represents a single tag within the active Trend Tsunami
/// 
/// The Trend Tsunami is a 48-hour wave of aesthetic dominance calculated
/// from global player behavior. Tags are ranked:
/// - Rank 1 (Crest): 2.5x multiplier
/// - Rank 2-3 (Surge): 1.5x multiplier
@freezed
class TrendTsunami with _$TrendTsunami {
  const factory TrendTsunami({
    required String id,
    required String tagName,
    required double multiplier,
    required int rank,
    required double totalWeight,
    required DateTime startsAt,
    required DateTime expiresAt,
    required DateTime createdAt,
  }) = _TrendTsunami;

  const TrendTsunami._();

  factory TrendTsunami.fromJson(Map<String, Object?> json) =>
      _$TrendTsunamiFromJson(json);

  /// Returns true if this tag is the Crest (rank 1, 2.5x multiplier)
  bool get isCrest => rank == 1 && multiplier == 2.5;

  /// Returns true if this tag is a Surge tag (rank 2-3, 1.5x multiplier)
  bool get isSurge => rank > 1 && multiplier == 1.5;

  /// Returns the time remaining until this tsunami expires
  Duration get timeRemaining {
    final DateTime now = DateTime.now().toUtc();
    if (now.isAfter(expiresAt)) {
      return Duration.zero;
    }
    return expiresAt.difference(now);
  }

  /// Returns formatted time remaining as "HH:MM:SS"
  String get timeRemainingFormatted {
    final Duration remaining = timeRemaining;
    if (remaining.isNegative || remaining.inSeconds == 0) {
      return '00:00:00';
    }
    final int hours = remaining.inHours;
    final int minutes = remaining.inMinutes.remainder(60);
    final int seconds = remaining.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Returns true if this tsunami has expired
  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);

  /// Returns the multiplier as a display string (e.g., "2.5x", "1.5x")
  String get multiplierDisplay => '${multiplier.toStringAsFixed(1)}x';

  /// Check if a given tag matches this tsunami tag
  /// Returns the multiplier if matched, null otherwise
  double? getMultiplierForTag(String tag) {
    if (tagName.toLowerCase() == tag.toLowerCase()) {
      return multiplier;
    }
    return null;
  }

  /// Check if any tag in the provided list matches this tsunami
  /// Returns the multiplier if any match, null otherwise
  double? getMultiplierForAnyTag(List<String> tags) {
    for (final String tag in tags) {
      final double? match = getMultiplierForTag(tag);
      if (match != null) {
        return match;
      }
    }
    return null;
  }
}

/// Extension methods for working with lists of TrendTsunamis
extension TrendTsunamiListExtension on List<TrendTsunami> {
  /// Returns the Crest tag (rank 1) if active, null otherwise
  TrendTsunami? get crestTag {
    try {
      return firstWhere(
        (TrendTsunami t) => t.isCrest && !t.isExpired,
      );
    } on StateError {
      return null;
    }
  }

  /// Returns all Surge tags (rank 2-3) that are active
  List<TrendTsunami> get surgeTags =>
      where((TrendTsunami t) => t.isSurge && !t.isExpired).toList();

  /// Returns only active (non-expired) tsunamis
  List<TrendTsunami> get activeOnly =>
      where((TrendTsunami t) => !t.isExpired).toList();

  /// Finds the best matching multiplier for a list of design tags
  /// Returns highest multiplier if multiple match, 1.0 if none match
  double getMultiplierForTags(List<String> designTags) {
    double maxMultiplier = 1.0;

    for (final TrendTsunami tsunami in activeOnly) {
      final double? match = tsunami.getMultiplierForAnyTag(designTags);
      if (match != null && match > maxMultiplier) {
        maxMultiplier = match;
      }
    }

    return maxMultiplier;
  }

  /// Returns true if any active tsunami matches the given tag
  bool hasMatchingTag(String tag) {
    return activeOnly.any(
      (TrendTsunami t) => t.tagName.toLowerCase() == tag.toLowerCase(),
    );
  }

  /// Returns matching tsunami for a tag, null if no match
  TrendTsunami? getMatchingTsunami(String tag) {
    try {
      return activeOnly.firstWhere(
        (TrendTsunami t) => t.tagName.toLowerCase() == tag.toLowerCase(),
      );
    } on StateError {
      return null;
    }
  }
}
