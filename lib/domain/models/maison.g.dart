// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maison.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MaisonImpl _$$MaisonImplFromJson(Map<String, dynamic> json) => _$MaisonImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      founderId: json['founderId'] as String,
      treasury: (json['treasury'] as num?)?.toDouble() ?? 0.0,
      memberIds: (json['memberIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      dominatedCities: (json['dominatedCities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      isRecruiting: json['isRecruiting'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$MaisonImplToJson(_$MaisonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'founderId': instance.founderId,
      'treasury': instance.treasury,
      'memberIds': instance.memberIds,
      'dominatedCities': instance.dominatedCities,
      'isRecruiting': instance.isRecruiting,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$MaisonMemberImpl _$$MaisonMemberImplFromJson(Map<String, dynamic> json) =>
    _$MaisonMemberImpl(
      maisonId: json['maisonId'] as String,
      playerId: json['playerId'] as String,
      role: $enumDecode(_$MaisonRoleEnumMap, json['role']),
      joinedAt: json['joinedAt'] == null
          ? null
          : DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$$MaisonMemberImplToJson(_$MaisonMemberImpl instance) =>
    <String, dynamic>{
      'maisonId': instance.maisonId,
      'playerId': instance.playerId,
      'role': _$MaisonRoleEnumMap[instance.role]!,
      'joinedAt': instance.joinedAt?.toIso8601String(),
    };

const _$MaisonRoleEnumMap = {
  MaisonRole.founder: 'founder',
  MaisonRole.creativeDirector: 'creative_director',
  MaisonRole.executiveDirector: 'executive_director',
  MaisonRole.brandDirector: 'brand_director',
  MaisonRole.member: 'member',
};
