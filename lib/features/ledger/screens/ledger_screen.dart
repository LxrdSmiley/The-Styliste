// GDD v8 §§18, 21, 22 — Gate A Empire projection and first-store dialog.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/styliste_colors.dart';
import '../../../core/theme/styliste_spacing.dart';
import '../../../core/theme/styliste_typography.dart';
import '../../../core/theme/styliste_visual_mode.dart';
import '../../../core/widgets/aurelian_components.dart';
import '../../../core/widgets/styliste_buttons.dart';
import '../../../core/widgets/styliste_scaffold.dart';
import '../../../domain/models/brand.dart';
import '../../../domain/models/store.dart';
import '../../ftue/providers/first_objective_provider.dart';
import '../../hq/providers/hq_provider.dart';
import '../providers/ledger_provider.dart';

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(firstObjectiveActionsProvider.notifier).markLedgerOpened();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Store>> stores =
        ref.watch(ledgerStoresStreamProvider);
    final FirstStoreState firstStore = ref.watch(firstStoreProvider);
    final AsyncValue<Brand> brand = ref.watch(hqBrandStreamProvider);
    final double? capital = brand.value?.totalRevenue;

    return AurelianScaffold(
      mode: StylisteVisualMode.executiveObsidian,
      appBar: const AurelianContextualAppBar(
        eyebrow: 'Kingston House',
        title: 'Empire',
      ),
      body: AurelianResponsiveBody(
        maxWidth: 680,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const AurelianSectionHeader(
              eyebrow: 'Ledger projection',
              title: 'Read the House without taking hidden action',
              detail:
                  'Capital and stores are server-owned projections. Gate A exposes only the reviewed first-store intent.',
            ),
            const SizedBox(height: StylisteSpacing.md),
            AurelianCard(
              emphasized: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(
                    Icons.account_balance_outlined,
                    color: StylisteColors.champagneGold,
                    semanticLabel: 'Capital projection',
                  ),
                  const SizedBox(width: StylisteSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'CAPITAL PROJECTION',
                          style: StylisteText.labelCaps.copyWith(
                            color: StylisteColors.champagneGold,
                          ),
                        ),
                        const SizedBox(height: StylisteSpacing.xs),
                        Text(
                          capital == null
                              ? '—'
                              : '\$${capital.toStringAsFixed(2)}',
                          style: StylisteText.metricLarge.copyWith(
                            color: StylisteColors.ivory,
                          ),
                        ),
                        const SizedBox(height: StylisteSpacing.xs),
                        Text(
                          'Read-only. The client cannot set, deduct, or grant this value.',
                          style: StylisteText.bodySmall.copyWith(
                            color: StylisteColors.warmGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (brand.hasError) ...<Widget>[
              const SizedBox(height: StylisteSpacing.md),
              AurelianStatePanel(
                kind: AurelianStateKind.retryableError,
                title: 'Capital projection is unavailable',
                message: 'No wallet or store value was changed.',
                actionLabel: 'Retry projection',
                onAction: () => ref.invalidate(hqBrandStreamProvider),
                compact: true,
              ),
            ],
            if (firstStore.errorMessage != null) ...<Widget>[
              const SizedBox(height: StylisteSpacing.md),
              AurelianStatePanel(
                kind: AurelianStateKind.retryableError,
                title: 'The store intent was not confirmed',
                message: firstStore.errorMessage!,
                actionLabel: 'Dismiss and review',
                onAction: () =>
                    ref.read(firstStoreProvider.notifier).clearError(),
                compact: true,
              ),
            ],
            const SizedBox(height: StylisteSpacing.lg),
            const AurelianSectionHeader(
              eyebrow: 'Kingston presence',
              title: 'Current store record',
              detail:
                  'Upgrades, expansion, additional cities, and automated revenue operations remain unavailable.',
            ),
            const SizedBox(height: StylisteSpacing.md),
            stores.when(
              loading: () => const AurelianStatePanel(
                kind: AurelianStateKind.loading,
                title: 'Restoring your store record',
                message: 'Reading the owner-safe store projection.',
              ),
              error: (_, __) => AurelianStatePanel(
                kind: AurelianStateKind.retryableError,
                title: 'Store record is temporarily unavailable',
                message: 'No store operation was started.',
                actionLabel: 'Retry store record',
                onAction: () => ref.invalidate(ledgerStoresStreamProvider),
              ),
              data: (List<Store> values) {
                if (values.isNotEmpty) {
                  unawaited(
                    ref
                        .read(firstObjectiveRepositoryProvider)
                        .recordValidatedEvent('store_result_viewed'),
                  );
                }
                if (values.isEmpty) {
                  return _NoStoreState(
                    isSubmitting: firstStore.isSubmitting,
                    onOpen: () => _showFirstStoreFlow(
                      context,
                      ref,
                      capital ?? 0,
                    ),
                  );
                }
                return Column(
                  children: values
                      .map(
                        (Store store) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: StylisteSpacing.sm,
                          ),
                          child: _StoreProjectionCard(store: store),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
          ],
        ),
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
      builder: (BuildContext context) =>
          FirstStoreDialog(currentBalance: currentBalance),
    );
    if (draft == null || !mounted) return;
    final bool opened = await ref.read(firstStoreProvider.notifier).open(
          storeType: draft.storeType,
          priceTier: draft.priceTier,
          inventoryCapacity: draft.inventoryCapacity,
        );
    if (!context.mounted || !opened) return;
    ref.invalidate(ledgerStoresStreamProvider);
    final FirstStoreState state = ref.read(firstStoreProvider);
    final Map<String, dynamic> result = state.result ?? <String, dynamic>{};
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Kingston store confirmed'),
        content: SingleChildScrollView(
          child: AurelianReceiptPanel(
            title: 'First-store server result',
            receiptId: state.idempotencyKey ?? 'Server receipt unavailable',
            restored: result['status'] == 'restored',
            detail:
                'Format ${draft.storeType}; price posture ${draft.priceTier}; inventory ${draft.inventoryCapacity}. No client value was treated as an outcome.',
          ),
        ),
        actions: <Widget>[
          GoldPrimaryButton(
            label: 'Continue',
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
  }
}

class _NoStoreState extends StatelessWidget {
  const _NoStoreState({
    required this.isSubmitting,
    required this.onOpen,
  });

  final bool isSubmitting;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return AurelianStatePanel(
      kind: AurelianStateKind.empty,
      title: 'No Kingston store is recorded',
      message:
          'Declare one bounded first-store intent. The server validates ownership, tutorial state, and the debt-free opening rule.',
      actionLabel: 'Open first-store brief',
      onAction: isSubmitting ? null : onOpen,
    );
  }
}

class _StoreProjectionCard extends StatelessWidget {
  const _StoreProjectionCard({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final String type =
        store.type == StoreType.flagship ? 'Flagship' : 'E-commerce';
    return AurelianCard(
      semanticLabel:
          '$type store in Kingston. Tier ${store.tier}. Server-owned projection.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.storefront_outlined,
                color: StylisteColors.champagneGold,
              ),
              const SizedBox(width: StylisteSpacing.sm),
              Expanded(child: Text(type, style: StylisteText.title)),
              AurelianStatusChip(
                label: 'Tier ${store.tier}',
                icon: Icons.layers_outlined,
              ),
            ],
          ),
          const SizedBox(height: StylisteSpacing.md),
          Wrap(
            spacing: StylisteSpacing.sm,
            runSpacing: StylisteSpacing.sm,
            children: <Widget>[
              _ProjectionMetric(
                label: 'Revenue / hour',
                value: '\$${store.revenuePerHour.toStringAsFixed(2)}',
              ),
              _ProjectionMetric(
                label: 'Loyalty',
                value: '${store.loyalty}',
              ),
              _ProjectionMetric(
                label: 'Market share',
                value: '${(store.marketShare * 100).toStringAsFixed(1)}%',
              ),
            ],
          ),
          const SizedBox(height: StylisteSpacing.md),
          const AurelianStatusChip(
            label: 'Upgrades unavailable in Gate A',
            icon: Icons.lock_outline,
            tone: AurelianStatusTone.warning,
          ),
        ],
      ),
    );
  }
}

class _ProjectionMetric extends StatelessWidget {
  const _ProjectionMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 136),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label.toUpperCase(), style: StylisteText.labelCaps),
          const SizedBox(height: StylisteSpacing.xxs),
          Text(value, style: StylisteText.metricSmall),
        ],
      ),
    );
  }
}

class FirstStoreDraft {
  const FirstStoreDraft({
    required this.storeType,
    required this.priceTier,
    required this.inventoryCapacity,
  });

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
  String _storeType = 'ecommerce';
  String _priceTier = 'signature';
  double _inventoryCapacity = 24;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('First Kingston store'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const LuxeGuidanceCard(
              mode: StylisteVisualMode.noirCinematic,
              message:
                  'Declare format, price posture, and inventory intent. The server owns affordability, tutorial state, and every result.',
            ),
            const SizedBox(height: StylisteSpacing.md),
            _selector(
              label: 'Format',
              value: _storeType,
              values: const <String>['ecommerce', 'flagship'],
              onChanged: (String value) => setState(() => _storeType = value),
            ),
            const SizedBox(height: StylisteSpacing.sm),
            _selector(
              label: 'Price posture',
              value: _priceTier,
              values: const <String>['accessible', 'signature', 'luxury'],
              onChanged: (String value) => setState(() => _priceTier = value),
            ),
            const SizedBox(height: StylisteSpacing.md),
            Text(
              'INVENTORY INTENT • ${_inventoryCapacity.round()} UNITS',
              style: StylisteText.labelCaps.copyWith(
                color: StylisteColors.champagneGold,
              ),
            ),
            Slider(
              value: _inventoryCapacity,
              min: 12,
              max: 60,
              divisions: 8,
              label: '${_inventoryCapacity.round()} units',
              onChanged: (double value) =>
                  setState(() => _inventoryCapacity = value),
            ),
            Text(
              'Displayed capital: \$${widget.currentBalance.toStringAsFixed(2)}. This projection is not submitted as authority.',
              style: StylisteText.bodySmall.copyWith(
                color: StylisteColors.warmGrey,
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        IvorySecondaryButton(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        GoldPrimaryButton(
          label: 'Submit store intent',
          onPressed: () => Navigator.of(context).pop(
            FirstStoreDraft(
              storeType: _storeType,
              priceTier: _priceTier,
              inventoryCapacity: _inventoryCapacity.round(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _selector({
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: values
          .map(
            (String item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item.replaceAll('_', ' ').toUpperCase()),
            ),
          )
          .toList(growable: false),
      onChanged: (String? next) {
        if (next != null) onChanged(next);
      },
    );
  }
}
