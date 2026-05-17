// Directive O — Equity Screen
// GDD §5.7 — Mogul Path: Corporate warfare dashboard
// Stock price, market share, hostile takeover launcher

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/aurelian_theme.dart';
import '../../../domain/models/brand.dart';
import '../../hq/providers/hq_provider.dart';
import '../providers/equity_provider.dart';

/// Equity Screen — Corporate warfare dashboard
/// Stock price (Hype * 1.5), market share ring chart, takeover button
class EquityScreen extends ConsumerWidget {
  const EquityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Brand> brandAsync = ref.watch(hqBrandStreamProvider);
    final EquityState equityState = ref.watch(equityProvider);

    return Scaffold(
      backgroundColor: AurelianPalette.textPrimary,
      appBar: AppBar(
        backgroundColor: AurelianPalette.textPrimary,
        foregroundColor: AurelianPalette.ivory,
        title: const Text(
          'EQUITY CONTROL',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: brandAsync.when(
        data: (Brand brand) => _EquityContent(
          brand: brand,
          equityState: equityState,
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AurelianPalette.champagneGold,
          ),
        ),
        error: (Object error, StackTrace stackTrace) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: AurelianPalette.danger),
          ),
        ),
      ),
    );
  }
}

class _EquityContent extends StatelessWidget {
  const _EquityContent({
    required this.brand,
    required this.equityState,
  });

  final Brand brand;
  final EquityState equityState;

  double get _stockPrice => brand.hypeScore * 1.5;
  double get _marketShare => math.min(brand.totalRevenue / 1000000, 100); // Mock calculation

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 20),

        // Stock Price Ticker
        Container(
          padding: const EdgeInsets.all(24.0),
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: AurelianPalette.champagneGold.withValues(alpha: 0.1),
            border: Border.all(
              color: AurelianPalette.champagneGold,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: <Widget>[
              const Text(
                'STOCK PRICE',
                style: TextStyle(
                  color: AurelianPalette.ivory,
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '\$${_stockPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AurelianPalette.champagneGold,
                      fontFamily: 'JetBrainsMono',
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AurelianPalette.success.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '+2.4%',
                      style: TextStyle(
                        color: AurelianPalette.success,
                        fontFamily: 'JetBrainsMono',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'BASED ON HYPE SCORE × 1.5',
                style: TextStyle(
                  color: AurelianPalette.textTertiary,
                  fontFamily: 'JetBrainsMono',
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Market Share Ring Chart
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: <Widget>[
              // Ring chart
              Expanded(
                child: CustomPaint(
                  size: const Size(180, 180),
                  painter: _MarketShareRingPainter(
                    playerShare: _marketShare,
                  ),
                ),
              ),
              // Legend
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _LegendItem(
                      color: AurelianPalette.champagneGold,
                      label: 'YOUR SHARE',
                      value: '${_marketShare.toStringAsFixed(1)}%',
                    ),
                    const SizedBox(height: 12),
                    _LegendItem(
                      color: AurelianPalette.danger,
                      label: 'COMPETITION',
                      value: '${(100 - _marketShare).toStringAsFixed(1)}%',
                    ),
                    const SizedBox(height: 12),
                    _LegendItem(
                      color: AurelianPalette.ivory.withValues(alpha: 0.3),
                      label: 'TOTAL MARKET',
                      value: '◆ 1.2M',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Divider
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          height: 1,
          color: AurelianPalette.ivory.withValues(alpha: 0.1),
        ),

        const SizedBox(height: 24),

        // Hostile Takeover Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                context.push(AppRouter.crisisKintsugi); // Navigate to mini-game
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AurelianPalette.danger.withValues(alpha: 0.2),
                foregroundColor: AurelianPalette.danger,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(
                    color: AurelianPalette.danger,
                    width: 2,
                  ),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.bolt),
                  SizedBox(width: 8),
                  Text(
                    'LAUNCH HOSTILE TAKEOVER',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Takeover info
        const Text(
          'WIN = +5000 CAPITAL • 30 SEC TUG-OF-WAR',
          style: TextStyle(
            color: AurelianPalette.textTertiary,
            fontFamily: 'JetBrainsMono',
            fontSize: 10,
          ),
        ),

        const Spacer(),

        // Mini-games list
        Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AurelianPalette.ivory.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'TACTICAL MINI-GAMES',
                style: TextStyle(
                  color: AurelianPalette.champagneGold,
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 12),
              _MiniGameItem(
                icon: Icons.trending_up,
                label: 'Hostile Takeover',
                reward: '+5000 Capital',
              ),
              _MiniGameItem(
                icon: Icons.price_change,
                label: 'Price War Blitz',
                reward: 'Idle +35%',
              ),
              _MiniGameItem(
                icon: Icons.local_shipping,
                label: 'Supplier Raid',
                reward: 'Logistics -15%',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Market share ring chart painter
class _MarketShareRingPainter extends CustomPainter {
  const _MarketShareRingPainter({required this.playerShare});

  final double playerShare;

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = math.min(centerX, centerY) - 10;
    const double strokeWidth = 20;

    // Background circle (competition)
    final Paint competitionPaint = Paint()
      ..color = AurelianPalette.danger.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(
      Offset(centerX, centerY),
      radius,
      competitionPaint,
    );

    // Player share arc
    final double sweepAngle = (playerShare / 100) * 2 * math.pi;
    final Paint playerPaint = Paint()
      ..color = AurelianPalette.champagneGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      -math.pi / 2, // Start at top
      sweepAngle,
      false,
      playerPaint,
    );

    // Center text
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '${playerShare.toStringAsFixed(0)}%',
        style: const TextStyle(
          color: AurelianPalette.champagneGold,
          fontFamily: 'JetBrainsMono',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        centerX - textPainter.width / 2,
        centerY - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Legend item for the ring chart
class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(
                color: AurelianPalette.textTertiary,
                fontFamily: 'SpaceGrotesk',
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontFamily: 'JetBrainsMono',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Mini-game list item
class _MiniGameItem extends StatelessWidget {
  const _MiniGameItem({
    required this.icon,
    required this.label,
    required this.reward,
  });

  final IconData icon;
  final String label;
  final String reward;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: <Widget>[
          Icon(icon, color: AurelianPalette.ivory, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AurelianPalette.ivory,
                fontFamily: 'SpaceGrotesk',
                fontSize: 12,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AurelianPalette.champagneGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              reward,
              style: const TextStyle(
                color: AurelianPalette.champagneGold,
                fontFamily: 'JetBrainsMono',
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
