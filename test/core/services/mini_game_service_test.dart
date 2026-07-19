import 'package:flutter_test/flutter_test.dart';

import 'package:the_styliste/core/services/mini_game_service.dart';

void main() {
  test('mini-game reward calls fail closed without a client proof request',
      () async {
    expect(MiniGameService.rewardsAreAvailable, isFalse);

    await expectLater(
      MiniGameService.start('price_war'),
      throwsA(isA<MiniGameRewardsUnavailableException>()),
    );
    await expectLater(
      MiniGameService.claim('attempt-id', <String, dynamic>{'outcome': 'win'}),
      throwsA(isA<MiniGameRewardsUnavailableException>()),
    );
  });
}
