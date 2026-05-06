// GDD §5.5–5.6 — Equity: IPO, stock ticker, hostile takeovers, portfolio
// TODO: Implement in Phase 3 (Mogul Path)

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class EquityScreen extends StatelessWidget {
  const EquityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Center(child: Text('Equity — Phase 3', style: TextStyle(color: AppColors.ivory))),
    );
  }
}
