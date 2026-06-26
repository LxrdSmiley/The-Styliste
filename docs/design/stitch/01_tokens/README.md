# Token Notes

Use the existing Flutter token foundation in `lib/core/theme/` as the source of truth.

Stitch palette mapping:

| Stitch Reference | Flutter Token |
| --- | --- |
| Ivory | `StylisteColors.ivory` |
| Alabaster | `StylisteColors.alabaster` |
| Champagne Gold | `StylisteColors.champagneGold` |
| Deep Gold | `StylisteColors.deepGold` |
| Soft Rose | `StylisteColors.roseAccent` |
| Obsidian | `StylisteColors.obsidian` |
| Obsidian Surface | `StylisteColors.obsidianSurface` |
| Warm Grey | `StylisteColors.warmGrey` |

Typography mapping:

- Editorial headings: `StylisteText.displayEditorial` or `StylisteText.headline`.
- Labels and badges: `StylisteText.labelCaps`.
- Metrics and deltas: `StylisteText.metricLarge` and `StylisteText.metricSmall`.
- Guidance and recovery copy: `StylisteText.body` and `StylisteText.bodySmall`.
