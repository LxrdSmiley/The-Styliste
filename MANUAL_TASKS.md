# MANUAL_TASKS.md

Items below are not safe to delegate to the IDE alone. They require developer, ops, store-console, moderation, or legal-owner decisions.

## Security, Credentials, And Ops

- Apply and verify `supabase/migrations/027_security_hardening.sql` on a disposable local/branch database before production. Then rerun Supabase security and performance advisors and confirm no anonymous `SECURITY DEFINER` RPCs, no exposed `SECURITY DEFINER` views, and no mutable function `search_path` findings remain.
- Decide whether the live project can tolerate the new default policy posture: all public-schema policies are altered to `TO authenticated`. If any signed-out marketing/public read is intentional, create explicit read-only views outside the game API surface instead of reopening gameplay tables to `anon`.
- Move or restrict the `pg_net` extension out of `public` if Supabase advisor still flags it. This is an ops-level database extension change, not an IDE-only patch.
- `.env.json` exists locally and is ignored by git. Confirm it was never committed or uploaded. If it was exposed, rotate the Supabase anon/JWT key set and any Firebase keys used in the file.
- `android/app/google-services.json`, `lib/firebase_options.dart`, and `firebase.json` are tracked. Firebase API keys are not secret by themselves, but restrict them in Google Cloud/Firebase console by app/package/SHA/bundle ID and enabled APIs.
- Remove or deprecate `lib/firebase_options.dart` if the app intentionally uses `String.fromEnvironment` through `FirebaseService`; otherwise it becomes a second, stale config source.
- Configure production `PLAY_GAMES_CLIENT_ID`; current local config scan found placeholder/empty provider values.
- Supabase `config.toml` has password minimum length 6, no password complexity, and `secure_password_change = false`. If email/password auth will be enabled, raise password requirements and require recent login for password changes.
- Confirm Firebase App Check enforcement in Firebase console for Auth-adjacent resources, Firestore/Storage/Functions if used. The Flutter app activates App Check, but console enforcement is manual.
- Add Firebase App Check token verification to Supabase Edge Functions that are called by the mobile app. Supabase does not automatically enforce Firebase App Check.
- Add edge/server rate limits for `mint-design`, `claim-mini-game-reward`, `validate-iap`, `calculate-idle-income`, `process-transaction`, `maison-donate`, `submit_to_gala`, `increment_post_hype`, reporting, and follow/unfollow. Database dedupe is present in places but is not a complete abuse-control layer.
- Lock service-role cron functions with shared secrets or Supabase scheduled invocation controls. `eclipse-event-tick` is the highest-priority function because it mutates global events with `SUPABASE_SERVICE_ROLE_KEY`.
- Create a private moderation workflow for `player_reports`: screenshot storage bucket, RLS on attachments, triage states, moderator roles, appeal path, audit log, and repeat-abuse throttles.
- Decide whether telemetry can be user-only. The hardened telemetry RPC rejects `player_id = null`; `send-fcm-notification` currently tries system notification telemetry. Either add a service-only system telemetry table/RPC or stop logging system telemetry into `telemetry_events`.

Security references used:

- Supabase API security: https://supabase.com/docs/guides/api/securing-your-api
- Supabase RLS roles and policy scoping: https://supabase.com/docs/guides/database/postgres/row-level-security
- Supabase view security and `security_invoker`: https://supabase.com/docs/guides/database/tables#view-security
- Firebase App Check Flutter providers: https://firebase.google.com/docs/app-check/flutter/default-providers
- Firebase API key management: https://firebase.google.com/docs/projects/api-keys

## Legal And Compliance

- No in-repo legal documents were found for Privacy Policy, Terms and Conditions, EULA, Community Guidelines, DMCA/Copyright, Refund Policy, Children's Privacy, Accessibility Statement, Cookie Policy, DPA/GDPR Addendum, or Marketing and Advertising Policy. Settings only links to external URLs. Legal cannot be marked complete until those URLs are live, versioned, and counsel-reviewed.
- Create an alpha-specific Privacy Policy that covers Firebase Auth, Firebase App Check, Firebase Messaging, Supabase Auth/Postgres/Edge Functions, IAP receipts, telemetry, reports/moderation, UGC, device identifiers, analytics, crash logs if any, retention periods, deletion/export, support requests, and international transfers.
- Add CCPA/CPRA notice-at-collection and rights workflow if California users are in scope: categories collected, purposes, retention, sharing/sale status, sensitive data, opt-out links if applicable, correction/deletion/access/non-discrimination rights.
- Add GDPR/UK GDPR workflow if EU/UK users are in scope: lawful bases, controller/processor roles, DPA/SCCs, DSR handling, age-consent rules, retention, data minimization, security measures, and contact/DPO details if required.
- Add COPPA/children policy and age-gating decision. If the game is not for children under 13, state that clearly and implement age-screening. If children may use it, parental consent, data minimization, and child-directed ad/analytics controls are mandatory.
- Add Community Guidelines with UGC/reporting/moderation rules, harassment policy, impersonation/fraud rules, fashion/IP copying policy, sanctions, appeals, and abuse of reporting.
- Register and publish a DMCA designated agent if relying on DMCA safe harbor. The website policy must expose the same current agent information.
- Add Terms and EULA liability limits, warranty disclaimers, virtual currency license language, no cash value, account termination, arbitration/class waiver decision if counsel approves, beta/alpha instability disclaimer, UGC license, and platform terms precedence.
- Add Refund Policy aligned with Apple App Store and Google Play billing flows. Do not promise refunds the platforms control unless the studio can fulfill them.
- Add Marketing and Advertising Policy for rewarded ads, influencer/endorsement disclosures, personalized ads, children/family restrictions, sweepstakes/contest disclaimers, and opt-outs.
- Add Accessibility Statement with target standard, current known gaps, contact channel, and remediation process.
- Add Cookie Policy only if web landing/support/legal pages use cookies or trackers; keep it consistent with the Privacy Policy.
- Add loot-box/gacha odds disclosures near every Sovereign/talent pull and every purchase path that can yield randomized virtual items. Google explicitly requires odds disclosure for randomized virtual items purchased through Play billing.

Legal references used:

- FTC children's privacy/COPPA guidance: https://www.ftc.gov/business-guidance/privacy-security/childrens-privacy
- California CCPA official guidance: https://oag.ca.gov/privacy/ccpa
- European Commission data protection/GDPR overview: https://commission.europa.eu/law/law-topic/data-protection_en
- U.S. Copyright Office DMCA designated agent directory: https://www.copyright.gov/dmca-directory/
- Apple App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Google Play payments policy and randomized-item odds: https://support.google.com/googleplay/android-developer/answer/9858738

## Store, Economy, And Platform

- Align IAP product IDs across `validate-iap`, store UI, Google Play Console, App Store Connect, legal text, and refund policy. Current code comments and product IDs do not form a single canonical list.
- Confirm Apple shared secret, Google service account JSON, package name, bundle IDs, SHA fingerprints, Play Integrity, DeviceCheck/App Attest, and Supabase secrets are set only in platform consoles or Supabase secrets.
- Publish gacha/talent odds, pity behavior, and any Sovereign limitations in UI and legal docs. Current code suggests odds/pity exist, but comments and thresholds need product/legal verification.
- Build a real support and moderation operations process before public alpha: support inbox, SLA, escalation rules, evidence retention, moderator training, and player appeal handling.
- Decide whether `README.md` may claim "All core systems, features, and polish implemented." The audit does not support that claim.

## Manual Feature Blockers

- AR Try-On and Street Snaps are scaffolded, not implemented. Ship with a clear alpha-unavailable state or integrate real AR/body tracking and sharing.
- World Map, Events, and Profile/Brand Story Archive screens are placeholders. Hide from alpha navigation or implement before claiming GDD parity.
- Luxe mentor still has placeholder animation and missing memory, quests, multi-language, and relationship depth.
- Digital Product Passport, sustainability certification tiers, celebrity endorsement, wholesale/B2B, physical-vs-digital split, real fashion trend ingestion, and "Leak a Rumor" are not complete in code.
- Vex exists as local/procedural review generation, but needs opt-in persistence, external sharing controls, moderation, and Brand Story Archive integration.
- Reporting needs screenshot upload, moderator workflow, rate limiting, and anti-abuse before UGC-heavy alpha.

## Static Analysis And Build Gate

- Developer-provided analyzer baseline: `dart analyze` has 115 issues; `flutter analysis` has 0 errors.
- Apply `IDE_DIRECTIVES.md` section 10, then run `dart analyze`, `flutter analyze`, `flutter test`, and any generated-code task used by this repo.
- The prior analyzer run attempted in this environment hung; use the pasted developer output as source of truth until a local successful run is available.

## Implementation Estimate And Blockers

- Estimated GDD v6 implementation: 42% overall.
- Core playable loop: about 55% implemented.
- Security/legal alpha readiness: about 45% after the SQL hardening patch, pending verification.
- Static-analysis readiness: blocked by 115 Dart issues.

Primary blockers:

- Legal documents are absent from the repo and external URLs were not verified as live final documents.
- Supabase hardening migration is patched but not yet applied and advisor-verified on a local/branch database.
- Several migrations and functions have schema drift: Gala ownership, archive ownership, daily check-in column name, provenance misuse for currency rewards, and notification telemetry.
- Feed client still calls the retired one-arg hype RPC until directive 5 is applied.
- App Check is activated in Flutter but not proven enforced for all backend entry points.
- Multiple GDD headline features are scaffolds or placeholders rather than playable systems.
