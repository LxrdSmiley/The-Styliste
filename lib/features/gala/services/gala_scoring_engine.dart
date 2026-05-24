// Directive J — Gala Scoring Engine
// GDD §6.9, §12.3.3 — 4-tier weighted voting with talent multipliers
// Kode Formula: final_points = base_points * (1 + (talent_multiplier - 1) * 0.5)

import 'package:flutter/services.dart';

import '../../../core/theme/aurelian_theme.dart';

/// Vote tiers with escalating power and haptic feedback
///
/// Vote Weights:
/// - Adore: 1 pt (unlimited soft cap at 100/day) — Light tick haptic
/// - Iconic: 3 pts (10/day limit) — Medium pulse haptic
/// - Sovereign: 10 pts (3/day limit) — Heavy double-thud haptic
/// - Timeless: 50 pts (1/day limit, costs 10 Luxe) — Sustained vibration
enum VoteTier {
  adore,
  iconic,
  sovereign,
  timeless,
}

extension VoteTierExtension on VoteTier {
  /// Display name for UI
  String get displayName {
    switch (this) {
      case VoteTier.adore:
        return 'ADORE';
      case VoteTier.iconic:
        return 'ICONIC';
      case VoteTier.sovereign:
        return 'SOVEREIGN';
      case VoteTier.timeless:
        return 'TIMELESS';
    }
  }

  /// Base point value
  int get basePoints {
    switch (this) {
      case VoteTier.adore:
        return 1;
      case VoteTier.iconic:
        return 3;
      case VoteTier.sovereign:
        return 10;
      case VoteTier.timeless:
        return 50;
    }
  }

  /// Daily usage limit
  int get dailyLimit {
    switch (this) {
      case VoteTier.adore:
        return 100; // Soft limit
      case VoteTier.iconic:
        return 10;
      case VoteTier.sovereign:
        return 3;
      case VoteTier.timeless:
        return 1;
    }
  }

  /// Luxe Token cost (only Timeless costs)
  int get luxeCost {
    switch (this) {
      case VoteTier.timeless:
        return 10;
      default:
        return 0;
    }
  }

  /// Tier color for UI
  Color get tierColor {
    switch (this) {
      case VoteTier.adore:
        return const Color(0xFFB8B8B8); // Silver
      case VoteTier.iconic:
        return const Color(0xFFCD7F32); // Bronze
      case VoteTier.sovereign:
        return const Color(0xFFD4AF37); // Gold
      case VoteTier.timeless:
        return AurelianPalette.alabaster; // White (premium)
    }
  }

  /// Execute haptic feedback appropriate to tier
  Future<void> executeHaptic() async {
    switch (this) {
      case VoteTier.adore:
        await HapticFeedback.lightImpact();
      case VoteTier.iconic:
        await HapticFeedback.mediumImpact();
      case VoteTier.sovereign:
        await HapticFeedback.heavyImpact();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.heavyImpact(); // Double-thud
      case VoteTier.timeless:
        // Sustained vibration (like Ascension white-out)
        for (int i = 0; i < 5; i++) {
          await HapticFeedback.vibrate();
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
    }
  }
}

/// Gala Scoring Engine
///
/// Implements Kode Formula for calculating final vote points
/// with talent multipliers.
class GalaScoringEngine {
  /// Calculate final points using Kode Formula
  ///
  /// Formula: final_points = base_points * (1 + (talent_multiplier - 1) * 0.5)
  ///
  /// Example calculations:
  /// - Sovereign vote (10) × no talent (1.0) = 10 pts
  /// - Sovereign vote (10) × Sovereign talent (2.0 = +100%) = 15 pts
  /// - Timeless vote (50) × Iconic talent (1.35 = +35%) = 58.75 pts
  static double calculateFinalPoints(VoteTier tier, double talentMultiplier) {
    final int base = tier.basePoints;
    // Talent bonus: 50% of hype multiplier boost applies to votes
    final double bonus = (talentMultiplier - 1.0) * 0.5;
    return base * (1.0 + bonus);
  }

  /// Format points for UI display (after vote cast, opaque before)
  static String formatPoints(double points) {
    if (points == points.toInt()) {
      return '+${points.toInt()}';
    }
    return '+${points.toStringAsFixed(1)}';
  }

  /// Get vote tier from string (for RPC responses)
  static VoteTier fromString(String tier) {
    switch (tier.toLowerCase()) {
      case 'adore':
        return VoteTier.adore;
      case 'iconic':
        return VoteTier.iconic;
      case 'sovereign':
        return VoteTier.sovereign;
      case 'timeless':
        return VoteTier.timeless;
      default:
        return VoteTier.adore;
    }
  }
}

/// Prize distribution calculator
///
/// Rank 1: 5000 Luxe (The Sovereign)
/// Rank 2: 2000 Luxe
/// Rank 3: 1000 Luxe
/// Ranks 4-10: 450 down to 100 (decreasing by 50)
/// Participation: 50 Luxe
class GalaPrizeCalculator {
  static int calculatePrize(int rank) {
    if (rank == 1) return 5000; // The Sovereign
    if (rank == 2) return 2000;
    if (rank == 3) return 1000;
    if (rank <= 10) return (500 - (rank - 4) * 50).clamp(100, 450);
    return 50; // Participation
  }

  static bool isGalaSovereign(int rank) => rank == 1;
}
