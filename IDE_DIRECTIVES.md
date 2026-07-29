# IDE_DIRECTIVES.md

## Decision

**The complete Aurelian UI Expansion Pass 2 is implemented, locally verified,
and published to its dedicated branch. Final visual approval remains pending
Smiley's review of the expansion-pass renders.**

This is a source, widget/runtime, disposable-database, security, and
deterministic-render handoff. It is not Android, iOS, Web, physical-device,
staging, deployment, or release-readiness evidence.

Authority: `THE_STYLISTE_GDD_v8.md` sections 4–8, 12, 18, 21–22;
`ART_DIRECTION_BIBLE.md`; the ranked companion authorities;
`PROJECT_RULES.md`; and `VERIFICATION_PROTOCOL.md`.

## Post-handoff Founder Trial remote unblock

On 2026-07-29, Smiley explicitly authorized the configured **The Styliste**
Supabase project for the complete pending migration set and the
`founder-trial` Edge Function.

```text
Supabase CLI: Updated from 2.104.0 to 2.110.0 with the published checksum
Remote migration deployment: Passed — 13 migrations applied with --include-all
Remote migration inventory: Passed — 61/61 local and remote versions match
Founder Trial Function deployment: Passed — ACTIVE with verify_jwt=true
Unauthenticated Function boundary: Passed — HTTP 401
First post-deployment A55 retry: Failed — hosted Data API rejected api schema
Remote Data API boundary: Passed — api schema is now exposed
Authenticated Galaxy A55 retry after Data API correction: Blocked — awaiting observation
```

Remote logs explain the reported device failure: every captured Founder Trial
attempt before deployment returned HTTP 404 because the Function did not
exist. After Function deployment, authentication succeeded but PostgREST
returned HTTP 406 / `PGRST106` because the hosted project still exposed only
`public` and `graphql_public`. The repository's reviewed `api` boundary is now
active; an unauthenticated `api` request reaches that schema and is denied by
its database permissions instead of failing schema selection.

The CLI configuration command used to inspect this mismatch did not honor the
piped negative response as a preview. It synchronized both the reviewed API
configuration and the repository's Auth configuration. No further
configuration write or rollback was attempted. The Auth result matches the
repository configuration—anonymous sign-in enabled, email sign-up disabled,
and stricter password/rate-limit settings—but remains runtime-unverified and
the broader-than-requested write is recorded in `BOTTLENECK_LOG.md`.

This addendum supersedes only the original handoff's statements that no remote
action had occurred. It does not promote staging, device, security,
accessibility, performance, or release readiness.

## Repository position

```text
Starting branch: codex/gate-a-wave-2a-ui-redesign
Starting SHA: c4405414195f5bcdff87b31848c3425a17e76e85
Implementation branch: codex/aurelian-ui-expansion-pass-2
Implementation SHA: 717e41faecda9798b4a29eb01f8cba85ab7aac2f
Implementation commit: feat(ui): expand the Aurelian experience across all player screens
Implementation push: Passed
Pull request: Not created
GitHub Actions matching this branch: 0
```

The implementation branch was pushed normally to `origin`. At the original
handoff, no direct `master` push, force-push, pull request, workflow dispatch,
tag, release, deployment, or remote Supabase action had occurred. The
authorized post-handoff Founder Trial deployment is recorded above.

## UI/UX skill audit

The following skills were discovered and invoked before player-facing source
changes:

- `frontend-design`
- `ui-ux-designer`
- `ui-ux-pro-max`
- `flutter-expert`
- `supabase`
- `accessibility-compliance`
- `flutter-build-responsive-layout`
- `flutter-design-system`
- `visual-testing`

Accepted recommendations:

- semantic canonical design tokens;
- 48 dp touch targets and 4/8 dp rhythm;
- editorial hierarchy and meaningful negative space;
- explicit async, preservation, authority, and retry states;
- portrait-first responsive constraints;
- large-text and reduced-motion variants;
- visible non-color status cues and semantics;
- restrained interaction feedback;
- deterministic visual fixtures and manual comparison; and
- Riverpod rebuild containment with immutable display data.

Rejected recommendations:

- app-store landing-page composition;
- Playfair or Source Serif typography;
- pink conversion CTAs;
- zero-radius brutalism;
- GSAP or Web-specific motion architecture;
- generic monochrome fashion styling;
- a second design system; and
- UI-owned economic or progression authority.

Rejection authority was GDD v8, the Aurelian creative authorities, existing
typography and Flutter architecture, accessibility, performance, security,
and Gate A scope.

```text
UI/UX Codex skills used: frontend-design, ui-ux-designer, ui-ux-pro-max,
flutter-expert, supabase, accessibility-compliance,
flutter-build-responsive-layout, flutter-design-system, visual-testing

The skills were invoked before source changes: Yes
Aurelian and GDD v8 compliance reviewed: Yes
Accessibility states reviewed: Yes
Final visual approval by Smiley: Pending Smiley review of expansion-pass renders
```

## Implemented player-facing expansion

### Session and onboarding

- Session loading now explains that no gameplay request starts before secure
  identity resolution.
- Authentication failure is player-safe, non-technical, retryable, and
  explicit that no progression write occurred.
- Opening Sanctuary introduces fashion authorship, Kingston creative
  authority, House identity, and the Artisan/Architect duality without a
  prolonged slideshow.
- The age gate remains legally direct and owns no gameplay progress.
- Luxe guidance is concise and avoids invented praise.
- House naming distinguishes local draft intent from authenticated server
  confirmation.
- Founder Trial gives Artisan and Architect distinct visual authorship and
  positioning treatments while preserving one gameplay ceiling, one House,
  stable idempotent receipts, and confirmed/restored states.

### HQ

- HQ is organized around House identity, Kingston context, one primary
  capsule action, current objective status, confirmed evidence, and secondary
  indicators.
- Artisan and Architect framing changes presentation and decision language,
  never the authoritative ceiling.
- Loading, error, and completion states remain visible and actionable.

### Atelier and capsule

- Atelier now uses garment silhouettes, pattern-cutting lines, tailoring
  annotations, material/palette relationships, and compact inspectors.
- Local garment study is visibly separated from bounded authenticated capsule
  intent.
- Collection Brief explains narrative and bounded grammar before submission.
- Hero Piece, Commercial Anchor, and Experimental Piece have distinct visual
  roles and forward-only stages.
- Readiness causes are explicit and server-derived.
- Confirmed and restored receipts show authority and preservation evidence.
- Sampling is deliberately unavailable after readiness; no production,
  launch, reward, Vex result, or Archive settlement was added.
- `/atelier/drop-preview` and `/atelier/drop-launch` remain shared unavailable
  boundaries with no deferred provider initialization or backend request.

### Empire and Feed

- Empire uses real read-only brand/store projections, operational hierarchy,
  receipts, constraints, and deliberate unavailable boundaries without
  inventing stores, customers, deliveries, suppliers, or staff.
- The existing first-store dialog distinguishes local form state from the
  authenticated server request.
- Feed is presented as a House editorial record rather than a generic social
  list.
- Current record cards explain who, what happened, why it matters, what
  changed, and the available next action.
- Comment and request sheets are explicitly read-only/held and cannot simulate
  a social mutation.

### House, settings, legal, and shell

- House presents verified House identity, Founder Path lens, Kingston,
  current authority, and bounded House-code language without fabricated
  Archive history or awards.
- The 320 px / 1.6× text fixture uses a stacked identity layout.
- Settings remain presentation-only and cannot change progression or economy.
- Legal documents use Aurelian hierarchy while preserving readability and
  their not-launch-approved status.
- The shell keeps the exact order `HQ`, `Atelier`, `Empire`, `Feed`, `House`
  with selected-state semantics, safe-area handling, and stable destination
  ownership.

## Shared system and reliability coverage

The pass extends the existing canonical token sources only:

```text
StylisteColors
StylisteText
StylisteSpacing
StylisteRadii
StylisteMotion
StylisteVisualMode
AurelianTheme
```

No second token source, UI package, font package, animation package, state
framework, or design system was introduced.

Shared additions include:

- editorial hero and evidence-band composition;
- garment/pattern-cutting line frames;
- consistent authority, preservation, and retry facts; and
- `AurelianStatePanel` coverage for loading, empty, editing, submitting,
  confirmed, restored, offline, retryable error, terminal error, permission
  denied, session expired, maintenance, disabled, and unavailable.

Player-facing state copy does not expose raw Supabase, PostgreSQL, Edge, RPC,
or stack-trace errors.

## Accessibility, responsive, and performance review

The source and widget review covers:

- 320–412 px portrait layouts;
- 48 dp minimum controls;
- text scale through the existing large-text tests and a deterministic
  320 px / 1.6× House fixture;
- screen-reader labels, state semantics, and selected navigation;
- non-color status cues;
- reduced-motion behavior and a 412 px Atelier fixture;
- safe-area and keyboard-aware scrollable layouts;
- overflow checks;
- one clear next action; and
- provider-state/restoration behavior.

The pass preserves Riverpod repositories/controllers and uses existing
provider ownership. Display components receive data and callbacks; they do not
take ownership of progression or economic state. No migration, RPC, Edge
Function, policy, ledger, reward, or game-authority implementation changed.

The architecture was reviewed for excessive blur, opacity, animation, nested
scrolling, broad provider watches, and fixed-height large-text failure.
Physical-device 60 fps and accessibility remain `Blocked`.

## Verification evidence

| Evidence | Result |
|---|---|
| Dart formatting | `Passed` — 229 files, 0 changes |
| Flutter analysis | `Static pass` — no issues |
| Flutter tests | `Passed` — 135 tests |
| Deterministic capture suite | `Passed` — 44 tests/renders |
| Supabase reset | `Passed` — 61 migrations |
| Supabase lint | `Passed` — exit 0 with six inherited warnings |
| pgTAP | `Passed` — 12 files / 108 assertions |
| Edge type checks | `Static pass` — 17/17 entry points |
| Edge identity/contracts | `Passed` — 16/16 |
| Economic concurrency | `Passed` — four mutations × 20 sessions |
| API inventory | `Passed` — 19/19 entries |
| Migration hashes | `Passed` — 61/61 |
| Migration tamper scenarios | `Passed` — 9/9 |
| GDD Feature IDs | `Static pass` — 160 unique IDs |
| Authority/API/allowlist/TODO/metadata guards | `Static pass` |
| Repository-health guard | `Passed` |
| Gitleaks 8.30.1 history | `Passed` — 101 commits, zero findings |
| Gitleaks 8.30.1 working tree | `Passed` — 11.38 MB, zero findings |
| Whitespace and conflict markers | `Passed` |
| Branch push | `Passed` |
| Matching GitHub Actions run | `Blocked` — zero runs; not triggered |

The first working-tree secret scan overlapped Flutter test-cache generation and
reported 17 private-key fixtures embedded in ignored dill output. No exception
was added. Generated output was cleared and both final redacted scans passed
with zero findings.

Detailed commands and status classifications are in
`docs/verification/aurelian_ui_expansion_pass_2/verification_results.md`.

## Deterministic visual evidence

The committed evidence contains:

- 24 before-renders;
- 44 after-renders;
- four after-render contact sheets;
- one complete capture manifest;
- the route/state surface inventory;
- the skill audit; and
- the approved design direction.

Every after-render visibly states:

```text
Deterministic source render — not physical-device evidence
```

All 44 after-renders were manually inspected. An initial review found and
corrected dark-receipt readability, active-role framing, and 320 px large-text
House layout. The final sheets show no Flutter overflow warning stripe.

Index:
`docs/verification/aurelian_ui_expansion_pass_2/visual_evidence_index.md`.

## Complete implementation changed-file inventory

### Installed UI/UX skill sources

- `.agents/skills/accessibility-compliance/` — five files
- `.agents/skills/flutter-build-responsive-layout/` — one file
- `.agents/skills/flutter-design-system/` — five files
- `.agents/skills/visual-testing/` — two files
- `skills-lock.json`

### Production source

- `lib/app.dart`
- `lib/core/theme/styliste_colors.dart`
- `lib/core/widgets/aurelian_components.dart`
- `lib/features/atelier/screens/atelier_screen.dart`
- `lib/features/capsule/screens/capsule_workspace_screen.dart`
- `lib/features/feed/screens/feed_screen.dart`
- `lib/features/ftue/widgets/first_objective_card.dart`
- `lib/features/hq/screens/hq_screen.dart`
- `lib/features/hq/widgets/hq_foundation_view.dart`
- `lib/features/ledger/screens/ledger_screen.dart`
- `lib/features/legal/screens/legal_document_screen.dart`
- `lib/features/onboarding/screens/aurelian_gate_screen.dart`
- `lib/features/onboarding/screens/founder_trial_screen.dart`
- `lib/features/onboarding/screens/origin_script_screen.dart`
- `lib/features/onboarding/screens/sovereign_registry_screen.dart`
- `lib/features/profile/screens/profile_screen.dart`
- `lib/features/settings/screens/settings_screen.dart`
- `lib/presentation/screens/main_shell.dart`

### Tests

- `test/core/widgets/aurelian_accessibility_test.dart`
- `test/features/capsule/capsule_workspace_screen_test.dart`
- `test/features/feed/feed_screen_accessibility_test.dart`
- `test/visual/aurelian_review_capture_test.dart`

### Verification evidence

- `docs/verification/aurelian_ui_expansion_pass_2/design_direction.md`
- `docs/verification/aurelian_ui_expansion_pass_2/surface_inventory.md`
- `docs/verification/aurelian_ui_expansion_pass_2/ui_ux_skill_audit.md`
- `docs/verification/aurelian_ui_expansion_pass_2/verification_results.md`
- `docs/verification/aurelian_ui_expansion_pass_2/visual_evidence_index.md`
- `docs/verification/aurelian_ui_expansion_pass_2/captures/before/` — 24
  indexed PNG files
- `docs/verification/aurelian_ui_expansion_pass_2/captures/after/` — 44
  indexed source-render PNG files and four contact sheets

The immutable Git inventory is available with:

```powershell
git show --name-status --format=fuller 717e41faecda9798b4a29eb01f8cba85ab7aac2f
```

No Supabase migration, database function, RLS policy, Edge Function,
repository DTO, route authority, reward, or progression implementation changed
in this pass.

## Inherited warnings and deferred evidence

Inherited warnings:

- five unmodified `OUT` variables in quarantined
  `public.execute_casting_pull`;
- one unread `v_brand` variable in
  `public.edge_open_first_store_atomic`;
- 31 packages locked below an upgradable version;
- 14 direct constraints below a resolvable version;
- discontinued transitive `build_resolvers` and `build_runner_core`;
- Windows LF-to-CRLF working-copy notices; and
- Supabase CLI 2.104.0's notice that 2.110.0 is available.

Deferred and `Blocked`:

- Android and iOS builds and installation;
- Flutter Web compilation/runtime;
- physical-device TalkBack and text scaling;
- physical-device performance and 60 fps;
- staging Supabase and deployment rehearsal;
- legal/privacy review;
- Jamaican/Caribbean cultural review;
- fashion-industry review;
- final art/audio review;
- representative player testing;
- retention and monetization validation; and
- release authorization.

## Scope and publication confirmation

No new gameplay was added to populate the UI. Sampling, manufacturing,
collection launch, Vex outcomes, recovery, Archive settlement, monetization,
multiplayer, territories, and later cities remain outside this pass.

The final status is:

```text
Local implementation gate: Passed
Dedicated-branch implementation push: Passed
GitHub Actions: Blocked — not triggered
Android and Web builds: Blocked
Remote Supabase and deployment: Blocked — not performed
Final visual approval: Pending Smiley review of expansion-pass renders
Production release: Blocked
```
