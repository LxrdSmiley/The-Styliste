import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_styliste/core/widgets/styliste_buttons.dart';
import 'package:the_styliste/domain/models/design.dart';
import 'package:the_styliste/features/atelier/providers/drop_design_provider.dart';
import 'package:the_styliste/features/atelier/widgets/face_vex_panel.dart';

void main() {
  testWidgets('FaceVexPanel primary action selects Vex critique', (
    WidgetTester tester,
  ) async {
    bool? selected;

    await tester.pumpWidget(
      _panelHarness(
        FaceVexPanel(
          vexOptedIn: false,
          onFaceVex: () => selected = true,
          onDropWithoutCritique: () => selected = false,
        ),
      ),
    );

    await tester.tap(find.widgetWithText(GoldPrimaryButton, 'FACE VEX'));
    await tester.pump();

    expect(selected, isTrue);
  });

  testWidgets('FaceVexPanel secondary action skips Vex critique', (
    WidgetTester tester,
  ) async {
    bool? selected;

    await tester.pumpWidget(
      _panelHarness(
        FaceVexPanel(
          vexOptedIn: true,
          onFaceVex: () => selected = true,
          onDropWithoutCritique: () => selected = false,
        ),
      ),
    );

    await tester.tap(
      find.widgetWithText(IvorySecondaryButton, 'DROP WITHOUT CRITIQUE'),
    );
    await tester.pump();

    expect(selected, isFalse);
  });

  test('DropDesignNotifier setVexOptIn explicitly sets true and false', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final DropDesignNotifier notifier =
        container.read(dropDesignProvider.notifier);
    notifier.initDropFlow(
      design: _design(),
      styleTags: const <String>['minimal'],
    );

    notifier.setVexOptIn(false);

    expect(container.read(dropDesignProvider).vexOptedIn, isFalse);
    expect(container.read(dropDesignProvider).vexReview, isNull);

    notifier.setVexOptIn(true);

    expect(container.read(dropDesignProvider).vexOptedIn, isTrue);
    expect(container.read(dropDesignProvider).vexReview, isNotNull);
  });
}

Widget _panelHarness(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 390.0,
          child: child,
        ),
      ),
    ),
  );
}

Design _design() {
  return const Design(
    id: 'design-1',
    playerId: 'player-1',
    name: 'Ivory Signal',
    sessionType: DesignSessionType.quickSketch,
    hypeScore: 72.0,
    isAlpha: true,
    fabricData: <String, dynamic>{
      'color_hex': 'FAF7F0',
      'style_tags': <String>['minimal'],
    },
  );
}
