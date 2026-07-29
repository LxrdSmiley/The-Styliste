# Changelog

Completed player-facing changes are recorded here. Verification status belongs
in `docs/verification/early_game_readiness.md`, not in release-marketing claims.

## [Unreleased]

### Added

- Added editorial Aurelian hero, evidence-band, and garment/pattern-cutting
  components across the reachable Gate A experience.
- Added a shared 14-state reliability presentation covering loading, empty,
  editing, submitting, confirmed, restored, offline, retryable error,
  terminal error, permission denied, session expired, maintenance, disabled,
  and unavailable conditions.
- Added deterministic expansion-pass review evidence: 24 before-renders, 44
  after-renders, four contact sheets, and an indexed 320 px large-text /
  412 px reduced-motion review.

- Added the Gate A Kingston Capsule Foundation: a Collection Brief and exactly
  three ordered Atelier looks—Hero Piece, Commercial Anchor, and Experimental
  Piece—with a visible server-confirmed readiness result.
- Added a deliberate sampling-unavailable boundary after capsule readiness;
  this slice creates no production, launch, score, reward, or Vex outcome.

### Changed

- Expanded Opening Sanctuary, Founder Trial, HQ, Atelier, the three-look
  capsule, Empire, Feed, House, Settings, Legal, and the five-tab shell with
  clearer hierarchy, contextual authority/preservation evidence, and one
  primary next action.
- Strengthened Atelier's fashion-specific visual identity with role-specific
  garment silhouettes, tailoring marks, bounded inspectors, explicit
  readiness causes, and a deliberate sampling boundary.
- Replaced technical backend terminology in player-facing reliability copy
  with plain-language secure-service wording.

- Founder Trial completion now leads into the Atelier capsule workspace. The
  Artisan and Architect lenses remain equal in gameplay ceiling.
- Redesigned all reachable Gate A player-facing surfaces with the canonical
  Aurelian visual system, including session safety, onboarding, HQ, Atelier,
  capsule, Empire, Feed, House, settings, legal, and the five-tab shell.
- Replaced active mint-to-drop reachability with a clear capsule-readiness and
  sampling-unavailable boundary. Deferred drop routes now present a safe
  unavailable state.

### Repository

- Installed and locked the requested standalone accessibility,
  responsive-layout, Flutter design-system, and visual-testing skills.
- Published the complete UI expansion on
  `codex/aurelian-ui-expansion-pass-2` at implementation SHA
  `717e41faecda9798b4a29eb01f8cba85ab7aac2f`.

- Added Semantic Versioning and synchronized prerelease metadata for
  `0.1.0-alpha.1+1`.
- Added a guarded GitHub draft-prerelease workflow and version-specific release
  notes.
- Replaced the Firebase identity bridge with direct Supabase Auth session
  bootstrap and recovery across Android and iOS.
- Removed Firebase client packages, platform configuration, Messaging/App Check
  startup, and the retired FCM Edge Function source.
- Deferred Flutter Web, Chrome, and GitHub Pages work; removed Web compilation
  from the active mobile readiness gates.
- Required README, changelog, release-note, and development-state maintenance
  after applicable implementation tasks.
- Separated ordinary debug APK smoke CI from protected signed-release evidence,
  removing an impossible requirement for ignored signing files on every push.

### Fixed

- Deployed the missing server-authoritative Founder Trial endpoint and its
  complete reviewed migration history to the configured Supabase project, and
  activated the reviewed hosted `api` schema boundary required by that
  endpoint. Existing A55 sessions can retry the preserved House-name intent
  without rebuilding the app; device confirmation remains pending.
- Preserved Supabase identities when a session refresh fails for a temporary
  connectivity reason; only terminal anonymous-session failure may create a new
  founder-trial identity, while linked accounts require explicit sign-in.
- Allowed the service-role design-release wrapper to execute for an actor whose
  bearer token was verified by the Edge Function.
- Made first and replayed design-release receipts identical and keyed each
  design-release ledger entry by design ID.
- Separated spendable House Funds from lifetime gross revenue, costs, net
  result, and idle-source rates in the forward-only Kingston authority model.
- Preserved non-store idle sources when the first Kingston store opens.
- Required server-owned starter-catalog validation and explicit Vex opt-in for
  design release without count-based score inflation.

### Security

- Kept raw `public`, `private`, and `ledger` relations outside the gameplay Data
  API throughout the new migration sequence; authenticated gameplay uses only
  reviewed `api` projections while enabled Edge mutations use service-only API
  wrappers.
- Added strict shared Edge validation for verified actor derivation, unknown
  keys, malformed JSON, UUID idempotency, body size, exact replay, and conflict
  responses across the six Kingston routes.
- Completed redacted historical Firebase/GCP key remediation and final
  Gitleaks 8.30.1 history/working-tree scans. Current source uses Supabase and
  contains no Firebase runtime reference.

## [0.1.0-alpha.1] - Unreleased

### Changed

- Limited the default Early Game navigation to HQ, Atelier, Empire, Feed, and House.
- Disabled late-wave deep links and sensitive mutation surfaces behind the feature registry.
- Changed the first-store tutorial contract to the Kingston Founder Trial flow.
- Added a versioned Early Game Design Blueprint with local Riverpod draft state and server-validated release intent.
- Made idle-income receipts and design-release results server-owned and replay-safe at the database boundary.
- Removed the Google Mobile Ads sample application ID and Early Game ad dependency.

### Security

- Removed direct authenticated writes to economic, progression, ownership, score, Maison-governance, and moderation data.
- Moved privileged database behavior behind reviewed service-only API wrappers and an append-only ledger.
- Added an API schema boundary, fail-closed authority matrix, RLS contract tests, and generated API inventory checks.
- Added full-history secret scanning to CI and documented placeholder-only environment names.

### Deferred

- User-run Flutter dependency resolution, analysis, tests, and Android build.
- Flutter Web, Chrome runtime, Pages deployment, and public-browser support are
  outside the current mobile milestone.
- Anonymous-sign-in CAPTCHA, account-upgrade UX, device performance,
  accessibility, purchase sandbox, and penetration verification.
