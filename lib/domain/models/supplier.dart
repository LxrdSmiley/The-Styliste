// GDD §5.1 — Supplier entity
// Tiered: Local → Regional → International → Luxury
// Rated on Quality, Cost, Reliability, Prestige

import 'package:freezed_annotation/freezed_annotation.dart';

part 'supplier.freezed.dart';
part 'supplier.g.dart';

enum SupplierTier {
  @JsonValue('local')
  local,
  @JsonValue('regional')
  regional,
  @JsonValue('international')
  international,
  @JsonValue('luxury')
  luxury,
  @JsonValue('black_market')
  blackMarket,   // GDD §8.9.3 — emergency crisis sourcing
}

enum SupplierCategory {
  @JsonValue('raw_materials')
  rawMaterials,
  @JsonValue('manufacturing')
  manufacturing,
  @JsonValue('logistics')
  logistics,
}

@freezed
class Supplier with _$Supplier {
  const factory Supplier({
    required String id,
    required String name,
    required SupplierTier tier,
    required SupplierCategory category,
    @Default(50) int quality,       // 0–100
    @Default(50) int cost,          // 0–100 (higher = more expensive)
    @Default(50) int reliability,   // 0–100
    @Default(50) int prestige,      // 0–100
    @Default(false) bool livingWageEnabled,       // GDD §8.9.4
    @Default(false) bool blockchainTraceable,     // GDD §8.9.4
    @Default(false) bool ethicalSupplierBadge,
  }) = _Supplier;

  factory Supplier.fromJson(Map<String, dynamic> json) =>
      _$SupplierFromJson(json);
}

@freezed
class SupplyChainContract with _$SupplyChainContract {
  const factory SupplyChainContract({
    required String id,
    required String playerId,
    required String supplierId,
    required SupplierTier tier,
    @Default(false) bool exclusivity,
    DateTime? contractExpiresAt,
  }) = _SupplyChainContract;

  factory SupplyChainContract.fromJson(Map<String, dynamic> json) =>
      _$SupplyChainContractFromJson(json);
}
