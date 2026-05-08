// GDD v6 §3 — Hype Score Calculator with Trend Tsunami Multiplier
// Alabaster Standard: Real-time 48h player-driven trend integration
// 
// Formula: H_score = (Base_Score × Tsunami_Multiplier) + Sovereign_Talent_Bonus
//
// Tsunami Multipliers:
//   - Crest Tag (Rank 1): 2.5x
//   - Surge Tags (Rank 2-3): 1.5x
//   - No match: 1.0x

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
    return materialQuality >= 0 && materialQuality <= 100 &&
           aestheticAlignment >= 0 && aestheticAlignment <= 100 &&
           sovereignTalentCount >= 0 &&
           totalTalentExpertise >= 0 && totalTalentExpertise <= 100;
  }
}

/// Result of hype score calculation with breakdown
class HypeCalculationResult {
  /// Final calculated hype score
  final double totalScore;
  
  /// Base score before any multipliers (material + aesthetic)
  final double baseScore;
  
  /// Tsunami multiplier applied (1.0, 1.5, or 2.5)
  final double tsunamiMultiplier;
  
  /// Sovereign talent bonus added
  final double talentBonus;
  
  /// The matching tsunami tag (if any)
  final String? matchingTsunamiTag;
  
  /// Whether the match was a Crest (2.5x) or Surge (1.5x)
  final bool wasCrestMatch;

  const HypeCalculationResult({
    required this.totalScore,
    required this.baseScore,
    required this.tsunamiMultiplier,
    required this.talentBonus,
    this.matchingTsunamiTag,
    this.wasCrestMatch = false,
  });

  /// Display multiplier as string (e.g., "2.5x", "1.5x", "1.0x")
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
      throw ArgumentError('Invalid hype calculation input: parameters out of range');
    }

    // Step 1: Calculate base score from material and aesthetic
    final double materialComponent = input.materialQuality * config.materialQualityWeight;
    final double aestheticComponent = input.aestheticAlignment * config.aestheticAlignmentWeight;
    final double baseScore = (materialComponent + aestheticComponent) * config.baseMultiplier;

    // Step 2: Find the best tsunami multiplier for the design's tags
    double tsunamiMultiplier = 1.0;
    String? matchingTag;
    bool wasCrest = false;

    if (activeTsunamis.isNotEmpty) {
      // Check for Crest match first (highest priority)
      final TrendTsunami? crest = activeTsunamis.crestTag;
      if (crest != null) {
        final double? crestMatch = crest.getMultiplierForAnyTag(input.styleTags);
        if (crestMatch != null) {
          tsunamiMultiplier = crestMatch;
          matchingTag = crest.tagName;
          wasCrest = true;
        }
      }

      // If no Crest match, check Surge tags
      if (tsunamiMultiplier == 1.0) {
        for (final TrendTsunami surge in activeTsunamis.surgeTags) {
          final double? surgeMatch = surge.getMultiplierForAnyTag(input.styleTags);
          if (surgeMatch != null) {
            tsunamiMultiplier = surgeMatch;
            matchingTag = surge.tagName;
            wasCrest = false;
            break; // Only first Surge match applies
          }
        }
      }
    }

    // Step 3: Calculate sovereign talent bonus (GDD §8.10)
    final double talentBonus = input.sovereignTalentCount > 0
        ? input.totalTalentExpertise * config.talentBonusPerLevel * input.sovereignTalentCount
        : 0.0;

    // Step 4: Calculate final score
    final double tsunamiAdjustedScore = baseScore * tsunamiMultiplier;
    final double totalScore = tsunamiAdjustedScore + talentBonus;

    return HypeCalculationResult(
      totalScore: totalScore.roundTo(2),
      baseScore: baseScore.roundTo(2),
      tsunamiMultiplier: tsunamiMultiplier,
      talentBonus: talentBonus.roundTo(2),
      matchingTsunamiTag: matchingTag,
      wasCrestMatch: wasCrest,
    );
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
    final double mod = 10.0 * places;
    return (this * mod).round() / mod;
  }
}
