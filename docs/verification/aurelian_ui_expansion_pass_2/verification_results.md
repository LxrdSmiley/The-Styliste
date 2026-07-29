# Aurelian UI Expansion Pass 2 — Local Verification

Verification date: 2026-07-29
Branch: `codex/aurelian-ui-expansion-pass-2`
Starting SHA: `c4405414195f5bcdff87b31848c3425a17e76e85`

This record uses only the status vocabulary in `VERIFICATION_PROTOCOL.md`.
It covers local source, widget/runtime, disposable-database, and deterministic
render evidence. It is not Android, iOS, Web, physical-device, staging,
deployment, or release-readiness evidence.

## Executed gate

| Evidence | Command / scope | Result |
|---|---|---|
| Dart formatting | `dart format --output=none --set-exit-if-changed lib test integration_test` | `Passed` — 229 files, 0 changes |
| Flutter analysis | `flutter analyze` | `Static pass` — no issues |
| Flutter widget/runtime suite | `flutter test` | `Passed` — 135 tests, 0 failures |
| Deterministic render suite | capture-enabled `test/visual/aurelian_review_capture_test.dart` | `Passed` — 44 tests/renders, 0 failures |
| Supabase migration replay | `supabase db reset --local --no-seed` | `Passed` — 61 migrations |
| Supabase lint | `supabase db lint --local` | `Passed` — exit 0; six inherited warnings retained below |
| Database authority contracts | `supabase test db` | `Passed` — 12 files / 108 assertions |
| Edge entry points | `deno check --config supabase/functions/tsconfig.json` for every `index.ts` | `Static pass` — 17/17 |
| Edge identity/contracts | `deno test --allow-env --allow-net supabase/tests/kingston_edge_identity_test.ts` | `Passed` — 16/16 |
| Economic concurrency | `supabase/tests/kingston_economic_concurrency.ps1` | `Passed` — four mutations × 20 sessions |
| Generated API inventory | local `api` schema query versus `docs/verification/api_schema_inventory.txt` | `Passed` — 19/19 entries |
| Migration manifest | `scripts/check_migration_hash_manifest.ps1` | `Passed` — 61/61 raw-byte SHA-256 entries |
| Migration tamper contract | disposable exact/missing/digest/byte/extra/path/duplicate/order/newline fixtures | `Passed` — 9/9 expected outcomes |
| Feature registry | `scripts/check_gdd_registry.ps1` | `Static pass` — 160 unique Feature IDs and one canonical registry |
| Authority inventory | `scripts/check_authority_inventory.ps1` | `Static pass` |
| Authority matrix | `scripts/check_authority_matrix.ps1` | `Static pass` |
| Early Game API contract | `scripts/check_early_game_api_contract.ps1` | `Static pass` |
| Edge allowlist | `scripts/check_early_game_edge_allowlist.ps1` | `Static pass` — seven reviewed endpoints |
| Deferred TODO guard | `scripts/check_deferred_todos.ps1` | `Static pass` |
| Release metadata | `scripts/check_release_metadata.ps1` | `Static pass` — `v0.1.0-alpha.1` synchronized |
| Dependency guard | `dart pub outdated --no-dev-dependencies` | `Static pass` — audit completed; inherited findings retained below |
| Repository-health guard | `scripts/maintenance/check_repository_health.ps1` | `Passed` |
| Gitleaks history | checksum-verified Gitleaks 8.30.1 `git` scan with complete redaction | `Passed` — 100 commits, 10.28 MB, zero findings |
| Gitleaks working tree | checksum-verified Gitleaks 8.30.1 `dir` scan with complete redaction | `Passed` — 11.37 MB, zero findings |
| Whitespace | `git diff --check` | `Passed` |
| Conflict markers | tracked `git grep` plus tracked/untracked `rg` scan | `Passed` — none found |

## Security-scan retry disposition

The first working-tree scan ran while Flutter was producing ignored
`build/test_cache` binaries and reported 17 private-key test-fixture strings
embedded in those generated dill files. The 100-commit history scan in the
same invocation still reported zero findings. No exception, ignore, rule
suppression, or credential disposition was added.

After the Flutter suite completed, `flutter clean` removed only generated
output. The checksum-verified Gitleaks 8.30.1 history and working-tree scans
were rerun and both reported zero findings. The final result above is therefore
the cleaned source-tree result, consistent with the repository's existing
security-remediation procedure.

## Inherited non-blocking findings

- Supabase lint still reports five unmodified `OUT` variables in the
  quarantined `public.execute_casting_pull` function and one unread `v_brand`
  variable in `public.edge_open_first_store_atomic`. The command exits 0 and
  no migration was changed by this visual pass.
- The dependency audit reports 31 packages locked below an upgradable version,
  14 direct constraints below a resolvable version, and the inherited
  discontinued transitive packages `build_resolvers` and
  `build_runner_core`. No dependency upgrade was authorized or made.
- Git continues to print the inherited Windows LF-to-CRLF working-copy warning.
  `git diff --check` is clean.
- Supabase CLI 2.104.0 reports that 2.110.0 is available. The repository CI
  remains pinned to the reviewed 2.104.0 version.

## Evidence deliberately deferred

| Evidence | Result |
|---|---|
| Android and iOS compilation | `Blocked` — creator direction |
| Flutter Web compilation/runtime | `Blocked` — directive boundary |
| Physical-device accessibility / TalkBack | `Blocked` |
| Physical-device 60 fps and performance | `Blocked` |
| Staging Supabase and deployment rehearsal | `Blocked` |
| Legal/privacy, Jamaican/Caribbean cultural, fashion-industry, and representative-player review | `Blocked` |
| Final visual approval | `Blocked` — Pending Smiley review of expansion-pass renders |

No Android or Web build, remote Supabase action, deployment, pull request,
force-push, tag, or release occurred during this local verification.
