import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_styliste/core/providers/auth_provider.dart';
import 'package:the_styliste/features/onboarding/providers/founder_trial_provider.dart';
import 'package:the_styliste/features/onboarding/screens/founder_trial_screen.dart';

void main() {
  for (final String specialization in <String>['artisan', 'architect']) {
    testWidgets(
      'Founder Trial confirms the $specialization lens with an equal ceiling',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final _FounderTrialGateway gateway = _FounderTrialGateway();

        await tester.pumpWidget(
          ProviderScope(
            overrides: <Override>[
              supabaseAuthActionsProvider.overrideWithValue(
                const _AuthActions(),
              ),
              founderTrialGatewayProvider.overrideWithValue(gateway),
            ],
            child: const MaterialApp(home: FounderTrialScreen()),
          ),
        );

        await tester.enterText(find.byType(TextField), 'House Meridian');
        await _tap(tester, 'BEGIN THE FOUNDER TRIAL');
        expect(find.text('Author the garment'), findsOneWidget);

        await _tap(tester, 'CHOOSE DRAPED BODICE');
        expect(find.text('Position the same garment'), findsOneWidget);

        await _tap(tester, 'CHOOSE LIMITED COLLECTOR RUN');
        expect(find.text('Two decisions, one garment'), findsOneWidget);

        await _tap(tester, 'MAKE ONE RESPONSE');
        expect(find.text('Choose the next decision'), findsOneWidget);

        await _tap(tester, 'CHOOSE REFINE THE SILHOUETTE');
        expect(find.text('Choose the lens you lead with'), findsOneWidget);
        expect(find.text('EQUAL GAMEPLAY CEILING'), findsOneWidget);

        await _tap(tester, 'LEAD AS ${specialization.toUpperCase()}');
        expect(
          find.text(
            '${specialization == 'architect' ? 'Architect' : 'Artisan'} lens confirmed',
          ),
          findsOneWidget,
        );
        expect(
            find.textContaining('No currency, Hype, reward'), findsOneWidget);
        expect(find.text('OPEN THE KINGSTON CAPSULE'), findsOneWidget);
        expect(tester.takeException(), isNull);

        for (final Map<String, dynamic> intent in gateway.intents) {
          expect(intent, isNot(containsPair('player_id', anything)));
          expect(intent, isNot(containsPair('house_id', anything)));
          expect(intent, isNot(containsPair('score', anything)));
          expect(intent, isNot(containsPair('reward', anything)));
          expect(intent['idempotency_key'], isA<String>());
        }
        expect(gateway.intents.last['specialization'], specialization);
      },
    );
  }

  testWidgets('resumed Founder Trial renders a restored receipt', (
    WidgetTester tester,
  ) async {
    final _FounderTrialGateway gateway = _FounderTrialGateway(
      resumeCompleted: true,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          supabaseAuthActionsProvider.overrideWithValue(const _AuthActions()),
          founderTrialGatewayProvider.overrideWithValue(gateway),
        ],
        child: const MaterialApp(home: FounderTrialScreen()),
      ),
    );

    await tester.enterText(find.byType(TextField), 'House Meridian');
    await _tap(tester, 'BEGIN THE FOUNDER TRIAL');

    expect(find.text('RESTORED FROM YOUR HOUSE RECORD'), findsOneWidget);
    expect(find.text('Architect lens confirmed'), findsOneWidget);
    expect(find.text('Founder Trial completion'), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _tap(WidgetTester tester, String label) async {
  final Finder target = find.text(label);
  await tester.scrollUntilVisible(
    target,
    360,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(target);
  await tester.pump();
  await tester.pump();
}

final class _FounderTrialGateway implements FounderTrialGateway {
  _FounderTrialGateway({this.resumeCompleted = false});

  final bool resumeCompleted;
  final List<Map<String, dynamic>> intents = <Map<String, dynamic>>[];

  @override
  Future<Map<String, dynamic>> submit(Map<String, dynamic> intent) async {
    intents.add(Map<String, dynamic>.from(intent));
    if (resumeCompleted) {
      return <String, dynamic>{
        'status': 'resumed',
        'stage': 'completed',
        'specialization': 'architect',
        'idempotency_key': intent['idempotency_key'],
      };
    }

    final String stage = switch (intent['next_stage']) {
      'complete_artisan_sample' => 'artisan_sample',
      'complete_architect_sample' => 'architect_sample',
      'reveal_shared_result' => 'result_visible',
      'choose_revision_or_business_response' => 'revision_or_business_response',
      'select_founder_path' => 'completed',
      _ => 'shared_starter_garment',
    };
    return <String, dynamic>{
      'status': 'confirmed',
      'stage': stage,
      'specialization': intent['specialization'],
      'idempotency_key': intent['idempotency_key'],
    };
  }
}

final class _AuthActions implements SupabaseAuthActions {
  const _AuthActions();

  @override
  Future<String> requireEstablishedUserId() async => 'player-1';

  @override
  Future<String> retrySession() async => 'player-1';

  @override
  Future<void> signOutAndRestart() async {}
}
