# IDE_DIRECTIVES.md

Audit target: full repository against `THE_STYLISTE_GDD_v6.md`, with security, credentials, legal, and static analysis prioritized ahead of gameplay polish.

Static-analysis baseline supplied by developer: `dart analyze` reports 115 issues, `flutter analysis` reports 0 errors.

## 1. GDD Coverage Map

Use this table as the implementation acceptance checklist. Status is code-present status, not design intent.

| GDD feature | Code map | Status | Required IDE action |
|---|---|---:|---|
| GDD §1.1 Onboarding, Aurelian Sanctuary 7 screens | `lib/features/onboarding/screens/*`, `supabase/migrations/018_onboarding_flag.sql` | Partial | Fix analyzer issues in onboarding, replace avatar placeholder with real mannequin asset gate, keep Supabase auth gate before onboarding writes. |
| GDD §2 Designer Loop | `lib/features/atelier`, `lib/features/feed`, `supabase/functions/mint-design` | Partial | Make Hype Score server-authoritative and formula-correct. See directives 5 and 7. |
| GDD §2 Mogul Loop | `lib/features/ledger`, `lib/features/store`, `lib/features/supply_chain`, `supabase/functions/process-transaction` | Partial | Repair schema drift and rate-limit all economy RPCs. See directives 2, 6, and 7. |
| GDD §3 Player Progression Paths | `lib/features/hq`, `lib/domain/models/player.dart`, `lib/core/router/app_router.dart` | Partial | Verify path-specific route guards and suppress unimplemented path widgets until functional. |
| GDD §3.0 Main HQ Dashboard | `lib/features/hq/screens/hq_screen.dart`, `lib/features/hq/widgets/*` | Partial | Fix bottom-sheet generic warnings and remove `_CashFlowRibbon` dead code. |
| GDD §3.1-3.2 Brand Rank and pacing | `lib/core/constants/game_constants.dart`, `lib/presentation/widgets/brand_rank_bar.dart`, rank fields in migrations | Partial | Align rank source of truth: use `players.brand_rank` or `brand_state.brand_rank`, not both. |
| GDD §3.3-3.4 Idle progression and soft cap | `lib/core/services/idle_engine_service.dart`, `supabase/functions/calculate-idle-income`, `supabase/migrations/014_idle_soft_cap.sql` | Partial | Keep server-only idle calculation and add RPC rate limit checks. |
| GDD §3.5 Aurelian Ascension | `lib/features/ascension`, `supabase/migrations/008_aurelian_ascension.sql` | Partial | Add analyzer type annotations in `ascension_provider.dart`. |
| GDD §3.6 Accessibility and progressive complexity | `lib/features/settings/screens/settings_screen.dart` Expert Mode | Partial | Add actual accessibility controls beyond Expert Mode: reduced motion, text scale, high contrast. |
| GDD §3.7 What's Next dashboard | HQ widgets and onboarding redirect | Partial | Add explicit post-onboarding objectives, or hide claims until implemented. |
| GDD §3.8 F2P progression | Economy constants and store providers | Partial | Add tests proving non-IAP path parity for rank and talent progression. |
| GDD §3.9 Path specialization | `CareerPath`, HQ path widgets | Partial | Add path-lock tests and prevent cross-path reward leakage. |
| GDD §4.1 Atelier UI and Hype_Score | `lib/features/atelier`, `lib/features/design/services/hype_calculator.dart`, `supabase/functions/mint-design` | Partial | Replace random hype and local-only calculation. See directive 7. |
| GDD §4.2 Atelier Verlet physics | `lib/features/atelier/widgets/garment_canvas.dart`, `lib/shaders/cloth_physics.frag`, `lib/features/onboarding/widgets/verlet_ribbon_painter.dart` | Partial | Remove unused physics fields and add golden/smoke tests for nonblank shader render. |
| GDD §4.3 Avatar customization | `lib/features/onboarding/screens/avatar_customizer_screen.dart` | Partial | Replace "stichless_mannequin.glb display placeholder" with asset-backed preview or hide 3D claim. |
| GDD §4.4 AR try-on and Street Snaps | `lib/features/ar_tryon/screens/ar_tryon_screen.dart` | Scaffold | Replace Phase 10 tracking placeholder with real ARKit/ARCore/body tracking or mark feature unavailable in alpha. |
| GDD §5 Mogul domain, Ledger, store, deals | `lib/features/ledger`, `lib/features/store`, `supabase/functions/process-transaction` | Partial | Keep all capital mutations in Edge Functions/RPCs; no client-side economy writes. |
| GDD §5.1 Supply chain logistics | `lib/features/supply_chain`, `supabase/migrations/009_supply_chain.sql` | Partial | Add missing manual negotiation risks and DPP audit integration. |
| GDD §5.2 Supplier negotiation risks | `lib/features/supply_chain/providers/supply_chain_provider.dart` | Partial | Add typed models and tests for risk outcomes. |
| GDD §5.3 Inventory management | `brand_state` inventory fields and supply widgets | Partial | Add tests for capacity caps and overflow behavior. |
| GDD §5.4 Marketing mechanics and campaign builder | `lib/features/ledger`, `supabase/migrations` campaign tables | Partial | Build campaign UI or hide route claims. |
| GDD §5.5-5.6 Central bank and equity | `lib/features/ledger`, `lib/features/equity`, `supabase/migrations/011_central_bank_equity.sql` | Partial | Fix analyzer type annotations and add anti-manipulation tests. |
| GDD §5.7 Mini-games | `lib/features/mini_games`, `supabase/functions/claim-mini-game-reward`, `supabase/migrations/017_mini_game_rewards.sql` | Partial | Use service-only reward RPC and remove broken `inject_capital_bonus` provenance write. See directive 6. |
| GDD §6.1 Global Live Feed | `lib/features/feed`, `supabase/migrations/002_feed_triggers.sql`, `020_rate_limiting.sql` | Partial | Update feed hype RPC to two-arg hardened function. See directive 5. |
| GDD §6.2 Partnerships and profit splits | `lib/features/feed`, `supabase/migrations/003_social_graph.sql` | Partial | Add split enforcement tests before alpha. |
| GDD §6.3 Maisons and leadership | `lib/features/maison`, `supabase/migrations/004_maison_treasury.sql` | Partial | Fix deprecated Riverpod ref and type annotations. |
| GDD §6.4-6.8 Social hooks, competitions, rewards | `lib/features/gala`, `lib/features/maison`, `lib/features/feed` | Partial | Repair Gala ownership validation and dynamic casts. See directive 6 and static-analysis table. |
| GDD §6.9 Aurelian Gala | `lib/features/gala`, `supabase/migrations/012_aurelian_gala.sql`, `019_luxe_trust_score.sql` | Partial | Validate design ownership and active event in latest `submit_to_gala`. See directive 6. |
| GDD §6.10 Reporting | `lib/features/reporting/widgets/report_modal.dart`, `supabase/migrations/015_player_reporting.sql` | Partial | Add screenshot bucket, server-side anti-abuse, moderation queue, and reporter rate limits. |
| GDD §7 Rivals and events | `lib/features/events`, `supabase/functions/eclipse-event-tick` | Scaffold | Secure cron invocation and replace "Events Coming in Phase 4". |
| GDD §8.1 Seasonal trend cycles | `lib/features/trends`, `supabase/migrations/006_trend_tsunami.sql` | Partial | Correct multipliers and use active trend in server mint. |
| GDD §8.1.1 real fashion trends | Trend provider and migration seeds | Missing | Add curated/imported trend source or mark as manual content pipeline. |
| GDD §8.1.2 Trend Tsunami | `lib/features/trends`, `TrendTsunami`, migrations | Partial | GDD says 48h and 1.5x alignment bonus; current code has 2.5x crest. Correct in directive 7. |
| GDD §8.3 celebrity endorsement | No complete feature module found | Missing | Add module or remove alpha claim. |
| GDD §8.4 IP protection | Reporting and legal links only | Partial | Add DMCA flow, proof upload, repeat-infringer policy hook. |
| GDD §8.5 economic volatility | `lib/features/events`, economy migrations | Partial | Add server-side event generation tests. |
| GDD §8.6 demographics and loyalty | scattered constants/providers | Partial | Add typed demand segments and formulas. |
| GDD §8.7 Media/PR and Vex AI critic | `lib/features/design/services/vex_ai_engine.dart`, `vex_review_card.dart` | Partial | Persist opt-in reviews to Brand Story Archive and remove unused pools. |
| GDD §8.9 regulations and DPP | no complete DPP module | Missing | Add DPP schema, score, audit, and resale display. |
| GDD §8.9.2 crisis, Tarnish, Kintsugi | `lib/features/crisis`, `supabase/migrations/010_crisis_management.sql` | Partial | Add "Leak a Rumor" and server-side crisis anti-abuse. |
| GDD §8.9.3-8.9.6 ethical/sustainability supply | supply providers and migrations | Partial | Add certifications and marketing-compliance checks. |
| GDD §8.9.7-8.9.8 Brand Heat and Founder Rep | `lib/features/hq/widgets/brand_heat_meter.dart`, `lib/features/hq/providers` | Partial | Confirm formulas server-side and fix painter lint. |
| GDD §8.9.9 resale and circular economy | `lib/features/archive`, `supabase/migrations/013_the_archive.sql` | Partial | Add `designs.owner_id` migration and ownership tests. See directive 6. |
| GDD §8.9.10 repair/longevity | `lib/features/crisis/screens/kintsugi_repair_screen.dart` | Partial | Remove unused path locals and add repair outcome tests. |
| GDD §8.9.11 dynamic demand/pricing | `lib/features/ledger`, `hype_calculator.dart` | Partial | Align formulas to GDD and test deterministic outputs. |
| GDD §8.9.12 Fashion Week politics | `lib/features/events`, `lib/features/gala` | Scaffold | Build event logic or hide alpha route. |
| GDD §8.9.13 wholesale/B2B | no complete feature module found | Missing | Add schema/provider/UI or move out of alpha scope. |
| GDD §8.9.14 physical vs digital fashion | no complete split module found | Missing | Add product split fields and demand tests. |
| GDD §8.10 Talent/Sovereign gacha | `lib/features/talent`, `supabase/migrations/011_talent_system.sql` | Partial | Verify actual odds, pity, and PvP caps server-side. |
| GDD §8.11 follower system | `lib/features/feed/providers/feed_provider.dart`, social graph migration | Partial | Fix hype RPC and add follow-abuse rate limits. |
| GDD §8.12 Luxe mentor and quests | `lib/features/luxe`, daily check-in widgets, migrations | Partial | Replace Rive placeholder and implement memory/quests/multi-language. |
| GDD §8.13 Brand Story Archive | `lib/features/profile`, archive/provenance views | Scaffold | Replace profile placeholder and persist story entries. |
| GDD §8.16 Support and feedback | reporting modal only | Partial | Add support ticket form, history, surveys, and SLA states. |
| GDD §8.15 Security | `lib/core/services/firebase_service.dart`, Supabase RLS migrations, Edge Functions | Partial | Apply directives 2, 3, 4, 5, and 6. |
| GDD §9 Monetization | `lib/features/store`, `supabase/functions/validate-iap`, store migrations | Partial | Align product IDs, disclose odds, and add refund/legal manual tasks. |
| GDD §10.1 legal docs | Settings links only; no repo legal docs found | Missing | Add Marketing Policy link in IDE; legal text is manual. See directive 9 and `MANUAL_TASKS.md`. |
| GDD §12 v6 overhaul | Trend Tsunami, Vex, DPP, crisis, monetization | Partial | Treat Trend, Vex, DPP, "Leak a Rumor", and season pass as alpha blockers if promised in release notes. |

## 2. Keep Supabase Security Hardening Migration And Verify It

GDD §8.15, §6.1, §8.16, §9.7.

File: `supabase/migrations/027_security_hardening.sql`

Status: patched in this audit. Keep this migration and run it on a local branch database before more gameplay work.

The migration now closes the Supabase advisor findings that are IDE-fixable in SQL:

```sql
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM anon;
```

It also replaces unsafe client-callable functions with explicit grants, fixes mutable function search paths, changes exposed views to invoker views, and adds missing FK indexes.

Test:

```bash
supabase db reset
supabase db lint
supabase db push --dry-run
```

Then manually verify:

```sql
select * from public.daily_revenue_ledger limit 1;
select * from public.player_active_buffs limit 1;
select public.increment_post_hype('<post-id>'::uuid, '<own-player-id>'::uuid);
```

Expected:

- Anonymous calls to public RPCs fail.
- Authenticated calls only work for the current `auth.uid()`.
- Second hype on the same post returns `ALREADY_HYPED`.
- Supabase advisor no longer reports security-definer views, mutable `search_path`, or anon-executable security-definer RPCs.

Reference: Supabase states API grants and RLS both control access, and functions should grant `EXECUTE` only to appropriate roles: https://supabase.com/docs/guides/api/securing-your-api. Supabase also documents `security_invoker` views so underlying RLS applies: https://supabase.com/docs/guides/database/tables#view-security.

## 3. Add Edge Function Invocation Secrets And App Check Verification Hooks

GDD §8.15.1, §8.15.2.

File: `supabase/functions/eclipse-event-tick/index.ts`

Problem: the function uses `SUPABASE_SERVICE_ROLE_KEY` and says "no JWT required". If deployed with public invocation, anyone with the URL can trigger global events.

Insert immediately after the `OPTIONS` block:

```ts
const expectedSecret = Deno.env.get("ECLIPSE_EVENT_TICK_SECRET");
const providedSecret = req.headers.get("x-cron-secret");

if (!expectedSecret || providedSecret !== expectedSecret) {
  return new Response(
    JSON.stringify({ error: "Forbidden" }),
    { status: 403, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
  );
}
```

Apply the same header-secret pattern to any service-role-only cron/admin Edge Function.

Test:

```bash
curl -i https://<project>.functions.supabase.co/eclipse-event-tick
curl -i -H "x-cron-secret: $ECLIPSE_EVENT_TICK_SECRET" https://<project>.functions.supabase.co/eclipse-event-tick
```

Expected: first call returns 403; second call executes.

Manual follow-up is required for Firebase App Check token verification in Supabase Edge Functions. The Flutter app activates App Check, but Supabase Functions do not automatically enforce Firebase App Check. See `MANUAL_TASKS.md`.

Reference: Firebase App Check for Flutter uses Play Integrity on Android and DeviceCheck/App Attest on Apple platforms to help ensure only the app can access Firebase resources: https://firebase.google.com/docs/app-check/flutter/default-providers.

## 4. Fail Fast When Runtime Keys Are Missing

GDD §8.15.1.

File: `lib/main.dart`

Problem: `_supabaseUrl` and `_supabaseAnonKey` are checked only with `assert`, which is stripped from release builds.

Replace:

```dart
assert(_supabaseUrl.isNotEmpty, 'SUPABASE_URL must be set via --dart-define-from-file');
assert(_supabaseAnonKey.isNotEmpty, 'SUPABASE_ANON_KEY must be set via --dart-define-from-file');
```

With:

```dart
if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
  throw StateError(
    'SUPABASE_URL and SUPABASE_ANON_KEY must be set via --dart-define-from-file',
  );
}
```

Test:

```bash
flutter run --release
flutter run --dart-define-from-file=.env.json
dart analyze
```

Expected: missing runtime config fails before app boot; configured app boots normally.

Reference: Firebase allows config API keys in app config, but they must be managed and restricted appropriately: https://firebase.google.com/docs/projects/api-keys.

## 5. Fix Feed Hype RPC After Security Hardening

GDD §6.1, §8.11, §8.15.2.

File: `lib/features/feed/providers/feed_provider.dart`

Problem: Dart calls the retired one-arg RPC:

```dart
await SupabaseService.client
    .rpc<void>(
      'increment_post_hype',
      params: <String, dynamic>{'target_post_id': postId},
    );
```

Replace the provider block with:

```dart
final FutureProviderFamily<void, String> hypePostProvider =
    FutureProvider.family<void, String>(
  (Ref<AsyncValue<void>> ref, String postId) async {
    final String uid = ref.read(activeUidProvider);

    await SupabaseService.client.rpc<Map<String, dynamic>>(
      'increment_post_hype',
      params: <String, dynamic>{
        'p_post_id': postId,
        'p_player_id': uid,
      },
    );
  },
);
```

Then replace all references to `hyypePostProvider` with `hypePostProvider`.

Test:

```bash
rg -n "hyypePostProvider|target_post_id" lib
dart analyze
```

Expected: no typo provider remains, no call to the revoked one-arg RPC remains, tapping hype once increments, tapping twice does not double-count.

## 6. Add Schema Drift Repair Migration Before Alpha

GDD §5.7, §6.9, §8.9.9, §8.12.

Create a new migration: `supabase/migrations/028_schema_drift_repair.sql`

Add:

```sql
-- Archive functions require ownership transfer. Existing schema only had player_id.
ALTER TABLE public.designs
  ADD COLUMN IF NOT EXISTS owner_id UUID REFERENCES public.players(id);

UPDATE public.designs
SET owner_id = player_id
WHERE owner_id IS NULL;

CREATE INDEX IF NOT EXISTS designs_owner_idx ON public.designs(owner_id);

-- Latest Gala function must validate ownership and active event.
DROP FUNCTION IF EXISTS public.submit_to_gala(UUID, UUID, UUID);
CREATE OR REPLACE FUNCTION public.submit_to_gala(
  p_player_id UUID,
  p_design_id UUID,
  p_event_id UUID
)
RETURNS TABLE(submission_id UUID, success BOOLEAN, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_submission_id UUID;
  v_existing UUID;
BEGIN
  PERFORM public.assert_self(p_player_id);

  IF NOT EXISTS (
    SELECT 1 FROM public.designs
    WHERE id = p_design_id AND COALESCE(owner_id, player_id) = p_player_id
  ) THEN
    RAISE EXCEPTION 'DESIGN_NOT_OWNED';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.gala_events
    WHERE id = p_event_id AND status = 'active'
  ) THEN
    RAISE EXCEPTION 'GALA_EVENT_NOT_ACTIVE';
  END IF;

  SELECT id INTO v_existing
  FROM public.gala_submissions
  WHERE player_id = p_player_id AND event_id = p_event_id;

  IF v_existing IS NOT NULL THEN
    RETURN QUERY SELECT v_existing, FALSE, 'ALREADY_SUBMITTED';
    RETURN;
  END IF;

  INSERT INTO public.gala_submissions (player_id, design_id, event_id, submitted_at)
  VALUES (p_player_id, p_design_id, p_event_id, NOW())
  RETURNING id INTO v_submission_id;

  PERFORM public.increment_luxe_trust(p_player_id, 1);

  RETURN QUERY SELECT v_submission_id, TRUE, 'SUBMISSION_ACCEPTED';
END;
$$;

REVOKE ALL ON FUNCTION public.submit_to_gala(UUID, UUID, UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.submit_to_gala(UUID, UUID, UUID) TO authenticated;

-- 019_luxe_trust_score referenced last_check_in_at, but 016 created last_check_in.
DROP FUNCTION IF EXISTS public.record_check_in(UUID);
CREATE OR REPLACE FUNCTION public.record_check_in(p_player_id UUID)
RETURNS TABLE(success BOOLEAN, streak INTEGER, reward_luxe INTEGER, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_last_check_in DATE;
  v_streak INTEGER := 1;
  v_reward INTEGER := 10;
BEGIN
  PERFORM public.assert_self(p_player_id);

  SELECT last_check_in, current_streak
  INTO v_last_check_in, v_streak
  FROM public.daily_check_ins
  WHERE player_id = p_player_id;

  IF v_last_check_in = CURRENT_DATE THEN
    RETURN QUERY SELECT FALSE, v_streak, 0, 'ALREADY_CLAIMED';
    RETURN;
  END IF;

  IF v_last_check_in = CURRENT_DATE - INTERVAL '1 day' THEN
    v_streak := v_streak + 1;
  ELSE
    v_streak := 1;
  END IF;

  v_reward := 10 + LEAST(v_streak, 30);

  INSERT INTO public.daily_check_ins (player_id, current_streak, last_check_in, total_check_ins)
  VALUES (p_player_id, v_streak, CURRENT_DATE, 1)
  ON CONFLICT (player_id) DO UPDATE
  SET current_streak = EXCLUDED.current_streak,
      last_check_in = EXCLUDED.last_check_in,
      total_check_ins = public.daily_check_ins.total_check_ins + 1;

  UPDATE public.brand_state
  SET luxe_tokens = luxe_tokens + v_reward
  WHERE player_id = p_player_id;

  PERFORM public.increment_luxe_trust(p_player_id, 1);

  RETURN QUERY SELECT TRUE, v_streak, v_reward, 'CHECK_IN_CLAIMED';
END;
$$;

REVOKE ALL ON FUNCTION public.record_check_in(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.record_check_in(UUID) TO authenticated;

-- Do not log pure currency rewards into provenance_ledger; it is design ownership history.
CREATE OR REPLACE FUNCTION public.inject_capital_bonus(
  p_player_id UUID,
  p_amount INT,
  p_reason TEXT DEFAULT 'mini_game_reward'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.role() <> 'service_role' THEN
    RAISE EXCEPTION 'SERVICE_ROLE_REQUIRED';
  END IF;

  RETURN public.grant_mini_game_reward(
    p_player_id,
    'hostile_takeover',
    p_reason,
    p_amount
  );
END;
$$;

REVOKE ALL ON FUNCTION public.inject_capital_bonus(UUID, INT, TEXT) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.inject_capital_bonus(UUID, INT, TEXT) TO service_role;
```

Test:

```bash
supabase db reset
supabase db lint
```

Expected: migrations apply cleanly; Gala rejects another player's design; archive transfer can update `designs.owner_id`; daily check-in no longer references a missing column.

## 7. Make Hype Score Server-Authoritative And GDD-Correct

GDD §4.1, §8.1.2, §8.10, §12.3.

Files:

- `lib/features/design/services/hype_calculator.dart`
- `supabase/functions/mint-design/index.ts`
- `supabase/migrations/006_trend_tsunami.sql`

Problem: GDD §4.1 formula is:

```text
Hype_Score = (Aesthetic_Alignment * Material_Quality) + Sovereign_Talent_Multiplier
```

GDD §8.1.2 says Trend Tsunami applies a 1.5x bonus to aesthetic alignment during the 48-hour trend. Current Dart comments and code use `Base_Score * Tsunami_Multiplier + Sovereign_Talent_Bonus` and allow a 2.5x crest. The Edge Function uses `Math.random()`, so the client preview and server mint are not the same economy.

In `hype_calculator.dart`, replace the comment block:

```dart
// Formula: H_score = (Base_Score × Tsunami_Multiplier) + Sovereign_Talent_Bonus
//
// Tsunami Multipliers:
//   - Crest Tag (Rank 1): 2.5x
//   - Surge Tags (Rank 2-3): 1.5x
//   - No match: 1.0x
```

With:

```dart
// Formula: Hype_Score =
//   (Aesthetic_Alignment * Trend_Tsunami_Alignment_Multiplier * Material_Quality_Normalized)
//   + Sovereign_Talent_Multiplier
//
// Trend Tsunami:
//   - Active matching trend: 1.5x to Aesthetic_Alignment for 48 hours.
//   - No match: 1.0x.
```

Then replace the Step 1 to Step 4 body in `calculate()` with deterministic formula logic:

```dart
final double tsunamiMultiplier = _hasTrendMatch(input, activeTsunamis) ? 1.5 : 1.0;
final double adjustedAesthetic =
    (input.aestheticAlignment * tsunamiMultiplier).clamp(0.0, 100.0);
final double materialQualityNormalized = input.materialQuality / 100.0;
final double baseScore =
    adjustedAesthetic * materialQualityNormalized * config.baseMultiplier;
final double talentBonus = input.sovereignTalentCount > 0
    ? input.totalTalentExpertise * config.talentBonusPerLevel * input.sovereignTalentCount
    : 0.0;
final double totalScore = (baseScore + talentBonus).clamp(0.0, 100.0);
```

Add helper:

```dart
bool _hasTrendMatch(
  HypeCalculationInput input,
  List<TrendTsunami> activeTsunamis,
) {
  return activeTsunamis.any(
    (TrendTsunami trend) => trend.getMultiplierForAnyTag(input.styleTags) != null,
  );
}
```

In `mint-design/index.ts`, replace the random section:

```ts
const baseHype: number = Math.random() * 70.0 + 30.0;
const rankBonus: number = Math.min(brandRank * 0.5, 25.0);
const rawHype: number = baseHype + rankBonus;
const hypoScore: number = parseFloat(Math.min(rawHype, 100.0).toFixed(2));
```

With server-side deterministic input validation. Do not accept a client-supplied `hype_score`:

```ts
const materialQuality = clampNumber(body.material_quality ?? 50, 0, 100);
const aestheticAlignment = clampNumber(body.aesthetic_alignment ?? 50, 0, 100);
const styleTags = Array.isArray(body.style_tags) ? body.style_tags.slice(0, 8) : [];
const trendMultiplier = await resolveTrendMultiplier(admin, styleTags);
const sovereignTalentBonus = await resolveSovereignTalentBonus(admin, playerId);

const adjustedAesthetic = Math.min(aestheticAlignment * trendMultiplier, 100);
const rawHype = adjustedAesthetic * (materialQuality / 100) + sovereignTalentBonus;
const hypoScore = parseFloat(Math.min(rawHype, 100).toFixed(2));
```

Add helpers in the same file:

```ts
function clampNumber(value: unknown, min: number, max: number): number {
  const n = Number(value);
  if (!Number.isFinite(n)) return min;
  return Math.min(Math.max(n, min), max);
}
```

Test:

```bash
dart test test/hype_calculator_test.dart
supabase functions serve mint-design
```

Add tests for no trend, matching trend, invalid client values, and Sovereign Talent bonus cap.

## 8. Remove TODOs, Scaffolds, Dead Code, And Ghost Claims

GDD §4.3, §4.4, §6.10, §7.2, §8.12, §8.13.

Replace or hide these alpha-breaking placeholders:

| File | Current scaffold | Replacement |
|---|---|---|
| `lib/features/world_map/screens/world_map_screen.dart` | `World Map - Coming in Phase 4` | Hide route in `app_router.dart` or replace with implemented 2.5D globe/city nodes. |
| `lib/features/events/screens/events_screen.dart` | `Events - Coming in Phase 4` | Hide route or implement Fashion Week/event calendar logic. |
| `lib/features/profile/screens/profile_screen.dart` | `Profile - Coming in Phase 4` | Implement Brand Story Archive and founder profile or remove route from alpha nav. |
| `lib/features/ar_tryon/screens/ar_tryon_screen.dart` | hardcoded `ALPHA PROTOTYPE`, `TRACKING - PHASE 10`, 2D torso box | Gate as unavailable in alpha or implement real AR tracking and real design binding. |
| `lib/features/luxe/widgets/luxe_widget.dart` | Rive placeholder/pulsing container | Add `assets/animations/luxe_idle.riv` or render a non-placeholder mentor component. |
| `lib/features/gala/screens/gala_runway_screen.dart` | 3D garment display placeholder | Bind to actual submitted design preview. |
| `lib/features/archive/screens/archive_market_screen.dart` | design preview placeholder | Render real design image/canvas preview from `design_image_url`. |
| `lib/features/onboarding/screens/avatar_customizer_screen.dart` | mannequin placeholder comment | Add real asset or remove 3D claim. |
| `lib/core/providers/mock_auth_provider.dart` | name says `mock`, stale `kMockUid` | Rename file/provider to `active_player_provider.dart`, keep Supabase UUID source. |
| `lib/domain/repositories/player_repository.dart` | "Uses mock UID until Firebase Auth is wired" | Update stale comment; Firebase/Supabase bridge exists. |
| `test/widget_test.dart` | Phase 0 scaffold smoke test only | Add real auth-gate/onboarding/provider smoke tests. |
| `README.md` | "Phase 0-4 Complete - All core systems..." | Replace with alpha audit status and known blockers. |

Test:

```bash
rg -n "TODO|FIXME|placeholder|Coming in Phase|Phase 10|mock-uid|scaffold smoke|PENDING ASSET" lib test README.md
dart analyze
flutter test
```

Expected: remaining matches are either intentional implementation comments or tracked manual tasks.

## 9. Add Missing Marketing Policy Link In Settings

GDD §10.1.

File: `lib/features/settings/screens/settings_screen.dart`

Problem: Settings links Privacy, Terms, EULA, Community, Cookie, DMCA, Refund, Children's Privacy, and Accessibility. GDD also requires Marketing and Advertising Policy.

Insert after Accessibility Statement:

```dart
_SettingsLinkTile(
  icon: Icons.campaign_outlined,
  title: 'Marketing & Advertising Policy',
  onTap: () => _launchUrl('https://thestyliste.app/marketing'),
),
```

Test:

```bash
dart analyze
flutter test
```

Manual test: Settings > Legal opens every policy URL without a 404.

## 10. Static Analysis Fix List

GDD §8.15 quality gate.

Run:

```bash
dart analyze
dart format lib test
```

Apply every fix below. The analyzer baseline is the developer-provided `dart analyze` output with 115 issues.

### 10.1 Warnings

| Issue | Exact fix |
|---|---|
| `lib/features/archive/screens/archive_market_screen.dart:292 inference_failure_on_function_invocation` | Add explicit type: `showModalBottomSheet<void>(...)` unless awaiting a value. |
| `lib/features/archive/screens/archive_market_screen.dart:304 inference_failure_on_function_invocation` | Add explicit type: `showDialog<void>(...)` unless awaiting a value. |
| `lib/features/archive/screens/archive_market_screen.dart:722 unused_local_variable breakdown` | Remove `breakdown` or render it in the UI. |
| `lib/features/atelier/providers/drop_design_provider.dart:9 unused_import` | Remove `import '../../../core/services/supabase_service.dart';`. |
| `lib/features/atelier/screens/drop_preview_screen.dart:79 inference_failure_on_function_invocation` | Add explicit type: `showDialog<void>(...)`. |
| `lib/features/crisis/screens/kintsugi_repair_screen.dart:149 inference_failure_on_function_invocation` | Add explicit type: `showDialog<void>(...)`. |
| `lib/features/crisis/screens/kintsugi_repair_screen.dart:526 unused_local_variable fillLength` | Remove `fillLength` or use it in path rendering. |
| `lib/features/crisis/screens/kintsugi_repair_screen.dart:527 unused_local_variable fillPath` | Remove `fillPath` or use it in path rendering. |
| `lib/features/crisis/widgets/tarnish_overlay.dart:6 unused_import` | Remove `import 'dart:ui';`. |
| `lib/features/crisis/widgets/tarnish_overlay.dart:10 unused_import` | Remove unused Aurelian theme import. |
| `lib/features/crisis/widgets/tarnish_overlay.dart:11 unused_import` | Remove unused HQ theme import. |
| `lib/features/design/services/vex_ai_engine.dart:33 unused_field tarnishedAdjectives` | Use in generated Tarnished Vex copy or remove the field. |
| `lib/features/design/services/vex_ai_engine.dart:56 unused_field derivativeAdjectives` | Use in derivative review generation or remove. |
| `lib/features/design/services/vex_ai_engine.dart:80 unused_field visionaryAdjectives` | Use in visionary review generation or remove. |
| `lib/features/design/services/vex_ai_engine.dart:105 unused_field sovereignAdjectives` | Use in sovereign review generation or remove. |
| `lib/features/design/services/vex_ai_engine.dart:112 unused_field bridges` | Use in review sentence composition or remove. |
| `lib/features/design/services/vex_ai_engine.dart:253 unused_local_variable multiplier` | Remove the local or include it in scoring/output. |
| `lib/features/design/widgets/vex_review_card.dart:33 unused_field _animationDuration` | Use it in the animation controller/duration or remove. |
| `lib/features/hq/theme/aurelian_hq_theme.dart:108 unused_local_variable floor` | Remove `floor` or use it in the color calculation. |
| `lib/features/hq/widgets/hq_architect_view.dart:198 inference_failure_on_function_invocation` | Add `showModalBottomSheet<void>(...)`. |
| `lib/features/hq/widgets/hq_architect_view.dart:234 inference_failure_on_function_invocation` | Add `showModalBottomSheet<void>(...)`. |
| `lib/features/hq/widgets/hq_architect_view.dart:537 unused_element _CashFlowRibbon` | Remove class or wire it into the architect view. |
| `lib/features/hq/widgets/hq_artisan_view.dart:178 inference_failure_on_function_invocation` | Add `showModalBottomSheet<void>(...)`. |
| `lib/features/maison/screens/district_map_screen.dart:262 inference_failure_on_function_invocation` | Add `showModalBottomSheet<void>(...)`. |
| `lib/features/onboarding/screens/aurelian_gate_screen.dart:50 unused_field _pressStartTime` | Remove the field or use it for press-duration logic. |
| `lib/features/onboarding/widgets/verlet_ribbon_painter.dart:175 unused_field _shadowOffset` | Remove the field or use it in shadow drawing. |
| `lib/features/onboarding/widgets/verlet_ribbon_painter.dart:291 unused_local_variable size` | Remove the local or use it in paint bounds. |

### 10.2 Infos

| Issue | Exact fix |
|---|---|
| `archive_provider.dart:44 always_specify_types` | Add explicit type to the local declaration. |
| `archive_provider.dart:46 always_specify_types` | Add explicit type to the local declaration. |
| `archive_provider.dart:47 always_specify_types` | Add explicit type to the local declaration. |
| `ascension_provider.dart:258 always_specify_types` | Add explicit type to the local declaration. |
| `ascension_provider.dart:266 always_specify_types` | Add explicit type to the local declaration. |
| `drop_design_provider.dart:16 directives_ordering` | Sort imports by Dart style after removing the unused import. |
| `drop_design_provider.dart:264 always_specify_types` | Add explicit type to the local declaration. |
| `drop_design_provider.dart:267 always_specify_types` | Add explicit type to the local declaration. |
| `drop_design_provider.dart:276 always_specify_types` | Add explicit type to the local declaration. |
| `drop_design_provider.dart:279 always_specify_types` | Add explicit type to the local declaration. |
| `drop_design_provider.dart:287 always_specify_types` | Add explicit type to the local declaration. |
| `atelier_screen.dart:78 unawaited_futures` | Add `import 'dart:async';` and wrap intentionally fire-and-forget Future with `unawaited(...)`, or `await` it. |
| `kintsugi_repair_screen.dart:93 unawaited_futures` | Add `unawaited(...)` or `await`. |
| `tarnish_overlay.dart:25-28 always_put_required_named_parameters_first` | Move all `required` named parameters before optional named parameters in the constructor. |
| `gala_provider.dart:149 avoid_dynamic_calls` | Cast response rows to `Map<String, dynamic>` before property access. |
| `gala_provider.dart:150 avoid_dynamic_calls` | Cast nested object before property access. |
| `gala_provider.dart:153 avoid_dynamic_calls` | Cast nested object before property access. |
| `gala_provider.dart:200 avoid_dynamic_calls` | Cast response rows to `Map<String, dynamic>` before property access. |
| `gala_provider.dart:201 avoid_dynamic_calls` | Cast nested object before property access. |
| `gala_provider.dart:204 avoid_dynamic_calls` | Cast nested object before property access. |
| `gala_provider.dart:317 always_specify_types` | Add explicit type to the local declaration. |
| `brand_heat_meter.dart:141 non_constant_identifier_names` | Rename `CustomPainter` parameter/local to `oldDelegate`. |
| `empire_pulse_painter.dart:18 always_put_required_named_parameters_first` | Move required named parameter before optional parameters. |
| `empire_pulse_painter.dart:294 non_constant_identifier_names` | Rename `CustomPainter` parameter/local to `oldDelegate`. |
| `glass_walled_penthouse.dart:365 non_constant_identifier_names` | Rename `CustomPainter` parameter/local to `oldDelegate`. |
| `glass_walled_penthouse.dart:401 non_constant_identifier_names` | Rename `CustomPainter` parameter/local to `oldDelegate`. |
| `hq_architect_view.dart:214 unawaited_futures` | Add `unawaited(...)` or `await`. |
| `hq_artisan_view.dart:194 unawaited_futures` | Add `unawaited(...)` or `await`. |
| `sun_dial_hype_meter.dart:331 non_constant_identifier_names` | Rename `CustomPainter` parameter/local to `oldDelegate`. |
| `equity_provider.dart:130 always_specify_types` | Use `final Session? session = ...`. |
| `equity_provider.dart:139 always_specify_types` | Use `final FunctionResponse response = ...`. |
| `equity_provider.dart:150 always_specify_types` | Add explicit type to callback/local declaration. |
| `ledger_provider.dart:125 always_specify_types` | Use `final Session? session = ...`. |
| `ledger_provider.dart:133 always_specify_types` | Use `final FunctionResponse response = ...`. |
| `ledger_provider.dart:143 always_specify_types` | Add explicit type to callback/local declaration. |
| `ledger_provider.dart:186 always_specify_types` | Use `final Session? session = ...`. |
| `ledger_provider.dart:194 always_specify_types` | Use `final FunctionResponse response = ...`. |
| `ledger_provider.dart:204 always_specify_types` | Add explicit type to callback/local declaration. |
| `bank_screen.dart:260 require_trailing_commas` | Add trailing comma to the argument/list literal at that callsite. |
| `district_provider.dart:200 deprecated_member_use` | Replace `FutureProviderRef` with `Ref`. |
| `district_provider.dart:224 always_specify_types` | Add explicit type to local declaration. |
| `district_provider.dart:229 always_specify_types` | Add explicit type to local declaration. |
| `district_provider.dart:232 always_specify_types` | Add explicit type to local declaration. |
| `district_provider.dart:233 always_specify_types` | Add explicit type to local declaration. |
| `district_provider.dart:235 always_specify_types` | Add explicit type to local declaration. |
| `district_provider.dart:236 always_specify_types` | Add explicit type to local declaration. |
| `district_provider.dart:256 always_specify_types` | Add explicit type to local declaration. |
| `district_provider.dart:258 always_specify_types` | Add explicit type to local declaration. |
| `district_provider.dart:259 always_specify_types` | Add explicit type to local declaration. |
| `ascension_confirmation_screen.dart:86 unawaited_futures` | Add `unawaited(...)` or `await`. |
| `aurelian_gate_screen.dart:82 use_build_context_synchronously` | After the async gap, guard with `if (!context.mounted) return;` before using that `BuildContext`. |
| `aurelian_gate_screen.dart:91 unawaited_futures` | Add `unawaited(...)` or `await`. |
| `avatar_customizer_screen.dart:221 always_specify_types` | Add explicit type to local declaration. |
| `career_path_screen.dart:60 unawaited_futures` | Add `unawaited(...)` or `await`. |
| `daily_check_in_widget.dart:93 unawaited_futures` | Add `unawaited(...)` or `await`. |
| `supply_chain_provider.dart:38 always_specify_types` | Add explicit type to local declaration. |
| `supply_chain_provider.dart:43 always_specify_types` | Add explicit type to local declaration. |
| `supply_chain_provider.dart:50 always_specify_types` | Add explicit type to local declaration. |
| `supply_chain_provider.dart:65 always_specify_types` | Add explicit type to local declaration. |
| `supply_chain_provider.dart:67 always_specify_types` | Add explicit type to local declaration. |
| `supply_chain_provider.dart:72 always_specify_types` | Add explicit type to local declaration. |
| `supply_chain_provider.dart:105 always_specify_types` | Add explicit type to local declaration. |
| `supply_chain_provider.dart:106 always_specify_types` | Add explicit type to local declaration. |
| `supply_chain_provider.dart:132 always_specify_types` | Add explicit type to local declaration. |
| `supply_chain_provider.dart:137 always_specify_types` | Add explicit type to local declaration. |
| `supply_chain_provider.dart:144 always_specify_types` | Add explicit type to local declaration. |
| `supply_chain_provider.dart:161 always_specify_types` | Add explicit type to local declaration. |
| `supply_chain_provider.dart:163 always_specify_types` | Add explicit type to local declaration. |
| `supply_chain_provider.dart:168 always_specify_types` | Add explicit type to local declaration. |
| `supply_chain_provider.dart:213 always_specify_types` | Add explicit type to local declaration. |
| `casting_provider.dart:96 always_specify_types` | Add explicit type to local declaration. |
| `casting_provider.dart:192 always_specify_types` | Add explicit type to local declaration. |
| `casting_provider.dart:223 always_specify_types` | Add explicit type to local declaration. |
| `casting_provider.dart:224 always_specify_types` | Add explicit type to local declaration. |
| `casting_provider.dart:225 always_specify_types` | Add explicit type to local declaration. |
| `talent_notifier.dart:107 always_specify_types` | Add explicit type to local declaration. |
| `casting_room_screen.dart:354 non_constant_identifier_names` | Rename `CustomPainter` parameter/local to `oldDelegate`. |
| `trend_provider.dart:59 always_specify_types` | Add explicit type to local declaration. |
| `trend_provider.dart:61 always_specify_types` | Add explicit type to local declaration. |
| `trend_provider.dart:64 always_specify_types` | Add explicit type to local declaration. |
| `trend_provider.dart:65 always_specify_types` | Add explicit type to local declaration. |
| `trend_provider.dart:76 always_specify_types` | Add explicit type to local declaration. |
| `trend_provider.dart:77 always_specify_types` | Add explicit type to local declaration. |
| `trend_provider.dart:78 always_specify_types` | Add explicit type to local declaration. |
| `brand_rank_bar.dart:33 always_specify_types` | Add explicit type to local declaration. |

Final static-analysis test:

```bash
dart analyze
flutter analyze
flutter test
```

Expected: `dart analyze` returns 0 issues; `flutter analyze` remains 0 errors.
