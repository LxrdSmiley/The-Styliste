// Directive K — Archive Providers
// GDD §8.9.9, §12.4.3 — P2P market state management
// Alabaster Standard: Strict FOR UPDATE locks, 30% tax burn

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/archive_models.dart';
import '../services/provenance_calculator.dart';

// =============================================================================
// Archive Listings Stream
// =============================================================================

/// Active market listings (real-time)
final StreamProvider<List<ArchiveListing>> archiveListingsProvider =
    StreamProvider<List<ArchiveListing>>(
        (Ref<AsyncValue<List<ArchiveListing>>> ref) {
  final SupabaseClient supabase = Supabase.instance.client;

  return supabase
      .from('archive_listings_enriched')
      .stream(primaryKey: <String>['id'])
      .order('listed_at')
      .map((List<Map<String, dynamic>> data) {
        return data
            .map((Map<String, dynamic> json) => ArchiveListing.fromJson(json))
            .toList();
      });
});

/// Filtered listings by price range
final ProviderFamily<AsyncValue<List<ArchiveListing>>, ({int min, int max})>
    filteredListingsProvider =
    ProviderFamily<AsyncValue<List<ArchiveListing>>, ({int min, int max})>(
        (Ref<AsyncValue<List<ArchiveListing>>> ref,
            ({int min, int max}) range) {
  final AsyncValue<List<ArchiveListing>> allListings =
      ref.watch(archiveListingsProvider);

  return allListings.when(
    data: (List<ArchiveListing> listings) {
      final List<ArchiveListing> filtered = listings.where((ArchiveListing l) {
        return l.listingPrice >= range.min && l.listingPrice <= range.max;
      }).toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (Object e, StackTrace s) => AsyncValue.error(e, s),
  );
});

/// User's own listings
final FutureProvider<List<ArchiveListing>> myListingsProvider =
    FutureProvider<List<ArchiveListing>>(
        (Ref<AsyncValue<List<ArchiveListing>>> ref) async {
  final SupabaseClient supabase = Supabase.instance.client;
  final String? userId = supabase.auth.currentUser?.id;

  if (userId == null) return <ArchiveListing>[];

  final List<Map<String, dynamic>> results = await supabase
      .from('archive_listings_enriched')
      .select()
      .eq('seller_id', userId);

  return results
      .map((Map<String, dynamic> json) => ArchiveListing.fromJson(json))
      .toList();
});

// =============================================================================
// Provenance Ledger Provider
// =============================================================================

/// Provenance history for specific design
final FutureProviderFamily<List<ProvenanceRecord>, String>
    provenanceLedgerProvider =
    FutureProviderFamily<List<ProvenanceRecord>, String>(
  (Ref<AsyncValue<List<ProvenanceRecord>>> ref, String designId) async {
    final SupabaseClient supabase = Supabase.instance.client;

    final List<Map<String, dynamic>> results = await supabase
        .from('provenance_ledger_enriched')
        .select()
        .eq('design_id', designId)
        .order('transferred_at', ascending: false);

    return results
        .map((Map<String, dynamic> json) => ProvenanceRecord.fromJson(json))
        .toList();
  },
);

// =============================================================================
// Purchase State Notifier
// =============================================================================

class PurchaseState {
  const PurchaseState({
    this.isPurchasing = false,
    this.lastResult,
    this.errorMessage,
  });

  final bool isPurchasing;
  final PurchaseResult? lastResult;
  final String? errorMessage;

  bool get hasError => errorMessage != null;
  bool get hasSuccess => lastResult?.success ?? false;

  PurchaseState copyWith({
    bool? isPurchasing,
    PurchaseResult? lastResult,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return PurchaseState(
      isPurchasing: isPurchasing ?? this.isPurchasing,
      lastResult: clearResult ? null : (lastResult ?? this.lastResult),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class PurchaseNotifier extends StateNotifier<PurchaseState> {
  PurchaseNotifier() : super(const PurchaseState());

  /// Execute purchase with FOR UPDATE protection
  Future<void> purchase(String listingId) async {
    if (state.isPurchasing) return;

    state =
        state.copyWith(isPurchasing: true, clearError: true, clearResult: true);

    try {
      final SupabaseClient supabase = Supabase.instance.client;
      final String? userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        state = state.copyWith(
          isPurchasing: false,
          errorMessage: 'Not authenticated',
        );
        return;
      }

      final Map<String, dynamic> result = await supabase.rpc(
        'execute_archive_purchase',
        params: <String, dynamic>{
          'p_buyer_id': userId,
          'p_listing_id': listingId,
        },
      );

      final PurchaseResult purchaseResult = PurchaseResult(
        success: result['success'] as bool,
        transactionId: result['transaction_id'] as String?,
        message: result['message'] as String?,
      );

      state = state.copyWith(
        isPurchasing: false,
        lastResult: purchaseResult,
      );
    } catch (e) {
      state = state.copyWith(
        isPurchasing: false,
        errorMessage: 'Purchase failed: $e',
      );
    }
  }

  void reset() {
    state = const PurchaseState();
  }
}

final StateNotifierProvider<PurchaseNotifier, PurchaseState> purchaseProvider =
    StateNotifierProvider<PurchaseNotifier, PurchaseState>(
  (Ref<PurchaseState> ref) => PurchaseNotifier(),
);

// =============================================================================
// Listing State Notifier (Create/Cancel)
// =============================================================================

class ListingState {
  const ListingState({
    this.isCreating = false,
    this.isCancelling = false,
    this.lastResult,
    this.cancelledListingId,
    this.errorMessage,
  });

  final bool isCreating;
  final bool isCancelling;
  final ListingResult? lastResult;
  final String? cancelledListingId;
  final String? errorMessage;

  bool get hasError => errorMessage != null;
  bool get isLoading => isCreating || isCancelling;

  ListingState copyWith({
    bool? isCreating,
    bool? isCancelling,
    ListingResult? lastResult,
    String? cancelledListingId,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return ListingState(
      isCreating: isCreating ?? this.isCreating,
      isCancelling: isCancelling ?? this.isCancelling,
      lastResult: clearResult ? null : (lastResult ?? this.lastResult),
      cancelledListingId: cancelledListingId ?? this.cancelledListingId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ListingNotifier extends StateNotifier<ListingState> {
  ListingNotifier() : super(const ListingState());

  /// Create new listing with price floor validation
  Future<void> createListing({
    required String designId,
    required int price,
    bool isGalaWinner = false,
    String? galaEventId,
  }) async {
    if (state.isLoading) return;

    state =
        state.copyWith(isCreating: true, clearError: true, clearResult: true);

    try {
      final SupabaseClient supabase = Supabase.instance.client;
      final String? userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        state = state.copyWith(
          isCreating: false,
          errorMessage: 'Not authenticated',
        );
        return;
      }

      final Map<String, dynamic> result = await supabase.rpc(
        'list_on_archive',
        params: <String, dynamic>{
          'p_seller_id': userId,
          'p_design_id': designId,
          'p_listing_price': price,
          'p_is_gala_winner': isGalaWinner,
          'p_gala_event_id': galaEventId,
        },
      );

      final ListingResult listingResult = ListingResult(
        success: result['success'] as bool,
        listingId: result['listing_id'] as String?,
        message: result['message'] as String?,
        minimumPrice: result['message']?.toString().contains('Minimum') ?? false
            ? int.tryParse(RegExp(r'\d+')
                    .firstMatch(result['message'] as String)
                    ?.group(0) ??
                '0')
            : null,
      );

      state = state.copyWith(
        isCreating: false,
        lastResult: listingResult,
      );
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        errorMessage: 'Listing failed: $e',
      );
    }
  }

  /// Cancel own listing
  Future<void> cancelListing(String listingId) async {
    if (state.isLoading) return;

    state = state.copyWith(isCancelling: true, clearError: true);

    try {
      final SupabaseClient supabase = Supabase.instance.client;

      final Map<String, dynamic> result = await supabase.rpc(
        'cancel_archive_listing',
        params: <String, dynamic>{
          'p_listing_id': listingId,
        },
      );

      final bool success = result['success'] as bool;

      state = state.copyWith(
        isCancelling: false,
        cancelledListingId: success ? listingId : null,
        errorMessage: success ? null : (result['message'] as String?),
      );
    } catch (e) {
      state = state.copyWith(
        isCancelling: false,
        errorMessage: 'Cancel failed: $e',
      );
    }
  }

  void reset() {
    state = const ListingState();
  }
}

final StateNotifierProvider<ListingNotifier, ListingState> listingProvider =
    StateNotifierProvider<ListingNotifier, ListingState>(
  (Ref<ListingState> ref) => ListingNotifier(),
);

// =============================================================================
// Market Stats Provider
// =============================================================================

final FutureProvider<MarketStats> marketStatsProvider =
    FutureProvider<MarketStats>((Ref<AsyncValue<MarketStats>> ref) async {
  final SupabaseClient supabase = Supabase.instance.client;

  // Get active listings count
  final List<Map<String, dynamic>> activeCount = await supabase
      .from('archive_listings')
      .select('id')
      .eq('status', 'active');

  // Get 24h volume and tax burned
  final List<Map<String, dynamic>> volumeData = await supabase
      .from('provenance_ledger')
      .select('sale_price, platform_tax')
      .gte('transferred_at',
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String());

  int totalVolume = 0;
  int taxBurned = 0;
  for (final Map<String, dynamic> row in volumeData) {
    totalVolume += (row['sale_price'] as num).toInt();
    taxBurned += (row['platform_tax'] as num).toInt();
  }

  double avgPrice = 0;
  if (volumeData.isNotEmpty) {
    avgPrice = totalVolume / volumeData.length;
  }

  return MarketStats(
    totalActiveListings: activeCount.length,
    totalVolume24h: totalVolume,
    averagePrice: avgPrice,
    taxBurned24h: taxBurned,
  );
});

// =============================================================================
// Price Floor Helper Provider
// =============================================================================

final FutureProviderFamily<int, String> priceFloorProvider =
    FutureProviderFamily<int, String>(
  (Ref<AsyncValue<int>> ref, String designId) async {
    final SupabaseClient supabase = Supabase.instance.client;

    final Map<String, dynamic> result = await supabase
        .from('designs')
        .select('hype_score')
        .eq('id', designId)
        .single();

    final int hypeScore = (result['hype_score'] as num?)?.toInt() ?? 0;
    return ArchivePriceFloor.calculate(hypeScore);
  },
);
