// GDD §9.8 — IAP Riverpod providers (Phase 9).
// iapProductsProvider: one-shot fetch of StoreKit/Play product details.
// iapPurchaseStreamProvider: wraps InAppPurchase.instance.purchaseStream.
// iapNotifierProvider: orchestrates purchase → validate-iap Edge Function flow.
//   Optimistic spinner on active product; error SnackBar via ref.listen.
//   Token balance reconciled by Realtime hqBrandStreamProvider on success.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';

// ---------------------------------------------------------------------------
// Product ID set — must match App Store Connect / Google Play Console entries.
// Directive M: The Aurelian Storefront — Premium fiat bridge
// ---------------------------------------------------------------------------
const Set<String> kLuxeProductIds = <String>{
  // Directive M: The Aurelian Storefront tiered products
  'initiates_cache', // $0.99 — 100 Luxe (impulse buy)
  'artisans_reserve', // $4.99 — 550 Luxe (standard top-up)
  'architects_vault', // $9.99 — 1200 Luxe (10-pull enabler)
  'sovereign_syndicate', // $49.99 — 6500 Luxe (whale anchor)
};

// Token grant amounts (mirrors server-side LUXE_PRODUCTS map — display only).
const Map<String, int> kLuxeGrants = <String, int>{
  // Directive M
  'initiates_cache': 100,
  'artisans_reserve': 550,
  'architects_vault': 1200,
  'sovereign_syndicate': 6500,
};

// ---------------------------------------------------------------------------
// Product details — one-shot fetch from StoreKit/Play.
// ---------------------------------------------------------------------------
final FutureProvider<List<ProductDetails>> iapProductsProvider =
    FutureProvider<List<ProductDetails>>(
  (Ref<AsyncValue<List<ProductDetails>>> ref) async {
    if (kIsWeb) return <ProductDetails>[];
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(kLuxeProductIds);
    return response.productDetails
      ..sort(
        (ProductDetails a, ProductDetails b) =>
            (kLuxeGrants[a.id] ?? 0).compareTo(kLuxeGrants[b.id] ?? 0),
      );
  },
);

// ---------------------------------------------------------------------------
// Purchase stream — wraps InAppPurchase.instance.purchaseStream.
// Always consumed by IapNotifier; exposed here for provider graph clarity.
// ---------------------------------------------------------------------------
final StreamProvider<List<PurchaseDetails>> iapPurchaseStreamProvider =
    StreamProvider<List<PurchaseDetails>>(
  (Ref<AsyncValue<List<PurchaseDetails>>> ref) => kIsWeb
      ? Stream<List<PurchaseDetails>>.value(<PurchaseDetails>[])
      : InAppPurchase.instance.purchaseStream,
);

// ---------------------------------------------------------------------------
// IAP state
// ---------------------------------------------------------------------------
class IapState {
  const IapState({
    this.purchasingProductId,
    this.errorMessage,
  });

  /// Non-null while a purchase is in flight — drives spinner on that card.
  final String? purchasingProductId;
  final String? errorMessage;

  IapState copyWith({
    String? purchasingProductId,
    String? errorMessage,
    bool clearPurchasing = false,
    bool clearError = false,
  }) =>
      IapState(
        purchasingProductId: clearPurchasing
            ? null
            : (purchasingProductId ?? this.purchasingProductId),
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

// ---------------------------------------------------------------------------
// IapNotifier
// ---------------------------------------------------------------------------
class IapNotifier extends StateNotifier<IapState> {
  IapNotifier(this._ref) : super(const IapState()) {
    // Subscribe to purchase stream — processes results as they arrive.
    _ref.listen<AsyncValue<List<PurchaseDetails>>>(
      iapPurchaseStreamProvider,
      (
        AsyncValue<List<PurchaseDetails>>? _,
        AsyncValue<List<PurchaseDetails>> next,
      ) {
        next.whenData((List<PurchaseDetails> purchases) {
          for (final PurchaseDetails purchase in purchases) {
            _handlePurchaseUpdate(purchase);
          }
        });
      },
    );
  }

  final Ref<IapState> _ref;

  Future<void> _handlePurchaseUpdate(PurchaseDetails purchase) async {
    if (kIsWeb) {
      if (mounted) {
        state = const IapState(
          errorMessage: 'PURCHASES ARE AVAILABLE IN THE MOBILE APP',
        );
      }
      return;
    }
    if (purchase.status == PurchaseStatus.pending) return;

    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      // Purchases remain mobile-only; the web preview returns a disabled state.
      final String? platform = switch (defaultTargetPlatform) {
        TargetPlatform.iOS => 'ios',
        TargetPlatform.android => 'android',
        _ => null,
      };
      if (platform == null) {
        if (mounted) {
          state = const IapState(
            errorMessage: 'PURCHASES ARE UNAVAILABLE ON THIS PLATFORM',
          );
        }
        return;
      }
      final String receiptData =
          purchase.verificationData.serverVerificationData;

      try {
        final FunctionResponse result =
            await SupabaseService.client.functions.invoke(
          SupabaseConstants.fnValidateIap,
          body: <String, dynamic>{
            'platform': platform,
            'productId': purchase.productID,
            'receiptData': receiptData,
          },
        );

        final Map<String, dynamic>? data = result.data as Map<String, dynamic>?;
        if (data != null && data['error'] != null) {
          throw Exception(data['error'] as String);
        }

        // Complete the purchase on the store side.
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
        if (mounted) state = const IapState();
      } on Exception catch (e) {
        if (mounted) {
          state = IapState(
            errorMessage: e.toString().contains('RECEIPT_ALREADY_REDEEMED')
                ? 'PURCHASE ALREADY CREDITED'
                : e.toString().contains('STORE_UNAVAILABLE')
                    ? 'STORE UNAVAILABLE — TRY AGAIN'
                    : 'PURCHASE FAILED — CONTACT SUPPORT',
          );
        }
      }
    } else if (purchase.status == PurchaseStatus.error) {
      if (mounted) {
        state = const IapState(errorMessage: 'PURCHASE CANCELLED OR FAILED');
      }
    }

    if (purchase.pendingCompletePurchase &&
        purchase.status != PurchaseStatus.purchased &&
        purchase.status != PurchaseStatus.restored) {
      await InAppPurchase.instance.completePurchase(purchase);
    }
  }

  /// Initiate a purchase flow for the given product.
  Future<void> buyProduct(ProductDetails product) async {
    if (state.purchasingProductId != null) return;
    if (kIsWeb) {
      state = const IapState(
        errorMessage: 'PURCHASES ARE AVAILABLE IN THE MOBILE APP',
      );
      return;
    }
    state = IapState(purchasingProductId: product.id);

    final String? accountToken = SupabaseService.currentUserId;
    if (accountToken == null) {
      state = const IapState(errorMessage: 'PLEASE SIGN IN AGAIN');
      return;
    }
    final PurchaseParam param = PurchaseParam(
      productDetails: product,
      applicationUserName: accountToken,
    );
    try {
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
    } on Exception catch (e) {
      if (mounted) {
        state = IapState(
          errorMessage: 'COULD NOT INITIATE PURCHASE: ${e.runtimeType}',
        );
      }
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true, clearPurchasing: true);
    }
  }
}

final StateNotifierProvider<IapNotifier, IapState> iapNotifierProvider =
    StateNotifierProvider<IapNotifier, IapState>(
  (Ref<IapState> ref) => IapNotifier(ref),
);
