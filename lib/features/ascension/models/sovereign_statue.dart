// GDD v6 §3.5 — Sovereign Statue Model
// Hall of Sovereigns: 3D memorialized brands with tier-based materials
// Alabaster Standard: Quartz → Gold → Alabaster progression

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/player.dart';

part 'sovereign_statue.freezed.dart';
part 'sovereign_statue.g.dart';

/// Statue material tiers — fixed progression based on memorialization count
/// 
/// 1st memorialization = Quartz (Rose Gold)
/// 2nd-4th memorializations = Gold (Champagne Gold)
/// 5th+ memorializations = Alabaster (Pure Ivory)
enum StatueTier {
  @JsonValue('Quartz')
  quartz,
  @JsonValue('Gold')
  gold,
  @JsonValue('Alabaster')
  alabaster,
}

/// Extension for tier properties
extension StatueTierExtension on StatueTier {
  /// Material color for 3D rendering and UI
  /// 
  /// Quartz: Rose gold / pinkish (#E8B4B8)
  /// Gold: Champagne gold (#F7E7CE)
  /// Alabaster: Pure ivory (#FFFFF0)
  // AI_UNCERTAINTY: These are Flutter Color values; verify with 3D shader compatibility
  int get materialColorValue {
    switch (this) {
      case StatueTier.quartz:
        return 0xFFE8B4B8;
      case StatueTier.gold:
        return 0xFFF7E7CE;
      case StatueTier.alabaster:
        return 0xFFFFFFF0;
    }
  }
  
  /// Display name for UI
  String get displayName {
    switch (this) {
      case StatueTier.quartz:
        return 'QUARTZ';
      case StatueTier.gold:
        return 'GOLD';
      case StatueTier.alabaster:
        return 'ALABASTER';
    }
  }
  
  /// Description of the tier
  String get description {
    switch (this) {
      case StatueTier.quartz:
        return 'First light of the empire';
      case StatueTier.gold:
        return 'The standard redefined';
      case StatueTier.alabaster:
        return 'Pure Aurelian perfection';
    }
  }
  
  /// Opacity for watermark overlay (Aurelian watermark effect)
  double get watermarkOpacity => 0.3;
  
  /// Font weight for museum plaque
  FontWeight get plaqueFontWeight {
    switch (this) {
      case StatueTier.quartz:
        return FontWeight.w400;
      case StatueTier.gold:
        return FontWeight.w300;
      case StatueTier.alabaster:
        return FontWeight.w100;
    }
  }
}

/// A memorialized brand in the Hall of Sovereigns
/// 
/// Created at Rank 100 ascension. Permanent record of player's
/// fashion empire achievement with 3D statue representation.
@freezed
class SovereignStatue with _$SovereignStatue {
  const factory SovereignStatue({
    required String id,
    required String playerId,
    required String brandName,
    required DateTime ascendedAt,
    required int finalMarketCap,
    @Default(0.0) double finalHypeScore,
    required StatueTier statueTier,
    required CareerPath careerPath,
    @Default(false) bool jointVentureFlag,
  }) = _SovereignStatue;

  const SovereignStatue._();

  factory SovereignStatue.fromJson(Map<String, Object?> json) =>
      _$SovereignStatueFromJson(json);

  /// Formatted ascension date: "January 15, 2026"
  String get formattedDate => DateFormat('MMMM d, yyyy').format(ascendedAt);
  
  /// Short date: "Jan 2026"
  String get shortDate => DateFormat('MMM yyyy').format(ascendedAt);
  
  /// Market cap formatted: "$1.5M" or "$850K"
  String get marketCapFormatted {
    if (finalMarketCap >= 1000000) {
      return '\$${(finalMarketCap / 1000000).toStringAsFixed(1)}M';
    } else if (finalMarketCap >= 1000) {
      return '\$${(finalMarketCap / 1000).toStringAsFixed(0)}K';
    }
    return '\$${finalMarketCap}';
  }
  
  /// Hype score formatted: "12.5K"
  String get hypeScoreFormatted {
    if (finalHypeScore >= 1000) {
      return '${(finalHypeScore / 1000).toStringAsFixed(1)}K';
    }
    return finalHypeScore.toStringAsFixed(0);
  }
  
  /// Museum plaque text
  String get plaqueText {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln(brandName.toUpperCase());
    buffer.writeln();
    buffer.writeln('${careerPath.displayName} Path');
    if (jointVentureFlag) {
      buffer.writeln('Joint Venture Master');
    }
    buffer.writeln();
    buffer.writeln('Market Cap: $marketCapFormatted');
    buffer.writeln('Final Hype: $hypeScoreFormatted');
    buffer.writeln();
    buffer.writeln('Ascended $formattedDate');
    return buffer.toString();
  }
  
  /// Single-line summary for lists
  String get summary => '$brandName — ${statueTier.displayName} — $shortDate';
}

/// Extension methods for statue collections
extension SovereignStatueListExtension on List<SovereignStatue> {
  /// Sort by ascension date (newest first)
  List<SovereignStatue> get byNewest =>
      this..sort((SovereignStatue a, SovereignStatue b) =>
          b.ascendedAt.compareTo(a.ascendedAt));
  
  /// Sort by tier (Alabaster first, then Gold, then Quartz)
  List<SovereignStatue> get byTier {
    final Map<StatueTier, int> tierOrder = <StatueTier, int>{
      StatueTier.alabaster: 0,
      StatueTier.gold: 1,
      StatueTier.quartz: 2,
    };
    return this..sort((SovereignStatue a, SovereignStatue b) =>
        tierOrder[a.statueTier]!.compareTo(tierOrder[b.statueTier]!));
  }
  
  /// Group by tier
  Map<StatueTier, List<SovereignStatue>> get byTierGroup {
    final Map<StatueTier, List<SovereignStatue>> result = <StatueTier, List<SovereignStatue>>{};
    for (final SovereignStatue statue in this) {
      result.putIfAbsent(statue.statueTier, () => <SovereignStatue>[]).add(statue);
    }
    return result;
  }
  
  /// Filter by player
  List<SovereignStatue> byPlayer(String playerId) =>
      where((SovereignStatue s) => s.playerId == playerId).toList();
  
  /// Total market cap of all statues
  int get totalMarketCap => fold(0, (int sum, SovereignStatue s) => sum + s.finalMarketCap);
  
  /// Average hype score
  double get averageHype => isEmpty ? 0.0 : 
      fold(0.0, (double sum, SovereignStatue s) => sum + s.finalHypeScore) / length;
}

/// Career path display extension
extension CareerPathDisplay on CareerPath {
  String get displayName {
    switch (this) {
      case CareerPath.designer:
        return 'Artisan';
      case CareerPath.mogul:
        return 'Architect';
    }
  }
}
