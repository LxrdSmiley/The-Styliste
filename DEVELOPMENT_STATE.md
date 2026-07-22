# The Styliste development state

Last updated: 2026-07-22
Updated by: Codex
Authority: `PROJECT_RULES.md`, `VERIFICATION_PROTOCOL.md`, canonical first body of `THE_STYLISTE_GDD_v7.md`

## Current Directive 1X state

Decision: **Partially aligned / blocked from publication**.

Baseline and checkout:

- Original branch: `master`.
- Original HEAD and `origin/master`: `ea5a6675ceb13772401d3b819f7566a313ec7a79`.
- Current branch: `codex/gdd-v7-kingston-alignment-20260722`.
- Last validated implementation HEAD before this state record:
  `ca72fa31e3ce557eaba9eecd2d5a4bbc811af5ec`.
- Local Directive 1X commits:
  - `961d2d3` — `docs: record GDD v7 alignment findings`;
  - `f61d874` — `fix: enforce Kingston API authority boundaries`;
  - `8889d66` — `test: make authority guard line-ending safe`;
  - `ca72fa3` — `test: preserve Deno source line endings`.
- No commit has been pushed. `origin/master` remains the baseline.
- The dirty tree was externally preserved before Directive 1X changes at
  `C:\Users\Karriene Hall\AppData\Local\Temp\the-styliste-directive-1x-preservation-20260722-115940-131.zip`
  with SHA-256
  `bc2c521b6d2bf8edd64b37c4ad2dacf45778655b71a932e0bf148b043ee9091d`.

Current implemented backend scope:

- Six enabled Kingston Edge routes share one strict actor-derived request
  boundary: `founder-trial`, `drop-design`, `open-first-store`,
  `calculate-idle-income`, `progression-event`, and `submit-player-report`.
- Later-wave social, mini-game reward, marketplace/transaction, Maison, IAP,
  trend, Eclipse, Realtime, and Storage surfaces remain disabled.
- Forward-only migrations define an `api`-only Data API, private/service-only
  authority functions, append-only versioned receipts, deterministic actor
  locks, exact replay, and conflicting-replay rejection.
- House Funds, lifetime gross revenue, lifetime costs, net result, and idle
  source rates are separated. First-store settlement preserves non-store idle
  sources.
- Starter design release validates a frozen catalog, session/actor ownership,
  and Vex opt-in without count-based scoring. Full canonical DesignBlueprint,
  lineage, rendering parity, and targeted revision remain incomplete.
- Active Feed data calls are confined to the owner-scoped
  `api.feed_projection`; later-wave social reads/mutations fail closed.
- The executable alignment register is
  `docs/governance/GDD_V7_CODE_ALIGNMENT_MATRIX.md`.

Observed validation on 2026-07-22:

- Dirty working tree: all five required static scripts exit `0`, labelled
  `Static pass`.
- Exact committed tree: GDD, deferred-TODO, and authority-inventory guards pass;
  the Early Game allowlist correctly fails because its matching Flutter caller
  corrections are still uncommitted, and the release-metadata guard correctly
  fails because its version/changelog dependencies are still uncommitted.
- `git diff --check`: exit `0`; line-ending warnings only.
- Exact committed-tree Supabase migration chain: every migration through
  `20260722190000_gdd_v7_kingston_authority_corrections.sql` applied. The most
  recent reset command returned `1` only after migration completion because
  the disabled local Storage service missed its health deadline; subsequent
  `supabase status` reported the local setup running. This detached-worktree
  replay used the original committed `001_initial_schema.sql` and
  `20260713122917_vertical_slice_first_hour.sql`; inherited edits to those
  published migrations were excluded and are not required.
- `supabase migration list --local`: exit `0`, complete through `20260722190000`.
- `supabase db lint --local --level error --fail-on error`: exit `0`.
- Transactional RLS authority and Kingston API contracts: exit `0` with
  rollback.
- Immediate authority containment: 44/44 pass.
- Security hardening pass 1: 15/15 pass.
- Four 20-session concurrent races (Founder, design release, first store, idle):
  pass with zero failed transaction/deadlock and one stable settlement effect.
- Exact committed-tree Deno formatting and type-check: exit `0` for shared
  modules and all six enabled entrypoints. `.gitattributes` now keeps TypeScript
  at LF on Windows checkouts.
- Exact committed-tree Edge identity/validation: 13/13 pass.

Known required failures/blockers:

- `platform_auth_mappings_identity_containment.test.sql` and
  `platform_auth_mappings_anonymous_access.test.sql` require authenticated
  direct `public.platform_auth_mappings` reads. They fail under the final
  API-only boundary and are protected from modification by prior authorization.
- `progression_feed_migration_repair.test.sql` requires authenticated raw
  `public` reads and a client-executable legacy progression wrapper; it fails
  under the API-only boundary.
- `execute_power_move_ownership_test.sql` requires authenticated execution of
  deferred crisis/power-move functions; it fails because those functions are
  quarantined for Kingston.
- The required repository `frontend-design` skill is unavailable. No
  player-facing UI change, full-alignment claim, or final GitHub push is
  permitted until it is located and loaded.
- Codex did not run Dart or Flutter. Smiley must run format, both analyzers,
  full unit/widget and integration tests, and debug/profile APK builds.
- The nonvisual Flutter data-contract changes remain uncommitted and
  unverified.
- The local commit sequence is intentionally not review-ready: a fresh checkout
  still has the baseline Flutter actor-ID contradiction until the uncommitted
  caller fixes pass Smiley validation and receive a separate commit.
- Physical Android QA, accessibility observation, profile performance, signing,
  production deployment, and production data access remain not performed.

Next safe action:

1. Smiley runs the exact Flutter/Dart command set recorded in the Directive 1X
   report.
2. Resolve the protected/historical SQL test-policy conflict through separate
   authorization without reopening raw `public` access.
3. Install or restore the real repository `frontend-design` skill before any UI
   implementation.
4. Only then create remaining scoped commits, rerun all applicable gates, and
   consider a normal review-branch push. Never push or merge `master`, deploy
   production migrations, force-push, sign, or distribute from this state.

## Historical Directive 0/1 record (superseded by the current section)

## Directive 0 governance lock

Prior approved source baseline:
- Branch: master
- HEAD: ea5a6675ceb13772401d3b819f7566a313ec7a79
- origin/master: ea5a6675ceb13772401d3b819f7566a313ec7a79

Current milestone:
- Pre-Alpha / Kingston Proof-of-Fun Recovery

Current directive:
- Directive 1 — Establish the Kingston Early Game API authority contract

Verification classification:
- Backend/security implementation; static and isolated Edge execution complete
- Flutter/Dart compilation: Blocked / not run
- Database execution: Blocked by unresponsive local Docker API
- Device and performance evidence: Blocked / not run

UI/UX implementation rule:
- All future player-facing UI work must load and follow the repository frontend-design skill under GDD v7 §18.1.

## Directive 1 — Kingston Early Game API authority contract

Status: **Revise — implementation and static/Edge evidence present; executable database evidence blocked by the local Docker API**.

Binding baseline before Directive 1 work:
- Branch: `master`
- HEAD: `ea5a6675ceb13772401d3b819f7566a313ec7a79`
- origin/master: `ea5a6675ceb13772401d3b819f7566a313ec7a79`
- Ahead/behind: `0/0`
- Staged files: none

Directive 0 follow-up:
- Approved as `Static pass`.
- The remaining 14-line restarted table-of-contents fragment contained no
  Feature ID, rule, changelog item, reference target, or unique canonical
  content and was removed.
- `scripts/check_gdd_registry.ps1` now rejects a restarted Markdown TOC after
  canonical closing material; current result: exit `0`, `Static pass`.

Exact enabled Edge allowlist:
- `founder-trial`
- `drop-design`
- `open-first-store`
- `calculate-idle-income`
- `progression-event`
- `submit-player-report`

Exact service-role-only API wrappers:
- `api.server_founder_trial_intent_v1`
- `api.server_design_intent_v1`
- `api.server_open_first_store_v1`
- `api.server_settle_idle_income_v1`
- `api.server_progression_event_v1`
- `api.server_submit_player_report_v1`

Exact owner-scoped API projections:
- `api.player_summary`
- `api.brand_summary`
- `api.founder_trial_state`
- `api.owned_designs`
- `api.design_session_state`
- `api.feed_projection` (owner-authored Kingston projection only)
- `api.first_week_objectives`
- `api.store_summary`
- `api.progression_state`
- `api.design_release_receipts`
- `api.first_store_receipts`
- `api.idle_settlement_receipts`

Disabled later-wave/configured surfaces:
- `feed-react`, `feed-comment`, `feed-inspiration`, `mint-design`
- `claim-mini-game-reward`, `process-transaction`, `maison-donate`
- `validate-iap`, `trend-decay`, `eclipse-event-tick`
- Realtime and Storage are disabled in local project configuration.
- Deferred source was preserved. Remaining source callers for mini-game reward,
  Maison donation, and IAP validation are outside the active Kingston routes and
  remain a later-wave cleanup concern; their endpoints are disabled.

Evidence labels:
- Static — GDD registry: `Static pass`, exit `0`.
- Static — authority inventory: `Static pass`, exit `0`.
- Static — Early Game contract: `Static pass`, exit `0`.
- Executed Edge — Deno type-check: `Passed`, exit `0`, all six entrypoints plus
  shared contract/routes and the identity test.
- Executed Edge — identity suite: `Passed`, 9 tests, 0 failed. It covers the
  shared boundary used by all six routes, actor-field rejection, missing,
  malformed, and rejected/expired tokens, verified owner derivation, foreign
  resource transport without actor substitution, replay-key transport, and the
  disabled-route dispatcher inventory.
- Executed database — `Blocked`: `supabase db reset --local --no-seed` timed out
  after approximately 184 seconds without output; `supabase status` and
  `docker ps` then also timed out. No migration success or failure is claimed.
- Executed concurrency — `Blocked`: the 20-session harness exists but was not
  run because the local database was unavailable.
- Database lint/migration alignment — `Blocked` by the same local Docker API.
- Dart/Flutter — `Not run by Codex` per Directive 1 prohibition; Smiley evidence
  remains required.
- Device/performance — `Not run`; no physical Android QA claim.
- Production — `Not accessed`, `not linked`, and `not deployed`.

Feature status:
- No Feature ID is promoted to `enabled`, `playable`, or `validated` because
  database reset, negative-role SQL, replay, and 20-session concurrency evidence
  has not executed.
- The catalog assigns `SEC-01`, `SEC-02`, `SEC-03`, `SEC-04`, `SEC-06`, and
  `SEC-12`; `TECH-01` and `TECH-02` govern the shared API/receipt boundary.
- The exact endpoint/catalog contract is recorded in
  `supabase/tests/authority_contract_matrix.json`.

Known remaining mismatches/blockers:
- The idle settlement is wired to the reviewed endpoint, but the existing
  later-wave warehouse presentation expects fields the Kingston receipt does
  not safely provide. The data layer returns a typed unavailable exception
  after settlement instead of fabricating inventory values; UI remediation is
  deferred until the required frontend-design skill and a UI directive exist.
- The new forward migration has not been executed against disposable Postgres,
  so SQL typing, grants, view return types, rollback cases, and ledger behavior
  remain unverified.
- Dart/Flutter formatting, analysis, and focused/full tests must be run by
  Smiley from the unchanged working tree.
- The repository `frontend-design` skill remains unavailable. This does not
  block backend-only Directive 1, but it blocks Directive 2 and all future UI
  implementation. `docs/UI_UX_DESIGNER_MASTER_PROMPT.md` was not used as a
  substitute.
- Directive 2 is not authorized and has not begun.

## Current position

- Milestone: **Pre-Alpha — Kingston Proof-of-Fun Recovery**.
- Directive 0: **Complete**.
- Directive 0 classification: **Static pass**.
- No gameplay feature has been activated.
- Next work requires new authorization.
- Any future UI work requires locating and loading the repository
  `frontend-design` skill before edits.
- Release posture: **Not Alpha-ready**.
- Current checkout: `master` at `ea5a6675ceb13772401d3b819f7566a313ec7a79`, matching `origin/master` after an observed `git pull --ff-only` on 2026-07-22.
- Pull result: fast-forward from `3cc1d718bc7ca0cd484efbce4aea37762710350c`; the remote change updated `THE_STYLISTE_GDD_v7.md`.
- Preserved local GDD patch: `stash@{0}: codex-pre-audit-local-gdd-v7-2026-07-22`. Directive 0 inspected it without applying, popping, or modifying it. The pre-cleanup GDD was a strict superset of the stash: the stash contained the canonical body followed by sections 1–9 of the same confirmed stale duplicate sequence, with no content absent from the pre-cleanup file.
- Working tree: extensively dirty before and after the pull. All unrelated user work remains preserved.
- Active promotion Feature ID: none. Directive 1 assigned the reviewed endpoint
  catalog but withheld promotion until database/replay/concurrency evidence runs.
  Directive 2 and all later implementation remain unauthorized.
- Web/Chrome/Pages: `Not applicable` to the current Android/iOS milestone.

## Audit outcome

The codebase was audited against GDD v7, `PROJECT_RULES.md`, and `VERIFICATION_PROTOCOL.md`. The binding findings and implementation sequence are in `IDE_DIRECTIVES.md`; operator-only work is in `MANUAL_TASKS.md`.

The repository has useful foundations—Flutter/Riverpod organization, Supabase Auth migration work, append-only ledger concepts, idempotency work, an `api` schema boundary, feature-route restrictions, CI guards, and a GDD Feature ID registry—but the checked-in implementation does not yet complete the GDD v7 Early Game causal loop.

Release-blocking findings:

- GDD v7 authority duplication was resolved by removing only the confirmed appended second whole-document body. The first canonical body and its 148 unique Feature IDs remain authoritative, and the whole-file registry guard now rejects recurrence.
- `supabase/config.toml` exposes only `api`, while active Flutter code and most enabled Edge Functions still call default `public` RPC/table surfaces. The final migration revokes authenticated execution on all `public` functions. The client/server contract is therefore inconsistent and active mutations are expected to fail under the declared boundary.
- Later-wave social, Maison, mini-game, IAP, and live-event functions are now
  disabled in `supabase/config.toml`; deferred source is preserved.
- The active onboarding is the obsolete seven-screen Sovereign Genesis flow, not the server-resumable Luxe Founder Trial.
- Atelier touch input does not own the saved blueprint; server Hype is primarily an array-count formula and conflicts with a legacy mint score.
- Architect gameplay does not yet provide an authoritative diagnose/intervene/observe/recover loop; store strategy fields are dropped by the Dart model and some displayed analytics are fixed/fabricated.
- `total_revenue` is overloaded as spendable funds and lifetime revenue; first-store opening overwrites the starting idle rate with a much smaller store sum.
- Idle client/function names, required request fields, and response fields disagree; House While Away is absent and settlement ownership is path-biased.
- The active Feed is cross-player social functionality even though Early Game permits only the authored NPC Feed.
- Required connected customer, supplier, buyer, Daily Brief, crisis/recovery, and Archive loops are incomplete or absent.
- Security contracts execute only a subset of the negative-role, endpoint, Realtime, Storage, and concurrency matrix.
- At least 70 Dart files appear unreachable under a static import-graph heuristic; analyzer/coverage evidence is required before classifying or deleting them.
- Legal documents are explicit closed-alpha placeholders and describe deferred features.
- Performance, device, live Auth/RLS, legal, and proof-of-fun evidence remain unobserved.

## Verification evidence from this audit

| Area | Result | Evidence |
|---|---|---|
| Git pull and remote equality | Passed | Local and remote HEAD both `ea5a6675...` |
| GDD registry | Static pass | Whole-file guard confirms one numbered section sequence (1–24), 148 unique Feature IDs, required FTUE/security acceptance IDs, strict UTF-8, and no known mojibake markers |
| Deferred TODO inventory | Static pass | `scripts/check_deferred_todos.ps1` |
| Authority name inventory | Static pass | `scripts/check_authority_matrix.ps1`; not behavioral proof |
| Release metadata | Static pass | `scripts/check_release_metadata.ps1` for `v0.1.0-alpha.1` |
| Patch whitespace | Static pass | `git diff --check`; line-ending warnings only |
| Flutter dependency resolution | Blocked | Not run after the pull/current dirty changes |
| Dart formatting | Blocked | Not run by Codex; Smiley must execute |
| Flutter analysis | Blocked | Not run by Codex; Smiley must execute |
| Flutter unit/widget tests | Blocked | Not run by Codex; prior runs do not cover current checkout |
| Flutter integration tests | Blocked | No explicit current execution |
| Supabase reset/lint | Blocked | Reset timed out without output; status and Docker API commands also timed out |
| RLS/authority contract | Static pass only | Focused executable SQL exists; database execution unavailable |
| Edge type-check | Passed | All six enabled entrypoints, shared modules, and identity test exited `0` |
| Edge identity unit suite | Passed | 9 passed, 0 failed |
| Hosted Supabase schema/settings | Blocked | Dashboard/live project not inspected in this audit |
| Android build/startup | Blocked | Not run; drive C has approximately 1.27 GB free |
| Device/accessibility/performance | Blocked | No Galaxy A55/lower-device profile evidence |
| Full-history secret scan | Blocked | Local `gitleaks` unavailable/unobserved |
| Legal readiness | Blocked | Placeholder copy; counsel and operations unavailable |
| F2P/dual-path parity | Blocked | No simulation/playtest; structural economy defects present |
| Proof of fun | Blocked | Full causal loop is not implemented and has not been playtested |
| Flutter Web/Pages | Not applicable | Explicit owner decision for current mobile milestone |

Historical passing results recorded before the current pull/dirty changes remain historical only. They do not promote current source to `Passed`.

## Next safe action

Directive 1 is `Revise`: implementation, static guards, and isolated Edge tests
are present, but the disposable SQL, lint, migration alignment, and 20-session
concurrency evidence could not run because the local Docker API was unresponsive.
Stop after the Directive 1 report. Do not promote Feature IDs, deploy, or begin
Directive 2. Before any future UI edit, restore and load the repository
`frontend-design` skill under the GDD v7 §18.1 rule.

Do not stage or commit the entire dirty tree as one change. Do not restore `public` Data API exposure to make legacy calls work. Do not start multiplayer, monetization, Milan, or other deferred scope.

## Current prohibited scope

- No Web/Chrome/Pages work.
- No Firebase restoration or second backend.
- No second state-management or design system.
- No client-owned economy, rewards, scoring, ownership, timestamps, progression, or offline duration.
- No player Feed, public profile, follows, comments, DMs, Maisons, Gala, territory, marketplace, IAP, ads, premium rewards, advanced finance, additional city, generative AI, or endgame exposure during recovery.
- No deletion of historical migrations.
- No deletion of source based only on a text reachability heuristic.
- No `Passed`, Alpha-ready, security-ready, performance-ready, or production-ready claim without the exact observed evidence required by `VERIFICATION_PROTOCOL.md`.
