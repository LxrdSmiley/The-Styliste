import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_styliste/core/providers/active_player_provider.dart';
import 'package:the_styliste/domain/models/feed_post.dart';
import 'package:the_styliste/features/feed/providers/feed_provider.dart';
import 'package:the_styliste/features/feed/screens/feed_screen.dart';

void main() {
  testWidgets('Feed exposes read-only comments and held social mutations', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_feedHarness(posts: <FeedPost>[_alphaPost()]));
    await tester.pump();
    await tester.pump();

    expect(find.text('HELD'), findsNothing);
    expect(find.text('REQUESTS'), findsOneWidget);
    expect(find.text('COMMENT'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('COMMENT'));
    await tester.pumpAndSettle();
    expect(find.text('Commenting is held'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Start the conversation'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Close comments'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('REQUESTS'));
    await tester.pumpAndSettle();
    expect(find.text('Request responses are held'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Feed card survives 320px portrait at large text', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _feedHarness(
        posts: <FeedPost>[_strangerAlphaPost()],
        mediaQueryData: const MediaQueryData(
          size: Size(320, 700),
          textScaler: TextScaler.linear(2),
          disableAnimations: true,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('HOUSE SIGNAL'), findsWidgets);
    expect(find.text('HELD'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _feedHarness({
  required List<FeedPost> posts,
  MediaQueryData? mediaQueryData,
}) {
  final Widget screen = mediaQueryData == null
      ? const FeedScreen()
      : MediaQuery(
          data: mediaQueryData,
          child: const FeedScreen(),
        );
  return ProviderScope(
    overrides: <Override>[
      activeUidProvider.overrideWith((Ref ref) => 'player-1'),
      feedStreamProvider.overrideWith(
        (Ref ref) => Stream<List<FeedPost>>.value(posts),
      ),
      followingIdsProvider.overrideWith(
        (Ref ref) => Stream<Set<String>>.value(const <String>{}),
      ),
      syndicateFeedProvider.overrideWith(
        (Ref ref) async => const <FeedPost>[],
      ),
    ],
    child: MaterialApp(home: screen),
  );
}

FeedPost _alphaPost() {
  return FeedPost(
    id: 'post-1',
    playerId: 'player-1',
    type: 'design_flex',
    content: const <String, dynamic>{
      'brand_name': 'House Meridian',
      'design_name': 'Kingston Studio Study',
      'fabric_color_hex': 'D6A84F',
      'result_explanation': 'A server-confirmed design record.',
    },
    hype: 42,
    likes: 7,
    createdAt: DateTime.utc(2026, 7, 27),
  );
}

FeedPost _strangerAlphaPost() {
  return FeedPost(
    id: 'post-2',
    playerId: 'player-2',
    type: 'design_flex',
    content: const <String, dynamic>{
      'brand_name': 'House North',
      'design_name': 'Community Cut',
      'fabric_color_hex': 'FAF7F0',
      'result_explanation': 'Visible server-projected causes only.',
    },
    hype: 24,
    likes: 3,
    createdAt: DateTime.utc(2026, 7, 27),
  );
}
