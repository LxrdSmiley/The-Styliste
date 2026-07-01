import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Feed first objective marker is deferred outside initState', () {
    final String source =
        File('lib/features/feed/screens/feed_screen.dart').readAsStringSync();
    final String initStateBody = _methodBody(source, 'void initState()');

    expect(initStateBody, contains('addPostFrameCallback'));
    expect(initStateBody, contains('markFeedVisited()'));
    expect(
      initStateBody,
      isNot(contains(
        'super.initState();\n'
        '    ref.read(firstObjectiveActionsProvider.notifier).markFeedVisited();',
      )),
    );
  });

  test('HQ first objective effects are post-frame and idempotent', () {
    final String source =
        File('lib/features/hq/screens/hq_screen.dart').readAsStringSync();
    final String scheduleBody = _methodBody(source, 'void _scheduleHqEffects');

    expect(source, contains('String? _lastScheduledHqEffectsPlayerId;'));
    expect(
      scheduleBody,
      contains('if (_lastScheduledHqEffectsPlayerId == player.id) return;'),
    );
    expect(
      scheduleBody,
      contains('_lastScheduledHqEffectsPlayerId = player.id;'),
    );
    expect(scheduleBody, contains('addPostFrameCallback'));
    expect(scheduleBody, contains('markReturnedToHq()'));
  });

  test('Ledger first objective marker is deferred outside initState', () {
    final String source =
        File('lib/features/ledger/screens/ledger_screen.dart')
            .readAsStringSync();
    final String initStateBody = _methodBody(source, 'void initState()');

    expect(initStateBody, contains('addPostFrameCallback'));
    expect(initStateBody, contains('markLedgerOpened()'));
  });
}

String _methodBody(String source, String signature) {
  final int signatureIndex = source.indexOf(signature);
  expect(signatureIndex, isNot(-1), reason: '$signature not found');

  final int bodyStart = source.indexOf('{', signatureIndex);
  expect(bodyStart, isNot(-1), reason: '$signature has no body');

  int depth = 0;
  for (int index = bodyStart; index < source.length; index += 1) {
    final String char = source[index];
    if (char == '{') depth += 1;
    if (char == '}') {
      depth -= 1;
      if (depth == 0) {
        return source.substring(bodyStart + 1, index);
      }
    }
  }

  fail('$signature body was not closed');
}
