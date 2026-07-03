import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Ledger empty state CTA calls server open_first_store path', () {
    final String providerSource =
        File('lib/features/ledger/providers/ledger_provider.dart')
            .readAsStringSync();
    final String screenSource =
        File('lib/features/ledger/screens/ledger_screen.dart')
            .readAsStringSync();

    expect(providerSource, contains("'action': 'open_first_store'"));
    expect(providerSource, contains('SupabaseConstants.fnProcessTransaction'));
    expect(providerSource, contains('OpenFirstStoreNotifier'));
    expect(screenSource, contains('OPEN FIRST STORE'));
    expect(screenSource, contains('openFirstStoreProvider'));
    expect(screenSource, contains('.open();'));
  });

  test('Ledger store list remains Realtime source of truth', () {
    final String providerSource =
        File('lib/features/ledger/providers/ledger_provider.dart')
            .readAsStringSync();

    expect(providerSource, contains('ledgerStoresStreamProvider'));
    expect(providerSource, contains(".from(SupabaseConstants.tableStores)"));
    expect(providerSource, contains(".stream(primaryKey: <String>['id'])"));
    expect(providerSource, contains('rows.map(Store.fromJson).toList()'));
    expect(providerSource, isNot(contains('Store(')));
  });

  test('process-transaction routes first store through authenticated user id',
      () {
    final String edgeFunctionSource =
        File('supabase/functions/process-transaction/index.ts')
            .readAsStringSync();

    expect(edgeFunctionSource, contains('action !== "upgrade_store"'));
    expect(edgeFunctionSource, contains('action !== "open_first_store"'));
    expect(edgeFunctionSource, contains('"edge_open_first_store_atomic"'));
    expect(edgeFunctionSource, contains('{ p_player_id: user.id }'));
    expect(edgeFunctionSource, isNot(contains('body.player_id')));
  });
}
