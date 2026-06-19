# MANUAL_TASKS.md — Security Hardening Audit Pass 1

> **Scope**: Actions that require Supabase Dashboard, Firebase Console, or environment configuration changes that cannot be performed via IDE alone.
> **Priority**: security/creds/RLS > Vex Reveal > sound > polish > new systems.

---

## 🔴 CRITICAL — Before Any Public Build

### TASK-01 · Set `CRON_SECRET` in Supabase Edge Function Secrets

**Where**: Supabase Dashboard → Settings → Edge Functions → Secrets
**Why**: SEC-01 directive adds a `CRON_SECRET` header check to `trend-decay`. The secret must exist in the environment or every cron invocation will fail.

**Steps**:
1. Generate a 64-char hex secret: `openssl rand -hex 32`
2. In Supabase Dashboard → Settings → Edge Functions → Add secret:
   - Name: `CRON_SECRET`
   - Value: *(paste generated secret)*
3. Update your Supabase Cron job (Dashboard → Cron) to include the header:
   ```
   x-cron-secret: <your-secret>
   ```
4. Verify `eclipse-event-tick` also uses the same `CRON_SECRET` env var.

---

### TASK-02 · Set `WEBHOOK_SECRET` in Supabase Edge Function Secrets

**Where**: Supabase Dashboard → Settings → Edge Functions → Secrets
**Why**: SEC-02 directive changes `send-fcm-notification` to fail-closed when `WEBHOOK_SECRET` is missing. If the secret is not set, all FCM notifications will stop working.

**Steps**:
1. Generate a 64-char hex secret: `openssl rand -hex 32`
2. In Supabase Dashboard → Settings → Edge Functions → Add secret:
   - Name: `WEBHOOK_SECRET`
   - Value: *(paste generated secret)*
3. In Supabase Dashboard → Database → Webhooks, update the webhook for `send-fcm-notification` to include:
   ```
   x-webhook-secret: <your-secret>
   ```

---

### TASK-03 · Audit RLS Policies on Direct-Write Tables

**Where**: Supabase Dashboard → Table Editor → RLS Policies (or via SQL Editor)
**Why**: SEC-03 through SEC-06 identify client-side writes. These are only safe if RLS is correctly enforced.

**Tables to verify**:

| Table | Required INSERT Policy | Required UPDATE Policy |
|---|---|---|
| `player_reports` | `WITH CHECK (reporter_id = auth.uid())` | DENY all |
| `player_roster` | n/a | `USING (player_id = auth.uid())` — or DENY if fully server-side |
| `feed_posts` | `WITH CHECK (player_id = auth.uid())` — or DENY if only via edge fn | n/a |
| `platform_auth_mappings` | `WITH CHECK (player_id = auth.uid())` | DENY all |

**Steps**:
1. Go to Supabase Dashboard → SQL Editor
2. Run for each table:
   ```sql
   SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
   FROM pg_policies
   WHERE tablename = '<table_name>';
   ```
3. If policies are missing or overly permissive, create them:
   ```sql
   -- Example for player_reports
   ALTER TABLE public.player_reports ENABLE ROW LEVEL SECURITY;
   
   CREATE POLICY "authenticated_insert_own_reports"
     ON public.player_reports FOR INSERT
     TO authenticated
     WITH CHECK (reporter_id = auth.uid());
   
   -- Deny all other operations for authenticated role
   CREATE POLICY "deny_select_reports"
     ON public.player_reports FOR SELECT
     TO authenticated
     USING (false);
   ```

---

### TASK-04 · Verify RPC Functions Enforce `auth.uid()` Checks

**Where**: Supabase Dashboard → SQL Editor
**Why**: SEC-10 identifies that client-side code passes `p_player_id` to RPCs. If these RPCs don't verify the caller's identity, any player can act as another.

**RPCs to audit**:
- `submit_to_gala`
- `cast_gala_vote`
- `get_gala_leaderboard`
- `edge_react_to_feed_post`
- `edge_add_feed_comment`
- `edge_request_design_inspiration`
- `edge_respond_design_inspiration`
- `edge_request_feed_collab`
- `edge_respond_feed_collab`

**Verification query**:
```sql
SELECT proname, prosrc
FROM pg_proc
WHERE proname IN (
  'submit_to_gala', 'cast_gala_vote', 'edge_react_to_feed_post',
  'edge_add_feed_comment', 'edge_request_design_inspiration',
  'edge_respond_design_inspiration', 'edge_request_feed_collab',
  'edge_respond_feed_collab'
);
```

For **each** function, verify it contains a line like:
```sql
IF p_player_id <> auth.uid() THEN
  RAISE EXCEPTION 'UNAUTHORIZED';
END IF;
```

**Note**: Edge-function-called RPCs (called via `admin` service role client) bypass RLS. For these, the edge function itself performs the JWT check, and `p_player_id` is extracted from the verified JWT — this is the correct pattern. Only RPCs called **directly** from the Flutter client via `supabase.rpc()` need the `auth.uid()` guard.

---

## 🟠 HIGH — Before Beta

### TASK-05 · Restrict Firebase API Keys

**Where**: Google Cloud Console → APIs & Services → Credentials
**Why**: SEC-11 and SEC-12 note that `firebase_options.dart` and `google-services.json` contain public API keys. These should be restricted to prevent unauthorized usage.

**Steps**:
1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials) for project `the-styliste`
2. For each API key:
   - **Android key**: Restrict to your package name (`com.skinteethnerds.styliste.the_styliste`) + SHA-1 fingerprint
   - **iOS key**: Restrict to your iOS bundle ID
   - **Web key** (if exists): Restrict to your domain(s)
3. Apply API restrictions: only enable the APIs you actually use (FCM, Crashlytics, Analytics, etc.)

---

### TASK-06 · Decide on Anonymous Sign-Ins

**Where**: Supabase Dashboard → Auth → Settings (production) + `supabase/config.toml` (local)
**Why**: SEC-07 flags that `enable_anonymous_sign_ins = true`. This needs a product decision.

**Options**:
- **A) Disable** (recommended): Set `enable_anonymous_sign_ins = false` in both config.toml and production dashboard. No game functionality requires anonymous sessions.
- **B) Keep with guard**: If you want a spectator/preview mode, add `AND (auth.jwt()->>'is_anonymous')::boolean IS NOT TRUE` to all INSERT/UPDATE/DELETE RLS policies so anon users are read-only.

---

### TASK-07 · Tighten Password Requirements (Production)

**Where**: Supabase Dashboard → Auth → Settings
**Why**: SEC-08. Even if email+password is not the primary auth flow, it's a fallback that should be hardened.

**Steps**:
1. Set minimum password length to 8
2. Set password requirements to `lower_upper_letters_digits`

---

### TASK-08 · Run Supabase Database Linter

**Where**: Terminal (local Supabase CLI)
**Why**: Catches RLS gaps, missing policies, and misconfigurations that the code audit cannot detect.

**Command**:
```bash
supabase db lint --local
```

Review output for:
- Tables with RLS disabled
- Tables with policies that are too permissive
- Functions with `SECURITY DEFINER` that lack `search_path` restrictions

---

### TASK-09 · Rotate Production Secrets

**Where**: Supabase Dashboard → Settings
**Why**: If any secret has been accidentally exposed during development, rotating ensures a clean production state.

**Secrets to rotate/verify before launch**:
- [ ] `SUPABASE_SERVICE_ROLE_KEY` — never exposed in client code (verified ✅)
- [ ] `CRON_SECRET` — freshly generated per TASK-01
- [ ] `WEBHOOK_SECRET` — freshly generated per TASK-02
- [ ] `FIREBASE_SERVICE_ACCOUNT` — stored in Supabase secrets, never in git
- [ ] `SUPABASE_ANON_KEY` — public by design, but regenerate if compromised

---

### TASK-10 · Deploy Edge Function Updates

**Where**: Terminal (Supabase CLI)
**Why**: After applying SEC-01 and SEC-02 code fixes, the updated edge functions must be deployed.

**Command**:
```bash
supabase functions deploy trend-decay --no-verify-jwt
supabase functions deploy send-fcm-notification --no-verify-jwt
```

**Note**: `--no-verify-jwt` is used because these functions handle their own auth (cron secret / webhook secret). The `verify_jwt = true` in `config.toml` only applies to functions listed there.

---

## 🟢 LOW — Pre-Launch Polish

### TASK-11 · Set Up Production Error Monitoring

**Where**: Sentry / Datadog / equivalent
**Why**: Without monitoring, auth failures, edge function errors, and RLS rejections will go unnoticed in production.

**Minimum coverage**:
- Flutter: Sentry SDK for uncaught exceptions and `SupabaseSessionExpiredException` tracking
- Edge Functions: Structured logging to Supabase Analytics or external service
- Database: `pg_stat_statements` review for unusual query patterns

---

### TASK-12 · Run Dependency Audit

**Where**: Terminal
**Why**: Outdated packages may contain known CVEs.

**Command**:
```bash
flutter pub outdated
```

Review output for security-critical packages:
- `supabase_flutter`
- `firebase_auth`
- `firebase_core`
- `flutter_secure_storage` (if used)

Do **not** blindly upgrade — check changelogs for breaking changes.

---
