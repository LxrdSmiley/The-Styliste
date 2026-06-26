import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_styliste/core/theme/styliste_colors.dart';
import 'package:the_styliste/core/theme/styliste_typography.dart';
import 'package:the_styliste/core/theme/styliste_visual_mode.dart';
import 'package:the_styliste/core/widgets/glass_metric_card.dart';
import 'package:the_styliste/core/widgets/pill_badge.dart';
import 'package:the_styliste/core/widgets/styliste_buttons.dart';
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

  test('Stitch palette and typography tokens compile', () {
    expect(StylisteColors.ivory, isA<Color>());
    expect(StylisteColors.alabaster, isA<Color>());
    expect(StylisteColors.champagneGold, isA<Color>());
    expect(StylisteColors.deepGold, isA<Color>());
    expect(StylisteColors.roseAccent, isA<Color>());
    expect(StylisteColors.obsidian, isA<Color>());
    expect(StylisteColors.obsidianSurface, isA<Color>());
    expect(StylisteColors.warmGrey, isA<Color>());
    expect(StylisteText.displayEditorial.fontFamily, 'SpaceGrotesk');
    expect(StylisteText.metricLarge.fontFamily, 'JetBrainsMono');
    expect(StylisteText.body.fontSize, greaterThanOrEqualTo(12.0));
  });

  testWidgets('GoldPrimaryButton supports disabled state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GoldPrimaryButton(
            label: 'Drop',
            disabledReason: 'Finish the garment first.',
            onPressed: null,
          ),
        ),
      ),
    );

    final ElevatedButton button = tester.widget(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
    expect(find.text('DROP'), findsOneWidget);
    expect(find.text('Finish the garment first.'), findsOneWidget);
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

  testWidgets('button system renders core variants and feedback states', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: <Widget>[
              ObsidianPrimaryButton(
                label: 'Face Vex',
                feedback: StylisteButtonFeedback.success,
                onPressed: () {},
              ),
              IvorySecondaryButton(
                label: 'Back to Atelier',
                feedback: StylisteButtonFeedback.error,
                onPressed: () {},
              ),
              PillChoiceButton(
                label: 'Runway',
                selected: true,
                onPressed: () {},
              ),
              IconCircleButton(
                icon: Icons.close,
                tooltip: 'Dismiss',
                onPressed: () {},
              ),
              FloatingReactionButton(
                label: 'Iconic',
                icon: Icons.auto_awesome,
                count: '12K',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('FACE VEX'), findsOneWidget);
    expect(find.text('BACK TO ATELIER'), findsOneWidget);
    expect(find.text('RUNWAY'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('ICONIC 12K'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNWidgets(5));
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
