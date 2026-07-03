# First Repeatable Loop Audit

Branch: `gameplay/first-repeatable-loop`

Goal: make the first mobile loop real and server-confirmed:

```text
Create Drop -> Publish -> Earn -> Upgrade / Claim -> Unlock Next Visible Thing
```

This audit is intentionally non-runtime. It identifies the blockers that must be fixed before adding more empire systems.

## 1. Idle income invocation

Files inspected:

- `lib/core/services/idle_engine_service.dart`
- `lib/core/constants/supabase_constants.dart`
- `supabase/migrations/014_supply_chain.sql`
- `supabase/migrations/20260607133004_repair_linted_rpc_schema_drift.sql`
- `supabase/migrations/027_security_hardening.sql`

Current finding:

- `IdleEngineService` documents `process_idle_income` as an RPC but calls it through `SupabaseService.invokeFunction`, which uses the Supabase Edge Functions path.
- The backend already has a Postgres RPC named `process_idle_income(p_player_id uuid)`.
- The RPC returns inventory and idle fields, but the client currently assumes an Edge Function response shape and falls back to a hardcoded warehouse capacity when the field is absent.

Blocker:

- Idle claim/catch-up is not aligned with the server-authoritative backend path.

Exact proposed fix:

- Change `IdleEngineService` to call `SupabaseService.client.rpc(SupabaseConstants.fnProcessIdleIncome, params: {'p_player_id': active user id})`.
- Normalize both map and single-row/list RPC response shapes into `IdleIncomeResult`.
- Do not add new idle math, fake offline income, or client-side revenue writes.

Risk level: Medium. This touches lifecycle-triggered economy sync, but the backend function already exists.

Tests required:

- Unit test for RPC result normalization.
- Unit/contract test that idle income uses the RPC path constant rather than `functions.invoke`.
- Supabase test only if the backend shape is changed.

Human decision required: No.

## 2. Brand Rank / XP progression

Files inspected:

- `supabase/functions/drop-design/index.ts`
- `supabase/migrations/20260607133004_repair_linted_rpc_schema_drift.sql`
- `lib/features/atelier/providers/drop_design_provider.dart`
- `lib/features/hq/providers/hq_provider.dart`
- `lib/presentation/widgets/brand_rank_bar.dart`

Current finding:

- `edge_drop_design` grants `xp_delta` and updates `players.total_xp`.
- It does not currently calculate the early Rank 1-10 value from total XP, does not update `players.brand_rank`, and does not return the required confirmed fields:
  - `current_rank`
  - `rank_progress_percent`
  - `rank_up_occurred`
- Existing client display still reads `rank_progress_delta`, which is a drop-local delta, not confirmed total rank progress.

Blocker:

- A player can earn XP from a drop without the first-loop Rank promise becoming visibly and authoritatively true.

Exact proposed fix:

- In the latest `edge_drop_design` migration definition, compute:
  - `new_total_xp = old_total_xp + xp_delta`
  - `current_rank = clamp(floor(new_total_xp / 1000) + 1, 1, 10)`
  - `rank_progress_percent = bounded progress within the current 1000 XP rank band`
  - `rank_up_occurred = current_rank > old_rank`
- Update `players.total_xp` and `players.brand_rank` in the same authoritative transaction.
- Return the new rank fields to `drop-design` and the Flutter drop result.
- Preserve duplicate drop idempotency by returning zero reward deltas for already-dropped designs.

Risk level: Medium. This changes authoritative progression output, but the rule is tightly scoped to Ranks 1-10.

Tests required:

- Drop grants XP.
- XP threshold increments rank.
- Rank progress remains bounded.
- Rank does not skip beyond the clamped Rank 10 first-loop scope.
- Duplicate drop does not duplicate XP/rank rewards.

Human decision required: No.

## 3. Mogul first playable action

Files inspected:

- `lib/features/ledger/screens/ledger_screen.dart`
- `lib/features/ledger/providers/ledger_provider.dart`
- `supabase/functions/process-transaction/index.ts`
- `supabase/migrations/001_initial_schema.sql`
- `supabase/migrations/20260618063958_security_hardening_pass_1_execution.sql`
- `test/features/ftue/first_objective_lifecycle_contract_test.dart`

Current finding:

- The Ledger screen streams owned stores and can upgrade an existing store.
- Empty Ledger state says `NO ASSETS / OPEN YOUR FIRST STORE`, but there is no tappable first-store action.
- `process-transaction` only accepts `upgrade_store`.
- The Mogul first objective is completed by visiting Ledger, Feed, and HQ, not by performing a real economy action.

Blocker:

- Mogul/Architect first playable path is not a real game loop yet.

Exact proposed fix:

- Add server-authoritative `open_first_store` through `process-transaction`.
- Add an RPC that creates exactly one starter store for the authenticated player if they have none:
  - `type = ecommerce`
  - `city = player.hq_city`
  - `tier = 1`
  - `revenue_per_hour = 500`
  - `market_share = 0`
  - first playable cost = 0
  - idempotent
- Add a Ledger empty-state CTA that calls the Edge Function and lets the existing Realtime store stream show the result.

Risk level: Medium. This requires a migration and Edge Function branch, but it is isolated from the broader store economy.

Tests required:

- First call creates one owned starter store.
- Second call does not duplicate.
- Cross-player store creation fails.
- Ledger empty-state CTA triggers the server path.
- Realtime/store stream remains the display source of truth.

Human decision required: No.

## 4. First objective clarity

Files inspected:

- `lib/features/ftue/providers/first_objective_provider.dart`
- `lib/features/ftue/widgets/first_objective_card.dart`
- `lib/features/ftue/widgets/luxe_first_objective_overlay.dart`
- `lib/features/hq/screens/hq_screen.dart`
- `lib/features/feed/screens/feed_screen.dart`
- `lib/features/ledger/screens/ledger_screen.dart`
- `lib/features/onboarding/screens/career_path_screen.dart`

Current finding:

- Designer objective correctly points to Atelier and checks for a server-confirmed Alpha Drop.
- Designer objective copy does not explicitly include returning to HQ for the first-loop feedback moment.
- Mogul objective is not tied to a server-confirmed store/action.
- Onboarding path confirmation still says a later change costs premium currency, which conflicts with the current first-loop directive and risks foregrounding monetization too early.

Blocker:

- The first objective card explains activity, but not the full repeatable loop promise.

Exact proposed fix:

- Designer objective: `Open Atelier -> Mint Alpha -> Drop to Feed -> Return HQ`.
- Mogul objective: `Open Ledger -> Open First Store -> See Asset -> Return HQ`.
- Add a marker/repository check for first store existence after `open_first_store`.
- Remove stale premium path-switching copy.

Risk level: Low to Medium. Copy changes are low risk; Mogul completion requires backend store support.

Tests required:

- Designer objective routing remains Atelier-first.
- Designer completion requires server-confirmed drop.
- Mogul CTA starts at Ledger.
- Mogul completion requires real owned starter store and return to HQ.

Human decision required: No.

## 5. Route / dead gameplay audit

Files inspected:

- `lib/core/router/app_router.dart`
- `lib/presentation/screens/main_shell.dart`
- `lib/features/hq/widgets/hq_artisan_view.dart`
- `lib/features/hq/widgets/hq_architect_view.dart`
- `lib/features/maison/screens/maison_screen.dart`
- `lib/features/maison/screens/district_map_screen.dart`
- `lib/features/store/screens/shop_screen.dart`
- `lib/features/ledger/screens/equity_screen.dart`
- `lib/features/mini_games/screens/hostile_takeover_screen.dart`

Current finding:

- Future systems are route-reachable or visible: Maison, District, Gala, Equity, AR, hostile takeovers, shop/storefront, archive market, and crisis content.
- Some future systems are active-looking even when disconnected or too advanced for the first session.
- The shell includes Maison as a first-session tab even though the first-loop directive says Maison expansion should be locked/hidden.

Blocker:

- First-session attention is diluted by systems that are larger than the currently supported repeatable loop.

Exact proposed fix:

- Do not delete future routes or large systems.
- Hide or lock first-session CTAs that imply active Maison, District, Gala, Equity/IPO, AR, hostile takeover, storefront monetization, or disconnected mini-games.
- Keep locked previews only where useful and clearly label them as locked future systems.

Risk level: Medium. Route cleanup can accidentally remove future work, so changes should be UI gating/copy first, not deletion.

Tests required:

- First-loop route reachability remains intact.
- Inactive systems are not presented as active first-session objectives.
- Maison/District/Gala/Equity are locked or unavailable from first-session objective surfaces.

Human decision required: No, as long as no future systems are deleted.

## 6. First-loop regression test plan

Required automated coverage:

- Idle RPC invocation/result shape.
- First drop XP/rank update.
- Bounded rank progress.
- Duplicate drop idempotency.
- First-store creation idempotency.
- Designer objective routing.
- Mogul first action CTA.
- Drop Preview duplicate-submit guard.
- First-loop route reachability.
- Inactive systems not presented as active first-session objectives.

Required Supabase coverage:

- `process_idle_income` returns the shape the client normalizes.
- `edge_drop_design` updates total XP and Rank 1-10 server-side.
- Duplicate `edge_drop_design` call does not duplicate rewards.
- `open_first_store` creates exactly one owned starter store.
- Cross-player ownership checks remain enforced.

Manual-only verification:

```text
1. Launch app.
2. Complete onboarding.
3. Enter HQ as Designer.
4. Open Atelier.
5. Mint Alpha.
6. Drop to Feed.
7. Confirm Vex/Feed result.
8. Return HQ.
9. Confirm XP/rank/heat/follower/idle deltas are server-confirmed.
10. Confirm next objective appears.
11. Start or switch to Architect/Mogul path.
12. Complete Open First Store.
13. Confirm Ledger/HQ shows real owned store or revenue change.
14. Claim idle income.
15. Confirm no raw backend errors.
16. Confirm no duplicate drop/reward.
```

Remaining deferred systems:

- Maison expansion.
- District.
- Gala.
- Equity / IPO.
- AR.
- Hostile takeovers.
- Storefront monetization.
- Disconnected mini-games.

## 7. Coverage matrix

Covered by automated tests:

- Idle RPC result normalization and RPC call-shape contract:
  `test/core/services/idle_engine_service_test.dart`.
- Drop Preview duplicate-submit guard:
  `test/features/atelier/drop_preview_duplicate_submit_guard_test.dart`.
- Designer/Mogul first objective copy, route intent, and starter-store repository check:
  `test/features/ftue/first_loop_scope_contract_test.dart`.
- Mogul first action CTA and Realtime store stream source of truth:
  `test/features/ledger/open_first_store_contract_test.dart`.
- First-loop route reachability:
  `test/core/router/first_loop_route_reachability_test.dart`.
- Existing marker lifecycle guard coverage:
  `test/features/ftue/first_objective_lifecycle_contract_test.dart`.

Covered by Supabase tests:

- Drop grants XP, updates Rank 1-10 server-side, bounds rank progress, and keeps duplicate drops idempotent:
  `supabase/tests/first_loop_rank_progression.sql`.
- Starter store creation is server-side, idempotent, and path-guarded:
  `supabase/tests/first_loop_open_first_store.sql`.

Manual-only verification:

- Full on-device loop:
  onboarding -> HQ -> Atelier -> mint -> Drop Preview -> Vex/no Vex -> Drop Launch -> Feed -> HQ feedback.
- Confirm HQ shows Rank/XP/heat/follower/idle changes from server-confirmed state.
- Confirm Architect/Mogul path can open Ledger, open first store, see the Realtime-owned asset, return HQ, and claim idle income.
- Confirm no raw Supabase/RPC/JWT/null/500 errors appear to the player.
- Confirm no duplicate drops, duplicate store creation, or duplicate rewards occur during fast tapping and back navigation.

Remaining deferred systems:

- Maison expansion.
- District.
- Gala.
- Equity / IPO.
- AR.
- Hostile takeovers.
- Storefront monetization.
- Disconnected mini-games.
