// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeedPostImpl _$$FeedPostImplFromJson(Map<String, dynamic> json) =>
    _$FeedPostImpl(
      id: json['id'] as String,
      playerId: json['player_id'] as String,
      type: json['type'] as String,
      content:
          json['content'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      hype: json['hype'] == null
          ? 0.0
          : const _SafeDouble().fromJson(json['hype']),
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$FeedPostImplToJson(_$FeedPostImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'player_id': instance.playerId,
      'type': instance.type,
      'content': instance.content,
      'hype': const _SafeDouble().toJson(instance.hype),
      'likes': instance.likes,
      'created_at': instance.createdAt?.toIso8601String(),
    };
