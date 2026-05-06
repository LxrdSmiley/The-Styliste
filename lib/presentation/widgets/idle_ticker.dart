// GDD §3.0 — Animated idle income ticker widget (top of HQ Dashboard)
// Phase 3: supports two display modes:
//   incomePerHour — shows the idle rate (e.g. 1.00/hr)
//   totalRevenue  — shows the running balance (e.g. $1,234.56) when provided
// Realtime brand_state stream drives updates automatically via hqBrandStreamProvider.

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class IdleTicker extends StatelessWidget {
  const IdleTicker({
    required this.incomePerHour,
    this.totalRevenue,
    super.key,
  });

  final double incomePerHour;

  /// When provided, shows the running balance instead of the rate.
  final double? totalRevenue;

  @override
  Widget build(BuildContext context) {
    final bool showBalance = totalRevenue != null;
    final String label = showBalance
        ? '\$${totalRevenue!.toStringAsFixed(2)}'
        : '${incomePerHour.toStringAsFixed(2)}/hr';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          showBalance ? Icons.account_balance_wallet_outlined : Icons.trending_up,
          color: AppColors.lime,
          size: 14.0,
        ),
        const SizedBox(width: 6.0),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.lime,
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
