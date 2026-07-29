import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_styliste/app.dart';
import 'package:the_styliste/core/router/feature_unavailable_screen.dart';
import 'package:the_styliste/domain/models/brand.dart';
import 'package:the_styliste/domain/models/player.dart';
import 'package:the_styliste/domain/models/store.dart';
import 'package:the_styliste/features/hq/providers/hq_provider.dart';
import 'package:the_styliste/features/ledger/providers/ledger_provider.dart';
import 'package:the_styliste/features/ledger/screens/ledger_screen.dart';
import 'package:the_styliste/features/legal/legal_documents.dart';
import 'package:the_styliste/features/legal/screens/legal_document_screen.dart';
import 'package:the_styliste/features/onboarding/screens/aurelian_gate_screen.dart';
import 'package:the_styliste/features/onboarding/screens/origin_script_screen.dart';
import 'package:the_styliste/features/onboarding/screens/sovereign_registry_screen.dart';
import 'package:the_styliste/features/profile/screens/profile_screen.dart';
import 'package:the_styliste/features/settings/screens/settings_screen.dart';

const Size _smallPortrait = Size(320, 700);
const MediaQueryData _largeTextMedia = MediaQueryData(
  size: _smallPortrait,
  textScaler: TextScaler.linear(2),
  disableAnimations: true,
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'age_gate_passed': true,
      'reduced_motion_enabled': true,
    });
  });

  testWidgets('session and unavailable boundaries survive large text', (
    WidgetTester tester,
  ) async {
    await _setSmallPortrait(tester);

    for (final Widget screen in <Widget>[
      const AurelianSessionGate(),
      const AurelianSessionGate(
        errorMessage:
            'Authentication is unavailable. Retry when you are ready.',
      ),
      const FeatureUnavailableScreen(),
    ]) {
      await tester.pumpWidget(_largeTextHarness(screen));
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('opening and Luxe introduction survive large text', (
    WidgetTester tester,
  ) async {
    await _setSmallPortrait(tester);

    await tester.pumpWidget(_largeTextHarness(const AurelianGateScreen()));
    await tester.pump(const Duration(milliseconds: 360));
    await tester.pump();
    expect(find.text('ENTER THE SANCTUARY'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(_largeTextHarness(const OriginScriptScreen()));
    await tester.pump();
    expect(find.text('NAME YOUR KINGSTON HOUSE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('age gate and House naming survive large text', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await _setSmallPortrait(tester);

    await tester.pumpWidget(_largeTextHarness(const AurelianGateScreen()));
    await tester.pump(const Duration(milliseconds: 360));
    await tester.pump();
    expect(find.text('Before the Sanctuary opens'), findsOneWidget);
    expect(find.text('I AM 13 OR OLDER'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('I AM UNDER 13'));
    await tester.pumpAndSettle();
    expect(find.text('The Sanctuary cannot open'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      ProviderScope(
        child: _largeTextHarness(const SovereignRegistryScreen()),
      ),
    );
    await tester.pump();
    expect(find.text('CONTINUE TO THE FOUNDER TRIAL'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('House, settings, and legal surfaces survive large text', (
    WidgetTester tester,
  ) async {
    await _setSmallPortrait(tester);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          hqPlayerStreamProvider.overrideWith(
            (Ref ref) => Stream<Player>.value(_player),
          ),
        ],
        child: _largeTextHarness(const ProfileScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('House Meridian'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(_largeTextHarness(const SettingsScreen()));
    await tester.pump();
    await tester.pump();
    expect(find.text('Expert Mode'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      _largeTextHarness(
        LegalDocumentScreen(document: LegalDocuments.all.first),
      ),
    );
    await tester.pump();
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Empire and first-store dialog survive large text', (
    WidgetTester tester,
  ) async {
    await _setSmallPortrait(tester);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          ledgerStoresStreamProvider.overrideWith(
            (Ref ref) => Stream<List<Store>>.value(const <Store>[]),
          ),
          hqBrandStreamProvider.overrideWith(
            (Ref ref) => Stream<Brand>.value(_brand),
          ),
        ],
        child: _largeTextHarness(const LedgerScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final Finder openButton = find.text('OPEN FIRST-STORE BRIEF');
    expect(openButton, findsOneWidget);
    await tester.ensureVisible(openButton);
    await tester.tap(openButton);
    await tester.pumpAndSettle();

    expect(find.text('First Kingston store'), findsOneWidget);
    expect(find.text('SUBMIT STORE INTENT'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _setSmallPortrait(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(_smallPortrait);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _largeTextHarness(Widget screen) {
  return MaterialApp(
    home: MediaQuery(
      data: _largeTextMedia,
      child: screen,
    ),
  );
}

const Player _player = Player(
  id: 'player-1',
  brandName: 'House Meridian',
  path: CareerPath.designer,
  hqCity: HqCity.kingston,
  onboardingComplete: true,
);

const Brand _brand = Brand(
  playerId: 'player-1',
  heat: 12,
  hypeScore: 40,
  followers: 120,
  totalRevenue: 2500,
);
