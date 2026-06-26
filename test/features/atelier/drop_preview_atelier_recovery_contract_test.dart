import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Drop Preview uses Luxe recovery and explicit Vex selection', () {
    final String source =
        File('lib/features/atelier/screens/drop_preview_screen.dart')
            .readAsStringSync();

    expect(source, contains('LuxeRecoveryCard'));
    expect(source, contains('The Feed missed that drop. Your design is safe.'));
    expect(source, contains('setVexOptIn(true)'));
    expect(source, contains('setVexOptIn(false)'));
    expect(source, contains('GoldPrimaryButton'));
    expect(source, isNot(contains('Drop failed. Please try again.')));
    expect(source, isNot(contains('FunctionException')));
    expect(source, isNot(contains('PostgrestException')));
    expect(source, isNot(contains('RPC')));
    expect(source, isNot(contains('null/500')));
  });

  test('DropDesignState error is player-safe', () {
    final String source =
        File('lib/features/atelier/providers/drop_design_provider.dart')
            .readAsStringSync();

    expect(source, contains('The Feed missed that drop. Your design is safe.'));
    expect(source, contains('void setVexOptIn(bool value)'));
    expect(source, contains('void toggleVexOptIn()'));
    expect(source, isNot(contains('Failed to drop:')));
  });

  test('Atelier recovery and projection remain player-safe', () {
    final String source =
        File('lib/features/atelier/screens/atelier_screen.dart')
            .readAsStringSync();

    expect(
      source,
      contains('The Atelier lost the thread. Your choices are still here.'),
    );
    expect(source, contains('_previewMaterialQualityHeuristic = 65.0'));
    expect(source, contains('_previewAestheticAlignmentHeuristic = 72.0'));
    expect(source, contains('Non-authoritative UI projection only.'));
    expect(
      source,
      contains('Final Hype is calculated by the server mint/drop path.'),
    );
    expect(source, contains('Projection only'));
    expect(source, isNot(contains('Mint failed. Please try again.')));
    expect(source, isNot(contains('Atelier session unavailable')));
  });
}
