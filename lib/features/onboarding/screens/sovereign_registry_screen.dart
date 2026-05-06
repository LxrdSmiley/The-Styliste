// GDD §1.1 Screen 3 — Sovereign Registry
// Brand naming screen: minimalist input, animated gold underline on focus,
// live validation (3–15 chars, alphanumeric, blocklist), feed name preview.
// Stores brand_name in onboardingProvider and advances to Career Path.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/onboarding_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';

class SovereignRegistryScreen extends ConsumerStatefulWidget {
  const SovereignRegistryScreen({super.key});

  @override
  ConsumerState<SovereignRegistryScreen> createState() =>
      _SovereignRegistryScreenState();
}

class _SovereignRegistryScreenState
    extends ConsumerState<SovereignRegistryScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _focused = false;
  String? _liveError;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    // Restore any in-progress brand name from provider.
    final String saved = ref.read(onboardingProvider).brandName;
    if (saved.isNotEmpty) {
      _controller.text = saved;
    }
    // Auto-focus on next frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _onFocusChange() {
    setState(() => _focused = _focusNode.hasFocus);
  }

  void _onChanged(String value) {
    ref.read(onboardingProvider.notifier).setBrandName(value);
    setState(() => _liveError = brandNameError(value));
  }

  void _onConfirm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    HapticFeedback.mediumImpact();
    context.go(AppRouter.onboardingCareerPath);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String currentName = ref.watch(
      onboardingProvider.select((OnboardingState s) => s.brandName),
    );
    final bool canProceed =
        validateBrandName(currentName) == BrandNameValidationResult.valid;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 64.0),

                // --- Header ---
                const Text(
                  'NAME YOUR\nEMPIRE.',
                  style: TextStyle(
                    color: AppColors.ivory,
                    fontSize: 36.0,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    letterSpacing: 2.0,
                  ),
                )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 500))
                    .slideY(begin: 0.08, curve: Curves.easeOut),

                const SizedBox(height: 8.0),

                const Text(
                  'This is permanent. Choose wisely.',
                  style: TextStyle(
                    color: AppColors.grey400,
                    fontSize: 13.0,
                    letterSpacing: 0.5,
                  ),
                )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 400),
                    ),

                const SizedBox(height: 56.0),

                // --- Brand name input with animated gold underline ---
                TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _onChanged,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: <TextInputFormatter>[
                    // Strip anything outside alphanumeric + space
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Z0-9 ]'),
                    ),
                    LengthLimitingTextInputFormatter(15),
                  ],
                  style: const TextStyle(
                    color: AppColors.ivory,
                    fontSize: 28.0,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 4.0,
                  ),
                  cursorColor: AppColors.gold,
                  decoration: InputDecoration(
                    hintText: 'BRAND NAME',
                    hintStyle: const TextStyle(
                      color: AppColors.grey600,
                      fontSize: 28.0,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4.0,
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.grey700,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.gold,
                        width: 2.0,
                      ),
                    ),
                    errorBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.danger, width: 1.5),
                    ),
                    focusedErrorBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.danger, width: 2.0),
                    ),
                    errorText: _liveError,
                    errorStyle: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 12.0,
                    ),
                    // Animated gold underline glow when focused
                    suffixIcon: _focused
                        ? const Icon(
                            Icons.edit,
                            color: AppColors.gold,
                            size: 16.0,
                          )
                              .animate(
                                onPlay: (AnimationController c) => c.repeat(reverse: true),
                              )
                              .fadeIn(duration: const Duration(milliseconds: 600))
                        : null,
                  ),
                  validator: (String? value) =>
                      brandNameError(value ?? ''),
                ),

                const SizedBox(height: 24.0),

                // --- Live feed preview ---
                if (canProceed)
                  AnimatedOpacity(
                    opacity: canProceed ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.public,
                          color: AppColors.grey400,
                          size: 14.0,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          'Global feed: @${currentName.trim().replaceAll(' ', '_').toLowerCase()}',
                          style: const TextStyle(
                            color: AppColors.grey400,
                            fontSize: 12.0,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                const Spacer(),

                // --- Confirm CTA ---
                SizedBox(
                  width: double.infinity,
                  child: AnimatedOpacity(
                    opacity: canProceed ? 1.0 : 0.3,
                    duration: const Duration(milliseconds: 300),
                    child: ElevatedButton(
                      onPressed: canProceed ? _onConfirm : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.obsidian,
                        disabledBackgroundColor: AppColors.grey700,
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                      child: const Text(
                        'CLAIM THIS NAME',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3.0,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
