// GDD §8.9.7 — Brand Heat system + hype/followers/revenue state
// Server-authoritative state: client reads, never writes directly.
//
// Phase 3 directive: Postgres NUMERIC fields may be serialized as int when the
// value is a whole number. _toDouble() guards against 'int is not a subtype of
// double' crash loops in the ticker and any other double consumer.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'brand.freezed.dart';
part 'brand.g.dart';

/// Phase 3 directive: Postgres NUMERIC fields may arrive as int when the value
/// is a whole number. This converter safely coerces num → double.
class _SafeDouble implements JsonConverter<double, Object?> {
  const _SafeDouble();
  @override
  double fromJson(Object? value) => (value as num?)?.toDouble() ?? 0.0;
  @override
  Object? toJson(double value) => value;
}

@freezed
class Brand with _$Brand {
  const factory Brand({
    required String playerId,
    @Default(50) int heat,          // 0–100 Brand Heat (GDD §8.9.7)
    @_SafeDouble() @Default(0.0) double hypoScore,
    @Default(0) int followers,
    @_SafeDouble() @Default(0.0) double idleRevenuePerHour,
    @_SafeDouble() @Default(0.0) double totalRevenue,
    @Default(false) bool momentumBuffActive,
    DateTime? momentumBuffUntil,
    DateTime? lastActiveAt,
    // Sustainability (GDD §8.9.5)
    @Default(0) int sustainabilityTier,
    @Default(false) bool dppEnabled,
    @Default(false) bool dppFullyMapped,
    // Founder Rep (GDD §8.9.8)
    @Default(50) int founderRep,
    // Luxe Tokens — hard currency (GDD §9.8); minted by validate-iap Edge Function.
    @Default(0) int luxeTokens,
  }) = _Brand;

  factory Brand.fromJson(Map<String, dynamic> json) => _$BrandFromJson(json);
}
