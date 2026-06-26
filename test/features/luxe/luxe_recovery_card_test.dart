import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_styliste/features/luxe/widgets/luxe_recovery_card.dart';

void main() {
  testWidgets('LuxeRecoveryCard renders title message and actions', (
    WidgetTester tester,
  ) async {
    int primaryTaps = 0;
    int secondaryTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LuxeRecoveryCard(
            title: 'Luxe',
            message: 'The Feed missed that drop. Your design is safe.',
            primaryLabel: 'Try Again',
            onPrimary: () => primaryTaps++,
            secondaryLabel: 'Return to Atelier',
            onSecondary: () => secondaryTaps++,
          ),
        ),
      ),
    );

    expect(find.text('LUXE'), findsOneWidget);
    expect(
      find.text('The Feed missed that drop. Your design is safe.'),
      findsOneWidget,
    );
    expect(find.text('TRY AGAIN'), findsOneWidget);
    expect(find.text('RETURN TO ATELIER'), findsOneWidget);

    await tester.tap(find.text('TRY AGAIN'));
    await tester.tap(find.text('RETURN TO ATELIER'));

    expect(primaryTaps, 1);
    expect(secondaryTaps, 1);
  });

  testWidgets('LuxeRecoveryCard supports loading state', (
    WidgetTester tester,
  ) async {
    int taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LuxeRecoveryCard(
            message:
                'The Atelier lost the thread. Your choices are still here.',
            primaryLabel: 'Try Again',
            isLoading: true,
            onPrimary: () => taps++,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    expect(taps, 0);
  });
}
