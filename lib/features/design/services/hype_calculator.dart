// GDD v6 §3 — Hype Score Calculator with Trend Tsunami Multiplier
// Alabaster Standard: Real-time 48h player-driven trend integration
//
// Formula: Hype_Score =
//   (Aesthetic_Alignment * Trend_Tsunami_Alignment_Multiplier * Material_Quality_Normalized)
//   + Sovereign_Talent_Multiplier
//
// Trend Tsunami:
//   - Active matching trend: 1.5x to Aesthetic_Alignment for 48 hours.
//   - No match: 1.0x.

import '../../trends/models/trend_tsunami.dart';

/// Configuration for hype calculation parameters
class HypeCalculatorConfig {
  /// Base multiplier for all calculations (can be tuned globally)
  final double baseMultiplier;

  /// Sovereign talent bonus per talent level (GDD §8.10)
  final double talentBonusPerLevel;

  /// Material quality weight in base score
  final double materialQualityWeight;

  /// Aesthetic alignment weight in base score
  final double aestheticAlignmentWeight;

  const HypeCalculatorConfig({
    this.baseMultiplier = 1.0,
    this.talentBonusPerLevel = 0.05,
    this.materialQualityWeight = 0.4,
    this.aestheticAlignmentWeight = 0.6,
  });

  /// Default production configuration
  static const HypeCalculatorConfig production = HypeCalculatorConfig();

  /// Expert mode configuration (higher weights, more volatile)
  static const HypeCalculatorConfig expert = HypeCalculatorConfig(
    baseMultiplier: 1.2,
    talentBonusPerLevel: 0.08,
    materialQualityWeight: 0.5,
    aestheticAlignmentWeight: 0.5,
  );
}

/// Input parameters for hype score calculation
class HypeCalculationInput {
  /// Design's style tags (e.g., ['minimalist', 'ivory', 'streetwear'])
  final List<String> styleTags;

  /// Material quality score (0-100)
  final double materialQuality;

  /// Aesthetic alignment score (0-100)
  final double aestheticAlignment;

  /// Number of sovereign talent assigned to this design (GDD §8.10)
  final int sovereignTalentCount;

  /// Total expertise level of assigned talent (0-100 per talent)
  final double totalTalentExpertise;

  const HypeCalculationInput({
    required this.styleTags,
    this.materialQuality = 50.0,
    this.aestheticAlignment = 50.0,
    this.sovereignTalentCount = 0,
    this.totalTalentExpertise = 0.0,
  });

  /// Validates all input values are within acceptable ranges
  bool get isValid {
    return materialQuality >= 0 &&
        materialQuality <= 100 &&
        aestheticAlignment >= 0 &&
        aestheticAlignment <= 100 &&
        sovereignTalentCount >= 0 &&
        totalTalentExpertise >= 0 &&
        totalTalentExpertise <= 100;
  }
}

/// Result of hype score calculation with breakdown
class HypeCalculationResult {
  /// Final calculated hype score
  final double totalScore;

  /// Base score before any multipliers (material + aesthetic)
  final double baseScore;

  /// Tsunami multiplier applied (1.0 or 1.5)
  final double tsunamiMultiplier;

  /// Sovereign talent bonus added
  final double talentBonus;

  /// The matching tsunami tag (if any)
  final String? matchingTsunamiTag;

  /// Whether the matching trend is currently ranked first
  final bool wasCrestMatch;

  const HypeCalculationResult({
    required this.totalScore,
    required this.baseScore,
    required this.tsunamiMultiplier,
    required this.talentBonus,
    this.matchingTsunamiTag,
    this.wasCrestMatch = false,
  });

  /// Display multiplier as string (e.g., "1.5x", "1.0x")
  String get multiplierDisplay => '${tsunamiMultiplier.toStringAsFixed(1)}x';

  /// The bonus amount added by the tsunami multiplier
  double get tsunamiBonus => baseScore * (tsunamiMultiplier - 1.0);

  /// Breakdown of score components as percentages
  Map<String, double> get breakdownPercentages {
    final double total = totalScore;
    if (total == 0) return <String, double>{};

    return <String, double>{
      'base': (baseScore / total) * 100,
      'tsunami_bonus': (tsunamiBonus / total) * 100,
      'talent_bonus': (talentBonus / total) * 100,
    };
  }
}

/// The Hype Score Calculator
///
/// Implements the GDD v6 formula with Trend Tsunami integration.
/// All calculations are deterministic and can be reproduced server-side
/// for validation.
class HypeCalculator {
  final HypeCalculatorConfig config;

  const HypeCalculator({this.config = HypeCalculatorConfig.production});

  /// Calculate the final hype score with full breakdown
  ///
  /// [input] - The design parameters
  /// [activeTsunamis] - Current trend waves from Riverpod provider
  ///
  /// Returns [HypeCalculationResult] with score and component breakdown
  HypeCalculationResult calculate({
    required HypeCalculationInput input,
    required List<TrendTsunami> activeTsunamis,
  }) {
    // Validate inputs
    if (!input.isValid) {
      throw ArgumentError(
        'Invalid hype calculation input: parameters out of range',
      );
    }

    final TrendTsunami? matchingTrend = _matchingTrend(input, activeTsunamis);
    final double tsunamiMultiplier =
        _hasTrendMatch(input, activeTsunamis) ? 1.5 : 1.0;
    final double adjustedAesthetic =
        (input.aestheticAlignment * tsunamiMultiplier)
            .clamp(0.0, 100.0)
            .toDouble();
    final double materialQualityNormalized = input.materialQuality / 100.0;
    final double baseScore =
        adjustedAesthetic * materialQualityNormalized * config.baseMultiplier;
    final double talentBonus = input.sovereignTalentCount > 0
        ? input.totalTalentExpertise *
            config.talentBonusPerLevel *
            input.sovereignTalentCount
        : 0.0;
    final double totalScore =
        (baseScore + talentBonus).clamp(0.0, 100.0).toDouble();

    return HypeCalculationResult(
      totalScore: totalScore.roundTo(2),
      baseScore: baseScore.roundTo(2),
      tsunamiMultiplier: tsunamiMultiplier,
      talentBonus: talentBonus.roundTo(2),
      matchingTsunamiTag: matchingTrend?.tagName,
      wasCrestMatch: matchingTrend?.rank == 1,
    );
  }

  bool _hasTrendMatch(
    HypeCalculationInput input,
    List<TrendTsunami> activeTsunamis,
  ) {
    return activeTsunamis.activeOnly.any(
      (TrendTsunami trend) =>
          trend.getMultiplierForAnyTag(input.styleTags) != null,
    );
  }

  TrendTsunami? _matchingTrend(
    HypeCalculationInput input,
    List<TrendTsunami> activeTsunamis,
  ) {
    for (final TrendTsunami trend in activeTsunamis.activeOnly) {
      if (trend.getMultiplierForAnyTag(input.styleTags) != null) {
        return trend;
      }
    }
    return null;
  }

  /// Quick calculate without full breakdown (for UI previews)
  ///
  /// Returns just the final hype score number
  double calculateQuick({
    required HypeCalculationInput input,
    required List<TrendTsunami> activeTsunamis,
  }) {
    return calculate(
      input: input,
      activeTsunamis: activeTsunamis,
    ).totalScore;
  }

  /// Projected score with a hypothetical tag selection
  ///
  /// Used in Atelier when user is selecting tags but hasn't confirmed
  double projectWithTags({
    required List<String> hypotheticalTags,
    required HypeCalculationInput baseInput,
    required List<TrendTsunami> activeTsunamis,
  }) {
    final HypeCalculationInput projectedInput = HypeCalculationInput(
      styleTags: hypotheticalTags,
      materialQuality: baseInput.materialQuality,
      aestheticAlignment: baseInput.aestheticAlignment,
      sovereignTalentCount: baseInput.sovereignTalentCount,
      totalTalentExpertise: baseInput.totalTalentExpertise,
    );

    return calculate(
      input: projectedInput,
      activeTsunamis: activeTsunamis,
    ).totalScore;
  }
}

/// Extension for rounding doubles to specific decimal places
extension _DoubleRounding on double {
  double roundTo(int places) {
    double factor = 1.0;
    for (int i = 0; i < places; i++) {
      factor *= 10.0;
    }
    return (this * factor).round() / factor;
  }
}
