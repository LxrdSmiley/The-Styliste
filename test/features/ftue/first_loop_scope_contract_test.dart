import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('first objectives describe real first-loop actions', () {
    final String providerSource =
        File('lib/features/ftue/providers/first_objective_provider.dart')
            .readAsStringSync();
    final String repositorySource =
        File('lib/features/ftue/repositories/first_objective_repository.dart')
            .readAsStringSync();

    expect(providerSource, contains('Launch your first Alpha Drop'));
    expect(providerSource, contains('drop it to Feed, then return HQ'));
    expect(providerSource, contains('Open your first store'));
    expect(providerSource, contains('launch a starter store, then return HQ'));
    expect(providerSource, contains('hasServerConfirmedStarterStore'));
    expect(providerSource, isNot(contains('Review your first empire move')));
    expect(providerSource, isNot(contains('Check Feed')));

    expect(repositorySource, contains('hasServerConfirmedStarterStore'));
    expect(repositorySource, contains(".from('store_summary')"));
    expect(repositorySource, contains(".eq('type', 'ecommerce')"));
  });

  test('stale premium path-switching copy is removed', () {
    final String source =
        File('lib/features/onboarding/screens/career_path_screen.dart')
            .readAsStringSync();

    expect(source, isNot(contains('premium currency')));
    expect(source, contains('Joint Venture'));
  });

  test('first-session advanced systems are locked or hidden', () {
    final String shellSource =
        File('lib/presentation/screens/main_shell.dart').readAsStringSync();
    final String architectSource =
        File('lib/features/hq/widgets/hq_architect_view.dart')
            .readAsStringSync();
    final String artisanSource =
        File('lib/features/hq/widgets/hq_artisan_view.dart').readAsStringSync();
    final String districtSource =
        File('lib/features/maison/screens/district_map_screen.dart')
            .readAsStringSync();

    expect(shellSource, contains("label: 'LOCKED'"));
    expect(shellSource, contains('enabled: false'));
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
