# UX_AUDIT.md

## Status

The uploaded `stitch_the_styliste_design_system.zip` package is the full Stitch UI reference set for the current prototype direction. It is a visual and UX catalog, not Flutter source.

Current integration state:

- Foundation components: implemented.
- HQ integration: implemented.
- Atelier and Drop Preview recovery polish: partially integrated.
- Drop Launch, Feed, Ledger, onboarding cinematic flow, and advanced Vex reveal work: deferred until explicitly scheduled.

## Authority Rules

- `the_styliste/DESIGN.md` is the canonical visual-token reference.
- `code.html` files are reference-only and must not be copied into Flutter.
- `image.png_1` through `image.png_10` are mood and genre references unless manually promoted later.
- District and Gala previews are future-locked references, not active implementation scope.
- Do not copy Stitch HTML into Flutter.
- Do not copy PNGs into runtime assets unless explicitly approved.
- Confirmed gameplay values remain server-authoritative. Client UI may show projections only when clearly labelled as projections.

## Design System

The Stitch system confirms the app should use semantic Flutter tokens rather than one-off screen colors. `DESIGN.md` is the canonical token reference, while the Flutter implementation should continue translating that into the existing `StylisteColors`, `StylisteVisualMode`, spacing, radius, motion, and component primitives.

Relevant Stitch references:

- `the_styliste/DESIGN.md`
- `button_input_system/screen.png`
- `luxe_system_library/screen.png`
- `vex_system_library/screen.png`
- `flutter_handoff_pack/screen.png`

## HQ

HQ Artisan and HQ Architect are the first proven runtime integrations. The Stitch references support the current split between `editorialLight` for Artisan and `executiveObsidian` for Architect.

Relevant Stitch references:

- `hq_artisan_1/screen.png`
- `hq_artisan_2/screen.png`
- `hq_artisan_with_luxe_guidance/screen.png`
- `hq_architect_1/screen.png`
- `hq_architect_2/screen.png`

## Atelier / Drops

Atelier is the next runtime target for controlled behavior-preserving integration. Drop Preview has recovery and Vex opt-in polish, but broader screen recreation and new gameplay mechanics remain out of scope.

Relevant Stitch references:

- `atelier_1/screen.png`
- `atelier_2/screen.png`
- `atelier_creative_hub/screen.png`
- `drop_preview_1/screen.png`
- `drop_preview_2/screen.png`
- `drop_preview_public_launch/screen.png`
- `drop_launch_1/screen.png`
- `drop_launch_2/screen.png`

## Onboarding

Onboarding references are cataloged for later cinematic flow work. They are not active implementation scope in this batch.

Relevant Stitch references:

- `career_path_selection/screen.png`
- `aurelian_gate/screen.png`
- `aurelian_gate_with_luxe/screen.png`
- `sovereign_registry/screen.png`
- `sovereign_registry_with_luxe/screen.png`

## Luxe

Luxe recovery has a shared primitive in Flutter. The broader Luxe guidance, onboarding, and overlay system remains partially integrated and should be expanded only through reusable components.

Relevant Stitch references:

- `luxe_system_library/screen.png`
- `luxe_recovery_states/screen.png`
- `hq_artisan_with_luxe_guidance/screen.png`

## Vex

The Vex visual-tier adapter and review-card action polish are integrated. The First Vex Reveal remains paused until the automated, SQL, and manual smoke gates are complete.

Relevant Stitch references:

- `a_set_of_six_premium_editorial_badges_for_a_fashion_critic_system_called_vex./screen.png`
- `vex_system_library/screen.png`
- `first_vex_reveal_1/screen.png`
- `first_vex_reveal_2/screen.png`
- `first_vex_reveal_cinematic/screen.png`

## Feed / Viral Moments

Feed and viral moment references are deferred. Feed expansion must keep report access, RPC/Edge Function flows, dedupe guarantees, and server-confirmed Alpha Drop publishing intact.

Relevant Stitch references:

- `global_feed_1/screen.png`
- `global_feed_2/screen.png`
- `iconic_surge_reaction/screen.png`
- `trend_tsunami_takeover/screen.png`

## Ledger / Mogul

Ledger and power-move references are cataloged for later Mogul UI work. The current approved work only added a SQL ownership regression test for `execute_power_move`.

Relevant Stitch references:

- `the_ledger_empire_power/screen.png`
- `flash_sale_preview_move/screen.png`
- `flash_sale_market_result/screen.png`
- `hq_architect_1/screen.png`
- `hq_architect_2/screen.png`

## Locked Future Features

District, Gala, AR, advanced social/map systems, advanced physics, and monetization references are future-locked. They must not become active implementation scope without a later directive.

Relevant Stitch references:

- `locked_preview_the_district/screen.png`
- `locked_preview_aurelian_gala/screen.png`
- `a_luxury_mobile_ui_screen_for_a_fashion_game._the_screen_shows_a_locked_feature/screen.png`

## First 5-Minute Flow

The first-session loop reference is cataloged for future sequencing. Current runtime priority remains behavior-preserving Atelier preparation, not a full onboarding rebuild.

Relevant Stitch references:

- `interaction_flow_first_5_minute_experience/screen.png`

## Mood / Genre References

The `image.png_1` through `image.png_10` folders are mood and genre references. They should inform tone, density, luxury/noir contrast, and power-moment composition only after a human promotes a specific image to canonical status.

Relevant Stitch references:

- `image.png_1/screen.png`
- `image.png_2/screen.png`
- `image.png_3/screen.png`
- `image.png_4/screen.png`
- `image.png_5/screen.png`
- `image.png_6/screen.png`
- `image.png_7/screen.png`
- `image.png_8/screen.png`
- `image.png_9/screen.png`
- `image.png_10/screen.png`
