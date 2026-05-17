// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CampaignImpl _$$CampaignImplFromJson(Map<String, dynamic> json) =>
    _$CampaignImpl(
      id: json['id'] as String,
      playerId: json['player_id'] as String,
      type: $enumDecode(_$CampaignTypeEnumMap, json['type']),
      status: $enumDecodeNullable(_$CampaignStatusEnumMap, json['status']) ??
          CampaignStatus.draft,
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      roiActual: (json['roi_actual'] as num?)?.toDouble() ?? 0.0,
      roiForecast: (json['roi_forecast'] as num?)?.toDouble() ?? 0.0,
      hypeLift: (json['hype_lift'] as num?)?.toDouble() ?? 0.0,
      salesLift: (json['sales_lift'] as num?)?.toDouble() ?? 0.0,
      maisonPoolId: json['maison_pool_id'] as String?,
      launchedAt: json['launched_at'] == null
          ? null
          : DateTime.parse(json['launched_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$$CampaignImplToJson(_$CampaignImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'player_id': instance.playerId,
      'type': _$CampaignTypeEnumMap[instance.type]!,
      'status': _$CampaignStatusEnumMap[instance.status]!,
      'budget': instance.budget,
      'roi_actual': instance.roiActual,
      'roi_forecast': instance.roiForecast,
      'hype_lift': instance.hypeLift,
      'sales_lift': instance.salesLift,
      'maison_pool_id': instance.maisonPoolId,
      'launched_at': instance.launchedAt?.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
    };

const _$CampaignTypeEnumMap = {
  CampaignType.socialBlast: 'social_blast',
  CampaignType.influencerDrop: 'influencer_drop',
  CampaignType.runwayEvent: 'runway_event',
  CampaignType.targetedAds: 'targeted_ads',
  CampaignType.custom: 'custom',
};

const _$CampaignStatusEnumMap = {
  CampaignStatus.draft: 'draft',
  CampaignStatus.active: 'active',
  CampaignStatus.completed: 'completed',
  CampaignStatus.failed: 'failed',
};
