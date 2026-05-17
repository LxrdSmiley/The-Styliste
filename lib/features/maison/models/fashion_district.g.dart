// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fashion_district.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FashionDistrictImpl _$$FashionDistrictImplFromJson(
        Map<String, dynamic> json) =>
    _$FashionDistrictImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      baseTakeoverCost: (json['base_takeover_cost'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      controllingMaisonId: json['controlling_maison_id'] as String?,
      controlledSince: json['controlled_since'] == null
          ? null
          : DateTime.parse(json['controlled_since'] as String),
      totalHype: (json['total_hype'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$FashionDistrictImplToJson(
        _$FashionDistrictImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'city': instance.city,
      'base_takeover_cost': instance.baseTakeoverCost,
      'created_at': instance.createdAt.toIso8601String(),
      'controlling_maison_id': instance.controllingMaisonId,
      'controlled_since': instance.controlledSince?.toIso8601String(),
      'total_hype': instance.totalHype,
    };

_$DistrictWatermarkImpl _$$DistrictWatermarkImplFromJson(
        Map<String, dynamic> json) =>
    _$DistrictWatermarkImpl(
      id: json['id'] as String,
      maisonId: json['maison_id'] as String,
      districtId: json['district_id'] as String,
      achievedAt: DateTime.parse(json['achieved_at'] as String),
    );

Map<String, dynamic> _$$DistrictWatermarkImplToJson(
        _$DistrictWatermarkImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'maison_id': instance.maisonId,
      'district_id': instance.districtId,
      'achieved_at': instance.achievedAt.toIso8601String(),
    };

_$TakeoverResultImpl _$$TakeoverResultImplFromJson(Map<String, dynamic> json) =>
    _$TakeoverResultImpl(
      success: json['success'] as bool,
      message: json['message'] as String,
      newController: json['new_controller'] as String?,
      defenseMultiplier:
          (json['defense_multiplier'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$$TakeoverResultImplToJson(
        _$TakeoverResultImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'new_controller': instance.newController,
      'defense_multiplier': instance.defenseMultiplier,
    };

_$DistrictDetailsImpl _$$DistrictDetailsImplFromJson(
        Map<String, dynamic> json) =>
    _$DistrictDetailsImpl(
      district:
          FashionDistrict.fromJson(json['district'] as Map<String, dynamic>),
      controllingMaisonName: json['controlling_maison_name'] as String?,
      controllingMaisonTag: json['controlling_maison_tag'] as String?,
      controllingMaisonTreasury:
          (json['controlling_maison_treasury'] as num?)?.toInt(),
      controllingMaisonHype: (json['controlling_maison_hype'] as num?)?.toInt(),
      hasWatermark: json['has_watermark'] as bool? ?? false,
    );

Map<String, dynamic> _$$DistrictDetailsImplToJson(
        _$DistrictDetailsImpl instance) =>
    <String, dynamic>{
      'district': instance.district.toJson(),
      'controlling_maison_name': instance.controllingMaisonName,
      'controlling_maison_tag': instance.controllingMaisonTag,
      'controlling_maison_treasury': instance.controllingMaisonTreasury,
      'controlling_maison_hype': instance.controllingMaisonHype,
      'has_watermark': instance.hasWatermark,
    };
