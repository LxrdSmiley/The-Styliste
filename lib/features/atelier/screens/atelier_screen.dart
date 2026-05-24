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
import '../providers/mint_design_provider.dart';
import '../widgets/fabric_swatch_panel.dart';
import '../widgets/garment_canvas.dart';

class AtelierScreen extends ConsumerStatefulWidget {
  const AtelierScreen({super.key});

  @override
  ConsumerState<AtelierScreen> createState() => _AtelierScreenState();
}

class _AtelierScreenState extends ConsumerState<AtelierScreen> {
  Color _selectedDye = AppColors.ivory;
  int _interactionSeconds = 0;
  bool _touchActive = false;
  bool _isMinting = false;
  Timer? _interactionTimer;

  static const int _gateSeconds = 5;

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

  // ---------------------------------------------------------------------------
  // Mint Alpha
  // ---------------------------------------------------------------------------

  Future<void> _onMintAlpha() async {
    if (_isMinting || !_mintUnlocked) return;
    setState(() => _isMinting = true);

    try {
      final Design design = await ref.read(
        mintDesignProvider(
          _selectedDye
              .toARGB32()
              .toRadixString(16)
              .padLeft(8, '0')
              .substring(2),
        ).future,
      );
      if (mounted) {
        // Navigate to Drop Preview with Vex Critic integration
        context.push(
          AppRouter.atelierDropPreview,
          extra: design,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isMinting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF3A1C1C),
            content: Text(
              'MINT FAILED — try again',
              style: TextStyle(color: Colors.redAccent),
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
              children: <Widget>[
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
