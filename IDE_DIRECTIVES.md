# IDE Directives — Current Execution State

Last reconciled: June 25, 2026
Active repository: `C:\STN\The-Styliste-1`

This file reflects the authoritative current worktree, not the older exported
snapshot used by the follow-up audit.

## Current Verdict

The security implementation is materially stronger, but public testing remains
blocked by operator configuration, legal review, platform purchase testing, and
manual runtime checks.

## Resolved Directives

### 1. Architect Cash Flow Ribbon

Resolved in `lib/features/hq/widgets/hq_architect_view.dart`.

- Visible only in the Architect HQ.
- Reads `Brand.idleRevenuePerHour` and `Brand.totalRevenue` from
  `hqBrandStreamProvider`.
- Displays hourly income, per-second income, and capital.
- `idleIncomeTickerProvider` drives visible refresh animation.
- No local economy mutation exists.

### 2. Server-Verified Mini-Game Rewards

Resolved through:

- `supabase/functions/claim-mini-game-reward/index.ts`
- `lib/core/services/mini_game_service.dart`
- `supabase/migrations/20260618063958_security_hardening_pass_1_execution.sql`

The server creates player-bound attempts with challenge data, expiry, cooldown,
and claim state. Claims require an attempt ID and game-specific proof. Reward
selection and mutation remain in a single database transaction. Replays and
cross-player claims are rejected.

### 3. Server-Authoritative Atelier Hype

Resolved through:

- `supabase/functions/mint-design/index.ts`
- `lib/features/atelier/providers/mint_design_provider.dart`
- `supabase/migrations/20260618063958_security_hardening_pass_1_execution.sql`

The client no longer sends authoritative material-quality or
aesthetic-alignment scores. The database owns the Atelier session, validates
allowlisted style tags, derives scoring inputs, and mints idempotently.

### 4. Canonical and Atomic IAP Granting

Resolved through:

- `lib/features/store/providers/iap_provider.dart`
- `lib/features/store/screens/shop_screen.dart`
- `lib/features/store/screens/aurelian_storefront_screen.dart`
- `supabase/functions/validate-iap/index.ts`
- `public.edge_redeem_iap_atomic(...)`

Canonical product IDs:

- `initiates_cache` → 100 Luxe
- `artisans_reserve` → 550 Luxe
- `architects_vault` → 1200 Luxe
- `sovereign_syndicate` → 6500 Luxe

The verified store transaction—not the request body—selects the grant. Account
binding, transaction uniqueness, receipt replay protection, and token increment
occur server-side.

### 5. Repository Security Documentation

Resolved by this file, `MANUAL_TASKS.md`, and
`Security_Audit_Pass1_Summary.md`.

### 6. Dead-End Route Presentation

Resolved with `lib/core/widgets/locked_feature_preview.dart`.

World Map, Profile/Brand Story Archive, Events, and AR Try-On now present
polished, honest later-build previews. They do not imply playable behavior and
do not simulate progress or rewards.

### 7. Report and Feed Abuse Controls

Resolved through:

- `supabase/migrations/20260622114500_harden_player_reports.sql`
- `supabase/migrations/20260622120000_restrict_player_report_grants.sql`
- `supabase/migrations/20260622121500_index_player_report_targets.sql`
- `lib/features/reporting/widgets/report_modal.dart`
- existing `feed-comment` and `feed-react` Edge Function rate limits.

Report categories and description length are database constrained. Self-reports,
mismatched targets, and forged reporter IDs are rejected. The same reporter
cannot report the same target again for 15 minutes, and each reporter is capped
at 10 reports per 24 hours. `authenticated` has only `SELECT` and `INSERT` on
the report table; `anon` has no table privileges.
Both report target foreign keys have covering indexes.

Feed comments are capped at 10 per five minutes and reactions at 30 per minute
through the service-only atomic rate-limit RPC.

### 8. Vex Scope Gate

Still intentionally paused. Do not implement First Vex Reveal until the manual
security, platform, legal, and runtime gates in `MANUAL_TASKS.md` are closed.

### 9. GDD §12.2.2 Standalone Mini-Game Retirement

Resolved through:

- `supabase/migrations/20260622123000_retire_standalone_staff_supplier_games.sql`
- `supabase/functions/claim-mini-game-reward/index.ts`
- removal of the unreachable Staff Rally and Supplier Raid screens/provider
  code.

`staff_rally` and `supplier_raid` can no longer be started through the Edge
Function or inserted into the attempt ledger. The obsolete logistics helper
RPCs were dropped. Equity now points toward the successor
`Supply Chain Scramble` Maison Feed Event instead of advertising Supplier Raid.

The complete Solidarity Strike and Supply Chain Scramble community-event
systems remain future GDD implementation work.

## Verification Completed by Codex

- Changed Edge Functions pass `deno check`.
- `trend-decay`, `send-fcm-notification`, and `claim-mini-game-reward` were
  redeployed to Supabase project `xzzklkmkjmwzpiedkwho` on June 23, 2026.
- Linked database lint has no error-level findings.
- Local `supabase db reset --local` passed on June 25, 2026 with Docker
  running; the full migration chain and seed file applied.
- Local `supabase db lint --local` passed on June 25, 2026 with warning-level
  findings only in `public.execute_casting_pull` and
  `public.rotate_gala_event`.
- The rollback-only security regression harness passes for mini-game replay,
  Atelier mint idempotency, store and Maison idempotency, IAP replay, Kintsugi
  fixed cost, report category validation, and report throttling.
- Unauthenticated JWT-backed endpoints return `401`.
- Unconfigured privileged secret-backed endpoints fail closed with `503`.
- `dart format lib test`, `flutter analyze`, and `flutter test` pass locally as
  of June 25, 2026.
- `git diff --check` reports no whitespace errors.
- The security release gate rejects unresolved Git merge conflict markers.

## Remaining Public-Test Blockers

- Configure and connect `CRON_INVOKE_SECRET`, `WEBHOOK_SECRET`,
  `ECLIPSE_EVENT_TICK_SECRET`, `FIREBASE_PROJECT_ID`, and
  `FIREBASE_SERVICE_ACCOUNT`.
- Enable and test production backups/PITR.
- Enable leaked-password protection where password auth is available.
- Complete Firebase App Check, API-key restrictions, signing fingerprints,
  monitoring, storage, and incident-response setup.
- Replace bundled closed-alpha legal placeholders with counsel-approved,
  published documents.
- Complete Apple/Google sandbox substitution, replay, restore, refund, and
  account-switch purchase tests.
- Complete manual runtime checks.
- Build the server-wide Solidarity Strike and Maison-ranked Supply Chain
  Scramble community events that replace the retired standalone games.

## Manual Terminal Commands for Smiley

```bash
flutter clean
flutter pub get
dart format lib
flutter analyze
flutter test
```

With Docker running:

```bash
supabase db reset --local
supabase db lint --local
```
