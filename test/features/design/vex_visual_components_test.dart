import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_styliste/core/widgets/styliste_buttons.dart';
import 'package:the_styliste/features/design/models/vex_review.dart';
import 'package:the_styliste/features/design/widgets/vex_review_card.dart';
import 'package:the_styliste/features/design/widgets/vex_verdict_badge.dart';

void main() {
  test('VexReview maps domain verdicts to visual tiers', () {
    expect(
      _review(verdict: VexVerdict.tarnished, hypeScore: 20.0).visualTier,
      VexVerdictVisualTier.quiet,
    );
    expect(
      _review(verdict: VexVerdict.derivative, hypeScore: 49.9).visualTier,
      VexVerdictVisualTier.watched,
    );
    expect(
      _review(verdict: VexVerdict.derivative, hypeScore: 50.0).visualTier,
      VexVerdictVisualTier.rising,
    );
    expect(
      _review(verdict: VexVerdict.visionary, hypeScore: 70.0).visualTier,
      VexVerdictVisualTier.trendSurge,
    );
    expect(
      _review(
        verdict: VexVerdict.visionary,
        hypeScore: 70.0,
        matchingTsunamiTag: 'minimal',
        tsunamiMultiplier: 1.5,
      ).visualTier,
      VexVerdictVisualTier.waveRider,
    );
    expect(
      _review(verdict: VexVerdict.sovereign, hypeScore: 95.0).visualTier,
      VexVerdictVisualTier.iconic,
    );
  });

  testWidgets('VexVerdictBadge renders player-facing tier label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VexVerdictBadge(tier: VexVerdictVisualTier.waveRider),
        ),
      ),
    );

    expect(find.text('WAVE RIDER'), findsOneWidget);
  });

  testWidgets('VexReviewCard uses shared buttons and launch copy', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VexReviewCard(
            review: _review(verdict: VexVerdict.derivative, hypeScore: 54.0),
            onShare: () {},
            onDismiss: () {},
          ),
        ),
      ),
    );

    expect(find.byType(IvorySecondaryButton), findsOneWidget);
    expect(find.byType(ObsidianPrimaryButton), findsOneWidget);
    expect(find.text('SHARE'), findsOneWidget);
    expect(find.text('CONTINUE TO LAUNCH'), findsOneWidget);
    expect(find.text('ACCEPT'), findsNothing);

    await tester.pump(const Duration(seconds: 1));
  });
}

VexReview _review({
  required VexVerdict verdict,
  required double hypeScore,
  String? matchingTsunamiTag,
  double? tsunamiMultiplier,
}) {
  return VexReview(
    headline: 'A controlled provocation.',
    body: 'Sharp enough to be watched.',
    verdict: verdict,
    hypeScore: hypeScore,
    matchingTsunamiTag: matchingTsunamiTag,
    tsunamiMultiplier: tsunamiMultiplier,
  );
}
