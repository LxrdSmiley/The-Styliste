// Directive I — Casting Room Screen
// GDD §12.4.1 — Premium Gacha UX: Wax Seal drag, Sovereign Dossier reveal
// Kode Addendum: No spinning wheels. Heavy haptics. Pure tactile elegance.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/aurelian_theme.dart';
import '../models/talent.dart';
import '../providers/casting_provider.dart';

/// Casting Room — Premium gacha experience
///
/// UX Flow:
/// 1. Concrete-and-ivory studio environment
/// 2. Drag wax seal down to break (heavy haptics)
/// 3. Blinding alabaster light bleeds through crack
/// 4. Sovereign Dossier slides in
/// 5. Dossier opens to reveal talent portrait
/// 6. Staggered haptic thuds for each step
class CastingRoomScreen extends ConsumerStatefulWidget {
  const CastingRoomScreen({super.key});

  @override
  ConsumerState<CastingRoomScreen> createState() => _CastingRoomScreenState();
}

class _CastingRoomScreenState extends ConsumerState<CastingRoomScreen>
    with TickerProviderStateMixin {
  late final AnimationController _sealController;
  late final AnimationController _lightController;
  late final AnimationController _dossierController;

  double _sealDragProgress = 0.0;
  bool _isDragging = false;
  bool _sealBroken = false;

  @override
  void initState() {
    super.initState();
    _sealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _lightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _dossierController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _sealController.dispose();
    _lightController.dispose();
    _dossierController.dispose();
    super.dispose();
  }

  Future<void> _onSealBreak() async {
    if (_sealBroken) return;

    setState(() => _sealBroken = true);

    // Heavy impact as seal breaks
    await HapticFeedback.heavyImpact();

    // Animate seal breaking
    await _sealController.forward();

    // Blinding light bleeds through
    await _lightController.forward();

    // Execute the actual casting pull
    await ref.read(castingProvider.notifier).executePull();

    // Dossier slides in
    await _dossierController.forward();
  }

  void _onSealDragUpdate(DragUpdateDetails details) {
    if (_sealBroken) return;

    setState(() {
      _isDragging = true;
      _sealDragProgress =
          (_sealDragProgress + details.delta.dy / 200).clamp(0.0, 1.0);
    });

    // Haptic feedback at 50% and 100%
    if (_sealDragProgress >= 0.5 && _sealDragProgress < 0.6) {
      HapticFeedback.lightImpact();
    }

    // Break seal at 100%
    if (_sealDragProgress >= 1.0) {
      _onSealBreak();
    }
  }

  void _onSealDragEnd(DragEndDetails details) {
    if (_sealBroken) return;

    setState(() => _isDragging = false);

    // Snap back if not broken
    if (_sealDragProgress < 1.0) {
      _animateSealReset();
    }
  }

  void _animateSealReset() {
    // Animate back to 0
    final TickerFuture ticker = _sealController.animateTo(0.0);
    ticker.whenComplete(() {
      if (mounted) {
        setState(() => _sealDragProgress = 0.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final CastingState state = ref.watch(castingProvider);
    final bool canAfford = ref.watch(canAffordSinglePullProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF2A2A2A), // Concrete studio
      body: Stack(
        children: <Widget>[
          // --- Studio Environment ---
          _StudioBackground(),

          // --- Main Content ---
          SafeArea(
            child: Column(
              children: <Widget>[
                // Header
                _CastingHeader(),

                // Main casting area
                Expanded(
                  child: state.hasResult
                      ? _buildResultsView(state)
                      : _buildCastingArea(state, canAfford),
                ),

                // Controls
                _CastingControls(
                  canAffordSingle: canAfford,
                  canAffordTen: ref.watch(canAffordTenPullProvider),
                  isLoading: state.isLoading,
                  onSingleCast: () => _startCasting(isTenPull: false),
                  onTenCast: () => _startCasting(isTenPull: true),
                ),
              ],
            ),
          ),

          // --- Blinding Light Overlay (when seal breaks) ---
          if (_sealBroken)
            AnimatedBuilder(
              animation: _lightController,
              builder: (BuildContext context, Widget? child) {
                return Container(
                  color: AurelianPalette.alabaster.withValues(
                    alpha: _lightController.value * 0.95,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCastingArea(CastingState state, bool canAfford) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Wax Seal (draggable)
          if (!state.isLoading && !state.hasResult)
            GestureDetector(
              onVerticalDragUpdate: canAfford ? _onSealDragUpdate : null,
              onVerticalDragEnd: canAfford ? _onSealDragEnd : null,
              child: AnimatedBuilder(
                animation: _sealController,
                builder: (BuildContext context, Widget? child) {
                  final double progress = _sealBroken
                      ? 1.0
                      : _sealDragProgress + _sealController.value;

                  return Transform.translate(
                    offset: Offset(0.0, progress * 100),
                    child: Transform.rotate(
                      angle: progress * 0.5,
                      child: Opacity(
                        opacity: 1.0 - progress,
                        child: _WaxSeal(
                          isDragging: _isDragging,
                          canAfford: canAfford,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          if (state.isLoading)
            const CircularProgressIndicator(
              color: AurelianPalette.champagneGold,
            ),

          const SizedBox(height: 48.0),

          // Instruction text
          Text(
            canAfford ? 'DRAG SEAL DOWN TO BREAK' : 'INSUFFICIENT LUXE TOKENS',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 3.0,
              color: canAfford
                  ? AurelianPalette.champagneGold
                  : const Color(0xFFFF6666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(CastingState state) {
    final CastingResult result = state.lastResult!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Results
        if (state.isRevealing || state.hasResult)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: result.pulls.length,
              itemBuilder: (BuildContext context, int index) {
                final bool isRevealed =
                    !state.isRevealing || index < state.currentRevealIndex;

                if (!isRevealed) {
                  return const SizedBox.shrink();
                }

                return _TalentDossier(
                  result: result.pulls[index],
                  delay: index * 100,
                );
              },
            ),
          ),

        // Skip button (during reveal)
        if (state.isRevealing)
          TextButton(
            onPressed: () => ref.read(castingProvider.notifier).skipReveal(),
            child: const Text(
              'SKIP',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                color: AurelianPalette.textTertiary,
              ),
            ),
          ),

        // Reset button
        if (!state.isRevealing)
          ElevatedButton(
            onPressed: () => ref.read(castingProvider.notifier).reset(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AurelianPalette.champagneGold,
              foregroundColor: const Color(0xFF2A2A2A),
            ),
            child: const Text('CAST AGAIN'),
          ),
      ],
    );
  }

  Future<void> _startCasting({required bool isTenPull}) async {
    await ref.read(castingProvider.notifier).executePull(isTenPull: isTenPull);
  }
}

// =============================================================================
// Studio Components
// =============================================================================

class _StudioBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF3A3A3A), // Lighter concrete at top
            Color(0xFF1A1A1A), // Darker at bottom
          ],
        ),
      ),
      child: CustomPaint(
        size: Size.infinite,
        painter: _ConcreteTexturePainter(),
      ),
    );
  }
}

class _ConcreteTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF4A4A4A).withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    // Subtle concrete grain
    final math.Random random = math.Random(42); // Seeded

    for (int i = 0; i < 100; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      final double length = random.nextDouble() * 20 + 5;

      canvas.drawLine(
        Offset(x, y),
        Offset(x + length, y + random.nextDouble() * 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter CustomPainter) => false;
}

// =============================================================================
// Wax Seal Component
// =============================================================================

class _WaxSeal extends StatelessWidget {
  const _WaxSeal({
    required this.isDragging,
    required this.canAfford,
  });

  final bool isDragging;
  final bool canAfford;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120.0,
      height: 120.0,
      decoration: BoxDecoration(
        color: canAfford ? const Color(0xFFD4AF37) : const Color(0xFF666666),
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: (canAfford ? const Color(0xFFD4AF37) : Colors.black)
                .withValues(alpha: isDragging ? 0.6 : 0.3),
            blurRadius: isDragging ? 32.0 : 20.0,
            spreadRadius: isDragging ? 8.0 : 4.0,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.local_florist, // Wax seal impression
          size: 48.0,
          color: canAfford ? const Color(0xFF2A2A2A) : const Color(0xFF999999),
        ),
      ),
    );
  }
}

// =============================================================================
// Talent Dossier Component
// =============================================================================

class _TalentDossier extends StatelessWidget {
  const _TalentDossier({
    required this.result,
    required this.delay,
  });

  final PullResult result;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: AurelianPalette.alabaster,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: result.tier.tierColor,
          width: 2.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                // Tier badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: result.tier.tierColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    result.tier.displayName.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 10.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                      color: result.tier.tierColor,
                    ),
                  ),
                ),
                const Spacer(),
                // Dupe indicator
                if (result.isDupe)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      '+${result.prestigeValue} PRESTIGE',
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 9.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16.0),
            // Talent name
            Text(
              result.name.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
                color: Color(0xFF2A2A2A),
              ),
            ),
            if (result.baseHypeMultiplier != null) ...<Widget>[
              const SizedBox(height: 8.0),
              Text(
                '+${((result.baseHypeMultiplier! - 1) * 100).toStringAsFixed(0)}% HYPE',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 12.0,
                  color: result.tier.tierColor,
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay));
  }
}

// =============================================================================
// Header & Controls
// =============================================================================

class _CastingHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<int> luxeAsync = ref.watch(availableLuxeProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'THE CASTING',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 24.0,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 4.0,
                  color: AurelianPalette.ivory,
                ),
              ),
              Text(
                'ROOM',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 8.0,
                  color: AurelianPalette.champagneGold,
                ),
              ),
            ],
          ),
          // Luxe balance
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: const Color(0xFFD4AF37),
              ),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.diamond,
                  size: 16.0,
                  color: Color(0xFFD4AF37),
                ),
                const SizedBox(width: 8.0),
                Text(
                  luxeAsync.when(
                    data: (int luxe) => luxe.toString(),
                    loading: () => '...',
                    error: (_, __) => '—',
                  ),
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD4AF37),
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

class _CastingControls extends StatelessWidget {
  const _CastingControls({
    required this.canAffordSingle,
    required this.canAffordTen,
    required this.isLoading,
    required this.onSingleCast,
    required this.onTenCast,
  });

  final bool canAffordSingle;
  final bool canAffordTen;
  final bool isLoading;
  final VoidCallback onSingleCast;
  final VoidCallback onTenCast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: <Widget>[
          // Single cast
          Expanded(
            child: _CastButton(
              label: 'SINGLE CAST',
              cost: TalentTierExtension.castingCost,
              enabled: canAffordSingle && !isLoading,
              onTap: onSingleCast,
            ),
          ),
          const SizedBox(width: 16.0),
          // Ten cast
          Expanded(
            child: _CastButton(
              label: 'TEN CAST',
              cost: TalentTierExtension.castingCostTen,
              enabled: canAffordTen && !isLoading,
              onTap: onTenCast,
              isHighlighted: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _CastButton extends StatelessWidget {
  const _CastButton({
    required this.label,
    required this.cost,
    required this.enabled,
    required this.onTap,
    this.isHighlighted = false,
  });

  final String label;
  final int cost;
  final bool enabled;
  final VoidCallback onTap;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        decoration: BoxDecoration(
          color: enabled
              ? (isHighlighted
                  ? AurelianPalette.champagneGold
                  : const Color(0xFF3A3A3A))
              : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: enabled
                ? (isHighlighted
                    ? AurelianPalette.champagneGold
                    : const Color(0xFF666666))
                : const Color(0xFF444444),
          ),
        ),
        child: Column(
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
                color: enabled
                    ? (isHighlighted
                        ? const Color(0xFF2A2A2A)
                        : AurelianPalette.ivory)
                    : const Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              '$cost LUXE',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 11.0,
                color: enabled
                    ? (isHighlighted
                        ? const Color(0xFF2A2A2A)
                        : AurelianPalette.champagneGold)
                    : const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
