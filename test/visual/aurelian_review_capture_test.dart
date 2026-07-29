import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_styliste/app.dart';
import 'package:the_styliste/core/providers/active_player_provider.dart';
import 'package:the_styliste/core/providers/auth_provider.dart';
import 'package:the_styliste/core/router/feature_unavailable_screen.dart';
import 'package:the_styliste/core/theme/aurelian_theme.dart';
import 'package:the_styliste/core/theme/styliste_visual_mode.dart';
import 'package:the_styliste/core/widgets/aurelian_components.dart';
import 'package:the_styliste/core/widgets/aurelian_navigation.dart';
import 'package:the_styliste/core/widgets/styliste_scaffold.dart';
import 'package:the_styliste/domain/models/brand.dart';
import 'package:the_styliste/domain/models/feed_post.dart';
import 'package:the_styliste/domain/models/player.dart';
import 'package:the_styliste/domain/models/store.dart';
import 'package:the_styliste/features/atelier/screens/atelier_screen.dart';
import 'package:the_styliste/features/capsule/providers/capsule_foundation_provider.dart';
import 'package:the_styliste/features/capsule/screens/capsule_workspace_screen.dart';
import 'package:the_styliste/features/feed/providers/feed_provider.dart';
import 'package:the_styliste/features/feed/screens/feed_screen.dart';
import 'package:the_styliste/features/ftue/providers/first_objective_provider.dart';
import 'package:the_styliste/features/ftue/repositories/first_objective_repository.dart';
import 'package:the_styliste/features/hq/providers/hq_provider.dart';
import 'package:the_styliste/features/hq/widgets/hq_architect_view.dart';
import 'package:the_styliste/features/hq/widgets/hq_artisan_view.dart';
import 'package:the_styliste/features/ledger/providers/ledger_provider.dart';
import 'package:the_styliste/features/ledger/screens/ledger_screen.dart';
import 'package:the_styliste/features/legal/legal_documents.dart';
import 'package:the_styliste/features/legal/screens/legal_document_screen.dart';
import 'package:the_styliste/features/onboarding/providers/founder_trial_provider.dart';
import 'package:the_styliste/features/onboarding/screens/aurelian_gate_screen.dart';
import 'package:the_styliste/features/onboarding/screens/founder_trial_screen.dart';
import 'package:the_styliste/features/onboarding/screens/origin_script_screen.dart';
import 'package:the_styliste/features/onboarding/screens/sovereign_registry_screen.dart';
import 'package:the_styliste/features/profile/screens/profile_screen.dart';
import 'package:the_styliste/features/settings/screens/settings_screen.dart';
import 'package:the_styliste/features/supply_chain/models/supply_chain_models.dart';
import 'package:the_styliste/features/supply_chain/providers/supply_chain_provider.dart';
import 'package:the_styliste/features/trends/models/trend_tsunami.dart';
import 'package:the_styliste/features/trends/providers/trend_provider.dart';

const bool _captureEnabled = bool.fromEnvironment('CAPTURE_AURELIAN_UI');
const String _captureSet = String.fromEnvironment(
  'AURELIAN_CAPTURE_SET',
  defaultValue: 'local',
);
const Key _captureBoundaryKey = Key('aurelian-review-capture-boundary');
const Size _phoneSize = Size(390, 844);

void main() {
  setUpAll(() async {
    await _loadFont('SpaceGrotesk', 'assets/fonts/SpaceGrotesk-Variable.ttf');
    await _loadFont('Inter', 'assets/fonts/Inter-Variable.ttf');
    await _loadFont(
      'JetBrainsMono',
      'assets/fonts/JetBrainsMono-Variable.ttf',
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'age_gate_passed': true,
    });
    final TestDefaultBinaryMessenger messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (MethodCall call) async => null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/accelerometer'),
      (MethodCall call) async => null,
    );
  });

  testWidgets('capture secure session loading', (WidgetTester tester) async {
    await _capture(
      tester,
      name: 'session_loading',
      app: const AurelianSessionGate(),
    );
  });

  testWidgets('capture safe authentication failure', (
    WidgetTester tester,
  ) async {
    await _capture(
      tester,
      name: 'session_safe_failure',
      app: const AurelianSessionGate(
        errorMessage:
            'Authentication is unavailable. Retry when you are ready.',
      ),
    );
  });

  testWidgets('capture Opening Sanctuary', (WidgetTester tester) async {
    await _capture(
      tester,
      name: 'opening_sanctuary',
      app: const _ReviewApp(home: AurelianGateScreen()),
      pumpFor: const Duration(milliseconds: 80),
    );
  });

  testWidgets('capture age gate', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await _capture(
      tester,
      name: 'age_gate',
      app: const _ReviewApp(home: AurelianGateScreen()),
      prepare: (WidgetTester tester) async {
        await tester.pump(const Duration(milliseconds: 360));
        await tester.pump();
      },
    );
  });

  testWidgets('capture Luxe introduction', (WidgetTester tester) async {
    await _capture(
      tester,
      name: 'luxe_introduction',
      app: const _ReviewApp(home: OriginScriptScreen()),
      pumpFor: const Duration(milliseconds: 640),
    );
  });

  testWidgets('capture House naming', (WidgetTester tester) async {
    await _capture(
      tester,
      name: 'house_naming',
      app: const ProviderScope(
        child: _ReviewApp(home: SovereignRegistryScreen()),
      ),
    );
  });

  testWidgets('capture Founder Trial entry', (
    WidgetTester tester,
  ) async {
    await _capture(
      tester,
      name: 'founder_trial_entry',
      app: ProviderScope(
        overrides: <Override>[
          supabaseAuthActionsProvider.overrideWithValue(
            const _CaptureAuthActions(),
          ),
          founderTrialGatewayProvider.overrideWithValue(
            const _CaptureFounderTrialGateway(),
          ),
        ],
        child: const _ReviewApp(home: FounderTrialScreen()),
      ),
    );
  });

  testWidgets('capture restored Founder Trial receipt', (
    WidgetTester tester,
  ) async {
    await _capture(
      tester,
      name: 'founder_trial_restored',
      app: ProviderScope(
        overrides: <Override>[
          founderTrialProvider.overrideWith(
            (Ref ref) => _CaptureFounderTrialNotifier(
              const FounderTrialState(
                stage: FounderTrialStage.completed,
                specialization: 'artisan',
                receiptId: 'trial-receipt-001',
                restored: true,
              ),
            ),
          ),
        ],
        child: const _ReviewApp(home: FounderTrialScreen()),
      ),
    );
  });

  testWidgets('capture Artisan HQ', (WidgetTester tester) async {
    await _capture(
      tester,
      name: 'hq_artisan',
      app: _hqHarness(
        child: HqArtisanView(player: _player(CareerPath.designer)),
      ),
    );
  });

  testWidgets('capture Architect HQ', (WidgetTester tester) async {
    await _capture(
      tester,
      name: 'hq_architect',
      app: _hqHarness(
        child: HqArchitectView(player: _player(CareerPath.mogul)),
      ),
    );
  });

  testWidgets('capture Atelier', (WidgetTester tester) async {
    await _capture(
      tester,
      name: 'atelier_workspace',
      app: ProviderScope(
        overrides: <Override>[
          activeTsunamiProvider.overrideWith(
            (Ref ref) => Stream<List<TrendTsunami>>.value(
              const <TrendTsunami>[],
            ),
          ),
        ],
        child: const _ReviewApp(
          home: AtelierScreen(prepareSessionOnStart: false),
        ),
      ),
    );
  });

  testWidgets('capture capsule brief', (WidgetTester tester) async {
    await _capture(
      tester,
      name: 'capsule_collection_brief',
      app: ProviderScope(
        overrides: <Override>[
          capsuleFoundationGatewayProvider.overrideWithValue(
            const _CaptureCapsuleGateway(),
          ),
        ],
        child: const _ReviewApp(home: CapsuleWorkspaceScreen()),
      ),
      pumpFor: const Duration(milliseconds: 80),
    );
  });

  testWidgets('capture Hero Piece workspace', (WidgetTester tester) async {
    await _capture(
      tester,
      name: 'capsule_hero_piece',
      app: _capsuleHarness(
        _capsuleReceipt(stage: 'brief_confirmed'),
      ),
      pumpFor: const Duration(milliseconds: 80),
    );
  });

  testWidgets('capture readiness and sampling boundary', (
    WidgetTester tester,
  ) async {
    await _capture(
      tester,
      name: 'capsule_readiness_sampling_boundary',
      app: _capsuleHarness(
        _capsuleReceipt(
          stage: 'sampling_unavailable',
          completedLooks: 3,
          samplingUnavailable: true,
        ),
      ),
      pumpFor: const Duration(milliseconds: 80),
    );
  });

  testWidgets('capture Empire projection', (WidgetTester tester) async {
    await _capture(
      tester,
      name: 'empire_projection',
      app: _ledgerHarness(),
      pumpFor: const Duration(milliseconds: 80),
    );
  });

  testWidgets('capture first-store dialog', (WidgetTester tester) async {
    await _capture(
      tester,
      name: 'first_store_dialog',
      app: const _ReviewApp(
        home: Scaffold(
          body: Center(
            child: FirstStoreDialog(currentBalance: 2500),
          ),
        ),
      ),
    );
  });

  testWidgets('capture Feed', (WidgetTester tester) async {
    await _capture(
      tester,
      name: 'feed_projection',
      app: _feedHarness(),
      pumpFor: const Duration(milliseconds: 80),
    );
  });

  testWidgets('capture read-only comment sheet', (WidgetTester tester) async {
    await _capture(
      tester,
      name: 'feed_comment_sheet',
      app: _feedSheetHarness(
        FeedCommentSheet(post: _feedPost()),
      ),
    );
  });

  testWidgets('capture held request sheet', (WidgetTester tester) async {
    await _capture(
      tester,
      name: 'feed_request_sheet',
      app: _feedSheetHarness(
        FeedRequestsSheet(post: _feedPost()),
      ),
    );
  });

  testWidgets('capture House identity', (WidgetTester tester) async {
    await _capture(
      tester,
      name: 'house_identity',
      app: _houseHarness(),
    );
  });

  testWidgets('capture settings', (WidgetTester tester) async {
    await _capture(
      tester,
      name: 'settings',
      app: const _ReviewApp(home: SettingsScreen()),
      pumpFor: const Duration(milliseconds: 80),
    );
  });

  testWidgets('capture legal document', (WidgetTester tester) async {
    await _capture(
      tester,
      name: 'legal_privacy',
      app: _ReviewApp(
        home: LegalDocumentScreen(document: LegalDocuments.all.first),
      ),
    );
  });

  testWidgets('capture unavailable boundary', (WidgetTester tester) async {
    await _capture(
      tester,
      name: 'drop_route_unavailable',
      app: const _ReviewApp(
        home: FeatureUnavailableScreen(
          title: 'Drop launch is held',
          message:
              'Launch, Vex review, rewards, and market outcomes are outside this build. No launch request has been started.',
        ),
      ),
    );
  });

  testWidgets('capture canonical five-tab navigation', (
    WidgetTester tester,
  ) async {
    await _capture(
      tester,
      name: 'five_tab_navigation',
      app: _ReviewApp(
        home: AurelianScaffold(
          mode: StylisteVisualMode.noirCinematic,
          body: const Center(
            child: AurelianStatePanel(
              kind: AurelianStateKind.confirmed,
              title: 'Kingston House restored',
              message: 'Choose one of the five Early Game destinations.',
            ),
          ),
          bottomNavigationBar: AurelianBottomNavigation(
            currentIndex: 0,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );
  });
}

class _ReviewApp extends StatelessWidget {
  const _ReviewApp({required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AurelianTheme.darkTheme,
      home: home,
    );
  }
}

Future<void> _capture(
  WidgetTester tester, {
  required String name,
  required Widget app,
  Duration pumpFor = const Duration(milliseconds: 32),
  Future<void> Function(WidgetTester tester)? prepare,
}) async {
  await tester.binding.setSurfaceSize(_phoneSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureBoundaryKey,
      child: SizedBox.fromSize(size: _phoneSize, child: app),
    ),
  );
  await tester.pump(pumpFor);
  await tester.pump();
  if (prepare != null) await prepare(tester);

  expect(tester.takeException(), isNull, reason: name);
  if (!_captureEnabled) return;

  await tester.runAsync(() async {
    final RenderRepaintBoundary boundary =
        tester.renderObject<RenderRepaintBoundary>(
      find.byKey(_captureBoundaryKey),
    );
    final ui.Image image = await boundary.toImage(pixelRatio: 1.5);
    final ByteData? bytes = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();
    if (bytes == null) {
      throw StateError('PNG encoding returned no bytes for $name.');
    }

    final Directory output = Directory(
      'docs/verification/aurelian_ui_redesign/captures/$_captureSet',
    );
    await output.create(recursive: true);
    await File('${output.path}/$name.png').writeAsBytes(
      bytes.buffer.asUint8List(),
      flush: true,
    );
  });
}

Future<void> _loadFont(String family, String asset) async {
  final FontLoader loader = FontLoader(family)..addFont(rootBundle.load(asset));
  await loader.load();
}

Widget _hqHarness({required Widget child}) {
  final Player designer = _player(CareerPath.designer);
  final Brand brand = _brand();

  return ProviderScope(
    overrides: <Override>[
      activeUidProvider.overrideWith((Ref ref) => designer.id),
      firstObjectiveRepositoryProvider.overrideWith(
        (Ref ref) => const _CaptureFirstObjectiveRepository(),
      ),
      hqPlayerStreamProvider.overrideWith(
        (Ref ref) => Stream<Player>.value(designer),
      ),
      hqBrandStreamProvider.overrideWith(
        (Ref ref) => Stream<Brand>.value(brand),
      ),
      latestAlphaDropProvider.overrideWith(
        (Ref ref) async => const LatestAlphaDropSummary(
          feedPostId: 'drop-capture',
          designName: 'Kingston Studio Study',
          hypeScore: 84,
          marketReaction: 'Rising',
          followersDelta: 12,
        ),
      ),
      supplyChainProvider.overrideWith(
        (Ref ref) => Stream<SupplyChainState>.value(
          const SupplyChainState(currentInventoryValue: 1200),
        ),
      ),
    ],
    child: _ReviewApp(home: child),
  );
}

Widget _houseHarness() {
  return ProviderScope(
    overrides: <Override>[
      hqPlayerStreamProvider.overrideWith(
        (Ref ref) => Stream<Player>.value(_player(CareerPath.designer)),
      ),
    ],
    child: const _ReviewApp(home: ProfileScreen()),
  );
}

Widget _ledgerHarness() {
  return ProviderScope(
    overrides: <Override>[
      ledgerStoresStreamProvider.overrideWith(
        (Ref ref) => Stream<List<Store>>.value(const <Store>[]),
      ),
      hqBrandStreamProvider.overrideWith(
        (Ref ref) => Stream<Brand>.value(_brand()),
      ),
    ],
    child: const _ReviewApp(home: LedgerScreen()),
  );
}

Widget _feedHarness() {
  return ProviderScope(
    overrides: <Override>[
      activeUidProvider.overrideWith((Ref ref) => 'capture-player'),
      feedStreamProvider.overrideWith(
        (Ref ref) => Stream<List<FeedPost>>.value(<FeedPost>[_feedPost()]),
      ),
      followingIdsProvider.overrideWith(
        (Ref ref) => Stream<Set<String>>.value(const <String>{}),
      ),
      syndicateFeedProvider.overrideWith(
        (Ref ref) async => const <FeedPost>[],
      ),
    ],
    child: const _ReviewApp(home: FeedScreen()),
  );
}

Widget _feedSheetHarness(Widget sheet) {
  return ProviderScope(
    child: _ReviewApp(
      home: Theme(
        data: AurelianTheme.darkTheme,
        child: Scaffold(
          backgroundColor: Colors.black54,
          body: Align(
            alignment: Alignment.bottomCenter,
            child: sheet,
          ),
        ),
      ),
    ),
  );
}

Widget _capsuleHarness(Map<String, dynamic> receipt) {
  return ProviderScope(
    overrides: <Override>[
      capsuleFoundationGatewayProvider.overrideWithValue(
        _ReceiptCapsuleGateway(receipt),
      ),
    ],
    child: const _ReviewApp(home: CapsuleWorkspaceScreen()),
  );
}

Player _player(CareerPath path) {
  return Player(
    id: 'capture-player',
    brandName: 'House Meridian',
    path: path,
    hqCity: HqCity.kingston,
    onboardingComplete: true,
  );
}

FeedPost _feedPost() {
  return FeedPost(
    id: 'feed-capture',
    playerId: 'capture-player',
    type: 'design_flex',
    content: const <String, dynamic>{
      'brand_name': 'House Meridian',
      'design_name': 'Kingston Studio Study',
      'fabric_color_hex': 'D6A84F',
      'result_explanation':
          'The House record confirms a clear silhouette and measured material direction.',
    },
    hype: 42,
    likes: 7,
    createdAt: DateTime.utc(2026, 7, 27),
  );
}

Map<String, dynamic> _capsuleReceipt({
  required String stage,
  int completedLooks = 0,
  bool samplingUnavailable = false,
}) {
  const Map<String, dynamic> grammar = <String, dynamic>{
    'silhouette': 'structured',
    'material': 'cotton_twill',
    'palette': 'ivory_obsidian',
    'construction': 'sharp_panel',
  };
  const List<String> roles = <String>[
    'hero_piece',
    'commercial_anchor',
    'experimental_piece',
  ];
  return <String, dynamic>{
    'status': samplingUnavailable ? 'restored' : 'confirmed',
    'capsule': <String, dynamic>{
      'stage': stage,
      'founder_specialization': 'artisan',
      'brief': const <String, dynamic>{
        'title': 'Kingston Frequency',
        'narrative': 'Tailored movement shaped by sound and community proof.',
      },
      'looks': <Object?>[
        for (int index = 0; index < roles.length; index++)
          <String, dynamic>{
            'role': roles[index],
            'grammar': index < completedLooks ? grammar : null,
          },
      ],
      'readiness': const <String, dynamic>{
        'causes': <String>[
          'One shared palette direction',
          'Three distinct garment roles',
          'Construction choices preserve the House line',
        ],
      },
      'sampling': <String, dynamic>{
        'status': samplingUnavailable ? 'unavailable' : 'not_reached',
      },
    },
  };
}

Brand _brand() {
  return const Brand(
    playerId: 'capture-player',
    heat: 24,
    hypeScore: 120,
    followers: 480,
    idleRevenuePerHour: 90,
    totalRevenue: 1400,
  );
}

final class _CaptureAuthActions implements SupabaseAuthActions {
  const _CaptureAuthActions();

  @override
  Future<String> requireEstablishedUserId() async => 'capture-player';

  @override
  Future<String> retrySession() async => 'capture-player';

  @override
  Future<void> signOutAndRestart() async {}
}

final class _CaptureFounderTrialGateway implements FounderTrialGateway {
  const _CaptureFounderTrialGateway();

  @override
  Future<Map<String, dynamic>> submit(Map<String, dynamic> intent) async {
    return <String, dynamic>{
      'stage': 'shared_starter_garment',
      'next_action': 'complete_artisan_sample',
    };
  }
}

final class _CaptureFounderTrialNotifier extends FounderTrialNotifier {
  _CaptureFounderTrialNotifier(FounderTrialState initial)
      : super(const _CaptureFounderTrialGateway()) {
    state = initial;
  }
}

final class _CaptureFirstObjectiveRepository
    implements FirstObjectiveRepository {
  const _CaptureFirstObjectiveRepository();

  @override
  Future<bool> hasServerConfirmedAlphaDrop(String playerId) async => false;

  @override
  Future<bool> hasServerConfirmedStarterStore(String playerId) async => false;

  @override
  Stream<List<FirstWeekObjective>> watchObjectives(String playerId) {
    return Stream<List<FirstWeekObjective>>.value(
      const <FirstWeekObjective>[],
    );
  }

  @override
  Future<void> recordValidatedEvent(
    String eventKey, {
    String? entityId,
  }) async {}
}

final class _CaptureCapsuleGateway implements CapsuleFoundationGateway {
  const _CaptureCapsuleGateway();

  @override
  Future<Map<String, dynamic>> submit(Map<String, dynamic> intent) async {
    return _capsuleReceipt(stage: 'brief_draft');
  }
}

final class _ReceiptCapsuleGateway implements CapsuleFoundationGateway {
  const _ReceiptCapsuleGateway(this.receipt);

  final Map<String, dynamic> receipt;

  @override
  Future<Map<String, dynamic>> submit(Map<String, dynamic> intent) async {
    return receipt;
  }
}
