// Directive G — Screen 7: Ascension Confirmation
// GDD v7 §§5.1, 19.1–19.3, 22 — fail-closed identity before Genesis.
// Kode's Final Polish: Premium card aesthetic, haptic ramp-up, expanding RadialGradient

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/aurelian_theme.dart';
import '../../../core/widgets/styliste_buttons.dart';
import '../../../domain/models/player.dart';
import '../providers/sovereign_genesis_provider.dart';

/// Ascension Confirmation Screen — The Sovereign Genesis
///
/// Features:
/// - Sovereign Dossier: Premium card showing all choices
/// - SEAL THE STANDARD button (massive, gold)
/// - Heavy haptic ramp-up after confirmed Genesis
/// - Radiant White-Out transition (RadialGradient expansion)
/// - 1.5s completion presentation after server confirmation
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
  bool _isRetrying = false;
  bool _isSigningOut = false;
  bool _showWhiteOut = false;
  bool _hasIdentityFailure = false;
  String? _errorMessage;

  static const String _identityFailureMessage =
      'Your secure game session could not be established. You can retry or restart safely.';
  static const String _genesisFailureMessage =
      'Your founding record could not be sealed. Please try again.';

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
    if (_isSealing || _isRetrying || _isSigningOut) return;

    final OnboardingState state = ref.read(onboardingProvider);

    // Validate all required fields
    if (!state.isReadyToCommit) {
      setState(
        () => _errorMessage = 'Please complete all choices before sealing.',
      );
      return;
    }

    setState(() {
      _isSealing = true;
      _hasIdentityFailure = false;
      _errorMessage = null;
    });

    try {
      final String userId = await ref
          .read(supabaseAuthActionsProvider)
          .requireEstablishedUserId();
      await _executeGenesis(state: state, userId: userId);
    } catch (_) {
      _handleIdentityFailure();
    }
  }

  Future<void> _retryIdentity() async {
    if (_isSealing || _isRetrying || _isSigningOut) return;

    final OnboardingState state = ref.read(onboardingProvider);
    if (!state.isReadyToCommit) {
      setState(
        () => _errorMessage = 'Please complete all choices before sealing.',
      );
      return;
    }

    setState(() {
      _isRetrying = true;
      _hasIdentityFailure = false;
      _errorMessage = null;
    });

    try {
      final String userId =
          await ref.read(supabaseAuthActionsProvider).retrySession();
      if (!mounted) return;
      setState(() => _isRetrying = false);
      setState(() => _isSealing = true);
      await _executeGenesis(state: state, userId: userId);
    } catch (_) {
      _handleIdentityFailure();
    }
  }

  Future<void> _signOutAndRestart() async {
    if (_isSealing || _isRetrying || _isSigningOut) return;

    setState(() {
      _isSigningOut = true;
      _errorMessage = null;
    });

    try {
      await ref.read(supabaseAuthActionsProvider).signOutAndRestart();
      if (!mounted) return;
      ref.read(onboardingProvider.notifier).reset();
      context.go(AppRouter.onboardingAurelianGate);
    } catch (_) {
      _handleIdentityFailure();
    }
  }

  Future<void> _executeGenesis({
    required OnboardingState state,
    required String userId,
  }) async {
    try {
      final SovereignGenesisResult result = await ref
          .read(sovereignGenesisGatewayProvider)
          .execute(
            SovereignGenesisRequest(
              userId: userId,
              brandName: state.brandName,
              careerPath: state.selectedPath!.apiValue,
              city: state.selectedCity!.apiValue,
              marketTier: state.selectedTier!.apiValue,
              avatarConfig: state.avatarConfig?.toJson() ?? <String, dynamic>{},
            ),
          );

      if (!result.success) {
        _handleGenesisError(result.message);
        return;
      }

      // Success presentation begins only after the server-confirmed result.
      await _hapticRampUp();
      if (!mounted) return;
      setState(() => _showWhiteOut = true);
      unawaited(_whiteOutController.forward());
    } catch (_) {
      _handleGenesisError(null);
    }
  }

  void _handleIdentityFailure() {
    _whiteOutController.stop();
    _whiteOutController.reset();
    if (!mounted) return;
    setState(() {
      _isSealing = false;
      _isRetrying = false;
      _isSigningOut = false;
      _showWhiteOut = false;
      _hasIdentityFailure = true;
      _errorMessage = _identityFailureMessage;
    });
  }

  void _handleGenesisError(String? errorCode) {
    if (errorCode == 'PLAYER_ALREADY_EXISTS' ||
        (errorCode?.contains('PLAYER_ALREADY_EXISTS') ?? false)) {
      if (mounted) {
        context.go(AppRouter.hq);
      }
      return;
    }

    _whiteOutController.stop();
    _whiteOutController.reset();
    if (!mounted) return;
    setState(() {
      _isSealing = false;
      _isRetrying = false;
      _showWhiteOut = false;
      _errorMessage = _genesisFailureMessage;
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
                if (_errorMessage != null) _buildErrorPanel(),

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
              key: const Key('success-whiteout'),
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
      child: Semantics(
        button: true,
        enabled: !_isSealing && !_isRetrying && !_isSigningOut,
        label: 'Seal the standard',
        child: GestureDetector(
          key: const Key('seal-the-standard'),
          onTap: _isSealing || _isRetrying || _isSigningOut
              ? null
              : _sealTheStandard,
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
      ),
    );
  }

  Widget _buildErrorPanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 12.0),
      child: Semantics(
        container: true,
        liveRegion: true,
        label: 'Identity recovery',
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: AurelianPalette.danger.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: AurelianPalette.danger.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: AurelianPalette.textPrimary,
                  fontSize: 12.0,
                ),
                textAlign: TextAlign.center,
              ),
              if (_hasIdentityFailure) ...<Widget>[
                const SizedBox(height: 12.0),
                GoldPrimaryButton(
                  key: const Key('retry-secure-sign-in'),
                  label: 'Retry Secure Sign-In',
                  icon: Icons.refresh,
                  onPressed:
                      _isRetrying || _isSigningOut ? null : _retryIdentity,
                  isLoading: _isRetrying,
                  disabledReason:
                      _isRetrying ? 'Secure sign-in is in progress.' : null,
                ),
                const SizedBox(height: 8.0),
                IvorySecondaryButton(
                  key: const Key('sign-out-and-restart'),
                  label: 'Sign Out & Restart',
                  icon: Icons.logout,
                  onPressed:
                      _isRetrying || _isSigningOut ? null : _signOutAndRestart,
                  isLoading: _isSigningOut,
                  disabledReason:
                      _isSigningOut ? 'Restarting authentication.' : null,
                ),
              ],
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
