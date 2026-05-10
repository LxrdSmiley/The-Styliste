// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CheckInStateImpl _$$CheckInStateImplFromJson(Map<String, dynamic> json) =>
    _$CheckInStateImpl(
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      lastCheckIn: json['lastCheckIn'] == null
          ? null
          : DateTime.parse(json['lastCheckIn'] as String),
      totalCheckIns: (json['totalCheckIns'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      rewardsClaimed: (json['rewardsClaimed'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      nextRewardAt: (json['nextRewardAt'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$CheckInStateImplToJson(_$CheckInStateImpl instance) =>
    <String, dynamic>{
      'currentStreak': instance.currentStreak,
      'lastCheckIn': instance.lastCheckIn?.toIso8601String(),
      'totalCheckIns': instance.totalCheckIns,
      'longestStreak': instance.longestStreak,
      'rewardsClaimed': instance.rewardsClaimed,
      'nextRewardAt': instance.nextRewardAt,
    };

_$CheckInRewardImpl _$$CheckInRewardImplFromJson(Map<String, dynamic> json) =>
    _$CheckInRewardImpl(
      day: (json['day'] as num).toInt(),
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$$CheckInRewardImplToJson(_$CheckInRewardImpl instance) =>
    <String, dynamic>{
      'day': instance.day,
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
    };
