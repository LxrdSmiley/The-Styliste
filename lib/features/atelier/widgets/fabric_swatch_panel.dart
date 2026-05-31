// GDD v6 section 4.1 - fabric-first Atelier swatch selector.

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/aurelian_theme.dart';

class FabricSwatchPanel extends StatelessWidget {
  const FabricSwatchPanel({
    required this.selectedColor,
    required this.onSwatchSelected,
    super.key,
  });

  final Color selectedColor;
  final ValueChanged<Color> onSwatchSelected;

  static const List<({Color color, String label, String note})> _swatches =
      <({Color color, String label, String note})>[
    (color: AppColors.ivory, label: 'IVORY', note: 'clean cut'),
    (color: AppColors.obsidianCard, label: 'NOIR', note: 'sharp trim'),
    (color: AppColors.gold, label: 'GOLD', note: 'runway glow'),
    (color: AppColors.lime, label: 'LIME', note: 'signal pop'),
  ];

  @override
  Widget build(BuildContext context) {
    final ({Color color, String label, String note}) selected =
        _selectedSwatch(selectedColor);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 14.0),
      decoration: BoxDecoration(
        color: AurelianPalette.alabaster,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AurelianPalette.champagneGold.withValues(alpha: 0.64),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'FABRIC PALETTE',
                  style: TextStyle(
                    color: AurelianPalette.textTertiary,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              Text(
                selected.label,
                style: const TextStyle(
                  color: AurelianPalette.textPrimary,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            height: 74.0,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _swatches.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(width: 12.0),
              itemBuilder: (BuildContext context, int index) {
                final ({Color color, String label, String note}) swatch =
                    _swatches[index];
                final bool isSelected =
                    swatch.color.toARGB32() == selectedColor.toARGB32();
                return _FabricSwatch(
                  swatch: swatch,
                  selected: isSelected,
                  onTap: () => onSwatchSelected(swatch.color),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static ({Color color, String label, String note}) _selectedSwatch(
    Color selectedColor,
  ) {
    for (final ({Color color, String label, String note}) swatch in _swatches) {
      if (swatch.color.toARGB32() == selectedColor.toARGB32()) return swatch;
    }
    return (color: selectedColor, label: 'CUSTOM', note: 'atelier dye');
  }
}

class _FabricSwatch extends StatelessWidget {
  const _FabricSwatch({
    required this.swatch,
    required this.selected,
    required this.onTap,
  });

  final ({Color color, String label, String note}) swatch;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: 92.0,
        padding: const EdgeInsets.all(7.0),
        decoration: BoxDecoration(
          color: selected
              ? AurelianPalette.champagneGold.withValues(alpha: 0.28)
              : AurelianPalette.ivory,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: selected
                ? AurelianPalette.champagneGoldDark
                : AurelianPalette.champagneGold.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    color: swatch.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AurelianPalette.textPrimary
                          : AurelianPalette.champagneGoldDark.withValues(
                              alpha: 0.45,
                            ),
                      width: selected ? 2.0 : 1.0,
                    ),
                    boxShadow: selected
                        ? <BoxShadow>[
                            BoxShadow(
                              color: swatch.color.withValues(alpha: 0.42),
                              blurRadius: 12.0,
                            ),
                          ]
                        : null,
                  ),
                  child: selected
                      ? Icon(
                          Icons.check,
                          color: _checkColor(swatch.color),
                          size: 16.0,
                        )
                      : null,
                ),
                const Spacer(),
                if (selected)
                  const Icon(
                    Icons.auto_awesome,
                    color: AurelianPalette.champagneGoldDark,
                    size: 14.0,
                  ),
              ],
            ),
            const Spacer(),
            Text(
              swatch.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AurelianPalette.textPrimary,
                fontSize: 10.0,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 1.0),
            Text(
              swatch.note.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AurelianPalette.textTertiary,
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _checkColor(Color color) {
    return color.computeLuminance() > 0.45
        ? AppColors.obsidian
        : AurelianPalette.ivory;
  }
}
