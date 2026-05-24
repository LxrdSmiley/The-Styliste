// Directive M: The Aurelian Storefront — Fiat Bridge
// GDD §9.8, §12.5 — Premium F2P monetization
//
// Aesthetic: Pure luxury. Deep Alabaster background.
// Typography: SpaceGrotesk headers, JetBrainsMono fiat pricing.
// The Sovereign Syndicate ($49.99): liquid_gold.frag shader backing.
// UX: Heavy haptic on success, Luxe cascade animation to treasury.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/theme/aurelian_theme.dart';
import '../../../domain/models/brand.dart';
import '../../hq/providers/hq_provider.dart';
import '../providers/iap_provider.dart';

/// The Aurelian Storefront — Premium fiat bridge
///
/// Four luxury tiers:
/// - Initiate's Cache ($0.99): Impulse buy
/// - Artisan's Reserve ($4.99): Standard top-up
/// - Architect's Vault ($9.99): 10-pull enabler
/// - Sovereign Syndicate ($49.99): Whale anchor with liquid gold shader
class AurelianStorefrontScreen extends ConsumerStatefulWidget {
  const AurelianStorefrontScreen({super.key});

  @override
  ConsumerState<AurelianStorefrontScreen> createState() =>
      _AurelianStorefrontScreenState();
}

class _AurelianStorefrontScreenState
    extends ConsumerState<AurelianStorefrontScreen> {
  int? _lastGrantedAmount;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Brand> brandAsync = ref.watch(hqBrandStreamProvider);
    final AsyncValue<List<ProductDetails>> productsAsync =
        ref.watch(iapProductsProvider);
    final IapState iapState = ref.watch(iapNotifierProvider);

    // Listen for successful purchases to trigger celebration
    ref.listen<IapState>(
      iapNotifierProvider,
      (IapState? previous, IapState next) {
        if (previous?.purchasingProductId != null &&
            next.purchasingProductId == null &&
            next.errorMessage == null) {
          _onPurchaseSuccess();
        }
        if (next.errorMessage != null) {
          _showError(next.errorMessage!);
          ref.read(iapNotifierProvider.notifier).clearError();
        }
      },
    );

    final int luxeBalance = brandAsync.maybeWhen(
      data: (Brand b) => b.luxeTokens,
      orElse: () => 0,
    );

    return Scaffold(
      backgroundColor: AurelianPalette.alabaster,
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            // ── Header ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              size: 20.0,
                              color: Color(0xFF2A2A2A),
                            ),
                          ),
                        ),
                        // Treasury display
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: AurelianPalette.champagneGold
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: AurelianPalette.champagneGold
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Text(
                                '◆ ',
                                style: TextStyle(
                                  color: AurelianPalette.champagneGold,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '$luxeBalance',
                                style: const TextStyle(
                                  fontFamily: 'JetBrainsMono',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2A2A2A),
                                ),
                              ),
                              Text(
                                ' LUXE',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2A2A2A)
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32.0),
                    const Text(
                      'THE AURELIAN\nSTOREFRONT',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 28.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3.0,
                        height: 1.2,
                        color: Color(0xFF2A2A2A),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'PREMIUM CURRENCY • FIAT BRIDGE',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 10.0,
                        letterSpacing: 3.0,
                        color: const Color(0xFF2A2A2A).withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    if (_lastGrantedAmount != null)
                      Text(
                        '+$_lastGrantedAmount LUXE GRANTED',
                        style: const TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF44AA44),
                        ),
                      ).animate().fadeIn().slideY(begin: -0.5, end: 0.0),
                  ],
                ),
              ),
            ),

            // ── Product Tiers ────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 0.0),
              sliver: productsAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFF2A2A2A),
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                ),
                error: (Object e, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'STORE UNAVAILABLE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 14.0,
                        letterSpacing: 2.0,
                        color: const Color(0xFF2A2A2A).withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                data: (List<ProductDetails> products) {
                  if (products.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'NO PRODUCTS CONFIGURED',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 14.0,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    );
                  }

                  // Sort products by tier order
                  final List<ProductDetails> sorted = _sortByTier(products);

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final ProductDetails product = sorted[index];
                        final LuxeTier tier = _getTier(product.id);
                        final bool isPurchasing =
                            iapState.purchasingProductId == product.id;
                        final bool anyPurchasing =
                            iapState.purchasingProductId != null;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _LuxeTierCard(
                            product: product,
                            tier: tier,
                            isPurchasing: isPurchasing,
                            enabled: !anyPurchasing,
                            onTap: () => ref
                                .read(iapNotifierProvider.notifier)
                                .buyProduct(product),
                          ),
                        );
                      },
                      childCount: sorted.length,
                    ),
                  );
                },
              ),
            ),

            // ── Restore purchases ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 48.0),
                child: GestureDetector(
                  onTap: () => InAppPurchase.instance.restorePurchases(),
                  child: Text(
                    'RESTORE PURCHASES',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 10.0,
                      letterSpacing: 2.0,
                      color: const Color(0xFF2A2A2A).withValues(alpha: 0.3),
                      decoration: TextDecoration.underline,
                      decorationColor:
                          const Color(0xFF2A2A2A).withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ProductDetails> _sortByTier(List<ProductDetails> products) {
    final Map<String, int> tierOrder = <String, int>{
      'initiates_cache': 0,
      'luxe_100': 0,
      'artisans_reserve': 1,
      'luxe_550': 1,
      'architects_vault': 2,
      'luxe_1200': 2,
      'sovereign_syndicate': 3,
      'luxe_2800': 3,
    };

    return products
      ..sort((ProductDetails a, ProductDetails b) {
        final int orderA = tierOrder[a.id] ?? 99;
        final int orderB = tierOrder[b.id] ?? 99;
        return orderA.compareTo(orderB);
      });
  }

  LuxeTier _getTier(String productId) {
    switch (productId) {
      case 'initiates_cache':
      case 'luxe_100':
        return LuxeTier.initiate;
      case 'artisans_reserve':
      case 'luxe_550':
        return LuxeTier.artisan;
      case 'architects_vault':
      case 'luxe_1200':
        return LuxeTier.architect;
      case 'sovereign_syndicate':
      case 'luxe_2800':
        return LuxeTier.sovereign;
      default:
        return LuxeTier.initiate;
    }
  }

  Future<void> _onPurchaseSuccess() async {
    // Sustained heavy haptic (The Golden Hour)
    for (int i = 0; i < 5; i++) {
      await HapticFeedback.heavyImpact();
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    // Show granted amount (will be updated by brand stream)
    setState(() => _lastGrantedAmount = _getLastGrantedAmount());

    // Clear after animation
    await Future<void>.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() => _lastGrantedAmount = null);
    }
  }

  int? _getLastGrantedAmount() {
    // Get from the most recent transaction - simplified
    // In production, this would read from the transaction record
    return null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: AurelianPalette.softRose,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}

// =============================================================================
// Luxe Tier Configuration
// =============================================================================

enum LuxeTier {
  initiate, // $0.99 - 100 Luxe
  artisan, // $4.99 - 550 Luxe
  architect, // $9.99 - 1200 Luxe
  sovereign, // $49.99 - 6500 Luxe
}

extension LuxeTierExtension on LuxeTier {
  String get displayName {
    switch (this) {
      case LuxeTier.initiate:
        return "THE INITIATE'S CACHE";
      case LuxeTier.artisan:
        return "THE ARTISAN'S RESERVE";
      case LuxeTier.architect:
        return "THE ARCHITECT'S VAULT";
      case LuxeTier.sovereign:
        return 'THE SOVEREIGN SYNDICATE';
    }
  }

  String get subtitle {
    switch (this) {
      case LuxeTier.initiate:
        return 'The impulse buy';
      case LuxeTier.artisan:
        return 'The standard top-up';
      case LuxeTier.architect:
        return 'The 10-pull enabler';
      case LuxeTier.sovereign:
        return 'The whale anchor';
    }
  }

  int get tokenAmount {
    switch (this) {
      case LuxeTier.initiate:
        return 100;
      case LuxeTier.artisan:
        return 550;
      case LuxeTier.architect:
        return 1200;
      case LuxeTier.sovereign:
        return 6500;
    }
  }

  Color get accentColor {
    switch (this) {
      case LuxeTier.initiate:
        return const Color(0xFFB8B8B8); // Silver
      case LuxeTier.artisan:
        return const Color(0xFFCD7F32); // Bronze
      case LuxeTier.architect:
        return AurelianPalette.champagneGold;
      case LuxeTier.sovereign:
        return const Color(0xFFD4AF37); // Deep Gold
    }
  }

  bool get hasLiquidGold => this == LuxeTier.sovereign;
}

// =============================================================================
// Luxe Tier Card
// =============================================================================

class _LuxeTierCard extends StatelessWidget {
  const _LuxeTierCard({
    required this.product,
    required this.tier,
    required this.isPurchasing,
    required this.enabled,
    required this.onTap,
  });

  final ProductDetails product;
  final LuxeTier tier;
  final bool isPurchasing;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: tier == LuxeTier.sovereign ? 180.0 : 140.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: tier.accentColor.withValues(alpha: enabled ? 0.5 : 0.2),
            width: tier == LuxeTier.sovereign ? 2.0 : 1.0,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: tier.accentColor.withValues(alpha: enabled ? 0.15 : 0.05),
              blurRadius: tier == LuxeTier.sovereign ? 24.0 : 12.0,
              spreadRadius: tier == LuxeTier.sovereign ? 4.0 : 0.0,
              offset: const Offset(0.0, 8.0),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Stack(
            children: <Widget>[
              // Liquid gold background for Sovereign tier
              if (tier.hasLiquidGold)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          const Color(0xFFFFF8E7).withValues(alpha: 0.8),
                          const Color(0xFFD4AF37).withValues(alpha: 0.2),
                          const Color(0xFFFFF8E7).withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                    child: CustomPaint(
                      painter: _LiquidGoldPainter(),
                      size: Size.infinite,
                    ),
                  ),
                ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: <Widget>[
                    // Left: Token info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // Tier name
                          Text(
                            tier.displayName,
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize:
                                  tier == LuxeTier.sovereign ? 16.0 : 13.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing:
                                  tier == LuxeTier.sovereign ? 2.0 : 1.5,
                              color: const Color(0xFF2A2A2A),
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          // Subtitle
                          Text(
                            tier.subtitle.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 9.0,
                              letterSpacing: 1.5,
                              color: const Color(0xFF2A2A2A)
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          // Token amount
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: <Widget>[
                              Text(
                                '◆ ${tier.tokenAmount}',
                                style: TextStyle(
                                  fontFamily: 'JetBrainsMono',
                                  fontSize:
                                      tier == LuxeTier.sovereign ? 32.0 : 24.0,
                                  fontWeight: FontWeight.w700,
                                  color: tier.accentColor,
                                ),
                              ),
                              const SizedBox(width: 6.0),
                              Text(
                                'LUXE',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      tier.accentColor.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Right: Price button
                    isPurchasing
                        ? SizedBox(
                            width: 24.0,
                            height: 24.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                tier.accentColor,
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: enabled
                                  ? tier.accentColor.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: tier.accentColor.withValues(
                                  alpha: enabled ? 0.5 : 0.2,
                                ),
                              ),
                            ),
                            child: Text(
                              product.price,
                              style: TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 14.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: enabled
                                    ? const Color(0xFF2A2A2A)
                                    : const Color(0xFF2A2A2A)
                                        .withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                  ],
                ),
              ),

              // Elite badge for Sovereign
              if (tier == LuxeTier.sovereign)
                Positioned(
                  top: 12.0,
                  right: 12.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Text(
                      'ELITE',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 8.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        color: Color(0xFFB8860B),
                      ),
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

// =============================================================================
// Liquid Gold Painter (Simulated shader effect)
// =============================================================================

class _LiquidGoldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          const Color(0xFFFFF8E7),
          const Color(0xFFD4AF37).withValues(alpha: 0.3),
          const Color(0xFFFFF8E7),
          const Color(0xFFD4AF37).withValues(alpha: 0.2),
        ],
        stops: const <double>[0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw flowing gold effect with bezier curves
    final Path path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.5,
      size.width * 0.5,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.7,
      size.width,
      size.height * 0.4,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Add shimmer highlights
    final Paint shimmerPaint = Paint()
      ..color = const Color(0xFFFFF8E7).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final Path shimmerPath = Path();
    shimmerPath.moveTo(size.width * 0.2, size.height);
    shimmerPath.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.8,
      size.width * 0.6,
      size.height * 0.85,
    );
    shimmerPath.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.9,
      size.width,
      size.height * 0.75,
    );
    shimmerPath.lineTo(size.width, size.height);
    shimmerPath.lineTo(size.width * 0.2, size.height);
    shimmerPath.close();

    canvas.drawPath(shimmerPath, shimmerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
