import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_styliste/core/theme/styliste_visual_mode.dart';
import 'package:the_styliste/core/widgets/glass_metric_card.dart';
import 'package:the_styliste/core/widgets/gold_primary_button.dart';
import 'package:the_styliste/core/widgets/pill_badge.dart';
import 'package:the_styliste/core/widgets/styliste_scaffold.dart';

void main() {
  test('all visual modes expose palette values', () {
    for (final StylisteVisualMode mode in StylisteVisualMode.values) {
      expect(mode.background, isA<Color>());
      expect(mode.surface, isA<Color>());
      expect(mode.text, isA<Color>());
      expect(mode.accent, isA<Color>());
      expect(mode.danger, isA<Color>());
      expect(mode.profit, isA<Color>());
    }
  });

  testWidgets('GoldPrimaryButton supports disabled state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GoldPrimaryButton(label: 'Drop', onPressed: null),
        ),
      ),
    );

    final ElevatedButton button = tester.widget(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
    expect(find.text('DROP'), findsOneWidget);
  });

  testWidgets('GoldPrimaryButton supports loading state', (
    WidgetTester tester,
  ) async {
    int taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GoldPrimaryButton(
            label: 'Launch',
            isLoading: true,
            onPressed: () => taps++,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    expect(taps, 0);
  });

  testWidgets('GlassMetricCard supports loading and error states', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassMetricCard(
            label: 'Followers',
            value: '12.4K',
            isLoading: true,
          ),
        ),
      ),
    );

    expect(find.text('FOLLOWERS'), findsNothing);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassMetricCard(
            label: 'Followers',
            value: '12.4K',
            error: 'Unable to load metric',
          ),
        ),
      ),
    );

    expect(find.text('Unable to load metric'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('PillBadge renders text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PillBadge(label: 'Exclusive'),
        ),
      ),
    );

    expect(find.text('EXCLUSIVE'), findsOneWidget);
  });

  testWidgets('StylisteScaffold renders body in all visual modes', (
    WidgetTester tester,
  ) async {
    for (final StylisteVisualMode mode in StylisteVisualMode.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: StylisteScaffold(
            mode: mode,
            body: Text('Body ${mode.name}'),
          ),
        ),
      );

      expect(find.text('Body ${mode.name}'), findsOneWidget);
    }
  });
}
