# IDE Directives — GDD v7 Codebase Readiness Audit

Audit date: 2026-07-22
Repository: `C:\STN\The-Styliste`
Branch: `master`
Audited HEAD: `ea5a6675ceb13772401d3b819f7566a313ec7a79`
Remote comparison: local `HEAD` equals `origin/master` after `git pull --ff-only`
Authorities: `THE_STYLISTE_GDD_v7.md`, `PROJECT_RULES.md`, `VERIFICATION_PROTOCOL.md`

## Audit verdict

**Current milestone: Kingston Proof-of-Fun Recovery / Pre-Alpha.**

The repository is **not Alpha-ready** and does not yet implement the GDD v7 Early Game causal loop. It contains useful Flutter/Riverpod structure and a serious attempt at a fail-closed Supabase boundary, but the active client, Edge Functions, and final database exposure contract do not agree. The expected result under the checked-in `api`-only Data API configuration is that onboarding and several active gameplay mutations cannot complete.

No Dart or Flutter command was run during this audit. Current compilation, tests, device behavior, 60 fps, and live Supabase behavior are therefore `Blocked`, not `Passed`.

### Repository snapshot

- Approximately 191 files under `lib/`, including large 600–1300-line screens.
- 16 unit/widget test files and 2 integration-test files.
- 54 Supabase migrations, 24 Edge Function entry-point files, 4 workflow files, and 7 repository scripts.
- A static relative-import/part scan did not find a missing referenced Dart source or generated part. This is not compiler evidence.
- Freezed/JSON generated files are present, but the source and `pubspec.lock` are dirty and require a current dependency/build-runner/analyzer check.
- Asset directories contain placeholders rather than production art. Shader files exist; no device/profile evidence exists.
- A static import-graph heuristic found at least 70 likely orphaned Dart files. Analyzer and coverage must confirm classification before deletion.

### Observed static results

| Check | Result | Evidence |
|---|---|---|
| Git synchronization | `Passed` | Fast-forward pull completed; local and remote HEAD are `ea5a6675...` |
| GDD registry guard | `Static pass` (incomplete) | The script validates only the first pre-glossary body and does not reject the appended second body |
| Deferred TODO guard | `Static pass` | `scripts/check_deferred_todos.ps1` |
| Authority inventory guard | `Static pass` | `scripts/check_authority_matrix.ps1`; name inventory only, not behavioral proof |
| Release metadata guard | `Static pass` | `scripts/check_release_metadata.ps1` for `v0.1.0-alpha.1` |
| Patch whitespace | `Static pass` | `git diff --check`; line-ending warnings only |
| Flutter compile/analyze/test | `Blocked` | Prohibited for Codex; current dirty checkout has not been rerun by Smiley |
| Supabase reset/lint/live RLS | `Blocked` | No disposable reset or hosted-project execution during this audit |
| Android/device/performance | `Blocked` | No build or profile run; drive C has about 1.27 GB free, below the 5 GB guard |
| Web/Pages | `Not applicable` | Explicitly outside the current mobile milestone |

## Highest-risk findings

| Priority | Finding | Static evidence and expected impact |
|---|---|---|
| P0 | GDD v7 has two active bodies | A complete older GDD begins again around line 4637. Sections 1–22 occur twice, and the registry check now fails. An IDE agent cannot reliably determine which rules control. |
| P0 | `api`-only Supabase boundary conflicts with active code | `supabase/config.toml` exposes only `api`. The final migration revokes authenticated execution on every `public` function. Active Flutter code and most Edge Functions still call `public` tables/RPCs. Onboarding, power moves, supply-chain actions, the player Feed, minting, first-store opening, and store upgrades are expected to fail or drift from the intended boundary. |
| P0 | Later-wave endpoints remain callable | Feed reactions/comments, Maison donation, mini-game rewards, IAP validation, trend jobs, and Eclipse jobs remain enabled in `supabase/config.toml`. Hiding routes does not disable an authenticated HTTP endpoint. This violates Early Game scope and unnecessarily expands the attack surface. |
| P0 | Security tests overstate coverage | The authority matrix checks names. The SQL contract executes only a subset of owner/stranger/replay cases; former-member, blocked-user, Storage, Realtime, Edge identity, and concurrency requirements remain comments. CI must not call those cases passed. |
| P0 | Active FTUE is an obsolete seven-screen Genesis flow | It selects New York/Paris/Tokyo/Milan, market tier, avatar, and “Ascension” before the first causal loop. Tutorial progress uses `SharedPreferences`. The client calls revoked `execute_sovereign_genesis` and sends `p_user_id`; no reviewed `api` wrapper exists. Luxe does not conduct the GDD Founder Trial. |
| P1 | Atelier input is cosmetic, while the score rewards array counts | Pointer movement changes shader uniforms but not the saved garment. `DesignBlueprint` and undo/redo exist but are not wired into the active Atelier. The server score is `35 + zone_count*5 + material_count*8 + palette_count*3 + construction_count*4`, so a modified client can maximize valid array counts without making a better design. Legacy mint and release paths also calculate different scores. |
| P1 | Architect loop is not diagnose → intervene → observe → recover | The first-store RPC records audience, price, capacity, cost, and demand, but the Dart `Store` model discards them. The UI mainly opens/upgrades a store. Fixed charts and heat explanations are fabricated, territory/power-move concepts are shown too early, and no authoritative store failure/recovery receipt exists. |
| P1 | Economy fields have conflicting meanings | `brand_state.total_revenue` is used as spendable capital and lifetime revenue. Opening a first store replaces the starting idle rate with the sum of store rates, reducing a Genesis rate of 500–3000/hour to roughly 1.4–6.16/hour. Artisan releases do not create an equivalent spendable-funds loop. F2P power is not currently sold, but path parity is unproven and structurally broken. |
| P1 | Idle settlement client/server contracts disagree | The client invokes `process_idle_income`; the configured function is `calculate-idle-income`. The client omits the required idempotency key and expects fields that the server does not return. The service is initialized from the Architect HQ rather than a path-neutral lifecycle owner. House While Away is absent. |
| P1 | Active Feed violates the Early Game registry | The current Feed polls cross-player data and exposes reactions, comments, follows, collaboration, and inspiration. GDD v7 `SOC-01` calls for an authored NPC Feed; player profiles and social Feed are `SOC-02` Beta. |
| P1 | Required Early Game living-world systems are missing | There is no connected named customer/cohort taste loop, supplier/buyer decision, Daily Brief system, or first branching crisis/recovery in the playable flow. Luxe, Vex history, blueprint, archive, and several NPC files appear orphaned from the main import graph. |
| P2 | Architecture contains substantial ghost/deferred code | A static import-graph heuristic found at least 70 Dart files not reachable from `lib/main.dart`; analyzer and coverage must confirm the final list. Large screens exceed 600–1300 lines. Deferred Gala, Maison, territory, IAP, minigame, casting, world-map, and endgame code increases maintenance and audit surface. |
| P2 | Performance readiness is unproven and has visible risks | Non-`autoDispose` providers poll forever every 30 seconds; Architect HQ rebuilds every two seconds; `GarmentCanvas` runs a manual ticker and overlapping pointer handlers; large widgets and shader/sensor effects lack profile evidence and reduced-motion proof. |
| P2 | Credential history is unproven | No obvious real service-role key or private key was found in the current tracked source scan, and ignored `.env.json` was not read. Full-history scanning is `Blocked` because local `gitleaks` evidence is unavailable. Retired Firebase configuration remains in history and `.firebaserc`; dashboard/CI secrets require owner review. |
| P2 | Legal copy is an internal placeholder | `legal_documents.dart` identifies itself as `Closed Alpha Placeholder v0.1` and describes IAP, Feed, Maisons, DMs, ads, and talent systems that are not approved for Early Game. Age gating, deletion/export operations, final retention/subprocessor terms, and counsel review are not complete. |

## Binding implementation rules

1. Work on only one gameplay directive, one backend/security directive, and one polish/tooling directive at a time.
2. Use forward-only Supabase migrations. Never rewrite an already-published migration to repair the current schema.
3. The Flutter client submits intent only. It never supplies authoritative owner IDs, balances, rewards, scores, timestamps, offline duration, inventory outcomes, or entitlements.
4. Do not re-expose the `public` schema to make broken calls work. Complete the reviewed `api` contract instead.
5. Do not enable multiplayer, monetization, territory, Gala, Store trading, private DMs, generative AI, or additional cities during Kingston Early Game recovery.
6. Do not run Dart or Flutter commands as Codex. Provide the smallest relevant commands for Smiley and record their observed result later.
7. After every directive, update `DEVELOPMENT_STATE.md`; update `BOTTLENECK_LOG.md` when the change adds recurring prevention. Do not mark a Feature ID `playable`, `validated`, or `enabled` without the evidence required by `VERIFICATION_PROTOCOL.md`.

## Directive 0: Restore a single GDD v7 authority

**Priority:** P0 — must precede gameplay implementation
**Authorized scope:** documentation/governance only

In `THE_STYLISTE_GDD_v7.md`, replace the duplicated whole-document structure with one canonical body: retain the detailed first body containing §21.3’s master Feature ID registry and remove the appended older body beginning with the second `## 1. Product Vision` after the first document’s closing material. Do not blend stale rules from the second body into the canonical body automatically.

Before editing, inspect the preserved local pre-pull GDD patch in `stash@{0}`. Smiley must decide whether any unique local text belongs in the canonical body; the IDE agent must not pop or apply the stash wholesale.

Acceptance criteria:

- Every numbered top-level section has exactly one canonical occurrence.
- `FTUE-01` through `SEC-14` remain present in the master registry.
- No non-UTF-8/mojibake text is introduced.
- `scripts/check_gdd_registry.ps1` is extended to reject a second whole-document body and then reports `Static pass`.

Test: run the registry guard and `git diff --check`; record only the observed labels. Cite GDD v7 §21.3 and PROJECT_RULES §§2–5.

## Directive 1: Contain the Early Game Supabase attack surface

**Priority:** P0
**Feature IDs:** `SEC-01`, `SEC-02`, `SEC-03`, `SEC-06`, `SEC-12`, `TECH-01`, `TECH-02`
**Depends on:** Directive 0

In a new forward migration under `supabase/migrations/`, replace the incomplete `api` boundary with an explicit Kingston Early Game contract. Keep base tables and privileged implementations in unexposed schemas. Add only the owner-scoped views and server-only wrappers required by the approved Early Game flow: player/brand state, Founder Trial state, design session/release, first-store action/result, idle settlement, progression event, and report submission. Each server mutation wrapper must require `service_role`, derive the player from a verified Edge Function actor, validate a UUID idempotency key, lock affected economic rows, and return one versioned receipt.

In every enabled Early Game Edge Function under `supabase/functions/`, replace default `admin.rpc(...)` calls with `admin.schema('api').rpc(...)` calls to a reviewed wrapper. In Flutter repositories/providers, replace direct default-schema table/RPC access with an owner-scoped `api` view or an authenticated Edge Function intent. Remove `p_user_id` from mobile request bodies when the server can derive `auth.uid()`.

In `supabase/config.toml`, replace the broad function list with an explicit Early Game allowlist. Disable Feed social mutations, Maison donation, mini-game reward claiming, IAP validation, Eclipse jobs, and any other later-wave function. Keep public player Feed, Maisons, Gala, territory, marketplace, and premium purchase endpoints off even if source remains in the repository.

Do not add `public` to `db.schemas`. Do not grant client roles execution on privileged functions. Do not use `user_metadata` as authorization.

Acceptance criteria:

- Every enabled function’s internal RPC exists in `api` and has an executable actor/role contract.
- No active Flutter Early Game path contains direct `.rpc('public_function')` or default-schema reads of private/economic tables.
- Hidden routes cannot call later-wave HTTP functions because those functions are disabled from the current deploy set.
- Service-role secrets remain server-only; no secret value appears in source, tests, logs, or mobile configuration.

Tests to add:

- Static allowlist test comparing `supabase/config.toml`, Edge Function folders, the API wrapper catalog, and Feature IDs.
- Disposable-database grants test proving authenticated/anon cannot execute privileged `public`, `private`, or `ledger` functions.
- Edge identity test proving a user cannot act for another UUID.
- Replay and 20-way concurrency tests for each economic mutation.

Smiley test commands are listed in `MANUAL_TASKS.md`. Cite GDD v7 §§19.2–19.10, 21.3 (`SEC-01`–`SEC-06`, `SEC-12`, `TECH-01`, `TECH-02`) and §22.

## Directive 2: Replace Sovereign Genesis with the Luxe Founder Trial

**Priority:** P0
**Feature IDs:** `FTUE-01`–`FTUE-05`, `PROG-03`, `LUXE-01`, `UI-03`, `UI-04`, `WORLD-02`
**Depends on:** Directive 1

In `lib/core/router/app_router.dart`, `lib/features/onboarding/`, and `lib/features/ftue/`, replace the active seven-screen Aurelian Gate → Origin Script → Sovereign Registry → Brand Footprint → Avatar → Career Path → Ascension Confirmation chain with one resumable Luxe-led Founder Trial:

1. accessibility and “Guide me / Brief me / Let me work” choice;
2. House name and founder intent;
3. one shared Kingston starter garment;
4. one short Artisan edit;
5. one short Architect price/inventory/store decision on the same garment;
6. one customer and Vex reaction;
7. one targeted design or commercial response;
8. Luxe path recommendation and player selection;
9. first Main Quest and first-return setup.

In `lib/features/onboarding/providers/sovereign_genesis_provider.dart`, replace direct `execute_sovereign_genesis` use with a Riverpod repository that sends step intents to the reviewed Early Game Edge/API contract. Persist step completion server-side; local storage may cache presentation state but cannot own tutorial completion. An anonymous Supabase account remains anonymous until it is explicitly upgraded through Auth.

Remove city, market-tier, avatar, Ascension, Feed post, and permanent starting-stat decisions from the critical FTUE. Kingston is fixed. Keep the alternate path available as a limited support path and provide one free reassignment through Rank 10 or seven active days.

Acceptance criteria:

- Meaningful input is available within 45 seconds.
- The Founder Trial reaches both path samples within 4–6 minutes and a complete causal loop within 8–12 minutes in usability testing.
- Force-close/reconnect resumes at the last server-confirmed step.
- Skip removes dialogue without skipping required decisions.
- Luxe never spends currency, accepts a contract, edits a garment, or performs an irreversible action.

Tests to write: router/resume widget tests, owner/stranger server tests, anonymous-account semantic test, skip/accessibility test, and a telemetry assertion for the timing gates. Cite GDD v7 §§5–6, 18.6, 21.3 (`FTUE-01`–`FTUE-05`, `PROG-03`, `LUXE-01`, `UI-03`, `UI-04`, `WORLD-02`) and §22.

## Directive 3: Separate House Funds from lifetime revenue and prove path parity

**Priority:** P0/P1
**Feature IDs:** `ECO-01`–`ECO-03`, `ECO-06`, `PROG-01`, `MON-01`, `MOG-01`, `IDLE-03`
**Depends on:** Directive 1

In a new forward migration, replace the overloaded use of `brand_state.total_revenue` with separate authoritative fields or projections for spendable House Funds, lifetime gross revenue, lifetime costs, and net result. Backfill deterministically, document the interpretation, and create compensating ledger entries rather than editing historical ledger rows.

In the first-store server mutation, replace `idle_revenue_per_hour = SUM(store.revenue_per_hour)` with a documented calculation that cannot erase unrelated valid production/automation income. Return before/after funds, revenue rate, costs, demand, margin, inventory capacity, and rule version in the receipt.

In the Artisan release settlement, add the same type of bounded, server-authoritative economic consequence needed to continue the core loop. Do not give either path a hidden multiplier, premium rescue, or uncapped compounding advantage.

Add a deterministic economy simulator under `tool/` or `scripts/` that compares Artisan and Architect progression at 1 hour, 24 hours, and 7 days across approved starter choices. The simulator must measure time to next meaningful action, active/idle ratio, recovery time, sources/sinks, and accumulated House Funds. Premium purchases must not be an input.

Acceptance criteria:

- Opening the first store cannot reduce a valid unrelated idle-income source.
- Currency balance, lifetime revenue, and ledger totals reconcile.
- Both paths can fund their next core action within the documented pacing band.
- No purchase affects score, Hype ceiling, ranked eligibility, Gala ceiling, territory, or recovery.

Tests: migration backfill/reconciliation, insufficient-funds, retry/concurrency, negative inventory, and parity-simulation thresholds. Cite GDD v7 §§6.6, 10, 17, 21.3 (`ECO-01`–`ECO-03`, `ECO-06`, `MON-01`) and §22.

## Directive 4: Make the Atelier blueprint real and remove count-based Hype exploits

**Priority:** P1
**Feature IDs:** `ART-01`, `ART-02`, `ART-04`, `ART-06`, `ART-07`, `VEX-01`, `NPC-01`
**Depends on:** Directives 1–3

In `lib/features/atelier/screens/atelier_screen.dart`, replace shader-only touch feedback and tag-count composition with a Riverpod-owned `DesignBlueprint` that records actual editable zones, proportions, material assignments, palette assignments, construction choices, version, and revision parent. Wire `design_blueprint_provider.dart` into the active screen, including undo, redo, compare, and targeted revision. The rendered garment must derive from the same blueprint submitted to the server.

In `drop_design_provider.dart`, replace the newly synthesized preview blueprint with the saved active blueprint. Use one score-preview contract clearly labeled as a projection; final Hype and rewards come only from server settlement.

In a new server rule-version migration, replace the count formula in `private.release_design` with validation against server-owned catalog IDs, player unlocks, allowed zone/material/construction compatibility, edit-session ownership, and revision lineage. Use one frozen scoring version based on explicit tradeoffs: silhouette cohesion, color harmony, material/construction quality, originality, audience fit, trend relevance, price-value fit, and responsibility. Array length alone must provide no score advantage. Retire or adapt the legacy mint score so one release has one authoritative Hype calculation.

Respect the Vex opt-in state. Produce a bounded deterministic response bundle: aggregate cohort result, one named customer reaction, optional Vex critique, Luxe cause summary, and one targeted revision opportunity. Generated AI prose remains disabled.

Acceptance criteria:

- Testers given the same brief can create observably different saved garments.
- Changing a visible zone changes the persisted blueprint and rendered result after reload.
- Invalid catalog strings, impossible combinations, foreign sessions, replayed sessions, and fabricated max-length arrays are rejected.
- The player can trace every result factor to an actual saved choice.
- Vex does not appear when critique is declined.

Tests: blueprint serialization, undo/redo/branch lineage, same-brief variance, server catalog validation, malicious payloads, retry/replay, deterministic taste fixtures, and Vex opt-in. Cite GDD v7 §8, §§12.2–12.4, 21.3 (`ART-01`, `ART-02`, `ART-04`, `ART-06`, `ART-07`, `VEX-01`, `NPC-01`) and §22.

## Directive 5: Build one authoritative Architect diagnosis loop

**Priority:** P1
**Feature IDs:** `MOG-01`, `MOG-02`, `ECO-01`, `ECO-06`, `UI-05`
**Depends on:** Directives 1 and 3

In `lib/domain/models/store.dart`, replace the incomplete summary model with fields returned by the reviewed store projection: audience, price tier, inventory capacity/on-hand, expected demand, operating cost, unit margin, stockout/overstock state, and last-settlement time. Regenerate Freezed/JSON files only through the approved build-runner workflow.

In `lib/features/ledger/screens/ledger_screen.dart`, the Empire/store providers, and `hq_architect_view.dart`, replace “open then upgrade,” fabricated chart points, fixed heat explanations, territory preview, endgame state, and revoked power-move calls with one loop:

`inspect visible store/customer/inventory state → identify a cause → choose price, inventory, or supply intervention → receive server settlement → observe changed customer flow/margin/stock → choose recovery or continue`.

Create a versioned `StoreOperationReceipt` returned by an authenticated Edge/API path. Record `store_result_viewed` only after the result screen is actually viewed, not merely because a store exists.

Acceptance criteria:

- The first store is Kingston-only and debt-free.
- A player can identify the primary problem without reading a spreadsheet.
- At least two viable interventions exist for the first failure.
- No displayed graph, heat cause, demand value, or revenue number is fabricated client-side.
- Territory, marketplace, franchising, advanced finance, and PvP remain disabled.

Tests: model decoding, result-view event timing, price/inventory decision fixtures, negative-inventory prevention, failure recovery, idempotency, and visible-cause widget tests. Cite GDD v7 §9, §§10.6–10.7, §18.9, 21.3 (`MOG-01`, `MOG-02`, `ECO-01`, `ECO-06`, `UI-05`) and §22.

## Directive 6: Replace the player Feed with the deterministic NPC Industry Feed

**Priority:** P1
**Feature IDs:** `SOC-01`, `SOC-02` deferred, `NPC-01`, `RIVAL-01`, `ARCHIVE-01`
**Depends on:** Directive 4

In `lib/features/feed/`, replace cross-player polling, likes, comments, follows, collaboration requests, inspiration actions, and public profiles with an owner-scoped Industry Feed containing only confirmed player events and deterministic authored NPC consequence cards. A first release should normally show one aggregate customer summary, two to five representative reactions, no more than one major editorial response, and a direct next action.

Remove Feed social mutation functions from the Early Game deploy allowlist and remove `public_profiles` from the exposed API until Beta privacy/moderation requirements exist. Preserve player-social designs as deferred canonical work, not active runtime behavior.

Acceptance criteria:

- A player cannot enumerate another player’s private profile, designs, wallet, inventory, tutorial state, or raw activity.
- Feed data is owner-scoped and grounded in authoritative release/store receipts.
- No background global-feed poll runs when the feature is not visible.
- The Archive records confirmed events and their rule versions, not client predictions.

Tests: owner/stranger projection tests, reaction-budget fixtures, no-social-action widget test, provider disposal/lifecycle test, and Archive provenance test. Cite GDD v7 §11, §§12.2–12.5, 21.3 (`SOC-01`, `SOC-02`, `NPC-01`, `RIVAL-01`, `ARCHIVE-01`) and §22.

## Directive 7: Repair idle settlement and implement House While Away

**Priority:** P1
**Feature IDs:** `IDLE-01`, `IDLE-02`, `IDLE-03`, `FTUE-05`, `UI-03`
**Depends on:** Directives 1 and 3

In `lib/core/services/idle_engine_service.dart` and `supabase_constants.dart`, replace `process_idle_income` and the obsolete inventory response parsing with one typed `IdleSettlementReceipt` matching the enabled `calculate-idle-income` Edge Function/API response. Send a UUID idempotency key, use server timestamps and caps, and preserve an identical receipt on replay.

Move lifecycle ownership out of Architect HQ into one path-neutral app/session coordinator. Both paths must settle through the same rule version. Build the House While Away screen from the receipt: time away, revenue, costs, production/sales, stockout or bottleneck, relevant event, and one linked next action. Do not trust the device clock or client-calculated offline duration.

Acceptance criteria:

- Both paths settle once after resume/reconnect.
- Retry and 20 concurrent calls produce one ledger credit and one stable receipt.
- Changed device time cannot increase settlement.
- Receipt fields match the server contract exactly.
- The player can understand what changed without opening multiple screens.

Tests: typed decoding, app lifecycle, both paths, retry, 20-way concurrency, changed clock, cap, zero elapsed time, and House While Away widget states. Cite GDD v7 §§10.5–10.6, 18.12, 21.3 (`IDLE-01`–`IDLE-03`, `FTUE-05`, `UI-03`) and §22.

## Directive 8: Implement the minimum Luxe quest and recovery layer

**Priority:** P1
**Feature IDs:** `LUXE-01`–`LUXE-03`, `CRISIS-01`, `NPC-02`, `NAR-01`
**Depends on:** Directives 2, 4, 5, and 7

In `lib/features/ftue/providers/first_objective_provider.dart` and its repository, replace the current first-week checklist—including the Global Feed objective—with server-owned Main Quest and Daily Brief records tied only to implemented Kingston actions. Luxe presents exact requirements/rewards, one free reroll, auto-claim, and no streak punishment. For the prototype, reward House Funds or ordinary materials only; keep premium currency issuance at zero until Beta economy and receipt validation.

Connect exactly two suppliers, one buyer, one trend, and one branching crisis/recovery to the core loop. Each choice must expose a tradeoff and write a confirmed event to the Archive. Do not add staff, weekly commissions, live events, multiple cities, generative dialogue, or social quests.

Acceptance criteria:

- Quests cannot require purchases, ads, wins, votes, log-in streaks, or unavailable features.
- Progress and claiming are idempotent and server-authoritative.
- The first crisis has at least two viable recoveries and no irreversible debt trap.
- Luxe explains causes and options without silently choosing.

Tests: reachability simulation, reroll/auto-claim/replay, reward ledger reconciliation, unavailable-feature guard, supplier/buyer tradeoff fixtures, and crisis recovery. Cite GDD v7 §§5.6, 10.7, 12.8, 21.3 (`LUXE-01`–`LUXE-03`, `CRISIS-01`, `NPC-02`, `NAR-01`) and §22.

## Directive 9: Quarantine ghost code and remove deferred dependencies

**Priority:** P2
**Feature IDs:** scope control under GDD v7 §21.0–21.2
**Depends on:** Directives 2–8 reaching `playable`

Generate an analyzer-backed reachability and coverage report before deleting anything. Replace the active import/dependency graph with only Kingston Early Game code. Remove `in_app_purchase` and other proven-unused packages from `pubspec.yaml` when no enabled source imports them. Move or delete confirmed ghost implementations for Gala, Maison, territory, marketplace, casting, minigames, advanced finance, Ascension, world-map, and monetization only after preserving their intended Feature IDs and requirements in the GDD/backlog.

Do not delete generated files manually, edit migrations, or remove code solely because a text heuristic cannot reach it. Treat `design_blueprint_provider.dart`, Luxe components, and Archive components as candidates to connect, not automatic deletions.

Acceptance criteria:

- Every retained runtime feature maps to an enabled Early Game Feature ID.
- Every deferred feature has no route, endpoint, Realtime publication, scheduled job, or mobile dependency.
- No duplicate state framework, design system, or parallel economy service remains.
- Freezed/JSON generated sources match their models.

Tests: analyzer, dependency audit, route allowlist, Edge allowlist, generated-code check, and coverage review. Cite GDD v7 §§21.0–21.3 and PROJECT_RULES §§2–6.

## Directive 10: Decompose hot UI paths and establish the 60 fps gate

**Priority:** P2
**Feature IDs:** `UI-01`–`UI-05`, `UI-10`, `PERF-01`
**Depends on:** Directives 4–7

In `atelier_screen.dart`, `feed_screen.dart`, `ledger_screen.dart`, `hq_architect_view.dart`, and active repositories/providers, replace large mixed-responsibility widgets and permanent polling loops with scoped Riverpod controllers, small state-complete components, lifecycle-aware streams, and `autoDispose` where state need not survive. Remove the two-second fake revenue ticker. Ensure one pointer pipeline owns Atelier manipulation. Pause shader/sensor animation off-screen and honor reduced motion.

Do not reduce visual quality by removing feedback required by the GDD; reduce unnecessary rebuilds and network work. Keep the five-tab portrait navigation and one design system.

Acceptance criteria:

- No hidden tab continues a 30-second polling loop unless an explicit server requirement and battery test justify it.
- Reduced motion stops nonessential continuous animation.
- Text scaling, semantics, focus order, contrast, and one-handed reach pass the core-task test.
- Galaxy A55 profile evidence meets the project 60 fps/frame-budget gate; weaker Android fallback is documented.

Tests to write: provider disposal, widget rebuild instrumentation, reduced-motion, text scaling, semantics, offline/error/loading states, and performance harness. Smiley performs profile-device execution. Cite GDD v7 §18, 21.3 (`UI-01`–`UI-05`, `UI-10`, `PERF-01`) and §22.

## Directive 11: Make verification claims executable and honest

**Priority:** P0/P2
**Feature IDs:** `SEC-12`, all acceptance gates
**Depends on:** Directive 1

In `supabase/tests/rls_authority_contract.sql`, replace comment-only matrices with executable fixtures for every enabled table/view/RPC/function: owner, stranger, anonymous authenticated user, blocked user, former relationship member, service actor, replay, malformed request, and concurrent economic request as applicable. Add separate executable Storage and Realtime tests before either feature is enabled.

In `scripts/check_authority_matrix.ps1` and `.github/workflows/flutter-ci.yml`, distinguish name inventory (`Static pass`) from executed behavioral tests (`Passed`). Add a check that every enabled Edge Function resolves only approved `api` wrappers. Run integration tests explicitly; `flutter test` alone must not be presented as device integration evidence. Build smoke without runtime Supabase defines is compilation evidence only.

Acceptance criteria:

- No comment or JSON name match is reported as behavioral security proof.
- CI fails when an endpoint is enabled without a wrapper, negative test, Feature ID, or owner.
- Current GDD registry, migration reset, database lint, Edge type-check, RLS, analyzer, unit, integration, build, and device gates have separate labels.
- `DEVELOPMENT_STATE.md` records the latest observed evidence after every task.

Cite GDD v7 §§19.9–19.10, 20, 21.2–21.3 (`SEC-12`) and `VERIFICATION_PROTOCOL.md` in full.

## Directive 12: Align closed-alpha legal copy with implemented scope

**Priority:** P2; release blocking for external testers
**Feature IDs:** `SEC-01`, `P-04`; counsel approval remains manual

After the enabled Early Game surface is frozen, replace `Closed Alpha Placeholder v0.1` copy in `lib/features/legal/legal_documents.dart` with accurate versioned closed-alpha disclosures that describe only collected data and enabled features. Remove claims about IAP, ads, DMs, Maisons, talent pulls, or social Feed until those systems are actually enabled. Add in-app routes for access/export/deletion requests only after their backend operations exist.

The IDE agent must not invent final GDPR, UK GDPR, CCPA/CPRA, COPPA, age-assurance, DMCA, refund, retention, or subprocessor terms. Insert clearly labeled counsel-owned content slots and stable policy-version identifiers; Smiley obtains legal review.

Acceptance criteria:

- Product behavior, telemetry, retention, support routes, and legal copy agree.
- External testing is blocked until age/eligibility, privacy operations, support contact, and counsel approval are recorded.
- No dark pattern, purchase pressure, or premium rescue is added.

Tests: policy-version display, route availability, consent/eligibility state, deletion/export integration only when implemented. Cite GDD v7 §§17, 19.5, 21.0–21.3 and §22.

## Milestone promotion gate

Do not call the build Alpha-ready until all of the following are observed:

- one canonical GDD and passing registry guard;
- a fail-closed Early Game `api` contract with executed negative RLS/identity/replay tests;
- Luxe Founder Trial completing the shared Artisan/Architect causal loop;
- real blueprint editing and explainable authoritative fashion judgment;
- one visible Architect diagnosis/recovery loop;
- deterministic NPC Feed, customer, suppliers, buyer, Vex, Luxe, quest, crisis, and Archive integration;
- correct path-neutral idle settlement and House While Away receipt;
- simulated and playtested dual-path/F2P parity;
- current analyzer/unit/integration/build evidence;
- Galaxy A55-class runtime/accessibility/performance evidence; and
- no enabled late-wave endpoint, job, route, dependency, or public-data surface.

Until then, the correct label is **Pre-Alpha / Kingston Proof-of-Fun Recovery**.
