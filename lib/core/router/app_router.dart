// PROJECT_RULES §3 — go_router navigation shell
// GDD §1.1 — Onboarding flow → Shell (HQ | Feed) → path-specific screens
// Phase 6: StatefulShellRoute for HQ + Feed persistent tabs.
// Atelier / Ledger are pushed routes over the shell — session screens, not tabs.

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/design.dart';
import '../../domain/models/player.dart';
import '../../features/ar_tryon/screens/ar_tryon_screen.dart';
import '../../features/archive/screens/archive_market_screen.dart';
import '../../features/ascension/screens/hall_of_sovereigns_screen.dart';
import '../../features/atelier/screens/atelier_screen.dart';
import '../../features/atelier/screens/drop_preview_screen.dart';
import '../../features/crisis/screens/kintsugi_repair_screen.dart';
import '../../features/events/screens/events_screen.dart';
import '../../features/feed/screens/feed_screen.dart';
import '../../features/gala/screens/gala_runway_screen.dart';
import '../../features/hq/providers/hq_provider.dart';
import '../../features/hq/screens/hq_screen.dart';
import '../../features/ledger/screens/bank_screen.dart';
import '../../features/ledger/screens/equity_screen.dart';
import '../../features/ledger/screens/ledger_screen.dart';
import '../../features/maison/screens/district_map_screen.dart';
import '../../features/maison/screens/maison_screen.dart';
import '../../features/onboarding/screens/ascension_confirmation_screen.dart';
import '../../features/onboarding/screens/aurelian_gate_screen.dart';
import '../../features/onboarding/screens/avatar_customizer_screen.dart';
import '../../features/onboarding/screens/brand_footprint_screen.dart';
import '../../features/onboarding/screens/career_path_screen.dart';
import '../../features/onboarding/screens/origin_script_screen.dart';
import '../../features/onboarding/screens/sovereign_registry_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/store/screens/aurelian_storefront_screen.dart';
import '../../features/store/screens/shop_screen.dart';
import '../../features/talent/screens/casting_room_screen.dart';
import '../../presentation/screens/main_shell.dart';

abstract final class AppRouter {
  // --- Route names ---
  static const String onboardingAurelianGate = '/onboarding/aurelian-gate';
  static const String onboardingOriginScript = '/onboarding/origin-script';
  static const String onboardingSovereignRegistry = '/onboarding/sovereign-registry';
  static const String onboardingBrandSelection = '/onboarding/brand-selection';
  static const String onboardingAvatarCustomiser = '/onboarding/avatar-customiser';
  static const String onboardingCareerPath = '/onboarding/career-path';
  static const String onboardingWhatsNext = '/onboarding/whats-next';

  static const String hq = '/hq';
  static const String feed = '/feed';
  static const String atelier = '/atelier';
  static const String atelierDropPreview = '/atelier/drop-preview';
  static const String ledger = '/ledger';
  static const String maison = '/maison';
  static const String bank = '/bank';
  static const String equity = '/equity';
  static const String districtMap = '/district-map';
  static const String events = '/events';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String arTryon = '/ar-tryon';
  static const String shop = '/shop';
  static const String hallOfSovereigns = '/hall-of-sovereigns';
  
  // --- Directive H: Crisis Engine ---
  static const String crisisKintsugi = '/crisis/kintsugi';
  
  // --- Directive I: Sovereign Talent ---
  static const String castingRoom = '/casting-room';
  
  // --- Directive J: Aurelian Gala ---
  static const String galaRunway = '/gala/runway';
  
  // --- Directive K: The Archive ---
  static const String archiveMarket = '/archive/market';
  
  // --- Directive M: The Aurelian Storefront ---
  static const String aurelianStorefront = '/store/aurelian-storefront';

  static final GoRouter router = GoRouter(
    initialLocation: onboardingAurelianGate,
    // GDD §1.1 — Redirect returning players past onboarding to HQ
    // Option B: synchronous Riverpod cache — zero latency, works offline
    // Guards against anonymous sessions being misidentified as returning players
    redirect: (BuildContext context, GoRouterState state) {
      final bool isOnboarding = state.matchedLocation.startsWith('/onboarding');
      if (!isOnboarding) return null;

      // Read cached player stream — no network call, no async race
      final ProviderContainer container =
          ProviderScope.containerOf(context, listen: false);
      final AsyncValue<Player> playerAsync =
          container.read(hqPlayerStreamProvider);

      return playerAsync.maybeWhen(
        data: (Player player) => player.onboardingComplete ? hq : null,
        orElse: () => null, // Stream not loaded — let onboarding proceed safely
      );
    },
    routes: <RouteBase>[
      // --- Onboarding (GDD §1.1) — Directive G Complete Sequence ---
      GoRoute(
        path: onboardingAurelianGate,
        builder: (BuildContext context, GoRouterState state) =>
            const AurelianGateScreen(),
      ),
      GoRoute(
        path: onboardingOriginScript,
        builder: (BuildContext context, GoRouterState state) =>
            const OriginScriptScreen(),
      ),
      GoRoute(
        path: onboardingSovereignRegistry,
        builder: (BuildContext context, GoRouterState state) =>
            const SovereignRegistryScreen(),
      ),
      // --- Screen 4: Brand Footprint (City + Tier) ---
      GoRoute(
        path: onboardingBrandSelection,
        builder: (BuildContext context, GoRouterState state) =>
            const BrandFootprintScreen(),
      ),
      // --- Screen 5: Avatar Customizer ---
      GoRoute(
        path: onboardingAvatarCustomiser,
        builder: (BuildContext context, GoRouterState state) =>
            const AvatarCustomizerScreen(),
      ),
      GoRoute(
        path: onboardingCareerPath,
        builder: (BuildContext context, GoRouterState state) =>
            const CareerPathScreen(),
      ),
      // --- Screen 7: Ascension Confirmation ---
      GoRoute(
        path: onboardingWhatsNext,
        builder: (BuildContext context, GoRouterState state) =>
            const AscensionConfirmationScreen(),
      ),

      // ── Authenticated shell (GDD §3.0 + §6.1 + §6.3) ———————————————
      // StatefulShellRoute keeps HQ, Feed, Maison branch trees alive across switches.
      // Atelier / Ledger are GoRoutes pushed on top of the shell.
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell,) {
          return MainShell(
            navigationShell: navigationShell,
            player: null, // Shell reads player internally from HqScreen stream.
          );
        },
        branches: <StatefulShellBranch>[
          // Branch 0 — HQ Dashboard
          StatefulShellBranch(
            routes: <GoRoute>[
              GoRoute(
                path: hq,
                builder: (BuildContext context, GoRouterState state) =>
                    const HqScreen(),
              ),
            ],
          ),

          // Branch 1 — Global Feed
          StatefulShellBranch(
            routes: <GoRoute>[
              GoRoute(
                path: feed,
                builder: (BuildContext context, GoRouterState state) =>
                    const FeedScreen(),
              ),
            ],
          ),

          // Branch 2 — Maison Hub (GDD §6.3)
          StatefulShellBranch(
            routes: <GoRoute>[
              GoRoute(
                path: maison,
                builder: (BuildContext context, GoRouterState state) =>
                    const MaisonScreen(),
              ),
            ],
          ),
        ],
      ),

      // --- Atelier: Designer session (GDD §4.1) — pushed over shell ---
      GoRoute(
        path: atelier,
        builder: (BuildContext context, GoRouterState state) =>
            const AtelierScreen(),
      ),

      // --- Atelier Drop Preview: Vex Critic integration (GDD v6) ---
      GoRoute(
        path: atelierDropPreview,
        builder: (BuildContext context, GoRouterState state) {
          final Design design = state.extra! as Design;
          return DropPreviewScreen(design: design);
        },
      ),

      // --- Ledger: Mogul capital allocation (GDD §5.1) — pushed over shell ---
      GoRoute(
        path: ledger,
        builder: (BuildContext context, GoRouterState state) =>
            const LedgerScreen(),
      ),

      // --- Shop: THE VAULT — Luxe Token IAP (GDD §9.8) — pushed over shell ---
      GoRoute(
        path: shop,
        builder: (BuildContext context, GoRouterState state) =>
            const ShopScreen(),
      ),

      // --- AR Try-On: camera viewport (GDD §4.4) — pushed over shell ---
      GoRoute(
        path: arTryon,
        builder: (BuildContext context, GoRouterState state) =>
            const ArTryOnScreen(),
      ),

      GoRoute(
        path: events,
        builder: (BuildContext context, GoRouterState state) =>
            const EventsScreen(),
      ),

      GoRoute(
        path: profile,
        builder: (BuildContext context, GoRouterState state) =>
            const ProfileScreen(),
      ),

      // --- District Map: Maison turf war (GDD v6) ---
      GoRoute(
        path: districtMap,
        builder: (BuildContext context, GoRouterState state) =>
            const DistrictMapScreen(),
      ),
      
      // --- Directive O: Mogul Terminals ---
      GoRoute(
        path: bank,
        builder: (BuildContext context, GoRouterState state) =>
            const BankScreen(),
      ),
      GoRoute(
        path: equity,
        builder: (BuildContext context, GoRouterState state) =>
            const EquityScreen(),
      ),

      // --- Hall of Sovereigns: Rank 100 memorialization (GDD v6) ---
      GoRoute(
        path: hallOfSovereigns,
        builder: (BuildContext context, GoRouterState state) =>
            const HallOfSovereignsScreen(),
      ),
      
      // --- Directive H: Crisis Engine Routes ---
      GoRoute(
        path: crisisKintsugi,
        builder: (BuildContext context, GoRouterState state) =>
            const KintsugiRepairScreen(),
      ),
      
      // --- Directive I: Sovereign Talent Routes ---
      GoRoute(
        path: castingRoom,
        builder: (BuildContext context, GoRouterState state) =>
            const CastingRoomScreen(),
      ),
      
      // --- Directive J: Aurelian Gala Routes ---
      GoRoute(
        path: galaRunway,
        builder: (BuildContext context, GoRouterState state) =>
            const GalaRunwayScreen(),
      ),
      
      // --- Directive K: The Archive Routes ---
      GoRoute(
        path: archiveMarket,
        builder: (BuildContext context, GoRouterState state) =>
            const ArchiveMarketScreen(),
      ),
      
      // --- Directive M: The Aurelian Storefront Routes ---
      GoRoute(
        path: aurelianStorefront,
        builder: (BuildContext context, GoRouterState state) =>
            const AurelianStorefrontScreen(),
      ),

      // --- GDD §3.6: Settings ---
      GoRoute(
        path: settings,
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsScreen(),
      ),
    ],
  );
}
