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
  double fromJson(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  Object? toJson(double value) => value;
}

@Freezed(fromJson: false, toJson: false)
@JsonSerializable(fieldRename: FieldRename.snake)
class Brand with _$Brand {
  const factory Brand({
    required String playerId,
    @Default(50) int heat, // 0–100 Brand Heat (GDD §8.9.7)
    @_SafeDouble() @Default(0.0) double hypeScore,
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
    // Directive H: Crisis Engine — Tarnish & Kintsugi (GDD §8.9.2)
    @Default(0) int currentTarnish, // 0-100 reputation damage
    @Default(0) int kintsugiLevel, // Number of successful repairs
    @Default(0) int totalScandalsSurvived,
    @Default(0) int prestigeTokens, // Future Gacha system
    String? marketTier, // high_luxury / mid_luxury / mass_market
    Map<String, dynamic>? avatarConfiguration,
    // Directive L: Supply Chain & Buffer Stock Engine (GDD §12.1.2)
    @Default(5000) int warehouseCapacity, // Max inventory storage
    @Default(0) int currentInventoryValue, // Current stored inventory
    @Default(1) int logisticsLevel, // Warehouse upgrade tier
  }) = _Brand;

  factory Brand.fromJson(Map<String, dynamic> json) => _$BrandFromJson(json);

  /// Decodes only the reviewed `api.brand_summary` owner projection.
  ///
  /// Wallet and private-profile fields are deliberately absent from that
  /// projection, so they retain the domain defaults instead of being inferred
  /// or fetched through a broader client authority path.
  static Brand fromSummaryJson(Map<String, dynamic> json) {
    return Brand(
      playerId: _requiredSummaryString(json['player_id'], 'player_id'),
      heat: _summaryInt(json['heat'], fallback: 50),
      hypeScore: const _SafeDouble().fromJson(json['hype_score']),
      followers: _summaryInt(json['followers']),
      idleRevenuePerHour:
          const _SafeDouble().fromJson(json['idle_revenue_per_hour']),
      totalRevenue: const _SafeDouble().fromJson(json['total_revenue']),
      momentumBuffActive: _summaryBool(json['momentum_buff_active']),
      momentumBuffUntil: _summaryDateTime(json['momentum_buff_until']),
      lastActiveAt: _summaryDateTime(json['last_active_at']),
      sustainabilityTier: _summaryInt(json['sustainability_tier']),
      dppEnabled: _summaryBool(json['dpp_enabled']),
      dppFullyMapped: _summaryBool(json['dpp_fully_mapped']),
      founderRep: _summaryInt(json['founder_rep'], fallback: 50),
      currentTarnish: _summaryInt(json['current_tarnish']),
      kintsugiLevel: _summaryInt(json['kintsugi_level']),
      totalScandalsSurvived: _summaryInt(json['total_scandals_survived']),
      marketTier: _summaryString(json['market_tier']),
      warehouseCapacity:
          _summaryInt(json['warehouse_capacity'], fallback: 5000),
      currentInventoryValue: _summaryInt(json['current_inventory_value']),
      logisticsLevel: _summaryInt(json['logistics_level'], fallback: 1),
    );
  }
}

String _requiredSummaryString(Object? value, String field) {
  final String? result = _summaryString(value);
  if (result == null) {
    throw FormatException('Missing required brand summary field: $field');
  }
  return result;
}

String? _summaryString(Object? value) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  return null;
}

int _summaryInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

bool _summaryBool(Object? value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
  }
  return fallback;
}

DateTime? _summaryDateTime(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
