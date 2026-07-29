import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_styliste/core/theme/aurelian_theme.dart';
import 'package:the_styliste/core/theme/styliste_colors.dart';
import 'package:the_styliste/core/theme/styliste_motion.dart';
import 'package:the_styliste/core/theme/styliste_spacing.dart';
import 'package:the_styliste/core/theme/styliste_visual_mode.dart';
import 'package:the_styliste/core/widgets/aurelian_components.dart';
import 'package:the_styliste/core/widgets/aurelian_navigation.dart';
import 'package:the_styliste/core/widgets/styliste_scaffold.dart';

void main() {
  test('canonical light and dark text pairs meet WCAG AA contrast', () {
    expect(
      _contrast(StylisteColors.textPrimary, StylisteColors.ivory),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(StylisteColors.deepGold, StylisteColors.ivory),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(StylisteColors.ivory, StylisteColors.obsidian),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(StylisteColors.champagneGold, StylisteColors.obsidian),
      greaterThanOrEqualTo(4.5),
    );
  });

  testWidgets('canonical navigation has five stable semantic destinations', (
    WidgetTester tester,
  ) async {
    int selected = -1;
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AurelianTheme.darkTheme,
        home: Scaffold(
          bottomNavigationBar: AurelianBottomNavigation(
            currentIndex: 1,
            onDestinationSelected: (int value) => selected = value,
          ),
        ),
      ),
    );

    for (final String label in AurelianBottomNavigation.labels) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(
      tester.getSize(find.byType(NavigationBar)).height,
      greaterThanOrEqualTo(StylisteSpacing.minTapTarget),
    );

    await tester.tap(find.text('House'));
    expect(selected, 4);

    final SemanticsNode navSemantics = tester.getSemantics(
      find.bySemanticsLabel('Primary navigation'),
    );
    expect(navSemantics.label, contains('Primary navigation'));
  });

  testWidgets('state panel exposes live status and 48dp retry action', (
    WidgetTester tester,
  ) async {
    bool retried = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AurelianTheme.lightTheme,
        home: Scaffold(
          body: AurelianStatePanel(
            kind: AurelianStateKind.retryableError,
            title: 'Connection paused',
            message: 'Your work is safe.',
            actionLabel: 'Retry',
            onAction: () => retried = true,
          ),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel(
        RegExp(r'Connection paused\. Your work is safe\.'),
      ),
      findsOneWidget,
    );
    final Finder retry = find.widgetWithText(ElevatedButton, 'RETRY');
    expect(tester.getSize(retry).height, greaterThanOrEqualTo(48));
    await tester.tap(retry);
    expect(retried, isTrue);
  });

  testWidgets('responsive scaffold survives 320px and large text', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(320, 700),
            textScaler: TextScaler.linear(2),
          ),
          child: AurelianScaffold(
            mode: StylisteVisualMode.editorialLight,
            body: AurelianResponsiveBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AurelianSectionHeader(
                    eyebrow: 'Kingston House',
                    title: 'A long Collection Brief heading',
                    detail:
                        'Large text must wrap without clipping or horizontal overflow.',
                  ),
                  SizedBox(height: StylisteSpacing.md),
                  AurelianStatePanel(
                    kind: AurelianStateKind.unavailable,
                    title: 'Sampling unavailable',
                    message: 'This boundary is deliberate.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('A long Collection Brief heading'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('motion token resolves to zero when animations are disabled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: _MotionProbe(),
        ),
      ),
    );

    expect(find.text('0'), findsOneWidget);
  });
}

class _MotionProbe extends StatelessWidget {
  const _MotionProbe();

  @override
  Widget build(BuildContext context) {
    return Text(
      '${StylisteMotion.resolve(context, StylisteMotion.micro).inMilliseconds}',
    );
  }
}

double _contrast(Color foreground, Color background) {
  final double lighter =
      foreground.computeLuminance() > background.computeLuminance()
          ? foreground.computeLuminance()
          : background.computeLuminance();
  final double darker =
      foreground.computeLuminance() > background.computeLuminance()
          ? background.computeLuminance()
          : foreground.computeLuminance();
  return (lighter + 0.05) / (darker + 0.05);
}
