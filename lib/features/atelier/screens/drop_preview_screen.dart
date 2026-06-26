// GDD v6 - Drop Preview Screen with Vex AI Critic
// Two-phase flow: Mint -> Preview (with tag selection + Vex opt-in) -> Drop
// Alabaster Standard: Aurelian palette, SpaceGrotesk typography, Champagne Gold accents

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/aurelian_theme.dart';
import '../../../core/widgets/gold_primary_button.dart';
import '../../../domain/models/design.dart';
import '../../design/models/vex_review.dart';
import '../../design/widgets/vex_review_card.dart';
import '../../luxe/widgets/luxe_recovery_card.dart';
import '../constants/style_tags.dart';
import '../providers/drop_design_provider.dart';
import '../widgets/face_vex_panel.dart';

class DropPreviewScreen extends ConsumerStatefulWidget {
  const DropPreviewScreen({required this.design, super.key});

  final Design design;

  @override
  ConsumerState<DropPreviewScreen> createState() => _DropPreviewScreenState();
}

class _DropPreviewScreenState extends ConsumerState<DropPreviewScreen> {
  final Set<String> _selectedTags = <String>{};

  @override
  void initState() {
    super.initState();
    _selectedTags.addAll(_readMintedStyleTags(widget.design));

    // Initialize drop flow
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted) return;
      ref.read(dropDesignProvider.notifier).initDropFlow(
            design: widget.design,
            styleTags: _selectedTags.toList(growable: false),
          );
    });
  }

  List<String> _readMintedStyleTags(Design design) {
    final Object? rawTags = design.fabricData['style_tags'];
    if (rawTags is List<Object?>) {
      final List<String> tags = rawTags
          .map((Object? value) => value?.toString().trim() ?? '')
          .where((String tag) => tag.isNotEmpty)
          .take(3)
          .toList(growable: false);
      if (tags.isNotEmpty) return tags;
    }
    return kDefaultStyleTags;
  }

  Future<void> _onDropToFeed() async {
    final VexReview? review =
        await ref.read(dropDesignProvider.notifier).executeDrop();

    if (!mounted) return;
    final String? error = ref.read(dropDesignProvider).error;
    if (error != null) {
      await _showDropRecovery();
      return;
    }

    if (review != null) {
      // Show Vex Review Card in modal
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16.0),
          child: VexReviewCard(
            review: review,
            onDismiss: () {
              Navigator.of(ctx).pop();
            },
          ),
        ),
      );
    }

    if (!mounted) return;
    context.go(AppRouter.atelierDropLaunch);
  }

  Future<void> _showDropRecovery() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16.0),
        child: LuxeRecoveryCard(
          title: 'Feed Recovery',
          message: 'The Feed missed that drop. Your design is safe.',
          primaryLabel: 'Try Again',
          onPrimary: () {
            Navigator.of(dialogContext).pop();
            unawaited(_onDropToFeed());
          },
          secondaryLabel: 'Return to Atelier',
          onSecondary: () {
            Navigator.of(dialogContext).pop();
            context.go(AppRouter.atelier);
          },
          icon: Icons.wifi_off_outlined,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DropDesignState dropState = ref.watch(dropDesignProvider);
    final double mintedHype =
        dropState.hypeResult?.totalScore ?? widget.design.hypeScore;
    final double multiplier = dropState.hypeResult?.tsunamiMultiplier ?? 1.0;
    final bool hasTsunamiMatch = multiplier > 1.0;
    final Color fabricColor = _readFabricColor(widget.design);
    final List<String> selectedTags = _selectedTags.toList(growable: false);

    return Scaffold(
      backgroundColor: AurelianPalette.ivory,
      appBar: AppBar(
        backgroundColor: AurelianPalette.ivory,
        foregroundColor: AurelianPalette.textPrimary,
        elevation: 0.0,
        centerTitle: true,
        title: const Text(
          'PREVIEW DROP',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 4.0,
            color: AurelianPalette.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: <Widget>[
          // --- Design Preview ---
          _DropGarmentPreview(
            design: widget.design,
            fabricColor: fabricColor,
            styleTags: selectedTags,
            hypeScore: mintedHype,
          ),

          const SizedBox(height: 24.0),

          // --- Minted Style Signals ---
          const Text(
            'MINTED STYLE SIGNALS',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 10.0,
              fontWeight: FontWeight.w500,
              letterSpacing: 2.0,
              color: AurelianPalette.textTertiary,
            ),
          ),
          const SizedBox(height: 12.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _selectedTags.map((String tag) {
              return Chip(
                label: Text(tag),
                backgroundColor:
                    AurelianPalette.champagneGold.withValues(alpha: 0.18),
                side: const BorderSide(color: AurelianPalette.champagneGold),
                labelStyle: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 12.0,
                  color: AurelianPalette.textPrimary,
                ),
              );
            }).toList(growable: false),
          ),

          const SizedBox(height: 24.0),

          // --- Vex Opt-In Choice ---
          FaceVexPanel(
            vexOptedIn: dropState.vexOptedIn,
            onFaceVex: () =>
                ref.read(dropDesignProvider.notifier).setVexOptIn(true),
            onDropWithoutCritique: () =>
                ref.read(dropDesignProvider.notifier).setVexOptIn(false),
          ),

          const SizedBox(height: 24.0),

          // --- Minted Hype Score ---
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: AurelianPalette.champagneGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: AurelianPalette.champagneGold.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'MINTED HYPE',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 10.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2.0,
                        color: AurelianPalette.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      mintedHype.toStringAsFixed(1),
                      style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 32.0,
                        fontWeight: FontWeight.w700,
                        color: AurelianPalette.champagneGold,
                      ),
                    ),
                  ],
                ),
                if (hasTsunamiMatch)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: AurelianPalette.champagneGold,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      '${multiplier.toStringAsFixed(1)}x',
                      style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                        color: AurelianPalette.ivory,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 28.0),

          // --- Drop Button ---
          SizedBox(
            width: double.infinity,
            child: GoldPrimaryButton(
              label: 'DROP TO FEED',
              isLoading: dropState.isDropping,
              onPressed: dropState.isDropping ? null : _onDropToFeed,
            ),
          ),
          const SizedBox(height: 12.0),
        ],
      ),
    );
  }
}

class _DropGarmentPreview extends StatelessWidget {
  const _DropGarmentPreview({
    required this.design,
    required this.fabricColor,
    required this.styleTags,
    required this.hypeScore,
  });

  final Design design;
  final Color fabricColor;
  final List<String> styleTags;
  final double hypeScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 258.0,
      decoration: BoxDecoration(
        color: AurelianPalette.alabaster,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: AurelianPalette.champagneGold.withValues(alpha: 0.56),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AurelianPalette.champagneGoldDark.withValues(alpha: 0.13),
            blurRadius: 26.0,
            offset: const Offset(0.0, 14.0),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AurelianPalette.ivory,
                  Color.lerp(
                        fabricColor,
                        AurelianPalette.champagneGold,
                        0.6,
                      )?.withValues(alpha: 0.44) ??
                      AurelianPalette.champagneGold.withValues(alpha: 0.44),
                  AurelianPalette.alabaster,
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _PreviewGarmentPainter(fabricColor: fabricColor),
            ),
          ),
          const Positioned(
            left: 16.0,
            top: 14.0,
            child: _PreviewBadge(label: 'ALPHA MINTED'),
          ),
          Positioned(
            right: 16.0,
            top: 14.0,
            child: _PreviewBadge(label: '${hypeScore.toStringAsFixed(1)} HYPE'),
          ),
          Positioned(
            left: 16.0,
            right: 16.0,
            bottom: 16.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  design.name.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 25.0,
                    fontWeight: FontWeight.w800,
                    height: 0.98,
                    color: AurelianPalette.textPrimary,
                  ),
                ),
                if (styleTags.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10.0),
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: styleTags.take(3).map((String tag) {
                      return _PreviewTagPill(label: tag);
                    }).toList(growable: false),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewBadge extends StatelessWidget {
  const _PreviewBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
      decoration: BoxDecoration(
        color: AurelianPalette.ivory.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(999.0),
        border: Border.all(
          color: AurelianPalette.champagneGoldDark.withValues(alpha: 0.42),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'SpaceGrotesk',
          color: AurelianPalette.textPrimary,
          fontSize: 9.0,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _PreviewTagPill extends StatelessWidget {
  const _PreviewTagPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: AurelianPalette.champagneGold.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(999.0),
        border: Border.all(color: AurelianPalette.champagneGoldDark),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'SpaceGrotesk',
          color: AurelianPalette.textPrimary,
          fontSize: 8.0,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _PreviewGarmentPainter extends CustomPainter {
  const _PreviewGarmentPainter({required this.fabricColor});

  final Color fabricColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width * 0.5, size.height * 0.43);
    final Paint glow = Paint()
      ..color = AurelianPalette.champagneGoldDark.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28.0);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.48,
        height: size.height * 0.78,
      ),
      glow,
    );

    final Path dress = Path()
      ..moveTo(center.dx - 34.0, size.height * 0.18)
      ..cubicTo(
        center.dx - 86.0,
        size.height * 0.28,
        center.dx - 78.0,
        size.height * 0.66,
        center.dx,
        size.height * 0.76,
      )
      ..cubicTo(
        center.dx + 78.0,
        size.height * 0.66,
        center.dx + 86.0,
        size.height * 0.28,
        center.dx + 34.0,
        size.height * 0.18,
      )
      ..quadraticBezierTo(
        center.dx,
        size.height * 0.28,
        center.dx - 34.0,
        size.height * 0.18,
      )
      ..close();

    final Paint fabric = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          fabricColor.withValues(alpha: 0.9),
          Color.lerp(
                fabricColor,
                AurelianPalette.textPrimary,
                0.2,
              )?.withValues(alpha: 0.88) ??
              fabricColor.withValues(alpha: 0.88),
          AurelianPalette.champagneGoldDark.withValues(alpha: 0.86),
        ],
      ).createShader(dress.getBounds());
    canvas.drawPath(dress, fabric);

    final Paint edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AurelianPalette.ivory.withValues(alpha: 0.72);
    canvas.drawPath(dress, edge);

    final Paint stand = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = AurelianPalette.textPrimary.withValues(alpha: 0.22);
    canvas
      ..drawLine(
        Offset(center.dx, size.height * 0.76),
        Offset(center.dx, size.height * 0.88),
        stand,
      )
      ..drawLine(
        Offset(center.dx - 36.0, size.height * 0.88),
        Offset(center.dx + 36.0, size.height * 0.88),
        stand,
      );
  }

  @override
  bool shouldRepaint(covariant _PreviewGarmentPainter oldDelegate) {
    return oldDelegate.fabricColor != fabricColor;
  }
}

Color _readFabricColor(Design design) {
  final Object? color = design.fabricData['color_hex'];
  if (color is! String) return AurelianPalette.ivory;

  try {
    final String clean = color.replaceAll('#', '').padLeft(6, '0');
    return Color(int.parse('FF$clean', radix: 16));
  } catch (_) {
    return AurelianPalette.ivory;
  }
}
