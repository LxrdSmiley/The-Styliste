import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:the_styliste/features/mini_games/widgets/mini_game_rewards_unavailable.dart';

void main() {
  testWidgets('reward quarantine explains the unavailable state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: MiniGameRewardsUnavailableScreen()),
    );

    expect(find.text('REWARDS PAUSED'), findsOneWidget);
    expect(
      find.textContaining('No currency, progression, or inventory'),
      findsOneWidget,
    );
    expect(find.text('RETURN'), findsOneWidget);
  });
}
