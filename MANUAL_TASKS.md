# Security Hardening Audit Pass 1 — Manual Tasks

These actions require Smiley or an authorized operator in Supabase, Firebase, Google Cloud, App Store Connect, Google Play Console, CI, or the release environment. Do not place secret values in source control, screenshots, chat, fixtures, or issue trackers.

## Execution status — June 23, 2026

Completed by Codex:

- Applied eight security/GDD-hardening migrations to Supabase project `xzzklkmkjmwzpiedkwho`.
- Deployed all 13 hardened Edge Functions. JWT-backed functions reject unauthenticated requests with `401`; secret-backed jobs fail closed with `503` while their required secrets are absent.
- Re-ran linked database lint with no error-level findings.
- Re-ran Supabase Security Advisor and Performance Advisor after the final schema change.
- Re-ran the rollback-only database security regression harness successfully.
- Type-checked every changed Edge Function with `deno check`.
- Resolved the follow-up merge conflicts in `trend-decay`,
  `send-fcm-notification`, `claim-mini-game-reward`, and this file.
- Redeployed `trend-decay`, `send-fcm-notification`, and
  `claim-mini-game-reward` to Supabase project `xzzklkmkjmwzpiedkwho`.
- Added a CI release-gate check that rejects unresolved Git merge conflict
  markers.
- Ran `dart format lib`, `flutter analyze`, and `flutter test` successfully.
- Re-ran `supabase db reset --local` successfully with Docker running on
  June 25, 2026; the full migration chain and `supabase/seed.sql` applied.
- Re-ran `supabase db lint --local` successfully with Docker running on
  June 25, 2026. It exited `0` with warning-level findings only in
  `public.execute_casting_pull` and `public.rotate_gala_event`.
- Smiley re-ran `dart format lib test`, `flutter analyze`, and `flutter test`
  successfully on June 25, 2026.
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
- Run the manual runtime checks at the end of this file.
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

Smiley last ran `dart format lib test`, `flutter analyze`, and `flutter test`
successfully on June 25, 2026. Codex last ran `supabase db reset --local` and
`supabase db lint --local` successfully on June 25, 2026. Verification is not
complete until the manual runtime/security checks succeed.

## 9. Manual runtime and security checks

First run the Required Runtime Smoke Test in `VERIFICATION_PROTOCOL.md`.

1. Launch with an expired saved session; refresh or safe sign-in recovery must occur without raw Supabase errors.
2. Sign out and confirm both Firebase and Supabase sessions are gone and Realtime channels are closed.
3. Switch accounts and confirm no previous-player profile, feed, inventory, store, or economy data appears.
4. Attempt direct/replayed/concurrent mini-game claims and confirm one valid attempt can pay at most once.
5. Tamper with mint score fields and confirm authoritative Hype is unchanged.
6. Invoke privileged cron/webhook functions with missing or incorrect credentials and confirm no mutation.
7. Run concurrent store upgrades and Maison donations and reconcile exact balances/tiers/ledger rows.
8. Run Apple/Google sandbox purchase substitution, replay, restore, refund, and account-binding tests.
9. Build through the controlled release pipeline and verify the production signing certificate.
