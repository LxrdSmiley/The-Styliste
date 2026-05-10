// Directive G — Screen 4: Brand Footprint
// GDD §1.1 — City selection + Market Tier selection
// Atmospheric VFX: Snow for NYC, cherry blossoms for Tokyo
// Alabaster Standard: Deeply minimalist, SpaceGrotesk typography

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/onboarding_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/aurelian_theme.dart';
import '../../../domain/models/player.dart';

/// Brand Footprint Screen — City + Tier Selection
/// 
/// Flow:
/// 1. Select HQ City (NYC, Paris, Tokyo, Milan)
/// 2. Select Market Tier (High/Mid/Mass)
/// 3. Continue to Avatar Customizer
class BrandFootprintScreen extends ConsumerStatefulWidget {
  const BrandFootprintScreen({super.key});

  @override
  ConsumerState<BrandFootprintScreen> createState() => _BrandFootprintScreenState();
}

class _BrandFootprintScreenState extends ConsumerState<BrandFootprintScreen> {
  HqCity? _selectedCity;
  MarketTier? _selectedTier;
  int _currentStep = 0; // 0 = city, 1 = tier

  final List<HqCity> _cities = const <HqCity>[
    HqCity.newYork,
    HqCity.paris,
    HqCity.tokyo,
    HqCity.milan,
  ];

  @override
  void initState() {
    super.initState();
    // Restore state from provider
    final OnboardingState state = ref.read(onboardingProvider);
    _selectedCity = state.selectedCity;
    _selectedTier = state.selectedTier;
    if (_selectedCity != null && _selectedTier == null) {
      _currentStep = 1;
    }
  }

  void _selectCity(HqCity city) {
    HapticFeedback.mediumImpact();
    setState(() => _selectedCity = city);
    ref.read(onboardingProvider.notifier).setCity(city);
    
    // Auto-advance to tier after short delay
    Future<void>.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _currentStep = 1);
      }
    });
  }

  void _selectTier(MarketTier tier) {
    HapticFeedback.heavyImpact();
    setState(() => _selectedTier = tier);
    ref.read(onboardingProvider.notifier).setTier(tier);
  }

  void _continue() {
    if (_selectedCity != null && _selectedTier != null) {
      context.push(AppRouter.onboardingAvatarCustomiser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AurelianPalette.ivory,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // --- Header ---
            _buildHeader(),
            
            const SizedBox(height: 32.0),
            
            // --- Progress indicator ---
            _buildProgressIndicator(),
            
            const SizedBox(height: 32.0),
            
            // --- Content area ---
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _currentStep == 0
                    ? _CitySelectionStep(
                        key: const ValueKey<String>('city'),
                        cities: _cities,
                        selectedCity: _selectedCity,
                        onSelect: _selectCity,
                      )
                    : _TierSelectionStep(
                        key: const ValueKey<String>('tier'),
                        selectedTier: _selectedTier,
                        onSelect: _selectTier,
                        onBack: () => setState(() => _currentStep = 0),
                      ),
              ),
            ),
            
            // --- Continue button ---
            if (_selectedCity != null && _selectedTier != null)
              _buildContinueButton()
                  .animate()
                  .fadeIn(delay: const Duration(milliseconds: 200))
                  .slideY(begin: 0.3, end: 0.0),
            
            const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'YOUR GLOBAL',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 4.0,
              color: AurelianPalette.textTertiary,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'FOOTPRINT',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 32.0,
              fontWeight: FontWeight.w300,
              letterSpacing: 2.0,
              color: AurelianPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            _currentStep == 0
                ? 'Choose your empire\'s headquarters'
                : 'Select your market position',
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

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: 2.0,
              color: _currentStep >= 0
                  ? AurelianPalette.champagneGold
                  : AurelianPalette.textTertiary.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Container(
              height: 2.0,
              color: _currentStep >= 1
                  ? AurelianPalette.champagneGold
                  : AurelianPalette.textTertiary.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Padding(
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
                color: AurelianPalette.champagneGold.withValues(alpha: 0.3),
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
                'CONTINUE',
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
    );
  }
}

// =============================================================================
// City Selection Step
// =============================================================================

class _CitySelectionStep extends StatelessWidget {
  const _CitySelectionStep({
    super.key,
    required this.cities,
    required this.selectedCity,
    required this.onSelect,
  });

  final List<HqCity> cities;
  final HqCity? selectedCity;
  final ValueChanged<HqCity> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      itemCount: cities.length,
      itemBuilder: (BuildContext context, int index) {
        final HqCity city = cities[index];
        final bool isSelected = selectedCity == city;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _CityCard(
            city: city,
            isSelected: isSelected,
            onTap: () => onSelect(city),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: index * 100))
              .slideX(begin: 0.2, end: 0.0),
        );
      },
    );
  }
}

class _CityCard extends StatelessWidget {
  const _CityCard({
    required this.city,
    required this.isSelected,
    required this.onTap,
  });

  final HqCity city;
  final bool isSelected;
  final VoidCallback onTap;

  String get _cityName {
    switch (city) {
      case HqCity.newYork:
        return 'NEW YORK';
      case HqCity.paris:
        return 'PARIS';
      case HqCity.tokyo:
        return 'TOKYO';
      case HqCity.milan:
        return 'MILAN';
      default:
        return city.name.toUpperCase();
    }
  }

  String get _cityTagline {
    switch (city) {
      case HqCity.newYork:
        return 'The Concrete Runway';
      case HqCity.paris:
        return 'Capital of Couture';
      case HqCity.tokyo:
        return 'Where Tradition Meets Future';
      case HqCity.milan:
        return "The Designer's Sanctuary";
      default:
        return '';
    }
  }

  Widget? get _atmosphericEffect {
    switch (city) {
      case HqCity.newYork:
        return const _SnowfallEffect();
      case HqCity.tokyo:
        return const _PetalEffect();
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140.0,
        decoration: BoxDecoration(
          color: isSelected
              ? AurelianPalette.champagneGold.withValues(alpha: 0.2)
              : AurelianPalette.alabaster,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected
                ? AurelianPalette.champagneGold
                : AurelianPalette.textTertiary.withValues(alpha: 0.2),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Stack(
            children: <Widget>[
              // Atmospheric effect
              if (_atmosphericEffect != null)
                Positioned.fill(child: _atmosphericEffect!),
              
              // City gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      _getCityColor().withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      _cityName,
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 24.0,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        letterSpacing: 2.0,
                        color: AurelianPalette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      _cityTagline,
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 12.0,
                        color: AurelianPalette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Selection indicator
              if (isSelected)
                Positioned(
                  top: 16.0,
                  right: 16.0,
                  child: Container(
                    width: 24.0,
                    height: 24.0,
                    decoration: BoxDecoration(
                      color: AurelianPalette.champagneGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCityColor() {
    switch (city) {
      case HqCity.newYork:
        return const Color(0xFF6B7B8C); // Cool grey
      case HqCity.paris:
        return const Color(0xFFD4AF37); // Gold
      case HqCity.tokyo:
        return const Color(0xFFFFB7C5); // Soft rose
      case HqCity.milan:
        return const Color(0xFF8B7355); // Warm brown
      default:
        return AurelianPalette.champagneGold;
    }
  }
}

// =============================================================================
// Atmospheric Effects
// =============================================================================

class _SnowfallEffect extends StatefulWidget {
  const _SnowfallEffect();

  @override
  State<_SnowfallEffect> createState() => _SnowfallEffectState();
}

class _SnowfallEffectState extends State<_SnowfallEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Snowflake> _snowflakes = <_Snowflake>[];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    // Generate random snowflakes
    for (int i = 0; i < 20; i++) {
      _snowflakes.add(_Snowflake.random());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _SnowfallPainter(
            snowflakes: _snowflakes,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _Snowflake {
  _Snowflake({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.wobble,
  });

  factory _Snowflake.random() {
    final math.Random random = math.Random();
    return _Snowflake(
      x: random.nextDouble(),
      y: random.nextDouble(),
      size: 1.0 + random.nextDouble() * 2.0,
      speed: 0.3 + random.nextDouble() * 0.5,
      wobble: random.nextDouble() * math.pi * 2,
    );
  }

  final double x;
  final double y;
  final double size;
  final double speed;
  final double wobble;
}

class _SnowfallPainter extends CustomPainter {
  _SnowfallPainter({
    required this.snowflakes,
    required this.progress,
  });

  final List<_Snowflake> snowflakes;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    for (final _Snowflake flake in snowflakes) {
      final double y = ((flake.y + progress * flake.speed) % 1.0) * size.height;
      final double x = flake.x * size.width + math.sin(progress * math.pi * 2 + flake.wobble) * 10;
      
      canvas.drawCircle(
        Offset(x, y),
        flake.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _PetalEffect extends StatefulWidget {
  const _PetalEffect();

  @override
  State<_PetalEffect> createState() => _PetalEffectState();
}

class _PetalEffectState extends State<_PetalEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _PetalPainter(progress: _controller.value),
        );
      },
    );
  }
}

class _PetalPainter extends CustomPainter {
  _PetalPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFFFB7C5).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    // Draw a few falling petals
    for (int i = 0; i < 8; i++) {
      final double y = ((i * 0.12 + progress * 0.3) % 1.0) * size.height;
      final double x = (i * 0.1 + math.sin(progress * math.pi * 2 + i) * 0.05 + 0.5) * size.width;
      final double rotation = progress * math.pi * 4 + i;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      
      // Draw petal shape
      final Path path = Path()
        ..moveTo(0.0, -6.0)
        ..quadraticBezierTo(4.0, 0.0, 0.0, 6.0)
        ..quadraticBezierTo(-4.0, 0.0, 0.0, -6.0);
      
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =============================================================================
// Tier Selection Step
// =============================================================================

class _TierSelectionStep extends StatelessWidget {
  const _TierSelectionStep({
    super.key,
    required this.selectedTier,
    required this.onSelect,
    required this.onBack,
  });

  final MarketTier? selectedTier;
  final ValueChanged<MarketTier> onSelect;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Back button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onBack,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.arrow_back,
                    size: 16.0,
                    color: AurelianPalette.textSecondary,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'BACK TO CITIES',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 11.0,
                      color: AurelianPalette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16.0),
        
        // Tier cards
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            itemCount: MarketTier.values.length,
            itemBuilder: (BuildContext context, int index) {
              final MarketTier tier = MarketTier.values[index];
              final bool isSelected = selectedTier == tier;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _TierCard(
                  tier: tier,
                  isSelected: isSelected,
                  onTap: () => onSelect(tier),
                )
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: index * 100))
                    .slideY(begin: 0.2, end: 0.0),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.tier,
    required this.isSelected,
    required this.onTap,
  });

  final MarketTier tier;
  final bool isSelected;
  final VoidCallback onTap;

  IconData get _tierIcon {
    switch (tier) {
      case MarketTier.highLuxury:
        return Icons.diamond;
      case MarketTier.midLuxury:
        return Icons.balance;
      case MarketTier.massMarket:
        return Icons.factory;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: isSelected
              ? AurelianPalette.champagneGold.withValues(alpha: 0.15)
              : AurelianPalette.alabaster,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected
                ? AurelianPalette.champagneGold
                : AurelianPalette.textTertiary.withValues(alpha: 0.2),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  _tierIcon,
                  size: 24.0,
                  color: isSelected
                      ? AurelianPalette.champagneGold
                      : AurelianPalette.textSecondary,
                ),
                const SizedBox(width: 12.0),
                Text(
                  tier.displayName.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 14.0,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: 2.0,
                    color: AurelianPalette.textPrimary,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    width: 24.0,
                    height: 24.0,
                    decoration: BoxDecoration(
                      color: AurelianPalette.champagneGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16.0,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(
              tier.description,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 13.0,
                color: AurelianPalette.textSecondary,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                _TierStat(
                  label: 'STARTING CAPITAL',
                  value: '\$${(tier.startingCapital / 1000).toStringAsFixed(0)}K',
                ),
                const SizedBox(width: 24.0),
                _TierStat(
                  label: 'HYPE CEILING',
                  value: (tier.hypeCeiling / 1000000).toStringAsFixed(1) + 'M',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TierStat extends StatelessWidget {
  const _TierStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 9.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
            color: AurelianPalette.textTertiary,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2A2A2A),
          ),
        ),
      ],
    );
  }
}
