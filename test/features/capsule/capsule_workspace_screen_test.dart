import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:the_styliste/features/capsule/providers/capsule_foundation_provider.dart';
import 'package:the_styliste/features/capsule/screens/capsule_workspace_screen.dart';

void main() {
  testWidgets(
      'capsule workspace presents the bounded brief before any sampling path', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        capsuleFoundationGatewayProvider.overrideWithValue(
          const _Gateway(stage: 'brief_draft'),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: CapsuleWorkspaceScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('COLLECTION BRIEF'), findsAtLeastNWidgets(1));
    expect(find.text('Hero Piece'), findsOneWidget);
    expect(find.text('Commercial Anchor'), findsOneWidget);
    expect(find.text('Experimental Piece'), findsOneWidget);
    expect(find.textContaining('Sampling is deliberately unavailable'),
        findsNothing);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('all forward-only capsule stages expose one next action', (
    WidgetTester tester,
  ) async {
    const List<(String, String)> stages = <(String, String)>[
      ('brief_confirmed', 'Confirm Hero Piece'),
      ('hero_piece_complete', 'Confirm Commercial Anchor'),
      ('commercial_anchor_complete', 'Confirm Experimental Piece'),
      ('experimental_piece_complete', 'Confirm capsule readiness'),
      ('sampling_unavailable', 'Sampling unavailable in this build'),
    ];

    for (final (String stage, String action) in stages) {
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          capsuleFoundationGatewayProvider.overrideWithValue(
            _Gateway(stage: stage),
          ),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: CapsuleWorkspaceScreen()),
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text(action.toUpperCase()),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(action.toUpperCase()), findsOneWidget, reason: stage);
      expect(find.text('Hero Piece'), findsWidgets);
      expect(find.text('Commercial Anchor'), findsWidgets);
      expect(find.text('Experimental Piece'), findsWidgets);
      expect(tester.takeException(), isNull, reason: stage);

      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    }
  });

  testWidgets('capsule workspace survives 320px portrait at large text', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        capsuleFoundationGatewayProvider.overrideWithValue(
          const _Gateway(stage: 'brief_draft'),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(320, 700),
              textScaler: TextScaler.linear(2),
            ),
            child: CapsuleWorkspaceScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('COLLECTION BRIEF'), findsAtLeastNWidgets(1));
    expect(tester.takeException(), isNull);
  });
}

final class _Gateway implements CapsuleFoundationGateway {
  const _Gateway({required this.stage});

  final String stage;

  @override
  Future<Map<String, dynamic>> submit(Map<String, dynamic> intent) async {
    final int completedLooks = switch (stage) {
      'hero_piece_complete' => 1,
      'commercial_anchor_complete' => 2,
      'experimental_piece_complete' || 'sampling_unavailable' => 3,
      _ => 0,
    };
    return <String, dynamic>{
      'status': stage == 'brief_draft' ? 'initialized' : 'confirmed',
      'capsule': <String, dynamic>{
        'stage': stage,
        'founder_specialization': 'artisan',
        'brief': stage == 'brief_draft'
            ? const <String, dynamic>{}
            : const <String, dynamic>{'title': 'Kingston Study'},
        'looks': <Object?>[
          <String, dynamic>{
            'role': 'hero_piece',
            'grammar': completedLooks >= 1
                ? const <String, dynamic>{'ok': true}
                : null,
          },
          <String, dynamic>{
            'role': 'commercial_anchor',
            'grammar': completedLooks >= 2
                ? const <String, dynamic>{'ok': true}
                : null,
          },
          <String, dynamic>{
            'role': 'experimental_piece',
            'grammar': completedLooks >= 3
                ? const <String, dynamic>{'ok': true}
                : null,
          },
        ],
        'readiness': stage == 'sampling_unavailable'
            ? const <String, dynamic>{
                'causes': <String>['Brief confirmed', 'Three roles complete'],
              }
            : const <String, dynamic>{},
        'sampling': <String, dynamic>{
          'status':
              stage == 'sampling_unavailable' ? 'unavailable' : 'not_reached',
        },
      },
    };
  }
}
