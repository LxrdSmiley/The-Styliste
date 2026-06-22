<<<<<<< HEAD
# Security Hardening Audit Pass 1 — Manual Tasks

These actions require Smiley or an authorized operator in Supabase, Firebase, Google Cloud, App Store Connect, Google Play Console, CI, or the release environment. Do not place secret values in source control, screenshots, chat, fixtures, or issue trackers.

## Execution status — June 22, 2026

Completed by Codex:

- Applied eight security/GDD-hardening migrations to Supabase project `xzzklkmkjmwzpiedkwho`.
- Deployed all 13 hardened Edge Functions. JWT-backed functions reject unauthenticated requests with `401`; secret-backed jobs fail closed with `503` while their required secrets are absent.
- Re-ran linked database lint with no error-level findings.
- Re-ran Supabase Security Advisor and Performance Advisor after the final schema change.
- Re-ran the rollback-only database security regression harness successfully.
- Type-checked every changed Edge Function with `deno check`.
- Added database rate limits, replay protection, atomic economy/payment RPCs, server-owned mini-game attempts, authoritative Atelier sessions, safe error surfaces, release-signing failure guards, tracked Gradle wrapper files, and the security release-gate workflow.
- Added database-enforced report categories, description limits, target integrity, a 15-minute same-target cooldown, and a 10-report daily cap.
- Reduced `player_reports` grants to authenticated `SELECT`/`INSERT` only and removed all `anon` table privileges.
- Added covering indexes for both player-report target foreign keys.
- Retired Staff Rally and Supplier Raid from the standalone mini-game API and
  removed their unreachable client screens; the replacement community events
  remain future implementation work.
- Replaced blunt World Map, Profile, Events, and AR unavailable screens with honest premium later-build previews.
- Confirmed the canonical Luxe IDs are aligned in Flutter and `validate-iap`: `initiates_cache`, `artisans_reserve`, `architects_vault`, and `sovereign_syndicate`.
- Confirmed `APPLE_BUNDLE_ID`, `APPLE_SHARED_SECRET`, `GOOGLE_PACKAGE_NAME`, and `GOOGLE_SERVICE_ACCOUNT_KEY` are configured by secret name. Secret values were not read or exposed.

Still requires an authorized operator:

- Generate and securely configure `CRON_INVOKE_SECRET`, `WEBHOOK_SECRET`, and `ECLIPSE_EVENT_TICK_SECRET`, then configure the matching scheduler/webhook callers. Do not enable those callers before both sides share the secret.
- Configure `FIREBASE_PROJECT_ID` and `FIREBASE_SERVICE_ACCOUNT` for FCM.
- Enable PITR/backups and perform a restore drill. Current linked-project status is WALG enabled, PITR disabled, with no available backup timestamps.
- Complete the Supabase Auth, Firebase/App Check, store-console, signing-certificate, monitoring, alerting, storage, and incident-readiness tasks below.
- Run the Flutter/Dart and manual runtime checks at the end of this file.
- Triage the remaining Advisor backlog separately: legacy callable `SECURITY DEFINER` RPCs, anonymous-access policy notices, `pg_net` in `public`, leaked-password protection, RLS performance plans, and unindexed foreign keys. The new service-only security tables intentionally have RLS with no client policies and revoked client grants.
- Replace the bundled closed-alpha legal placeholders with counsel-approved, versioned documents published at stable public URLs before external testing.

## 1. Credential and configuration classification

### Safe public configuration

- Supabase project URL and anon/publishable client key are public client configuration. Keep RLS and grants correct; do not treat the anon key as authorization.
- `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, and `lib/firebase_options.dart` contain Firebase client configuration. Their API keys are identifiers, not server secrets, but must be restricted by Android package/SHA, iOS bundle ID, and required APIs in Google Cloud.

No client-side `SUPABASE_SERVICE_ROLE_KEY`, Apple shared secret, Google service-account private key, webhook secret, or PEM private key was confirmed by this audit.

### Secrets that must remain server/console-only

- `SUPABASE_SERVICE_ROLE_KEY`
- `FIREBASE_SERVICE_ACCOUNT`
- `GOOGLE_SERVICE_ACCOUNT_KEY`
- `APPLE_SHARED_SECRET`
- `WEBHOOK_SECRET`
- Android upload keystore, alias, and passwords
- Any cron/scheduler invocation secret added for privileged jobs

Verify each is stored only in Supabase secrets, CI secret storage, or the appropriate platform console. Rotate immediately if any value was previously committed, pasted into logs/chat, included in an artifact, or shared outside the authorized team.

### Unknown exposure requiring owner confirmation

- `.env.json` is ignored in the current checkout. Confirm through repository history, cloud backups, shared archives, and CI artifacts that it was never committed or uploaded.
- `android/key.properties` and `android/upload-keystore.jks` are ignored. Confirm they have never entered repository history or distributable build artifacts.
- Confirm prior Edge Function logs did not print authorization headers, receipts, service-account JSON, or secret values.

## 2. Supabase dashboard actions

1. Configure a scheduler-only `CRON_INVOKE_SECRET` for `trend-decay`. It is deployed but fails closed until configured.
2. Configure `WEBHOOK_SECRET`, `FIREBASE_PROJECT_ID`, and `FIREBASE_SERVICE_ACCOUNT` before enabling database webhooks for `send-fcm-notification`. It is deployed but fails closed until configured.
3. Configure `ECLIPSE_EVENT_TICK_SECRET` before enabling the Eclipse scheduler. It is deployed but fails closed until configured.
4. Review and disposition the remaining Security/Performance Advisor backlog. The final Advisor runs are complete, and linked CLI database lint passes. Relevant guidance: [callable definer RPCs](https://supabase.com/docs/guides/database/database-linter?lint=0029_authenticated_security_definer_function_executable), [anonymous policies](https://supabase.com/docs/guides/database/database-advisors?queryGroups=lint&lint=0012_auth_allow_anonymous_sign_ins), [extensions in public](https://supabase.com/docs/guides/database/database-linter?lint=0014_extension_in_public), and [leaked-password protection](https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection).
5. Confirm reward, IAP, store-upgrade, Maison-donation, cooldown, and mint RPCs are executable only by the intended service role/Edge Function paths.
6. Enable leaked-password protection if email/password authentication is available.
7. Review password minimum length, password-change reauthentication, anonymous-sign-in policy, OTP expiry, redirect URLs, and allowed auth providers.
8. Configure per-user/server rate limits for auth attempts, drop mint/publish, feed reactions/comments, mini-game attempts/claims, IAP validation, store upgrades, Maison donations, gala votes, and casting pulls.
9. Verify production and development use separate Supabase projects, secrets, auth redirect URLs, storage buckets, and scheduled jobs.
10. Enable production backups and PITR appropriate to the launch tier. Perform and document a restore drill before public testing.
11. Configure alerts/log review for repeated `401/403/409/429/5xx`, reward-claim spikes, receipt replay, unusual service-role calls, and privileged scheduled-job frequency.
12. Review Storage buckets: no public write access, user-owned paths where applicable, MIME allowlists, upload-size limits, and no executable/script uploads.

## 3. Firebase and Google Cloud actions

1. Fix and verify the Firebase-to-Supabase provider configuration. Do not rely on the app's fallback to an unrelated Supabase anonymous identity.
2. Restrict Firebase client API keys by application identity and only the APIs the app needs.
3. Confirm Android package name, SHA-1/SHA-256 fingerprints, iOS bundle ID, APNs configuration, and Firebase Auth providers match production builds.
4. Enforce Firebase App Check for every Firebase resource used by the app. App Check activation in Flutter is not equivalent to console enforcement.
5. Decide how Supabase Edge Functions will validate app attestation for abuse-sensitive mobile calls; Supabase does not automatically enforce Firebase App Check.
6. Enable Crashlytics or an approved equivalent and verify auth/session failures, purchase validation failures, and fatal startup errors are visible without logging tokens or personal data.
7. Review FCM service-account scope and rotate the account key if its historical handling is uncertain.

## 4. Apple and Google Play purchase checks

1. Create one canonical product catalog and align product IDs/grants across App Store Connect, Google Play Console, Flutter, Edge Functions, and legal/refund copy.
2. Confirm the store-console products exactly match the now-aligned code catalog: `initiates_cache`, `artisans_reserve`, `architects_vault`, and `sovereign_syndicate`.
3. Configure Apple transaction verification credentials and Google Play service-account access only in server-side secrets.
4. Require App Account Token on Apple and obfuscated account identifiers on Google purchases, mapped to the authenticated player.
5. Test low-tier/high-tier substitution, restored purchases, refunds/revocations, pending purchases, sandbox/TestFlight, receipt replay, concurrent redemption, and account switching.
6. Confirm no raw receipt or purchase token is retained longer than needed and no receipt appears in client/server logs.

## 5. Release signing and CI

1. Confirm the committed release-signing guard fails in the controlled CI environment when signing material is absent.
2. Store the Android upload keystore and passwords in the release secret manager; keep them out of source control.
3. Ensure the newly added Gradle wrapper scripts and wrapper JAR are included in the next commit.
4. Extend the added security release gate with environment-owned checks for the expected certificate fingerprint, version, environment/project IDs, and minification.
5. Protect production deployment branches and require review for migrations, Edge Functions, auth configuration, payment code, and signing changes.

## 6. Bot and abuse-control decisions

- Do not add a Flutter CAPTCHA dependency in this pass.
- Decide whether Supabase Auth CAPTCHA/bot protection is appropriate for account creation and recovery.
- Prefer server-side cooldowns, unique constraints, idempotency keys, attempt records, and per-user/IP/device rate limits for gameplay and social abuse.
- Establish moderation limits for comments, reactions, reports, follows, gala votes, casting pulls, mini-game claims, and drop publishing.
- Document escalation thresholds and an emergency kill switch for reward and purchase endpoints.

## 7. Monitoring, backups, and incident readiness

1. Create dashboards/alerts for auth bridge failures, mismatched identities, expired-session loops, Realtime reconnect failures, reward volume, currency deltas, IAP rejection/replay, and privileged function invocation.
2. Define log retention and redact authorization headers, JWTs, receipts, device tokens, email addresses, and secret values.
3. Document credential rotation, compromised-account response, fraudulent-currency rollback, purchase reconciliation, database restore, and player notification procedures.
4. Confirm Play Console and App Store crash/ANR/payment reports are monitored by an owner with an escalation path.
5. Perform a staging restore test and a tabletop incident exercise before public testing.

## 8. Dependency audit — no updates in this pass

Smiley should run these manually and save the output for a separate dependency decision:

```bash
flutter pub outdated
dart pub deps
```

This repository uses Deno Edge Functions and has no applicable Node package audit requirement unless a `package.json`/npm runtime is added later.

Review Deno import versions and advisories separately. Pin or update them only in an approved dependency-hardening pass.

## Manual Terminal Commands for Smiley

After approved code fixes are implemented, run:

```bash
dart format lib
flutter analyze
flutter test
```

If Supabase migrations or Edge Functions change, also run:

```bash
supabase db reset --local
supabase db lint --local
```

Paste the complete output back to Codex. Verification is not complete until the commands and the manual runtime/security checks succeed.

## 9. Manual runtime and security checks

1. Launch with an expired saved session; refresh or safe sign-in recovery must occur without raw Supabase errors.
2. Sign out and confirm both Firebase and Supabase sessions are gone and Realtime channels are closed.
3. Switch accounts and confirm no previous-player profile, feed, inventory, store, or economy data appears.
4. Attempt direct/replayed/concurrent mini-game claims and confirm one valid attempt can pay at most once.
5. Tamper with mint score fields and confirm authoritative Hype is unchanged.
6. Invoke privileged cron/webhook functions with missing or incorrect credentials and confirm no mutation.
7. Run concurrent store upgrades and Maison donations and reconcile exact balances/tiers/ledger rows.
8. Run Apple/Google sandbox purchase substitution, replay, restore, refund, and account-binding tests.
9. Build through the controlled release pipeline and verify the production signing certificate.
=======
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
>>>>>>> 813e538151b2ac74022b84c094a35a53fc1d2bb8
