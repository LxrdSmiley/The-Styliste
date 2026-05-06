// GDD §5.5 — Central Bank: loans, credit score, debt management
// TODO: Implement in Phase 3 (Mogul Path)

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class BankScreen extends StatelessWidget {
  const BankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Center(child: Text('Bank — Phase 3', style: TextStyle(color: AppColors.ivory))),
    );
  }
}
