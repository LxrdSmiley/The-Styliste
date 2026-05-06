// GDD §3 — Player entity: core identity and progression state
// Freezed + JsonSerializable for type-safe serialization (PROJECT_RULES §3)

import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';
part 'player.g.dart';

/// Designer or Mogul career path (GDD §1.1 Screen 6)
enum CareerPath {
  @JsonValue('designer')
  designer,
  @JsonValue('mogul')
  mogul,
}

/// Starting HQ city and market tier (GDD §1.1 Screen 4)
enum HqCity {
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
}

@freezed
class Player with _$Player {
  const factory Player({
    required String id,
    required String brandName,
    required CareerPath path,
    required HqCity hqCity,
    @Default(1) int brandRank,
    @Default(0) int totalXp,
    @Default(false) bool onboardingComplete,
    @Default(false) bool isAnonymous,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}
