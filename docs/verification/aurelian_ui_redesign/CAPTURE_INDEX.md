# Aurelian UI Redesign Capture Index

Every image referenced by this index is classified as:

> **Deterministic source render — not physical-device evidence**

The capture viewport is 390 × 844 logical pixels at a deterministic 1.5 image
pixel ratio. These renders do not establish Android compilation, device
compatibility, TalkBack behavior, GPU performance, or 60 fps.

## Inherited presentation

| Capture | Surface | Inspection note |
|---|---|---|
| `captures/before/opening_manifesto.png` | Opening manifesto | Headless Flutter uses the deterministic test font; this records layout rather than approved typography. |
| `captures/before/founder_trial_entry.png` | Founder Trial entry | House-name entry and legacy dark presentation captured before redesign. |
| `captures/before/hq_artisan.png` | Artisan HQ | 390px render exposed an inherited 81px horizontal overflow. |
| `captures/before/hq_architect.png` | Architect HQ | 390px render exposed inherited 81px, 42px, and 28px horizontal overflows. |
| `captures/before/atelier_workspace.png` | Atelier | Existing studio workspace captured with deterministic empty trend data. |
| `captures/before/capsule_collection_brief.png` | Collection Brief | Inherited Wave 2A brief-draft state captured with a fixed server receipt fixture. |
| `captures/before/house_identity.png` | House identity | Existing deliberate locked-state presentation captured. |
| `captures/before/settings.png` | Settings | 390px render exposed an inherited 63px horizontal overflow. |

## Redesigned presentation

The after pass uses the bundled Space Grotesk, Inter, and JetBrains Mono
families. The temporary inherited-overflow allowances were removed before the
pass ran.

| Capture | Surface or state | Manual inspection |
|---|---|---|
| `captures/after/session_loading.png` | Secure-session restoration | Obsidian hierarchy is clear; live loading state is non-economic. |
| `captures/after/session_safe_failure.png` | Safe authentication failure | Retry is the single clear action; no backend details are exposed. |
| `captures/after/opening_sanctuary.png` | Opening Sanctuary | Kingston, tailoring, sound, streetwear, and ambition are legible without cultural shorthand. |
| `captures/after/age_gate.png` | Age gate | Dialog content, both choices, backdrop state, and touch targets are visible without clipping. |
| `captures/after/luxe_introduction.png` | Luxe introduction | Manifesto hierarchy and non-pushy guidance remain distinct. |
| `captures/after/house_naming.png` | House naming | Local-draft authority boundary and disabled validation state are explicit. |
| `captures/after/founder_trial_entry.png` | Founder Trial entry | Shared-garment/equal-ceiling guidance, progress, input, and next action are clear. |
| `captures/after/founder_trial_restored.png` | Restored Founder Trial receipt | Restored status, server receipt, equal ceiling, and no-reward statement are visible. |
| `captures/after/hq_artisan.png` | Artisan HQ | Authorship framing, equal ceiling, capsule objective, and garment signature are clear. |
| `captures/after/hq_architect.png` | Architect HQ | Positioning framing differs while the gameplay ceiling remains visibly equal. |
| `captures/after/atelier_workspace.png` | Atelier | Garment remains central; local editor and authenticated capsule boundaries are explicit. |
| `captures/after/capsule_collection_brief.png` | Collection Brief | Three canonical roles and forward stage are visible before the form below the fold. |
| `captures/after/capsule_hero_piece.png` | Hero Piece | Active first role follows the confirmed brief without exposing sampling. |
| `captures/after/capsule_readiness_sampling_boundary.png` | Readiness/sampling boundary | All roles are confirmed with non-color cues; the next stage is deliberately unavailable. |
| `captures/after/empire_projection.png` | Empire | Read-only capital and bounded first-store intent are distinguishable. |
| `captures/after/first_store_dialog.png` | First-store dialog | Bounded inputs, Luxe authority copy, and two clear actions fit the portrait viewport. |
| `captures/after/feed_projection.png` | Feed/editorial card | Server-projected cause is not truncated; held actions remain visually distinct. |
| `captures/after/feed_comment_sheet.png` | Comment sheet | Empty and read-only states coexist in one scroll-safe sheet. |
| `captures/after/feed_request_sheet.png` | Request sheet | Held-response and empty states coexist without overflow. |
| `captures/after/house_identity.png` | House identity | Kingston craft, sound/streetwear, community proof, and equal ceiling are explicit. |
| `captures/after/settings.png` | Settings | Presentation-only controls and legal boundary are clear in Obsidian mode. |
| `captures/after/legal_privacy.png` | Legal document | Alpha status and source metadata are visually separated from body copy. |
| `captures/after/drop_route_unavailable.png` | Deferred drop route | No launch, Vex, reward, or market operation is implied. |
| `captures/after/five_tab_navigation.png` | Canonical shell navigation | `HQ`, `Atelier`, `Empire`, `Feed`, `House` are present in the approved order. |

All 24 after-captures were manually inspected for clipping, overflow,
hierarchy, typography, state clarity, and Ivory/Obsidian consistency. The
capture smoke test reported no layout exception. Large-text, semantics,
reduced-motion, and 320px behavior are recorded separately by automated tests;
physical TalkBack and device evidence remain blocked.

Authority: GDD v8 §§18, 21, and 22; `VERIFICATION_PROTOCOL.md`.
