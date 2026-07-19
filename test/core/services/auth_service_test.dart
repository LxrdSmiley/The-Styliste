import 'package:flutter_test/flutter_test.dart';

import 'package:the_styliste/core/services/auth_service.dart';

void main() {
  test('legacy restoration returns a deterministic unavailable result',
      () async {
    final PlatformRestorationResult result =
        await AuthService.instance.getPlatformRestorationStatus();

    expect(result.status, PlatformRestorationStatus.unavailable);
    expect(await AuthService.instance.signInSilently(), isNull);
    expect(PlatformRestorationResult.safeMessage, isNot(contains('token')));
    expect(
      PlatformRestorationResult.safeMessage,
      isNot(contains('credential')),
    );
  });
}
