// Directive J — Gala Runway Screen
// GDD §6.9, §12.3.3 — The Void of Radiance
//
// Aesthetic: Vantablack (#000000) background, blinding Alabaster spotlight
// Interaction: Vertical TikTok-style swipe with escalating haptic voting
// Memory: Only current/next/previous 3D controllers active (120fps)

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/aurelian_theme.dart';
import '../../talent/models/talent.dart';
import '../models/gala_models.dart';
import '../providers/gala_provider.dart';
import '../services/gala_scoring_engine.dart';

/// Gala Runway — Void of Radiance
///
/// The player swipes through submissions in a vertical TikTok-style feed.
/// Each submission shows a 3D garment with optional Gilded Ripple (Sovereign talent).
/// Voting console at bottom with 4 tiers and escalating haptics.
class GalaRunwayScreen extends ConsumerStatefulWidget {
  const GalaRunwayScreen({super.key});

  @override
  ConsumerState<GalaRunwayScreen> createState() => _GalaRunwayScreenState();
}

class _GalaRunwayScreenState extends ConsumerState<GalaRunwayScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadFeed();
  }

  void _loadFeed() {
    final AsyncValue<GalaEvent?> galaAsync = ref.read(currentGalaProvider);
    galaAsync.whenOrNull(
      data: (GalaEvent? gala) {
        if (gala != null) {
          ref.read(galaFeedProvider.notifier).loadFeed(gala.id);
        }
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    ref.read(galaFeedProvider.notifier).setCurrentIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final GalaFeedState feedState = ref.watch(galaFeedProvider);
    final AsyncValue<GalaEvent?> galaAsync = ref.watch(currentGalaProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Vantablack
      body: Stack(
        children: <Widget>[
          // --- Main feed ---
          _buildFeed(feedState),

          // --- Top gradient (status bar blend) ---
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            height: 100.0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // --- Header ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildHeader(galaAsync),
            ),
          ),

          // --- Voting console ---
          if (feedState.submissions.isNotEmpty)
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: _VotingConsole(
                submission: _currentIndex < feedState.submissions.length
                    ? feedState.submissions[_currentIndex]
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeed(GalaFeedState feedState) {
    if (feedState.isLoading && feedState.submissions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AurelianPalette.champagneGold,
        ),
      );
    }

    if (feedState.submissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.style_outlined,
              size: 64.0,
              color: AurelianPalette.champagneGold.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16.0),
            Text(
              'NO SUBMISSIONS YET',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 14.0,
                letterSpacing: 3.0,
                color: AurelianPalette.ivory.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return PageView.builder(
      scrollDirection: Axis.vertical,
      controller: _pageController,
      itemCount: feedState.submissions.length,
      onPageChanged: _onPageChanged,
      itemBuilder: (BuildContext context, int index) {
        final GalaSubmission submission = feedState.submissions[index];
        final bool isActive = feedState.isIndexActive(index);

        return _RunwayCard(
          submission: submission,
          isActive: isActive,
        );
      },
    );
  }

  Widget _buildHeader(AsyncValue<GalaEvent?> galaAsync) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Back button
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 20.0,
            ),
          ),
        ),

        // Theme title
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: galaAsync.when(
              data: (GalaEvent? gala) {
                if (gala == null) return const SizedBox.shrink();
                return Column(
                  children: <Widget>[
                    Text(
                      gala.themeTitle.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3.0,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      gala.formattedTimeRemaining,
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 10.0,
                        color: AurelianPalette.champagneGold,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Runway Card — Individual submission display
// =============================================================================

class _RunwayCard extends StatelessWidget {
  const _RunwayCard({
    required this.submission,
    required this.isActive,
  });

  final GalaSubmission submission;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final bool hasGildedRipple = submission.hasSovereignTalent;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // --- Blinding top-down spotlight ---
        Positioned.fill(
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return RadialGradient(
                center: Alignment.topCenter,
                radius: 0.8,
                colors: <Color>[
                  AurelianPalette.alabaster
                      .withValues(alpha: hasGildedRipple ? 0.6 : 0.3),
                  Colors.transparent,
                ],
                stops: const <double>[0.0, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcOver,
            child: Container(
              color: Colors.black,
            ),
          ),
        ),

        // --- Submitted design display ---
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Gilded Ripple aura (if Sovereign talent)
              if (hasGildedRipple)
                Container(
                  width: 280.0,
                  height: 400.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        AurelianPalette.champagneGold.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

              Container(
                width: 240.0,
                height: 360.0,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: hasGildedRipple
                        ? AurelianPalette.champagneGold
                        : Colors.white.withValues(alpha: 0.2),
                    width: hasGildedRipple ? 2.0 : 1.0,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: submission.designImageUrl == null
                    ? Center(
                        child: Icon(
                          Icons.checkroom,
                          size: 64.0,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      )
                    : Image.network(
                        submission.designImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) =>
                            Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 56.0,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),

        // --- Submission info (left side) ---
        Positioned(
          left: 16.0,
          bottom: 140.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Player name
              Text(
                submission.playerName?.toUpperCase() ?? 'DESIGNER',
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8.0),
              // Design name
              Text(
                submission.designName ?? 'Untitled Design',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 12.0,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16.0),
              // Score
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.favorite,
                    size: 14.0,
                    color: Color(0xFFFF6B6B),
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    submission.formattedScore,
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              // Talent badge (if assigned)
              if (submission.talent != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: submission.talent!.tier.tierColor
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    'FEAT. ${submission.talent!.name.toUpperCase()}',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 9.0,
                      letterSpacing: 1.0,
                      color: submission.talent!.tier.tierColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Voting Console — 4-tier voting with escalating haptics
// =============================================================================

class _VotingConsole extends ConsumerWidget {
  const _VotingConsole({this.submission});

  final GalaSubmission? submission;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final VoteCastingState castState = ref.watch(voteCastingProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: <Color>[
            Colors.black.withValues(alpha: 0.95),
            Colors.transparent,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 32.0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Points explosion animation (when vote cast)
            if (castState.lastResult?.success ?? false)
              _PointsExplosion(points: castState.lastResult!.finalPoints),

            const SizedBox(height: 16.0),

            Semantics(
              container: true,
              liveRegion: true,
              label: 'Gala judging is temporarily unavailable.',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.72),
                  border: Border.all(
                    color: AurelianPalette.champagneGold.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'JUDGING PAUSED',
                      style: TextStyle(
                        color: AurelianPalette.champagneGold,
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      kGalaVotingUnavailableMessage,
                      style: TextStyle(
                        color: AurelianPalette.textSecondary,
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 14.0,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16.0),

            // Retain the tier hierarchy as disabled context; no paid scoring
            // action can be sent while the formula is quarantined.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: VoteTier.values.map((VoteTier tier) {
                return _VoteButton(
                  tier: tier,
                  onTap: null,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.tier,
    this.onTap,
  });

  final VoteTier tier;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Icon button
          Container(
            width: 64.0,
            height: 64.0,
            decoration: BoxDecoration(
              color: onTap != null
                  ? tier.tierColor.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: onTap != null
                    ? tier.tierColor
                    : Colors.white.withValues(alpha: 0.1),
                width: 2.0,
              ),
            ),
            child: Center(
              child: _getTierIcon(tier, onTap != null),
            ),
          ),
          const SizedBox(height: 8.0),
          // Label
          Text(
            tier.displayName,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 10.0,
              letterSpacing: 1.5,
              color: onTap != null
                  ? tier.tierColor
                  : Colors.white.withValues(alpha: 0.3),
            ),
          ),
          // Luxe cost indicator (only for Timeless)
          if (tier == VoteTier.timeless)
            Text(
              '10 LUXE',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 8.0,
                color: onTap != null
                    ? const Color(0xFFD4AF37)
                    : Colors.white.withValues(alpha: 0.3),
              ),
            ),
        ],
      ),
    );
  }

  Widget _getTierIcon(VoteTier tier, bool isEnabled) {
    final Color color =
        isEnabled ? tier.tierColor : Colors.white.withValues(alpha: 0.3);
    final double size = switch (tier) {
      VoteTier.adore => 24.0,
      VoteTier.iconic => 28.0,
      VoteTier.sovereign => 32.0,
      VoteTier.timeless => 36.0,
    };

    return Icon(
      switch (tier) {
        VoteTier.adore => Icons.favorite,
        VoteTier.iconic => Icons.star,
        VoteTier.sovereign => Icons.emoji_events,
        VoteTier.timeless => Icons.diamond,
      },
      color: color,
      size: size,
    );
  }
}

// =============================================================================
// Points Explosion Animation
// =============================================================================

class _PointsExplosion extends StatelessWidget {
  const _PointsExplosion({required this.points});

  final double points;

  @override
  Widget build(BuildContext context) {
    return Text(
      GalaScoringEngine.formatPoints(points),
      style: const TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 48.0,
        fontWeight: FontWeight.w700,
        color: AurelianPalette.champagneGold,
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.2, 1.2),
          duration: 200.ms,
        )
        .then()
        .scale(
          end: const Offset(1.0, 1.0),
          duration: 100.ms,
        )
        .moveY(begin: 0.0, end: -50.0, duration: 500.ms)
        .fadeOut(duration: 500.ms);
  }
}
