// Directive K — Provenance Calculator
// GDD §8.9.9, §12.4.3 — Ownership history multipliers with strict caps
// Alabaster Standard: Controlled hyperinflation, mathematical precision

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Provenance Calculator
///
/// Economic Rules (Kode's Resolutions):
/// - +10% per previous owner (cumulative, max 10 owners = +100%)
/// - +50% Sovereign Bump if any previous owner was Rank 100 (Hall of Sovereigns)
/// - Absolute Maximum: +150% total (2.5x multiplier)
///
/// Example Scenarios:
/// - 5 owners, no Sovereign: 1.0 + 0.5 = 1.5x (50% bonus)
/// - 10 owners + Sovereign: 1.0 + 1.0 + 0.5 = 2.5x (150% bonus) [CAP]
/// - 20 owners + Sovereign: Still 2.5x (150% bonus) [HARD CAP]
class ProvenanceCalculator {
  // Constants from Kode's economic model
  static const double _perOwnerBonus = 0.10; // +10% per transfer
  static const double _sovereignBump = 0.50; // +50% if any owner was Rank 100
  static const double _maxTransferBonus = 1.00; // +100% cap from transfers
  static const double _absoluteMaxMultiplier = 2.50; // 2.5x = +150% total
  static const int _maxTransferCount = 10; // Beyond 10, no additional bonus

  /// Calculate provenance multiplier
  ///
  /// [transferCount]: Number of times garment has changed hands
  /// [hasSovereignProvenance]: True if any previous owner was Rank 100
  static double calculateMultiplier(
      int transferCount, bool hasSovereignProvenance) {
    // Base multiplier
    double multiplier = 1.0;

    // Transfer bonus (capped at 10 owners = +100%)
    final double transferBonus =
        (math.min(transferCount, _maxTransferCount) * _perOwnerBonus)
            .clamp(0.0, _maxTransferBonus);
    multiplier += transferBonus;

    // Sovereign bonus (separate, not capped by transfer limit)
    if (hasSovereignProvenance) {
      multiplier += _sovereignBump;
    }

    // Hard cap at absolute maximum
    return multiplier.clamp(1.0, _absoluteMaxMultiplier);
  }

  /// Calculate effective hype score with provenance
  static int calculateEffectiveHype(
      int baseHype, int transferCount, bool hasSovereignProvenance) {
    final double multiplier =
        calculateMultiplier(transferCount, hasSovereignProvenance);
    return (baseHype * multiplier).round();
  }

  /// Get formatted provenance description for UI
  static String getProvenanceDescription(
      int transferCount, bool hasSovereignProvenance) {
    final List<String> parts = <String>[];

    if (transferCount > 0) {
      final int cappedCount = math.min(transferCount, _maxTransferCount);
      if (transferCount > _maxTransferCount) {
        parts.add('$cappedCount+ previous owners (max provenance)');
      } else {
        parts.add(
            '$transferCount previous ${transferCount == 1 ? 'owner' : 'owners'}');
      }
    }

    if (hasSovereignProvenance) {
      parts.add('Sovereign provenance');
    }

    if (parts.isEmpty) {
      return 'Mint condition';
    }

    return parts.join(' • ');
  }

  /// Get detailed provenance breakdown
  static ProvenanceBreakdown getBreakdown(
      int transferCount, bool hasSovereignProvenance) {
    final double transferBonus =
        (math.min(transferCount, _maxTransferCount) * _perOwnerBonus)
            .clamp(0.0, _maxTransferBonus);
    final double sovereignBonus = hasSovereignProvenance ? _sovereignBump : 0.0;
    final double totalBonus = (transferBonus + sovereignBonus).clamp(0.0, 1.50);

    return ProvenanceBreakdown(
      baseMultiplier: 1.0,
      transferBonus: transferBonus,
      sovereignBonus: sovereignBonus,
      totalMultiplier: 1.0 + totalBonus,
      capped: transferCount > _maxTransferCount,
    );
  }

  /// Format multiplier for display (e.g., "+150%")
  static String formatMultiplier(double multiplier) {
    final int percentage = ((multiplier - 1.0) * 100).round();
    if (percentage <= 0) return '';
    return '+$percentage%';
  }

  /// Check if provenance is at maximum cap
  static bool isAtMaxCap(int transferCount, bool hasSovereignProvenance) {
    final double multiplier =
        calculateMultiplier(transferCount, hasSovereignProvenance);
    return multiplier >= _absoluteMaxMultiplier;
  }
}

/// Detailed breakdown of provenance calculation
class ProvenanceBreakdown {
  const ProvenanceBreakdown({
    required this.baseMultiplier,
    required this.transferBonus,
    required this.sovereignBonus,
    required this.totalMultiplier,
    required this.capped,
  });

  final double baseMultiplier; // Always 1.0
  final double transferBonus; // 0.0 to 1.0
  final double sovereignBonus; // 0.0 or 0.5
  final double totalMultiplier; // 1.0 to 2.5
  final bool capped; // True if transfer count > 10

  double get totalBonus => totalMultiplier - 1.0;

  String get formattedTotal =>
      ProvenanceCalculator.formatMultiplier(totalMultiplier);
}

/// Price floor calculator
class ArchivePriceFloor {
  /// Calculate minimum listing price
  ///
  /// Rule: GREATEST(1000, hypeScore * 10)
  static int calculate(int hypeScore) {
    return math.max(1000, hypeScore * 10);
  }

  /// Validate price against floor
  static bool isValid(int price, int hypeScore) {
    return price >= calculate(hypeScore);
  }

  /// Get formatted floor price message
  static String getFloorMessage(int hypeScore) {
    final int floor = calculate(hypeScore);
    return 'Minimum listing price: \$$floor (based on $hypeScore hype)';
  }
}

/// Transaction calculator (30% tax burn)
class ArchiveTransactionCalculator {
  static const double _taxRate = 0.30; // 30%
  static const double _payoutRate = 0.70; // 70%

  /// Calculate tax amount (rounded down)
  static int calculateTax(int salePrice) {
    return (salePrice * _taxRate).floor();
  }

  /// Calculate seller payout (rounded down)
  static int calculatePayout(int salePrice) {
    return (salePrice * _payoutRate).floor();
  }

  /// Get transaction breakdown
  static TransactionBreakdown calculateBreakdown(int salePrice) {
    final int tax = calculateTax(salePrice);
    final int payout = calculatePayout(salePrice);
    final int roundingError = salePrice - tax - payout; // Should be 0 or 1

    return TransactionBreakdown(
      salePrice: salePrice,
      platformTax: tax,
      sellerPayout: payout + roundingError, // Give rounding error to seller
      buyerTotal: salePrice,
    );
  }
}

class TransactionBreakdown {
  const TransactionBreakdown({
    required this.salePrice,
    required this.platformTax,
    required this.sellerPayout,
    required this.buyerTotal,
  });

  final int salePrice;
  final int platformTax; // 30% — burned/deflationary
  final int sellerPayout; // 70% — received by seller
  final int buyerTotal; // Full price paid by buyer

  double get taxPercentage => (platformTax / salePrice) * 100;
  double get payoutPercentage => (sellerPayout / salePrice) * 100;
}

/// Time remaining formatter for 48-hour FOMO
class FOMOCountdown {
  static String format(DateTime expiresAt) {
    final Duration remaining = expiresAt.difference(DateTime.now());

    if (remaining.isNegative) {
      return 'EXPIRED';
    }

    final int hours = remaining.inHours;
    final int minutes = remaining.inMinutes % 60;

    if (hours >= 24) {
      final int days = hours ~/ 24;
      final int remainingHours = hours % 24;
      return '${days}d ${remainingHours}h';
    }

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }

    return '${minutes}m';
  }

  /// Get urgency color based on time remaining
  static Color getUrgencyColor(DateTime expiresAt) {
    final Duration remaining = expiresAt.difference(DateTime.now());

    if (remaining.isNegative) {
      return const Color(0xFF666666); // Grey
    }

    if (remaining.inHours < 6) {
      return const Color(0xFFFF4444); // Red — urgent
    }

    if (remaining.inHours < 24) {
      return const Color(0xFFFFAA00); // Orange — warning
    }

    return const Color(0xFF44AA44); // Green — safe
  }
}
