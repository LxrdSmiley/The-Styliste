# Security Audit Pass 1 — Execution Summary

Last updated: June 22, 2026  
Supabase project: `xzzklkmkjmwzpiedkwho`

## Outcome

The confirmed pass-one code vulnerabilities have been remediated and deployed.
This does not constitute public-launch approval: manual platform, legal,
operational, Flutter, and runtime gates remain.

## Resolved

- Firebase/Supabase bridge events are serialized; sign-out clears both sessions
  and Realtime channels.
- Mini-games use server-created attempts, bounded proofs, cooldowns,
  transactional rewards, and one-time claims.
- Atelier sessions and final Hype are server-owned and idempotent.
- Apple and Google purchases are account-bound and transaction-bound; canonical
  product grants are applied atomically.
- Store upgrades and Maison donations use locked, idempotent database
  transactions.
- Staff Rally cooldown and stamina changes are server-owned.
- `trend-decay`, `eclipse-event-tick`, and FCM webhook entry points fail closed
  without strong deployment secrets.
- FCM webhooks validate schema/table/event/record shape and reject replay.
- Feed comments, reactions, inspiration, drops, idle income, Atelier, IAP,
  mini-games, upgrades, and donations have server-side rate limits.
- Player reports now enforce category, target, description, anti-self-report,
  same-target cooldown, and daily-cap rules in Postgres.
- Android release tasks fail when signing configuration is absent; the pinned
  Gradle wrapper is included for source control.
- Edge Functions return stable player-safe errors with server correlation IDs.
- Architect HQ contains the stream-backed Cash Flow Ribbon.
- World Map, Profile, Events, and AR routes use honest polished locked previews.
- Staff Rally and Supplier Raid are retired from the standalone mini-game API,
  attempt ledger, and client code as required by GDD v6 §12.2.2.

## Database Changes

- `20260618063958_security_hardening_pass_1_execution.sql`
- `20260618070214_repair_remaining_linted_security_functions.sql`
- `20260618070433_edge_rate_limit_enforcement.sql`
- `20260622113000_harden_kintsugi_cost_authority.sql`
- `20260622114500_harden_player_reports.sql`
- `20260622120000_restrict_player_report_grants.sql`
- `20260622121500_index_player_report_targets.sql`
- `20260622123000_retire_standalone_staff_supplier_games.sql`

All eight migrations are applied to the linked project.

## Automated Evidence

- `deno check` completed successfully for all changed Edge Functions.
- `supabase db lint --linked --level error --fail-on error` completed
  successfully after the final schema.
- `supabase/tests/security_hardening_pass_1.sql` completed successfully and
  rolled back its fixtures.
- Live unauthenticated smoke tests returned:
  - `401` for JWT-backed gameplay/payment functions.
  - `503` for privileged functions whose required secrets are not configured.

## Intentionally Open

- First Vex Reveal remains paused.
- Solidarity Strike and Supply Chain Scramble still require their full
  community-event implementations.
- Bundled legal text remains closed-alpha placeholder copy and requires
  counsel-approved public documents.
- Privileged scheduler/webhook and Firebase messaging secrets remain operator
  work.
- PITR is disabled and no backup timestamp is currently available.
- Supabase Advisor backlog remains for legacy callable definer RPC review,
  anonymous-policy classification, `pg_net` placement, leaked-password
  protection, RLS performance plans, and unindexed foreign keys.
- Store-console purchase sandbox and refund/revocation testing remains manual.
- Flutter formatting, analysis, tests, and runtime QA remain Smiley-run tasks.

## Secret Handling

No secret values are recorded in this document. Configuration status was checked
by secret name only.
