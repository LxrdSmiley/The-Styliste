import 'package:flutter/material.dart';

import '../theme/aurelian_theme.dart';

enum ConsequenceKind { gain, loss, neutral }

class ConsequenceLine {
  const ConsequenceLine({
    required this.label,
    required this.value,
    this.kind = ConsequenceKind.neutral,
  });

  final String label;
  final String value;
  final ConsequenceKind kind;
}

/// Displays server-returned causes for a result.
/// The client renders the explanation; it does not recalculate the outcome.
class ConsequenceBreakdown extends StatelessWidget {
  const ConsequenceBreakdown({
    required this.title,
    required this.lines,
    super.key,
  });

  final String title;
  final List<ConsequenceLine> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AurelianPalette.alabaster.withValues(alpha: 0.06),
        border: Border.all(
          color: AurelianPalette.champagneGold.withValues(alpha: 0.25),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AurelianPalette.champagneGold,
              fontFamily: 'SpaceGrotesk',
              fontSize: 10.0,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 10.0),
          ...lines.map(_buildLine),
        ],
      ),
    );
  }

  Widget _buildLine(ConsequenceLine line) {
    final Color color = switch (line.kind) {
      ConsequenceKind.gain => AurelianPalette.success,
      ConsequenceKind.loss => AurelianPalette.danger,
      ConsequenceKind.neutral => AurelianPalette.textSecondary,
    };
    final String prefix = switch (line.kind) {
      ConsequenceKind.gain => '+',
      ConsequenceKind.loss => '−',
      ConsequenceKind.neutral => '•',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 18.0,
            child: Text(
              prefix,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: Text(
              line.label,
              style: const TextStyle(
                color: AurelianPalette.textSecondary,
                fontFamily: 'SpaceGrotesk',
                fontSize: 11.0,
              ),
            ),
          ),
          Text(
            line.value,
            style: TextStyle(
              color: color,
              fontFamily: 'JetBrainsMono',
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
