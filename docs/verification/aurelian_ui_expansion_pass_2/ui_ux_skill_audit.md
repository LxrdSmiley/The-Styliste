# Aurelian UI Expansion Pass 2 — UI/UX Skill Audit

Date: 2026-07-29
Starting branch: `codex/aurelian-ui-expansion-pass-2`
Starting commit: `c4405414195f5bcdff87b31848c3425a17e76e85`
Evidence classification: **Static pass**
Player-facing source edited before this record: **No**

This audit is binding for the complete expansion pass. The product authorities
remain `THE_STYLISTE_GDD_v8.md` §§4–8, 12, 18, 21–22,
`ART_DIRECTION_BIBLE.md`, `EMOTIONAL_EXPERIENCE_BIBLE.md`,
`NARRATIVE_STYLE_GUIDE.md`, `NON_FEATURE_COMPLETION_GATE.md`,
`PROJECT_RULES.md`, and `VERIFICATION_PROTOCOL.md`.

## UI/UX skill audit

- Skills discovered:
  - `frontend-design`
  - `ui-ux-designer`
  - `ui-ux-pro-max`
  - `flutter-expert`
  - `supabase`
  - `accessibility-compliance`
  - `flutter-build-responsive-layout`
  - `flutter-design-system`
  - `visual-testing`
- Skills invoked:
  - `frontend-design` for a distinctive, fashion-specific editorial hierarchy.
  - `ui-ux-designer` for systematic information architecture, progressive
    disclosure, accessible states, and cross-screen consistency.
  - `ui-ux-pro-max` for touch, contrast, focus, motion, navigation, responsive,
    and pre-delivery checks.
  - `flutter-expert` for Riverpod containment, Flutter widget composition,
    semantics, const subtrees, and golden/widget testing.
  - `supabase` for preserving the existing authenticated, RLS-constrained,
    server-authoritative boundary while the UI is changed.
  - `accessibility-compliance` for WCAG 2.2 principles, non-color cues,
    screen-reader semantics, logical focus, large text, and reduced motion.
  - `flutter-build-responsive-layout` for constraint-driven portrait layouts
    using `LayoutBuilder`, `MediaQuery.sizeOf`, `Flexible`, and bounded content
    widths.
  - `flutter-design-system` for canonical token and shared-component
    enforcement with no hardcoded independent visual values.
  - `visual-testing` for deterministic fixtures, stable baselines, animation
    control, explicit review, and responsive/state capture coverage.
- Recommendations accepted:
  - Use only `StylisteColors`, `StylisteText`, `StylisteSpacing`,
    `StylisteRadii`, `StylisteMotion`, `StylisteVisualMode`, and
    `AurelianTheme` as independent visual authorities.
  - Prefer existing Aurelian components over raw `ElevatedButton`, arbitrary
    `SizedBox` magic numbers, inline `TextStyle`, and screen-local colors.
  - Keep one obvious primary action per screen and use progressive disclosure
    for secondary detail.
  - Use a 4dp/8dp spacing rhythm and at least 48dp interactive targets.
  - Use semantic labels, selected/disabled/busy state, visible focus, logical
    reading order, and non-color status cues.
  - Support 320–412px portrait widths, large text, keyboard insets, safe areas,
    and reduced motion without hiding critical information.
  - Use `LayoutBuilder` and parent constraints rather than device-type or
    orientation assumptions.
  - Keep motion meaningful, interruptible, restrained to 150–300ms, and absent
    when reduced motion is requested.
  - Model loading, empty, editing, submitting, confirmed, restored, offline,
    retryable error, terminal error, permission denied, session expired,
    maintenance, disabled, and unavailable states explicitly.
  - Use Flutter widget/golden tests and deterministic fixtures for source
    renders; review every changed baseline rather than bulk-accepting images.
  - Use Riverpod `select` and small immutable display models to contain rebuilds.
  - Preserve the existing Supabase identity, repository, Edge/RPC, RLS, and
    server-derived authority path. UI callbacks may submit intent only.
- Recommendations rejected:
  - The UI Pro Max generated “Minimal Single Column / Exaggerated Minimalism”
    landing-page composition.
  - Playfair Display and Source Serif typography.
  - Pink CTA and generic monochrome luxury palette.
  - GSAP and web-only ARIA/Playwright implementation patterns.
  - Zero-radius brutalism, generic black-and-white fashion styling, decorative
    scroll reveal, and oversized landing-page typography.
  - A second token library, a generic package, or a new state-management layer.
  - Device or performance claims based only on static source or deterministic
    captures.
- Authority for rejection:
  1. `THE_STYLISTE_GDD_v8.md`, especially §§18, 21, and 22.
  2. `ART_DIRECTION_BIBLE.md` and Aurelian Radiance.
  3. `EMOTIONAL_EXPERIENCE_BIBLE.md`.
  4. `NARRATIVE_STYLE_GUIDE.md`.
  5. `NON_FEATURE_COMPLETION_GATE.md`.
  6. Existing canonical Aurelian typography and Flutter architecture.
  7. Accessibility, performance, security, server-authority, and F2P rules.
- Screen families covered:
  - Supabase session resolution and safe authentication failure.
  - Opening Sanctuary, age gate, Luxe introduction, House naming, Founder
    Trial, and Founder Path confirmation.
  - Five-destination shell: HQ, Atelier, Empire, Feed, House.
  - HQ strategy, guidance, evidence, blockers, and deferred boundaries.
  - Atelier, Collection Brief, capsule overview, Hero Piece, Commercial
    Anchor, Experimental Piece, readiness, receipts, and sampling boundary.
  - Empire, Ledger, and the implemented first-store dialog.
  - Feed editorial cards plus request and comment sheets.
  - House identity, settings, legal documents, confirmations, and account
    actions.
  - All applicable reliability states and the deliberately unavailable drop
    routes.
  - Dead/future-wave surfaces for inventory only; they remain unreachable.

## Skill-specific implementation translation

The installed accessibility skill contains web examples. This Flutter project
will implement the equivalent behavior with `Semantics`, native buttons and
fields, `FocusTraversalGroup`, `MediaQuery.disableAnimationsOf`, text-scaling
tests, and explicit state announcements.

The installed visual-testing skill is Playwright-oriented. Flutter Web is
deferred, so the pass will apply its determinism and baseline-review principles
through Flutter widget/golden capture infrastructure. No Web build, browser
runtime, hosted visual-testing service, or new JavaScript test stack is
authorized.

## Baseline reconciliation

Before this audit, the working tree contained only the creator-requested skill
installations:

- `skills-lock.json`
- `.agents/skills/accessibility-compliance/`
- `.agents/skills/flutter-build-responsive-layout/`
- `.agents/skills/flutter-design-system/`
- `.agents/skills/visual-testing/`

No player-facing file had changed on this branch at the time of this record.
