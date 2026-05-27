// GDD v6 — Drop Preview Screen with Vex AI Critic
// Two-phase flow: Mint → Preview (with tag selection + Vex opt-in) → Drop
// Alabaster Standard: Aurelian palette, SpaceGrotesk typography, Champagne Gold accents

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/aurelian_theme.dart';
import '../../../domain/models/design.dart';
import '../../design/models/vex_review.dart';
import '../../design/widgets/vex_review_card.dart';
import '../constants/style_tags.dart';
import '../providers/drop_design_provider.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dropDesignProvider.notifier).initDropFlow(
            design: widget.design,
            styleTags: _selectedTags.toList(),
          );
    });
  }

  List<String> _readMintedStyleTags(Design design) {
    final Object? rawTags = design.fabricData['style_tags'];
    if (rawTags is List) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
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

  @override
  Widget build(BuildContext context) {
    final DropDesignState dropState = ref.watch(dropDesignProvider);
    final double projectedHype = dropState.hypeResult?.totalScore ?? 0.0;
    final double multiplier = dropState.hypeResult?.tsunamiMultiplier ?? 1.0;
    final bool hasTsunamiMatch = multiplier > 1.0;

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
          Container(
            height: 200.0,
            decoration: BoxDecoration(
              color: AurelianPalette.alabaster,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: AurelianPalette.champagneGold.withValues(alpha: 0.3),
              ),
            ),
            child: Center(
              child: Text(
                widget.design.name,
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                  color: AurelianPalette.textPrimary,
                ),
              ),
            ),
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
            }).toList(),
          ),

          const SizedBox(height: 24.0),

          // --- Vex Opt-In Toggle ---
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AurelianPalette.alabaster,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: <Widget>[
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'FACE VEX JUDGMENT',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: AurelianPalette.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'Receive AI critique on your drop',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 12.0,
                          color: AurelianPalette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: dropState.vexOptedIn,
                  onChanged: (_) =>
                      ref.read(dropDesignProvider.notifier).toggleVexOptIn(),
                  activeThumbColor: AurelianPalette.champagneGold,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24.0),

          // --- Projected Hype Score ---
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
                      'PROJECTED HYPE',
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
                      projectedHype.toStringAsFixed(1),
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
            height: 56.0,
            child: ElevatedButton(
              onPressed: dropState.isDropping ? null : _onDropToFeed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AurelianPalette.champagneGold,
                foregroundColor: AurelianPalette.textPrimary,
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: dropState.isDropping
                  ? const CircularProgressIndicator(
                      color: AurelianPalette.ivory,
                    )
                  : const Text(
                      'DROP TO FEED',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12.0),
        ],
      ),
    );
  }
}
