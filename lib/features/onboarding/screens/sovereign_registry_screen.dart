// GDD v8 §§18, 21, 22 — local House-name intent before Founder Trial.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/onboarding_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/styliste_colors.dart';
import '../../../core/theme/styliste_spacing.dart';
import '../../../core/theme/styliste_typography.dart';
import '../../../core/theme/styliste_visual_mode.dart';
import '../../../core/widgets/aurelian_components.dart';
import '../../../core/widgets/styliste_buttons.dart';
import '../../../core/widgets/styliste_scaffold.dart';

class SovereignRegistryScreen extends ConsumerStatefulWidget {
  const SovereignRegistryScreen({super.key});

  @override
  ConsumerState<SovereignRegistryScreen> createState() =>
      _SovereignRegistryScreenState();
}

class _SovereignRegistryScreenState
    extends ConsumerState<SovereignRegistryScreen> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _liveError;

  @override
  void initState() {
    super.initState();
    final String saved = ref.read(onboardingProvider).brandName;
    if (saved.isNotEmpty) _controller.text = saved;
  }

  void _onChanged(String value) {
    ref.read(onboardingProvider.notifier).setBrandName(value);
    setState(() => _liveError = brandNameError(value));
  }

  void _onConfirm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.go(AppRouter.onboardingFounderTrial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String currentName = ref.watch(
      onboardingProvider.select((OnboardingState state) => state.brandName),
    );
    final bool canProceed =
        validateBrandName(currentName) == BrandNameValidationResult.valid;

    return AurelianScaffold(
      mode: StylisteVisualMode.noirCinematic,
      appBar: const AurelianContextualAppBar(
        eyebrow: 'Kingston House',
        title: 'House Identity',
      ),
      body: AurelianResponsiveBody(
        maxWidth: 560,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const AurelianSectionHeader(
                eyebrow: 'Name the House',
                title: 'Give the work a name it can grow into',
                detail:
                    'This is local draft intent until the authenticated Founder Trial confirms it server-side.',
              ),
              const SizedBox(height: StylisteSpacing.lg),
              AurelianCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _controller,
                      autofocus: true,
                      onChanged: _onChanged,
                      onFieldSubmitted: (_) {
                        if (canProceed) _onConfirm();
                      },
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      maxLength: 40,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9 ]'),
                        ),
                      ],
                      style: StylisteText.headline.copyWith(
                        color: StylisteColors.ivory,
                      ),
                      decoration: InputDecoration(
                        labelText: 'House name',
                        hintText: 'House Meridian',
                        helperText: '2–40 letters, numbers, or spaces',
                        errorText: _liveError,
                      ),
                      validator: (String? value) => brandNameError(value ?? ''),
                    ),
                    if (canProceed) ...<Widget>[
                      const SizedBox(height: StylisteSpacing.md),
                      Semantics(
                        label: 'House-name preview. $currentName.',
                        child: Container(
                          padding: const EdgeInsets.all(StylisteSpacing.md),
                          decoration: BoxDecoration(
                            color: StylisteColors.champagneGold.withValues(
                              alpha: 0.1,
                            ),
                            border: Border.all(
                              color: StylisteColors.champagneGold.withValues(
                                alpha: 0.56,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'EDITORIAL PREVIEW',
                                style: StylisteText.labelCaps.copyWith(
                                  color: StylisteColors.champagneGold,
                                ),
                              ),
                              const SizedBox(height: StylisteSpacing.xs),
                              Text(
                                currentName.trim(),
                                style: StylisteText.displayEditorial.copyWith(
                                  color: StylisteColors.ivory,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: StylisteSpacing.lg),
              GoldPrimaryButton(
                label: 'Continue to the Founder Trial',
                icon: Icons.arrow_forward,
                disabledReason:
                    canProceed ? null : 'Enter a valid House name to continue.',
                onPressed: canProceed ? _onConfirm : null,
              ),
              const SizedBox(height: StylisteSpacing.sm),
              Text(
                'No player ID, House ownership, progression, or reward value is chosen here.',
                textAlign: TextAlign.center,
                style: StylisteText.bodySmall.copyWith(
                  color: StylisteColors.warmGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
