import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Drop Preview prevents duplicate drop submits', () {
    final String screenSource =
        File('lib/features/atelier/screens/drop_preview_screen.dart')
            .readAsStringSync();
    final String providerSource =
        File('lib/features/atelier/providers/drop_design_provider.dart')
            .readAsStringSync();

    expect(screenSource, contains('isLoading: dropState.isDropping'));
    expect(
      screenSource,
      contains('onPressed: dropState.isDropping ? null : _onDropToFeed'),
    );
    expect(
      providerSource,
      contains('if (state.design == null || state.isDropping) return null;'),
    );
    expect(providerSource, contains('state.copyWith(isDropping: true'));
    expect(providerSource, contains('isDropping: false'));
  });
}
