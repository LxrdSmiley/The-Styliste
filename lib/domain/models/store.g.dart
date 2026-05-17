// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoreImpl _$$StoreImplFromJson(Map<String, dynamic> json) => _$StoreImpl(
      id: json['id'] as String,
      playerId: json['player_id'] as String,
      type: $enumDecode(_$StoreTypeEnumMap, json['type']),
      city: $enumDecode(_$StoreCityEnumMap, json['city']),
      tier: (json['tier'] as num?)?.toInt() ?? 1,
      revenuePerHour: json['revenue_per_hour'] == null
          ? 0.0
          : const _SafeDouble().fromJson(json['revenue_per_hour']),
      loyalty: (json['loyalty'] as num?)?.toInt() ?? 100,
      marketShare: json['market_share'] == null
          ? 0.0
          : const _SafeDouble().fromJson(json['market_share']),
      maisonId: json['maison_id'] as String?,
      openedAt: json['opened_at'] == null
          ? null
          : DateTime.parse(json['opened_at'] as String),
    );

Map<String, dynamic> _$$StoreImplToJson(_$StoreImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'player_id': instance.playerId,
      'type': _$StoreTypeEnumMap[instance.type]!,
      'city': _$StoreCityEnumMap[instance.city]!,
      'tier': instance.tier,
      'revenue_per_hour': const _SafeDouble().toJson(instance.revenuePerHour),
      'loyalty': instance.loyalty,
      'market_share': const _SafeDouble().toJson(instance.marketShare),
      'maison_id': instance.maisonId,
      'opened_at': instance.openedAt?.toIso8601String(),
    };

const _$StoreTypeEnumMap = {
  StoreType.flagship: 'flagship',
  StoreType.ecommerce: 'ecommerce',
};

const _$StoreCityEnumMap = {
  StoreCity.newYork: 'new_york',
  StoreCity.paris: 'paris',
  StoreCity.tokyo: 'tokyo',
  StoreCity.london: 'london',
  StoreCity.milan: 'milan',
  StoreCity.seoul: 'seoul',
  StoreCity.nairobi: 'nairobi',
  StoreCity.saoPaulo: 'sao_paulo',
  StoreCity.amsterdam: 'amsterdam',
  StoreCity.losAngeles: 'los_angeles',
};
