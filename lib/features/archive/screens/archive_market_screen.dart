// Directive K — Archive Market Screen
// GDD §8.9.9, §12.4.3 — Brutalist Auction House
// 
// Aesthetic: Alabaster background with harsh black grid lines
// Typography: JetBrainsMono exclusively (financial terminal)
// Features: Market grid, provenance ledger, Gala/Sovereign badges, 48h FOMO countdown

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/aurelian_theme.dart';
import '../models/archive_models.dart';
import '../providers/archive_provider.dart';
import '../services/provenance_calculator.dart';

/// Archive Market — Brutalist P2P Auction House
/// 
/// Contrast: Not warm/inviting. Cold, financial, data-driven.
/// Background: AurelianPalette.alabaster with harsh black grid lines
/// Font: JetBrainsMono exclusively
class ArchiveMarketScreen extends ConsumerStatefulWidget {
  const ArchiveMarketScreen({super.key});

  @override
  ConsumerState<ArchiveMarketScreen> createState() => _ArchiveMarketScreenState();
}

class _ArchiveMarketScreenState extends ConsumerState<ArchiveMarketScreen> {
  bool _showMyListings = false;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<ArchiveListing>> listingsAsync = _showMyListings
        ? ref.watch(myListingsProvider)
        : ref.watch(archiveListingsProvider);

    return Scaffold(
      backgroundColor: AurelianPalette.alabaster, // Brutalist white
      appBar: _buildAppBar(),
      body: Column(
        children: <Widget>[
          // Toggle: All Listings / My Listings
          _buildToggleBar(),
          
          // Market stats bar
          _buildStatsBar(),
          
          // Grid
          Expanded(
            child: listingsAsync.when(
              data: (List<ArchiveListing> listings) {
                if (listings.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildMarketGrid(listings);
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              ),
              error: (Object error, StackTrace _) => Center(
                child: Text(
                  'ERROR: $error',
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AurelianPalette.alabaster,
      elevation: 0,
      centerTitle: true,
      title: Column(
        children: <Widget>[
          const Text(
            'THE ARCHIVE',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 4.0,
              color: Colors.black,
            ),
          ),
          Text(
            'P2P MARKET // 30% PLATFORM TAX',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 8.0,
              letterSpacing: 2.0,
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => context.pop(),
      ),
      actions: <Widget>[
        // Info button
        IconButton(
          icon: Icon(
            Icons.info_outline,
            color: Colors.black.withValues(alpha: 0.5),
          ),
          onPressed: _showMarketInfo,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          height: 1.0,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildToggleBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showMyListings = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: !_showMyListings ? Colors.black : Colors.transparent,
                      width: 2.0,
                    ),
                  ),
                ),
                child: Text(
                  'ALL LISTINGS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                    color: !_showMyListings ? Colors.black : Colors.black.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 1.0,
            height: 48.0,
            color: Colors.black.withValues(alpha: 0.2),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showMyListings = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _showMyListings ? Colors.black : Colors.transparent,
                      width: 2.0,
                    ),
                  ),
                ),
                child: Text(
                  'MY LISTINGS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                    color: _showMyListings ? Colors.black : Colors.black.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    final AsyncValue<MarketStats> statsAsync = ref.watch(marketStatsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.03),
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: statsAsync.when(
        data: (MarketStats stats) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _StatItem(
                label: 'ACTIVE',
                value: stats.totalActiveListings.toString(),
              ),
              _StatItem(
                label: '24H VOL',
                value: '\$${(stats.totalVolume24h / 1000).toStringAsFixed(1)}K',
              ),
              _StatItem(
                label: 'TAX BURNED',
                value: '\$${(stats.taxBurned24h / 1000).toStringAsFixed(1)}K',
                valueColor: const Color(0xFFFF4444),
              ),
            ],
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildMarketGrid(List<ArchiveListing> listings) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: listings.length,
      itemBuilder: (BuildContext context, int index) {
        return _ListingCard(
          listing: listings[index],
          isMine: _showMyListings,
          onTap: () => _showListingDetails(listings[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.store_outlined,
            size: 64.0,
            color: Colors.black.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16.0),
          Text(
            _showMyListings ? 'NO ACTIVE LISTINGS' : 'MARKET EMPTY',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 12.0,
              letterSpacing: 2.0,
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  void _showListingDetails(ArchiveListing listing) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AurelianPalette.alabaster,
      isScrollControlled: true,
      builder: (BuildContext ctx) => _ListingDetailSheet(
        listing: listing,
        isMine: _showMyListings,
      ),
    );
  }

  void _showMarketInfo() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: AurelianPalette.alabaster,
        title: const Text(
          'ARCHIVE PROTOCOL',
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 14.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _infoRow('Duration', '48 hours (FOMO)'),
            _infoRow('Min Price', 'MAX(1000, Hype×10)'),
            _infoRow('Platform Tax', '30% (burned)'),
            _infoRow('Seller Payout', '70%'),
            _infoRow('Provenance', '+10% per owner (max 10)'),
            _infoRow('Sovereign Bump', '+50% if any owner Rank 100'),
            _infoRow('Max Provenance', '+150% total'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'ACKNOWLEDGED',
              style: TextStyle(fontFamily: 'JetBrainsMono'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 11.0,
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Listing Card (Grid Item)
// =============================================================================

class _ListingCard extends StatelessWidget {
  const _ListingCard({
    required this.listing,
    required this.isMine,
    this.onTap,
  });

  final ArchiveListing listing;
  final bool isMine;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AurelianPalette.alabaster,
          border: Border.all(
            
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Badges row
            if (listing.isGalaWinner || listing.hasSovereignProvenance)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    if (listing.isGalaWinner)
                      const _Badge(
                        label: 'GALA WINNER',
                        color: Color(0xFFD4AF37),
                      ),
                    if (listing.hasSovereignProvenance) ...<Widget>[
                      const SizedBox(width: 4.0),
                      const _Badge(
                        label: 'SOVEREIGN',
                        color: Color(0xFF8B0000),
                      ),
                    ],
                  ],
                ),
              ),
            
            // Design preview placeholder
            Expanded(
              child: Container(
                color: Colors.black.withValues(alpha: 0.03),
                child: Center(
                  child: Icon(
                    Icons.checkroom,
                    size: 48.0,
                    color: Colors.black.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
            
            // Info section
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.black.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Design name
                  Text(
                    listing.designName?.toUpperCase() ?? 'UNTITLED',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // Price
                  Text(
                    '\$${listing.listingPrice}',
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  // Countdown (FOMO)
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.timer,
                        size: 10.0,
                        color: listing.urgencyColor,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        listing.formattedTimeRemaining,
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 9.0,
                          color: listing.urgencyColor,
                        ),
                      ),
                    ],
                  ),
                  // Provenance indicator
                  if (listing.transferCount > 0)
                    Text(
                      '${listing.transferCount} OWNER${listing.transferCount == 1 ? '' : 'S'}',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 8.0,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(
          color: color,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 7.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: color,
        ),
      ),
    );
  }
}

// =============================================================================
// Listing Detail Sheet (Bottom Sheet)
// =============================================================================

class _ListingDetailSheet extends ConsumerWidget {
  const _ListingDetailSheet({
    required this.listing,
    required this.isMine,
  });

  final ArchiveListing listing;
  final bool isMine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PurchaseState purchaseState = ref.watch(purchaseProvider);
    final ListingState listingState = ref.watch(listingProvider);

    return Container(
      padding: const EdgeInsets.all(24.0),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Handle
          Center(
            child: Container(
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          
          // Title
          Text(
            listing.designName?.toUpperCase() ?? 'UNTITLED',
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 18.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8.0),
          
          // Seller
          Text(
            'SELLER: ${listing.sellerName?.toUpperCase() ?? 'UNKNOWN'}',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 10.0,
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24.0),
          
          // Price breakdown
          _buildPriceBreakdown(),
          const SizedBox(height: 24.0),
          
          // Provenance section
          _buildProvenanceSection(),
          const SizedBox(height: 24.0),
          
          // Transaction breakdown
          _buildTransactionBreakdown(),
          const SizedBox(height: 24.0),
          
          // Action buttons
          if (isMine)
            _buildCancelButton(ref, listingState)
          else
            _buildPurchaseButton(ref, purchaseState),
          
          // Error display
          if (purchaseState.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                purchaseState.errorMessage!,
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 10.0,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          if (listingState.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                listingState.errorMessage!,
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 10.0,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(
          
        ),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'LISTING PRICE',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 10.0,
                ),
              ),
              Text(
                '\$${listing.listingPrice}',
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'PRICE FLOOR',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 9.0,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ),
              Text(
                '\$${listing.priceFloor}',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 9.0,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProvenanceSection() {
    final ProvenanceBreakdown breakdown = ProvenanceCalculator.getBreakdown(
      listing.transferCount,
      listing.hasSovereignProvenance,
    );

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.03),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'PROVENANCE',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 10.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            listing.provenanceDescription,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 11.0,
              color: Colors.black.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: <Widget>[
              Text(
                'BASE HYPE: ${listing.hypeScore}',
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 9.0,
                ),
              ),
              const SizedBox(width: 16.0),
              Text(
                'EFFECTIVE: ${listing.effectiveHype}',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 9.0,
                  fontWeight: FontWeight.w700,
                  color: listing.hasSovereignProvenance || listing.transferCount > 0
                      ? const Color(0xFFD4AF37)
                      : Colors.black,
                ),
              ),
              if (listing.formattedProvenance.isNotEmpty) ...<Widget>[
                const SizedBox(width: 8.0),
                Text(
                  listing.formattedProvenance,
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 9.0,
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionBreakdown() {
    final TransactionBreakdown breakdown = listing.transactionBreakdown;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: <Widget>[
          _transactionRow('YOU PAY', '\$${breakdown.buyerTotal}', isBold: true),
          const Divider(height: 16.0),
          _transactionRow('SELLER RECEIVES', '\$${breakdown.sellerPayout} (70%)'),
          const SizedBox(height: 4.0),
          _transactionRow(
            'PLATFORM TAX (BURNED)',
            '\$${breakdown.platformTax} (30%)',
            valueColor: const Color(0xFFFF4444),
          ),
        ],
      ),
    );
  }

  Widget _transactionRow(String label, String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: isBold ? 11.0 : 10.0,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: isBold ? 14.0 : 10.0,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseButton(WidgetRef ref, PurchaseState state) {
    return GestureDetector(
      onTap: state.isPurchasing
          ? null
          : () => ref.read(purchaseProvider.notifier).purchase(listing.id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(width: 2.0),
        ),
        child: Center(
          child: state.isPurchasing
              ? const SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'EXECUTE PURCHASE',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(WidgetRef ref, ListingState state) {
    return GestureDetector(
      onTap: state.isCancelling
          ? null
          : () => ref.read(listingProvider.notifier).cancelListing(listing.id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 2.0),
        ),
        child: Center(
          child: state.isCancelling
              ? const SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
              : const Text(
                  'CANCEL LISTING',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: Colors.black,
                  ),
                ),
        ),
      ),
    );
  }
}

// =============================================================================
// Stats Bar Widget
// =============================================================================

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 14.0,
            fontWeight: FontWeight.w700,
            color: valueColor ?? Colors.black,
          ),
        ),
        const SizedBox(height: 2.0),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 8.0,
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
