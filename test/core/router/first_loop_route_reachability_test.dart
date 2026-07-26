import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('first repeatable loop routes remain reachable', () {
    final String routerSource =
        File('lib/core/router/app_router.dart').readAsStringSync();

    expect(routerSource, contains("static const String hq = '/hq';"));
    expect(routerSource, contains("static const String feed = '/feed';"));
    expect(routerSource, contains("static const String atelier = '/atelier';"));
    expect(
      routerSource,
      contains(
        "static const String atelierDropPreview = '/atelier/drop-preview';",
      ),
    );
    expect(
      routerSource,
      contains(
        "static const String atelierDropLaunch = '/atelier/drop-launch';",
      ),
    );
    expect(routerSource, contains("static const String ledger = '/empire';"));

    expect(routerSource, contains('StatefulShellRoute.indexedStack'));
    expect(routerSource, contains('path: hq'));
    expect(routerSource, contains('path: feed'));
    expect(routerSource, contains('path: atelier'));
    expect(routerSource, contains('path: atelierDropPreview'));
    expect(routerSource, contains('path: atelierDropLaunch'));
    expect(routerSource, contains('path: ledger'));
  });

  test('future Maison tab is locked in first-session navigation', () {
    final String shellSource =
        File('lib/presentation/screens/main_shell.dart').readAsStringSync();

    expect(shellSource, contains("label: 'LOCKED'"));
    expect(shellSource, contains('enabled: false'));
    expect(shellSource, isNot(contains("label: 'MAISON'")));
  });
}
