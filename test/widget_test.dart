import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

import 'package:the_styliste/app.dart';
import 'package:the_styliste/core/providers/auth_provider.dart';
import 'package:the_styliste/core/providers/onboarding_provider.dart';
import 'package:the_styliste/domain/models/player.dart';

void main() {
  testWidgets('auth gate renders while Supabase session bootstrap is pending', (
    WidgetTester tester,
  ) async {
    final Completer<User> pendingSession = Completer<User>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          supabaseSessionBootstrapProvider.overrideWith(
            (Ref ref) => pendingSession.future,
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
