import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/styliste_colors.dart';
import '../../../core/theme/styliste_spacing.dart';
import '../../../core/theme/styliste_typography.dart';
import '../../../core/theme/styliste_visual_mode.dart';
import '../../../core/widgets/aurelian_components.dart';
import '../../../core/widgets/styliste_buttons.dart';
import '../../../core/widgets/styliste_scaffold.dart';
import '../providers/founder_trial_provider.dart';

class FounderTrialScreen extends ConsumerStatefulWidget {
  const FounderTrialScreen({super.key});

  @override
  ConsumerState<FounderTrialScreen> createState() => _FounderTrialScreenState();
}

class _FounderTrialScreenState extends ConsumerState<FounderTrialScreen> {
  late final TextEditingController _brandNameController;

  @override
  void initState() {
    super.initState();
    _brandNameController = TextEditingController(
      text: ref.read(onboardingProvider).brandName,
    );
  }

  @override
  void dispose() {
    _brandNameController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final String brandName = _brandNameController.text.trim();
    if (brandName.length < 2 || brandName.length > 40) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose a House name between 2 and 40 characters.'),
        ),
      );
      return;
    }
    ref.read(onboardingProvider.notifier).setBrandName(brandName);
    try {
      await ref.read(supabaseAuthActionsProvider).requireEstablishedUserId();
      await ref
          .read(founderTrialProvider.notifier)
          .initialize(brandName: brandName);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your secure game session is not ready. Retry safely.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final FounderTrialState state = ref.watch(founderTrialProvider);
    final FounderTrialNotifier actions = ref.read(
      founderTrialProvider.notifier,
    );

    return AurelianScaffold(
      mode: StylisteVisualMode.noirCinematic,
      appBar: const AurelianContextualAppBar(
        eyebrow: 'Kingston House',
        title: 'Founder Trial',
      ),
      body: AurelianResponsiveBody(
        maxWidth: 580,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _TrialProgress(stage: state.stage),
            const SizedBox(height: StylisteSpacing.lg),
            const LuxeGuidanceCard(
              mode: StylisteVisualMode.noirCinematic,
              message:
                  'One shared garment. One authorship choice. One positioning choice. Neither path raises your gameplay ceiling.',
            ),
            if (state.restored) ...<Widget>[
              const SizedBox(height: StylisteSpacing.md),
              const AurelianStatusChip(
                label: 'Restored from your House record',
                icon: Icons.restore,
                tone: AurelianStatusTone.positive,
              ),
            ],
            const SizedBox(height: StylisteSpacing.lg),
            AurelianMotionSwap(
              identity: state.stage,
              child: _stageBody(context, state, actions),
            ),
            if (state.error != null) ...<Widget>[
              const SizedBox(height: StylisteSpacing.md),
              AurelianStatePanel(
                kind: AurelianStateKind.retryableError,
                title: 'The last step was not confirmed',
                message: state.error!,
                actionLabel: 'Retry the same step',
                onAction: () => unawaited(actions.retry()),
                compact: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stageBody(
    BuildContext context,
    FounderTrialState state,
    FounderTrialNotifier actions,
  ) {
    if (state.isSubmitting) {
      return const AurelianStatePanel(
        kind: AurelianStateKind.loading,
        title: 'Confirming with your House record',
        message:
            'Your current choice is locked locally while the server records it once.',
      );
    }

    return switch (state.stage) {
      FounderTrialStage.notStarted => _houseNameStep(),
      FounderTrialStage.sharedStarterGarment => _TrialChoiceStep(
          eyebrow: 'Artisan sample',
          title: 'Author the garment',
          detail:
              'Choose how the shared starter garment carries your hand. This records a design cause, not a score.',
          firstLabel: 'Draped bodice',
          firstDetail: 'Fluid line, softer structure, movement first.',
          secondLabel: 'Structured bodice',
          secondDetail: 'Defined line, tailored hold, construction first.',
          onFirst: () => unawaited(
            actions.chooseArtisanSample('draped_bodice'),
          ),
          onSecond: () => unawaited(
            actions.chooseArtisanSample('structured_bodice'),
          ),
        ),
      FounderTrialStage.artisanSample => _TrialChoiceStep(
          eyebrow: 'Architect sample',
          title: 'Position the same garment',
          detail:
              'Choose how it reaches Kingston. The garment is unchanged; the operating decision is different.',
          firstLabel: 'Limited collector run',
          firstDetail: 'Narrow reach, controlled scarcity, focused signal.',
          secondLabel: 'Neighborhood run',
          secondDetail:
              'Broader local proof, community visibility, measured run.',
          onFirst: () => unawaited(
            actions.chooseArchitectSample('limited_run'),
          ),
          onSecond: () => unawaited(
            actions.chooseArchitectSample('neighborhood_run'),
          ),
        ),
      FounderTrialStage.architectSample => _TrialResultStep(
          onContinue: () => unawaited(actions.revealSharedResult()),
        ),
      FounderTrialStage.resultVisible => _TrialChoiceStep(
          eyebrow: 'One useful response',
          title: 'Choose the next decision',
          detail:
              'Respond to the visible result. Luxe records your decision without hidden praise or a client-owned score.',
          firstLabel: 'Refine the silhouette',
          firstDetail: 'Return to authorship and clarify the garment line.',
          secondLabel: 'Adjust the run plan',
          secondDetail: 'Return to positioning and revise the operating shape.',
          onFirst: () => unawaited(
            actions.chooseResponse('refine_silhouette'),
          ),
          onSecond: () => unawaited(
            actions.chooseResponse('adjust_run_plan'),
          ),
        ),
      FounderTrialStage.revisionOrBusinessResponse => _FounderPathStep(
          onArtisan: () => unawaited(
            actions.chooseSpecialization('artisan'),
          ),
          onArchitect: () => unawaited(
            actions.chooseSpecialization('architect'),
          ),
        ),
      FounderTrialStage.completed => _CompletedTrial(
          specialization: state.specialization,
          receiptId: state.receiptId,
          restored: state.restored,
          onContinue: () => context.go(AppRouter.atelierCapsule),
        ),
    };
  }

  Widget _houseNameStep() {
    return AurelianCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const AurelianSectionHeader(
            eyebrow: 'House identity',
            title: 'Name the House you are building',
            detail:
                'This name is submitted with your authenticated founder identity and can be resumed safely.',
          ),
          const SizedBox(height: StylisteSpacing.lg),
          TextField(
            controller: _brandNameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            maxLength: 40,
            autofillHints: const <String>[AutofillHints.organizationName],
            decoration: const InputDecoration(
              labelText: 'House name',
              hintText: 'House Meridian',
              helperText: '2–40 characters',
            ),
            onSubmitted: (_) => unawaited(_initialize()),
          ),
          const SizedBox(height: StylisteSpacing.md),
          GoldPrimaryButton(
            label: 'Begin the Founder Trial',
            icon: Icons.arrow_forward,
            onPressed: _initialize,
          ),
        ],
      ),
    );
  }
}

class _TrialProgress extends StatelessWidget {
  const _TrialProgress({required this.stage});

  final FounderTrialStage stage;

  @override
  Widget build(BuildContext context) {
    final int current = switch (stage) {
      FounderTrialStage.notStarted => 0,
      FounderTrialStage.sharedStarterGarment => 1,
      FounderTrialStage.artisanSample => 2,
      FounderTrialStage.architectSample => 3,
      FounderTrialStage.resultVisible => 4,
      FounderTrialStage.revisionOrBusinessResponse => 5,
      FounderTrialStage.completed => 6,
    };
    return Semantics(
      label: 'Founder Trial progress. Step $current of 6.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'FOUNDER TRIAL',
                  style: StylisteText.labelCaps.copyWith(
                    color: StylisteColors.champagneGold,
                  ),
                ),
              ),
              Text(
                '$current / 6',
                style: StylisteText.metricSmall.copyWith(
                  color: StylisteColors.warmGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: StylisteSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: current / 6,
              minHeight: 6,
              color: StylisteColors.champagneGold,
              backgroundColor: StylisteColors.outlineDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrialChoiceStep extends StatelessWidget {
  const _TrialChoiceStep({
    required this.eyebrow,
    required this.title,
    required this.detail,
    required this.firstLabel,
    required this.firstDetail,
    required this.secondLabel,
    required this.secondDetail,
    required this.onFirst,
    required this.onSecond,
  });

  final String eyebrow;
  final String title;
  final String detail;
  final String firstLabel;
  final String firstDetail;
  final String secondLabel;
  final String secondDetail;
  final VoidCallback onFirst;
  final VoidCallback onSecond;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AurelianSectionHeader(
          eyebrow: eyebrow,
          title: title,
          detail: detail,
        ),
        const SizedBox(height: StylisteSpacing.md),
        _DecisionCard(
          label: firstLabel,
          detail: firstDetail,
          icon: Icons.gesture_outlined,
          onPressed: onFirst,
        ),
        const SizedBox(height: StylisteSpacing.sm),
        _DecisionCard(
          label: secondLabel,
          detail: secondDetail,
          icon: Icons.architecture_outlined,
          onPressed: onSecond,
        ),
      ],
    );
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({
    required this.label,
    required this.detail,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final String detail;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AurelianCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Icon(
            icon,
            color: StylisteColors.champagneGold,
            size: StylisteSpacing.iconLg,
            semanticLabel: label,
          ),
          const SizedBox(height: StylisteSpacing.sm),
          Text(label, style: StylisteText.title),
          const SizedBox(height: StylisteSpacing.xs),
          Text(
            detail,
            style: StylisteText.body.copyWith(
              color: StylisteColors.warmGrey,
            ),
          ),
          const SizedBox(height: StylisteSpacing.md),
          IvorySecondaryButton(
            label: 'Choose $label',
            icon: Icons.arrow_forward,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class _TrialResultStep extends StatelessWidget {
  const _TrialResultStep({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const AurelianSectionHeader(
          eyebrow: 'Visible result',
          title: 'Two decisions, one garment',
          detail:
              'Authorship shaped the garment. Positioning shaped its route through Kingston. Neither created a hidden advantage.',
        ),
        const SizedBox(height: StylisteSpacing.md),
        const AurelianCard(
          child: Column(
            children: <Widget>[
              _CauseRow(
                icon: Icons.checkroom_outlined,
                label: 'Artisan cause',
                value: 'Garment line and construction',
              ),
              Divider(height: StylisteSpacing.lg),
              _CauseRow(
                icon: Icons.storefront_outlined,
                label: 'Architect cause',
                value: 'Run shape and local reach',
              ),
              Divider(height: StylisteSpacing.lg),
              _CauseRow(
                icon: Icons.balance_outlined,
                label: 'Gameplay ceiling',
                value: 'Equal for both Founder Paths',
              ),
            ],
          ),
        ),
        const SizedBox(height: StylisteSpacing.md),
        GoldPrimaryButton(
          label: 'Make one response',
          icon: Icons.arrow_forward,
          onPressed: onContinue,
        ),
      ],
    );
  }
}

class _CauseRow extends StatelessWidget {
  const _CauseRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          icon,
          color: StylisteColors.champagneGold,
          semanticLabel: label,
        ),
        const SizedBox(width: StylisteSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: StylisteText.labelCaps),
              const SizedBox(height: StylisteSpacing.xxs),
              Text(value, style: StylisteText.body),
            ],
          ),
        ),
      ],
    );
  }
}

class _FounderPathStep extends StatelessWidget {
  const _FounderPathStep({
    required this.onArtisan,
    required this.onArchitect,
  });

  final VoidCallback onArtisan;
  final VoidCallback onArchitect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const AurelianSectionHeader(
          eyebrow: 'Founder Path',
          title: 'Choose the lens you lead with',
          detail:
              'Your lead lens changes emphasis and language. It never changes access, scoring ceilings, strategic options, or authoritative outcomes.',
        ),
        const SizedBox(height: StylisteSpacing.md),
        _PathCard(
          title: 'Artisan',
          subtitle: 'Lead with authorship',
          detail:
              'Begin from silhouette, material, construction, and the emotional clarity of the garment.',
          icon: Icons.draw_outlined,
          onPressed: onArtisan,
        ),
        const SizedBox(height: StylisteSpacing.sm),
        _PathCard(
          title: 'Architect',
          subtitle: 'Lead with positioning',
          detail:
              'Begin from audience, run shape, operating trade-offs, and how the House enters the market.',
          icon: Icons.account_tree_outlined,
          onPressed: onArchitect,
        ),
        const SizedBox(height: StylisteSpacing.md),
        const AurelianStatusChip(
          label: 'Equal gameplay ceiling',
          icon: Icons.balance_outlined,
          tone: AurelianStatusTone.positive,
        ),
      ],
    );
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String detail;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AurelianCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                icon,
                color: StylisteColors.champagneGold,
                semanticLabel: title,
              ),
              const SizedBox(width: StylisteSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: StylisteText.headline),
                    Text(
                      subtitle,
                      style: StylisteText.bodySmall.copyWith(
                        color: StylisteColors.warmGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: StylisteSpacing.sm),
          Text(detail, style: StylisteText.body),
          const SizedBox(height: StylisteSpacing.md),
          GoldPrimaryButton(
            label: 'Lead as $title',
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class _CompletedTrial extends StatelessWidget {
  const _CompletedTrial({
    required this.specialization,
    required this.receiptId,
    required this.restored,
    required this.onContinue,
  });

  final String? specialization;
  final String? receiptId;
  final bool restored;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final String lens = specialization == 'architect' ? 'Architect' : 'Artisan';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AurelianStatePanel(
          kind: restored
              ? AurelianStateKind.restored
              : AurelianStateKind.confirmed,
          title: '$lens lens confirmed',
          message:
              'Your server-owned Founder Path is recorded. Both lenses remain available with equal gameplay ceilings.',
        ),
        if (receiptId != null) ...<Widget>[
          const SizedBox(height: StylisteSpacing.md),
          AurelianReceiptPanel(
            title: 'Founder Trial completion',
            receiptId: receiptId!,
            restored: restored,
            detail: 'No currency, Hype, reward, or launch result was issued.',
          ),
        ],
        const SizedBox(height: StylisteSpacing.md),
        GoldPrimaryButton(
          label: 'Open the Kingston Capsule',
          icon: Icons.arrow_forward,
          onPressed: onContinue,
        ),
      ],
    );
  }
}
