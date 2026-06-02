// First Alpha Drop loop: cosmetic Flame launch scene only.
// executeDrop() remains the authoritative Supabase write path.

import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../feed/providers/feed_provider.dart';

class DropLaunchSceneScreen extends ConsumerStatefulWidget {
  const DropLaunchSceneScreen({super.key});

  @override
  ConsumerState<DropLaunchSceneScreen> createState() =>
      _DropLaunchSceneScreenState();
}

class _DropLaunchSceneScreenState extends ConsumerState<DropLaunchSceneScreen> {
  late final _DropLaunchGame _game;

  @override
  void initState() {
    super.initState();
    final PendingAlphaDrop? pending = ref.read(pendingAlphaDropProvider);
    _game = _DropLaunchGame(
      fabricColor: _hexToColor(pending?.fabricColorHex ?? 'FAF7F0'),
      hypeScore: pending?.hypeScore ?? 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final PendingAlphaDrop? pending = ref.watch(pendingAlphaDropProvider);
    final String designName = pending?.designName ?? 'Alpha Drop';
    final double hypeScore = pending?.hypeScore ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          GameWidget<_DropLaunchGame>(game: _game),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  AppColors.obsidian.withValues(alpha: 0.08),
                  AppColors.obsidian.withValues(alpha: 0.22),
                  AppColors.obsidian.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22.0, 28.0, 22.0, 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _SceneBadge(),
                  const Spacer(),
                  Text(
                    designName.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.ivory,
                      fontSize: 36.0,
                      fontWeight: FontWeight.w900,
                      height: 0.96,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: <Widget>[
                      const _LaunchMetric(
                        label: 'ALPHA DROP',
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 8.0),
                      _LaunchMetric(
                        label: '${hypeScore.toStringAsFixed(1)} HYPE',
                        color: AppColors.lime,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18.0),
                  if (pending != null) _DropResultPanel(drop: pending),
                  const SizedBox(height: 22.0),
                  SizedBox(
                    width: double.infinity,
                    height: 54.0,
                    child: ElevatedButton(
                      onPressed: () => context.go('/feed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.obsidian,
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'ENTER GLOBAL FEED',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
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
}

class _DropResultPanel extends StatelessWidget {
  const _DropResultPanel({required this.drop});

  final PendingAlphaDrop drop;

  @override
  Widget build(BuildContext context) {
    final List<_ResultMetric> metrics = <_ResultMetric>[
      if ((drop.followersDelta ?? 0) > 0)
        _ResultMetric('+${drop.followersDelta} FOLLOWERS'),
      if ((drop.brandHeatDelta ?? 0) > 0)
        _ResultMetric('+${drop.brandHeatDelta} BRAND HEAT'),
      if ((drop.xpDelta ?? 0) > 0) _ResultMetric('+${drop.xpDelta} XP'),
      if ((drop.rankProgressDelta ?? 0.0) > 0.0)
        _ResultMetric(
          '+${drop.rankProgressDelta!.toStringAsFixed(1)}% RANK PROGRESS',
        ),
      if ((drop.idleRevenueDelta ?? 0.0) > 0.0)
        _ResultMetric(
          '+${drop.idleRevenueDelta!.toStringAsFixed(0)}/HR IDLE',
        ),
    ];
    final String? vexLine = _firstText(<String?>[
      drop.vexQuote,
      drop.vexHeadline,
      drop.vexVerdict,
    ]);
    final String? nextObjective = _firstText(<String?>[drop.nextObjective]);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.obsidian.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      drop.marketReaction?.toUpperCase() ?? 'MARKET REACTION',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 10.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '${drop.hypeScore.toStringAsFixed(1)} HYPE',
                      style: const TextStyle(
                        color: AppColors.ivory,
                        fontSize: 28.0,
                        fontWeight: FontWeight.w900,
                        height: 0.95,
                      ),
                    ),
                  ],
                ),
              ),
              if (metrics.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: metrics
                      .take(3)
                      .map(
                        (_ResultMetric metric) => Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Text(
                            metric.label,
                            style: const TextStyle(
                              color: AppColors.lime,
                              fontSize: 10.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
            ],
          ),
          if (vexLine != null) ...<Widget>[
            const SizedBox(height: 10.0),
            Text(
              'VEX: $vexLine',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.ivory.withValues(alpha: 0.72),
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
          if (nextObjective != null) ...<Widget>[
            const SizedBox(height: 8.0),
            Text(
              'NEXT: $nextObjective',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.gold.withValues(alpha: 0.86),
                fontSize: 11.0,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultMetric {
  const _ResultMetric(this.label);

  final String label;
}

class _SceneBadge extends StatelessWidget {
  const _SceneBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.obsidian.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.42)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.auto_awesome, color: AppColors.gold, size: 16.0),
          SizedBox(width: 8.0),
          Text(
            'DROP LAUNCH',
            style: TextStyle(
              color: AppColors.ivory,
              fontSize: 10.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _LaunchMetric extends StatelessWidget {
  const _LaunchMetric({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: color.withValues(alpha: 0.42)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.3,
        ),
      ),
    );
  }
}

class _DropLaunchGame extends FlameGame<World> {
  _DropLaunchGame({
    required this.fabricColor,
    required this.hypeScore,
  });

  final Color fabricColor;
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
    final Size canvasSize = Size(size.x, size.y);
    if (canvasSize.isEmpty) return;

    final Rect bounds = Offset.zero & canvasSize;
    final Paint backdrop = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 1.1,
        colors: <Color>[
          fabricColor.withValues(alpha: 0.28),
          AppColors.obsidianSurface,
          AppColors.obsidian,
        ],
      ).createShader(bounds);
    canvas.drawRect(bounds, backdrop);

    final Offset center = Offset(canvasSize.width / 2, canvasSize.height * 0.4);
    final double pulse = (math.sin(_elapsed * 2.4) + 1.0) / 2.0;
    final double glowAlpha = hypeScore >= 80.0 ? 0.32 : 0.16;
    final Paint glow = Paint()
      ..color = AppColors.gold.withValues(alpha: glowAlpha + pulse * 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 36.0);
    canvas.drawCircle(center, canvasSize.width * (0.22 + pulse * 0.03), glow);

    final Paint ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.gold.withValues(alpha: 0.42);
    for (int index = 0; index < 4; index += 1) {
      final double radius = canvasSize.width * (0.16 + index * 0.07) +
          math.sin(_elapsed * 1.8 + index) * 5.0;
      canvas.drawCircle(center, radius, ringPaint);
    }

    final Path silhouette = Path()
      ..moveTo(center.dx - 54.0, center.dy - 112.0)
      ..cubicTo(
        center.dx - 120.0,
        center.dy - 62.0,
        center.dx - 86.0,
        center.dy + 112.0,
        center.dx,
        center.dy + 158.0,
      )
      ..cubicTo(
        center.dx + 86.0,
        center.dy + 112.0,
        center.dx + 120.0,
        center.dy - 62.0,
        center.dx + 54.0,
        center.dy - 112.0,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy - 68.0,
        center.dx - 54.0,
        center.dy - 112.0,
      )
      ..close();
    final Paint fabric = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          fabricColor,
          Color.lerp(fabricColor, AppColors.obsidian, 0.36) ?? fabricColor,
          AppColors.gold.withValues(alpha: 0.72),
        ],
      ).createShader(silhouette.getBounds());
    canvas.drawPath(silhouette, fabric);

    final Paint edge = Paint()
      ..color = AppColors.ivory.withValues(alpha: 0.48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(silhouette, edge);

    final Paint particle = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.58)
      ..style = PaintingStyle.fill;
    for (int index = 0; index < 28; index += 1) {
      final double orbit = _elapsed * 0.65 + index * 0.7;
      final double radius = canvasSize.width * (0.18 + (index % 6) * 0.025);
      canvas.drawCircle(
        Offset(
          center.dx + math.cos(orbit) * radius,
          center.dy + math.sin(orbit * 1.2) * radius * 1.3,
        ),
        index.isEven ? 1.6 : 1.0,
        particle,
      );
    }
  }
}

String? _firstText(List<String?> values) {
  for (final String? value in values) {
    if (value != null && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}

Color _hexToColor(String hex) {
  try {
    final String clean = hex.replaceAll('#', '').padLeft(6, '0');
    return Color(int.parse('FF$clean', radix: 16));
  } catch (_) {
    return AppColors.ivory;
  }
}
