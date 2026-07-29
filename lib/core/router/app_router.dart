// GDD v7 §§18, 21, 22 — compile-safe Early Game navigation only.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/design.dart';
import '../../domain/models/player.dart';
import '../../features/atelier/screens/atelier_screen.dart';
import '../../features/capsule/screens/capsule_workspace_screen.dart';
import '../../features/feed/screens/feed_screen.dart';
import '../../features/hq/providers/hq_provider.dart';
import '../../features/hq/screens/hq_screen.dart';
import '../../features/ledger/screens/ledger_screen.dart';
import '../../features/onboarding/screens/aurelian_gate_screen.dart';
import '../../features/onboarding/screens/founder_trial_screen.dart';
import '../../features/onboarding/screens/origin_script_screen.dart';
import '../../features/onboarding/screens/sovereign_registry_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../presentation/screens/main_shell.dart';
import 'feature_registry.dart';
import 'feature_unavailable_screen.dart';

abstract final class AppRouter {
  static const String onboardingAurelianGate = '/onboarding/aurelian-gate';
  static const String onboardingOriginScript = '/onboarding/origin-script';
  static const String onboardingSovereignRegistry =
      '/onboarding/sovereign-registry';
  static const String onboardingFounderTrial = '/onboarding/founder-trial';

  // Former questionnaire routes remain compile-safe but deliberately
  // unavailable in Gate A. Preserved historical screens therefore cannot
  // create a reachable deep link or regain onboarding authority.
  static const String onboardingBrandSelection = '/unavailable';
  static const String onboardingAvatarCustomiser = '/unavailable';
  static const String onboardingCareerPath = '/unavailable';
  static const String onboardingWhatsNext = '/unavailable';

  static const String hq = '/hq';
  static const String atelier = '/atelier';
  static const String atelierCapsule = '/atelier/capsule';
  static const String atelierDropPreview = '/atelier/drop-preview';
  static const String atelierDropLaunch = '/atelier/drop-launch';
  static const String ledger = '/empire';
  static const String feed = '/feed';
  static const String house = '/house';
  static const String profile = house;
  static const String settings = '/house/settings';

  // Compile-safe legacy constants. They deliberately resolve to the safe
  // unavailable route until a later-wave feature package is reviewed.
  static const String maison = '/unavailable';
  static const String bank = '/unavailable';
  static const String equity = '/unavailable';
  static const String districtMap = '/unavailable';
  static const String events = '/unavailable';
  static const String arTryon = '/unavailable';
  static const String shop = '/unavailable';
  static const String hallOfSovereigns = '/unavailable';
  static const String crisisKintsugi = '/unavailable';
  static const String castingRoom = '/unavailable';
  static const String galaRunway = '/unavailable';
  static const String archiveMarket = '/unavailable';
  static const String aurelianStorefront = '/unavailable';

  static final GoRouter router = GoRouter(
    initialLocation: onboardingAurelianGate,
    redirect: (BuildContext context, GoRouterState state) {
      final ProviderContainer container = ProviderScope.containerOf(
        context,
        listen: false,
      );
      final FeatureRegistry registry = container.read(featureRegistryProvider);
      final AppFeature? feature = _featureForLocation(state.matchedLocation);
      if (feature != null && !registry.isEnabled(feature)) {
        return '/unavailable';
      }
      if (!state.matchedLocation.startsWith('/onboarding')) {
        return null;
      }
      final AsyncValue<Player> player = container.read(hqPlayerStreamProvider);
      return player.maybeWhen(
        data: (Player value) => value.onboardingComplete ? hq : null,
        orElse: () => null,
      );
    },
    errorBuilder: (BuildContext context, GoRouterState state) =>
        const FeatureUnavailableScreen(),
    routes: <RouteBase>[
      GoRoute(
        path: '/unavailable',
        builder: (_, __) => const FeatureUnavailableScreen(),
      ),
      GoRoute(
        path: onboardingAurelianGate,
        builder: (_, __) => const AurelianGateScreen(),
      ),
      GoRoute(
        path: onboardingOriginScript,
        builder: (_, __) => const OriginScriptScreen(),
      ),
      GoRoute(
        path: onboardingSovereignRegistry,
        builder: (_, __) => const SovereignRegistryScreen(),
      ),
      GoRoute(
        path: onboardingFounderTrial,
        builder: (_, __) => const FounderTrialScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) =>
            MainShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(path: hq, builder: (_, __) => const HqScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: atelier,
                builder: (BuildContext context, GoRouterState state) {
                  final Object? extra = state.extra;
                  return AtelierScreen(
                    inspirationDesign: extra is Design ? extra : null,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(path: ledger, builder: (_, __) => const LedgerScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(path: feed, builder: (_, __) => const FeedScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(path: house, builder: (_, __) => const ProfileScreen()),
            ],
          ),
        ],
      ),
      GoRoute(
        path: atelierDropPreview,
        builder: (_, __) => const FeatureUnavailableScreen(
          title: 'Drop preview is held',
          message:
              'Gate A ends at capsule readiness. Drop preview will return only after the launch authority gate is approved.',
          returnLocation: atelier,
        ),
      ),
      GoRoute(
        path: atelierDropLaunch,
        builder: (_, __) => const FeatureUnavailableScreen(
          title: 'Drop launch is held',
          message:
              'Launch, Vex review, rewards, and market outcomes are outside this build. No launch request has been started.',
          returnLocation: atelier,
        ),
      ),
      GoRoute(
        path: atelierCapsule,
        builder: (_, __) => const CapsuleWorkspaceScreen(),
      ),
      GoRoute(path: settings, builder: (_, __) => const SettingsScreen()),
    ],
  );

  static AppFeature? _featureForLocation(String location) {
    if (location == hq) return AppFeature.hq;
    if (location.startsWith(atelier)) return AppFeature.atelier;
    if (location.startsWith(ledger)) return AppFeature.empire;
    if (location == feed) return AppFeature.feed;
    if (location.startsWith(house)) return AppFeature.house;
    return null;
  }
}
