// Directive L — Buffer Stock Monitor
// GDD §12.1.2 — Replaces Cash Flow Ribbon with warehouse capacity display
// 
// The Golden Hour HQ Integration:
// - Flowing (0-99%): Champagne gold progress bar
// - Halted (100%): Flashing SoftRose with liquidation prompt
// - Heavy haptic on liquidation tap
// - Gold drain animation on conversion

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/aurelian_theme.dart';
import '../models/supply_chain_models.dart';
import '../providers/supply_chain_provider.dart';

/// Buffer Stock Monitor — Warehouse capacity display with liquidation trigger
/// 
/// States:
/// - Flowing: Champagne gold bar, ticking inventory value
/// - Halted (100%): Flashing SoftRose, "SUPPLY CHAIN HALTED"
/// 
/// Interaction: Tap to liquidate when full. Heavy haptic feedback.
class BufferStockMonitor extends ConsumerStatefulWidget {
  const BufferStockMonitor({super.key});

  @override
  ConsumerState<BufferStockMonitor> createState() => _BufferStockMonitorState();
}

class _BufferStockMonitorState extends ConsumerState<BufferStockMonitor>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  bool _isLiquidating = false;
  int? _lastLiquidatedAmount;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<SupplyChainState> stateAsync = ref.watch(supplyChainProvider);
    final AsyncValue<LiquidationResult?> liquidationAsync = ref.watch(liquidationProvider);

    // Handle liquidation result
    liquidationAsync.whenOrNull(
      data: (LiquidationResult? result) {
        if (result != null && result.isSuccessful && mounted) {
          _lastLiquidatedAmount = result.liquidatedAmount;
          // Reset after showing animation
          Timer(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() => _lastLiquidatedAmount = null);
              ref.read(liquidationProvider.notifier).reset();
            }
          });
        }
      },
    );

    return stateAsync.when(
      data: (SupplyChainState state) {
        final bool isHalted = state.needsLiquidation;

        // Flashing animation when halted
        if (isHalted && !_flashController.isAnimating) {
          _flashController.repeat(reverse: true);
        } else if (!isHalted && _flashController.isAnimating) {
          _flashController.stop();
          _flashController.reset();
        }

        return GestureDetector(
          onTap: isHalted ? _triggerLiquidation : null,
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isHalted
                    ? <Color>[
                        AurelianPalette.softRose.withValues(alpha: 0.2),
                        AurelianPalette.softRose.withValues(alpha: 0.05),
                      ]
                    : <Color>[
                        const Color(0xFFF7E7CE),
                        const Color(0xFFE8D4B8),
                      ],
              ),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: isHalted
                    ? AurelianPalette.softRose
                    : const Color(0xFFE8D4B8),
                width: isHalted ? 2.0 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.warehouse,
                          size: 20.0,
                          color: isHalted ? AurelianPalette.softRose : const Color(0xFF2A2A2A),
                        ),
                        const SizedBox(width: 12.0),
                        Text(
                          'BUFFER STOCK',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.0,
                            color: isHalted ? AurelianPalette.softRose : const Color(0xFF2A2A2A),
                          ),
                        ),
                      ],
                    ),
                    // Status badge
                    _buildStatusBadge(state),
                  ],
                ),

                const SizedBox(height: 16.0),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: LinearProgressIndicator(
                    value: state.fillPercent.clamp(0.0, 100.0) / 100.0,
                    minHeight: 8.0,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isHalted
                          ? AurelianPalette.softRose
                          : AurelianPalette.champagneGold,
                    ),
                  ),
                ),

                const SizedBox(height: 12.0),

                // Values row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // Inventory value
                    AnimatedBuilder(
                      animation: _flashController,
                      builder: (BuildContext context, Widget? child) {
                        return Opacity(
                          opacity: isHalted
                              ? 0.7 + (_flashController.value * 0.3)
                              : 1.0,
                          child: Text(
                            '\$${state.currentInventoryValue}',
                            style: const TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 22.0,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2A2A2A),
                            ),
                          ),
                        );
                      },
                    ),

                    // Percentage
                    Text(
                      '${state.formattedFillPercent}',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: isHalted
                            ? AurelianPalette.softRose
                            : const Color(0xFF2A2A2A).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),

                // Halted message
                if (isHalted) ...<Widget>[
                  const SizedBox(height: 12.0),
                  AnimatedBuilder(
                    animation: _flashController,
                    builder: (BuildContext context, Widget? child) {
                      return Opacity(
                        opacity: 0.5 + (_flashController.value * 0.5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: AurelianPalette.softRose.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.warning_amber,
                                size: 16.0,
                                color: AurelianPalette.softRose,
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                'TAP TO LIQUIDATE',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                  color: AurelianPalette.softRose,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],

                // Liquidation success animation
                if (_lastLiquidatedAmount != null) ...<Widget>[
                  const SizedBox(height: 12.0),
                  Text(
                    '+\$$_lastLiquidatedAmount CAPITAL GAINED',
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF44AA44),
                    ),
                  ).animate().slideY(
                    begin: 1.0,
                    end: 0.0,
                    duration: 300.ms,
                  ).fadeIn(),
                ],

                // Loading state
                if (_isLiquidating) ...<Widget>[
                  const SizedBox(height: 12.0),
                  const Center(
                    child: SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => _buildSkeleton(),
      error: (Object error, StackTrace _) => _buildError(error),
    );
  }

  Widget _buildStatusBadge(SupplyChainState state) {
    final bool isHalted = state.needsLiquidation;
    final Color badgeColor = isHalted
        ? AurelianPalette.softRose
        : state.fillPercent >= 75.0
            ? const Color(0xFFFFAA00)
            : AurelianPalette.champagneGold;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        state.statusText,
        style: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 9.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF7E7CE).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: const SizedBox(
        height: 80.0,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
          ),
        ),
      ),
    );
  }

  Widget _buildError(Object error) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AurelianPalette.softRose.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AurelianPalette.softRose),
      ),
      child: Text(
        'SUPPLY CHAIN ERROR',
        style: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 12.0,
          color: AurelianPalette.softRose,
        ),
      ),
    );
  }

  Future<void> _triggerLiquidation() async {
    if (_isLiquidating) return;

    // Heavy haptic feedback (The Golden Hour)
    await HapticFeedback.heavyImpact();

    setState(() => _isLiquidating = true);

    await ref.read(liquidationProvider.notifier).liquidate();

    if (mounted) {
      setState(() => _isLiquidating = false);
    }
  }
}
