// Directive G — Screen 7: Ascension Confirmation
// GDD §1.1 — The climax. The Sovereign Dossier. The Radiant White-Out.
// Kode's Final Polish: Premium card aesthetic, haptic ramp-up, expanding RadialGradient

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/onboarding_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/aurelian_theme.dart';
import '../../../domain/models/player.dart';

/// Ascension Confirmation Screen — The Sovereign Genesis
///
/// Features:
/// - Sovereign Dossier: Premium card showing all choices
/// - SEAL THE STANDARD button (massive, gold)
/// - Heavy haptic ramp-up on press
/// - Radiant White-Out transition (RadialGradient expansion)
/// - 1.5s hold while backend provisions
/// - Crossfade to Golden Hour HQ
class AscensionConfirmationScreen extends ConsumerStatefulWidget {
  const AscensionConfirmationScreen({super.key});

  @override
  ConsumerState<AscensionConfirmationScreen> createState() =>
      _AscensionConfirmationScreenState();
}

class _AscensionConfirmationScreenState
    extends ConsumerState<AscensionConfirmationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _whiteOutController;
  bool _isSealing = false;
  bool _showWhiteOut = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _whiteOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _whiteOutController.addStatusListener(_onWhiteOutStatusChange);
  }

  void _onWhiteOutStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // White-out complete, navigate to HQ
      if (mounted) {
        context.go(AppRouter.hq);
      }
    }
  }

  @override
  void dispose() {
    _whiteOutController.dispose();
    super.dispose();
  }

  Future<void> _sealTheStandard() async {
    if (_isSealing) return;

    final OnboardingState state = ref.read(onboardingProvider);

    // Validate all required fields
    if (!state.isReadyToCommit) {
      setState(
<<<<<<< HEAD
          () => _errorMessage = 'Please complete all choices before sealing.');
=======
        () => _errorMessage = 'Please complete all choices before sealing.',
      );
>>>>>>> b82f5aa0df7cf605d44fb4b2ee0b34ca518f7b9e
      return;
    }

    setState(() => _isSealing = true);

    // Step 1: Haptic ramp-up
    await _hapticRampUp();

    // Step 2: Start white-out animation
    setState(() => _showWhiteOut = true);
<<<<<<< HEAD
    _whiteOutController.forward();
=======
    unawaited(_whiteOutController.forward());
>>>>>>> b82f5aa0df7cf605d44fb4b2ee0b34ca518f7b9e

    // Step 3: Execute genesis RPC while animation plays
    try {
      final SupabaseClient supabase = Supabase.instance.client;
      final String userId = supabase.auth.currentUser!.id;

      final Map<String, dynamic> result = await supabase.rpc(
        'execute_sovereign_genesis',
        params: <String, dynamic>{
          'p_user_id': userId,
          'p_brand_name': state.brandName,
          'p_career_path': state.selectedPath!.apiValue,
          'p_city': state.selectedCity!.apiValue,
          'p_market_tier': state.selectedTier!.apiValue,
          'p_avatar_config':
              state.avatarConfig?.toJson() ?? <String, dynamic>{},
        },
      );

      if (result['success'] == true) {
        // Success: White-out will complete and navigate automatically
        // Animation continues to completion...
      } else {
        _handleGenesisError(result['message'] as String? ?? 'Unknown error');
      }
    } catch (e) {
      _handleGenesisError(e.toString());
    }
  }

  void _handleGenesisError(String error) {
    _whiteOutController.stop();
    _whiteOutController.reset();
    setState(() {
      _isSealing = false;
      _showWhiteOut = false;
      _errorMessage = 'Genesis failed: $error';
    });
  }

  Future<void> _hapticRampUp() async {
    // Heavy impact at start
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Vibrations during expansion
    for (int i = 0; i < 5; i++) {
      await HapticFeedback.vibrate();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingState state = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: AurelianPalette.ivory,
      body: Stack(
        children: <Widget>[
          // --- Main content ---
          SafeArea(
            child: Column(
              children: <Widget>[
                // --- Header ---
                _buildHeader(),

                const SizedBox(height: 32.0),

                // --- Sovereign Dossier (Kode's Premium Card) ---
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _SovereignDossier(state: state)
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 200))
                        .slideY(begin: 0.1, end: 0.0),
                  ),
                ),

                // --- Error message ---
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                // --- SEAL THE STANDARD button ---
                _buildSealButton()
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 400))
                    .slideY(begin: 0.3, end: 0.0),

                const SizedBox(height: 32.0),
              ],
            ),
          ),

          // --- Radiant White-Out overlay ---
          if (_showWhiteOut)
            AnimatedBuilder(
              animation: _whiteOutController,
              builder: (BuildContext context, Widget? child) {
                return _WhiteOutOverlay(
                  progress: _whiteOutController.value,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'THE ASCENSION',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 4.0,
              color: AurelianPalette.textTertiary,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            'CONFIRMATION',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 32.0,
              fontWeight: FontWeight.w300,
              letterSpacing: 2.0,
              color: AurelianPalette.textPrimary,
            ),
          ),
          SizedBox(height: 12.0),
          Text(
            'Review your Sovereign Dossier before sealing your destiny.',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 14.0,
              color: AurelianPalette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSealButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GestureDetector(
        onTap: _isSealing ? null : _sealTheStandard,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[
                AurelianPalette.champagneGold,
                Color(0xFFE8D4B8),
              ],
            ),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AurelianPalette.champagneGold.withValues(
                  alpha: _isSealing ? 0.6 : 0.3,
                ),
                blurRadius: _isSealing ? 32.0 : 16.0,
                spreadRadius: _isSealing ? 4.0 : 2.0,
                offset: const Offset(0.0, 8.0),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_isSealing)
                const SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF2A2A2A)),
                  ),
                )
              else
                const Icon(
                  Icons.verified,
                  size: 24.0,
                  color: Color(0xFF2A2A2A),
                ),
              const SizedBox(width: 12.0),
              Text(
                _isSealing ? 'ESTABLISHING EMPIRE...' : 'SEAL THE STANDARD',
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3.0,
                  color: Color(0xFF2A2A2A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Sovereign Dossier — Kode's Premium Card Aesthetic
// =============================================================================

class _SovereignDossier extends StatelessWidget {
  const _SovereignDossier({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        color: AurelianPalette.alabaster,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: AurelianPalette.champagneGold,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AurelianPalette.champagneGold.withValues(alpha: 0.1),
            blurRadius: 24.0,
            spreadRadius: 2.0,
            offset: const Offset(0.0, 8.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // --- Dossier header ---
          Row(
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: AurelianPalette.champagneGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  'SOVEREIGN DOSSIER',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 10.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                    color: AurelianPalette.champagneGold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24.0),

          // --- Brand Name (Hero) ---
          _DossierField(
            label: 'BRAND NAME',
            value: state.brandName.toUpperCase(),
            isHero: true,
          ),

          const Divider(
            height: 32.0,
            color: Color(0xFFE8D4B8),
          ),

          // --- Two-column layout ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _DossierField(
                      label: 'HEADQUARTERS',
                      value: _getCityDisplay(state.selectedCity),
                    ),
                    const SizedBox(height: 20.0),
                    _DossierField(
                      label: 'CAREER PATH',
                      value:
                          state.selectedPath?.displayName.toUpperCase() ?? '—',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _DossierField(
                      label: 'MARKET TIER',
                      value:
                          state.selectedTier?.displayName.toUpperCase() ?? '—',
                    ),
                    const SizedBox(height: 20.0),
                    _DossierField(
                      label: 'STARTING CAPITAL',
                      value: state.selectedTier != null
                          ? '\$${(state.selectedTier!.startingCapital / 1000).toStringAsFixed(0)}K'
                          : '—',
                      valueFont: 'JetBrainsMono',
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(
            height: 32.0,
            color: Color(0xFFE8D4B8),
          ),

          // --- Avatar summary ---
          _DossierField(
            label: 'FOUNDER VISAGE',
            value: state.avatarConfig != null
                ? 'Face ${state.avatarConfig!.faceIndex} • Body ${state.avatarConfig!.bodyIndex} • Hair ${state.avatarConfig!.hairIndex} • Fit ${state.avatarConfig!.fitIndex}'
                : 'Default Configuration',
          ),

          const SizedBox(height: 20.0),

          // --- Hype ceiling (raw stat) ---
          if (state.selectedTier != null)
            _DossierField(
              label: 'HYPE CEILING',
              value:
                  '${(state.selectedTier!.hypeCeiling / 1000000).toStringAsFixed(1)}M',
              valueFont: 'JetBrainsMono',
            ),
        ],
      ),
    );
  }

  String _getCityDisplay(HqCity? city) {
    if (city == null) return '—';
    switch (city) {
      case HqCity.newYork:
        return 'NEW YORK';
      case HqCity.paris:
        return 'PARIS';
      case HqCity.tokyo:
        return 'TOKYO';
      case HqCity.milan:
        return 'MILAN';
      case HqCity.london:
        return 'LONDON';
      case HqCity.seoul:
        return 'SEOUL';
      default:
        return city.name.toUpperCase();
    }
  }
}

class _DossierField extends StatelessWidget {
  const _DossierField({
    required this.label,
    required this.value,
    this.isHero = false,
    this.valueFont = 'SpaceGrotesk',
  });

  final String label;
  final String value;
  final bool isHero;
  final String valueFont;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 9.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
            color: AurelianPalette.textTertiary,
          ),
        ),
        const SizedBox(height: 6.0),
        Text(
          value,
          style: TextStyle(
            fontFamily: valueFont,
            fontSize: isHero ? 28.0 : 16.0,
            fontWeight: isHero ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: isHero ? 3.0 : 1.5,
            color: AurelianPalette.textPrimary,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Radiant White-Out Overlay
// =============================================================================

class _WhiteOutOverlay extends StatelessWidget {
  const _WhiteOutOverlay({required this.progress});

  final double progress; // 0.0 → 1.0

  @override
  Widget build(BuildContext context) {
    // Progress mapping:
    // 0.0 - 0.3: Champagne gold center expanding
    // 0.3 - 0.7: Alabaster blending in
    // 0.7 - 1.0: Pure white

    final double radius = 0.2 + (progress * 2.0); // 0.2 → 2.2 (fills screen)

    Color centerColor;
    Color midColor;
    Color outerColor;

    if (progress < 0.3) {
      // Phase 1: Champagne gold dominant
      centerColor = AurelianPalette.champagneGold;
      midColor = AurelianPalette.champagneGold.withValues(alpha: 0.8);
      outerColor = Colors.transparent;
    } else if (progress < 0.7) {
      // Phase 2: Alabaster blending
      centerColor = Colors.white;
      midColor = AurelianPalette.alabaster;
      outerColor = AurelianPalette.champagneGold.withValues(alpha: 0.5);
    } else {
      // Phase 3: Pure white
      centerColor = Colors.white;
      midColor = Colors.white;
      outerColor = Colors.white.withValues(alpha: 0.9);
    }

    return Container(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: radius,
            colors: <Color>[
              centerColor,
              midColor,
              outerColor,
            ],
            stops: const <double>[0.0, 0.5, 1.0],
          ),
        ),
        child: progress > 0.8
            ? Center(
                child: Text(
                  'WELCOME TO YOUR EMPIRE',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 4.0,
                    color: AurelianPalette.textTertiary
                        .withValues(alpha: 1.0 - progress),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
