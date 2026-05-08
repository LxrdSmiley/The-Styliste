// GDD v6 — Maison District Warfare Models
// 9 districts across 3 cities, 30-day Aurelian Watermarks
// Alabaster Standard: Hybrid Capital+Hype power formula

import 'package:freezed_annotation/freezed_annotation.dart';

part 'fashion_district.freezed.dart';
part 'fashion_district.g.dart';

/// A fashion district — hyper-localized territory for Maison control
/// 
/// 9 districts total: 3 cities × 3 districts each
/// - NYC: SoHo, Meatpacking, Williamsburg
/// - Tokyo: Ginza, Harajuku, Shibuya
/// - Paris: Le Marais, Saint-Germain, Montmartre
@freezed
class FashionDistrict with _$FashionDistrict {
  const factory FashionDistrict({
    required String id,
    required String name,
    required String city,
    String? controllingMaisonId,
    DateTime? controlledSince,
    required int baseTakeoverCost,
    @Default(0) int totalHype,
    required DateTime createdAt,
  }) = _FashionDistrict;

  const FashionDistrict._();

  factory FashionDistrict.fromJson(Map<String, Object?> json) =>
      _$FashionDistrictFromJson(json);

  /// Days since district was controlled (0 if unowned)
  int get daysControlled {
    if (controlledSince == null) return 0;
    return DateTime.now().difference(controlledSince!).inDays;
  }

  /// Whether district has achieved 30-day legacy watermark
  /// UI renders Aurelian watermark when true
  bool get hasLegacyWatermark => daysControlled >= 30;

  /// Whether district is currently unowned
  bool get isUnowned => controllingMaisonId == null;

  /// Whether district is controlled (not unowned)
  bool get isControlled => controllingMaisonId != null;

  /// Defense multiplier for current controller
  /// +5% per day held, capped at 2.5x
  double get defenseMultiplier {
    if (!isControlled) return 1.0;
    final double multiplier = 1.0 + (daysControlled * 0.05);
    return multiplier > 2.5 ? 2.5 : multiplier;
  }

  /// Display string for defense multiplier (e.g., "1.25x")
  String get defenseMultiplierDisplay => '${defenseMultiplier.toStringAsFixed(2)}x';

  /// Cost to attempt takeover (base cost, actual bid may need to exceed defender power)
  String get takeoverCostFormatted => '\$${baseTakeoverCost.toStringAsFixed(0)}';

  /// City group identifier for UI clustering
  String get cityGroup => city.toLowerCase().replaceAll(' ', '_');
}

/// Permanent legacy watermark for 30-day district control
@freezed
class DistrictWatermark with _$DistrictWatermark {
  const factory DistrictWatermark({
    required String id,
    required String maisonId,
    required String districtId,
    required DateTime achievedAt,
  }) = _DistrictWatermark;

  factory DistrictWatermark.fromJson(Map<String, Object?> json) =>
      _$DistrictWatermarkFromJson(json);
}

/// Takeover attempt result from RPC
@freezed
class TakeoverResult with _$TakeoverResult {
  const factory TakeoverResult({
    required bool success,
    required String message,
    String? newController,
    @Default(1.0) double defenseMultiplier,
  }) = _TakeoverResult;

  factory TakeoverResult.fromJson(Map<String, Object?> json) =>
      _$TakeoverResultFromJson(json);
}

/// District with extended info for UI (includes maison name, member hype, etc.)
@freezed
class DistrictDetails with _$DistrictDetails {
  const factory DistrictDetails({
    required FashionDistrict district,
    String? controllingMaisonName,
    String? controllingMaisonTag,
    int? controllingMaisonTreasury,
    int? controllingMaisonHype,
    bool hasWatermark = false,
  }) = _DistrictDetails;
}

/// Extension methods for district list operations
extension DistrictListExtension on List<FashionDistrict> {
  /// Get districts by city
  List<FashionDistrict> byCity(String city) =>
      where((FashionDistrict d) => d.city == city).toList();

  /// Get controlled districts only
  List<FashionDistrict> get controlledOnly =>
      where((FashionDistrict d) => d.isControlled).toList();

  /// Get unowned districts only
  List<FashionDistrict> get unownedOnly =>
      where((FashionDistrict d) => d.isUnowned).toList();

  /// Get districts with legacy watermarks
  List<FashionDistrict> get withWatermark =>
      where((FashionDistrict d) => d.hasLegacyWatermark).toList();

  /// Sort by city, then by name
  List<FashionDistrict> get sorted =>
      this..sort((FashionDistrict a, FashionDistrict b) {
        final int cityCompare = a.city.compareTo(b.city);
        if (cityCompare != 0) return cityCompare;
        return a.name.compareTo(b.name);
      });

  /// Group by city
  Map<String, List<FashionDistrict>> get byCityGroup {
    final Map<String, List<FashionDistrict>> result = <String, List<FashionDistrict>>{};
    for (final FashionDistrict district in this) {
      result.putIfAbsent(district.city, () => <FashionDistrict>[]).add(district);
    }
    return result;
  }
}
