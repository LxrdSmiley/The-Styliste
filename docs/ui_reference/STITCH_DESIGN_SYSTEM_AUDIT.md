# STITCH_DESIGN_SYSTEM_AUDIT.md

## 1. Asset Intake

Uploaded reference package:

`c:\Users\Karriene Hall\Downloads\New folder\stitch_the_styliste_design_system.zip`

| Screen / System | Package File |
| --- | --- |
| HQ Architect | `hq_architect/screen.png` |
| HQ Artisan | `hq_artisan/screen.png` |
| Atelier | `atelier/screen.png` |
| Drop Preview | `drop_preview/screen.png` |
| Drop Launch | `drop_launch/screen.png` |
| Global Feed | `global_feed/screen.png` |
| First Vex Reveal | `first_vex_reveal/screen.png` |
| Design System | `the_styliste/DESIGN.md` |

This package is the current visual north star for The Styliste. It is not direct implementation code, and its PNGs must not be copied into runtime UI as permanent screen assets. Flutter implementation should translate the package into semantic tokens, reusable components, and server-authoritative UI states.

GDD support: v6 §1, §4.5, §6.1.

## 2. Overall Verdict

The package is a strong UI direction for The Styliste because it communicates luxury fashion, noir prestige, editorial layout, Designer/Mogul identity, premium mobile game feel, and cinematic reward moments.

The primary implementation risk is systemization. The screens look handcrafted, so the next implementation pass should create reusable Flutter tokens/components before recreating screens.

## 3. Strengths

| Area | Assessment |
| --- | --- |
| Visual identity | Ivory, obsidian, champagne gold, editorial typography, and restrained rose accents fit the luxury fashion empire fantasy. |
| Fashion fantasy | Screens read closer to a luxury campaign/editorial product than a generic mobile game UI. |
| HQ Architect | Strong executive/tycoon direction with clearer business hierarchy than a purely cosmetic dashboard. |
| HQ Artisan | Strong editorial brand tone, useful as the light-mode anchor for Designer identity. |
| Atelier | Strongest screen direction; garment-first composition supports creative production. |
| Drop Launch | Feels like an event and should become a reusable power moment pattern. |
| Global Feed | Social-feed influence is clear but elevated enough for the game's prestige tone. |
| First Vex Reveal | Strong cinematic review/reward surface. Vex is canonical in GDD v6 and already present in the codebase. |
| Metrics | Mono numeric treatment supports idle/tycoon readability. |

## 4. Critical UX Risks

| Risk | Problem | Required Fix |
| --- | --- | --- |
| Light/dark inconsistency | HQ Artisan is ivory/editorial while many other screens are obsidian/noir. | Define intentional visual modes and map screens to them. |
| Token mismatch | `DESIGN.md` contains Material-like color tokens while narrative copy names Ivory, Alabaster, Obsidian, Champagne Gold, Deep Gold, and Soft Rose. | Use semantic Flutter tokens instead of one-off raw colors. |
| Small text density | Some cards/buttons may compress on 390px portrait width. | Enforce readable text sizes and 48x48 tap targets. |
| Heavy effects | Glows, blur, particles, and full-screen art can threaten 60fps. | Confine effects to fixed hero/power-moment zones, not scroll lists. |
| One-off implementation | Direct screen recreation would fragment the UI system. | Build reusable components first. |
| Server authority | Drop, boost, reward, and review screens display values that must not be invented by client UI. | Confirmed rewards must come from Supabase RPC/Edge Function responses. Projections must be clearly labelled. |

## 5. Screen-by-Screen Notes

### HQ Architect

Verdict: Good Mogul direction with strong tycoon readability.

Required implementation guidance:

- Keep revenue/profit hierarchy prominent above the fold.
- Add clearer "what changed while offline" feedback before expanding power actions.
- Ensure power actions route through domain/repository/RPC paths and never mutate economy values from widgets.

GDD support: v6 §4.5, §5, §5.4, §8.18.

### HQ Artisan

Verdict: Strong editorial brand profile direction, but it needs more dashboard/game feedback.

Required implementation guidance:

- Keep EditorialLight mode.
- Make next action obvious.
- Keep Brand Rank, followers, hype meter, and idle revenue visible above the fold.
- Add clear loading/error/offline states for live HQ data.

GDD support: v6 §4.5, §8.11, §8.12.

### Atelier

Verdict: Strongest screen direction in the package.

Required implementation guidance:

- Convert fabric/style chips into reusable selectable components.
- Projection scores must be domain-derived or visibly labelled as projections.
- Locked materials need clear unlock requirements.
- Add loading/empty/error states for garment assets.

GDD support: v6 §4, §4.2, §4.3.

### Drop Preview

Verdict: Strong tension-before-launch screen.

Required implementation guidance:

- Clearly distinguish projected values from confirmed results.
- "Drop to Feed" must call the approved server path only.
- Include insufficient resource and server sync pending states.
- Disable repeated taps while the drop request is in flight.

GDD support: v6 §4, §6.1, §8.18.

### Drop Launch

Verdict: Strong power moment.

Required implementation guidance:

- Render confirmed reward values from the one-time server response payload.
- Do not recalculate rewards locally after launch.
- Add reduced-motion fallback for cinematic animation.

GDD support: v6 §6.1, §8.18, §9.1.

### Global Feed

Verdict: Strong vertical social feed concept.

Required implementation guidance:

- Add report access before expanding social features.
- Feed post long-press or overflow menu must expose report action.
- Add empty/offline/error states.
- Keep feed interactions RPC/Edge Function based and rate-limitable.
- Avoid blur/particles inside scrolling list items.

GDD support: v6 §6.1, §6.5, §6.6.

### First Vex Reveal

Verdict: Strong narrative-review moment.

Vex canon status: Confirmed. `Vex` appears in `THE_STYLISTE_GDD_v6.md` and existing code under design, atelier, feed, and HQ features.

Required implementation guidance:

- Treat this as a reusable critic/review power moment, not a one-off screen.
- Score/reward values must come from server-confirmed payloads when presented as confirmed outcomes.
- Any preview text must be labelled as preview/projection if generated client-side.

GDD support: v6 §8.7, §8.12, §6.1, §12.3.2.

## 6. Component-First Plan

Before screen recreation, define reusable Flutter components:

| Component | Purpose |
| --- | --- |
| `StylisteScaffold` | Shared safe area, visual mode background, bottom navigation handling. |
| `PrestigeHeader` | Brand name, rank badge, screen title, and optional context action. |
| `GoldPrimaryButton` | Main CTA style with disabled/loading states. |
| `GlassMetricCard` | Followers, hype, revenue, XP, rank, and growth metrics. |
| `EditorialStatStrip` | Compact horizontal metric row for HQ/feed cards. |
| `GarmentHeroCard` | Atelier/drop/feed garment presentation surface. |
| `LuxeOverlayCard` | Luxe tutorial/dialog overlays and mentor prompts. |
| `PowerMomentScreen` | Drop Launch, Vex Reveal, major rewards, and cinematic result surfaces. |
| `StylisteBottomNav` | Studio / Feed / Maison navigation treatment. |
| `PillBadge` | Rank, tags, season, exclusive, trend, and status labels. |

Do not implement these components until a dedicated component pass is requested.

## 7. Server-Authority Contract

For Drop Preview, Drop Launch, Feed, and Vex/Critic reveal UI:

- Confirmed followers, XP, rank progress, idle revenue, currency, valuation, IAP rewards, and reward deltas must come from Supabase RPC/Edge Function responses.
- UI may show projected values only when clearly labelled as projection.
- Widgets must not mutate economy, followers, rank, XP, valuation, or idle rewards directly.
- Report access is required for feed posts before social feature expansion.

GDD support: v6 §8.18, §9.1, §9.2.

## 8. QA / Verification Notes

- Verify future implementation uses semantic tokens rather than raw one-off colors.
- Verify 48x48 minimum tap targets on all CTAs and icon buttons.
- Verify reduced-motion alternatives for Drop Launch and Vex Reveal.
- Verify feed report entry point exists on each post.
- Inspect UI code for direct client mutation of followers, XP, rank, idle revenue, currency, or valuation.
