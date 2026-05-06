// GDD §9.8 — The Vault: Luxe Token cosmetic shop (Phase 9).
// Gold/Obsidian palette — premium hard currency purchase UX.
// Live luxe_tokens balance from hqBrandStreamProvider (Realtime reconciliation).
// IAP flow: IapNotifier.buyProduct → validate-iap Edge Function → token grant.
// Error SnackBar via ref.listen; spinner on purchasing card.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/models/brand.dart';
import '../../../features/hq/providers/hq_provider.dart';
import '../providers/iap_provider.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Brand> brandAsync = ref.watch(hqBrandStreamProvider);
    final AsyncValue<List<ProductDetails>> productsAsync =
        ref.watch(iapProductsProvider);
    final IapState iapState = ref.watch(iapNotifierProvider);

    // Error SnackBar
    ref.listen<IapState>(
      iapNotifierProvider,
      (IapState? prev, IapState next) {
        if (next.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                next.errorMessage!,
                style: const TextStyle(color: AppColors.ivory, letterSpacing: 1.5),
              ),
              backgroundColor: AppColors.obsidianCard,
            ),
          );
          ref.read(iapNotifierProvider.notifier).clearError();
        }
      },
    );

    final int luxeBalance = brandAsync.maybeWhen(
      data: (Brand b) => b.luxeTokens,
      orElse: () => 0,
    );

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            // ── Header ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        const Text(
                          'THE VAULT',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 13.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4.0,
                          ),
                        ),
                        const Spacer(),
                        // Live balance chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.1),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Text(
                                '◆ ',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 9.0,
                                ),
                              ),
                              Text(
                                '$luxeBalance LT',
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'GDD §9.8 — HARD CURRENCY',
                      style: TextStyle(
                        color: AppColors.ivory.withValues(alpha: 0.25),
                        fontSize: 8.0,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      'LUXE TOKEN PACKS',
                      style: TextStyle(
                        color: AppColors.ivory.withValues(alpha: 0.5),
                        fontSize: 9.0,
                        letterSpacing: 3.0,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                  ],
                ),
              ),
            ),

            // ── Product packs ────────────────────────────────────────────
            productsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                    child: SizedBox(
                      width: 16.0,
                      height: 16.0,
                      child: CircularProgressIndicator(
                        color: AppColors.gold,
                        strokeWidth: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
              error: (Object e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'STORE UNAVAILABLE',
                    style: TextStyle(
                      color: AppColors.ivory.withValues(alpha: 0.3),
                      fontSize: 11.0,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
              data: (List<ProductDetails> products) {
                if (products.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0.0),
                      child: Text(
                        'NO PRODUCTS AVAILABLE',
                        style: TextStyle(
                          color: AppColors.ivory.withValues(alpha: 0.3),
                          fontSize: 11.0,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 32.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final ProductDetails product = products[index];
                        final bool isPurchasing =
                            iapState.purchasingProductId == product.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: _LuxePackCard(
                            product: product,
                            grantAmount: kLuxeGrants[product.id] ?? 0,
                            isPurchasing: isPurchasing,
                            anyPurchasing: iapState.purchasingProductId != null,
                            onTap: () => ref
                                .read(iapNotifierProvider.notifier)
                                .buyProduct(product),
                          ),
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                );
              },
            ),

            // ── Restore purchases ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 48.0),
                child: GestureDetector(
                  onTap: () => InAppPurchase.instance.restorePurchases(),
                  child: Text(
                    'RESTORE PURCHASES',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.ivory.withValues(alpha: 0.2),
                      fontSize: 9.0,
                      letterSpacing: 2.0,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.ivory.withValues(alpha: 0.15),
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
}

// ---------------------------------------------------------------------------
// Luxe Token pack card — Gold gradient border, token count, price.
// ---------------------------------------------------------------------------
class _LuxePackCard extends StatelessWidget {
  const _LuxePackCard({
    required this.product,
    required this.grantAmount,
    required this.isPurchasing,
    required this.anyPurchasing,
    required this.onTap,
  });

  final ProductDetails product;
  final int grantAmount;
  final bool isPurchasing;
  final bool anyPurchasing;
  final VoidCallback onTap;

  bool get _isPopular => product.id == 'luxe_1200';

  @override
  Widget build(BuildContext context) {
    final bool enabled = !anyPurchasing;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.obsidianCard,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            color: _isPopular
                ? AppColors.gold.withValues(alpha: 0.5)
                : AppColors.gold.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: <Widget>[
            // Token amount + label
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Text(
                      '◆ $grantAmount',
                      style: TextStyle(
                        color: enabled ? AppColors.gold : AppColors.gold.withValues(alpha: 0.3),
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 5.0),
                    Text(
                      'LUXE',
                      style: TextStyle(
                        color: AppColors.gold.withValues(alpha: 0.6),
                        fontSize: 9.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
                if (_isPopular)
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 1.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                      child: const Text(
                        'BEST VALUE',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 7.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const Spacer(),

            // Price / spinner
            isPurchasing
                ? const SizedBox(
                    width: 18.0,
                    height: 18.0,
                    child: CircularProgressIndicator(
                      color: AppColors.gold,
                      strokeWidth: 1.5,
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: enabled
                          ? AppColors.gold.withValues(alpha: 0.12)
                          : Colors.transparent,
                      border: Border.all(
                        color: AppColors.gold.withValues(
                          alpha: enabled ? 0.4 : 0.1,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    child: Text(
                      product.price,
                      style: TextStyle(
                        color: AppColors.gold.withValues(
                          alpha: enabled ? 0.9 : 0.3,
                        ),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
