import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:the_styliste/features/onboarding/providers/founder_trial_provider.dart';

void main() {
  test('Founder Trial submits bounded server-owned intents', () async {
    final _RecordingFounderTrialGateway gateway = _RecordingFounderTrialGateway(
      responses: <Map<String, dynamic>>[
        <String, dynamic>{
          'stage': 'shared_starter_garment',
          'next_action': 'complete_artisan_sample',
        },
        <String, dynamic>{
          'stage': 'artisan_sample',
          'next_action': 'complete_architect_sample',
        },
      ],
    );
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        founderTrialGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);

    final FounderTrialNotifier notifier =
        container.read(founderTrialProvider.notifier);
    await notifier.initialize(brandName: 'Luxe Kingston');
    await notifier.chooseArtisanSample('draped_bodice');

    expect(
      gateway.intents,
      <Map<String, dynamic>>[
        <String, dynamic>{
          'action': 'initialize',
          'brand_name': 'Luxe Kingston',
          'idempotency_key': isA<String>(),
        },
        <String, dynamic>{
          'action': 'advance',
          'next_stage': 'complete_artisan_sample',
          'artisan_choice': 'draped_bodice',
          'idempotency_key': isA<String>(),
        },
      ],
    );
    expect(gateway.intents.expand((Map<String, dynamic> value) => value.keys),
        isNot(contains('player_id')));
    expect(container.read(founderTrialProvider).stage,
        FounderTrialStage.artisanSample);
  });

  test('Founder Trial retries a failed step with the same idempotency key',
      () async {
    final _RecordingFounderTrialGateway gateway = _RecordingFounderTrialGateway(
      failuresBeforeSuccess: 1,
      responses: <Map<String, dynamic>>[
        <String, dynamic>{
          'stage': 'shared_starter_garment',
          'next_action': 'complete_artisan_sample',
        },
      ],
    );
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        founderTrialGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);

    final FounderTrialNotifier notifier =
        container.read(founderTrialProvider.notifier);
    await notifier.initialize(brandName: 'Luxe Kingston');
    await notifier.initialize(brandName: 'Luxe Kingston');

    expect(gateway.intents, hasLength(2));
    expect(
      gateway.intents.first['idempotency_key'],
      gateway.intents.last['idempotency_key'],
    );
    expect(container.read(founderTrialProvider).error, isNull);
    expect(
      container.read(founderTrialProvider).stage,
      FounderTrialStage.sharedStarterGarment,
    );
  });
}

final class _RecordingFounderTrialGateway implements FounderTrialGateway {
  _RecordingFounderTrialGateway({
    required this.responses,
    this.failuresBeforeSuccess = 0,
  });

  final List<Map<String, dynamic>> responses;
  final int failuresBeforeSuccess;
  final List<Map<String, dynamic>> intents = <Map<String, dynamic>>[];
  int _calls = 0;

  @override
  Future<Map<String, dynamic>> submit(Map<String, dynamic> intent) async {
    intents.add(Map<String, dynamic>.from(intent));
    if (_calls++ < failuresBeforeSuccess) {
      throw StateError('network interrupted');
    }
    return responses.removeAt(0);
  }
}
