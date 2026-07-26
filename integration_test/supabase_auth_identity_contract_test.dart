import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:the_styliste/app.dart';
import 'package:the_styliste/core/providers/auth_provider.dart';

const bool _runLiveIdentityContract =
    bool.fromEnvironment('RUN_LIVE_IDENTITY_CONTRACT');
const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String _supabasePublishableKey =
    String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (!_runLiveIdentityContract) return;
    if (_supabaseUrl.isEmpty || _supabasePublishableKey.isEmpty) {
      fail('Live identity contract requires staging Supabase configuration.');
    }
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabasePublishableKey,
    );
  });

  testWidgets(
    'Supabase Auth owns the player identity used by the game session',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: TheStyliste()));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final User? user = Supabase.instance.client.auth.currentUser;
      expect(user, isNotNull);

      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      await expectLater(
        container.read(supabaseAuthActionsProvider).requireEstablishedUserId(),
        completion(equals(user!.id)),
      );
    },
    skip: !_runLiveIdentityContract,
  );
}
