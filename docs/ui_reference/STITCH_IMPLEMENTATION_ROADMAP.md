# STITCH_IMPLEMENTATION_ROADMAP.md

## Scope

This roadmap translates the full Stitch UI reference set into implementation order. It does not approve new runtime scope by itself.

## Implemented

1. Foundation components - implemented.
   - `StylisteScaffold`
   - `GoldPrimaryButton`
   - `PillBadge`
   - `GlassMetricCard`
   - semantic color, mode, spacing, radius, and motion tokens

2. HQ integration - implemented.
   - Artisan HQ uses `editorialLight`.
   - Architect HQ uses `executiveObsidian`.
   - HQ metric/chip/CTA patterns use the component foundation.

## Next

3. Atelier integration - next runtime target.
   - Continue behavior-preserving integration only.
   - Keep server-authoritative mint/drop paths.
   - Keep projection copy visibly labelled.
   - Do not implement AR, AI texture generation, 3D cloth physics, rewards, or drop publishing changes in this phase.

4. Drop Preview.
   - Preserve existing provider and Edge Function flow.
   - Keep Vex opt-in explicit.
   - Keep recovery copy player-safe.
   - Prevent repeated drop submission while a request is in flight.

5. Drop Launch / Alpha result.
   - Render confirmed one-time server response payloads.
   - Add reduced-motion fallback before cinematic polish.
   - Do not recalculate rewards locally.

## Deferred

6. Global Feed.
   - Add report access and empty/offline/error states before broader social expansion.
   - Keep feed interactions RPC/Edge Function based and rate-limitable.

7. Luxe overlays and recovery states.
   - Expand from `LuxeRecoveryCard` into reusable overlay patterns.
   - Persist only local UI preferences, not gameplay progress.

8. Vex review/reveal system.
   - Continue using the visual adapter without changing the backend/domain enum.
   - Hold First Vex Reveal until automated, SQL, and manual smoke gates pass.

9. Ledger / power move screens.
   - Use server-authoritative RPC results only.
   - Do not mutate revenue, tarnish, followers, rank, or rewards from UI widgets.

10. Onboarding cinematic flow.
    - Use the Stitch onboarding references after the first five-minute loop is stable.
    - Do not rebuild onboarding as part of the current runtime priority.

## Future

11. Locked District/Gala previews.
    - Keep as future-locked reference material.
    - Do not implement District, Gala, Maison expansion, equity trading, or advanced social surfaces from these references in this branch.

12. Future high-cost systems: AR, full 3D physics, advanced map/social.
    - Requires separate technical design, performance budget, and gameplay authority review before implementation.

## Reference Rules

- `the_styliste/DESIGN.md` remains the canonical visual-token source.
- `code.html` files are reference-only, not Flutter source.
- `image.png_1` through `image.png_10` remain mood references until promoted.
- PNGs remain docs/reference assets only unless explicitly approved for runtime use.
