// Phase 0 scaffold smoke test — The Styliste
// VERIFICATION_PROTOCOL — confirm widget tree compiles and mounts without error
// Full integration tests are added in Phase 1 once Firebase/Supabase are wired.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:the_styliste/app.dart';

void main() {
  testWidgets('Phase 0 scaffold smoke test — TheStyliste widget mounts', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TheStyliste(),
      ),
    );
    // Verify the widget tree mounts without throwing
    expect(tester.takeException(), isNull);
  });
}
