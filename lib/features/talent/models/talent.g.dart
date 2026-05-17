// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TalentImpl _$$TalentImplFromJson(Map<String, dynamic> json) => _$TalentImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      tier: $enumDecode(_$TalentTierEnumMap, json['tier']),
      portraitUrl: json['portrait_url'] as String?,
      baseHypeMultiplier:
          (json['base_hype_multiplier'] as num?)?.toDouble() ?? 1.0,
      scandalRiskFactor: (json['scandal_risk_factor'] as num?)?.toInt() ?? 0,
      biography: json['biography'] as String?,
      signatureStyle: (json['signature_style'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$$TalentImplToJson(_$TalentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'tier': _$TalentTierEnumMap[instance.tier]!,
      'portrait_url': instance.portraitUrl,
      'base_hype_multiplier': instance.baseHypeMultiplier,
      'scandal_risk_factor': instance.scandalRiskFactor,
      'biography': instance.biography,
      'signature_style': instance.signatureStyle,
      'is_active': instance.isActive,
    };

const _$TalentTierEnumMap = {
  TalentTier.risingStar: 'rising_star',
  TalentTier.established: 'established',
  TalentTier.iconic: 'iconic',
  TalentTier.sovereign: 'sovereign',
};

_$RosterTalentImpl _$$RosterTalentImplFromJson(Map<String, dynamic> json) =>
    _$RosterTalentImpl(
      talentId: json['talent_id'] as String,
      name: json['name'] as String,
      tier: $enumDecode(_$TalentTierEnumMap, json['tier']),
      portraitUrl: json['portrait_url'] as String?,
      baseHypeMultiplier:
          (json['base_hype_multiplier'] as num?)?.toDouble() ?? 1.0,
      scandalRiskFactor: (json['scandal_risk_factor'] as num?)?.toInt() ?? 0,
      biography: json['biography'] as String?,
      signatureStyle: (json['signature_style'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      acquiredAt: json['acquired_at'] == null
          ? null
          : DateTime.parse(json['acquired_at'] as String),
      acquisitionSource:
          json['acquisition_source'] as String? ?? 'casting_call',
      isFavorite: json['is_favorite'] as bool? ?? false,
    );

Map<String, dynamic> _$$RosterTalentImplToJson(_$RosterTalentImpl instance) =>
    <String, dynamic>{
      'talent_id': instance.talentId,
      'name': instance.name,
      'tier': _$TalentTierEnumMap[instance.tier]!,
      'portrait_url': instance.portraitUrl,
      'base_hype_multiplier': instance.baseHypeMultiplier,
      'scandal_risk_factor': instance.scandalRiskFactor,
      'biography': instance.biography,
      'signature_style': instance.signatureStyle,
      'acquired_at': instance.acquiredAt?.toIso8601String(),
      'acquisition_source': instance.acquisitionSource,
      'is_favorite': instance.isFavorite,
    };

_$PullResultImpl _$$PullResultImplFromJson(Map<String, dynamic> json) =>
    _$PullResultImpl(
      talentId: json['talent_id'] as String,
      name: json['name'] as String,
      tier: $enumDecode(_$TalentTierEnumMap, json['tier']),
      isDupe: json['is_dupe'] as bool,
      portraitUrl: json['portrait_url'] as String?,
      prestigeValue: (json['prestige_value'] as num?)?.toInt() ?? 0,
      baseHypeMultiplier: (json['base_hype_multiplier'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$PullResultImplToJson(_$PullResultImpl instance) =>
    <String, dynamic>{
      'talent_id': instance.talentId,
      'name': instance.name,
      'tier': _$TalentTierEnumMap[instance.tier]!,
      'is_dupe': instance.isDupe,
      'portrait_url': instance.portraitUrl,
      'prestige_value': instance.prestigeValue,
      'base_hype_multiplier': instance.baseHypeMultiplier,
    };

_$CastingResultImpl _$$CastingResultImplFromJson(Map<String, dynamic> json) =>
    _$CastingResultImpl(
      pulls: (json['pulls'] as List<dynamic>)
          .map((e) => PullResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      luxeSpent: (json['luxe_spent'] as num?)?.toInt() ?? 0,
      prestigeEarned: (json['prestige_earned'] as num?)?.toInt() ?? 0,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$CastingResultImplToJson(_$CastingResultImpl instance) =>
    <String, dynamic>{
      'pulls': instance.pulls.map((e) => e.toJson()).toList(),
      'luxe_spent': instance.luxeSpent,
      'prestige_earned': instance.prestigeEarned,
      'message': instance.message,
    };

_$PityStateImpl _$$PityStateImplFromJson(Map<String, dynamic> json) =>
    _$PityStateImpl(
      bannerId: json['banner_id'] as String? ?? 'standard',
      pullsSinceSovereign:
          (json['pulls_since_sovereign'] as num?)?.toInt() ?? 0,
      totalPulls: (json['total_pulls'] as num?)?.toInt() ?? 0,
      lastPullAt: json['last_pull_at'] == null
          ? null
          : DateTime.parse(json['last_pull_at'] as String),
    );

Map<String, dynamic> _$$PityStateImplToJson(_$PityStateImpl instance) =>
    <String, dynamic>{
      'banner_id': instance.bannerId,
      'pulls_since_sovereign': instance.pullsSinceSovereign,
      'total_pulls': instance.totalPulls,
      'last_pull_at': instance.lastPullAt?.toIso8601String(),
    };
