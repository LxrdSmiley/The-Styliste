// Phase 1b — Onboarding state management
// Holds transient brand_name + path selection across the onboarding screens.
// Written to Supabase only after Career Path confirmation (GDD §1.1 Screen 6).
// PROJECT_RULES §3 — Riverpod StateNotifier; no direct DB writes from UI.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/player.dart';

// ---------------------------------------------------------------------------
// Brand name validation
// ---------------------------------------------------------------------------

/// Basic local profanity blocklist — extended in Phase 4 with server-side check.
const List<String> _kBlocklist = <String>[
  'fuck', 'shit', 'ass', 'bitch', 'cunt', 'dick', 'pussy', 'cock',
  'nigga', 'nigger', 'faggot', 'retard',
];

enum BrandNameValidationResult {
  valid,
  tooShort,       // < 3 chars
  tooLong,        // > 15 chars
  invalidChars,   // not alphanumeric (spaces allowed between words)
  blocklisted,    // matches local profanity list
}

/// Validates a brand name against all Phase 1b rules.
BrandNameValidationResult validateBrandName(String name) {
  final String trimmed = name.trim();

  if (trimmed.length < 3) return BrandNameValidationResult.tooShort;
  if (trimmed.length > 15) return BrandNameValidationResult.tooLong;

  // Alphanumeric + single internal spaces only — no special chars
  final RegExp validPattern = RegExp(r'^[a-zA-Z0-9]([a-zA-Z0-9 ]*[a-zA-Z0-9])?$');
  if (!validPattern.hasMatch(trimmed)) {
    return BrandNameValidationResult.invalidChars;
  }

  final String lower = trimmed.toLowerCase();
  for (final String word in _kBlocklist) {
    if (lower.contains(word)) return BrandNameValidationResult.blocklisted;
  }

  return BrandNameValidationResult.valid;
}

String? brandNameError(String name) {
  return switch (validateBrandName(name)) {
    BrandNameValidationResult.valid => null,
    BrandNameValidationResult.tooShort => 'Brand name must be at least 3 characters.',
    BrandNameValidationResult.tooLong => 'Brand name must be 15 characters or fewer.',
    BrandNameValidationResult.invalidChars =>
      'Alphanumeric characters only. No special symbols.',
    BrandNameValidationResult.blocklisted =>
      'That name isn\'t allowed. Choose something else, darling.',
  };
}

// ---------------------------------------------------------------------------
// Onboarding state
// ---------------------------------------------------------------------------

class OnboardingState {
  const OnboardingState({
    this.brandName = '',
    this.selectedPath,
    this.selectedCity,
    this.isCommitting = false,
    this.commitError,
  });

  final String brandName;
  final CareerPath? selectedPath;
  final HqCity? selectedCity;

  /// True while createPlayerProfile is in-flight.
  final bool isCommitting;

  /// Non-null if the Supabase commit failed.
  final String? commitError;

  bool get isReadyToCommit =>
      validateBrandName(brandName) == BrandNameValidationResult.valid &&
      selectedPath != null &&
      selectedCity != null;

  OnboardingState copyWith({
    String? brandName,
    CareerPath? selectedPath,
    HqCity? selectedCity,
    bool? isCommitting,
    String? commitError,
    bool clearError = false,
  }) {
    return OnboardingState(
      brandName: brandName ?? this.brandName,
      selectedPath: selectedPath ?? this.selectedPath,
      selectedCity: selectedCity ?? this.selectedCity,
      isCommitting: isCommitting ?? this.isCommitting,
      commitError: clearError ? null : (commitError ?? this.commitError),
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void setBrandName(String name) {
    state = state.copyWith(brandName: name, clearError: true);
  }

  void setPath(CareerPath path) {
    state = state.copyWith(selectedPath: path, clearError: true);
  }

  void setCity(HqCity city) {
    state = state.copyWith(selectedCity: city, clearError: true);
  }

  void setCommitting({required bool value}) {
    state = state.copyWith(isCommitting: value);
  }

  void setCommitError(String error) {
    state = state.copyWith(commitError: error, isCommitting: false);
  }

  void reset() {
    state = const OnboardingState();
  }
}

final StateNotifierProvider<OnboardingNotifier, OnboardingState>
    onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (Ref<OnboardingState> ref) => OnboardingNotifier(),
);
