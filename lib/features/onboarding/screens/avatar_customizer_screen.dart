// Directive G — Screen 5: Avatar Customizer
// GDD §1.1 — Founder's visage customization
// Founder preview with horizontal scrolling chips for Face/Body/Hair/Fit

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/onboarding_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/aurelian_theme.dart';

/// Avatar Customizer Screen — Founder's identity
///
/// Features:
/// - Founder preview driven by selected Face/Body/Hair/Fit values
/// - Bottom sheet customization UI
/// - 4 categories: Face, Body, Hair, Starting Fit
/// - Horizontal scrolling chips for each
class AvatarCustomizerScreen extends ConsumerStatefulWidget {
  const AvatarCustomizerScreen({super.key});

  @override
  ConsumerState<AvatarCustomizerScreen> createState() =>
      _AvatarCustomizerScreenState();
}

class _AvatarCustomizerScreenState
    extends ConsumerState<AvatarCustomizerScreen> {
  int _selectedCategory = 0;

  final List<_CustomizationCategory> _categories =
      const <_CustomizationCategory>[
    _CustomizationCategory(
      name: 'FACE',
      icon: Icons.face,
      options: <String>[
        'Classic',
        'Bold',
        'Youthful',
        'Refined',
        'Avant-Garde',
      ],
    ),
    _CustomizationCategory(
      name: 'BODY',
      icon: Icons.accessibility,
      options: <String>['Slim', 'Athletic', 'Curved', 'Tall', 'Petite'],
    ),
    _CustomizationCategory(
      name: 'HAIR',
      icon: Icons.content_cut,
      options: <String>['Long', 'Short', 'Curly', 'Bald', 'Styled'],
    ),
    _CustomizationCategory(
      name: 'FIT',
      icon: Icons.checkroom,
      options: <String>['Suit', 'Casual', 'Avant', 'Street', 'Couture'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Restore state from provider
    final AvatarConfig? saved = ref.read(onboardingProvider).avatarConfig;
    if (saved != null) {
      // Could restore UI state here
    }
  }

  void _selectOption(int categoryIndex, int optionIndex) {
    HapticFeedback.lightImpact();
    final OnboardingNotifier notifier = ref.read(onboardingProvider.notifier);

    switch (categoryIndex) {
      case 0:
        notifier.updateAvatarFace(optionIndex);
      case 1:
        notifier.updateAvatarBody(optionIndex);
      case 2:
        notifier.updateAvatarHair(optionIndex);
      case 3:
        notifier.updateAvatarFit(optionIndex);
    }
  }

  void _continue() {
    context.push(AppRouter.onboardingCareerPath);
  }

  @override
  Widget build(BuildContext context) {
    final AvatarConfig? currentConfig =
        ref.watch(onboardingProvider).avatarConfig;
    final int faceIndex = currentConfig?.faceIndex ?? 0;
    final int bodyIndex = currentConfig?.bodyIndex ?? 0;
    final int hairIndex = currentConfig?.hairIndex ?? 0;
    final int fitIndex = currentConfig?.fitIndex ?? 0;

    return Scaffold(
      backgroundColor: AurelianPalette.ivory,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            // --- Avatar Preview (full screen behind) ---
            Positioned.fill(
              child: _AvatarPreview(
                faceIndex: faceIndex,
                bodyIndex: bodyIndex,
                hairIndex: hairIndex,
                fitIndex: fitIndex,
              ),
            ),

            // --- Header overlay ---
            Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: _buildHeader(),
            ),

            // --- Bottom customization sheet ---
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: _buildCustomizationSheet()
                  .animate()
                  .fadeIn(delay: const Duration(milliseconds: 300))
                  .slideY(begin: 0.3, end: 0.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AurelianPalette.ivory,
            AurelianPalette.ivory.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'THE FOUNDER',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 4.0,
              color: AurelianPalette.textTertiary,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            'VISAGE',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 32.0,
              fontWeight: FontWeight.w300,
              letterSpacing: 2.0,
              color: AurelianPalette.textPrimary,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Customize your founder\'s appearance',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 14.0,
              color: AurelianPalette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationSheet() {
    return Container(
      decoration: BoxDecoration(
        color: AurelianPalette.ivory,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24.0,
            spreadRadius: 4.0,
            offset: const Offset(0.0, -8.0),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12.0),
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: AurelianPalette.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),

            const SizedBox(height: 24.0),

            // Category tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children:
                    List<Widget>.generate(_categories.length, (int index) {
                  final bool isSelected = _selectedCategory == index;
                  final _CustomizationCategory category = _categories[index];

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedCategory = index);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: index > 0 ? 8.0 : 0.0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AurelianPalette.champagneGold
                                  .withValues(alpha: 0.2)
                              : AurelianPalette.alabaster,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: isSelected
                                ? AurelianPalette.champagneGold
                                : AurelianPalette.textTertiary
                                    .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Icon(
                          category.icon,
                          size: 20.0,
                          color: isSelected
                              ? AurelianPalette.champagneGold
                              : AurelianPalette.textSecondary,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 24.0),

            // Category label
            Text(
              _categories[_selectedCategory].name,
              style: const TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 3.0,
                color: AurelianPalette.textTertiary,
              ),
            ),

            const SizedBox(height: 16.0),

            // Options list
            SizedBox(
              height: 80.0,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                scrollDirection: Axis.horizontal,
                itemCount: _categories[_selectedCategory].options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option =
                      _categories[_selectedCategory].options[index];
                  final int currentSelection =
                      _getCurrentSelection(_selectedCategory);
                  final bool isSelected = currentSelection == index;

                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: _OptionChip(
                      label: option,
                      isSelected: isSelected,
                      onTap: () => _selectOption(_selectedCategory, index),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24.0),

            // Continue button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GestureDetector(
                onTap: _continue,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  decoration: BoxDecoration(
                    color: AurelianPalette.champagneGold,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AurelianPalette.champagneGold
                            .withValues(alpha: 0.3),
                        blurRadius: 16.0,
                        spreadRadius: 2.0,
                        offset: const Offset(0.0, 8.0),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'CONFIRM IDENTITY',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3.0,
                          color: Color(0xFF2A2A2A),
                        ),
                      ),
                      SizedBox(width: 12.0),
                      Icon(
                        Icons.arrow_forward,
                        size: 18.0,
                        color: Color(0xFF2A2A2A),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  int _getCurrentSelection(int categoryIndex) {
    final AvatarConfig? config = ref.read(onboardingProvider).avatarConfig;
    switch (categoryIndex) {
      case 0:
        return config?.faceIndex ?? 0;
      case 1:
        return config?.bodyIndex ?? 0;
      case 2:
        return config?.hairIndex ?? 0;
      case 3:
        return config?.fitIndex ?? 0;
    }
    return 0;
  }
}

// =============================================================================
// Avatar Preview
// =============================================================================

class _AvatarPreview extends StatefulWidget {
  const _AvatarPreview({
    required this.faceIndex,
    required this.bodyIndex,
    required this.hairIndex,
    required this.fitIndex,
  });

  final int faceIndex;
  final int bodyIndex;
  final int hairIndex;
  final int fitIndex;

  @override
  State<_AvatarPreview> createState() => _AvatarPreviewState();
}

class _AvatarPreviewState extends State<_AvatarPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> palette = <Color>[
      AurelianPalette.champagneGold,
      AurelianPalette.softRose,
      AurelianPalette.textSecondary,
      AurelianPalette.textPrimary,
      AurelianPalette.alabaster,
    ];
    final Color accent = palette[widget.fitIndex % palette.length];

    return AnimatedBuilder(
      animation: _rotateController,
      builder: (BuildContext context, Widget? child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                AurelianPalette.ivory,
                accent.withValues(alpha: 0.12),
              ],
            ),
          ),
          child: Center(
            child: Transform.rotate(
              angle: (_rotateController.value - 0.5) * 0.12,
              child: Container(
                width: 220,
                height: 360,
                decoration: BoxDecoration(
                  color: AurelianPalette.alabaster.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(110),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.55),
                    width: 2,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: accent.withValues(alpha: 0.2),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.face_retouching_natural,
                      size: 72,
                      color: AurelianPalette.textPrimary.withValues(
                        alpha: 0.72 + widget.faceIndex * 0.04,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Icon(
                      Icons.accessibility_new,
                      size: 124,
                      color: accent.withValues(
                        alpha: 0.45 + widget.bodyIndex * 0.05,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'FIT ${widget.fitIndex + 1} / HAIR ${widget.hairIndex + 1}',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 10,
                        letterSpacing: 2,
                        color: AurelianPalette.textSecondary
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// UI Components
// =============================================================================

class _CustomizationCategory {
  const _CustomizationCategory({
    required this.name,
    required this.icon,
    required this.options,
  });

  final String name;
  final IconData icon;
  final List<String> options;
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected
              ? AurelianPalette.champagneGold
              : AurelianPalette.alabaster,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected
                ? AurelianPalette.champagneGold
                : AurelianPalette.textTertiary.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 11.0,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: 1.5,
            color: isSelected
                ? const Color(0xFF2A2A2A)
                : AurelianPalette.textSecondary,
          ),
        ),
      ),
    );
  }
}
