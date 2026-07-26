# The Styliste bottleneck log

Last updated: 2026-07-22
Authority: `PROJECT_RULES.md` and `VERIFICATION_PROTOCOL.md`

Record a problem here when it recurs or when its failure mode can silently
invalidate readiness evidence. Each entry must identify permanent prevention;
chat history alone is not a prevention mechanism.

## B-001 — Flutter integration tests missing from dependency graph

- Symptom: `flutter analyze` could not resolve `package:integration_test` and reported undefined integration-test bindings.
- Root cause: integration harnesses were added before the Flutter SDK `integration_test` development dependency.
- Permanent prevention: keep `integration_test` under `dev_dependencies` and run dependency resolution before analysis.
- Automated check: `flutter-checks` CI job.
- Affected files: `pubspec.yaml`, `pubspec.lock`, `integration_test/`.
- Verification command: `flutter pub get && flutter analyze && flutter test`.
- Latest result: `Passed` from the user-run Flutter suite on 2026-07-22.

## B-002 — Dependency and late-wave package drift

- Symptom: dependency resolution carried unused camera, AR/3D, ads, webview, audio, and game-service packages into the Early Game build.
- Root cause: future-wave experiments shared the main application dependency graph.
- Permanent prevention: prove an Early Game use with `rg` before adding or retaining a package; isolate approved future interfaces and commit the lockfile.
- Automated check: CI dependency audit plus `scripts/maintenance/check_repository_health.ps1`.
- Affected files: `pubspec.yaml`, `pubspec.lock`, disabled feature modules.
- Verification command: `flutter pub outdated --no-dev` followed by `flutter analyze` and the release-build smoke job.
- Latest result: `Static pass`; device size/performance impact remains `Blocked`.

## B-003 — Supabase API-schema bootstrap and migration drift

- Symptom: PostgREST repeatedly failed because configured schema `api` did not exist; an attempted `--exclude rest` flag was invalid.
- Root cause: a persisted pre-boundary database was started with new Data API configuration, and the container name was assumed instead of discovered through CLI help.
- Permanent prevention: use a fresh disposable project in CI, plain `supabase start`, `supabase db reset --local --no-seed`, and compare the migration list/API inventory.
- Automated check: `authority-contract` CI job and maintenance health script.
- Affected files: `supabase/config.toml`, `supabase/migrations/`, `.github/workflows/flutter-ci.yml`, `docs/verification/api_schema_inventory.txt`.
- Verification command: `supabase migration list --local` and `supabase db lint --local`.
- Latest result: `Passed` locally on 2026-07-22; production/deployed drift remains `Blocked`.

## B-004 — RLS contract harness produced false failures

- Symptom: the authority matrix reported every reviewed RPC as unmapped, then treated PostgreSQL's rejected-GRANT warning as a successful self-grant.
- Root cause: the matrix prefixed an already schema-qualified `regprocedure`, and the test asserted an exception rather than the resulting privilege state.
- Permanent prevention: compare canonical `regprocedure` names and assert catalog privileges after attempted grants.
- Automated check: rollback-only `supabase/tests/rls_authority_contract.sql` in CI.
- Affected files: `supabase/tests/rls_authority_contract.sql`, `supabase/tests/authority_contract_matrix.json`.
- Verification command: execute the SQL file against the disposable local database with `ON_ERROR_STOP=1`.
- Latest result: `Passed` locally on 2026-07-22.

## B-005 — Database lint warnings hide in quarantined routines

- Symptom: database lint reports an unread `v_brand` variable and unmodified output variables in the quarantined Casting function.
- Root cause: legacy compatibility signatures and lock checks survived after the caller was disabled.
- Permanent prevention: remove unused variables in a forward migration and keep quarantined functions minimal, inert, and ungranted.
- Automated check: `supabase db lint --local` in CI.
- Affected files: `supabase/migrations/20260713122917_vertical_slice_first_hour.sql`, `supabase/migrations/20260719180512_quarantine_functional_casting.sql`.
- Verification command: `supabase db lint --local`.
- Latest result: `Passed` with warnings; warning-free cleanup is pending.

## B-006 — Stale generated/configuration sources

- Symptom: Firebase initialization existed in both generated options and Dart-define configuration, causing uncertain startup authority.
- Root cause: generated configuration and hand-maintained configuration evolved independently.
- Permanent prevention: one reviewed initialization source per service, reference search before deleting generated files, and no generated artifact without an owner and regeneration command.
- Automated check: Flutter analysis, conflict scan, and explicit `rg` reference checks during maintenance.
- Affected files: deleted `lib/firebase_options.dart`, `lib/core/services/firebase_service.dart`, `lib/main.dart`, `firebase.json`.
- Verification command: `rg -n "firebase_options|Firebase.initializeApp" lib firebase.json` plus `flutter analyze`.
- Latest result: `Static pass`; Firebase client/configuration/function source was
  removed on 2026-07-22. Dependency resolution and Flutter verification remain
  Blocked until Smiley runs the recorded commands.

## B-007 — Secret-history verification unavailable locally

- Symptom: the repository can inspect current configuration, but cannot locally prove that prior commits contain no leaked credential.
- Root cause: `gitleaks` is not installed in the current workstation environment.
- Permanent prevention: full-history checkout and gitleaks scan in CI; local maintenance fails closed when the executable is absent.
- Automated check: `gitleaks/gitleaks-action` with `fetch-depth: 0`.
- Affected files: `.github/workflows/flutter-ci.yml`, `.env.example`, `.gitignore`, Git history.
- Verification command: `gitleaks git . --redact=100 --no-banner`.
- Latest result: `Blocked` locally; CI execution pending.

## B-008 — Performance evidence can be mistaken for performance readiness

- Symptom: a performance harness exists, but no Galaxy A55-class profile/device result exists.
- Root cause: source checks and widget tests cannot measure frame/raster timing, thermals, memory, or lower-spec fallbacks.
- Permanent prevention: require profile-mode device evidence before changing `PERF-01` to `Passed`; record device, OS, build mode, frame data, reduced motion, text scaling, and offline behavior.
- Automated check: release-build smoke CI plus the integration performance harness; manual profile evidence remains required.
- Affected files: `integration_test/early_game_performance_harness_test.dart`, performance-sensitive Early Game screens and shaders.
- Verification command: the approved profile/device procedure in `VERIFICATION_PROTOCOL.md` §§5, 9–11.
- Latest result: `Blocked`.

## Storage-growth watchlist

No recurring storage-growth incident has been observed yet, so no destructive
cleanup script is authorized. Before enabling player uploads, add per-owner
bucket policies, type/size limits, retention rules, orphan detection, and a
read-only repository-size/storage report. Verification must cover owner,
stranger, blocked, and removed-member access. Status: `Blocked` pending a live
Storage inventory and usage baseline.

## B-011 — Supabase publishable-key parameter drift

- Symptom: direct Supabase Auth and its live integration test used `publishableKey:` in `Supabase.initialize`, which does not exist in the resolved `supabase_flutter` 2.12.4 API.
- Root cause: the new key format was confused with the SDK's retained `anonKey` named parameter.
- Permanent prevention: keep `SUPABASE_PUBLISHABLE_KEY` as the preferred value and pass the selected public key through the SDK's retained `anonKey:` parameter.
- Automated check: `flutter analyze` plus the staging auth integration test.
- Affected files: `lib/main.dart`, `integration_test/supabase_auth_identity_contract_test.dart`.
- Verification command: `flutter analyze`, followed by the live staging identity test when authorized.
- Latest result: `Static pass`; current Flutter compilation evidence is pending Smiley's rerun.

## B-009 — GitHub Pages mistaken for browser compatibility

- Symptom: a Pages deployment is treated as a way to run the Android/iOS game
  in a browser without implementing Flutter Web.
- Root cause: deployment hosting, web compilation, platform compatibility, and
  backend security were treated as one step.
- Permanent prevention: Web compilation and Pages deployment remain outside the
  mobile milestone unless a later authorization restores their separate gates.
- Automated check: none in the active mobile readiness workflow.
- Affected files: `README.md`, `docs/WEB_PREVIEW.md`,
  `.github/workflows/pages.yml`, `VERIFICATION_PROTOCOL.md`.
- Verification command: none for the current milestone.
- Latest result: `Not applicable`; Web was deferred by the project owner.

## B-010 — Normal CI required unavailable release-signing secrets

- Symptom: every push/PR readiness run required `android/key.properties` even
  though the file is correctly ignored and no CI step materialized it.
- Root cause: unsigned build smoke evidence and signed release evidence were
  combined in one always-on job.
- Permanent prevention: normal CI performs a debug APK smoke build and proves
  signing material is absent/no debug fallback exists; a signed release remains
  a separate authorized workflow with protected secrets and manual evidence.
- Automated check: `supply-chain-and-build-smoke` in
  `.github/workflows/flutter-ci.yml`.
- Affected files: `.github/workflows/flutter-ci.yml`, Android signing
  configuration, `MANUAL_TASKS.md`.
- Verification command: GitHub Actions execution plus the separate signed
  release procedure when credentials are configured.
- Latest result: `Static pass`; signed release execution remains `Blocked`.

## B-012 — Build volume exhausted drive C

- Symptom: Android `mergeDebugNativeLibs` and a now-deferred Flutter Web attempt failed with Windows error 112; the Web cleanup also found a generated CanvasKit file in use.
- Root cause: drive C had approximately 0.25 GB free while the partial repository build directory had already grown to approximately 1.58 GB.
- Permanent prevention: keep at least 5 GB free before Android builds and keep Web builds outside the current milestone.
- Automated check: `scripts/maintenance/check_build_space.ps1` performs a read-only Android build-space preflight.
- Affected files: generated `build/`, generated `.dart_tool/`, Gradle/Flutter caches; no source or migration file caused this failure.
- Verification command: inspect drive free space, run `flutter clean`, then retry the Android debug build only.
- Latest result: `Blocked`; drive C has 1.27 GB free, below the 5 GB build threshold. `build/web` is absent.

## B-013 — GDD v7 duplicated body recurrence

- Symptom: top-level GDD sections restarted after the canonical Version 7
  changelog, creating a second stale whole-document body and conflicting rules.
- Root cause: confirmed whole-document append/merge-boundary failure introduced
  the shorter stale v7 content after the completed canonical body. This
  directive did not investigate or attribute a specific tool or operator action.
- Permanent prevention: keep exactly one canonical GDD body and require the
  whole-file registry guard before merge. The guard rejects duplicate canonical
  headings, duplicate numbered sections, a sequence restart after closing
  material, duplicate Feature IDs, missing required FTUE/security IDs, malformed
  UTF-8, and known mojibake markers.
- Required review rule: run the full-file numbered-heading inventory and never
  silently blend historical or contradictory GDD bodies into the canonical body.
- Automated check: `scripts/check_gdd_registry.ps1`.
- Affected file: `THE_STYLISTE_GDD_v7.md` (pre-existing committed content).
- Verification command:
  `powershell -ExecutionPolicy Bypass -File scripts/check_gdd_registry.ps1`
  plus manual heading-inventory review.
- Latest result: `Static pass`; the file has exactly one top-level numbered
  sequence, sections 1–24, and 148 unique Feature IDs.

## B-014 — API-only Supabase boundary drifted from active callers

- Symptom: `supabase/config.toml` exposes only `api`, and the last boundary
  migration revokes client execution on `public` functions, while active Flutter
  code and enabled Edge Functions still call default-schema `public` RPCs and
  tables.
- Root cause: the schema-exposure migration, Edge Function wrappers, client
  repositories, and function-deploy configuration were changed independently.
- Permanent prevention: maintain one machine-readable Early Game API allowlist;
  require every enabled Edge Function to call a reviewed `api` wrapper; reject
  direct public/private/ledger client calls; test the deployed schema setting.
- Automated check: extend `scripts/check_authority_matrix.ps1` to compare active
  Dart access, enabled Edge Functions, internal RPC targets, and `api` wrappers.
- Affected files: `supabase/config.toml`,
  `supabase/migrations/20260721120638_api_schema_boundary.sql`, enabled Edge
  Functions, and active Flutter repositories/providers.
- Verification command: static allowlist guard, disposable database reset/lint,
  executable identity/RLS contract, and isolated staging integration tests.
- Latest result: current static guards pass; local RLS/Kingston SQL contracts,
  database lint, and four economic concurrency races pass. Hosted deployment
  remains `Blocked` and was not inspected.

## B-015 — Hidden routes left later-wave server endpoints enabled

- Symptom: player Feed mutations, Maison donation, mini-game rewards, IAP
  validation, and live-event jobs remain registered even when the mobile route
  registry sends their screens to `/unavailable`.
- Root cause: client navigation was treated as authorization and deployment
  containment.
- Permanent prevention: generate the current function deploy list from an
  approved Feature ID allowlist; fail CI when a deferred feature has an enabled
  endpoint, Realtime publication, scheduled job, or mobile dependency.
- Automated check: compare `feature_registry.dart`, GDD implementation status,
  `supabase/config.toml`, Realtime publication inventory, workflow deploy lists,
  and `pubspec.yaml`.
- Affected files: `lib/core/router/feature_registry.dart`,
  `supabase/config.toml`, `.github/workflows/`, and deferred client dependencies.
- Verification command: allowlist guard plus direct HTTP denial/not-deployed
  checks against the isolated staging project.
- Latest result: the exact six-route Kingston allowlist is `Static pass`; all
  listed later-wave endpoints are disabled locally. Hosted deployment state
  remains `Blocked` and was not inspected.

## B-016 — Authority inventory was mistaken for behavioral security proof

- Symptom: JSON/name comparisons pass while former-member, blocked-user,
  Storage, Realtime, Edge identity, and concurrency cases exist only as comments
  or are absent from executable fixtures.
- Root cause: source inventory and live negative authorization tests were given
  the same readiness language.
- Permanent prevention: label inventory as `Static pass`; require executable
  role/identity/replay/concurrency cases before `Passed`; fail on comment-only
  mandatory cases.
- Automated check: contract-case manifest mapped to executed SQL/HTTP/Realtime/
  Storage test IDs and captured results.
- Affected files: `supabase/tests/authority_contract_matrix.json`,
  `supabase/tests/rls_authority_contract.sql`, CI workflows, and verification
  documentation.
- Verification command: disposable and isolated-staging security suites under
  `VERIFICATION_PROTOCOL.md`.
- Latest result: static inventory, current RLS/Kingston SQL contracts, 59 TAP
  assertions, 13 Edge identity/validation tests, and four 20-way economic races
  pass. Historical tests with retired authority expectations still fail; hosted,
  former-member, blocked-user, Storage, and Realtime behavior remain blocked or
  not applicable to the disabled local services.

## B-017 — Edge config and function-folder inventory drift

- Symptom: function source folders, `[functions.<name>]` sections, and the
  reviewed deployment allowlist can describe different callable surfaces.
- Root cause: adding source and enabling deployment were independent manual
  operations with no shared catalog.
- Permanent prevention: catalog every configured and unconfigured source;
  compare folders, config sections, enabled state, wrappers, Feature IDs,
  tests, owner, and disable switch before review.
- Automated check: `scripts/check_authority_matrix.ps1` and
  `scripts/check_early_game_api_contract.ps1`.
- Affected files: `supabase/config.toml`, `supabase/functions/`,
  `supabase/tests/authority_contract_matrix.json`.
- Verification command: run both static guards, then execute disabled-endpoint
  HTTP checks in an isolated environment.
- Latest result: `Static pass`; hosted/behavioral disable evidence remains
  `Blocked`.

## B-018 — Enabled Edge code called default-schema privileged RPCs

- Symptom: authenticated Edge Functions verified a JWT but then called
  `admin.rpc(...)`, bypassing the reviewed `api` wrapper inventory.
- Root cause: RPC schema selection was treated as an implementation detail
  rather than part of the security boundary.
- Permanent prevention: every enabled mutation uses the shared Edge boundary
  and `service.schema('api').rpc(...)`; default-schema privileged RPC calls fail
  the static contract guard.
- Automated check: `scripts/check_early_game_api_contract.ps1` plus Deno
  type-check/identity tests.
- Affected files: enabled `supabase/functions/*/index.ts` and `_shared/`.
- Verification command: static guard, Deno suite, disposable SQL wrapper tests.
- Latest result: `Static pass`, Edge 13/13, local SQL contracts, lint, and
  economic concurrency all pass. Hosted execution remains blocked.

## B-019 — Mobile mutation payloads carried authoritative actor IDs

- Symptom: Flutter RPC bodies supplied `p_user_id`, `player_id`, or `owner_id`,
  allowing identity confusion when a server path failed to re-derive ownership.
- Root cause: resource identifiers and actor authority were represented with the
  same untyped request maps.
- Permanent prevention: Flutter submits only intent/resource data; Edge derives
  the actor with `auth.getUser`; PostgreSQL maps the verified subject through
  `private.auth_player_identities`.
- Automated check: active Flutter mutation scan in
  `scripts/check_early_game_api_contract.ps1` and shared Edge validator tests.
- Affected files: Early Game repositories/providers/services and shared Edge
  route validation.
- Verification command: static guard plus actor/body-mismatch Edge tests.
- Latest result: `Static pass` and Edge unit `Passed`; Flutter analyzer/tests
  remain operator-pending.

## B-020 — Comment-only security cases looked executable

- Symptom: an authority matrix named owner, stranger, anonymous, replay, and
  concurrency scenarios without code that actually opened sessions or asserted
  state.
- Root cause: inventory rows and behavioral evidence shared the same status
  language.
- Permanent prevention: every catalog row names concrete SQL/Deno/PowerShell
  tests; reports label inventory only as `Static pass` and require observed exit
  codes for behavioral `Passed`.
- Automated check: catalog field enforcement in
  `scripts/check_early_game_api_contract.ps1`.
- Affected files: `supabase/tests/authority_contract_matrix.json`, focused SQL,
  Edge identity suite, concurrency harness.
- Verification command: execute each named test against disposable local and
  isolated staging environments.
- Latest result: Edge 13/13, transactional RLS/Kingston SQL, and all four
  20-session economic races pass locally; historical retired-contract failures
  remain explicit.

## B-021 — Enabled endpoints lacked Feature IDs, owners, or negative tests

- Symptom: a function could be enabled with no binding Feature ID, owner,
  anonymous/stranger case, replay case, concurrency case, or disable path.
- Root cause: deployment configuration had no enforceable governance schema.
- Permanent prevention: reject enabled entries missing any mandatory catalog
  field and reject enabled names absent from the exact six-function allowlist.
- Automated check: `scripts/check_early_game_api_contract.ps1`.
- Affected files: `supabase/config.toml` and
  `supabase/tests/authority_contract_matrix.json`.
- Verification command: static guard followed by named behavioral suites.
- Latest result: `Static pass`; database and concurrency evidence executed and
  passed for current Kingston mutations. Promotion remains withheld because UI,
  Flutter, historical-contract, hosted, and physical-device gates are open.

## B-022 — Local Docker API blocked disposable database evidence

- Symptom: `supabase db reset --local --no-seed` emitted no output and timed out
  after approximately 184 seconds; subsequent `supabase status`, `docker ps`,
  and `docker version` calls also timed out.
- Root cause: unresponsive local Docker API. No migration-chain diagnosis is
  inferred because the CLI never returned migration output.
- Permanent prevention: require `docker version` to return promptly before a
  local Supabase run; restart Docker Desktop only as a separate operator action
  after confirming no other workloads depend on it; then rerun reset, migration
  alignment, lint, focused SQL, and concurrency from the unchanged tree.
- Automated check: bounded Docker health preflight before the disposable
  backend job.
- Affected area: local verification environment only; no production service or
  repository source was altered to work around it.
- Verification command: `docker version`, then the Directive 1 local backend
  command sequence.
- Latest result: superseded. Docker recovered; the migration chain, lint, SQL,
  and concurrency checks executed. See B-023 for the remaining reset health
  timing issue.

## B-023 — Supabase reset can report failure after migrations complete

- Symptom: `supabase db reset --local --no-seed` applied every migration and
  restarted containers, then returned exit `1` because the disabled local
  Storage service missed the health deadline.
- Root cause: Supabase CLI v2.104.0 still starts/checks the Storage container
  during reset even when `[storage].enabled=false`; service startup timing is
  independent of SQL replay success.
- Permanent prevention: preserve the reset exit code, inspect the migration
  application log, then independently require `supabase status`, the exact
  migration list, database lint, and executable contracts. Never relabel the
  reset command itself as passed when its exit code is nonzero.
- Automated check: capture migration output and post-reset service/migration
  state as separate CI artifacts.
- Affected area: local disposable verification environment only.
- Verification command: `supabase db reset --local --no-seed`, followed by
  `supabase status`, `supabase migration list --local`, and database lint.
- Latest result: all migrations through `20260722190000` applied; reset command
  exit `1` on Storage health timing; subsequent status/list/lint exit `0`.

## B-024 — Historical SQL contracts can demand a retired authority model

- Symptom: protected platform-identity, progression/feed repair, and power-move
  ownership tests fail because they require authenticated raw `public` relation
  or function access that the Kingston `api`-only boundary revokes.
- Root cause: tests were written for earlier deployment contracts and were not
  versioned or retired when the Data API and runtime scope changed.
- Permanent prevention: every security test declares its milestone and expected
  schema boundary; superseded contracts are reviewed and migrated under
  explicit authorization, never made green by restoring obsolete grants.
- Automated check: the authority matrix maps each test to Feature ID, current
  milestone, exposed schema, and expected enabled/deferred state.
- Affected files: `supabase/tests/platform_auth_mappings_identity_containment.test.sql`,
  `supabase/tests/platform_auth_mappings_anonymous_access.test.sql`,
  `supabase/tests/progression_feed_migration_repair.test.sql`, and
  `supabase/tests/execute_power_move_ownership_test.sql`.
- Verification command: run each file individually against a fresh disposable
  database and preserve its exact TAP result.
- Latest result: current Kingston contracts pass; the four historical suites
  fail for the documented retired-access expectations. Protected identity files
  remain unchanged.

## B-025 — Windows checkout line endings invalidated source guards

- Symptom: an authority regex passed against an LF dirty file but failed on a
  normal CRLF checkout; Deno formatting likewise rejected all committed
  TypeScript solely because the worktree used CRLF.
- Root cause: repository checks assumed working-tree line endings while no
  `.gitattributes` rule protected Deno sources.
- Permanent prevention: make PowerShell line regexes CRLF/LF-safe and enforce
  `*.ts text eol=lf` in `.gitattributes`; validate from a fresh detached
  committed checkout, not only the dirty source tree.
- Automated check: the required static guard and `deno fmt --check` run in CI
  after a fresh checkout.
- Affected files: `.gitattributes`,
  `scripts/check_early_game_api_contract.ps1`, all TypeScript Edge/test files.
- Latest result: fresh Windows checkout reports `w/lf`; static schema parsing
  and Deno formatting/type-check pass.

## B-026 — Dirty-tree validation concealed an incomplete commit boundary

- Symptom: all static guards passed in the dirty working tree, but a detached
  checkout of the local backend commits failed the Early Game guard because the
  matching Flutter caller corrections had not been committed.
- Root cause: backend and caller changes were tested together, then split at a
  commit boundary before the Smiley-only Flutter gate could authorize the Dart
  scope.
- Permanent prevention: validate every proposed commit sequence from a clean
  detached worktree. Do not publish a partial branch whose required guards rely
  on uncommitted files.
- Automated check: fresh-checkout static/Edge/database jobs run against the
  exact commit SHA proposed for publication.
- Affected files: the six-route backend contract, Early Game Flutter callers,
  and release-metadata dependencies.
- Latest result: local backend commits are preserved but not pushed; the exact
  committed database and Edge scopes pass, while the branch-level caller and
  release-metadata guards remain blocked pending Smiley validation and scoped
  follow-up commits.
