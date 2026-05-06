// GDD §6.1 — FeedPost entity: Global Live Feed row.
// Phase 6: Freezed model with _SafeDouble on hype (Postgres NUMERIC).
// `type` is the discriminator: 'design_flex' | 'mogul_flex'.
// `content` is a flexible JSONB map — never assume any key is present.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_post.freezed.dart';
part 'feed_post.g.dart';

/// Safe coercion: num → double. Guards against Postgres NUMERIC → int JSON.
class _SafeDouble implements JsonConverter<double, Object?> {
  const _SafeDouble();
  @override
  double fromJson(Object? value) => (value as num?)?.toDouble() ?? 0.0;
  @override
  Object? toJson(double value) => value;
}

@freezed
class FeedPost with _$FeedPost {
  const factory FeedPost({
    required String id,
    required String playerId,
    required String type,
    @Default(<String, dynamic>{}) Map<String, dynamic> content,
    @Default(0.0) @_SafeDouble() double hype,
    @Default(0) int likes,
    DateTime? createdAt,
  }) = _FeedPost;

  factory FeedPost.fromJson(Map<String, dynamic> json) =>
      _$FeedPostFromJson(json);
}
