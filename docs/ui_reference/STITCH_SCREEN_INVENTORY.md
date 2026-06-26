# STITCH_SCREEN_INVENTORY.md

## Source

Inventory source: `c:\Users\Karriene Hall\Downloads\New folder\stitch_the_styliste_design_system.zip`.

This table includes every Stitch package folder containing `screen.png`.

| Folder | Type | Canonical Status | GDD Section | Implementation Status |
| --- | --- | --- | --- | --- |
| `a_high_end_luxury_mobile_ui_screen_for_a_fashion_game._the_screen_shows_a` | Mood / Genre Reference | mood-reference | §4.5 | deferred |
| `a_luxury_mobile_ui_screen_for_a_fashion_game._the_screen_shows_a_locked_feature` | Locked Future Feature | future-locked | §4.5 | deferred |
| `a_set_of_six_premium_editorial_badges_for_a_fashion_critic_system_called_vex.` | Vex | canonical | §8.7, §12.3.2 | partially-integrated |
| `atelier_1` | Atelier / Drops | canonical | §4, §4.2 | partially-integrated |
| `atelier_2` | Atelier / Drops | variant | §4, §4.2 | partially-integrated |
| `atelier_creative_hub` | Atelier / Drops | canonical | §4, §4.2 | partially-integrated |
| `aurelian_gate` | Onboarding | canonical | §3.6, §4.5 | not-started |
| `aurelian_gate_with_luxe` | Onboarding / Luxe | variant | §3.6, §4.5, §8.12 | not-started |
| `button_input_system` | Design System | canonical | §4.5 | implemented |
| `career_path_selection` | Onboarding | canonical | §3.6, §4.5 | not-started |
| `drop_launch_1` | Atelier / Drops | canonical | §6.1, §8.18 | not-started |
| `drop_launch_2` | Atelier / Drops | variant | §6.1, §8.18 | not-started |
| `drop_preview_1` | Atelier / Drops | canonical | §4, §6.1, §8.18 | partially-integrated |
| `drop_preview_2` | Atelier / Drops | variant | §4, §6.1, §8.18 | partially-integrated |
| `drop_preview_public_launch` | Atelier / Drops | canonical | §4, §6.1, §8.18 | partially-integrated |
| `first_vex_reveal_1` | Vex | canonical | §8.7, §12.3.2 | deferred |
| `first_vex_reveal_2` | Vex | variant | §8.7, §12.3.2 | deferred |
| `first_vex_reveal_cinematic` | Vex | canonical | §8.7, §12.3.2 | deferred |
| `flash_sale_market_result` | Ledger / Mogul | canonical | §5, §8.18 | deferred |
| `flash_sale_preview_move` | Ledger / Mogul | canonical | §5, §8.18 | deferred |
| `flutter_handoff_pack` | Design System | canonical | §4.5 | partially-integrated |
| `global_feed_1` | Feed / Viral Moments | canonical | §6.1, §6.5, §6.6 | not-started |
| `global_feed_2` | Feed / Viral Moments | variant | §6.1, §6.5, §6.6 | not-started |
| `hq_architect_1` | HQ | canonical | §4.5, §5 | implemented |
| `hq_architect_2` | HQ | variant | §4.5, §5 | implemented |
| `hq_artisan_1` | HQ | canonical | §4.5, §8.12 | implemented |
| `hq_artisan_2` | HQ | variant | §4.5, §8.12 | implemented |
| `hq_artisan_with_luxe_guidance` | HQ / Luxe | variant | §3.6, §4.5, §8.12 | partially-integrated |
| `iconic_surge_reaction` | Feed / Viral Moments | canonical | §6.1, §8.12 | deferred |
| `image.png_1` | Mood / Genre Reference | mood-reference | §4.5 | deferred |
| `image.png_2` | Mood / Genre Reference | mood-reference | §4.5 | deferred |
| `image.png_3` | Mood / Genre Reference | mood-reference | §4.5 | deferred |
| `image.png_4` | Mood / Genre Reference | mood-reference | §4.5 | deferred |
| `image.png_5` | Mood / Genre Reference | mood-reference | §4.5 | deferred |
| `image.png_6` | Mood / Genre Reference | mood-reference | §4.5 | deferred |
| `image.png_7` | Mood / Genre Reference | mood-reference | §4.5 | deferred |
| `image.png_8` | Mood / Genre Reference | mood-reference | §4.5 | deferred |
| `image.png_9` | Mood / Genre Reference | mood-reference | §4.5 | deferred |
| `image.png_10` | Mood / Genre Reference | mood-reference | §4.5 | deferred |
| `interaction_flow_first_5_minute_experience` | First 5-Minute Flow | canonical | §3.6, §4.5, §8.12 | partially-integrated |
| `locked_preview_aurelian_gala` | Locked Future Feature | future-locked | §4.5 | deferred |
| `locked_preview_the_district` | Locked Future Feature | future-locked | §4.5 | deferred |
| `luxe_recovery_states` | Luxe | canonical | §3.6, §8.12 | partially-integrated |
| `luxe_system_library` | Luxe / Design System | canonical | §3.6, §4.5, §8.12 | partially-integrated |
| `sovereign_registry` | Onboarding | needs-review | §3.6, §4.5 | not-started |
| `sovereign_registry_with_luxe` | Onboarding / Luxe | needs-review | §3.6, §4.5, §8.12 | not-started |
| `the_ledger_empire_power` | Ledger / Mogul | canonical | §5, §8.18 | deferred |
| `trend_tsunami_takeover` | Feed / Viral Moments | canonical | §6.1, §8.12 | deferred |
| `vex_system_library` | Vex / Design System | canonical | §8.7, §12.3.2 | partially-integrated |

## Status Definitions

Canonical statuses:

- `canonical`: approved reference for a screen, system, or reusable UI pattern.
- `variant`: alternate visual treatment or state for an approved surface.
- `mood-reference`: tone/genre reference only.
- `future-locked`: reference for a feature explicitly outside active implementation scope.
- `needs-review`: recognizable reference that needs product/design confirmation before implementation.

Implementation statuses:

- `implemented`: current Flutter branch has a matching foundation or screen integration.
- `partially-integrated`: current Flutter branch has related foundation, UI wiring, or recovery primitives but not full screen parity.
- `not-started`: no approved runtime implementation in this branch.
- `deferred`: intentionally held for a later scoped task.
