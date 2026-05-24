// GDD §4.1 — Fabric dye swatch selector for the Atelier session.
// Four swatches: Obsidian, Ivory, Gold, Lime — matching AppColors palette.
// Selected swatch shows a 2px gold ring indicator.

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FabricSwatchPanel extends StatelessWidget {
  const FabricSwatchPanel({
    required this.selectedColor,
    required this.onSwatchSelected,
    super.key,
  });

  final Color selectedColor;
  final ValueChanged<Color> onSwatchSelected;

  static const List<({Color color, String label})> _swatches =
      <({Color color, String label})>[
    (color: AppColors.ivory, label: 'IVORY'),
    (color: AppColors.obsidianCard, label: 'NOIR'),
    (color: AppColors.gold, label: 'GOLD'),
    (color: AppColors.lime, label: 'LIME'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        itemCount: _swatches.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16.0),
        itemBuilder: (BuildContext context, int index) {
          final ({Color color, String label}) swatch = _swatches[index];
          final bool isSelected =
              swatch.color.toARGB32() == selectedColor.toARGB32();
          return GestureDetector(
            onTap: () => onSwatchSelected(swatch.color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: swatch.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.gold : Colors.transparent,
                  width: 2.0,
                ),
                boxShadow: isSelected
                    ? <BoxShadow>[
                        BoxShadow(
                          color: AppColors.goldWithOpacity(0.45),
                          blurRadius: 8.0,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
