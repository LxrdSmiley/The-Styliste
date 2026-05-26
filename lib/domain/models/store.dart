// ignore_for_file: invalid_annotation_target

// GDD §5.2 — Store entity (Physical Flagship + Online E-Commerce)
// Mogul path core asset. Revenue is server-computed.
// Phase 5: _SafeDouble converter on NUMERIC fields — Postgres may return int
// when value is a whole number; prevents 'int is not subtype of double' crash.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'store.freezed.dart';
part 'store.g.dart';

/// Safe coercion: num → double. Guards against Postgres NUMERIC → int JSON.
class _SafeDouble implements JsonConverter<double, Object?> {
  const _SafeDouble();
  @override
  double fromJson(Object? value) => (value as num?)?.toDouble() ?? 0.0;
  @override
  Object? toJson(double value) => value;
}

enum StoreType {
  @JsonValue('flagship')
  flagship,
  @JsonValue('ecommerce')
  ecommerce,
}

enum StoreCity {
  @JsonValue('new_york')
  newYork,
  @JsonValue('paris')
  paris,
  @JsonValue('tokyo')
  tokyo,
  @JsonValue('london')
  london,
  @JsonValue('milan')
  milan,
  @JsonValue('seoul')
  seoul,
  @JsonValue('nairobi')
  nairobi,
  @JsonValue('sao_paulo')
  saoPaulo,
  @JsonValue('amsterdam')
  amsterdam,
  @JsonValue('los_angeles')
  losAngeles,
}

@freezed
class Store with _$Store {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory Store({
    required String id,
    required String playerId,
    required StoreType type,
    required StoreCity city,
    @Default(1) int tier,
    @Default(0.0) @_SafeDouble() double revenuePerHour,
    @Default(100) int loyalty, // 0–100
    @Default(0.0) @_SafeDouble() double marketShare, // 0.0–1.0
    String? maisonId, // null if solo-owned
    DateTime? openedAt,
  }) = _Store;

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
}
