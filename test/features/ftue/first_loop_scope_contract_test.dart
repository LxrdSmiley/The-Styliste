import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('first objective is the shared Kingston capsule boundary', () {
    final String providerSource =
        File('lib/features/ftue/providers/first_objective_provider.dart')
            .readAsStringSync();
    final String overlaySource =
        File('lib/features/ftue/widgets/luxe_first_objective_overlay.dart')
            .readAsStringSync();

    expect(providerSource, contains('Build your Kingston capsule'));
    expect(providerSource, contains('Artisan path changes the framing'));
    expect(providerSource, contains('Architect path changes the framing'));
    expect(providerSource, contains('not the gameplay ceiling'));
    expect(providerSource, contains('AppRouter.atelierCapsule'));
    expect(providerSource, contains('samplingUnavailable'));
    expect(providerSource, isNot(contains('Launch your first Alpha Drop')));
    expect(providerSource, isNot(contains('Open your first store')));
    expect(providerSource, isNot(contains('hasServerConfirmedStarterStore')));

    expect(overlaySource, contains('Hero Piece'));
    expect(overlaySource, contains('Commercial Anchor'));
    expect(overlaySource, contains('Experimental Piece'));
    expect(overlaySource, contains('equal ceiling'));
    expect(overlaySource, isNot(contains('Mint your first Alpha')));
    expect(overlaySource, isNot(contains('Launch your first store')));
  });

  test('stale premium path-switching copy is removed', () {
    final String source =
        File('lib/features/onboarding/screens/career_path_screen.dart')
            .readAsStringSync();

    expect(source, isNot(contains('premium currency')));
    expect(source, contains('Joint Venture'));
  });

  test('first-session navigation exposes only the five canonical destinations',
      () {
    final String shellSource =
        File('lib/presentation/screens/main_shell.dart').readAsStringSync();
    final String navigationSource =
        File('lib/core/widgets/aurelian_navigation.dart').readAsStringSync();
    final String architectSource =
        File('lib/features/hq/widgets/hq_architect_view.dart')
            .readAsStringSync();
    final String artisanSource =
        File('lib/features/hq/widgets/hq_artisan_view.dart').readAsStringSync();
    final String districtSource =
        File('lib/features/maison/screens/district_map_screen.dart')
            .readAsStringSync();

    for (final String label in <String>[
      'HQ',
      'Atelier',
      'Empire',
      'Feed',
      'House',
    ]) {
      expect(navigationSource, contains("label: '$label'"));
    }
    expect(shellSource, contains('AurelianBottomNavigation'));
    expect(shellSource, isNot(contains("label: 'LOCKED'")));
    expect(architectSource, isNot(contains('onKintsugiRequest:')));
    expect(architectSource, isNot(contains('onApologyRequest:')));
    expect(architectSource, isNot(contains('execute_power_move')));
    expect(architectSource, isNot(contains('logisticsUpgradeProvider')));
    expect(architectSource, isNot(contains('AppRouter.districtMap')));
    expect(architectSource, isNot(contains('PUBLIC APOLOGY')));
    expect(artisanSource, isNot(contains('onKintsugiRequest:')));
    expect(artisanSource, isNot(contains('onApologyRequest:')));
    expect(artisanSource, isNot(contains('execute_power_move')));
    expect(districtSource, contains('DISTRICT WARFARE LOCKED'));
    expect(districtSource, isNot(contains('INITIATE SIEGE')));
  });
}
