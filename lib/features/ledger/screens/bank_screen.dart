// Directive O — Bank Screen
// GDD §5.2 — Mogul Path: Brutalist financial terminal
// Live Capital + Transaction history + daily ledger chart

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/providers/mock_auth_provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/aurelian_theme.dart';
import '../../../domain/models/brand.dart';
import '../../hq/providers/hq_provider.dart';

/// Bank Screen — Brutalist financial terminal
/// Shows Total Capital, daily revenue chart, and live transaction ledger
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

final FutureProvider<List<Map<String, dynamic>>> dailyRevenueLedgerProvider =
    FutureProvider<List<Map<String, dynamic>>>(
        (Ref<AsyncValue<List<Map<String, dynamic>>>> ref) async {
  final String playerId = ref.watch(activeUidProvider);
  if (playerId.isEmpty) return <Map<String, dynamic>>[];

  return SupabaseService.client
      .from('daily_revenue_ledger')
      .select()
      .eq('player_id', playerId)
      .order('revenue_date', ascending: true)
      .limit(7);
});

class _BankContent extends ConsumerWidget {
  const _BankContent({required this.brand});

  final Brand brand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Map<String, dynamic>>> ledgerAsync =
        ref.watch(dailyRevenueLedgerProvider);

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

        // 7-Day Chart
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
                '7-DAY REVENUE',
                style: TextStyle(
                  color: AurelianPalette.ivory,
                  fontFamily: 'JetBrainsMono',
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ledgerAsync.when(
                  data: (List<Map<String, dynamic>> rows) => CustomPaint(
                    size: Size.infinite,
                    painter: _RevenueChartPainter(rows),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AurelianPalette.champagneGold,
                    ),
                  ),
                  error: (_, __) => const Center(
                    child: Text(
                      'LEDGER UNAVAILABLE',
                      style: TextStyle(
                        color: AurelianPalette.danger,
                        fontFamily: 'JetBrainsMono',
                        fontSize: 11,
                      ),
                    ),
                  ),
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

/// Daily revenue chart painter
class _RevenueChartPainter extends CustomPainter {
  const _RevenueChartPainter(this.rows);

  final List<Map<String, dynamic>> rows;

  @override
  void paint(Canvas canvas, Size size) {
    if (rows.isEmpty) {
      final TextPainter empty = TextPainter(
        text: const TextSpan(
          text: 'NO LEDGER DATA',
          style: TextStyle(
            color: AurelianPalette.textTertiary,
            fontFamily: 'JetBrainsMono',
            fontSize: 11,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout(maxWidth: size.width);
      empty.paint(
        canvas,
        Offset((size.width - empty.width) / 2, (size.height - empty.height) / 2),
      );
      return;
    }

    final Paint linePaint = Paint()
      ..color = AurelianPalette.champagneGold
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint fillPaint = Paint()
      ..color = AurelianPalette.champagneGold.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final List<double> totals = rows
        .map((Map<String, dynamic> row) =>
            (row['revenue_total'] as num?)?.toDouble() ?? 0.0)
        .toList();
    final double maxTotal =
        totals.reduce(mathMax).clamp(1.0, double.infinity).toDouble();
    final double xStep = rows.length == 1 ? 0 : size.width / (rows.length - 1);
    final List<Offset> points = <Offset>[
      for (int i = 0; i < totals.length; i++)
        Offset(
          rows.length == 1 ? size.width / 2 : i * xStep,
          size.height -
              ((totals[i] / maxTotal) * size.height * 0.8) -
              size.height * 0.1,
        ),
    ];

    final Path path = Path()..moveTo(points.first.dx, points.first.dy);

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
  bool shouldRepaint(covariant _RevenueChartPainter oldDelegate) =>
      oldDelegate.rows != rows;
}

double mathMax(double a, double b) => a > b ? a : b;

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
          return const Center(
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
