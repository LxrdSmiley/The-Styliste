import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_styliste/core/router/app_router.dart';

void main() {
  testWidgets('deferred drop deep links render without backend initialization',
      (
    WidgetTester tester,
  ) async {
    AppRouter.router.go(AppRouter.atelierDropPreview);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: AppRouter.router),
      ),
    );
    await tester.pump();

    expect(find.text('Drop preview is held'), findsOneWidget);
    expect(find.textContaining('Gate A ends at capsule readiness'),
        findsOneWidget);
    expect(tester.takeException(), isNull);

    AppRouter.router.go(AppRouter.atelierDropLaunch);
    await tester.pump();
    await tester.pump();

    expect(find.text('Drop launch is held'), findsOneWidget);
    expect(find.textContaining('No launch request has been started'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('deferred routes import no launch implementation or mutation provider',
      () {
    final String router =
        File('lib/core/router/app_router.dart').readAsStringSync();
    final String atelier =
        File('lib/features/atelier/screens/atelier_screen.dart')
            .readAsStringSync();

    expect(router, isNot(contains('drop_preview_screen.dart')));
    expect(router, isNot(contains('drop_launch_scene_screen.dart')));
    expect(router, isNot(contains('dropDesignProvider')));
    expect(router, isNot(contains('mintDesignProvider')));
    expect(atelier, isNot(contains('mint_design_provider.dart')));
    expect(atelier, isNot(contains('mintDesignProvider')));
    expect(atelier, isNot(contains('startAtelierSession')));
    expect(atelier, contains('Only the capsule submits bounded'));
  });
}
