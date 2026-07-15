import 'package:flutter_test/flutter_test.dart';
import 'package:the_styliste/features/feed/providers/feed_provider.dart';

void main() {
  group('FeedComment', () {
    test('parses the base feed_comments row shape', () {
      final FeedComment comment = FeedComment.fromJson(
        <String, dynamic>{
          'id': 'comment-1',
          'post_id': 'post-1',
          'player_id': 'player-1',
          'body': 'Sharp silhouette.',
          'created_at': '2026-05-25T12:00:00Z',
        },
      );

      expect(comment.id, 'comment-1');
      expect(comment.postId, 'post-1');
      expect(comment.playerId, 'player-1');
      expect(comment.body, 'Sharp silhouette.');
      expect(comment.brandName, isNull);
      expect(comment.createdAt.toUtc(), DateTime.utc(2026, 5, 25, 12));
    });

    test('parses the enriched edge_add_feed_comment comment payload', () {
      final FeedComment comment = FeedComment.fromJson(
        <String, dynamic>{
          'id': 'comment-2',
          'post_id': 'post-2',
          'player_id': 'player-2',
          'brand_name': 'Maison Noire',
          'body': 'That drop has teeth.',
          'created_at': DateTime.utc(2026, 5, 25, 13),
        },
      );

      expect(comment.id, 'comment-2');
      expect(comment.brandName, 'Maison Noire');
      expect(comment.createdAt, DateTime.utc(2026, 5, 25, 13));
    });

    test('accepts comment_id as a backend response alias', () {
      final FeedComment comment = FeedComment.fromJson(
        <String, dynamic>{
          'comment_id': 'comment-3',
          'post_id': 'post-3',
          'player_id': 'player-3',
          'body': 'Front row energy.',
          'created_at': '2026-05-25T14:00:00Z',
        },
      );

      expect(comment.id, 'comment-3');
      expect(comment.body, 'Front row energy.');
    });
  });
}
