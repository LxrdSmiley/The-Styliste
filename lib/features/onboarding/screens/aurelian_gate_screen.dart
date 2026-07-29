// GDD v8 §§18, 21, 22 — Opening Sanctuary and age gate.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/styliste_colors.dart';
import '../../../core/theme/styliste_radii.dart';
import '../../../core/theme/styliste_spacing.dart';
import '../../../core/theme/styliste_typography.dart';
import '../../../core/theme/styliste_visual_mode.dart';
import '../../../core/widgets/aurelian_components.dart';
import '../../../core/widgets/styliste_buttons.dart';
import '../../../core/widgets/styliste_scaffold.dart';

enum _GateState { checkingAge, ready, denied }

class AurelianGateScreen extends ConsumerStatefulWidget {
  const AurelianGateScreen({super.key});

  @override
  ConsumerState<AurelianGateScreen> createState() => _AurelianGateScreenState();
}

class _AurelianGateScreenState extends ConsumerState<AurelianGateScreen> {
  _GateState _state = _GateState.checkingAge;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_checkAgeGate());
    });
  }

  Future<void> _checkAgeGate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('age_gate_passed') ?? false) {
      if (mounted) setState(() => _state = _GateState.ready);
      return;
    }
    if (!mounted) return;
    final bool? eligible = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const _AgeGateDialog(),
    );
    if (!mounted) return;
    if (eligible ?? false) {
      await prefs.setBool('age_gate_passed', true);
      if (mounted) setState(() => _state = _GateState.ready);
    } else {
      setState(() => _state = _GateState.denied);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AurelianScaffold(
      mode: StylisteVisualMode.noirCinematic,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _SanctuaryLinePainter()),
            ),
          ),
          AurelianResponsiveBody(
            maxWidth: 520,
            child: switch (_state) {
              _GateState.checkingAge => const AurelianStatePanel(
                  kind: AurelianStateKind.loading,
                  title: 'Preparing the Sanctuary',
                  message: 'Checking the local age-gate record.',
                  authorityLabel: 'Local eligibility record only.',
                  preservationLabel:
                      'No House or gameplay state has been created.',
                ),
              _GateState.denied => const AurelianStatePanel(
                  kind: AurelianStateKind.permissionDenied,
                  title: 'The Sanctuary cannot open',
                  message:
                      'The Styliste is available only to players who meet the minimum age requirement.',
                  authorityLabel: 'Eligibility gate',
                  preservationLabel:
                      'No account progression or economic state was created.',
                ),
              _GateState.ready => const _SanctuaryInvitation(),
            },
          ),
        ],
      ),
    );
  }
}

class _SanctuaryInvitation extends StatelessWidget {
  const _SanctuaryInvitation();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          'Opening Sanctuary. Your House begins in Kingston. Enter the Sanctuary.',
      child: AurelianEditorialHero(
        dark: true,
        eyebrow: 'Kingston · Opening appointment',
        title: 'The Opening\nSanctuary',
        detail:
            'Your House begins where tailoring, sound, streetwear, and global creative ambition meet.',
        visual: Row(
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: StylisteColors.champagneGold,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(StylisteRadii.card),
              ),
              child: Text(
                'S',
                style: StylisteText.displayEditorial.copyWith(
                  color: StylisteColors.champagneGold,
                ),
              ),
            ),
            const SizedBox(width: StylisteSpacing.md),
            Expanded(
              child: Text(
                'Fashion authorship\nHouse identity\nKingston authority',
                style: StylisteText.labelCaps.copyWith(
                  color: StylisteColors.warmGrey,
                  height: 1.7,
                ),
              ),
            ),
          ],
        ),
        status: const AurelianStatusChip(
          label: 'Founder trial begins here',
          icon: Icons.content_cut_outlined,
        ),
        primaryAction: GoldPrimaryButton(
          label: 'Enter the Sanctuary',
          icon: Icons.arrow_forward,
          onPressed: () => context.go(AppRouter.onboardingOriginScript),
        ),
        footnote:
            'No purchase, reward, or progression is created on this screen.',
      ),
    );
  }
}

class _AgeGateDialog extends StatelessWidget {
  const _AgeGateDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        Icons.shield_outlined,
        semanticLabel: 'Age eligibility',
      ),
      title: const Text('Before the Sanctuary opens'),
      content: const AurelianCutLineFrame(
        padding: EdgeInsets.all(StylisteSpacing.md),
        child: Text(
          'Please confirm that you meet the minimum age requirement for The Styliste. This choice does not create gameplay progress.',
        ),
      ),
      actionsOverflowDirection: VerticalDirection.up,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actions: <Widget>[
        IvorySecondaryButton(
          label: 'I am under 13',
          onPressed: () => Navigator.of(context).pop(false),
        ),
        GoldPrimaryButton(
          label: 'I am 13 or older',
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}

class _SanctuaryLinePainter extends CustomPainter {
  const _SanctuaryLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint line = Paint()
      ..color = StylisteColors.champagneGold.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final Path path = Path()
      ..moveTo(size.width * 0.67, 0)
      ..cubicTo(
        size.width * 0.56,
        size.height * 0.25,
        size.width * 0.92,
        size.height * 0.42,
        size.width * 0.72,
        size.height,
      );
    canvas.drawPath(path, line);

    final Paint measure = Paint()
      ..color = StylisteColors.roseAccent.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (double y = 80; y < size.height; y += 48) {
      canvas.drawLine(
        Offset(size.width - 36, y),
        Offset(size.width - (y % 96 == 0 ? 56 : 44), y),
        measure,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SanctuaryLinePainter oldDelegate) => false;
}
