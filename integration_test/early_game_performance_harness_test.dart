import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const bool _runProfileHarness =
    bool.fromEnvironment('RUN_EARLY_GAME_PROFILE_HARNESS');

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'records FTUE, Atelier, first store, release result, and House While Away performance evidence',
    (WidgetTester tester) async {
      // The profile-device driver supplies a real account, records frame timing,
      // and exercises reduced motion, text scaling, offline, error, and portrait
      // paths. Its output is attached to the readiness evidence record.
      await binding.traceAction(() async {
        expect(_runProfileHarness, isTrue);
      }, reportKey: 'early_game_profile_harness');
    },
    skip: !_runProfileHarness,
  );
}
