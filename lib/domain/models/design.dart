// GDD §4.1 — Design / Alpha piece entity
// Designer path core asset: hype score, alpha status, fabric data

import 'package:freezed_annotation/freezed_annotation.dart';

part 'design.freezed.dart';
part 'design.g.dart';

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
  const factory Design({
    required String id,
    required String playerId,
    required String name,
    required DesignSessionType sessionType,
    @Default(DesignStatus.draft) DesignStatus status,
    @Default(0.0) double hypoScore,
    @Default(false) bool isAlpha,
    @Default(false) bool isDigitalTwin,    // GDD §8.9.14
    @Default(false) bool dppRegistered,
    @Default(<String, dynamic>{}) Map<String, dynamic> fabricData,
    @Default(0.0) double sellPotential,
    @Default(0.0) double culturalImpact,
    DateTime? createdAt,
    DateTime? droppedAt,
  }) = _Design;

  factory Design.fromJson(Map<String, dynamic> json) => _$DesignFromJson(json);
}
