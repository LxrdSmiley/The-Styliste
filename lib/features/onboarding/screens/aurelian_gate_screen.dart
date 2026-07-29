// GDD v8 §§18, 21, 22 — Opening Sanctuary and age gate.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/styliste_colors.dart';
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
                ),
              _GateState.denied => const AurelianStatePanel(
                  kind: AurelianStateKind.permissionDenied,
                  title: 'The Sanctuary cannot open',
                  message:
                      'The Styliste is available only to players who meet the minimum age requirement.',
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: StylisteColors.champagneGold,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'S',
                style: TextStyle(
                  color: StylisteColors.champagneGold,
                  fontFamily: StylisteText.displayFamily,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: StylisteSpacing.xl),
          Text(
            'THE OPENING\nSANCTUARY',
            style: StylisteText.displayHero.copyWith(
              color: StylisteColors.ivory,
            ),
          ),
          const SizedBox(height: StylisteSpacing.md),
          Text(
            'Your House begins in Kingston: at the meeting point of tailoring, sound, streetwear, and global creative ambition.',
            style: StylisteText.bodyLarge.copyWith(
              color: StylisteColors.warmGrey,
            ),
          ),
          const SizedBox(height: StylisteSpacing.xl),
          GoldPrimaryButton(
            label: 'Enter the Sanctuary',
            icon: Icons.arrow_forward,
            onPressed: () => context.go(AppRouter.onboardingOriginScript),
          ),
          const SizedBox(height: StylisteSpacing.sm),
          Text(
            'No purchase, reward, or progression is created on this screen.',
            textAlign: TextAlign.center,
            style: StylisteText.bodySmall.copyWith(
              color: StylisteColors.warmGreyDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeGateDialog extends StatelessWidget {
  const _AgeGateDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Before the Sanctuary opens'),
      content: const Text(
        'Please confirm that you meet the minimum age requirement for The Styliste.',
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
