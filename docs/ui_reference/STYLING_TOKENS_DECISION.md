# STYLING_TOKENS_DECISION.md

## 1. Decision

The Stitch package is approved as the visual north star, but implementation must use canonical semantic Flutter tokens rather than copying raw Material-style names or one-off screen colors.

`the_styliste/DESIGN.md` includes generated Material-like tokens such as `surface`, `primary`, `tertiary`, and `surface-container`. Its narrative direction names the actual brand palette: Ivory, Alabaster, Obsidian, Champagne Gold, Deep Gold, and Soft Rose. The Flutter system should resolve this by exposing semantic design tokens that describe intent and usage.

GDD support: v6 §4.5.

## 2. Canonical Visual Modes

| Mode | Usage Note | Primary Screens |
| --- | --- | --- |
| `EditorialLight` | Calm ivory/editorial brand-management surfaces. Use for Designer identity, profile-like dashboards, wardrobe/archive surfaces, and quiet planning moments. | HQ Artisan, archive, brand profile, wardrobe. |
| `NoirCinematic` | High-contrast obsidian power moments. Use for feed drama, launches, critic reveals, prestige overlays, and cinematic transitions. | Drop Preview, Drop Launch, First Vex Reveal, premium moments. |
| `ExecutiveObsidian` | Dense but polished business operations. Use for Mogul/tycoon surfaces where numbers, risk, and strategic control matter most. | HQ Architect, Ledger, bank, equity, supply chain. |
| `AtelierWarmStudio` | Warm creative workspace mode. Use for garment creation, fabric selection, swatches, layers, and creative previews. | Atelier, design editor, material selection. |

Mode switching is intentional. The app should not be globally "light" or globally "dark"; it should shift by player context and fantasy.

## 3. Canonical Color Tokens

| Flutter Token | Suggested Value | Usage Note |
| --- | --- | --- |
| `StylisteColor.obsidian` | `#090909` | Cinematic backgrounds, nav bars, executive panels, power moments, and high-contrast feed/reveal surfaces. |
| `StylisteColor.ivory` | `#FFFFF0` | Editorial canvas for calm Designer/HQ surfaces. Use as the highest-level light background. |
| `StylisteColor.alabaster` | `#FAF7F0` | Secondary light surfaces, cards, panels, dividers, and soft fabric-like depth. |
| `StylisteColor.champagneGold` | `#D6A84F` | Prestige emphasis, primary CTAs, rank highlights, selected states, and premium affordances. Use sparingly. |
| `StylisteColor.deepGold` | `#7C5800` | Pressed/active CTA state, strong gold text, high-value reward moments, and deep contrast on light surfaces. |
| `StylisteColor.roseAccent` | `#E19DAA` | Human/lifestyle accents, soft notifications, Luxe warmth, and non-critical emotional highlights. |
| `StylisteColor.rivalRed` | `#BA1A1A` | Danger, rival, crisis, destructive actions, failed validation, and Tarnish/scandal states only. |
| `StylisteColor.profitGreen` | `#2F7D4E` | Positive business growth, profit, supply-chain recovery, and successful financial deltas only. |
| `StylisteColor.textPrimary` | `#1C1B1B` on light, `#F3F0EF` on dark | Main readable text. Must meet contrast targets for its mode. |
| `StylisteColor.textSecondary` | `#4E4637` on light, `#D2C5B2` on dark | Secondary labels, descriptions, and subdued metadata. |
| `StylisteColor.outlineSubtle` | `#D2C5B2` | Thin dividers, card borders, disabled outlines, and editorial separators. |
| `StylisteColor.glassLight` | derived from `alabaster` with opacity | Frosted light overlay surfaces. Avoid in long scrolling lists if blur is expensive. |
| `StylisteColor.glassDark` | derived from `obsidian` with opacity | Noir overlay surfaces. Use fixed-position hero/power zones, not repeated feed cells. |

Do not use blue as a default UI accent. Purple/blue are reserved for rare, digital, AI/future, or explicitly scoped special features.

## 4. Typography Tokens

| Flutter Token | Family | Usage Note |
| --- | --- | --- |
| `StylisteText.displayEditorial` | Space Grotesk | Large screen titles, power moments, Vex/Luxe reveal headlines. Avoid in compact cards. |
| `StylisteText.headline` | Space Grotesk | Section headings, card titles, HQ module titles. |
| `StylisteText.labelCaps` | Space Grotesk | All-caps editorial labels such as `GLOBAL FEED`, `FIRST OBJECTIVE`, and rank/status labels. |
| `StylisteText.metricLarge` | JetBrains Mono | Followers, revenue, hype, XP, rank progress, idle income, and primary numeric stats. |
| `StylisteText.metricSmall` | JetBrains Mono | Compact deltas, timestamps, inventory counts, and ticker values. |
| `StylisteText.body` | Inter | Descriptions, instructions, feed body text, and tutorial copy. |
| `StylisteText.bodySmall` | Inter | Secondary metadata. Do not use below readable mobile size. |

Minimum body size should stay at or above 12sp equivalent, and primary interactive text should be large enough to read on 390px portrait screens.

## 5. Spacing / Shape Tokens

| Flutter Token | Suggested Value | Usage Note |
| --- | --- | --- |
| `StylisteSpacing.unit` | `4.0` | Base spacing unit. |
| `StylisteSpacing.safeMargin` | `24.0` | Portrait safe-area margin for premium editorial breathing room. |
| `StylisteSpacing.gutter` | `16.0` | Standard internal content gutter. |
| `StylisteSpacing.stackSm` | `8.0` | Tight vertical grouping. |
| `StylisteSpacing.stackMd` | `16.0` | Standard card/module spacing. |
| `StylisteSpacing.stackLg` | `32.0` | Section breaks and major vertical rhythm. |
| `StylisteRadius.sm` | `4.0` | Small chips, input focus details, and compact accents. |
| `StylisteRadius.card` | `8.0` to `12.0` | Standard cards and panels. Keep consistent with existing app surfaces. |
| `StylisteRadius.hero` | `20.0` | Large immersive garment/power cards and primary buttons. |
| `StylisteRadius.pill` | `999.0` | Badges, tags, status labels, and selected chips. |

All tap targets must be at least 48x48.

## 6. Elevation / Effects Tokens

| Flutter Token | Usage Note |
| --- | --- |
| `StylisteShadow.subtleCard` | Standard light lift for cards on ivory/alabaster surfaces. |
| `StylisteShadow.goldGlow` | Reserved for active primary CTAs, legendary/reward moments, and selected premium states. Do not use repeatedly in lists. |
| `StylisteGlass.lightPanel` | Semi-transparent alabaster/ivory overlay with subtle border. Avoid expensive blur in scrolling cells. |
| `StylisteGlass.darkPanel` | Semi-transparent obsidian overlay for noir moments and fixed hero panels. |
| `StylisteMotion.micro` | 120-220ms tap/hover/state response. |
| `StylisteMotion.screenTransition` | 250-450ms screen transition. |
| `StylisteMotion.powerMoment` | Up to 900ms cinematic reveal with reduced-motion fallback. |

Effects must protect 60fps on mid-range Android devices. Heavy blur, glow, shader, and particle treatments belong in fixed hero zones or one-shot reveal screens, not repeated list items.

## 7. Component Token Mapping

| Component | Required Tokens / Usage Note |
| --- | --- |
| `StylisteScaffold` | Accepts visual mode, controls background token, safe margins, bottom navigation padding, and reduced-motion defaults. |
| `PrestigeHeader` | Uses `headline`, `labelCaps`, `metricSmall`, `champagneGold`, and optional `PillBadge`. |
| `GoldPrimaryButton` | Uses `champagneGold`, `deepGold`, `textPrimary`, 48x48 minimum target, loading/disabled states, and no economy mutation. |
| `GlassMetricCard` | Uses mode-aware glass panel, mono metric typography, clear delta color roles, and compact loading/error states. |
| `EditorialStatStrip` | Uses mono metrics, subtle dividers, and one-line labels for above-the-fold HQ readability. |
| `GarmentHeroCard` | Uses garment preview, mode-specific background, fallback/empty/error asset states, and no blocking heavy effects. |
| `LuxeOverlayCard` | Uses rose/gold warmth, accessible dismiss/CTA actions, and local UI preference only when persistence is needed. |
| `PowerMomentScreen` | Uses `NoirCinematic`, one-shot result payloads, reduced-motion fallback, and server-confirmed reward display. |
| `StylisteBottomNav` | Uses `obsidian`, `champagneGold`, `textSecondary`, clear selected state, and 48x48 tab targets. |
| `PillBadge` | Uses pill radius, `labelCaps` or compact mono text, and semantic color role based on rank/tag/status. |

## 8. Server-Authority Styling Rule

Token and component implementation must not weaken server-authoritative gameplay:

- UI tokens may style reward values but must not create them.
- Confirmed rewards must come from Supabase RPC/Edge Function responses.
- Client-side projections must be labelled as projected.
- Widgets must not directly mutate followers, XP, rank, idle revenue, currency, valuation, or IAP rewards.

GDD support: v6 §8.18, §9.1, §9.2.

## 9. Implementation Status

This document is a design decision record only. Do not implement components or screen recreation until the next explicit component-first implementation directive.
