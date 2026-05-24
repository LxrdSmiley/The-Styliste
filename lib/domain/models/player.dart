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

extension CareerPathExtension on CareerPath {
  String get displayName {
    switch (this) {
      case CareerPath.designer:
        return 'The Artisan';
      case CareerPath.mogul:
        return 'The Architect';
    }
  }
}

extension CareerPathApi on CareerPath {
  String get apiValue => switch (this) {
        CareerPath.designer => 'designer',
        CareerPath.mogul => 'mogul',
      };
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

extension HqCityApi on HqCity {
  String get apiValue => switch (this) {
        HqCity.newYork => 'new_york',
        HqCity.paris => 'paris',
        HqCity.tokyo => 'tokyo',
        HqCity.london => 'london',
        HqCity.milan => 'milan',
        HqCity.seoul => 'seoul',
        HqCity.nairobi => 'nairobi',
        HqCity.saoPaulo => 'sao_paulo',
      };
}

@freezed
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
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
    // --- Ascension Fields (GDD v6 §3.5) ---
    @Default(false) bool isJointVenture,
    @Default(0) int sovereignMultipliers,
    DateTime? jointVentureUnlockedAt,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    // --- Luxe Relationship (GDD §8.12) ---
    // Trust Score: relationship meter, NOT wealth meter. Default 50 = warm baseline.
    // Increments: +1 daily check-in, +1 gala entry, +2 casting gold, +5 kintsugi
    @Default(50) int luxeTrustScore,
  }) = _Player;

  const Player._();

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  /// Can unlock Joint Venture at Rank 50
  bool get canUnlockJointVenture => brandRank >= 50 && !isJointVenture;

  /// Can memorialize at Rank 100
  bool get canMemorialize => brandRank >= 100;

  /// Sovereign multiplier bonus: +25% per stamp (max 500% at 20 stamps)
  /// Applied to both Hype Score and idle income globally
  double get sovereignMultiplierBonus => 1.0 + (sovereignMultipliers * 0.25);

  /// Formatted bonus display (e.g., "+125%")
  String get sovereignMultiplierDisplay =>
      '+${((sovereignMultiplierBonus - 1.0) * 100).toInt()}%';

  /// Total memorializations / sovereign multipliers count
  int get memorializationCount => sovereignMultipliers;
}
