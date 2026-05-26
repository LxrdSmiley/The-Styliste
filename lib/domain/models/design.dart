// ignore_for_file: invalid_annotation_target

// GDD §4.1 — Design / Alpha piece entity
// Designer path core asset: hype score, alpha status, fabric data

import 'package:freezed_annotation/freezed_annotation.dart';

part 'design.freezed.dart';
part 'design.g.dart';

/// Supabase can deserialize Postgres numeric values as int, double, or String
/// depending on the path. Keep design parsing tolerant because mint-design owns
/// hype_score now.
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

enum DesignSessionType {
  @JsonValue('quick_sketch')
  quickSketch,
  @JsonValue('deep_session')
  deepSession,
}

enum DesignStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('complete')
  complete,
  @JsonValue('dropped')
  dropped,
  @JsonValue('retired')
  retired,
}

@freezed
class Design with _$Design {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory Design({
    required String id,
    required String playerId,
    required String name,
    required DesignSessionType sessionType,
    @Default(DesignStatus.draft) DesignStatus status,
    @Default(0.0) @_SafeDouble() double hypeScore,
    @Default(false) bool isAlpha,
    @Default(false) bool isDigitalTwin, // GDD §8.9.14
    @Default(false) bool dppRegistered,
    @Default(<String, dynamic>{}) Map<String, dynamic> fabricData,
    @Default(0.0) @_SafeDouble() double sellPotential,
    @Default(0.0) @_SafeDouble() double culturalImpact,
    DateTime? createdAt,
    DateTime? droppedAt,
  }) = _Design;

  factory Design.fromJson(Map<String, dynamic> json) => _$DesignFromJson(json);
}

extension DesignExtension on Design {
  String get fabricTier => fabricData['tier'] as String? ?? 'standard_cotton';
}
