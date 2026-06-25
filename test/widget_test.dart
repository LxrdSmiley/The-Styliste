import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:the_styliste/app.dart';
import 'package:the_styliste/core/providers/auth_provider.dart';
import 'package:the_styliste/core/providers/onboarding_provider.dart';
import 'package:the_styliste/domain/models/player.dart';

void main() {
  testWidgets('auth gate renders while Firebase sign-in is pending', (
    WidgetTester tester,
  ) async {
    final Completer<User> pendingSignIn = Completer<User>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          firebaseAnonSignInProvider.overrideWith(
            (Ref ref) => pendingSignIn.future,
          ),
          supabaseBridgeProvider.overrideWith(
            (Ref ref) => const Stream<void>.empty(),
          ),
        ],
        child: const TheStyliste(),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  test('onboarding provider requires a complete founding profile', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final OnboardingNotifier notifier =
        container.read(onboardingProvider.notifier);

    expect(container.read(onboardingProvider).isReadyToCommit, isFalse);

    notifier
      ..setBrandName('Aurelian')
      ..setPath(CareerPath.designer)
      ..setCity(HqCity.paris)
      ..setTier(MarketTier.highLuxury);

    expect(container.read(onboardingProvider).isReadyToCommit, isTrue);
  });

  test('avatar choices are persisted in onboarding state', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final OnboardingNotifier notifier =
        container.read(onboardingProvider.notifier);

    notifier
      ..updateAvatarFace(2)
      ..updateAvatarBody(1)
      ..updateAvatarHair(3)
      ..updateAvatarFit(4);

    final AvatarConfig? avatarConfig =
        container.read(onboardingProvider).avatarConfig;

    expect(avatarConfig?.toJson(), <String, int>{
      'face': 2,
      'body': 1,
      'hair': 3,
      'fit': 4,
    });
  });
}
