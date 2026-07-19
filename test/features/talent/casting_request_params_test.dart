import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:the_styliste/features/talent/models/talent.dart';
import 'package:the_styliste/features/talent/providers/casting_provider.dart';
import 'package:the_styliste/features/talent/screens/casting_room_screen.dart';

void main() {
  test('Casting notifier remains typed unavailable without an RPC call',
      () async {
    final CastingNotifier notifier = CastingNotifier();

    await notifier.executePull(isTenPull: true);

    expect(notifier.state.availability, CastingAvailability.unavailable);
    expect(notifier.state.isUnavailable, isTrue);
    expect(notifier.state.message, kCastingUnavailableMessage);

    final String providerSource = File(
      'lib/features/talent/providers/casting_provider.dart',
    ).readAsStringSync();
    expect(providerSource, isNot(contains('fnExecuteCastingPull')));
    expect(providerSource, isNot(contains('execute_casting_pull')));
    expect(providerSource, isNot(contains('castingPullRequestParams')));
    expect(providerSource, isNot(contains("'p_banner_id'")));
    expect(providerSource, isNot(contains("'p_is_ten_pull'")));
  });

  testWidgets(
    'Casting quarantine is accessible, navigable, and keeps owned Talent read-only',
    (WidgetTester tester) async {
      const RosterTalent ownedTalent = RosterTalent(
        talentId: 'talent-1',
        name: 'Avery Archive',
        tier: TalentTier.established,
        acquisitionSource: 'historical_casting',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            playerRosterProvider.overrideWith(
              (Ref ref) =>
                  Stream<List<RosterTalent>>.value(<RosterTalent>[ownedTalent]),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const CastingRoomScreen(),
                        ),
                      ),
                      child: const Text('OPEN CASTING'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('OPEN CASTING'));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(
          RegExp(RegExp.escape(kCastingUnavailableMessage)),
        ),
        findsOneWidget,
      );
      expect(find.text('CASTING TEMPORARILY UNAVAILABLE'), findsOneWidget);
      expect(find.text('Avery Archive'), findsOneWidget);
      expect(find.text('ESTABLISHED'), findsOneWidget);
      expect(find.text('SINGLE CAST'), findsNothing);
      expect(find.text('TEN CAST'), findsNothing);
      expect(find.text('CAST AGAIN'), findsNothing);
      expect(find.textContaining('LUXE SPENT'), findsNothing);
      expect(find.textContaining('HYPE'), findsNothing);

      await tester.tap(find.byTooltip('Return to the previous screen'));
      await tester.pumpAndSettle();

      expect(find.text('OPEN CASTING'), findsOneWidget);
      expect(find.text('CASTING TEMPORARILY UNAVAILABLE'), findsNothing);
    },
  );
}
