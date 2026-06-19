# IDE_DIRECTIVES.md — Security Hardening Audit Pass 1

> **Scope**: Automated fixes and refactors that can be applied directly in-IDE.
> **Priority**: security/creds/RLS > Vex Reveal > sound > polish > new systems.
> **Rule**: No code changes were made during the audit read — all items below are queued directives.

---

## CRITICAL — Fix Before Any Public Build

### SEC-01 · `trend-decay` Edge Function Has No Auth Guard

**File**: `supabase/functions/trend-decay/index.ts`
**Risk**: HIGH — This function uses `SUPABASE_SERVICE_ROLE_KEY` but accepts **any** HTTP request with zero authentication. An attacker can invoke it manually via `curl` to decay all player heat scores at will.

**Fix**: Add the `x-cron-secret` header check (identical pattern to `eclipse-event-tick`):
```diff
 serve(async (_req: Request): Promise<Response> => {
+  // ── Auth: Cron-secret header gate ───────────────────────────────────────
+  const cronSecret = _req.headers.get("x-cron-secret");
+  const expected = Deno.env.get("CRON_SECRET");
+  if (!expected || cronSecret !== expected) {
+    return new Response(JSON.stringify({ error: "Unauthorized" }), {
+      status: 401,
+      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
+    });
+  }
+
   try {
```

---

### SEC-02 · `send-fcm-notification` Webhook Secret Check is Conditional

**File**: `supabase/functions/send-fcm-notification/index.ts` (lines 66–71)
**Risk**: HIGH — The webhook secret check uses `if (expectedSecret && ...)` meaning if `WEBHOOK_SECRET` is not set in the environment, the function silently passes **all** requests unauthenticated. This turns a "fail-open" misconfiguration into a free notification spammer.

**Fix**: Fail closed when the secret is missing:
```diff
-    if (expectedSecret && webhookSecret !== expectedSecret) {
-      return new Response('Unauthorized', { status: 401 });
-    }
+    if (!expectedSecret) {
+      console.error("WEBHOOK_SECRET not configured — rejecting request.");
+      return new Response('Server misconfigured', { status: 500 });
+    }
+    if (webhookSecret !== expectedSecret) {
+      return new Response('Unauthorized', { status: 401 });
+    }
```

---

### SEC-03 · `talent_notifier.dart` Direct Client-Side DB Write

**File**: `lib/features/talent/providers/talent_notifier.dart` (lines 124–131)
**Risk**: MEDIUM — On a staff rally **loss**, the notifier writes `gala_cooldown_until` directly to `player_roster` via the Supabase client. If RLS allows this UPDATE, a player could forge a shorter cooldown by modifying the request payload. The **win** path correctly routes through the `claim-mini-game-reward` edge function.

**Fix**: Route the loss path through the same edge function (or a dedicated server RPC):
```dart
// Instead of:
await supabase
    .from('player_roster')
    .update({'gala_cooldown_until': cooldownUntil.toIso8601String()})
    .eq('player_id', userId)
    .eq('talent_id', talentId);

// Use:
await SupabaseService.invokeFunction('claim-mini-game-reward', body: {
  'game_key': 'staff_rally',
  'result_key': 'cooldown_loss',
  'talent_id': talentId,
});
```
Then handle `cooldown_loss` in the `claim-mini-game-reward` edge function server-side.

---

### SEC-04 · `report_modal.dart` Direct Client-Side INSERT

**File**: `lib/features/reporting/widgets/report_modal.dart` (lines 46–55)
**Risk**: MEDIUM — The report modal inserts directly into `player_reports` from the client. This is acceptable **only if** the `player_reports` table has strict RLS:
- INSERT: `auth.uid() = reporter_id` (so users can't forge reports from other accounts)
- SELECT: denied for `authenticated` role (reporters shouldn't read the reports table)
- UPDATE/DELETE: denied for `authenticated` role

**Action**: Verify the RLS policy on `player_reports`. If no INSERT policy exists, add one:
```sql
CREATE POLICY "players_can_report"
  ON public.player_reports FOR INSERT
  TO authenticated
  WITH CHECK (reporter_id = auth.uid());
```

---

### SEC-05 · `supabase_feed_repository.dart` Direct Client-Side INSERT

**File**: `lib/data/repositories/supabase_feed_repository.dart` (line 42)
**Risk**: MEDIUM — Feed posts are inserted directly from the client. The `drop-design` edge function handles the design->feed pipeline server-side, but this repository also has a direct `.insert()` path. Confirm this path is either:
1. Dead code from an earlier phase (remove it), or
2. Protected by RLS that enforces `auth.uid() = player_id`

---

### SEC-06 · `auth_service.dart` Direct INSERT into `platform_auth_mappings`

**File**: `lib/core/services/auth_service.dart` (line 132)
**Risk**: LOW — This insert maps a platform identifier (Game Center/Play Games) to a Supabase UUID during auth linkage. Acceptable if RLS restricts INSERT to `auth.uid() = player_id` and prevents updates/deletes.

**Action**: Verify RLS on `platform_auth_mappings`:
```sql
CREATE POLICY "player_can_link_own_account"
  ON public.platform_auth_mappings FOR INSERT
  TO authenticated
  WITH CHECK (player_id = auth.uid());
```

---

## HIGH — Harden Before Beta

### SEC-07 · `supabase/config.toml` — Anonymous Sign-Ins Enabled

**File**: `supabase/config.toml` (line 173)
**Risk**: MEDIUM — `enable_anonymous_sign_ins = true` allows unauthenticated users to create anonymous sessions. If any RLS policy uses `auth.uid()` without checking `auth.jwt()->>'is_anonymous'`, anonymous users get the same permissions as real players.

**Fix** (if anonymous users should not play the game):
```diff
- enable_anonymous_sign_ins = true
+ enable_anonymous_sign_ins = false
```
If anonymous access is intentional (e.g. for preview/spectator mode), add a check to all RLS policies:
```sql
AND (auth.jwt()->>'is_anonymous')::boolean IS NOT TRUE
```

---

### SEC-08 · `supabase/config.toml` — Weak Password Requirements

**File**: `supabase/config.toml` (lines 177–180)
**Risk**: LOW — `minimum_password_length = 6` and `password_requirements = ""` are the weakest possible settings. Since The Styliste uses Firebase third-party auth (Game Center / Play Games), direct email+password sign-up may not be the primary flow — but if it's available, this should be tightened.

**Fix**:
```diff
- minimum_password_length = 6
- password_requirements = ""
+ minimum_password_length = 8
+ password_requirements = "lower_upper_letters_digits"
```

---

### SEC-09 · CORS `Access-Control-Allow-Origin: *` on All Edge Functions

**Files**: Every edge function
**Risk**: LOW-MEDIUM — Wildcard CORS means any website can make authenticated requests to your edge functions if it obtains a valid JWT. Since JWTs are short-lived and tied to mobile auth, the practical risk is low but not zero.

**Fix**: Before production launch, restrict CORS to your app's actual origins:
```typescript
const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "https://the-styliste.app",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};
```

---

### SEC-10 · `gala_provider.dart` — Client-Side RPC Calls Pass `p_player_id`

**File**: `lib/features/gala/providers/gala_provider.dart` (lines 496–504)
**Risk**: LOW — The `submit_to_gala` RPC receives `p_player_id` from the client (`supabase.auth.currentUser!.id`). This is safe **only if** the Postgres function verifies `auth.uid() = p_player_id` internally. If it blindly trusts the parameter, a player could submit designs on behalf of another player.

**Action**: Verify the `submit_to_gala` SQL function includes:
```sql
IF p_player_id <> auth.uid() THEN
  RAISE EXCEPTION 'UNAUTHORIZED';
END IF;
```
Apply the same check to `cast_gala_vote` and all feed RPCs.

---

## INFORMATIONAL — No Immediate Action Required

### SEC-11 · `firebase_options.dart` Contains Public API Keys ✅

**File**: `lib/firebase_options.dart`
**Status**: SAFE — These are public client-side keys. Restrict them via Firebase Console > Project Settings > API Restrictions (SHA fingerprint / bundle ID restrictions).

### SEC-12 · `google-services.json` Contains Public API Key ✅

**File**: `android/app/google-services.json`
**Status**: SAFE — Public Android API key. Apply SHA-1 restrictions in Google Cloud Console.

### SEC-13 · `.env.json` is Not Tracked by Git ✅

**Verification**: `git ls-files --error-unmatch .env.json` returned exit code 1 (not tracked).
`.gitignore` correctly includes `.env.json`.

### SEC-14 · `seed.sql` Contains No Secrets ✅

**File**: `supabase/seed.sql`
**Status**: SAFE — Only reference supplier data with generated UUIDs.

### SEC-15 · Session Management is Robust ✅

**File**: `lib/core/services/supabase_service.dart`
**Status**: GOOD — `ensureFreshSession()` proactively refreshes tokens 2 minutes before expiry, Realtime channels are re-authed on refresh, and expired sessions throw player-safe exceptions. Sign-out clears Realtime → Firebase → Supabase in correct order.

### SEC-16 · Brand Name Input is Properly Sanitized ✅

**File**: `lib/features/onboarding/screens/sovereign_registry_screen.dart`
**Status**: GOOD — Input is filtered to `[a-zA-Z0-9 ]`, capped at 15 characters, and validated through `brandNameError()` before proceeding.

### SEC-17 · Feed Comment Input Has Length Validation ✅

**File**: `lib/features/feed/screens/feed_screen.dart` (line 1133) + `feed-comment/index.ts` (line 77)
**Status**: GOOD — Client enforces `maxLength: 280`, server double-checks `1 <= length <= 280`.

### SEC-18 · No `using(true)` or `with check(true)` Open RLS Policies ✅

**Status**: GOOD — Grep across all SQL migrations returned zero matches for blanket `using (true)` or `with check (true)` policies.

---
