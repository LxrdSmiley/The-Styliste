// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoreImpl _$$StoreImplFromJson(Map<String, dynamic> json) => _$StoreImpl(
      id: json['id'] as String,
      playerId: json['playerId'] as String,
      type: $enumDecode(_$StoreTypeEnumMap, json['type']),
      city: $enumDecode(_$StoreCityEnumMap, json['city']),
      tier: (json['tier'] as num?)?.toInt() ?? 1,
      revenuePerHour: json['revenuePerHour'] == null
          ? 0.0
          : const _SafeDouble().fromJson(json['revenuePerHour']),
      loyalty: (json['loyalty'] as num?)?.toInt() ?? 100,
      marketShare: json['marketShare'] == null
          ? 0.0
          : const _SafeDouble().fromJson(json['marketShare']),
      maisonId: json['maisonId'] as String?,
      openedAt: json['openedAt'] == null
          ? null
          : DateTime.parse(json['openedAt'] as String),
    );

Map<String, dynamic> _$$StoreImplToJson(_$StoreImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'playerId': instance.playerId,
      'type': _$StoreTypeEnumMap[instance.type]!,
      'city': _$StoreCityEnumMap[instance.city]!,
      'tier': instance.tier,
      'revenuePerHour': const _SafeDouble().toJson(instance.revenuePerHour),
      'loyalty': instance.loyalty,
      'marketShare': const _SafeDouble().toJson(instance.marketShare),
      'maisonId': instance.maisonId,
      'openedAt': instance.openedAt?.toIso8601String(),
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
