import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_styliste/core/theme/styliste_visual_mode.dart';
import 'package:the_styliste/core/widgets/glass_metric_card.dart';
import 'package:the_styliste/core/widgets/gold_primary_button.dart';
import 'package:the_styliste/core/widgets/pill_badge.dart';
import 'package:the_styliste/core/widgets/styliste_scaffold.dart';
import 'package:the_styliste/features/atelier/screens/atelier_screen.dart';
import 'package:the_styliste/features/trends/models/trend_tsunami.dart';
import 'package:the_styliste/features/trends/providers/trend_provider.dart';

void main() {
  testWidgets('Atelier uses atelierWarmStudio mode and foundation widgets', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_atelierHarness());
    await tester.pump();

    final StylisteScaffold scaffold =
        tester.widget<StylisteScaffold>(find.byType(StylisteScaffold));
    expect(scaffold.mode, StylisteVisualMode.atelierWarmStudio);
    expect(find.byType(PillBadge), findsWidgets);
    expect(find.text('BASE SILHOUETTE'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byType(GoldPrimaryButton),
      460.0,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(GoldPrimaryButton), findsOneWidget);
    expect(find.byType(GlassMetricCard), findsWidgets);
  });

  testWidgets('Atelier trend error state renders without crash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _atelierHarness(
        trendStream: Stream<List<TrendTsunami>>.error(
          StateError('trend unavailable'),
        ),
      ),
    );
    await tester.pump();

    await tester.scrollUntilVisible(
      find.textContaining('Trend signal unavailable'),
      320.0,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Trend signal unavailable'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Atelier reduced-motion fallback renders without crash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_atelierHarness(disableAnimations: true));
    await tester.pump();

    expect(find.text('REDUCED MOTION'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _atelierHarness({
  Stream<List<TrendTsunami>>? trendStream,
  bool disableAnimations = false,
}) {
  return ProviderScope(
    overrides: <Override>[
      activeTsunamiProvider.overrideWith(
        (Ref ref) =>
            trendStream ??
            Stream<List<TrendTsunami>>.value(
              const <TrendTsunami>[],
            ),
      ),
    ],
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: const AtelierScreen(prepareSessionOnStart: false),
      ),
    ),
  );
}
