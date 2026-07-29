import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:the_styliste/features/capsule/models/kingston_capsule.dart';
import 'package:the_styliste/features/capsule/providers/capsule_foundation_provider.dart';

void main() {
  test(
    'capsule intents contain bounded choices but no client authority',
    () async {
      final _CapsuleGateway gateway = _CapsuleGateway();
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          capsuleFoundationGatewayProvider.overrideWithValue(gateway),
        ],
      );
      addTearDown(container.dispose);

      final CapsuleFoundationNotifier notifier = container.read(
        capsuleFoundationProvider.notifier,
      );
      await notifier.restore();
      expect(
        container.read(capsuleFoundationProvider).phase,
        CapsuleFoundationPhase.empty,
      );

      await notifier.saveBrief(
        const CollectionBrief(
          title: 'Port Royal After Dark',
          narrative:
              'A precise Kingston capsule that balances ceremony with ease.',
          targetAudience: 'kingston_creatives',
          houseCode: 'tailored_radiance',
          paletteDirection: 'kingston_blue_ivory',
          materialDirection: 'linen_blend',
        ),
      );

      final Map<String, dynamic> briefIntent = gateway.calls.last;
      expect(briefIntent['action'], 'save_brief');
      expect(briefIntent['player_id'], isNull);
      expect(briefIntent['house_id'], isNull);
      expect(briefIntent['readiness'], isNull);
      expect(briefIntent['score'], isNull);
      expect(briefIntent['idempotency_key'], isNotEmpty);
      expect(
        container.read(capsuleFoundationProvider).capsule?.stage,
        KingstonCapsuleStage.briefConfirmed,
      );
    },
  );

  test('offline retry preserves the exact idempotency key', () async {
    final _CapsuleGateway gateway = _CapsuleGateway(failFirstRestore: true);
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        capsuleFoundationGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);

    final CapsuleFoundationNotifier notifier = container.read(
      capsuleFoundationProvider.notifier,
    );
    await notifier.restore();
    expect(
      container.read(capsuleFoundationProvider).phase,
      CapsuleFoundationPhase.offline,
    );
    await notifier.retry();

    expect(gateway.calls, hasLength(2));
    expect(
      gateway.calls.first['idempotency_key'],
      gateway.calls.last['idempotency_key'],
    );
    expect(
      container.read(capsuleFoundationProvider).phase,
      CapsuleFoundationPhase.empty,
    );
  });
}

final class _CapsuleGateway implements CapsuleFoundationGateway {
  _CapsuleGateway({this.failFirstRestore = false});

  final bool failFirstRestore;
  final List<Map<String, dynamic>> calls = <Map<String, dynamic>>[];

  @override
  Future<Map<String, dynamic>> submit(Map<String, dynamic> intent) async {
    calls.add(Map<String, dynamic>.from(intent));
    if (failFirstRestore && calls.length == 1) {
      throw const SocketException('offline');
    }
    final String action = intent['action'] as String;
    return <String, dynamic>{
      'status': action == 'initialize' ? 'initialized' : 'brief_confirmed',
      'capsule': <String, dynamic>{
        'stage': action == 'save_brief' ? 'brief_confirmed' : 'brief_draft',
        'founder_specialization': 'artisan',
        'brief': const <String, dynamic>{},
        'looks': const <Object?>[
          <String, dynamic>{'role': 'hero_piece', 'grammar': null},
          <String, dynamic>{'role': 'commercial_anchor', 'grammar': null},
          <String, dynamic>{'role': 'experimental_piece', 'grammar': null},
        ],
        'readiness': const <String, dynamic>{},
        'sampling': const <String, dynamic>{'status': 'not_reached'},
      },
    };
  }
}
