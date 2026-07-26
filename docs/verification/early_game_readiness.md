# Early Game readiness evidence

Generated: 2026-07-22  
Reviewer: Codex static audit  
Audit basis: repository inspection plus the recorded local Flutter static suite and disposable Supabase bootstrap below. No device, purchase sandbox, or penetration test evidence is available.

Only the status labels in `VERIFICATION_PROTOCOL.md` are used. `Static pass` records repository evidence, not observed behavior. A release candidate must not claim Alpha or Beta readiness while any enabled prerequisite below lacks `Passed` evidence.

## Execution update — 2026-07-22

| Check | Command | Status | Evidence |
|---|---|---|---|
| Dependency resolution | `flutter pub get` | Passed | Post-migration resolution completed; 21 Firebase/notification dependencies were removed. |
| Formatting | `dart format lib test integration_test` | Blocked | Prior run Passed with 205 files inspected; current session-classification test and auth fixes await rerun. |
| Static analysis | `flutter analyze` | Blocked | Prior run reported two informational findings; current source awaits the smallest rerun. |
| Widget suite | `flutter test` | Blocked | Prior 49-test run Passed; current regression changes await execution. |
| Android debug build | `flutter build apk --debug` | Blocked | `mergeDebugNativeLibs` could not continue because drive C had insufficient free space. |
| Flutter Web / browser / Pages | No current command | Not applicable | Deferred by project-owner decision and excluded from the mobile milestone. |
| Local Supabase bootstrap | `supabase start` and disposable reset | Blocked | Prior full migration pass succeeded; the changed design-release authorization/replay contract awaits rerun. |
| Database lint | `supabase db lint --local` | Blocked | Prior run Passed with two non-blocking legacy warnings; changed SQL awaits rerun. |
| RLS authority contract | `supabase/tests/rls_authority_contract.sql` | Static pass | Added service-role release success, identical replay, and stranger-denial assertions; current disposable execution is pending. |

No current clean analyzer, successful Android build, device, Supabase Auth
integration, purchase, performance, or penetration result has Passed evidence.
The earlier post-migration widget suite Passed before the latest regression fixes.

## Repository publication tooling — 2026-07-22

| Check | Command or evidence | Status | Evidence |
|---|---|---|---|
| Release metadata | `scripts/check_release_metadata.ps1` | Static pass | `pubspec.yaml`, README, changelog, Settings version, and `docs/releases/v0.1.0-alpha.1.md` are synchronized. |
| Flutter Web / browser / Pages | Project-owner scope decision | Not applicable | Deferred; no current build, workflow, or public-URL evidence is required. |
| GitHub workflow execution | Uncommitted workflow inspection | Blocked | No GitHub Actions run or local YAML parser is available for this working tree. |
| Signed mobile release | Signing and device evidence | Blocked | Normal CI uses a debug APK smoke build; release signing remains a protected manual gate. |

| Feature ID | Wave | Sources | Threat model / data owner | Flag | Test command | Status | Date | Reviewer |
|---|---|---|---|---|---|---|---|---|
| P-01 | EG | `THE_STYLISTE_GDD_v7.md` | Product contract / client presentation | `earlyGame` | `scripts/check_gdd_registry.ps1` | Static pass | 2026-07-21 | Codex |
| P-02 | EG | `PROJECT_RULES.md`, authority migrations | Client-untrusted authority / PostgreSQL | `earlyGame` | `psql ... rls_authority_contract.sql` | Blocked | 2026-07-21 | Codex |
| LOOP-01 | EG | `lib/features/atelier`, `lib/features/ledger` | Replay and score forgery / PostgreSQL | `earlyGame` | `flutter test` | Blocked | 2026-07-21 | Codex |
| FTUE-01 | EG | `lib/features/onboarding`, `founder_trials` | Resume and identity / PostgreSQL | `earlyGame` | `flutter test integration_test` | Blocked | 2026-07-21 | Codex |
| FTUE-02 | EG | `founder_trials`, Atelier blueprint | Starter-state integrity / PostgreSQL | `earlyGame` | `psql ... rls_authority_contract.sql` | Blocked | 2026-07-21 | Codex |
| FTUE-03 | EG | `founder_trials`, `open-first-store` | Tutorial replay/debt / PostgreSQL | `earlyGame` | `flutter test integration_test` | Blocked | 2026-07-21 | Codex |
| FTUE-04 | EG | `lib/core/providers/auth_provider.dart` | Session bootstrap / Supabase Auth | `earlyGame` | `integration_test/supabase_auth_identity_contract_test.dart` | Blocked | 2026-07-22 | Codex |
| FTUE-05 | EG | `first_week_objectives`, idle RPC | Reward replay / PostgreSQL ledger | `earlyGame` | `psql ... rls_authority_contract.sql` | Blocked | 2026-07-21 | Codex |
| PROG-01 | EG | authority migration, `players`, `brand_state` | Progression tampering / PostgreSQL | `earlyGame` | `psql ... rls_authority_contract.sql` | Blocked | 2026-07-21 | Codex |
| PROG-03 | EG | `lib/features/onboarding` | Identity transition / PostgreSQL | `earlyGame` | `flutter test integration_test` | Blocked | 2026-07-21 | Codex |
| PROG-04 | EG | `first_week_objectives` | Objective spoofing / PostgreSQL | `earlyGame` | `flutter test` | Blocked | 2026-07-21 | Codex |
| WORLD-02 | EG | `open-first-store`, `ledger_screen.dart` | Starter city rules / PostgreSQL | `earlyGame` | `flutter test` | Static pass | 2026-07-21 | Codex |
| WORLD-06 | EG | `vertical_slice_first_hour.sql` | Demand input tampering / PostgreSQL | `earlyGame` | `psql ... rls_authority_contract.sql` | Blocked | 2026-07-21 | Codex |
| ART-01 | EG | `design_blueprint.dart` | Blueprint field injection / PostgreSQL | `earlyGame` | `deno check supabase/functions/drop-design/index.ts` | Static pass | 2026-07-21 | Codex |
| ART-02 | EG | `lib/features/atelier` | Local draft only / Riverpod | `earlyGame` | `flutter test integration_test/early_game_performance_harness_test.dart` | Blocked | 2026-07-21 | Codex |
| ART-04 | EG | `design_blueprint_provider.dart` | Undo/reconnect does not mutate server / Riverpod | `earlyGame` | `flutter test` | Blocked | 2026-07-21 | Codex |
| ART-06 | EG | `private.release_design` | Hype/score injection / PostgreSQL | `earlyGame` | `psql ... rls_authority_contract.sql` | Blocked | 2026-07-21 | Codex |
| ART-07 | EG | `private.release_design` | Determinism / PostgreSQL | `earlyGame` | `psql ... rls_authority_contract.sql` | Blocked | 2026-07-21 | Codex |
| MOG-01 | EG | `open-first-store`, `edge_open_first_store_atomic` | Store/debt tampering / PostgreSQL | `earlyGame` | `psql ... rls_authority_contract.sql` | Blocked | 2026-07-21 | Codex |
| MOG-02 | EG | `ledger_screen.dart` | Business-response authority / PostgreSQL | `earlyGame` | `flutter test` | Blocked | 2026-07-21 | Codex |
| ECO-01 | EG | `vertical_slice_first_hour.sql` | Settlement integrity / PostgreSQL | `earlyGame` | `psql ... rls_authority_contract.sql` | Blocked | 2026-07-21 | Codex |
| ECO-02 | EG | `ledger.economy_ledger`, `ledger.reward_issuance` | Wallet and reward replay / ledger | `earlyGame` | `psql ... rls_authority_contract.sql` | Blocked | 2026-07-21 | Codex |
| ECO-03 | EG | `settle_idle_income` | Clock manipulation / PostgreSQL | `earlyGame` | `psql ... rls_authority_contract.sql` | Blocked | 2026-07-21 | Codex |
| ECO-06 | EG | `founder_trials` | Debt-free tutorial recovery / PostgreSQL | `earlyGame` | `flutter test` | Blocked | 2026-07-21 | Codex |
| SOC-01 | EG | `api.feed_projection`, `feed-react` | Feed counter tampering / PostgreSQL | `earlyGame` | `psql ... rls_authority_contract.sql` | Blocked | 2026-07-21 | Codex |
| LUXE-01 | EG | `lib/features/luxe`, result payload | Untrusted recommendation / server result | `earlyGame` | `flutter test` | Blocked | 2026-07-21 | Codex |
| LUXE-02 | EG | `first_week_objectives` | Quest replay / PostgreSQL | `earlyGame` | `psql ... rls_authority_contract.sql` | Blocked | 2026-07-21 | Codex |
| LUXE-03 | EG | `ledger.reward_policy_versions` | Reward-cap bypass / ledger | `earlyGame` | `psql ... rls_authority_contract.sql` | Blocked | 2026-07-21 | Codex |
| NAR-01 | EG | `founder_trials` | Result-history integrity / PostgreSQL | `earlyGame` | `flutter test` | Blocked | 2026-07-21 | Codex |
| VEX-01 | EG | `private.release_design`, `drop-design` | Forged critic payload / PostgreSQL | `earlyGame` | `deno check supabase/functions/drop-design/index.ts` | Static pass | 2026-07-21 | Codex |
| RIVAL-01 | EG | GDD registry only | Future scripted state / not enabled route | `earlyGame` | `scripts/check_gdd_registry.ps1` | Static pass | 2026-07-21 | Codex |
| ARCHIVE-01 | EG | GDD registry only | Confirmed-history boundary / not enabled route | `earlyGame` | `scripts/check_gdd_registry.ps1` | Static pass | 2026-07-21 | Codex |
| NPC-01 | EG | `private.release_design` result | Customer-result integrity / PostgreSQL | `earlyGame` | `psql ... rls_authority_contract.sql` | Blocked | 2026-07-21 | Codex |
| NPC-02 | EG | `ledger_screen.dart` | Supplier input authority / PostgreSQL | `earlyGame` | `flutter test` | Blocked | 2026-07-21 | Codex |
| CRISIS-01 | EG | disabled route surface | Recovery state / not enabled route | disabled | `flutter test` | Not applicable | 2026-07-21 | Codex |
| EVENT-01 | EG | disabled route surface | Time/event authority / not enabled route | disabled | `flutter test` | Not applicable | 2026-07-21 | Codex |
| AUTO-01 | EG | disabled route surface | Automation authority / not enabled route | disabled | `flutter test` | Not applicable | 2026-07-21 | Codex |
| IDLE-01 | EG | `settle_idle_income`, Edge Function | Clock/replay/concurrency / PostgreSQL | `earlyGame` | `psql ... rls_authority_contract.sql` | Blocked | 2026-07-21 | Codex |
| IDLE-02 | EG | `calculate-idle-income` | Receipt integrity / PostgreSQL | `earlyGame` | `flutter test integration_test` | Blocked | 2026-07-21 | Codex |
| IDLE-03 | EG | `settle_idle_income` | Payout inflation / PostgreSQL | `earlyGame` | `psql ... rls_authority_contract.sql` | Blocked | 2026-07-21 | Codex |
| MON-01 | EG | `pubspec.yaml`, reward policy | Pay-to-win / ledger | `earlyGame` | `rg google_mobile_ads` | Static pass | 2026-07-21 | Codex |
| UI-01 | EG | `app_router.dart`, `main_shell.dart` | Disabled-route data fetch / feature registry | `earlyGame` | `flutter test` | Blocked | 2026-07-21 | Codex |
| UI-03 | EG | Early screen modules | Runtime/accessibility/performance / Flutter | `earlyGame` | `flutter test integration_test/early_game_performance_harness_test.dart` | Blocked | 2026-07-21 | Codex |
| UI-10 | EG | widget and integration tests | Accessibility/runtime / Flutter | `earlyGame` | `flutter test` | Blocked | 2026-07-21 | Codex |
| PERF-01 | EG | performance harness | Frame budget / Galaxy A55 | `earlyGame` | `flutter test integration_test/early_game_performance_harness_test.dart` | Blocked | 2026-07-21 | Codex |
| TECH-01 | EG | `app_router.dart`, migrations | Client authority / PostgreSQL | `earlyGame` | `supabase db reset --local` | Blocked | 2026-07-21 | Codex |
| TECH-02 | EG | authority/API migrations | RLS, lock, receipt / PostgreSQL | `earlyGame` | `psql ... rls_authority_contract.sql` | Blocked | 2026-07-21 | Codex |
| SEC-01 | EG | this record, GDD §19 | Full threat model / security owner | `earlyGame` | manual review | Static pass | 2026-07-21 | Codex |
| SEC-02 | EG | `api_schema_boundary` migration | API exposure / PostgreSQL | `earlyGame` | `supabase db reset --local` | Blocked | 2026-07-21 | Codex |
| SEC-03 | EG | `revoke_legacy_client_authority` migration | RLS ownership / PostgreSQL | `earlyGame` | `psql ... rls_authority_contract.sql` | Blocked | 2026-07-21 | Codex |
| SEC-04 | EG | `ledger.*`, settlement RPC | Replay/concurrency / PostgreSQL | `earlyGame` | `psql ... rls_authority_contract.sql` | Blocked | 2026-07-21 | Codex |
| SEC-05 | EG | direct Supabase Auth bootstrap/recovery | Account takeover / Supabase Auth | `earlyGame` | `integration_test/supabase_auth_identity_contract_test.dart` | Blocked | 2026-07-22 | Codex |
| SEC-06 | EG | Edge Functions, config | JWT/schema/secret / Edge runtime | `earlyGame` | `deno check ...` | Static pass | 2026-07-21 | Codex |
| SEC-12 | EG | CI workflow, SQL contract | Regression / CI | `earlyGame` | GitHub Actions | Static pass | 2026-07-21 | Codex |
| DATA-01 | EG | generated readiness record | Evidence integrity / documentation | `earlyGame` | `scripts/check_gdd_registry.ps1` | Static pass | 2026-07-21 | Codex |

## Disabled feature registry coverage

These feature IDs are present in the canonical GDD registry but are not enabled
in the Kingston Early Game route registry. They have no player-facing data or
mutation surface in this build. Their status is `Not applicable` for this
release wave, not a claim that their later-wave implementation is ready.

| Feature ID | Wave | Sources | Threat model / data owner | Flag | Test command | Status | Date | Reviewer |
|---|---|---|---|---|---|---|---|---|
| ART-03 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| ART-05 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| ART-08 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| AUTO-02 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| AUTO-03 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| AUTO-04 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| COMP-01 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| COMP-02 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| COMP-03 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| COMP-04 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| COMP-05 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| COMP-06 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| COMP-07 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| CRISIS-02 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| CRISIS-03 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| DATA-02 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| DATA-03 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| DATA-04 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| ECO-04 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| ECO-05 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| END-01 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| END-02 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| END-03 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| END-04 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| EVENT-02 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| EVENT-03 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| LUXE-04 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| LUXE-05 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| MODE-01 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| MOG-03 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| MOG-04 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| MOG-05 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| MOG-06 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| MOG-07 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| MOG-08 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| MOG-09 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| MON-02 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| MON-03 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| MON-04 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| MON-05 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| MON-06 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| MON-07 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| MON-08 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| MON-09 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| MON-10 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| MON-11 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| MON-12 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| NAR-02 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| NPC-03 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| NPC-04 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| NPC-05 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| NPC-06 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| NPC-07 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| NPC-08 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| NPC-09 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| OPS-01 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| OPS-02 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| OPS-03 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| P-03 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| P-04 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| PROG-02 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| PROG-05 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| SEC-07 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| SEC-08 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| SEC-09 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| SEC-10 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| SEC-11 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| SEC-13 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| SEC-14 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| SOC-02 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| SOC-03 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| SOC-04 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| SOC-05 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| SOC-06 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| SOC-07 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| SOC-08 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| SOC-09 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| STAFF-01 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| STAFF-02 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| TECH-03 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| TECH-04 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| UI-02 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| UI-04 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| UI-05 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| UI-06 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| UI-07 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| UI-08 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| UI-09 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| WORLD-01 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| WORLD-03 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| WORLD-04 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| WORLD-05 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |
| WORLD-07 | Later | GDD v7 registry | Disabled feature / no data surface | disabled | route-guard test | Not applicable | 2026-07-21 | Codex |

## Required live evidence before a readiness claim

- Disposable-project migration, RLS, Storage, Realtime, Edge Function, concurrency, replay, ledger-reconciliation, and API-inventory runs.
- Supabase Auth integration states using real identities, not a handcrafted JWT fixture.
- Android/iOS debug and release starts, signed Android release smoke test, secret scan, purchase sandbox, and restore flow.
- Galaxy A55-class profile evidence for the FTUE, Atelier, first store, release result, and House While Away flows, including reduced motion, text scaling, offline, failure, and portrait-only states.
