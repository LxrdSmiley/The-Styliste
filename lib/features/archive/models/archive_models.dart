// Directive K — Archive Models
// GDD §8.9.9, §12.4.3 — P2P market with provenance tracking

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../services/provenance_calculator.dart';

part 'archive_models.freezed.dart';
part 'archive_models.g.dart';

/// Archive Listing — P2P market entry
@freezed
class ArchiveListing with _$ArchiveListing {
  const factory ArchiveListing({
    required String id,
    required String sellerId,
    required String designId,
    required int listingPrice,
    DateTime? listedAt,
    DateTime? expiresAt,
    @Default('active') String status,
    @Default(false) bool isGalaWinner,
    String? galaEventId,
    // Enriched fields from view
    String? designName,
    @Default(0) int hypeScore,
    @Default(1.0) double provenanceMultiplier,
    @Default(false) bool hasSovereignProvenance,
    @Default(0) int transferCount,
    String? designImageUrl,
    String? sellerName,
    @Default(1) int sellerRank,
    @Default(false) bool sellerIsSovereign,
    String? galaTheme,
  }) = _ArchiveListing;

  factory ArchiveListing.fromJson(Map<String, dynamic> json) =>
      _$ArchiveListingFromJson(json);

  /// Calculate effective hype with provenance
  int get effectiveHype => ProvenanceCalculator.calculateEffectiveHype(
        hypeScore,
        transferCount,
        hasSovereignProvenance,
      );

  /// Get provenance description
  String get provenanceDescription => ProvenanceCalculator.getProvenanceDescription(
        transferCount,
        hasSovereignProvenance,
      );

  /// Get formatted provenance multiplier
  String get formattedProvenance => ProvenanceCalculator.formatMultiplier(
        provenanceMultiplier,
      );

  /// Time remaining until expiry
  Duration? get timeRemaining {
    if (expiresAt == null) return null;
    return expiresAt!.difference(DateTime.now());
  }

  /// Check if listing is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Formatted time remaining for FOMO display
  String get formattedTimeRemaining {
    if (expiresAt == null) return '';
    return FOMOCountdown.format(expiresAt!);
  }

  /// Get urgency color for countdown
  Color? get urgencyColor {
    if (expiresAt == null) return null;
    return FOMOCountdown.getUrgencyColor(expiresAt!);
  }

  /// Get minimum price floor for this item
  int get priceFloor => ArchivePriceFloor.calculate(hypeScore);

  /// Check if listing price meets floor
  bool get meetsPriceFloor => ArchivePriceFloor.isValid(listingPrice, hypeScore);

  /// Get transaction breakdown (30% tax)
  TransactionBreakdown get transactionBreakdown =>
      ArchiveTransactionCalculator.calculateBreakdown(listingPrice);

  /// Check if provenance is at maximum cap
  bool get isMaxProvenance => ProvenanceCalculator.isAtMaxCap(
        transferCount,
        hasSovereignProvenance,
      );
}

/// Provenance Record — Single ownership transfer
@freezed
class ProvenanceRecord with _$ProvenanceRecord {
  const factory ProvenanceRecord({
    required String id,
    required String designId,
    String? listingId,
    required String previousOwnerId,
    required String newOwnerId,
    required int salePrice,
    required int platformTax,
    required int sellerPayout,
    DateTime? transferredAt,
    // Enriched fields
    String? previousOwnerName,
    int? previousOwnerRank,
    String? newOwnerName,
    int? newOwnerRank,
    String? designName,
  }) = _ProvenanceRecord;

  factory ProvenanceRecord.fromJson(Map<String, dynamic> json) =>
      _$ProvenanceRecordFromJson(json);

  /// Get tax percentage
  double get taxPercentage => (platformTax / salePrice) * 100;

  /// Get payout percentage
  double get payoutPercentage => (sellerPayout / salePrice) * 100;

  /// Format sale price
  String get formattedSalePrice => '\$$salePrice';

  /// Check if previous owner was Sovereign (Rank 100)
  bool get wasSovereignOwner => (previousOwnerRank ?? 0) >= 100;
}

/// Transaction Result — Purchase outcome
@freezed
class PurchaseResult with _$PurchaseResult {
  const factory PurchaseResult({
    required bool success,
    String? transactionId,
    String? message,
    int? newProvenanceCount,
    double? newProvenanceMultiplier,
  }) = _PurchaseResult;

  factory PurchaseResult.fromJson(Map<String, dynamic> json) =>
      _$PurchaseResultFromJson(json);
}

/// Listing Result — Create listing outcome
@freezed
class ListingResult with _$ListingResult {
  const factory ListingResult({
    required bool success,
    String? listingId,
    String? message,
    int? minimumPrice,
  }) = _ListingResult;

  factory ListingResult.fromJson(Map<String, dynamic> json) =>
      _$ListingResultFromJson(json);
}

/// Market Statistics
@freezed
class MarketStats with _$MarketStats {
  const factory MarketStats({
    @Default(0) int totalActiveListings,
    @Default(0) int totalVolume24h,
    @Default(0) double averagePrice,
    @Default(0) int taxBurned24h,
  }) = _MarketStats;

  factory MarketStats.fromJson(Map<String, dynamic> json) =>
      _$MarketStatsFromJson(json);
}
