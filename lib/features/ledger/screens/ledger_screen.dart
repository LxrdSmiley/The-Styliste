// GDD §5.1 — Ledger UI: Mogul capital allocation dashboard (Phase 5).
// Lime palette. Streams store list + brand balance; optimistic upgrade UX.
//
// Optimistic UI pattern:
//   Tap Upgrade → HapticFeedback + spinner on THIS card only → edge fn call
//   → Realtime stream resolves truth → optimistic state cleared.
//   HTTP 400 → "INSUFFICIENT CAPITAL" SnackBar + state reverted.
//
// dart:math pow() used for client-side cost display mirror:
//   cost = 500 * pow(1.5, store.tier)  — matches edge function formula exactly.

import 'dart:async';
import 'dart:math' show pow;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/consequence_breakdown.dart';
import '../../../domain/models/brand.dart';
import '../../../domain/models/store.dart';
import '../../../features/ftue/providers/first_objective_provider.dart';
import '../../../features/hq/providers/hq_provider.dart';
import '../providers/ledger_provider.dart';

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  bool _errorSnackbarShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(firstObjectiveActionsProvider.notifier).markLedgerOpened();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Store>> storesAsync =
        ref.watch(ledgerStoresStreamProvider);
    final UpgradeStoreState upgradeState = ref.watch(upgradeStoreProvider);
    final FirstStoreState firstStoreState = ref.watch(firstStoreProvider);

    // Surface error once per error event, then clear.
    if (upgradeState.errorMessage != null && !_errorSnackbarShown) {
      _errorSnackbarShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.obsidianCard,
              content: Text(
                upgradeState.errorMessage!,
                style: const TextStyle(
                  color: AppColors.lime,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          ref.read(upgradeStoreProvider.notifier).clearError();
          _errorSnackbarShown = false;
        }
      });
    }

    if (firstStoreState.errorMessage != null && !_errorSnackbarShown) {
      _errorSnackbarShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.obsidianCard,
              content: Text(
                firstStoreState.errorMessage!,
                style: const TextStyle(
                  color: AppColors.lime,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          );
          ref.read(firstStoreProvider.notifier).clearError();
          _errorSnackbarShown = false;
        }
      });
    }

    // Live balance from brand_state Realtime stream (source of truth).
    final double liveBalance = ref.watch(hqBrandStreamProvider).maybeWhen(
          data: (Brand brand) => brand.totalRevenue,
          orElse: () => 0.0,
        );

    // Effective balance: use optimistic preview during upgrade in-flight.
    final double displayBalance = upgradeState.optimisticBalance ?? liveBalance;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: AppColors.obsidian,
        foregroundColor: AppColors.lime,
        elevation: 0.0,
        centerTitle: true,
        title: const Text(
          'LEDGER',
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 4.0,
            color: AppColors.lime,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.lime),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Balance header ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'CAPITAL',
                  style: TextStyle(
                    color: AppColors.lime.withValues(alpha: 0.5),
                    fontSize: 9.0,
                    letterSpacing: 3.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '\$${displayBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.lime,
                    fontSize: 28.0,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1.0,
                  ),
                ),
                const Divider(color: AppColors.obsidianCard, height: 24.0),
                Text(
                  'ASSETS',
                  style: TextStyle(
                    color: AppColors.lime.withValues(alpha: 0.5),
                    fontSize: 9.0,
                    letterSpacing: 3.0,
                  ),
                ),
              ],
            ),
          ),

          // ── Store grid ───────────────────────────────────────────────────
          Expanded(
            child: storesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.lime,
                  strokeWidth: 1.5,
                ),
              ),
              error: (Object e, _) => Center(
                child: Text(
                  'ERROR LOADING ASSETS',
                  style: TextStyle(
                    color: AppColors.lime.withValues(alpha: 0.5),
                    letterSpacing: 2.0,
                    fontSize: 11.0,
                  ),
                ),
              ),
              data: (List<Store> stores) {
                if (stores.isNotEmpty) {
                  unawaited(
                    ref
                        .read(firstObjectiveRepositoryProvider)
                        .recordValidatedEvent('store_result_viewed'),
                  );
                }
                if (stores.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'NO ASSETS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.lime.withValues(alpha: 0.7),
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3.0,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            'Choose your first city, format, price posture, and inventory risk.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.lime.withValues(alpha: 0.45),
                              fontSize: 11.0,
                              letterSpacing: 1.0,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 18.0),
                          OutlinedButton.icon(
                            onPressed: firstStoreState.isSubmitting
                                ? null
                                : () => _showFirstStoreFlow(
                                      context,
                                      ref,
                                      liveBalance,
                                    ),
                            icon: firstStoreState.isSubmitting
                                ? const SizedBox(
                                    width: 14.0,
                                    height: 14.0,
                                    child: CircularProgressIndicator(
                                      color: AppColors.lime,
                                      strokeWidth: 1.5,
                                    ),
                                  )
                                : const Icon(Icons.add_business, size: 16.0),
                            label: const Text('OPEN FIRST STORE'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.lime,
                              side: const BorderSide(color: AppColors.lime),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18.0,
                                vertical: 12.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 32.0),
                  itemCount: stores.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12.0),
                  itemBuilder: (BuildContext context, int index) {
                    final Store store = stores[index];
                    return _StoreCard(
                      store: store,
                      currentBalance: liveBalance,
                      upgradeState: upgradeState,
                      onUpgrade: () {
                        HapticFeedback.mediumImpact();
                        ref.read(upgradeStoreProvider.notifier).upgrade(
                              store: store,
                              currentBalance: liveBalance,
                            );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFirstStoreFlow(
    BuildContext context,
    WidgetRef ref,
    double currentBalance,
  ) async {
    final FirstStoreDraft? draft = await showDialog<FirstStoreDraft>(
      context: context,
      builder: (_) => FirstStoreDialog(currentBalance: currentBalance),
    );
    if (draft == null || !mounted) return;
    final bool opened = await ref.read(firstStoreProvider.notifier).open(
          city: draft.city,
          storeType: draft.storeType,
          priceTier: draft.priceTier,
          inventoryCapacity: draft.inventoryCapacity,
        );
    if (!context.mounted) return;
    if (opened) {
      ref.invalidate(ledgerStoresStreamProvider);
      final Map<String, dynamic> result =
          ref.read(firstStoreProvider).result ?? <String, dynamic>{};
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            backgroundColor: AppColors.obsidianCard,
            title: const Text(
              'STORE OPENED',
              style: TextStyle(
                color: AppColors.lime,
                fontSize: 14.0,
                letterSpacing: 2.0,
              ),
            ),
            content: ConsequenceBreakdown(
              title: 'Server result',
              lines: <ConsequenceLine>[
                ConsequenceLine(
                  label: 'Opening investment',
                  value: '-\$${result['opening_cost'] ?? '—'}',
                  kind: ConsequenceKind.loss,
                ),
                ConsequenceLine(
                  label: 'Expected daily demand',
                  value: '${result['expected_demand_per_day'] ?? '—'}',
                  kind: ConsequenceKind.gain,
                ),
                ConsequenceLine(
                  label: 'Operating cost per hour',
                  value: '\$${result['operating_cost_per_hour'] ?? '—'}',
                ),
                ConsequenceLine(
                  label: 'Idle revenue per hour',
                  value: '\$${result['revenue_per_hour'] ?? '—'}',
                  kind: ConsequenceKind.gain,
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('CONTINUE'),
              ),
            ],
          ),
        );
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.obsidianCard,
          content: Text(
            'FIRST STORE OPENED — YOUR EMPIRE IS LIVE',
            style: TextStyle(
              color: AppColors.lime,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
      );
    }
  }
}

class FirstStoreDraft {
  const FirstStoreDraft({
    required this.city,
    required this.storeType,
    required this.priceTier,
    required this.inventoryCapacity,
  });

  final String city;
  final String storeType;
  final String priceTier;
  final int inventoryCapacity;
}

class FirstStoreDialog extends StatefulWidget {
  const FirstStoreDialog({required this.currentBalance, super.key});

  final double currentBalance;

  @override
  State<FirstStoreDialog> createState() => _FirstStoreDialogState();
}

class _FirstStoreDialogState extends State<FirstStoreDialog> {
  String _city = 'new_york';
  String _storeType = 'ecommerce';
  String _priceTier = 'signature';
  double _inventoryCapacity = 24;

  double get _openingCost => _storeType == 'flagship' ? 15000 : 8000;
  double get _demand => switch (_priceTier) {
        'accessible' => 18,
        'luxury' => 5,
        _ => 10,
      };
  double get _operatingCost => _storeType == 'flagship' ? 140 : 35;

  @override
  Widget build(BuildContext context) {
    final bool affordable = widget.currentBalance >= _openingCost;
    return AlertDialog(
      backgroundColor: AppColors.obsidianCard,
      title: const Text(
        'OPEN YOUR FIRST STORE',
        style: TextStyle(
          color: AppColors.lime,
          fontSize: 14.0,
          letterSpacing: 2.0,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _select<String>(
              'CITY',
              _city,
              <String>['new_york', 'paris', 'tokyo'],
              (String value) => setState(() => _city = value),
            ),
            _select<String>(
              'FORMAT',
              _storeType,
              <String>['ecommerce', 'flagship'],
              (String value) => setState(() => _storeType = value),
            ),
            _select<String>(
              'PRICE POSTURE',
              _priceTier,
              <String>['accessible', 'signature', 'luxury'],
              (String value) => setState(() => _priceTier = value),
            ),
            const SizedBox(height: 8.0),
            Text(
              'INVENTORY POSTURE: ${_inventoryCapacity.round()} UNITS',
              style: const TextStyle(
                color: AppColors.lime,
                fontSize: 10.0,
                letterSpacing: 1.2,
              ),
            ),
            Slider(
              value: _inventoryCapacity,
              min: 12,
              max: 60,
              divisions: 8,
              activeColor: AppColors.lime,
              onChanged: (double value) =>
                  setState(() => _inventoryCapacity = value),
            ),
            const Divider(color: AppColors.obsidian),
            Text(
              'OPENING INVESTMENT  \$${_openingCost.toStringAsFixed(0)}',
              style: const TextStyle(color: AppColors.ivory, fontSize: 11.0),
            ),
            Text(
              'EXPECTED DEMAND  ${_demand.toStringAsFixed(0)} / DAY',
              style: const TextStyle(color: AppColors.ivory, fontSize: 11.0),
            ),
            Text(
              'OPERATING COST  \$${_operatingCost.toStringAsFixed(0)} / HOUR',
              style: const TextStyle(color: AppColors.ivory, fontSize: 11.0),
            ),
            Text(
              'AVAILABLE CAPITAL  \$${widget.currentBalance.toStringAsFixed(0)}',
              style: TextStyle(
                color: affordable ? AppColors.lime : Colors.redAccent,
                fontSize: 11.0,
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        FilledButton(
          onPressed: affordable
              ? () => Navigator.pop(
                    context,
                    FirstStoreDraft(
                      city: _city,
                      storeType: _storeType,
                      priceTier: _priceTier,
                      inventoryCapacity: _inventoryCapacity.round(),
                    ),
                  )
              : null,
          child: const Text('CONFIRM INVESTMENT'),
        ),
      ],
    );
  }

  Widget _select<T>(
    String label,
    T value,
    List<T> values,
    ValueChanged<T> onChanged,
  ) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      dropdownColor: AppColors.obsidianCard,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.lime,
          fontSize: 10.0,
        ),
      ),
      style: const TextStyle(color: AppColors.ivory, fontSize: 12.0),
      items: values
          .map(
            (T item) => DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString().replaceAll('_', ' ').toUpperCase()),
            ),
          )
          .toList(),
      onChanged: (T? next) {
        if (next != null) onChanged(next);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Private store card — isolates per-card state check to avoid full rebuilds.
// ---------------------------------------------------------------------------
class _StoreCard extends StatelessWidget {
  const _StoreCard({
    required this.store,
    required this.currentBalance,
    required this.upgradeState,
    required this.onUpgrade,
  });

  final Store store;
  final double currentBalance;
  final UpgradeStoreState upgradeState;
  final VoidCallback onUpgrade;

  static const double _baseCost = 500.0;
  static const double _costExponent = 1.5;

  double get _cost => _baseCost * pow(_costExponent, store.tier);

  bool get _isUpgradingThis => upgradeState.upgradingStoreId == store.id;
  bool get _anyUpgradeInFlight => upgradeState.upgradingStoreId != null;
  bool get _canAfford => currentBalance >= _cost;

  @override
  Widget build(BuildContext context) {
    final bool buttonEnabled = _canAfford && !_anyUpgradeInFlight;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.obsidianCard,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: _isUpgradingThis
              ? AppColors.lime
              : AppColors.lime.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Header row ─────────────────────────────────────────────────
          Row(
            children: <Widget>[
              // City + type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      store.city.name.toUpperCase().replaceAll('_', ' '),
                      style: const TextStyle(
                        color: AppColors.lime,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      store.type.name.toUpperCase(),
                      style: TextStyle(
                        color: AppColors.lime.withValues(alpha: 0.5),
                        fontSize: 9.0,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
              // Tier badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: AppColors.lime.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(2.0),
                ),
                child: Text(
                  'T${store.tier}',
                  style: const TextStyle(
                    color: AppColors.lime,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12.0),

          // ── Revenue rate ────────────────────────────────────────────────
          Text(
            '\$${store.revenuePerHour.toStringAsFixed(2)}/hr',
            style: TextStyle(
              color: AppColors.ivory.withValues(alpha: 0.7),
              fontSize: 12.0,
              letterSpacing: 1.0,
            ),
          ),

          const SizedBox(height: 12.0),

          // ── Upgrade CTA ─────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 40.0,
            child: OutlinedButton(
              onPressed: buttonEnabled ? onUpgrade : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.lime,
                side: BorderSide(
                  color: buttonEnabled
                      ? AppColors.lime
                      : AppColors.lime.withValues(alpha: 0.2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                padding: EdgeInsets.zero,
              ),
              child: _isUpgradingThis
                  ? const SizedBox(
                      width: 16.0,
                      height: 16.0,
                      child: CircularProgressIndicator(
                        color: AppColors.lime,
                        strokeWidth: 1.5,
                      ),
                    )
                  : Text(
                      _canAfford
                          ? 'UPGRADE  \$${_cost.toStringAsFixed(0)}'
                          : 'INSUFFICIENT  \$${_cost.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        color: buttonEnabled
                            ? AppColors.lime
                            : AppColors.lime.withValues(alpha: 0.25),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
