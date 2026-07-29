import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Ledger empty state CTA calls the authoritative open-first-store path',
      () {
    final String providerSource =
        File('lib/features/ledger/providers/ledger_provider.dart')
            .readAsStringSync();
    final String screenSource =
        File('lib/features/ledger/screens/ledger_screen.dart')
            .readAsStringSync();

    expect(providerSource, contains('SupabaseConstants.fnOpenFirstStore'));
    expect(providerSource, contains('FirstStoreNotifier'));
    expect(providerSource,
        isNot(contains('SupabaseConstants.fnProcessTransaction')));
    expect(screenSource, contains('Open first-store brief'));
    expect(screenSource, contains('firstStoreProvider'));
    expect(screenSource, contains('_showFirstStoreFlow'));
  });

  test('Ledger store list uses the server-owned store summary', () {
    final String providerSource =
        File('lib/features/ledger/providers/ledger_provider.dart')
            .readAsStringSync();

    expect(providerSource, contains('ledgerStoresStreamProvider'));
    expect(providerSource, contains(".schema('api')"));
    expect(providerSource, contains(".from('store_summary')"));
    expect(providerSource,
        contains('rows.map(Store.fromJson).toList(growable: false)'));
    expect(providerSource, isNot(contains('Store(')));
  });

  test('open-first-store routes through the Kingston request guard', () {
    final String edgeFunctionSource =
        File('supabase/functions/open-first-store/index.ts').readAsStringSync();

    expect(edgeFunctionSource, contains('handleKingstonRequest'));
    expect(edgeFunctionSource, contains('KINGSTON_ROUTES["open-first-store"]'));
  });
}
