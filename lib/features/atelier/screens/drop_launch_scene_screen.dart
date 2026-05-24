import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../design/models/vex_review.dart';
import '../models/drop_launch_payload.dart';

class DropLaunchSceneScreen extends StatefulWidget {
  const DropLaunchSceneScreen({
    required this.payload,
    super.key,
  });

  final DropLaunchPayload payload;

  @override
  State<DropLaunchSceneScreen> createState() => _DropLaunchSceneScreenState();
}

class _DropLaunchSceneScreenState extends State<DropLaunchSceneScreen> {
  late final _DropLaunchGame _game;
  bool _canContinue = false;

  @override
  void initState() {
    super.initState();
    _game = _DropLaunchGame(
      designName: widget.payload.design.name,
      hypeScore: widget.payload.hypeScore,
    );

    HapticFeedback.heavyImpact();

    Future<void>.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      setState(() => _canContinue = true);
      HapticFeedback.mediumImpact();
    });
  }

  @override
  void dispose() {
    _game.pauseEngine();
    super.dispose();
  }

  void _enterFeed() {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String verdict = _verdictLabel(widget.payload.review);
    HapticFeedback.selectionClick();
    context.go(AppRouter.feed);
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: AppColors.obsidianCard,
        content: Text(
          '${widget.payload.hypeScore.toStringAsFixed(1)} HYPE CONFIRMED · $verdict',
          style: const TextStyle(color: AppColors.ivory),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String verdict = _verdictLabel(widget.payload.review);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: GameWidget<_DropLaunchGame>(game: _game),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 28.0),
              child: Column(
                children: <Widget>[
                  const Text(
                    'DROP LAUNCHED',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4.0,
                    ),
                  ),
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: _canContinue ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: _LaunchSummaryPanel(
                      designName: widget.payload.design.name,
                      hypeScore: widget.payload.hypeScore,
                      verdict: verdict,
                      onEnterFeed: _canContinue ? _enterFeed : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _verdictLabel(VexReview? review) {
    return switch (review?.verdict) {
      VexVerdict.tarnished => 'TARNISHED',
      VexVerdict.derivative => 'DERIVATIVE',
      VexVerdict.visionary => 'VISIONARY',
      VexVerdict.sovereign => 'SOVEREIGN',
      null => 'LIVE DROP',
    };
  }
}

class _LaunchSummaryPanel extends StatelessWidget {
  const _LaunchSummaryPanel({
    required this.designName,
    required this.hypeScore,
    required this.verdict,
    required this.onEnterFeed,
  });

  final String designName;
  final double hypeScore;
  final String verdict;
  final VoidCallback? onEnterFeed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppColors.obsidianCard.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.45),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.16),
            blurRadius: 28.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            designName.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.ivory,
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            '${hypeScore.toStringAsFixed(1)} HYPE',
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 28.0,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            verdict,
            style: TextStyle(
              color: AppColors.ivory.withValues(alpha: 0.58),
              fontSize: 10.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.0,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'MARKET REACTION LIVE ON GLOBAL FEED',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.ivory.withValues(alpha: 0.42),
              fontSize: 9.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 18.0),
          SizedBox(
            width: double.infinity,
            height: 48.0,
            child: OutlinedButton(
              onPressed: onEnterFeed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gold,
                side: const BorderSide(color: AppColors.gold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: const Text(
                'ENTER GLOBAL FEED',
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropLaunchGame extends FlameGame<World> {
  _DropLaunchGame({
    required this.designName,
    required this.hypeScore,
  });

  final String designName;
  final double hypeScore;

  double _elapsed = 0.0;

  @override
  Color backgroundColor() => AppColors.obsidian;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final Size viewport = Size(size.x, size.y);
    final Offset center = Offset(viewport.width / 2.0, viewport.height * 0.42);
    final double launchProgress = (_elapsed / 2.2).clamp(0.0, 1.0);
    final double pulse = (sin(_elapsed * pi * 2.0) + 1.0) / 2.0;

    _drawBackground(canvas, viewport);
    _drawPulseRings(canvas, center, launchProgress, pulse);
    _drawGarmentCard(canvas, center, launchProgress);
    _drawConfetti(canvas, viewport, center, launchProgress);
    _drawTexts(canvas, center, launchProgress);
  }

  void _drawBackground(Canvas canvas, Size viewport) {
    final Rect rect = Offset.zero & viewport;
    final Paint paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          AppColors.obsidian,
          AppColors.obsidianSurface,
          AppColors.obsidian,
        ],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  void _drawPulseRings(
    Canvas canvas,
    Offset center,
    double launchProgress,
    double pulse,
  ) {
    final Paint ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.gold.withValues(alpha: 0.16 + (pulse * 0.1));

    for (int i = 0; i < 4; i++) {
      final double radius = 42.0 + (i * 38.0) + (launchProgress * 90.0);
      canvas.drawCircle(center, radius, ringPaint);
    }

    final Paint corePaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.18 + pulse * 0.08);
    canvas.drawCircle(center, 78.0 + pulse * 8.0, corePaint);
  }

  void _drawGarmentCard(
    Canvas canvas,
    Offset center,
    double launchProgress,
  ) {
    final double lift = Curves.easeOutCubic.transform(launchProgress) * 42.0;
    final Rect cardRect = Rect.fromCenter(
      center: center.translate(0.0, -lift),
      width: 138.0,
      height: 188.0,
    );

    final RRect card = RRect.fromRectAndRadius(
      cardRect,
      const Radius.circular(16.0),
    );

    final Paint cardPaint = Paint()
      ..color = AppColors.ivory.withValues(alpha: 0.94);
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.gold;

    canvas.drawRRect(card, cardPaint);
    canvas.drawRRect(card, borderPaint);

    final Path silhouette = Path()
      ..moveTo(center.dx, cardRect.top + 34.0)
      ..quadraticBezierTo(
        cardRect.left + 24.0,
        cardRect.top + 70.0,
        cardRect.left + 36.0,
        cardRect.bottom - 30.0,
      )
      ..quadraticBezierTo(
        center.dx,
        cardRect.bottom - 8.0,
        cardRect.right - 36.0,
        cardRect.bottom - 30.0,
      )
      ..quadraticBezierTo(
        cardRect.right - 24.0,
        cardRect.top + 70.0,
        center.dx,
        cardRect.top + 34.0,
      )
      ..close();

    final Paint silhouettePaint = Paint()
      ..color = AppColors.obsidian.withValues(alpha: 0.9);
    canvas.drawPath(silhouette, silhouettePaint);

    final Paint goldLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.gold.withValues(alpha: 0.8);
    canvas.drawLine(
      Offset(center.dx, cardRect.top + 42.0),
      Offset(center.dx, cardRect.bottom - 24.0),
      goldLine,
    );
  }

  void _drawConfetti(
    Canvas canvas,
    Size viewport,
    Offset center,
    double launchProgress,
  ) {
    final Paint paint = Paint();

    for (int i = 0; i < 42; i++) {
      final double angle = (i / 42.0) * pi * 2.0;
      final double speed = 76.0 + ((i % 7) * 18.0);
      final double drift = launchProgress * speed;
      final Offset pos = Offset(
        center.dx + cos(angle) * drift,
        center.dy + sin(angle) * drift + (sin(_elapsed * 2.0 + i) * 8.0),
      );

      final double alpha = (1.0 - launchProgress).clamp(0.0, 1.0);
      paint.color = (i.isEven ? AppColors.gold : AppColors.ivory).withValues(
        alpha: alpha * 0.72,
      );

      canvas.drawCircle(pos, 2.0 + (i % 3), paint);
    }
  }

  void _drawTexts(
    Canvas canvas,
    Offset center,
    double launchProgress,
  ) {
    _drawCenteredText(
      canvas,
      hypeScore.toStringAsFixed(1),
      center.translate(0.0, 142.0),
      TextStyle(
        color: AppColors.gold.withValues(alpha: launchProgress),
        fontSize: 42.0,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.0,
      ),
    );

    _drawCenteredText(
      canvas,
      'HYPE SCORE',
      center.translate(0.0, 184.0),
      TextStyle(
        color: AppColors.ivory.withValues(alpha: launchProgress * 0.55),
        fontSize: 10.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 3.0,
      ),
    );
  }

  void _drawCenteredText(
    Canvas canvas,
    String text,
    Offset center,
    TextStyle style,
  ) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.x - 40.0);

    painter.paint(
      canvas,
      center - Offset(painter.width / 2.0, painter.height / 2.0),
    );
  }
}
