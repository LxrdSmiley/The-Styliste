// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CheckInStateImpl _$$CheckInStateImplFromJson(Map<String, dynamic> json) =>
    _$CheckInStateImpl(
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      lastCheckIn: json['last_check_in'] == null
          ? null
          : DateTime.parse(json['last_check_in'] as String),
      totalCheckIns: (json['total_check_ins'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
      rewardsClaimed: (json['rewards_claimed'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      nextRewardAt: (json['next_reward_at'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$CheckInStateImplToJson(_$CheckInStateImpl instance) =>
    <String, dynamic>{
      'current_streak': instance.currentStreak,
      'last_check_in': instance.lastCheckIn?.toIso8601String(),
      'total_check_ins': instance.totalCheckIns,
      'longest_streak': instance.longestStreak,
      'rewards_claimed': instance.rewardsClaimed,
      'next_reward_at': instance.nextRewardAt,
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
