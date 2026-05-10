// Directive I — Talent Models
// GDD §8.10 — Sovereign Talent casting system
// Alabaster Standard: Type-safe, Freezed, with tier extensions

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'talent.freezed.dart';
part 'talent.g.dart';

/// Talent tiers in ascending rarity
/// 
/// Drop rates:
/// - Rising Star: 60% (1 prestige on dupe)
/// - Established: 30% (5 prestige on dupe)
/// - Iconic: 9% (15 prestige on dupe)
/// - Sovereign: 0.5% (50 prestige on dupe, pity at 90)
enum TalentTier {
  @JsonValue('rising_star')
  risingStar,
  @JsonValue('established')
  established,
  @JsonValue('iconic')
  iconic,
  @JsonValue('sovereign')
  sovereign,
}

extension TalentTierExtension on TalentTier {
  String get displayName {
    switch (this) {
      case TalentTier.risingStar:
        return 'Rising Star';
      case TalentTier.established:
        return 'Established';
      case TalentTier.iconic:
        return 'Iconic';
      case TalentTier.sovereign:
        return 'Sovereign';
    }
  }
  
  /// Tier color for UI
  Color get tierColor {
    switch (this) {
      case TalentTier.risingStar:
        return const Color(0xFFB8B8B8); // Silver-grey
      case TalentTier.established:
        return const Color(0xFFCD7F32); // Bronze
      case TalentTier.iconic:
        return const Color(0xFFE8D4B8); // Champagne
      case TalentTier.sovereign:
        return const Color(0xFFD4AF37); // Deep gold
    }
  }
  
  /// Base drop rate percentage
  double get baseDropRate {
    switch (this) {
      case TalentTier.risingStar:
        return 60.0;
      case TalentTier.established:
        return 30.0;
      case TalentTier.iconic:
        return 9.0;
      case TalentTier.sovereign:
        return 0.5;
    }
  }
  
  /// Prestige tokens earned on duplicate pull
  int get prestigeValue {
    switch (this) {
      case TalentTier.risingStar:
        return 1;
      case TalentTier.established:
        return 5;
      case TalentTier.iconic:
        return 15;
      case TalentTier.sovereign:
        return 50;
    }
  }
  
  /// Cost in Luxe Tokens for casting pull
  static int get castingCost => 100;
  
  /// Ten-pull cost (no discount per Alabaster Standard)
  static int get castingCostTen => 1000;
  
  /// Pity threshold for guaranteed Sovereign
  static int get pityThreshold => 90;
}

/// Talent model — represents a celebrity/model/designer in the gacha pool
@freezed
class Talent with _$Talent {
  const factory Talent({
    required String id,
    required String name,
    required TalentTier tier,
    String? portraitUrl,
    @Default(1.0) double baseHypeMultiplier,
    @Default(0) int scandalRiskFactor,
    String? biography,
    @Default(<String>[]) List<String> signatureStyle,
    @Default(true) bool isActive,
  }) = _Talent;
  
  factory Talent.fromJson(Map<String, dynamic> json) => _$TalentFromJson(json);
}

/// Player's owned talent with acquisition metadata
@freezed
class RosterTalent with _$RosterTalent {
  const factory RosterTalent({
    required String talentId,
    required String name,
    required TalentTier tier,
    String? portraitUrl,
    required double baseHypeMultiplier,
    @Default(0) int scandalRiskFactor,
    String? biography,
    DateTime? acquiredAt,
    @Default(false) bool isFavorite,
    required int prestigeValue,  // Dupe value
  }) = _RosterTalent;
  
  factory RosterTalent.fromJson(Map<String, dynamic> json) => _$RosterTalentFromJson(json);
}

/// Single pull result from casting
@freezed
class PullResult with _$PullResult {
  const factory PullResult({
    required String talentId,
    required String name,
    required TalentTier tier,
    String? portraitUrl,
    required bool isDupe,
    @Default(0) int prestigeValue,
    double? baseHypeMultiplier,
  }) = _PullResult;
  
  factory PullResult.fromJson(Map<String, dynamic> json) => _$PullResultFromJson(json);
}

/// Complete casting pull result (single or ten)
@freezed
class CastingResult with _$CastingResult {
  const factory CastingResult({
    required List<PullResult> pulls,
    @Default(0) int luxeSpent,
    @Default(0) int prestigeEarned,
    String? message,
  }) = _CastingResult;
  
  factory CastingResult.fromJson(Map<String, dynamic> json) => _$CastingResultFromJson(json);
}

/// Pity state tracking
@freezed
class PityState with _$PityState {
  const PityState._();
  const factory PityState({
    @Default('standard') String bannerId,
    @Default(0) int pullsSinceSovereign,
    @Default(0) int totalPulls,
    DateTime? lastPullAt,
  }) = _PityState;
  
  factory PityState.fromJson(Map<String, dynamic> json) => _$PityStateFromJson(json);
  
  /// Calculate progress to pity (0.0 - 1.0)
  double get pityProgress => 
    pullsSinceSovereign / TalentTierExtension.pityThreshold;
  
  /// Pulls remaining until guaranteed Sovereign
  int get pullsUntilPity => 
    TalentTierExtension.pityThreshold - pullsSinceSovereign;
}
