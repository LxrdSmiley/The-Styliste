// GDD v6 — District Map Screen: Abstract Aurelian War Room
// 9 districts, 3 cities, stylized minimalist interface
// No Google Maps — custom Flutter layout with InteractiveViewer

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/aurelian_theme.dart';
import '../models/fashion_district.dart';
import '../providers/district_provider.dart';

/// Abstract district map — the Alabaster War Room
///
/// Features:
/// - Ivory background with delicate city connection lines
/// - 9 district nodes (pulsing if controlled)
/// - Aurelian Watermarks for 30-day legacy holders
/// - Smooth pan/zoom via InteractiveViewer
class DistrictMapScreen extends ConsumerWidget {
  const DistrictMapScreen({super.key});

  // District positions on the abstract map (0-1000 coordinate space)
  static const Map<String, Map<String, double>> _districtPositions =
      <String, Map<String, double>>{
    // New York (left cluster)
    'SoHo': <String, double>{'x': 150, 'y': 300},
    'Meatpacking': <String, double>{'x': 200, 'y': 400},
    'Williamsburg': <String, double>{'x': 280, 'y': 250},

    // Tokyo (center cluster)
    'Ginza': <String, double>{'x': 500, 'y': 300},
    'Harajuku': <String, double>{'x': 480, 'y': 420},
    'Shibuya': <String, double>{'x': 550, 'y': 380},

    // Paris (right cluster)
    'Le Marais': <String, double>{'x': 750, 'y': 280},
    'Saint-Germain': <String, double>{'x': 780, 'y': 380},
    'Montmartre': <String, double>{'x': 720, 'y': 450},
  };

  // City labels
  static const Map<String, Map<String, double>> _cityLabels =
      <String, Map<String, double>>{
    'NEW YORK': <String, double>{'x': 200, 'y': 180},
    'TOKYO': <String, double>{'x': 510, 'y': 220},
    'PARIS': <String, double>{'x': 750, 'y': 200},
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<FashionDistrict>> districtsAsync =
        ref.watch(globalDistrictsProvider);

    return Scaffold(
      backgroundColor: AurelianPalette.ivory,
      appBar: AppBar(
        backgroundColor: AurelianPalette.ivory,
        foregroundColor: AurelianPalette.textPrimary,
        elevation: 0.0,
        centerTitle: true,
        title: const Text(
          'DISTRICT WARFARE',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 4.0,
            color: AurelianPalette.textPrimary,
          ),
        ),
      ),
      body: districtsAsync.when(
        data: (List<FashionDistrict> districts) => _DistrictMapView(
          districts: districts,
        ),
        loading: () => const Center(
          child:
              CircularProgressIndicator(color: AurelianPalette.champagneGold),
        ),
        error: (Object err, StackTrace stack) => const Center(
          child: Text(
            'Failed to load districts',
            style: TextStyle(color: AurelianPalette.danger),
          ),
        ),
      ),
    );
  }
}

/// The interactive district map
class _DistrictMapView extends StatelessWidget {
  const _DistrictMapView({required this.districts});

  final List<FashionDistrict> districts;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(100.0),
      minScale: 0.5,
      maxScale: 3.0,
      child: Container(
        width: 1000.0,
        height: 600.0,
        color: AurelianPalette.ivory,
        child: Stack(
          children: <Widget>[
            // --- City connection lines ---
            CustomPaint(
              size: const Size(1000.0, 600.0),
              painter: _CityConnectionPainter(),
            ),

            // --- City labels ---
            ...DistrictMapScreen._cityLabels.entries
                .map((MapEntry<String, Map<String, double>> entry) {
              return Positioned(
                left: entry.value['x']! - 40,
                top: entry.value['y']!,
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 10.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 3.0,
                    color: AurelianPalette.textTertiary,
                  ),
                ),
              );
            }),

            // --- District nodes ---
            ...districts.map((FashionDistrict district) {
              final Map<String, double>? pos =
                  DistrictMapScreen._districtPositions[district.name];
              if (pos == null) return const SizedBox.shrink();

              return Positioned(
                left: pos['x']! - 30,
                top: pos['y']! - 30,
                child: _DistrictNode(district: district)
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 400))
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: const Duration(milliseconds: 400),
                    ),
              );
            }),

            // --- Aurelian Watermarks (30-day legacy) ---
            ...districts.where((FashionDistrict d) => d.hasLegacyWatermark).map(
              (FashionDistrict district) {
                final Map<String, double>? pos =
                    DistrictMapScreen._districtPositions[district.name];
                if (pos == null) return const SizedBox.shrink();

                return Positioned(
                  left: pos['x']! - 80,
                  top: pos['y']! - 60,
                  child: const _AurelianWatermark(maisonTag: '[LEGACY]')
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 800))
                      .rotate(
                        begin: -0.3,
                        end: -0.26, // -15 degrees
                        duration: const Duration(milliseconds: 600),
                      ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual district node
class _DistrictNode extends StatelessWidget {
  const _DistrictNode({required this.district});

  final FashionDistrict district;

  @override
  Widget build(BuildContext context) {
    final bool isControlled = district.isControlled;
    final bool hasWatermark = district.hasLegacyWatermark;

    return GestureDetector(
      onTap: () => _showDistrictDetails(context),
      child: Container(
        width: 60.0,
        height: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isControlled
              ? AurelianPalette.softRose.withValues(alpha: 0.2)
              : AurelianPalette.alabaster,
          border: Border.all(
            color: isControlled
                ? AurelianPalette.softRose
                : AurelianPalette.textTertiary.withValues(alpha: 0.3),
            width: isControlled ? 2.0 : 1.0,
          ),
          boxShadow: isControlled
              ? <BoxShadow>[
                  BoxShadow(
                    color: AurelianPalette.softRose.withValues(alpha: 0.4),
                    blurRadius: 12.0,
                    spreadRadius: 2.0,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                district.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 8.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: isControlled
                      ? AurelianPalette.softRose
                      : AurelianPalette.textSecondary,
                ),
              ),
              if (isControlled) ...<Widget>[
                const SizedBox(height: 2.0),
                Text(
                  '${district.daysControlled}d',
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 7.0,
                    color: AurelianPalette.textTertiary,
                  ),
                ),
              ],
              if (hasWatermark)
                Container(
                  margin: const EdgeInsets.only(top: 2.0),
                  width: 4.0,
                  height: 4.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AurelianPalette.champagneGold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDistrictDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AurelianPalette.ivory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext ctx) => _DistrictDetailsSheet(district: district),
    );
  }
}

/// Aurelian Watermark overlay for 30-day legacy
class _AurelianWatermark extends StatelessWidget {
  const _AurelianWatermark({required this.maisonTag});

  final String maisonTag;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.26, // -15 degrees
      child: Text(
        maisonTag,
        style: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 36.0,
          fontWeight: FontWeight.w100,
          color: AurelianPalette.champagneGold.withValues(alpha: 0.3),
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}

/// City connection lines painter
class _CityConnectionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AurelianPalette.textTertiary.withValues(alpha: 0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw subtle connection lines between cities
    final List<Offset> cityCenters = <Offset>[
      const Offset(200, 320), // NYC center
      const Offset(510, 340), // Tokyo center
      const Offset(750, 320), // Paris center
    ];

    // Connect cities with delicate lines
    for (int i = 0; i < cityCenters.length - 1; i++) {
      canvas.drawLine(cityCenters[i], cityCenters[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// District details bottom sheet
class _DistrictDetailsSheet extends StatelessWidget {
  const _DistrictDetailsSheet({required this.district});

  final FashionDistrict district;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    district.name.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                      color: AurelianPalette.textPrimary,
                    ),
                  ),
                  Text(
                    district.city.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 12.0,
                      letterSpacing: 2.0,
                      color: AurelianPalette.textTertiary,
                    ),
                  ),
                ],
              ),
              if (district.hasLegacyWatermark)
                Container(
                  padding: const EdgeInsets.symmetric(
<<<<<<< HEAD
                      horizontal: 12.0, vertical: 6.0),
=======
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
>>>>>>> b82f5aa0df7cf605d44fb4b2ee0b34ca518f7b9e
                  decoration: BoxDecoration(
                    color: AurelianPalette.champagneGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: AurelianPalette.champagneGold),
                  ),
                  child: const Text(
                    'LEGACY',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 10.0,
                      fontWeight: FontWeight.w600,
                      color: AurelianPalette.champagneGold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24.0),

          // Status
          if (district.isControlled) ...<Widget>[
            _buildInfoRow(
<<<<<<< HEAD
                'Controller', district.controllingMaisonId ?? 'Unknown'),
            _buildInfoRow('Days Held', '${district.daysControlled} days'),
            _buildInfoRow(
                'Defense Multiplier', district.defenseMultiplierDisplay),
=======
              'Controller',
              district.controllingMaisonId ?? 'Unknown',
            ),
            _buildInfoRow('Days Held', '${district.daysControlled} days'),
            _buildInfoRow(
              'Defense Multiplier',
              district.defenseMultiplierDisplay,
            ),
>>>>>>> b82f5aa0df7cf605d44fb4b2ee0b34ca518f7b9e
          ] else ...<Widget>[
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AurelianPalette.ivoryDark,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Row(
                children: <Widget>[
                  Icon(
                    Icons.circle_outlined,
                    size: 16.0,
                    color: AurelianPalette.textSecondary,
                  ),
                  SizedBox(width: 12.0),
                  Text(
                    'UNOWNED — Open for siege',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 14.0,
                      color: AurelianPalette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16.0),

          // Base cost
          _buildInfoRow('Base Takeover Cost', district.takeoverCostFormatted),

          const SizedBox(height: 24.0),

          // Action button
          if (!district.isControlled)
            SizedBox(
              width: double.infinity,
              height: 56.0,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to siege preparation
                  Navigator.pop(context);
                  // context.push('/maison/siege/${district.id}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AurelianPalette.champagneGold,
                  foregroundColor: AurelianPalette.textPrimary,
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  'INITIATE SIEGE',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 10.0,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
              color: AurelianPalette.textTertiary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: AurelianPalette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
