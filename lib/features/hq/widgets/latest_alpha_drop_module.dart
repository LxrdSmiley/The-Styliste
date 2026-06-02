import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/hq_provider.dart';

class LatestAlphaDropModule extends ConsumerWidget {
  const LatestAlphaDropModule({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<LatestAlphaDropSummary?> latestAsync =
        ref.watch(latestAlphaDropProvider);

    return latestAsync.maybeWhen(
      data: (LatestAlphaDropSummary? drop) {
        if (drop == null) return const SizedBox.shrink();
        return _LatestAlphaDropCard(drop: drop);
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _LatestAlphaDropCard extends StatelessWidget {
  const _LatestAlphaDropCard({required this.drop});

  final LatestAlphaDropSummary drop;

  @override
  Widget build(BuildContext context) {
    final List<String> metrics = <String>[
      if ((drop.followersDelta ?? 0) > 0) '+${drop.followersDelta} followers',
      if ((drop.brandHeatDelta ?? 0) > 0) '+${drop.brandHeatDelta} heat',
      if ((drop.xpDelta ?? 0) > 0) '+${drop.xpDelta} XP',
      if ((drop.rankProgressDelta ?? 0.0) > 0.0)
        '+${drop.rankProgressDelta!.toStringAsFixed(1)}% rank',
    ];
    final String? nextMove = _firstText(<String?>[drop.nextObjective]);
    final String? vexLine = _firstText(<String?>[
      drop.vexQuote,
      drop.vexHeadline,
      drop.vexVerdict,
    ]);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F0),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFFE8D4B8).withValues(alpha: 0.48),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFFF7E7CE).withValues(alpha: 0.18),
            blurRadius: 16.0,
            offset: const Offset(0.0, 8.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'LATEST ALPHA DROP',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 10.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.4,
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      drop.designName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Color(0xFF2A2A2A),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Market reaction: ${drop.marketReaction ?? 'Live'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              Text(
                '${drop.hypeScore.toStringAsFixed(1)} HYPE',
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB8944D),
                ),
              ),
            ],
          ),
          if (metrics.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: metrics
                  .map((String metric) => _MetricPill(label: metric))
                  .toList(growable: false),
            ),
          ],
          if (vexLine != null) ...<Widget>[
            const SizedBox(height: 12.0),
            Text(
              'Vex: $vexLine',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                height: 1.3,
                color: Color(0xFF2A2A2A),
              ),
            ),
          ],
          if (nextMove != null) ...<Widget>[
            const SizedBox(height: 10.0),
            Text(
              'Next move: $nextMove',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                height: 1.25,
                color: Color(0xFF4C4336),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF7E7CE).withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(999.0),
        border: Border.all(color: const Color(0xFFE8D4B8)),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 9.0,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
          color: Color(0xFF2A2A2A),
        ),
      ),
    );
  }
}

String? _firstText(List<String?> values) {
  for (final String? value in values) {
    if (value != null && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}
