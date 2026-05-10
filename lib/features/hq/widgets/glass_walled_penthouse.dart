// Directive F — Glass-Walled Penthouse Background
// Parallax-enabled golden hour environment with sensor-driven depth
// GDD §3.0 — "The HQ visually ascends as Brand Rank increases"
// Directive H: Integrated with TarnishOverlay for Crisis Engine

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../crisis/widgets/tarnish_overlay.dart';
import '../theme/aurelian_hq_theme.dart';

/// Glass-Walled Penthouse background with parallax depth
/// 
/// Features:
/// - Sensor-driven parallax (or simulated slow pan if sensors unavailable)
/// - Rank-based window size and floor height
/// - Ivory marble with champagne-gold sunlight
/// - Glass reflections and depth layers
/// - Directive H: Integrated tarnish degradation overlay
class GlassWalledPenthouse extends StatefulWidget {
  const GlassWalledPenthouse({
    super.key,
    required this.rank,
    required this.child,
    this.playerId,
    this.tarnishLevel = 0,
    this.kintsugiLevel = 0,
    this.onKintsugiRequest,
    this.onApologyRequest,
  });

  final int rank;
  final Widget child;
  final String? playerId;      // For seeded fracture generation
  final int tarnishLevel;      // 0-100
  final int kintsugiLevel;     // Permanent gold veins
  final VoidCallback? onKintsugiRequest;
  final VoidCallback? onApologyRequest;

  @override
  State<GlassWalledPenthouse> createState() => _GlassWalledPenthouseState();
}

class _GlassWalledPenthouseState extends State<GlassWalledPenthouse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _parallaxController;
  double _parallaxX = 0.0;
  double _parallaxY = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Simulated parallax animation (120 second cycle)
    _parallaxController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..repeat();
    
    _parallaxController.addListener(_updateParallax);
    
    // Attempt to get real accelerometer data
    _initSensors();
  }
  
  void _initSensors() {
    // AI_UNCERTAINTY: accelerometer package not confirmed in pubspec
    // Falling back to simulated parallax via AnimationController
    // If sensors available, replace with: accelerometerEvents.listen(...)
  }
  
  void _updateParallax() {
    // Gentle sine wave motion (simulated window view shift)
    final double time = _parallaxController.value * 2 * math.pi;
    setState(() {
      _parallaxX = math.sin(time) * 0.02; // ±2% horizontal shift
      _parallaxY = math.cos(time * 0.7) * 0.01; // ±1% vertical shift
    });
  }

  @override
  void dispose() {
    _parallaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MaterialTier tier = AurelianHQTheme.materialTier(widget.rank);
    final double windowScale = AurelianHQTheme.windowScale(widget.rank);
    
    return Container(
      decoration: const BoxDecoration(
        gradient: AurelianHQTheme.penthouseGradient,
      ),
      child: Stack(
        children: <Widget>[
          // --- Layer 1: Skyline (deepest, most parallax) ---
          _SkylineLayer(
            parallaxX: _parallaxX * 2.0,
            parallaxY: _parallaxY * 2.0,
          ),
          
          // --- Layer 2: Window frames ---
          _WindowFrameLayer(
            parallaxX: _parallaxX,
            parallaxY: _parallaxY,
            scale: windowScale,
          ),
          
          // --- Layer 3: Sunlight streaming through ---
          _SunlightLayer(
            parallaxX: _parallaxX * 0.5,
            parallaxY: _parallaxY * 0.5,
          ),
          
          // --- Layer 4: Marble surface reflections ---
          _MarbleReflectionLayer(tier: tier),
          
          // --- Layer 5: Floor number indicator ---
          Positioned(
            top: 60.0,
            right: 24.0,
            child: Text(
              AurelianHQTheme.floorLabel(widget.rank),
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 48.0,
                fontWeight: FontWeight.w100,
                color: const Color(0xFFE8D4B8).withValues(alpha: 0.3),
              ),
            ),
          ),
          
          // --- Content layer with Tarnish Overlay (Directive H) ---
          TarnishOverlay(
            tarnishLevel: widget.tarnishLevel,
            kintsugiLevel: widget.kintsugiLevel,
            playerId: widget.playerId ?? 'default',
            onKintsugiRequest: widget.onKintsugiRequest,
            onApologyRequest: widget.onApologyRequest,
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

/// Deep skyline layer with heavy parallax
class _SkylineLayer extends StatelessWidget {
  const _SkylineLayer({
    required this.parallaxX,
    required this.parallaxY,
  });

  final double parallaxX;
  final double parallaxY;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(
        parallaxX * MediaQuery.of(context).size.width,
        parallaxY * MediaQuery.of(context).size.height,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              const Color(0xFFE8E8E8), // Distant buildings
              const Color(0xFFF0F0F0).withValues(alpha: 0.5),
              Colors.transparent,
            ],
          ),
        ),
        child: CustomPaint(
          size: Size.infinite,
          painter: _SkylinePainter(),
        ),
      ),
    );
  }
}

/// Window frame layer with medium parallax
class _WindowFrameLayer extends StatelessWidget {
  const _WindowFrameLayer({
    required this.parallaxX,
    required this.parallaxY,
    required this.scale,
  });

  final double parallaxX;
  final double parallaxY;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(
        parallaxX * MediaQuery.of(context).size.width * 0.5,
        parallaxY * MediaQuery.of(context).size.height * 0.5,
      ),
      child: Transform.scale(
        scale: scale,
        child: CustomPaint(
          size: Size.infinite,
          painter: _WindowFramePainter(),
        ),
      ),
    );
  }
}

/// Sunlight streaming through windows
class _SunlightLayer extends StatelessWidget {
  const _SunlightLayer({
    required this.parallaxX,
    required this.parallaxY,
  });

  final double parallaxX;
  final double parallaxY;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(
        parallaxX * MediaQuery.of(context).size.width * 0.3,
        parallaxY * MediaQuery.of(context).size.height * 0.3,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: AurelianHQTheme.sunlightGradient,
        ),
      ),
    );
  }
}

/// Marble surface with reflections
class _MarbleReflectionLayer extends StatelessWidget {
  const _MarbleReflectionLayer({required this.tier});

  final MaterialTier tier;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0.0,
      left: 0.0,
      right: 0.0,
      height: 120.0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: <Color>[
              tier.surfaceColor,
              tier.surfaceColor.withValues(alpha: 0.0),
            ],
          ),
        ),
        child: CustomPaint(
          size: Size.infinite,
          painter: _MarbleTexturePainter(),
        ),
      ),
    );
  }
}

/// Painter for stylized skyline silhouette
class _SkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFD0D0D0)
      ..style = PaintingStyle.fill;
    
    // Simple stylized building silhouettes
    final Path path = Path()
      ..moveTo(0.0, size.height)
      ..lineTo(0.0, size.height * 0.6)
      ..lineTo(size.width * 0.1, size.height * 0.6)
      ..lineTo(size.width * 0.1, size.height * 0.4)
      ..lineTo(size.width * 0.25, size.height * 0.4)
      ..lineTo(size.width * 0.25, size.height * 0.5)
      ..lineTo(size.width * 0.4, size.height * 0.5)
      ..lineTo(size.width * 0.4, size.height * 0.3)
      ..lineTo(size.width * 0.6, size.height * 0.3)
      ..lineTo(size.width * 0.6, size.height * 0.55)
      ..lineTo(size.width * 0.75, size.height * 0.55)
      ..lineTo(size.width * 0.75, size.height * 0.45)
      ..lineTo(size.width * 0.9, size.height * 0.45)
      ..lineTo(size.width * 0.9, size.height * 0.65)
      ..lineTo(size.width, size.height * 0.65)
      ..lineTo(size.width, size.height);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for minimalist window frames
class _WindowFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint framePaint = Paint()
      ..color = const Color(0x40FFFFFF) // 25% white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    // Main window frame (floor-to-ceiling)
    final Rect windowRect = Rect.fromLTWH(
      size.width * 0.05,
      size.height * 0.1,
      size.width * 0.9,
      size.height * 0.6,
    );
    
    canvas.drawRect(windowRect, framePaint);
    
    // Window mullions (dividers)
    final Paint mullionPaint = Paint()
      ..color = const Color(0x30FFFFFF)
      ..strokeWidth = 1.0;
    
    // Vertical mullion
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.1),
      Offset(size.width * 0.5, size.height * 0.7),
      mullionPaint,
    );
    
    // Horizontal mullion
    canvas.drawLine(
      Offset(size.width * 0.05, size.height * 0.4),
      Offset(size.width * 0.95, size.height * 0.4),
      mullionPaint,
    );
    
    // Glass reflection hint
    final Paint glassPaint = Paint()
      ..color = const Color(0x08F7E7CE) // 3% champagne
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(windowRect, glassPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter) => false;
}

/// Painter for subtle marble texture
class _MarbleTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint veinPaint = Paint()
      ..color = const Color(0x15E8D4B8) // 8% champagne
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    // Subtle marble veins
    final Path path = Path()
      ..moveTo(0.0, size.height * 0.5)
      ..cubicTo(
        size.width * 0.3, size.height * 0.3,
        size.width * 0.6, size.height * 0.7,
        size.width, size.height * 0.4,
      );
    
    canvas.drawPath(path, veinPaint);
    
    // Second vein
    final Path path2 = Path()
      ..moveTo(size.width * 0.2, size.height)
      ..cubicTo(
        size.width * 0.4, size.height * 0.6,
        size.width * 0.7, size.height * 0.8,
        size.width * 0.9, 0.0,
      );
    
    canvas.drawPath(path2, veinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter) => false;
}
