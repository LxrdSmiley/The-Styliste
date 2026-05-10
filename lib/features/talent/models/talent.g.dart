// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TalentImpl _$$TalentImplFromJson(Map<String, dynamic> json) => _$TalentImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      tier: $enumDecode(_$TalentTierEnumMap, json['tier']),
      portraitUrl: json['portraitUrl'] as String?,
      baseHypeMultiplier:
          (json['baseHypeMultiplier'] as num?)?.toDouble() ?? 1.0,
      scandalRiskFactor: (json['scandalRiskFactor'] as num?)?.toInt() ?? 0,
      biography: json['biography'] as String?,
      signatureStyle: (json['signatureStyle'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$TalentImplToJson(_$TalentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'tier': _$TalentTierEnumMap[instance.tier]!,
      'portraitUrl': instance.portraitUrl,
      'baseHypeMultiplier': instance.baseHypeMultiplier,
      'scandalRiskFactor': instance.scandalRiskFactor,
      'biography': instance.biography,
      'signatureStyle': instance.signatureStyle,
      'isActive': instance.isActive,
    };

const _$TalentTierEnumMap = {
  TalentTier.risingStar: 'rising_star',
  TalentTier.established: 'established',
  TalentTier.iconic: 'iconic',
  TalentTier.sovereign: 'sovereign',
};

_$RosterTalentImpl _$$RosterTalentImplFromJson(Map<String, dynamic> json) =>
    _$RosterTalentImpl(
      talentId: json['talentId'] as String,
      name: json['name'] as String,
      tier: $enumDecode(_$TalentTierEnumMap, json['tier']),
      portraitUrl: json['portraitUrl'] as String?,
      baseHypeMultiplier: (json['baseHypeMultiplier'] as num).toDouble(),
      scandalRiskFactor: (json['scandalRiskFactor'] as num?)?.toInt() ?? 0,
      biography: json['biography'] as String?,
      acquiredAt: json['acquiredAt'] == null
          ? null
          : DateTime.parse(json['acquiredAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      prestigeValue: (json['prestigeValue'] as num).toInt(),
    );

Map<String, dynamic> _$$RosterTalentImplToJson(_$RosterTalentImpl instance) =>
    <String, dynamic>{
      'talentId': instance.talentId,
      'name': instance.name,
      'tier': _$TalentTierEnumMap[instance.tier]!,
      'portraitUrl': instance.portraitUrl,
      'baseHypeMultiplier': instance.baseHypeMultiplier,
      'scandalRiskFactor': instance.scandalRiskFactor,
      'biography': instance.biography,
      'acquiredAt': instance.acquiredAt?.toIso8601String(),
      'isFavorite': instance.isFavorite,
      'prestigeValue': instance.prestigeValue,
    };

_$PullResultImpl _$$PullResultImplFromJson(Map<String, dynamic> json) =>
    _$PullResultImpl(
      talentId: json['talentId'] as String,
      name: json['name'] as String,
      tier: $enumDecode(_$TalentTierEnumMap, json['tier']),
      portraitUrl: json['portraitUrl'] as String?,
      isDupe: json['isDupe'] as bool,
      prestigeValue: (json['prestigeValue'] as num?)?.toInt() ?? 0,
      baseHypeMultiplier: (json['baseHypeMultiplier'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$PullResultImplToJson(_$PullResultImpl instance) =>
    <String, dynamic>{
      'talentId': instance.talentId,
      'name': instance.name,
      'tier': _$TalentTierEnumMap[instance.tier]!,
      'portraitUrl': instance.portraitUrl,
      'isDupe': instance.isDupe,
      'prestigeValue': instance.prestigeValue,
      'baseHypeMultiplier': instance.baseHypeMultiplier,
    };

_$CastingResultImpl _$$CastingResultImplFromJson(Map<String, dynamic> json) =>
    _$CastingResultImpl(
      pulls: (json['pulls'] as List<dynamic>)
          .map((e) => PullResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      luxeSpent: (json['luxeSpent'] as num?)?.toInt() ?? 0,
      prestigeEarned: (json['prestigeEarned'] as num?)?.toInt() ?? 0,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$CastingResultImplToJson(_$CastingResultImpl instance) =>
    <String, dynamic>{
      'pulls': instance.pulls,
      'luxeSpent': instance.luxeSpent,
      'prestigeEarned': instance.prestigeEarned,
      'message': instance.message,
    };

_$PityStateImpl _$$PityStateImplFromJson(Map<String, dynamic> json) =>
    _$PityStateImpl(
      bannerId: json['bannerId'] as String? ?? 'standard',
      pullsSinceSovereign: (json['pullsSinceSovereign'] as num?)?.toInt() ?? 0,
      totalPulls: (json['totalPulls'] as num?)?.toInt() ?? 0,
      lastPullAt: json['lastPullAt'] == null
          ? null
          : DateTime.parse(json['lastPullAt'] as String),
    );

Map<String, dynamic> _$$PityStateImplToJson(_$PityStateImpl instance) =>
    <String, dynamic>{
      'bannerId': instance.bannerId,
      'pullsSinceSovereign': instance.pullsSinceSovereign,
      'totalPulls': instance.totalPulls,
      'lastPullAt': instance.lastPullAt?.toIso8601String(),
    };
