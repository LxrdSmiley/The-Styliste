// Directive H — Kintsugi Repair Screen
// GDD §8.9.2 — The golden repair ritual
// Kode Addendum #3: liquid_gold.frag masked to fracture lines

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/aurelian_theme.dart';
import '../../../domain/models/brand.dart';
import '../../hq/providers/hq_provider.dart';
import '../services/tarnish_calculator.dart';

/// Kintsugi Repair Ritual Screen
///
/// Visual experience:
/// - Liquid gold shader fills fractures
/// - Heavy haptics throughout
/// - "Healing" animation of cracks filling with gold
/// - Premium feel justifies 30% capital cost
class KintsugiRepairScreen extends ConsumerStatefulWidget {
  const KintsugiRepairScreen({super.key});

  @override
  ConsumerState<KintsugiRepairScreen> createState() =>
      _KintsugiRepairScreenState();
}

class _KintsugiRepairScreenState extends ConsumerState<KintsugiRepairScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fillController;
  late final AnimationController _pulseController;
  ui.FragmentShader? _shader;
  bool _isLoading = true;
  bool _isRepairing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final ui.FragmentProgram program = await ui.FragmentProgram.fromAsset(
        'lib/shaders/liquid_gold.frag',
      );
      if (!mounted) return;
      setState(() {
        _shader = program.fragmentShader();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'The liquid-gold effect is unavailable.';
      });
    }
  }

  @override
  void dispose() {
    _fillController.dispose();
    _pulseController.dispose();
    _shader?.dispose();
    super.dispose();
  }

  Future<void> _executeRepair() async {
    if (_isRepairing) return;

    setState(() => _isRepairing = true);

    // Haptic ramp-up
    await _hapticRampUp();
    if (!mounted) return;

    // Start fill animation
    unawaited(_fillController.forward());

    // Execute RPC
    try {
      final Object? response = await Supabase.instance.client.rpc<Object?>(
        SupabaseConstants.fnApplyKintsugiRepair,
      );
      final Map<String, dynamic> result;
      if (response is Map<Object?, Object?>) {
        result = Map<String, dynamic>.from(response);
      } else if (response is List &&
          response.length == 1 &&
          response.first is Map<Object?, Object?>) {
        result = Map<String, dynamic>.from(
          response.first as Map<Object?, Object?>,
        );
      } else {
        throw const FormatException('Invalid repair response.');
      }

      if (result['success'] == true) {
        final int newLevel = result['new_kintsugi_level'] as int;
        final int capitalSpent = result['capital_spent'] as int;

        // Wait for animation to complete
        await Future<void>.delayed(const Duration(milliseconds: 2500));

        if (mounted) {
          _showSuccessDialog(newLevel, capitalSpent);
        }
      } else {
        _handleError(_repairErrorMessage(result['message'] as String?));
      }
    } catch (_) {
      _handleError('Kintsugi repair is unavailable. Please try again.');
    }
  }

  void _handleError(String error) {
    if (!mounted) return;
    _fillController.stop();
    _fillController.reset();
    setState(() {
      _isRepairing = false;
      _errorMessage = error;
    });
  }

  String _repairErrorMessage(String? code) => switch (code) {
        'BRAND_NOT_FOUND' => 'Your brand profile is not ready yet.',
        'NO_TARNISH_TO_REPAIR' => 'There is no Tarnish to repair.',
        'INSUFFICIENT_PRESTIGE_TOKENS' =>
          'You need 10 Prestige Tokens for Kintsugi.',
        _ => 'Kintsugi repair is unavailable. Please try again.',
      };

  Future<void> _hapticRampUp() async {
    for (int i = 0; i < 3; i++) {
      await HapticFeedback.heavyImpact();
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }

    // Continuous vibration during repair
    for (int i = 0; i < 10; i++) {
      await HapticFeedback.vibrate();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  void _showSuccessDialog(int newLevel, int capitalSpent) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: AurelianPalette.alabaster,
        title: const Text(
          'KINTSUGI COMPLETE',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.auto_fix_high,
              size: 64.0,
              color: Color(0xFFD4AF37),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Your brand has been restored.',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                color: AurelianPalette.textSecondary,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Kintsugi Level: $newLevel',
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Capital Invested: \$$capitalSpent',
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 12.0,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Permanent gold veins now adorn your empire.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 12.0,
                fontStyle: FontStyle.italic,
                color: Color(0xFFD4AF37),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go(AppRouter.hq);
            },
            child: const Text(
              'RETURN TO HQ',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Brand> brandAsync = ref.watch(hqBrandStreamProvider);
    final double capitalCost = brandAsync.when(
      data: (Brand b) =>
          TarnishCalculator.calculateKintsugiCapitalCost(b.totalRevenue),
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );

    return Scaffold(
      backgroundColor: AurelianPalette.ivory,
      body: Stack(
        children: <Widget>[
          // --- Liquid Gold Shader Background ---
          if (_shader != null)
            AnimatedBuilder(
              animation: Listenable.merge(
                <Listenable>[_fillController, _pulseController],
              ),
              builder: (BuildContext context, Widget? child) {
                _shader!
                  ..setFloat(0, _fillController.value * 3.0) // uTime
                  ..setFloat(
                    1,
                    MediaQuery.of(context).size.width,
                  ) // uResolution.x
                  ..setFloat(
                    2,
                    MediaQuery.of(context).size.height,
                  ) // uResolution.y
                  ..setFloat(3, 0.5) // uTouch.x (center)
                  ..setFloat(4, 0.5) // uTouch.y (center)
                  ..setFloat(
                    5,
                    0.5 + _pulseController.value * 0.5,
                  ); // uCharge

                return CustomPaint(
                  size: Size.infinite,
                  painter: _ShaderPainter(shader: _shader!),
                );
              },
            )
          else if (_isLoading)
            const Center(child: CircularProgressIndicator()),

          // --- Fracture Fill Animation Overlay ---
          AnimatedBuilder(
            animation: _fillController,
            builder: (BuildContext context, Widget? child) {
              return CustomPaint(
                size: Size.infinite,
                painter: FractureFillPainter(
                  progress: _fillController.value,
                ),
              );
            },
          ),

          // --- Content ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  // Header
                  const Text(
                    'KINTSUGI REPAIR',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 28.0,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4.0,
                      color: AurelianPalette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Fill the cracks with gold',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 14.0,
                      color: AurelianPalette.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 48.0),

                  // Cost breakdown
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: AurelianPalette.alabaster,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: AurelianPalette.champagneGold,
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        _CostRow(
                          label: 'CAPITAL REQUIRED',
                          value: '\$${capitalCost.toStringAsFixed(0)}',
                          isAccent: true,
                        ),
                        const Divider(height: 16.0),
                        const _CostRow(
                          label: 'PRESTIGE TOKENS',
                          value: '10',
                        ),
                      ],
                    ),
                  ),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 32.0),

                  // Execute button
                  GestureDetector(
                    onTap: _isRepairing ? null : _executeRepair,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: <Color>[
                            Color(0xFFD4AF37),
                            Color(0xFFF7E7CE),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withValues(
                              alpha: _isRepairing ? 0.6 : 0.3,
                            ),
                            blurRadius: _isRepairing ? 32.0 : 16.0,
                            spreadRadius: _isRepairing ? 4.0 : 2.0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          if (_isRepairing)
                            const SizedBox(
                              width: 20.0,
                              height: 20.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF2A2A2A),
                                ),
                              ),
                            )
                          else
                            const Icon(
                              Icons.auto_fix_high,
                              color: Color(0xFF2A2A2A),
                            ),
                          const SizedBox(width: 12.0),
                          Text(
                            _isRepairing ? 'RESTORING...' : 'EXECUTE REPAIR',
                            style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3.0,
                              color: Color(0xFF2A2A2A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // Cancel button
                  TextButton(
                    onPressed: _isRepairing ? null : () => context.pop(),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        color: AurelianPalette.textTertiary,
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

// =============================================================================
// Supporting Widgets
// =============================================================================

class _CostRow extends StatelessWidget {
  const _CostRow({
    required this.label,
    required this.value,
    this.isAccent = false,
  });

  final String label;
  final String value;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 11.0,
            letterSpacing: 2.0,
            color: AurelianPalette.textTertiary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: isAccent
                ? const Color(0xFFD4AF37)
                : AurelianPalette.textPrimary,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Painters
// =============================================================================

class _ShaderPainter extends CustomPainter {
  _ShaderPainter({required this.shader});

  final ui.FragmentShader? shader;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0.0, 0.0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Fracture Fill Painter — Animates cracks filling with gold
class FractureFillPainter extends CustomPainter {
  FractureFillPainter({required this.progress});

  final double progress; // 0.0 → 1.0

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fracturePaint = Paint()
      ..color = const Color(0xFF6B6B6B)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final Paint goldFillPaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: progress)
      ..strokeWidth = 2.0 + progress * 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw sample fractures being filled
    final List<Offset> fractures = <Offset>[
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.8),
    ];

    for (final Offset start in fractures) {
      // Grey fracture line
      final Path fracture = Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(start.dx + 50, start.dy + 30)
        ..lineTo(start.dx + 80, start.dy + 20);

      canvas.drawPath(fracture, fracturePaint);

      // Gold fill (animated along path)
      // Simplified: draw gold segment at start
      if (progress > 0) {
        canvas.drawLine(
          start,
          Offset(
            start.dx + 50 * progress,
            start.dy + 30 * progress,
          ),
          goldFillPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
