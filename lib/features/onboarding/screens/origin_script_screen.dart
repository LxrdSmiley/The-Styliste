// GDD v8 §§18, 21, 22 — opening manifesto and Luxe introduction.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/styliste_colors.dart';
import '../../../core/theme/styliste_spacing.dart';
import '../../../core/theme/styliste_typography.dart';
import '../../../core/theme/styliste_visual_mode.dart';
import '../../../core/widgets/aurelian_components.dart';
import '../../../core/widgets/styliste_buttons.dart';
import '../../../core/widgets/styliste_scaffold.dart';

class OriginScriptScreen extends ConsumerWidget {
  const OriginScriptScreen({super.key});

  static const List<String> manifesto = <String>[
    'Every empire starts with a stitch.',
    'The world remembers the Houses that define their own line.',
    'You came here to set direction — not to inherit it.',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AurelianScaffold(
      mode: StylisteVisualMode.noirCinematic,
      body: AurelianResponsiveBody(
        maxWidth: 560,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'A HOUSE BEGINS WITH INTENT',
              style: StylisteText.labelCaps.copyWith(
                color: StylisteColors.champagneGold,
              ),
            ),
            const SizedBox(height: StylisteSpacing.xl),
            ...manifesto.indexed.map(
              ((int, String) entry) => Padding(
                padding: const EdgeInsets.only(
                  bottom: StylisteSpacing.lg,
                ),
                child: Semantics(
                  label: 'Manifesto line ${entry.$1 + 1}. ${entry.$2}',
                  child: Text(
                    entry.$2,
                    style: StylisteText.displayEditorial.copyWith(
                      color: entry.$1 == 0
                          ? StylisteColors.ivory
                          : StylisteColors.warmGrey,
                      fontSize: entry.$1 == 0 ? 34 : 25,
                      height: 1.08,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: StylisteSpacing.md),
            const LuxeGuidanceCard(
              mode: StylisteVisualMode.noirCinematic,
              contextLabel: 'Meet Luxe',
              message:
                  'I will clarify the decision in front of you. I will not invent praise, hide a trade-off, or make the choice for your House.',
            ),
            const SizedBox(height: StylisteSpacing.lg),
            GoldPrimaryButton(
              label: 'Name your Kingston House',
              icon: Icons.arrow_forward,
              onPressed: () =>
                  context.go(AppRouter.onboardingSovereignRegistry),
            ),
          ],
        ),
      ),
    );
  }
}
