// Directive H — Tarnish Visual Degradation Overlay
// Kode Addendum #1: Seeded random for deterministic, unique fractures
// GDD §8.9.2 — Obsidian Rot: 0-20 Pristine, 21-50 Fractures, 51-99 Sludge, 100 Lockdown

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/theme/aurelian_theme.dart';
import '../../hq/theme/aurelian_hq_theme.dart';
import '../services/tarnish_calculator.dart';

/// Tarnish Overlay — Visual degradation system for HQ
/// 
/// Features:
/// - 0-20: Pure Alabaster (no overlay)
/// - 21-50: Grey hairline fractures (seeded, deterministic per player)
/// - 51-99: Obsidian sludge + desaturated gold
/// - 100: Total lockdown overlay
/// - Permanent Kintsugi gold veins (from repairs)
class TarnishOverlay extends StatelessWidget {
  const TarnishOverlay({
    super.key,
    required this.tarnishLevel,
    required this.kintsugiLevel,
    required this.playerId, // For seeded fracture generation
    required this.child,
    this.onKintsugiRequest,
    this.onApologyRequest,
  });

  final int tarnishLevel;  // 0-100
  final int kintsugiLevel; // Permanent gold veins
  final String playerId;   // Seed for deterministic fractures
  final Widget child;
  final VoidCallback? onKintsugiRequest;
  final VoidCallback? onApologyRequest;

  @override
  Widget build(BuildContext context) {
    final TarnishVisualTier tier = TarnishCalculator.getVisualTier(tarnishLevel);
    
    return Stack(
      children: <Widget>[
        // Base content
        child,
        
        // Tier 2: Hairline Fractures (21-50)
        if (tier.index >= TarnishVisualTier.fractured.index)
          CustomPaint(
            size: Size.infinite,
            painter: HairlineFracturePainter(
              seed: playerId,
              density: (tarnishLevel - 20) / 30, // 0.0 → 1.0
              opacity: 0.3 + (tarnishLevel - 20) * 0.01,
            ),
          ),
        
        // Tier 3: Obsidian Sludge (51-99)
        if (tier.index >= TarnishVisualTier.obsidian.index)
          _ObsidianSludgeLayer(
            intensity: (tarnishLevel - 50) / 50, // 0.0 → 1.0
          ),
        
        // Permanent Kintsugi Gold Veins (from repairs)
        if (kintsugiLevel > 0)
          CustomPaint(
            size: Size.infinite,
            painter: KintsugiVeinPainter(
              seed: playerId,
              level: kintsugiLevel,
            ),
          ),
        
        // Tier 4: Total Lockdown (100)
        if (tier == TarnishVisualTier.lockdown)
          _LockdownOverlay(
            onKintsugi: onKintsugiRequest,
            onApology: onApologyRequest,
          ),
      ],
    );
  }
}

// =============================================================================
// Hairline Fracture Painter — Seeded, Deterministic
// =============================================================================

class HairlineFracturePainter extends CustomPainter {
  HairlineFracturePainter({
    required this.seed,
    required this.density,
    required this.opacity,
  });

  final String seed;
  final double density;  // 0.0 to 1.0
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final math.Random random = math.Random(seed.hashCode);
    final Paint paint = Paint()
      ..color = const Color(0xFF6B6B6B).withValues(alpha: opacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    // Number of fractures based on density
    final int fractureCount = (5 + density * 15).toInt();
    
    for (int i = 0; i < fractureCount; i++) {
      final double startX = random.nextDouble() * size.width;
      final double startY = random.nextDouble() * size.height;
      
      // Jagged line with 2-4 segments
      final int segments = 2 + random.nextInt(3);
      final Path path = Path();
      path.moveTo(startX, startY);
      
      double currentX = startX;
      double currentY = startY;
      
      for (int j = 0; j < segments; j++) {
        // Random direction and length
        final double angle = random.nextDouble() * math.pi * 2;
        final double length = 20 + random.nextDouble() * 60;
        
        currentX += math.cos(angle) * length;
        currentY += math.sin(angle) * length;
        
        path.lineTo(currentX, currentY);
      }
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// Obsidian Sludge Layer — Desaturates gold accents
// =============================================================================

class _ObsidianSludgeLayer extends StatelessWidget {
  const _ObsidianSludgeLayer({required this.intensity});

  final double intensity; // 0.0 to 1.0

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A1A).withValues(alpha: intensity * 0.4),
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(<double>[
          // Desaturate: reduce color channels
          0.8 - intensity * 0.2, 0.1, 0.1, 0, 0,
          0.1, 0.8 - intensity * 0.2, 0.1, 0, 0,
          0.1, 0.1, 0.8 - intensity * 0.2, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: const SizedBox.expand(),
      ),
    );
  }
}

// =============================================================================
// Kintsugi Vein Painter — Permanent Gold Scars
// =============================================================================

class KintsugiVeinPainter extends CustomPainter {
  KintsugiVeinPainter({
    required this.seed,
    required this.level,
  });

  final String seed;
  final int level; // Kintsugi level (number of repairs)

  @override
  void paint(Canvas canvas, Size size) {
    final math.Random random = math.Random(seed.hashCode + level);
    
    final Paint paint = Paint()
      ..color = const Color(0xFFD4AF37) // Deep gold
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Veins radiate from repaired fractures
    // Each repair adds 2-3 gold veins
    final int veinCount = level * 2 + random.nextInt(3);
    
    for (int i = 0; i < veinCount; i++) {
      final double centerX = random.nextDouble() * size.width;
      final double centerY = random.nextDouble() * size.height;
      
      // Draw branching gold vein
      _drawGoldVein(
        canvas,
        Offset(centerX, centerY),
        paint,
        random,
        depth: 2 + (level ~/ 3), // Deeper branching at higher levels
      );
    }
  }
  
  void _drawGoldVein(
    Canvas canvas,
    Offset start,
    Paint paint,
    math.Random random,
    {required int depth}
  ) {
    if (depth <= 0) return;
    
    final double angle = random.nextDouble() * math.pi * 2;
    final double length = 30 + random.nextDouble() * 50;
    
    final Offset end = Offset(
      start.dx + math.cos(angle) * length,
      start.dy + math.sin(angle) * length,
    );
    
    // Draw main vein
    canvas.drawLine(start, end, paint);
    
    // Draw smaller branches
    if (depth > 1) {
      final int branches = 1 + random.nextInt(2);
      for (int i = 0; i < branches; i++) {
        final double branchAngle = angle + (random.nextDouble() - 0.5) * math.pi / 2;
        final double branchLength = length * 0.5;
        final Offset branchEnd = Offset(
          end.dx + math.cos(branchAngle) * branchLength,
          end.dy + math.sin(branchAngle) * branchLength,
        );
        
        final Paint branchPaint = paint..strokeWidth = 1.0;
        canvas.drawLine(end, branchEnd, branchPaint);
        
        // Recursive branches
        _drawGoldVein(canvas, branchEnd, branchPaint, random, depth: depth - 1);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// Lockdown Overlay — Absolute halt (Kode Addendum #2)
// =============================================================================

class _LockdownOverlay extends StatelessWidget {
  const _LockdownOverlay({
    this.onKintsugi,
    this.onApology,
  });

  final VoidCallback? onKintsugi;
  final VoidCallback? onApology;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0A0A).withValues(alpha: 0.95),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Warning icon
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3333).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFF3333),
                    width: 2.0,
                  ),
                ),
                child: const Icon(
                  Icons.block,
                  size: 40.0,
                  color: Color(0xFFFF3333),
                ),
              ),
              
              const SizedBox(height: 32.0),
              
              // Title
              Text(
                'BRAND LOCKDOWN',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4.0,
                  color: const Color(0xFFFF3333),
                ),
              ),
              
              const SizedBox(height: 16.0),
              
              // Message
              Text(
                'Your reputation has suffered critical damage. '
                'All passive income generation has been halted. '
                'Immediate action is required to restore operations.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 14.0,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              
              const SizedBox(height: 48.0),
              
              // Kintsugi button (full repair)
              GestureDetector(
                onTap: onKintsugi,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                        blurRadius: 16.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: const Column(
                    children: <Widget>[
                      Text(
                        'EXECUTE KINTSUGI',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3.0,
                          color: Color(0xFF0A0A0A),
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        '30% Capital + 10 Prestige Tokens',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 11.0,
                          color: Color(0xFF0A0A0A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16.0),
              
              // Apology button (partial repair)
              GestureDetector(
                onTap: onApology,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Column(
                    children: <Widget>[
                      Text(
                        'ISSUE PUBLIC APOLOGY',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.0,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        '10% Capital • Reduces Tarnish by 30',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 10.0,
                          color: Colors.white70,
                        ),
                      ),
                    ],
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
