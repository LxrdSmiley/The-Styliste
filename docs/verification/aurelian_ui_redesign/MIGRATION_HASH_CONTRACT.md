# Migration hash contract

Status: **Local integrity verification implemented; publication remains blocked
by independent Gitleaks remediation.**

This record distinguishes the former broad baseline capture from the canonical
migration-integrity contract. It does not change migration history, migration
contents, database authority, or player-facing source.

## Investigation result

Before this repair, `baseline_hashes.csv` was an untracked, broad source-capture
file. It contained hashes for many unrelated source and evidence files and only
three migration rows. No repository script, CI job, or documentation validated
it as a migration manifest. Therefore it could not safely be repurposed as the
canonical migration contract.

## Migration hash contract

- Manifest path:
  `docs/verification/aurelian_ui_redesign/migration_hash_manifest.csv`
- Generator path: `scripts/generate_migration_hash_manifest.ps1`
- Guard script path: `scripts/check_migration_hash_manifest.ps1`
- CI invocation: `.github/workflows/flutter-ci.yml`, `authority-contract` job,
  **GDD, authority, and deferred-feature registry** step.
- Repository-health invocation:
  `scripts/maintenance/check_repository_health.ps1`.
- Documented coverage rule: exactly one entry for every direct `*.sql` file in
  `supabase/migrations/`; no migration file may be omitted or represented more
  than once.
- Actual migration count: 61.
- Former candidate migration-entry count: 3.
- Former missing entry count: 58.
- Former extra migration-entry count: 0.
- Former duplicate migration-entry count: 0.
- Canonical manifest entry count: 61.
- Ordering requirement: ascending migration filename. The checked-in files use
  either the accepted legacy three-digit sequence or a 14-digit UTC timestamp,
  followed by a lowercase underscore-separated name.
- Hash algorithm: SHA-256 over the exact file bytes.
- Path normalization rule: repository-relative, forward-slash paths beginning
  `supabase/migrations/`; absolute, backslash, parent-relative, and unrelated
  paths are rejected.
- Newline normalization rule: none. A line-ending-only change alters the raw
  byte SHA-256 and is rejected until it is intentionally reviewed and the
  manifest is regenerated.

## Verified file inventory

`migration_hash_inventory.csv` records each of the 61 migrations with its
filename, prefix, byte size, raw-byte SHA-256, tracked status, duplicate-prefix
status, duplicate-content status, and working-tree modification state at this
verification point.

At capture, 58 migrations were clean and Git-tracked. The three untracked
files are the approved Wave 2A Founder Trial, legacy Power Move quarantine, and
Capsule Foundation migrations. All three executed in the accepted 61-migration
local reset; no pre-existing migration had a working-tree modification.

## Safety result

- No migration filename, ordering, or content changed during this repair.
- No migration prefix or content hash was duplicated.
- No migration contained a merge-conflict marker or the bounded credential
  patterns checked during the inventory pass.
- The local `supabase_migrations.schema_migrations` order exactly matched all
  61 filename prefixes after the accepted local reset.

Authority: `THE_STYLISTE_GDD_v8.md` sections 19, 21, and 22; `PROJECT_RULES.md`;
and `VERIFICATION_PROTOCOL.md`.

## Tamper-detection evidence

The validator was executed against a disposable copy of the manifest and
migration directory. The exact-file scenario exited `0`; every tampered
scenario exited `1` as required.

| Scenario | Exit code | Result |
|---|---:|---|
| All 61 exact files present | 0 | Passed |
| Manifest entry removed | 1 | Detected |
| Manifest digest altered | 1 | Detected |
| Migration byte altered | 1 | Detected |
| Unexpected migration added | 1 | Detected |
| Manifest path for nonexistent migration | 1 | Detected |
| Duplicate manifest entry | 1 | Detected |
| Path-order-only variation | 1 | Detected; canonical order is required |
| Line-ending-only variation | 1 | Detected; raw-byte hashing has no newline normalization |

The test command invoked
`scripts/check_migration_hash_manifest.ps1 -MigrationDirectory <temporary copy>
-ManifestPath <temporary copy>` for each scenario. No repository migration or
manifest was mutated by a tamper test.

## Post-repair local verification

| Check | Exit code | Result |
|---|---:|---|
| Deterministic generator versus checked manifest | 0 | Passed; 61 entries match exactly. |
| Pre-repair versus current migration hashes | 0 | Passed; no migration content changed. |
| Migration hash validator | 0 | Passed; 61/61 exact files. |
| Local migration inventory | 0 | Passed; all 61 filename prefixes match local history. |
| `supabase db reset --local --no-seed` | 0 | Passed; all 61 migrations replayed. |
| `supabase db lint --local` | 0 | Passed with six inherited warnings. |
| `supabase test db` | 0 | Passed; 12 files / 108 assertions. |
| Kingston economic concurrency harness | 0 | Passed; four 20-session scenarios. |
| API inventory comparison | 0 | Passed; 19 exact entries. |
| Authority inventory, authority matrix, and static API guards | 0 | Static pass. |
| Repository-health guard | 1 | Reached the independent Gitleaks-availability blocker. |
| `git diff --check` | 0 | Passed. |
| Conflict-marker scan | 1 from `git grep` | Passed; exit 1 means no markers found. |

The six non-blocking lint warnings are unchanged: five unmodified `OUT`
variables in `public.execute_casting_pull` (`success`, `pulls`, `luxe_spent`,
`prestige_earned`, and `message`) and one unread `v_brand` variable in
`public.edge_open_first_store_atomic`.

## Files changed by this repair

- `.github/workflows/flutter-ci.yml`
- `scripts/generate_migration_hash_manifest.ps1`
- `scripts/check_migration_hash_manifest.ps1`
- `scripts/check_deferred_todos.ps1`
- `scripts/maintenance/check_repository_health.ps1`
- `docs/verification/aurelian_ui_redesign/migration_hash_manifest.csv`
- `docs/verification/aurelian_ui_redesign/migration_hash_inventory.csv`
- `docs/verification/aurelian_ui_redesign/MIGRATION_HASH_CONTRACT.md`
- `docs/verification/aurelian_ui_redesign/SECURITY_KEY_REMEDIATION.md`
- `docs/verification/aurelian_ui_redesign/UI_REDESIGN_AUDIT.md`
- `DEVELOPMENT_STATE.md`
- `BOTTLENECK_LOG.md`

No migration content, player-facing UI source, RLS policy, database function,
or Edge contract changed. Nothing was staged, committed, pushed, deployed, or
sent to a remote Supabase project.
