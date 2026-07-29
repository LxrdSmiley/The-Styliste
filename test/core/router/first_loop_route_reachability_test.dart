import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Gate A routes preserve the capsule and deny deferred drop routes', () {
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
    expect(
      routerSource,
      contains("static const String atelierCapsule = '/atelier/capsule';"),
    );
    expect(
      routerSource,
      contains(
        "static const String onboardingFounderTrial = '/onboarding/founder-trial';",
      ),
    );

    expect(routerSource, contains('StatefulShellRoute.indexedStack'));
    expect(routerSource, contains('path: hq'));
    expect(routerSource, contains('path: feed'));
    expect(routerSource, contains('path: atelier'));
    expect(routerSource, contains('path: atelierDropPreview'));
    expect(routerSource, contains('path: atelierDropLaunch'));
    expect(routerSource, contains('path: atelierCapsule'));
    expect(routerSource, contains('path: ledger'));
    expect(routerSource, contains('path: onboardingFounderTrial'));
    expect(routerSource, isNot(contains('path: onboardingBrandSelection')));
    expect(routerSource, isNot(contains('path: onboardingAvatarCustomiser')));
    expect(routerSource, isNot(contains('path: onboardingCareerPath')));
    expect(routerSource, isNot(contains('drop_preview_screen.dart')));
    expect(routerSource, isNot(contains('drop_launch_scene_screen.dart')));
    expect(routerSource, contains('Gate A ends at capsule readiness'));
    expect(routerSource, contains('No launch request has been started'));
  });

  test('five canonical destinations are available in the Early Game shell', () {
    final String shellSource =
        File('lib/presentation/screens/main_shell.dart').readAsStringSync();
    final String navigationSource =
        File('lib/core/widgets/aurelian_navigation.dart').readAsStringSync();

    for (final String label in <String>[
      'HQ',
      'Atelier',
      'Empire',
      'Feed',
      'House',
    ]) {
      expect(navigationSource, contains("label: '$label'"));
    }
    expect(shellSource, isNot(contains("label: 'LOCKED'")));
    expect(shellSource, contains('navigationShell.goBranch(0)'));
    expect(navigationSource, contains('selectedIndex: currentIndex'));
    expect(navigationSource, contains("label: 'Primary navigation'"));
  });
}
