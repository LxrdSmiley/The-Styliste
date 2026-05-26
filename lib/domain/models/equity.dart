// ignore_for_file: invalid_annotation_target

// GDD §5.5–5.6 — Equity / IPO / stock system
// IPO unlocks at Brand Rank 60. Hostile takeover at 51%+ ownership.
// All equity mutations are server-authoritative (PROJECT_RULES §3).

import 'package:freezed_annotation/freezed_annotation.dart';

part 'equity.freezed.dart';
part 'equity.g.dart';

enum ShareType {
  @JsonValue('common')
  common,
  @JsonValue('preferred')
  preferred,
}

@freezed
class BrandEquity with _$BrandEquity {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory BrandEquity({
    required String brandId,
    @Default(0) int totalShares,
    @Default(0.0) double sharePrice,
    @Default(0.0) double valuation,
    @Default(false) bool isPublic,
    @Default(0.0) double dividendPayoutRatio,
    DateTime? ipoAt,
  }) = _BrandEquity;

  factory BrandEquity.fromJson(Map<String, dynamic> json) =>
      _$BrandEquityFromJson(json);
}

@freezed
class EquityPosition with _$EquityPosition {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory EquityPosition({
    required String id,
    required String holderId,
    required String brandId,
    required ShareType shareType,
    @Default(0) int sharesOwned,
    @Default(0.0) double averagePurchasePrice,
    DateTime? acquiredAt,
  }) = _EquityPosition;

  factory EquityPosition.fromJson(Map<String, dynamic> json) =>
      _$EquityPositionFromJson(json);
}
