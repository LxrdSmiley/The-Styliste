# Stitch Reference Intake

Source package:

`c:\Users\Karriene Hall\Downloads\New folder\stitch_the_styliste_design_system.zip`

These files are docs-only visual references for Initial Prototype Assembly. They must not be copied into runtime assets or treated as generated Flutter implementation.

## Reference Map

| Required reference | Local file |
| --- | --- |
| Core component page | `button-state-matrix.png`, `luxe-system-library.png`, `vex-system-library.png` |
| Button state matrix | `button-state-matrix.png` |
| Luxe recovery states | `luxe-recovery-states.png` |
| Vex system | `vex-system-library.png`, `vex-verdict-badges.png`, `first-vex-reveal-cinematic.png` |
| Atelier + Drop Flow | `atelier-creative-hub.png`, `drop-preview-public-launch.png`, `drop-launch.png` |
| Global Feed Reaction States | `global-feed.png`, `iconic-surge-reaction.png`, `trend-tsunami-takeover.png` |
| Mogul + Ledger | `hq-architect.png`, `ledger-empire-power.png`, `flash-sale-preview-move.png`, `flash-sale-market-result.png` |
| First 5-Minute Flow | `first-5-minute-flow.png` |
| Flutter Handoff Notes | This README plus `docs/ui_reference/STITCH_DESIGN_SYSTEM_AUDIT.md` and `docs/ui_reference/STYLING_TOKENS_DECISION.md` |
| Maison locked preview only | `locked-maison-preview.png` |

## Implementation Notes

- Start with reusable Flutter tokens and components before further screen recreation.
- Keep Maison, Equity, District, Gala, AR, and advanced social systems out of the playable-loop pass.
- Keep gameplay state server-authoritative. UI may display server-confirmed rewards or clearly labelled projections, but must not invent followers, hype, XP, revenue, rank, valuation, or reward values.
- Do not use generated Stitch HTML as Flutter source.
