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

// =================================================================-----------
// Market Tier for Brand Footprint (Screen 4)
// =================================================================-----------

enum MarketTier {
  highLuxury,   // Low initial sales, massive hype ceiling
  midLuxury,    // Balanced path
  massMarket,   // High initial volume, strict hype caps
}

extension MarketTierExtension on MarketTier {
  String get displayName {
    switch (this) {
      case MarketTier.highLuxury:
        return 'High Luxury';
      case MarketTier.midLuxury:
        return 'Mid Luxury';
      case MarketTier.massMarket:
        return 'Mass Market';
    }
  }
  
  String get description {
    switch (this) {
      case MarketTier.highLuxury:
        return 'Prestige over profit. Low initial sales, massive hype ceiling.';
      case MarketTier.midLuxury:
        return 'The balanced path. Moderate growth in both directions.';
      case MarketTier.massMarket:
        return 'Volume is victory. High initial volume, strict hype caps.';
    }
  }
  
  int get startingCapital {
    switch (this) {
      case MarketTier.highLuxury:
        return 50000;
      case MarketTier.midLuxury:
        return 100000;
      case MarketTier.massMarket:
        return 200000;
    }
  }
  
  int get hypeCeiling {
    switch (this) {
      case MarketTier.highLuxury:
        return 1000000;
      case MarketTier.midLuxury:
        return 500000;
      case MarketTier.massMarket:
        return 100000;
    }
  }
}

// =================================================================-----------
// Avatar Configuration for Avatar Customizer (Screen 5)
// =================================================================-----------

class AvatarConfig {
  const AvatarConfig({
    this.faceIndex = 0,
    this.bodyIndex = 0,
    this.hairIndex = 0,
    this.fitIndex = 0,
  });

  final int faceIndex;
  final int bodyIndex;
  final int hairIndex;
  final int fitIndex;

  AvatarConfig copyWith({
    int? faceIndex,
    int? bodyIndex,
    int? hairIndex,
    int? fitIndex,
  }) {
    return AvatarConfig(
      faceIndex: faceIndex ?? this.faceIndex,
      bodyIndex: bodyIndex ?? this.bodyIndex,
      hairIndex: hairIndex ?? this.hairIndex,
      fitIndex: fitIndex ?? this.fitIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'face': faceIndex,
      'body': bodyIndex,
      'hair': hairIndex,
      'fit': fitIndex,
    };
  }
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
    this.selectedTier,
    this.avatarConfig,
    this.isCommitting = false,
    this.commitError,
    this.genesisProgress = 0.0,
  });

  final String brandName;
  final CareerPath? selectedPath;
  final HqCity? selectedCity;
  final MarketTier? selectedTier;        // NEW: Screen 4
  final AvatarConfig? avatarConfig;        // NEW: Screen 5

  /// True while createPlayerProfile is in-flight.
  final bool isCommitting;

  /// Non-null if the Supabase commit failed.
  final String? commitError;
  
  /// White-out animation progress (0.0 → 1.0)
  final double genesisProgress;

  bool get isReadyToCommit =>
      validateBrandName(brandName) == BrandNameValidationResult.valid &&
      selectedPath != null &&
      selectedCity != null &&
      selectedTier != null;

  OnboardingState copyWith({
    String? brandName,
    CareerPath? selectedPath,
    HqCity? selectedCity,
    MarketTier? selectedTier,
    AvatarConfig? avatarConfig,
    bool? isCommitting,
    String? commitError,
    double? genesisProgress,
    bool clearError = false,
  }) {
    return OnboardingState(
      brandName: brandName ?? this.brandName,
      selectedPath: selectedPath ?? this.selectedPath,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedTier: selectedTier ?? this.selectedTier,
      avatarConfig: avatarConfig ?? this.avatarConfig,
      isCommitting: isCommitting ?? this.isCommitting,
      commitError: clearError ? null : (commitError ?? this.commitError),
      genesisProgress: genesisProgress ?? this.genesisProgress,
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
  
  void setTier(MarketTier tier) {
    state = state.copyWith(selectedTier: tier, clearError: true);
  }
  
  void setAvatarConfig(AvatarConfig config) {
    state = state.copyWith(avatarConfig: config, clearError: true);
  }
  
  void updateAvatarFace(int index) {
    final AvatarConfig current = state.avatarConfig ?? const AvatarConfig();
    state = state.copyWith(avatarConfig: current.copyWith(faceIndex: index));
  }
  
  void updateAvatarBody(int index) {
    final AvatarConfig current = state.avatarConfig ?? const AvatarConfig();
    state = state.copyWith(avatarConfig: current.copyWith(bodyIndex: index));
  }
  
  void updateAvatarHair(int index) {
    final AvatarConfig current = state.avatarConfig ?? const AvatarConfig();
    state = state.copyWith(avatarConfig: current.copyWith(hairIndex: index));
  }
  
  void updateAvatarFit(int index) {
    final AvatarConfig current = state.avatarConfig ?? const AvatarConfig();
    state = state.copyWith(avatarConfig: current.copyWith(fitIndex: index));
  }

  void setCommitting({required bool value}) {
    state = state.copyWith(isCommitting: value);
  }
  
  void setGenesisProgress(double progress) {
    state = state.copyWith(genesisProgress: progress);
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
