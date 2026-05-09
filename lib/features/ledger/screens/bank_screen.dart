// Directive O — Bank Screen
// GDD §5.2 — Mogul Path: Brutalist financial terminal
// Live Capital + Transaction history + Mocked 7-day chart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/aurelian_theme.dart';
import '../../../domain/models/brand.dart';
import '../../hq/providers/hq_provider.dart';

/// Bank Screen — Brutalist financial terminal
/// Shows Total Capital, mocked 7-day chart, and live transaction ledger
class BankScreen extends ConsumerWidget {
  const BankScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Brand> brandAsync = ref.watch(hqBrandStreamProvider);

    return Scaffold(
      backgroundColor: AurelianPalette.textPrimary,
      appBar: AppBar(
        backgroundColor: AurelianPalette.textPrimary,
        foregroundColor: AurelianPalette.ivory,
        title: const Text(
          'THE BANK',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: brandAsync.when(
        data: (Brand brand) => _BankContent(brand: brand),
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

class _BankContent extends StatelessWidget {
  const _BankContent({required this.brand});

  final Brand brand;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Total Capital Display
        Container(
          padding: const EdgeInsets.all(24.0),
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AurelianPalette.champagneGold.withValues(alpha: 0.1),
            border: Border.all(color: AurelianPalette.champagneGold, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: <Widget>[
              const Text(
                'TOTAL CAPITAL',
                style: TextStyle(
                  color: AurelianPalette.ivory,
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '◆ ${NumberFormat.compact().format(brand.totalRevenue)}',
                style: const TextStyle(
                  color: AurelianPalette.champagneGold,
                  fontFamily: 'JetBrainsMono',
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Mocked 7-Day Chart
        Container(
          height: 150,
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AurelianPalette.ivory.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '7-DAY REVENUE (MOCKED)',
                style: TextStyle(
                  color: AurelianPalette.ivory,
                  fontFamily: 'JetBrainsMono',
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _RevenueChartPainter(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Transaction Ledger Header
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text(
                  'TRANSACTION',
                  style: TextStyle(
                    color: AurelianPalette.textTertiary,
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'AMOUNT',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AurelianPalette.textTertiary,
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'DATE',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AurelianPalette.textTertiary,
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Transaction List
        Expanded(
          child: _TransactionList(),
        ),
      ],
    );
  }
}

/// Mocked revenue chart painter
class _RevenueChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = AurelianPalette.champagneGold
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint fillPaint = Paint()
      ..color = AurelianPalette.champagneGold.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Generate mock bezier curve
    final Path path = Path();
    path.moveTo(0, size.height * 0.7);

    // Create a smooth curve
    final List<Offset> points = <Offset>[
      Offset(size.width * 0.1, size.height * 0.6),
      Offset(size.width * 0.2, size.height * 0.75),
      Offset(size.width * 0.3, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.45),
      Offset(size.width * 0.5, size.height * 0.55),
      Offset(size.width * 0.6, size.height * 0.35),
      Offset(size.width * 0.7, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.25),
      Offset(size.width * 0.9, size.height * 0.3),
      Offset(size.width, size.height * 0.2),
    ];

    for (int i = 0; i < points.length - 1; i++) {
      final Offset current = points[i];
      final Offset next = points[i + 1];
      final Offset mid = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );
      path.quadraticBezierTo(current.dx, current.dy, mid.dx, mid.dy);
    }

    // Draw fill
    final Path fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    canvas.drawPath(path, linePaint);

    // Draw dots at data points
    final Paint dotPaint = Paint()
      ..color = AurelianPalette.champagneGold
      ..style = PaintingStyle.fill;

    for (final Offset point in points) {
      canvas.drawCircle(point, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Live transaction list from provenance_ledger and fiat_transactions
class _TransactionList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch recent transactions from Supabase
    final Future<List<Map<String, dynamic>>> transactionsFuture =
        _fetchTransactions();

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: transactionsFuture,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AurelianPalette.champagneGold,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading transactions',
              style: TextStyle(color: AurelianPalette.danger),
            ),
          );
        }

        final List<Map<String, dynamic>> transactions = snapshot.data ?? <Map<String, dynamic>>[];

        if (transactions.isEmpty) {
          return const Center(
            child: Text(
              'NO TRANSACTIONS',
              style: TextStyle(
                color: AurelianPalette.textTertiary,
                fontFamily: 'JetBrainsMono',
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: transactions.length,
          itemBuilder: (BuildContext context, int index) {
            final Map<String, dynamic> tx = transactions[index];
            return _TransactionRow(
              description: tx['description'] as String? ?? 'Unknown',
              amount: tx['amount'] as int? ?? 0,
              isPositive: tx['is_positive'] as bool? ?? true,
              date: DateTime.tryParse(tx['date'] as String? ?? '') ?? DateTime.now(),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchTransactions() async {
    final String? userId = SupabaseService.client.auth.currentUser?.id;
    if (userId == null) return <Map<String, dynamic>>[];

    // Fetch from provenance_ledger (Archive sales, capital injections)
    final List<Map<String, dynamic>> provenance = await SupabaseService.client
        .from(SupabaseConstants.tableProvenanceLedger)
        .select('sale_price, provenance_note, created_at')
        .eq('buyer_id', userId)
        .order('created_at', ascending: false)
        .limit(10);

    // Fetch from fiat_transactions (Storefront purchases)
    final List<Map<String, dynamic>> fiat = await SupabaseService.client
        .from(SupabaseConstants.tableFiatTransactions)
        .select('amount, product_id, transaction_status, created_at')
        .eq('player_id', userId)
        .order('created_at', ascending: false)
        .limit(10);

    // Combine and format transactions
    final List<Map<String, dynamic>> allTx = <Map<String, dynamic>>[];

    for (final Map<String, dynamic> p in provenance) {
      allTx.add(<String, dynamic>{
        'description': p['provenance_note'] ?? 'Archive transaction',
        'amount': (p['sale_price'] as num?)?.toInt() ?? 0,
        'is_positive': true,
        'date': p['created_at'],
      });
    }

    for (final Map<String, dynamic> f in fiat) {
      final String status = f['transaction_status'] as String? ?? '';
      if (status == 'completed') {
        allTx.add(<String, dynamic>{
          'description': 'Luxe Token purchase',
          'amount': (f['amount'] as num?)?.toInt() ?? 0,
          'is_positive': false,
          'date': f['created_at'],
        });
      }
    }

    // Sort by date and take most recent 20
    allTx.sort(
      (Map<String, dynamic> a, Map<String, dynamic> b) =>
          (DateTime.tryParse(b['date'] as String? ?? '') ?? DateTime.now())
              .compareTo(
        DateTime.tryParse(a['date'] as String? ?? '') ?? DateTime.now(),
      ),
    );

    return allTx.take(20).toList();
  }
}

/// Single transaction row
class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.description,
    required this.amount,
    required this.isPositive,
    required this.date,
  });

  final String description;
  final int amount;
  final bool isPositive;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(
              description.toUpperCase(),
              style: const TextStyle(
                color: AurelianPalette.ivory,
                fontFamily: 'JetBrainsMono',
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${isPositive ? '+' : '-'}◆ ${NumberFormat.compact().format(amount)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isPositive ? AurelianPalette.success : AurelianPalette.danger,
                fontFamily: 'JetBrainsMono',
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('MM/dd HH:mm').format(date),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AurelianPalette.textTertiary,
                fontFamily: 'JetBrainsMono',
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
