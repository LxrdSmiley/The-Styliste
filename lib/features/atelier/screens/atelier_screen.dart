// GDD §4.1 — Atelier UI: timed cloth physics design session (Designer path).
// Phase 4: GarmentCanvas (GPU shader), FabricSwatchPanel, Mint Alpha CTA.
//
// 5-second interaction gate (Phase 4 directive):
//   _interactionSeconds increments ONLY while _touchActive == true.
//   Passive idle time in the Atelier does NOT count toward the gate.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/design.dart';
import '../constants/style_tags.dart';
import '../providers/mint_design_provider.dart';
import '../widgets/fabric_swatch_panel.dart';
import '../widgets/garment_canvas.dart';

class AtelierScreen extends ConsumerStatefulWidget {
  const AtelierScreen({this.inspirationDesign, super.key});

  final Design? inspirationDesign;

  @override
  ConsumerState<AtelierScreen> createState() => _AtelierScreenState();
}

class _AtelierScreenState extends ConsumerState<AtelierScreen> {
  Color _selectedDye = AppColors.ivory;
  final Set<String> _selectedStyleTags = <String>{...kDefaultStyleTags};
  int _interactionSeconds = 0;
  bool _touchActive = false;
  bool _isMinting = false;
  Timer? _interactionTimer;

  static const int _gateSeconds = 5;

  @override
  void initState() {
    super.initState();

    final Design? inspiration = widget.inspirationDesign;
    if (inspiration == null) return;

    _selectedDye = _hexToColor(
      inspiration.fabricData['color_hex'] as String? ?? 'FAF7F0',
    );
    final List<String> inspirationTags = _readStyleTags(inspiration);
    if (inspirationTags.isNotEmpty) {
      _selectedStyleTags
        ..clear()
        ..addAll(inspirationTags.take(3));
    }
  }

  // ---------------------------------------------------------------------------
  // Interaction gate timer — only ticks while touch is active.
  // ---------------------------------------------------------------------------

  void _onInteractionActive(bool active) {
    setState(() => _touchActive = active);
    if (active) {
      _interactionTimer ??= Timer.periodic(
        const Duration(seconds: 1),
        (_) {
          if (!_touchActive) return; // double-guard
          if (_interactionSeconds < _gateSeconds) {
            setState(() => _interactionSeconds++);
          }
        },
      );
    } else {
      // Pause timer when finger lifts — passive idle time excluded.
      _interactionTimer?.cancel();
      _interactionTimer = null;
    }
  }

  bool get _mintUnlocked => _interactionSeconds >= _gateSeconds;

  void _onTagToggle(String tag) {
    setState(() {
      if (_selectedStyleTags.contains(tag)) {
        if (_selectedStyleTags.length > 1) {
          _selectedStyleTags.remove(tag);
        }
        return;
      }
      if (_selectedStyleTags.length < 3) {
        _selectedStyleTags.add(tag);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Mint Alpha
  // ---------------------------------------------------------------------------

  Future<void> _onMintAlpha() async {
    if (_isMinting || !_mintUnlocked) return;
    setState(() => _isMinting = true);

    try {
      final Design design = await ref.read(
        mintDesignProvider(
          MintDesignInput(
            fabricColorHex: _selectedDye
                .toARGB32()
                .toRadixString(16)
                .padLeft(8, '0')
                .substring(2),
            styleTags: _selectedStyleTags.toList(growable: false),
          ),
        ).future,
      );
      if (mounted) {
        setState(() => _isMinting = false);
        // Navigate to Drop Preview with Vex Critic integration.
        unawaited(
          context.push(
            AppRouter.atelierDropPreview,
            extra: design,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isMinting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF3A1C1C),
            content: Text(
              'Mint failed: $e',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _interactionTimer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final double progress =
        (_interactionSeconds / _gateSeconds).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: AppColors.obsidian,
        foregroundColor: AppColors.ivory,
        elevation: 0.0,
        centerTitle: true,
        title: const Text(
          'ATELIER',
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 4.0,
            color: AppColors.ivory,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          if (widget.inspirationDesign != null)
            _InspirationBanner(design: widget.inspirationDesign!),

          // --- Fabric dye selector ---
          FabricSwatchPanel(
            selectedColor: _selectedDye,
            onSwatchSelected: (Color c) => setState(() => _selectedDye = c),
          ),

          // --- Cloth physics canvas (Expanded — full bleed) ---
          Expanded(
            child: GarmentCanvas(
              dyeColor: _selectedDye,
              onInteractionActive: _onInteractionActive,
            ),
          ),

          // --- Interaction progress + Mint Alpha CTA ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'STYLE SIGNALS',
                  style: TextStyle(
                    color: AppColors.ivory.withValues(alpha: 0.45),
                    fontSize: 9.0,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: kAvailableStyleTags.map((String tag) {
                    final bool selected = _selectedStyleTags.contains(tag);
                    return ChoiceChip(
                      label: Text(tag.toUpperCase()),
                      selected: selected,
                      onSelected: (_) => _onTagToggle(tag),
                      selectedColor: AppColors.gold.withValues(alpha: 0.18),
                      backgroundColor: AppColors.obsidianCard,
                      side: BorderSide(
                        color: selected
                            ? AppColors.gold
                            : AppColors.grey700.withValues(alpha: 0.7),
                      ),
                      labelStyle: TextStyle(
                        color: selected
                            ? AppColors.gold
                            : AppColors.ivory.withValues(alpha: 0.62),
                        fontSize: 9.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16.0),
                // Progress bar — fills as player interacts.
                if (!_mintUnlocked)
                  Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'INTERACTION MOMENTUM',
                            style: TextStyle(
                              color: AppColors.ivory.withValues(alpha: 0.45),
                              fontSize: 9.0,
                              letterSpacing: 2.0,
                            ),
                          ),
                          Text(
                            '$_interactionSeconds / $_gateSeconds s',
                            style: TextStyle(
                              color: AppColors.ivory.withValues(alpha: 0.45),
                              fontSize: 9.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6.0),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.obsidianCard,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(AppColors.gold),
                        minHeight: 2.0,
                      ),
                      const SizedBox(height: 12.0),
                    ],
                  ),

                // Mint Alpha CTA
                SizedBox(
                  width: double.infinity,
                  height: 52.0,
                  child: OutlinedButton(
                    onPressed:
                        (_mintUnlocked && !_isMinting) ? _onMintAlpha : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gold,
                      side: BorderSide(
                        color: _mintUnlocked
                            ? AppColors.gold
                            : AppColors.gold.withValues(alpha: 0.25),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: _isMinting
                        ? const SizedBox(
                            width: 18.0,
                            height: 18.0,
                            child: CircularProgressIndicator(
                              color: AppColors.gold,
                            ),
                          )
                        : Text(
                            _mintUnlocked ? 'MINT ALPHA' : 'MINT ALPHA',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3.0,
                              color: _mintUnlocked
                                  ? AppColors.gold
                                  : AppColors.gold.withValues(alpha: 0.3),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InspirationBanner extends StatelessWidget {
  const _InspirationBanner({required this.design});

  final Design design;

  @override
  Widget build(BuildContext context) {
    final String sourceName =
        design.fabricData['inspiration_source_name'] as String? ?? design.name;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        border: Border(
          bottom: BorderSide(color: AppColors.gold.withValues(alpha: 0.28)),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.palette_outlined, color: AppColors.gold, size: 16.0),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              'INSPIRATION LOADED: ${sourceName.toUpperCase()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 10.0,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<String> _readStyleTags(Design design) {
  final Object? rawTags = design.fabricData['style_tags'];
  if (rawTags is! List) return kDefaultStyleTags;

  final List<String> tags = rawTags
      .map((Object? value) => value?.toString().trim() ?? '')
      .where((String tag) => tag.isNotEmpty)
      .take(3)
      .toList(growable: false);
  return tags.isEmpty ? kDefaultStyleTags : tags;
}

Color _hexToColor(String hex) {
  try {
    final String clean = hex.replaceAll('#', '').padLeft(6, '0');
    return Color(int.parse('FF$clean', radix: 16));
  } catch (_) {
    return AppColors.ivory;
  }
}
