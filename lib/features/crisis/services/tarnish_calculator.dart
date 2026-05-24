// Directive H — Tarnish Calculator
// GDD §8.9.2 — Kode Formula: finalTarnish = base / (1 + kintsugi*0.25 + sovereign*0.15)
// Alabaster Standard: Deterministic, fair, mathematically elegant

import 'dart:math' as math;

/// Tarnish Impact Calculator
///
/// Calculates scandal impact based on brand resilience:
/// - Kintsugi Level: +25% resistance per level (survived scandals)
/// - Sovereign Multipliers: +15% resistance per ascension
///
/// Formula: finalTarnish = baseSeverity / (1 + kintsugiResist + sovereignResist)
class TarnishCalculator {
  const TarnishCalculator._();

  /// Calculate final tarnish from a scandal event using Kode formula
  ///
  /// [baseSeverity]: Raw scandal severity (1-100)
  /// [kintsugiLevel]: Number of successful Kintsugi repairs
  /// [sovereignMultipliers]: From Hall of Sovereigns ascensions
  /// [currentTarnish]: Existing tarnish (for clamping)
  static int calculateFinalTarnish({
    required int baseSeverity,
    required int kintsugiLevel,
    required int sovereignMultipliers,
    int currentTarnish = 0,
  }) {
    // Kode Formula: resistance multiplier
    final double resistance =
        1.0 + (kintsugiLevel * 0.25) + (sovereignMultipliers * 0.15);

    // Calculate reduced tarnish
    final double rawFinal = baseSeverity / resistance;
    final int calculatedTarnish = rawFinal.ceil();

    // Clamp to 0-100 total
    final int newTotal = (currentTarnish + calculatedTarnish).clamp(0, 100);

    // Return just the increment, not the total
    return newTotal - currentTarnish;
  }

  /// Calculate total tarnish after adding new scandal
  static int calculateTotalTarnish({
    required int currentTarnish,
    required int incomingSeverity,
    required int kintsugiLevel,
    required int sovereignMultipliers,
  }) {
    final int finalTarnish = calculateFinalTarnish(
      baseSeverity: incomingSeverity,
      kintsugiLevel: kintsugiLevel,
      sovereignMultipliers: sovereignMultipliers,
      currentTarnish: currentTarnish,
    );

    return (currentTarnish + finalTarnish).clamp(0, 100);
  }

  /// Check if incoming scandal would trigger lockdown (tarnish >= 100)
  static bool wouldCauseLockdown({
    required int currentTarnish,
    required int incomingSeverity,
    required int kintsugiLevel,
    required int sovereignMultipliers,
  }) {
    final int projectedTotal = calculateTotalTarnish(
      currentTarnish: currentTarnish,
      incomingSeverity: incomingSeverity,
      kintsugiLevel: kintsugiLevel,
      sovereignMultipliers: sovereignMultipliers,
    );
    return projectedTotal >= 100;
  }

  /// Calculate Kintsugi repair cost (30% of capital)
  static double calculateKintsugiCapitalCost(double currentCapital) {
    return currentCapital * 0.30;
  }

  /// Calculate apology cost (10% of capital)
  static double calculateApologyCapitalCost(double currentCapital) {
    return currentCapital * 0.10;
  }

  /// Get visual degradation tier based on tarnish level
  static TarnishVisualTier getVisualTier(int tarnish) {
    if (tarnish <= 20) return TarnishVisualTier.pristine;
    if (tarnish <= 50) return TarnishVisualTier.fractured;
    if (tarnish <= 99) return TarnishVisualTier.obsidian;
    return TarnishVisualTier.lockdown;
  }

  /// Get descriptive text for tarnish level
  static String getTarnishDescription(int tarnish) {
    return switch (getVisualTier(tarnish)) {
      TarnishVisualTier.pristine => 'Reputation Pristine',
      TarnishVisualTier.fractured => 'Hairline Fractures Detected',
      TarnishVisualTier.obsidian => 'Obsidian Sludge Accumulating',
      TarnishVisualTier.lockdown =>
        'BRAND LOCKDOWN - IMMEDIATE ACTION REQUIRED',
    };
  }
}

/// Visual degradation tiers for HQ overlay
enum TarnishVisualTier {
  pristine, // 0-20: Pure Alabaster
  fractured, // 21-50: Grey hairline fractures
  obsidian, // 51-99: Obsidian sludge, desaturated gold
  lockdown, // 100: Total lockdown, idle halted
}

/// Seeded random generator for deterministic scars
///
/// Kode Addendum: Fracture paths must be unique per player but consistent
/// across app restarts. Use brand_name hash as seed.
class SeededRandom {
  final math.Random _random;

  SeededRandom(String seed) : _random = math.Random(seed.hashCode);

  double nextDouble() => _random.nextDouble();
  int nextInt(int max) => _random.nextInt(max);

  /// Generate list of random values seeded from player identity
  static List<double> generateSeededValues(String playerId, int count) {
    final SeededRandom seeded = SeededRandom(playerId);
    return List<double>.generate(count, (_) => seeded.nextDouble());
  }
}
