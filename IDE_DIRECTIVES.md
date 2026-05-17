# IDE_DIRECTIVES.md

## Audit scope

- Reviewed upload: `/mnt/data/The-Styliste-master (10).zip`
- Static audit only: Flutter/Dart SDKs are not installed in this sandbox, so `flutter analyze`, `flutter test`, `dart run build_runner`, and full compilation could not be executed here.
- Priority order applied: security/credentials → server-authoritative Mogul/economy → schema/model drift → ghost code/TODOs → polish.

---

## Directive 1: Block app entry until Firebase anonymous sign-in and Supabase auth bridge both complete

**Problem:** `lib/app.dart` watches `supabaseBridgeProvider` but does not gate rendering on it. Screens can execute Supabase reads/RPCs before `Supabase.instance.client.auth.currentUser` exists, causing UUID mismatches and null crashes.

**In `lib/app.dart`, replace:**

```dart
final AsyncValue<Object?> anonSignIn =
    ref.watch(firebaseAnonSignInProvider);
ref.watch(supabaseBridgeProvider);
return anonSignIn.when(
  loading: () => const _ObsidianGate(),
  error: (Object e, _) => _ObsidianGate(errorMessage: e.toString()),
  data: (_) => MaterialApp.router(
    title: 'The Styliste',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: ThemeMode.dark,
    routerConfig: AppRouter.router,
  ),
);
```

**With:**

```dart
final AsyncValue<Object?> anonSignIn =
    ref.watch(firebaseAnonSignInProvider);
final AsyncValue<void> supabaseBridge = ref.watch(supabaseBridgeProvider);

return anonSignIn.when(
  loading: () => const _ObsidianGate(),
  error: (Object e, _) => _ObsidianGate(errorMessage: e.toString()),
  data: (_) => supabaseBridge.when(
    loading: () => const _ObsidianGate(),
    error: (Object e, _) => _ObsidianGate(errorMessage: e.toString()),
    data: (_) => MaterialApp.router(
      title: 'The Styliste',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: AppRouter.router,
    ),
  ),
);
```

**Use:** Riverpod async auth gate pattern. Do not render economy/HQ/onboarding routes until Supabase auth is ready.

**Test:**

```bash
flutter analyze
flutter test
```

Manual smoke test: cold launch → anonymous Firebase sign-in → Supabase user exists → onboarding/HQ does not crash.

**Cite:** GDD v6 §1.1 Onboarding Flow; PROJECT_RULES §2 Firebase + Supabase Split, §3 Source of Truth Hierarchy.

---

## Directive 2: Replace Firebase UID usage with Supabase UUID as the active player id

**Problem:** `activeUidProvider` currently exposes Firebase UID. Supabase tables use UUID columns and RLS uses `auth.uid()`. Passing Firebase UID into `.eq('id', uid)` and RPC params breaks UUID casts and can bypass the intended server-authoritative identity model.

**In `lib/core/providers/mock_auth_provider.dart`, replace the entire file with:**

```dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String kMockUid = 'mock-uid-phase1';

final StreamProvider<String?> supabaseUserIdProvider =
    StreamProvider<String?>((Ref<String?> ref) {
  final StreamController<String?> controller = StreamController<String?>();
  controller.add(Supabase.instance.client.auth.currentUser?.id);

  final StreamSubscription<AuthState> subscription =
      Supabase.instance.client.auth.onAuthStateChange.listen((AuthState state) {
    controller.add(state.session?.user.id);
  });

  ref.onDispose(() {
    unawaited(subscription.cancel());
    unawaited(controller.close());
  });

  return controller.stream.distinct();
});

final Provider<String> activeUidProvider = Provider<String>((Ref<String> ref) {
  final AsyncValue<String?> supabaseUid = ref.watch(supabaseUserIdProvider);
  return supabaseUid.maybeWhen(
    data: (String? uid) => uid ?? '',
    orElse: () => Supabase.instance.client.auth.currentUser?.id ?? '',
  );
});
```

If the local Riverpod version rejects typed `Ref<String?>` / `Ref<String>`, use untyped `Ref ref` consistently.

**Use:** Supabase session UUID as the only player id for Supabase tables/RPCs. Firebase UID must only be used to bridge/authenticate, not as a database primary key.

**Test:**

```bash
flutter analyze
rg "FirebaseAuth.instance.currentUser\?\.uid|activeUidProvider" lib
```

Confirm no Supabase query/RPC receives Firebase UID.

**Cite:** PROJECT_RULES §2 Firebase + Supabase Split, §3 Source of Truth Hierarchy; GDD v6 §1.1.

---

## Directive 3: Add auth guards to player-scoped Supabase RPCs and revoke unsafe direct economy mutation

**Problem:** Multiple `SECURITY DEFINER` RPCs accept `p_player_id`, `p_user_id`, `p_buyer_id`, or `p_seller_id` without proving the caller owns that UUID. This allows cross-player mutation if the function is callable by `authenticated`.

**Create `supabase/migrations/020_security_hardening.sql` with:**

```sql
-- Security hardening: player-scoped RPC guard helpers and dangerous grant removal.

CREATE OR REPLACE FUNCTION public.assert_self(p_player_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL OR auth.uid() <> p_player_id THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;
END;
$$;

REVOKE ALL ON FUNCTION public.assert_self(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.assert_self(UUID) TO authenticated, service_role;

-- Client must not directly mint currency, inventory, Luxe, or arbitrary mini-game rewards.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'add_inventory') THEN
    REVOKE EXECUTE ON FUNCTION public.add_inventory(UUID, TEXT, INTEGER) FROM authenticated;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'verify_and_grant_luxe') THEN
    REVOKE EXECUTE ON FUNCTION public.verify_and_grant_luxe(UUID, TEXT, TEXT, TEXT, TEXT, NUMERIC, INTEGER) FROM authenticated;
    GRANT EXECUTE ON FUNCTION public.verify_and_grant_luxe(UUID, TEXT, TEXT, TEXT, TEXT, NUMERIC, INTEGER) TO service_role;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'record_failed_transaction') THEN
    REVOKE EXECUTE ON FUNCTION public.record_failed_transaction(UUID, TEXT, TEXT, NUMERIC, TEXT) FROM authenticated;
    GRANT EXECUTE ON FUNCTION public.record_failed_transaction(UUID, TEXT, TEXT, NUMERIC, TEXT) TO service_role;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'increment_luxe_trust') THEN
    REVOKE EXECUTE ON FUNCTION public.increment_luxe_trust(UUID, INTEGER) FROM authenticated;
    GRANT EXECUTE ON FUNCTION public.increment_luxe_trust(UUID, INTEGER) TO service_role;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'trigger_scandal') THEN
    REVOKE EXECUTE ON FUNCTION public.trigger_scandal(UUID, TEXT, TEXT, INTEGER) FROM authenticated;
    GRANT EXECUTE ON FUNCTION public.trigger_scandal(UUID, TEXT, TEXT, INTEGER) TO service_role;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_global_trend_tsunami') THEN
    REVOKE EXECUTE ON FUNCTION public.calculate_global_trend_tsunami() FROM authenticated;
    GRANT EXECUTE ON FUNCTION public.calculate_global_trend_tsunami() TO service_role;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'inject_capital_bonus') THEN
    REVOKE EXECUTE ON FUNCTION public.inject_capital_bonus(UUID, NUMERIC) FROM authenticated;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'apply_idle_multiplier') THEN
    REVOKE EXECUTE ON FUNCTION public.apply_idle_multiplier(UUID, INTEGER, INTEGER) FROM authenticated;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'reset_talent_stamina') THEN
    REVOKE EXECUTE ON FUNCTION public.reset_talent_stamina(UUID, TEXT) FROM authenticated;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'apply_logistics_discount') THEN
    REVOKE EXECUTE ON FUNCTION public.apply_logistics_discount(UUID, INTEGER, INTEGER) FROM authenticated;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'halt_supply_chain') THEN
    REVOKE EXECUTE ON FUNCTION public.halt_supply_chain(UUID, INTEGER) FROM authenticated;
  END IF;
END $$;
```

**Then patch each existing player-scoped RPC body immediately after `BEGIN`:**

```sql
PERFORM public.assert_self(p_player_id);
```

Apply the matching param name per function:

- `execute_sovereign_genesis` → `PERFORM public.assert_self(p_user_id);`
- `unlock_joint_venture` → `PERFORM public.assert_self(p_player_id);`
- `execute_memorialization` → `PERFORM public.assert_self(p_player_id);`
- `get_sovereign_multiplier` → `PERFORM public.assert_self(p_player_id);`
- `apply_kintsugi_repair` → `PERFORM public.assert_self(p_player_id);`
- `apply_public_apology` → `PERFORM public.assert_self(p_player_id);`
- `execute_casting_pull` → `PERFORM public.assert_self(p_player_id);`
- `get_player_roster` → `PERFORM public.assert_self(p_player_id);`
- `execute_archive_purchase` → `PERFORM public.assert_self(p_buyer_id);`
- `list_on_archive` → `PERFORM public.assert_self(p_seller_id);`
- `execute_liquidation` → `PERFORM public.assert_self(p_player_id);`
- `upgrade_logistics` → `PERFORM public.assert_self(p_player_id);`
- `process_idle_income` → `PERFORM public.assert_self(p_player_id);`
- `record_check_in` → `PERFORM public.assert_self(p_player_id);`
- `register_fcm_token` → `PERFORM public.assert_self(p_player_id);`
- `claim_daily_reward` → `PERFORM public.assert_self(p_player_id);`

**Patch `attempt_district_takeover` with maison membership authorization instead of self-check:**

```sql
IF NOT EXISTS (
  SELECT 1
  FROM public.maison_members
  WHERE maison_id = p_attacker_maison_id
    AND player_id = auth.uid()
    AND role IN ('founder', 'executive_director')
) THEN
  RAISE EXCEPTION 'Unauthorized';
END IF;
```

**Use:** Supabase RLS + `SECURITY DEFINER` ownership assertion. Client must never pass arbitrary player ids to mutate economy.

**Test:**

```bash
supabase db reset
supabase test db
```

Manual SQL test: create two authenticated users; user A must fail when calling any listed RPC with user B’s UUID.

**Cite:** PROJECT_RULES §3 Source of Truth Hierarchy, §4 Forbidden Patterns; GDD v6 §3.3 Idle Progression, §5.5 Equity System, §6.3 Maisons, §8.9.2 Crisis Management.

---

## Directive 4: Standardize idle revenue column to `idle_revenue_per_hour`

**Problem:** Schema/code drift exists between `brand_state.revenue_idle`, `brand_state.idle_revenue_per_hour`, `Brand.idleRevenuePerHour`, `execute_sovereign_genesis`, and `calculate-idle-income`. This can break idle economy calculation and onboarding.

**If the database is not deployed yet:**

- In `supabase/migrations/001_initial_schema.sql`, replace every `revenue_idle` column definition/reference with `idle_revenue_per_hour`.
- In `supabase/migrations/014_supply_chain.sql`, remove the duplicate `ADD COLUMN IF NOT EXISTS idle_revenue_per_hour` if it becomes redundant.

**If the database may already be deployed, add this to a new migration instead:**

```sql
ALTER TABLE public.brand_state
  ADD COLUMN IF NOT EXISTS idle_revenue_per_hour NUMERIC(14,2) NOT NULL DEFAULT 0;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'brand_state'
      AND column_name = 'revenue_idle'
  ) THEN
    EXECUTE '
      UPDATE public.brand_state
      SET idle_revenue_per_hour = CASE
        WHEN idle_revenue_per_hour = 0 THEN COALESCE(revenue_idle, 0)
        ELSE idle_revenue_per_hour
      END
    ';
  END IF;
END $$;
```

**In `supabase/functions/calculate-idle-income/index.ts`, replace all:**

```ts
revenue_idle
```

**With:**

```ts
idle_revenue_per_hour
```

Also update the row interface and calculations:

```ts
interface BrandStateRow {
  idle_revenue_per_hour: number;
  last_active_at: string;
  current_cap_soft: number;
}

const baseRate = Number(brandState.idle_revenue_per_hour);
```

**Use:** Server-authoritative idle economy. Keep client UI read-only for idle income math.

**Test:**

```bash
supabase db reset
supabase functions serve calculate-idle-income
```

Manual test: set `idle_revenue_per_hour = 120`; simulate two hours offline; payout must respect GDD soft cap.

**Cite:** GDD v6 §3.3 Idle Progression Mechanics, §3.4 Idle Soft Cap Mechanics; PROJECT_RULES §3.

---

## Directive 5: Fix `019_luxe_trust_score.sql` crisis column drift

**Problem:** `supabase/migrations/019_luxe_trust_score.sql` patches `apply_kintsugi_repair` using `tarnish_level`, but `010_crisis_engine.sql` defines `current_tarnish`. The function will fail once executed.

**In `supabase/migrations/019_luxe_trust_score.sql`, replace every:**

```sql
tarnish_level
```

**With:**

```sql
current_tarnish
```

Specifically verify the function uses:

```sql
SELECT total_revenue, current_tarnish, kintsugi_level
INTO v_current_revenue, v_current_tarnish, v_kintsugi_level
FROM public.brand_state
WHERE player_id = p_player_id;
```

and:

```sql
UPDATE public.brand_state
SET total_revenue = total_revenue - v_cost,
    current_tarnish = 0,
    kintsugi_level = kintsugi_level + 1,
    luxe_trust_score = GREATEST(0, luxe_trust_score - 10)
WHERE player_id = p_player_id;
```

**Use:** Existing crisis schema; no new duplicate tarnish column.

**Test:**

```bash
supabase db reset
```

Manual RPC test: call `apply_kintsugi_repair` after setting `current_tarnish > 0`; verify tarnish resets and Luxe Trust penalty applies.

**Cite:** GDD v6 §8.9.2 Crisis Management.

---

## Directive 6: Fix Talent table drift between `player_roster` and `player_talent_roster`

**Problem:** `017_mini_game_rewards.sql` and `lib/features/talent/providers/talent_notifier.dart` reference `player_talent_roster`, but migrations create `player_roster`. `reset_talent_stamina` also expects stamina columns that do not exist.

**Create a migration `supabase/migrations/021_talent_roster_hardening.sql` with:**

```sql
ALTER TABLE public.player_roster
  ADD COLUMN IF NOT EXISTS stamina INTEGER NOT NULL DEFAULT 100 CHECK (stamina BETWEEN 0 AND 100),
  ADD COLUMN IF NOT EXISTS morale INTEGER NOT NULL DEFAULT 100 CHECK (morale BETWEEN 0 AND 100),
  ADD COLUMN IF NOT EXISTS last_stamina_refresh TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS gala_cooldown_until TIMESTAMPTZ;
```

**In `lib/features/talent/providers/talent_notifier.dart`, replace:**

```dart
.from('player_talent_roster')
```

**With:**

```dart
.from('player_roster')
```

**In `supabase/migrations/017_mini_game_rewards.sql`, rewrite `reset_talent_stamina` to target `player_roster` and guard ownership:**

```sql
CREATE OR REPLACE FUNCTION public.reset_talent_stamina(
  p_player_id UUID,
  p_talent_id TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_updated_count INTEGER;
BEGIN
  PERFORM public.assert_self(p_player_id);

  UPDATE public.player_roster
  SET stamina = 100,
      last_stamina_refresh = now()
  WHERE player_id = p_player_id
    AND talent_id::TEXT = p_talent_id;

  GET DIAGNOSTICS v_updated_count = ROW_COUNT;

  IF v_updated_count = 0 THEN
    RETURN json_build_object('success', false, 'error', 'Talent not found');
  END IF;

  RETURN json_build_object('success', true, 'stamina', 100);
END;
$$;
```

**Use:** Single canonical roster table.

**Test:**

```bash
supabase db reset
flutter analyze
```

Manual test: pull talent → roster row exists → apply stamina reset reward → `player_roster.stamina = 100`.

**Cite:** GDD v6 §8.10 Talent Management, §6.9 Aurelian Gala.

---

## Directive 7: Implement or remove missing `execute_power_move` RPC

**Problem:** `lib/features/hq/widgets/hq_architect_view.dart` and `lib/features/hq/widgets/hq_artisan_view.dart` call `rpc('execute_power_move')`, but no migration defines that function. This is runtime-dead UI.

**Create `supabase/migrations/022_execute_power_move.sql` with a minimal server-authoritative implementation:**

```sql
CREATE OR REPLACE FUNCTION public.execute_power_move(
  p_player_id UUID,
  p_move_key TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_cost NUMERIC := 0;
  v_effect JSONB := '{}'::jsonb;
BEGIN
  PERFORM public.assert_self(p_player_id);

  CASE p_move_key
    WHEN 'public_apology' THEN
      SELECT (public.apply_public_apology(p_player_id))->>'cost'
      INTO v_cost;
      v_effect := jsonb_build_object('crisis_reduction', 25);
    ELSE
      RAISE EXCEPTION 'Unknown power move: %', p_move_key;
  END CASE;

  RETURN json_build_object(
    'success', true,
    'move_key', p_move_key,
    'cost', COALESCE(v_cost, 0),
    'effect', v_effect
  );
END;
$$;

REVOKE ALL ON FUNCTION public.execute_power_move(UUID, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.execute_power_move(UUID, TEXT) TO authenticated;
```

Then update both HQ widgets so only supported `p_move_key` values are passed. Remove any button whose backend effect is not implemented.

**Use:** Server-authoritative HQ actions. No client-only Power Move effects.

**Test:**

```bash
supabase db reset
flutter analyze
```

Manual test: press Public Apology in HQ → RPC returns success → brand state updates through server function only.

**Cite:** GDD v6 §3.0 Main HQ Dashboard, §8.9.2 Crisis Management.

---

## Directive 8: Fix system feed posts and FCM notification backend drift

**Problem A:** `supabase/functions/eclipse-event-tick/index.ts` inserts `feed_posts.player_id = null`, but `feed_posts.player_id` is `NOT NULL`.

**Add migration `supabase/migrations/023_system_feed_posts.sql`:**

```sql
ALTER TABLE public.feed_posts
  ALTER COLUMN player_id DROP NOT NULL,
  ADD COLUMN IF NOT EXISTS is_system BOOLEAN NOT NULL DEFAULT false;

DROP POLICY IF EXISTS "Users can create feed posts" ON public.feed_posts;

CREATE POLICY "Users can create own feed posts"
ON public.feed_posts
FOR INSERT
TO authenticated
WITH CHECK (player_id = auth.uid() AND is_system = false);
```

**In `supabase/functions/eclipse-event-tick/index.ts`, set system posts explicitly:**

```ts
await supabase.from('feed_posts').insert({
  player_id: null,
  is_system: true,
  content: announcement,
  hype_score: 0,
});
```

**Problem B:** `supabase/functions/send-fcm-notification/index.ts` queries `districts`, but the schema table is `fashion_districts`; it also returns `placeholder_token`.

**In `supabase/functions/send-fcm-notification/index.ts`, replace:**

```ts
.from('districts')
```

**With:**

```ts
.from('fashion_districts')
```

**Replace the placeholder-token path with a real token lookup:**

```ts
async function getPlayerFCMTokens(playerId: string): Promise<string[]> {
  const { data, error } = await supabase
    .from('fcm_tokens')
    .select('token')
    .eq('player_id', playerId);

  if (error) {
    throw error;
  }

  return (data ?? [])
    .map((row: { token: string }) => row.token)
    .filter((token: string) => token.length > 0);
}
```

If no tokens exist, return a 204-style success payload and do not attempt FCM send.

**Use:** Service-role Edge Function for system notifications; no placeholder notification path.

**Test:**

```bash
supabase functions serve eclipse-event-tick
supabase functions serve send-fcm-notification
```

Manual test: trigger district takeover → notification function resolves `fashion_districts` and real `fcm_tokens` rows.

**Cite:** GDD v6 §6.1 Global Live Feed, §7.2 Fashion Events.

---

## Directive 9: Fix Supabase JSON serialization drift in Freezed models

**Problem:** Many generated `*.g.dart` files read camelCase JSON keys, while Supabase returns snake_case columns. This silently nulls fields or breaks parsing for domain rows.

**In these Freezed model files, add or verify:**

```dart
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
```

Apply to:

- `lib/domain/models/design.dart`
- `lib/domain/models/store.dart`
- `lib/domain/models/campaign.dart`
- `lib/domain/models/equity.dart`
- `lib/domain/models/maison.dart`
- `lib/domain/models/supplier.dart`
- `lib/domain/models/feed_post.dart`
- `lib/features/archive/models/archive_models.dart`
- `lib/features/check_in/models/check_in_models.dart`
- `lib/features/gala/models/gala_models.dart`
- `lib/features/maison/models/fashion_district.dart`
- `lib/features/onboarding/models/sovereign_statue.dart`
- `lib/features/supply_chain/models/supply_chain_models.dart`
- `lib/features/talent/models/talent.dart`
- `lib/features/trends/models/trend_tsunami.dart`
- `lib/features/vex/models/vex_review.dart`

**In `lib/domain/models/design.dart`, replace typo field:**

```dart
int hypoScore
```

**With:**

```dart
int hypeScore
```

Then regenerate all Freezed/JSON code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Use:** Supabase snake_case row mapping. Do not manually map snake_case in repositories unless the model is intentionally not a database row.

**Test:**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
rg "json\['[a-z]+[A-Z]" lib -g "*.g.dart"
```

Investigate every remaining camelCase generated key. Only client-only DTOs may remain camelCase.

**Cite:** PROJECT_RULES §3 Source of Truth Hierarchy; GDD v6 §4.1 Atelier UI, §5.1 Supply Chain Logistics, §6.3 Maisons, §8.10 Talent Management.

---

## Directive 10: Fix onboarding enum API values before calling `execute_sovereign_genesis`

**Problem:** `AscensionConfirmationScreen` sends enum `.name`, producing `newYork`, `highLuxury`, and `midLuxury`. `execute_sovereign_genesis` validates snake_case values such as `new_york` and `high_luxury`.

**In `lib/domain/models/player.dart`, add:**

```dart
extension CareerPathApi on CareerPath {
  String get apiValue => switch (this) {
        CareerPath.designer => 'designer',
        CareerPath.mogul => 'mogul',
      };
}

extension HqCityApi on HqCity {
  String get apiValue => switch (this) {
        HqCity.newYork => 'new_york',
        HqCity.paris => 'paris',
        HqCity.tokyo => 'tokyo',
        HqCity.milan => 'milan',
      };
}
```

**In `lib/core/providers/onboarding_provider.dart`, add:**

```dart
extension MarketTierApi on MarketTier {
  String get apiValue => switch (this) {
        MarketTier.highLuxury => 'high_luxury',
        MarketTier.midLuxury => 'mid_luxury',
        MarketTier.massMarket => 'mass_market',
      };
}
```

**In `lib/features/onboarding/screens/ascension_confirmation_screen.dart`, replace:**

```dart
'p_career_path': state.selectedPath!.name,
'p_city': state.selectedCity!.name,
'p_market_tier': state.selectedTier!.name,
```

**With:**

```dart
'p_career_path': state.selectedPath!.apiValue,
'p_city': state.selectedCity!.apiValue,
'p_market_tier': state.selectedTier!.apiValue,
```

**Use:** Explicit API values for DB/RPC params. Do not depend on Dart enum `.name` for persisted values.

**Test:**

```bash
flutter analyze
```

Manual test: select New York + High Luxury → RPC receives `new_york` and `high_luxury` → player and brand rows are created.

**Cite:** GDD v6 §1.1 Onboarding Flow — The Aurelian Sanctuary.

---

## Directive 11: Fix `Player.toJson` and sovereign multiplier display bug

**Problem A:** `Player.toJson` manually serializes enum `.name`, which conflicts with snake_case DB values for `hq_city`.

**In `lib/domain/models/player.dart`, replace the manual `toJson()` body with generated serialization:**

```dart
factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
Map<String, dynamic> toJson() => _$PlayerToJson(this);
```

Ensure enum fields use `@JsonValue` annotations or converters so DB values remain snake_case.

**Problem B:** `sovereignMultiplierDisplay` has an operator precedence bug.

**Replace:**

```dart
String get sovereignMultiplierDisplay => 
    '+${(sovereignMultiplierBonus - 1.0) * 100.toInt()}%';
```

**With:**

```dart
String get sovereignMultiplierDisplay =>
    '+${((sovereignMultiplierBonus - 1.0) * 100).toInt()}%';
```

**Use:** Generated JSON and explicit enum conversion.

**Test:**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

Manual test: a multiplier of `1.25` displays `+25%`.

**Cite:** GDD v6 §3.5 Aurelian Ascension.

---

## Directive 12: Replace client-controlled mini-game reward amounts with server-authoritative claims

**Problem:** Mini-game screens generate outcomes with client `Random()` and then call reward RPCs with arbitrary player ids/amounts/durations. This violates server-authoritative economy rules and is exploitable.

**In these files, remove direct reward RPC calls and route all rewards through one server-authoritative claim endpoint:**

- `lib/features/mini_games/screens/supplier_raid_screen.dart`
- `lib/features/mini_games/screens/flash_sale_screen.dart`
- Any screen calling `inject_capital_bonus`, `apply_idle_multiplier`, `apply_logistics_discount`, `halt_supply_chain`, or `reset_talent_stamina`

**Create a new Edge Function `supabase/functions/claim-mini-game-reward/index.ts`:**

```ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const supabase = createClient(supabaseUrl, serviceRoleKey);

Deno.serve(async (req: Request) => {
  const authHeader = req.headers.get('Authorization') ?? '';
  const token = authHeader.replace('Bearer ', '');
  const { data: userData, error: userError } = await supabase.auth.getUser(token);

  if (userError || !userData.user) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 });
  }

  const { game_key: gameKey, result_key: resultKey } = await req.json();
  const playerId = userData.user.id;

  const rewardTable: Record<string, Record<string, { currency: number }>> = {
    supplier_raid: {
      standard_win: { currency: 250 },
      perfect_win: { currency: 500 },
    },
    flash_sale: {
      standard_win: { currency: 150 },
      perfect_win: { currency: 300 },
    },
  };

  const reward = rewardTable[gameKey]?.[resultKey];
  if (!reward) {
    return new Response(JSON.stringify({ error: 'Invalid reward' }), { status: 400 });
  }

  const { error } = await supabase.rpc('process_idle_income', {
    p_player_id: playerId,
    p_amount: reward.currency,
  });

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 400 });
  }

  return new Response(JSON.stringify({ success: true, reward }), { status: 200 });
});
```

If `process_idle_income` does not accept direct amount claims, create a dedicated guarded RPC for mini-game rewards. Do not reuse unrestricted `add_inventory`.

**Use:** Server-defined reward table. Client may report result key only; server decides payout.

**Test:**

```bash
supabase functions serve claim-mini-game-reward
flutter analyze
```

Manual tamper test: alter request payload to claim invalid high reward → server returns 400 and no economy mutation occurs.

**Cite:** PROJECT_RULES §3 and §4; GDD v6 §3.8 F2P Progression Strategies, §5.1 Supply Chain Logistics.

---

## Directive 13: Replace mocked bank chart data with server ledger data

**Problem:** `lib/features/ledger/screens/bank_screen.dart` uses mocked 7-day chart data. This is ghost economy UI and can mislead players.

**In `lib/features/ledger/screens/bank_screen.dart`, remove mocked chart generation and read from a Supabase daily ledger view.**

**Create migration `supabase/migrations/024_daily_revenue_view.sql`:**

```sql
CREATE OR REPLACE VIEW public.daily_revenue_ledger AS
SELECT
  player_id,
  date_trunc('day', created_at)::date AS revenue_date,
  SUM(amount) AS revenue_total
FROM public.idle_income_log
GROUP BY player_id, date_trunc('day', created_at)::date;

GRANT SELECT ON public.daily_revenue_ledger TO authenticated;
```

**Add RLS-safe client query:**

```dart
final String playerId = ref.watch(activeUidProvider);
final List<dynamic> rows = await Supabase.instance.client
    .from('daily_revenue_ledger')
    .select()
    .eq('player_id', playerId)
    .order('revenue_date', ascending: true)
    .limit(7);
```

**Use:** Ledger-derived finance visuals only. No mock revenue chart in production UI.

**Test:**

```bash
flutter analyze
supabase db reset
```

Manual test: create three `idle_income_log` rows → bank chart renders only those dates/totals.

**Cite:** GDD v6 §5.1 Supply Chain Logistics, §3.3 Idle Progression Mechanics.

---

## Directive 14: Complete player reporting flow

**Problem:** `lib/features/reporting/widgets/report_modal.dart` is placeholder-level, but GDD requires player reporting in three taps or fewer, backend submission, and anti-abuse support.

**In `lib/features/reporting/widgets/report_modal.dart`, implement a modal that writes to `player_reports`:**

```dart
await Supabase.instance.client.from('player_reports').insert(<String, dynamic>{
  'reporter_id': Supabase.instance.client.auth.currentUser!.id,
  'reported_player_id': reportedPlayerId,
  'category': selectedCategory,
  'description': descriptionController.text.trim(),
});
```

Add category buttons: `harassment`, `hate`, `spam`, `cheating`, `inappropriate_content`, `other`.

After submit, show a non-blocking success state and close the modal. Do not expose reporter identity in client UI.

**Use:** Supabase insert under RLS. Keep the flow at three taps: open → category → submit.

**Test:**

```bash
flutter analyze
```

Manual test: report a player → `player_reports` row exists → duplicate spam is rate-limited by backend policy if configured.

**Cite:** GDD v6 §6.10 Player Reporting and Safety.

---

## Directive 15: Remove or route ghost navigation constants and dead bottom nav

**Problem:** `AppRouter` declares routes such as `events`, `profile`, `crisisStatus`, `galaLeaderboard`, `galaSubmit`, and `onboardingSpecialization` without complete route wiring. `BottomNav` appears superseded by `MainShell` and can become dead code.

**In `lib/core/router/app_router.dart`:**

- Add `GoRoute`s for every declared route constant that has a real screen.
- Delete constants for screens not implemented.
- Ensure route names used by widgets exist in `AppRouter.router`.

**In `lib/core/widgets/bottom_nav.dart`:**

- Delete the file if `MainShell` is the only shell navigation implementation.
- Otherwise wire it into `MainShell` and remove the duplicate `_FloatingNavBar` implementation.

**Use:** One navigation source of truth. No route constants without routes.

**Test:**

```bash
flutter analyze
rg "AppRoutes\." lib
```

Manual route test: tap each bottom-nav item and each deep-linking button; no unknown route errors.

**Cite:** GDD v6 §3.0 Main HQ Dashboard, §3.6 Accessibility & Progressive Complexity.

---

## Directive 16: Replace `print` and production debug leakage

**Problem:** `analysis_options.yaml` enables `avoid_print`, but code still uses `print` in auth/Firebase paths. Debug token logs can leak sensitive setup data if misbuilt.

**In `lib/core/providers/auth_provider.dart`, replace all `print(...)` calls with:**

```dart
if (kDebugMode) {
  debugPrint('message');
}
```

Add imports where needed:

```dart
import 'package:flutter/foundation.dart';
```

**In `lib/core/services/firebase_service.dart`, ensure App Check debug token logging is debug-only and never compiled into release behavior:**

```dart
if (kDebugMode) {
  debugPrint('Firebase App Check debug provider active for local development.');
}
```

Do not print raw App Check debug tokens in app logs.

**Use:** Flutter `debugPrint` gated by `kDebugMode`; no `print`.

**Test:**

```bash
flutter analyze
rg "\bprint\(" lib
```

**Cite:** PROJECT_RULES §1 Non-Negotiable Constraints, §5 Quality Gates.

---

## Directive 17: Add missing platform auth mapping table or remove unused cloud-save auth service

**Problem:** `lib/core/services/auth_service.dart` references `platform_auth_mappings`, but no migration creates that table. `_restoreSession` is placeholder-like and the service can mislead future implementation.

**Option A — implement the table. Create `supabase/migrations/025_platform_auth_mappings.sql`:**

```sql
CREATE TABLE IF NOT EXISTS public.platform_auth_mappings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  platform TEXT NOT NULL CHECK (platform IN ('play_games', 'game_center')),
  platform_user_id TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(platform, platform_user_id),
  UNIQUE(player_id, platform)
);

ALTER TABLE public.platform_auth_mappings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own platform mappings"
ON public.platform_auth_mappings
FOR SELECT
TO authenticated
USING (player_id = auth.uid());

CREATE POLICY "Users can insert own platform mappings"
ON public.platform_auth_mappings
FOR INSERT
TO authenticated
WITH CHECK (player_id = auth.uid());
```

**Option B — if platform cloud save is not shipping in this milestone:**

- Remove `lib/core/services/auth_service.dart`.
- Remove all providers/imports referencing it.
- Remove `games_services` usage until implemented.

**Use:** No table references without migrations.

**Test:**

```bash
supabase db reset
flutter analyze
rg "platform_auth_mappings|AuthService" lib supabase
```

**Cite:** GDD v6 §3.6 Accessibility & Progressive Complexity; PROJECT_RULES §5 Quality Gates.

---

## Directive 18: Update `.env.json.example` to match required `--dart-define` keys

**Problem:** `.env.json.example` only lists Supabase keys, but `FirebaseService.currentPlatformOptions` requires multiple Firebase `String.fromEnvironment` values. New devs will fail bootstrapping.

**In `.env.json.example`, replace contents with:**

```json
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_ANON_KEY": "your-supabase-anon-key",
  "FIREBASE_ANDROID_API_KEY": "your-android-api-key",
  "FIREBASE_ANDROID_APP_ID": "your-android-app-id",
  "FIREBASE_IOS_API_KEY": "your-ios-api-key",
  "FIREBASE_IOS_APP_ID": "your-ios-app-id",
  "FIREBASE_MESSAGING_SENDER_ID": "your-sender-id",
  "FIREBASE_PROJECT_ID": "your-project-id",
  "FIREBASE_STORAGE_BUCKET": "your-project.appspot.com",
  "PLAY_GAMES_CLIENT_ID": "your-play-games-client-id"
}
```

**Use:** Environment-driven platform config only.

**Test:**

```bash
flutter run --dart-define-from-file=.env.json
```

**Cite:** PROJECT_RULES §1 Non-Negotiable Constraints, §2 Firebase + Supabase Split.

---

## Directive 19: Replace TODO/placeholder UI with shippable disabled states or remove it from routes

**Problem:** Placeholder surfaces exist in AR, events, world map, profile, reporting, Luxe, and notification code. Shipping placeholders violates the project quality gate.

**Search and fix all matches:**

```bash
rg -n "TODO|placeholder|mock|sample|stub|not implemented|coming soon" lib supabase
```

For each result:

- If the feature is in the current milestone: implement the server-backed behavior.
- If the feature is not in the current milestone: remove route access and show no production entry point.
- If the UI must remain visible: show a server-backed disabled state with copy that does not imply fake progress or fake rewards.

High-priority files found in the static audit:

- `lib/features/world_map/screens/world_map_screen.dart`
- `lib/features/events/screens/events_screen.dart`
- `lib/features/profile/screens/profile_screen.dart`
- `lib/features/reporting/widgets/report_modal.dart`
- `lib/features/ar/screens/ar_runway_screen.dart`
- `lib/features/gala/screens/gala_submission_screen.dart`
- `supabase/functions/send-fcm-notification/index.ts`
- `supabase/functions/trend-decay/index.ts`

**Use:** No ghost code; no fake backend.

**Test:**

```bash
flutter analyze
rg -n "TODO|placeholder|mock|sample|stub|not implemented|coming soon" lib supabase
```

Every remaining hit must be annotated with `// AI_UNCERTAINTY:` and linked to a tracked task.

**Cite:** PROJECT_RULES §4 Forbidden Patterns, §5 Quality Gates; VERIFICATION_PROTOCOL §3.

---

## Directive 20: Enforce portrait-first and 60fps-safe Atelier physics

**Problem:** GDD requires tactile Atelier manipulation and 60fps. Any physics/drag/shader implementation must avoid rebuild-heavy patterns and unbounded per-frame work.

**In Atelier widgets/services, enforce:**

- Use `CustomPainter` or isolated render widgets for cloth/Verlet previews.
- Use `RepaintBoundary` around interactive canvas sections.
- Avoid `setState` for every particle if Riverpod/global state is involved.
- Keep Supabase writes out of drag/tick loops; persist only on confirmed design save.
- Lock mobile orientation to portrait in app startup if not already configured.

**Add to `lib/main.dart` before `runApp`:**

```dart
await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
  DeviceOrientation.portraitUp,
]);
```

Add imports if missing:

```dart
import 'package:flutter/services.dart';
```

**Use:** 60fps local rendering; server-authoritative persistence only on save.

**Test:**

```bash
flutter analyze
flutter run --profile
```

Manual profile test: Atelier drag must stay near 16ms/frame on low-end Android.

**Cite:** GDD v6 §4.1 Atelier UI, §4.2 Atelier Physics Simulation; PROJECT_RULES §1 Non-Negotiable Constraints.
