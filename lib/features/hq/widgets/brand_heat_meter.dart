// Directive F — Brand Heat Meter
// GDD §3.0 — "The empire's vital sign — never hidden, never collapsible"
// Kode Addendum: Use .select() optimization — only rebuild on explicit change

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/aurelian_hq_theme.dart';

/// Brand Heat Meter — Horizontal gradient bar showing brand status
/// 
/// States:
/// - 0-25 (Cold): Obsidian cracks along edges
/// - 26-50 (Cool): Grey tones
/// - 51-75 (Warm): Champagne emergence  
/// - 76-100 (Iconic): Slow gold pulse
///
/// Tap to open Brand Heat breakdown panel
class BrandHeatMeter extends StatelessWidget {
  const BrandHeatMeter({
    super.key,
    required this.heatPercent,
    this.onTap,
    this.showLabel = true,
    this.height = 24.0,
  });

  final int heatPercent;
  final VoidCallback? onTap;
  final bool showLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final BrandHeatState state = BrandHeatStateExtension.fromPercent(heatPercent);
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          gradient: AurelianHQTheme.brandHeatGradient(heatPercent / 100),
          boxShadow: state.hasPulse
              ? <BoxShadow>[
                  BoxShadow(
                    color: AurelianHQTheme.roseAccent.withValues(alpha: 0.3),
                    blurRadius: 8.0,
                    spreadRadius: 2.0,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: Stack(
            children: <Widget>[
              // Heat fill (animated width)
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                width: (MediaQuery.of(context).size.width - 48.0) * (heatPercent / 100),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      state.primaryColor.withValues(alpha: 0.3),
                      state.primaryColor,
                    ],
                  ),
                ),
              ),

              // Obsidian cracks for cold state (0-25)
              if (state.hasCracks)
                CustomPaint(
                  size: Size.infinite,
                  painter: _ObsidianCrackPainter(),
                ),

              // Iconic pulse overlay (76-100)
              if (state.hasPulse)
                _PulseOverlay(height: height),

              // Label
              if (showLabel)
                Center(
                  child: Text(
                    '$heatPercent°',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      color: heatPercent > 50
                          ? const Color(0xFF2A2A2A)
                          : Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Obsidian crack painter for cold state
class _ObsidianCrackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint crackPaint = Paint()
      ..color = AurelianHQTheme.obsidianCrack.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Hairline cracks along edges
    final List<Offset> cracks = <Offset>[
      const Offset(0.0, 0.3),
      const Offset(0.0, 0.7),
      Offset(size.width, 0.2),
      Offset(size.width, 0.8),
    ];

    for (final Offset crack in cracks) {
      final double x = crack.dx == 0.0 ? 2.0 : size.width - 2.0;
      canvas.drawLine(
        Offset(x, crack.dy * size.height),
        Offset(
          x + (crack.dx == 0.0 ? 8.0 : -8.0),
          crack.dy * size.height + (crack.dy < 0.5 ? 4.0 : -4.0),
        ),
        crackPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter) => false;
}

/// Gold pulse overlay for iconic state
class _PulseOverlay extends StatefulWidget {
  const _PulseOverlay({required this.height});

  final double height;

  @override
  State<_PulseOverlay> createState() => _PulseOverlayState();
}

class _PulseOverlayState extends State<_PulseOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (BuildContext context, Widget? child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                const Color(0xFFF7E7CE).withValues(
                  alpha: 0.2 * (1.0 - _pulseController.value),
                ),
                Colors.transparent,
                const Color(0xFFF7E7CE).withValues(
                  alpha: 0.2 * _pulseController.value,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Brand Heat breakdown panel (shown on tap)
class BrandHeatBreakdownPanel extends StatelessWidget {
  const BrandHeatBreakdownPanel({
    super.key,
    required this.heatPercent,
    required this.decayRate,
    required this.activeInputs,
  });

  final int heatPercent;
  final double decayRate;
  final List<HeatInput> activeInputs;

  @override
  Widget build(BuildContext context) {
    final BrandHeatState state = BrandHeatStateExtension.fromPercent(heatPercent);
    
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AurelianHQTheme.marbleSurface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: state.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'BRAND HEAT',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                  color: state.primaryColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: state.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  state.name.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 10.0,
                    fontWeight: FontWeight.w600,
                    color: state.primaryColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16.0),

          // Heat meter (larger version)
          BrandHeatMeter(
            heatPercent: heatPercent,
            height: 32.0,
            showLabel: false,
          ),

          const SizedBox(height: 16.0),

          // Stats
          _StatRow(label: 'Current', value: '$heatPercent°'),
          _StatRow(label: 'Decay Rate', value: '-${decayRate.toStringAsFixed(1)}/hr'),
          _StatRow(label: 'Active Inputs', value: '${activeInputs.length} sources'),

          const SizedBox(height: 12.0),

          // Input breakdown
          if (activeInputs.isNotEmpty) ...<Widget>[
            const Divider(color: Color(0xFFE8E8E8)),
            const SizedBox(height: 8.0),
            ...activeInputs.map((HeatInput input) => _InputRow(input: input)),
          ],
        ],
      ),
    );
  }
}

/// Heat input data model
class HeatInput {
  const HeatInput({
    required this.name,
    required this.contribution,
    required this.isPositive,
  });

  final String name;
  final double contribution;
  final bool isPositive;
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 10.0,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
              color: Color(0xFF888888),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2A2A2A),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({required this.input});

  final HeatInput input;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                input.isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12.0,
                color: input.isPositive
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFF44336),
              ),
              const SizedBox(width: 8.0),
              Text(
                input.name,
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 12.0,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          Text(
            '${input.isPositive ? '+' : ''}${input.contribution.toStringAsFixed(1)}°',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: input.isPositive
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFF44336),
            ),
          ),
        ],
      ),
    );
  }
}
