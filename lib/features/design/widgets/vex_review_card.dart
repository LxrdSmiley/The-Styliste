// GDD v6 — Vex AI Critic: Review Card UI
// Aurelian Standard: Editorial "snap" animation, Champagne Gold seal for Sovereign
// Alabaster palette with delicate borders and soft expansive shadow

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/aurelian_theme.dart';
import '../models/vex_review.dart';

/// The Vex Review Card — editorial critique overlay
///
/// Displays procedural review with:
/// - Ivory container with champagne gold 1px border
/// - Soft expansive shadow
/// - "VEX CRITIQUE" header in SpaceGrotesk ultra-light
/// - Headline in bold editorial style
/// - Body in JetBrainsMono (AI/calculated aesthetic)
/// - Rotating Sovereign Seal (top-right, only for Sovereign verdict)
class VexReviewCard extends StatelessWidget {
  const VexReviewCard({
    required this.review,
    super.key,
    this.onDismiss,
    this.onShare,
  });

  final VexReview review;
  final VoidCallback? onDismiss;
  final VoidCallback? onShare;

  static const Duration _staggerDelay = Duration(milliseconds: 100);
  static const Duration _animationDuration = Duration(milliseconds: 600);

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const <Effect<dynamic>>[
        FadeEffect(
          begin: 0.0,
          end: 1.0,
          duration: _animationDuration,
          curve: Curves.easeOut,
        ),
        ScaleEffect(
          begin: Offset(0.95, 0.95),
          end: Offset(1.0, 1.0),
          duration: _animationDuration,
          curve: Curves.easeOutBack,
        ),
      ],
      child: Container(
        margin: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: AurelianPalette.ivory,
          border: Border.all(
            color: AurelianPalette.champagneGold,
          ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AurelianPalette.champagneGold.withValues(alpha: 0.15),
              blurRadius: 24.0,
              spreadRadius: 4.0,
              offset: const Offset(0.0, 8.0),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Stack(
            children: <Widget>[
              // Main content
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // --- VEX CRITIQUE Header ---
                    _buildHeader()
                        .animate(delay: _staggerDelay)
                        .fadeIn(duration: const Duration(milliseconds: 400))
                        .slideX(
                          begin: -0.1,
                          end: 0.0,
                          duration: const Duration(milliseconds: 400),
                        ),

                    const SizedBox(height: 24.0),

                    // --- Verdict Badge ---
                    _buildVerdictBadge()
                        .animate(delay: _staggerDelay * 2)
                        .fadeIn(duration: const Duration(milliseconds: 400))
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.0, 1.0),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutBack,
                        ),

                    const SizedBox(height: 20.0),

                    // --- Headline ---
                    _buildHeadline()
                        .animate(delay: _staggerDelay * 3)
                        .fadeIn(duration: const Duration(milliseconds: 400))
                        .slideY(
                          begin: 0.2,
                          end: 0.0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                        ),

                    const SizedBox(height: 16.0),

                    // --- Divider ---
                    Divider(
                      color:
                          AurelianPalette.champagneGold.withValues(alpha: 0.3),
                      thickness: 1.0,
                    )
                        .animate(delay: _staggerDelay * 4)
                        .fadeIn(duration: const Duration(milliseconds: 300))
                        .scaleX(
                          begin: 0.0,
                          end: 1.0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                        ),

                    const SizedBox(height: 16.0),

                    // --- Body Text ---
                    _buildBody()
                        .animate(delay: _staggerDelay * 5)
                        .fadeIn(duration: const Duration(milliseconds: 400))
                        .slideY(
                          begin: 0.1,
                          end: 0.0,
                          duration: const Duration(milliseconds: 400),
                        ),

                    const SizedBox(height: 24.0),

                    // --- Hype Score Footer ---
                    _buildHypeFooter()
                        .animate(delay: _staggerDelay * 6)
                        .fadeIn(duration: const Duration(milliseconds: 400)),

                    const SizedBox(height: 24.0),

                    // --- Action Buttons ---
                    _buildActions()
                        .animate(delay: _staggerDelay * 7)
                        .fadeIn(duration: const Duration(milliseconds: 400))
                        .slideY(
                          begin: 0.2,
                          end: 0.0,
                          duration: const Duration(milliseconds: 400),
                        ),
                  ],
                ),
              ),

              // --- Sovereign Seal (top-right, only for sovereign verdict) ---
              if (review.verdict.showsSovereignSeal)
                Positioned(
                  top: 16.0,
                  right: 16.0,
                  child: _SovereignSeal()
                      .animate()
                      .rotate(
                        begin: 0.0,
                        end: 1.0,
                        duration: const Duration(seconds: 20),
                      )
                      .fadeIn(duration: const Duration(milliseconds: 800))
                      .slideX(
                        begin: 1.0,
                        end: 0.0,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutBack,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Component Builders ---

  Widget _buildHeader() {
    return Row(
      children: <Widget>[
        Container(
          width: 4.0,
          height: 24.0,
          color: AurelianPalette.champagneGold,
        ),
        const SizedBox(width: 12.0),
        const Text(
          'VEX CRITIQUE',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 10.0,
            fontWeight: FontWeight.w300,
            color: AurelianPalette.textTertiary,
            letterSpacing: 4.0,
          ),
        ),
      ],
    );
  }

  Widget _buildVerdictBadge() {
    final Color badgeColor = switch (review.verdict) {
      VexVerdict.tarnished => const Color(0xFF8B4513),
      VexVerdict.derivative => AurelianPalette.textSecondary,
      VexVerdict.visionary => AurelianPalette.champagneGold,
      VexVerdict.sovereign => const Color(0xFFD4AF37),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        review.verdict.displayName,
        style: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
          color: badgeColor,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildHeadline() {
    return Text(
      review.headline,
      style: const TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
        color: AurelianPalette.textPrimary,
        height: 1.3,
      ),
    );
  }

  Widget _buildBody() {
    return Text(
      review.body,
      style: const TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: AurelianPalette.textSecondary,
        height: 1.6,
      ),
    );
  }

  Widget _buildHypeFooter() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AurelianPalette.ivoryDark,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'HYPE SCORE',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 10.0,
                  fontWeight: FontWeight.w500,
                  color: AurelianPalette.textTertiary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                review.hypeScoreFormatted,
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                  color: AurelianPalette.champagneGold,
                ),
              ),
            ],
          ),
          if (review.referencesTsunami)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: AurelianPalette.champagneGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text(
                '${review.matchingTsunamiTag} ${review.multiplierDisplay}',
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: AurelianPalette.champagneGold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        if (onShare != null)
          TextButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share, size: 18.0),
            label: const Text('SHARE'),
            style: TextButton.styleFrom(
              foregroundColor: AurelianPalette.textSecondary,
            ),
          ),
        const SizedBox(width: 16.0),
        ElevatedButton(
          onPressed: onDismiss,
          style: ElevatedButton.styleFrom(
            backgroundColor: AurelianPalette.champagneGold,
            foregroundColor: AurelianPalette.textPrimary,
            elevation: 0.0,
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          ),
          child: const Text(
            'ACCEPT',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}

/// Rotating geometric seal for Sovereign verdicts
class _SovereignSeal extends StatefulWidget {
  @override
  State<_SovereignSeal> createState() => _SovereignSealState();
}

class _SovereignSealState extends State<_SovereignSeal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Transform.rotate(
          angle: _controller.value * 2.0 * 3.14159,
          child: CustomPaint(
            size: const Size(48.0, 48.0),
            painter: _SealPainter(),
          ),
        );
      },
    );
  }
}

class _SealPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AurelianPalette.champagneGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final Paint fillPaint = Paint()
      ..color = AurelianPalette.champagneGold.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 4.0;

    // Outer circle
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius - 4.0, fillPaint);

    // Inner geometric pattern (octagon)
    final Path octagon = Path();
    for (int i = 0; i < 8; i++) {
      final double angle = (i * 45.0) * 3.14159 / 180.0;
      final double x = center.dx + (radius - 12.0) * cos(angle);
      final double y = center.dy + (radius - 12.0) * sin(angle);
      if (i == 0) {
        octagon.moveTo(x, y);
      } else {
        octagon.lineTo(x, y);
      }
    }
    octagon.close();
    canvas.drawPath(octagon, paint);

    // Center dot
    canvas.drawCircle(
      center,
      3.0,
      Paint()..color = AurelianPalette.champagneGold,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
