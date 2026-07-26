import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:the_styliste/core/providers/auth_provider.dart';
import 'package:the_styliste/core/providers/onboarding_provider.dart';
import 'package:the_styliste/domain/models/player.dart';
import 'package:the_styliste/features/onboarding/providers/sovereign_genesis_provider.dart';
import 'package:the_styliste/features/onboarding/screens/ascension_confirmation_screen.dart';

void main() {
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets(
      'unresolved Supabase session prevents Genesis and exposes recovery', (
    WidgetTester tester,
  ) async {
    final Completer<String> sessionPending = Completer<String>();
    final _FakeSupabaseAuthActions actions = _FakeSupabaseAuthActions(
      require: () => sessionPending.future,
    );
    final _FakeGenesisGateway genesis = _FakeGenesisGateway();

    await _pumpScreen(tester, actions: actions, genesis: genesis);
    await tester.tap(find.byKey(const Key('seal-the-standard')));
    await tester.pump();

    expect(genesis.calls, 0);
    expect(find.byKey(const Key('success-whiteout')), findsNothing);

    sessionPending.completeError(StateError('credential-token-secret'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.textContaining('credential-token-secret'), findsNothing);
    expect(find.textContaining('secure game session'), findsOneWidget);
    expect(find.byKey(const Key('retry-secure-sign-in')), findsOneWidget);
    expect(find.byKey(const Key('sign-out-and-restart')), findsOneWidget);
  });

  testWidgets('retry is serialized and a successful retry invokes Genesis once',
      (
    WidgetTester tester,
  ) async {
    final Completer<String> retryPending = Completer<String>();
    final _FakeSupabaseAuthActions actions = _FakeSupabaseAuthActions(
      require: () async => throw StateError('session-unavailable'),
      retry: () => retryPending.future,
    );
    final _FakeGenesisGateway genesis = _FakeGenesisGateway(
      result: const SovereignGenesisResult(success: true),
    );

    await _pumpScreen(tester, actions: actions, genesis: genesis);
    await tester.tap(find.byKey(const Key('seal-the-standard')));
    await tester.pump();
    expect(find.byKey(const Key('retry-secure-sign-in')), findsOneWidget);

    await tester.tap(find.byKey(const Key('retry-secure-sign-in')));
    await tester.pump();

    expect(actions.retryCalls, 1);
    expect(genesis.calls, 0);
    expect(find.byKey(const Key('retry-secure-sign-in')), findsNothing);

    retryPending.complete('established-supabase-uuid');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(actions.retryCalls, 1);
    expect(genesis.calls, 1);
    expect(genesis.requests.single.userId, 'established-supabase-uuid');
  });

  testWidgets('failed retry remains recoverable', (WidgetTester tester) async {
    final _FakeSupabaseAuthActions actions = _FakeSupabaseAuthActions(
      require: () async => throw StateError('session-unavailable'),
      retry: () async => throw StateError('retry-failed'),
    );

    await _pumpScreen(
      tester,
      actions: actions,
      genesis: _FakeGenesisGateway(),
    );
    await tester.tap(find.byKey(const Key('seal-the-standard')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('retry-secure-sign-in')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(const Key('retry-secure-sign-in')), findsOneWidget);
    expect(find.byKey(const Key('sign-out-and-restart')), findsOneWidget);
  });

  testWidgets('success effects begin only after confirmed Genesis success', (
    WidgetTester tester,
  ) async {
    final Completer<SovereignGenesisResult> genesisPending =
        Completer<SovereignGenesisResult>();
    final _FakeSupabaseAuthActions actions = _FakeSupabaseAuthActions(
      require: () async => 'established-supabase-uuid',
    );
    final _FakeGenesisGateway genesis = _FakeGenesisGateway(
      pending: genesisPending,
    );

    await _pumpScreen(tester, actions: actions, genesis: genesis);
    await tester.tap(find.byKey(const Key('seal-the-standard')));
    await tester.pump();

    expect(genesis.calls, 1);
    expect(find.byKey(const Key('success-whiteout')), findsNothing);

    genesisPending.complete(const SovereignGenesisResult(success: true));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.byKey(const Key('success-whiteout')), findsOneWidget);
  });

  testWidgets('sign-out uses the auth action and restarts at the gate', (
    WidgetTester tester,
  ) async {
    final _FakeSupabaseAuthActions actions = _FakeSupabaseAuthActions(
      require: () async => throw StateError('session-unavailable'),
    );

    final ProviderContainer container = _configuredContainer(
      actions: actions,
      genesis: _FakeGenesisGateway(),
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/confirm',
            routes: <RouteBase>[
              GoRoute(
                path: '/confirm',
                builder: (_, __) => const AscensionConfirmationScreen(),
              ),
              GoRoute(
                path: '/onboarding/aurelian-gate',
                builder: (_, __) => const Text('AURELIAN GATE'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('seal-the-standard')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('sign-out-and-restart')));
    await tester.pumpAndSettle();

    expect(actions.signOutCalls, 1);
    expect(find.text('AURELIAN GATE'), findsOneWidget);
  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required _FakeSupabaseAuthActions actions,
  required _FakeGenesisGateway genesis,
}) async {
  final ProviderContainer container = _configuredContainer(
    actions: actions,
    genesis: genesis,
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: AscensionConfirmationScreen(),
      ),
    ),
  );
}

ProviderContainer _configuredContainer({
  required _FakeSupabaseAuthActions actions,
  required _FakeGenesisGateway genesis,
}) {
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      supabaseAuthActionsProvider.overrideWithValue(actions),
      sovereignGenesisGatewayProvider.overrideWithValue(genesis),
    ],
  );
  final OnboardingNotifier notifier =
      container.read(onboardingProvider.notifier);
  notifier
    ..setBrandName('Aurelian')
    ..setPath(CareerPath.designer)
    ..setCity(HqCity.paris)
    ..setTier(MarketTier.highLuxury);
  return container;
}

final class _FakeSupabaseAuthActions implements SupabaseAuthActions {
  _FakeSupabaseAuthActions({this.require, this.retry});

  final Future<String> Function()? require;
  final Future<String> Function()? retry;
  int retryCalls = 0;
  int signOutCalls = 0;

  @override
  Future<String> requireEstablishedUserId() =>
      require?.call() ?? Future<String>.value('established-supabase-uuid');

  @override
  Future<String> retrySession() {
    retryCalls++;
    return retry?.call() ?? Future<String>.value('established-supabase-uuid');
  }

  @override
  Future<void> signOutAndRestart() async {
    signOutCalls++;
  }
}

final class _FakeGenesisGateway implements SovereignGenesisGateway {
  _FakeGenesisGateway({this.result, this.pending});

  final SovereignGenesisResult? result;
  final Completer<SovereignGenesisResult>? pending;
  final List<SovereignGenesisRequest> requests = <SovereignGenesisRequest>[];

  int get calls => requests.length;

  @override
  Future<SovereignGenesisResult> execute(SovereignGenesisRequest request) {
    requests.add(request);
    return pending?.future ??
        Future<SovereignGenesisResult>.value(
          result ?? const SovereignGenesisResult(success: false),
        );
  }
}
