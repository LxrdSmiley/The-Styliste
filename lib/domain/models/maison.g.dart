// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maison.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MaisonImpl _$$MaisonImplFromJson(Map<String, dynamic> json) => _$MaisonImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      founderId: json['founder_id'] as String,
      treasury: (json['treasury'] as num?)?.toDouble() ?? 0.0,
      memberIds: (json['member_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      dominatedCities: (json['dominated_cities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      isRecruiting: json['is_recruiting'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$MaisonImplToJson(_$MaisonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'founder_id': instance.founderId,
      'treasury': instance.treasury,
      'member_ids': instance.memberIds,
      'dominated_cities': instance.dominatedCities,
      'is_recruiting': instance.isRecruiting,
      'created_at': instance.createdAt?.toIso8601String(),
    };

_$MaisonMemberImpl _$$MaisonMemberImplFromJson(Map<String, dynamic> json) =>
    _$MaisonMemberImpl(
      maisonId: json['maison_id'] as String,
      playerId: json['player_id'] as String,
      role: $enumDecode(_$MaisonRoleEnumMap, json['role']),
      joinedAt: json['joined_at'] == null
          ? null
          : DateTime.parse(json['joined_at'] as String),
    );

Map<String, dynamic> _$$MaisonMemberImplToJson(_$MaisonMemberImpl instance) =>
    <String, dynamic>{
      'maison_id': instance.maisonId,
      'player_id': instance.playerId,
      'role': _$MaisonRoleEnumMap[instance.role]!,
      'joined_at': instance.joinedAt?.toIso8601String(),
    };

const _$MaisonRoleEnumMap = {
  MaisonRole.founder: 'founder',
  MaisonRole.creativeDirector: 'creative_director',
  MaisonRole.executiveDirector: 'executive_director',
  MaisonRole.brandDirector: 'brand_director',
  MaisonRole.member: 'member',
};
