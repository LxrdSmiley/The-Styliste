# Manual Tasks — GDD v7 Audit Follow-Up

Audit date: 2026-07-22
Repository: `C:\STN\The-Styliste`
Audited HEAD: `ea5a6675ceb13772401d3b819f7566a313ec7a79`

These actions require Smiley or an authorized operator. They are not safe to infer from source inspection and must not be marked `Passed` until the result is observed. Do not paste credentials, access tokens, receipts, private keys, database passwords, recovery codes, or service-role values into chat, source, screenshots, fixtures, or issue text.

## 1. Preserve and review the Git pull state

The requested pull is complete. `master` and `origin/master` both point to `ea5a6675ceb13772401d3b819f7566a313ec7a79`. The pull changed the repository GDD v7. Existing unrelated local work remains dirty and must be preserved.

One local pre-pull GDD patch is stored at:

```text
stash@{0}: codex-pre-audit-local-gdd-v7-2026-07-22
```

Review it without applying it:

```powershell
Set-Location 'C:\STN\The-Styliste'
git stash show --stat 'stash@{0}'
git stash show -p 'stash@{0}'
```

Developer decision required:

- Identify any genuinely unique local GDD text that belongs in the detailed first GDD body.
- Do not run `git stash pop` or apply the entire stash. The pulled GDD already contains a duplicated older body, and a wholesale apply could reintroduce conflicting authority.
- Approve Directive 0’s GDD cleanup as its own reviewable commit before gameplay work.
- Keep all other pre-existing dirty files intact. Do not use reset/checkout/clean to erase them.

## 2. Approve the recovery milestone and work order

Approve the current label as:

```text
Pre-Alpha — Kingston Proof-of-Fun Recovery
```

Do not authorize “implement the GDD.” Give the IDE agent one numbered directive from `IDE_DIRECTIVES.md` at a time. The safe starting order is:

1. Directive 0 — one canonical GDD.
2. Directive 1 — fail-closed Early Game Supabase/API allowlist.
3. Directive 2 — Luxe Founder Trial.
4. Directive 3 — economy field separation and parity simulator.
5. Directives 4–8 — the playable Kingston causal loop.
6. Directives 9–12 — quarantine, performance, verification, and external-test readiness.

At any time, permit at most one gameplay task, one backend/security task, and one polish/tooling task. Do not approve Milan, player Feed, Maisons, Gala, DMs, territory, store trading, IAP, ads, generative AI, advanced finance, or endgame work during this recovery milestone.

## 3. Run the current mobile baseline after GDD cleanup

Codex is prohibited from running Dart and Flutter commands. After Directive 0 is reviewed, run these from the repository root and return the complete output for any failure:

```powershell
Set-Location 'C:\STN\The-Styliste'
powershell -ExecutionPolicy Bypass -File .\scripts\check_gdd_registry.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\check_deferred_todos.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\check_authority_matrix.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\check_release_metadata.ps1
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
```

Record each result independently. A formatting pass does not prove analysis; unit tests do not prove integration, security, startup, device behavior, or performance.

Do not run Web/Chrome/Pages commands. They are `Not applicable` to the mobile milestone.

## 4. Create a disposable local Supabase verification environment

Only reset a target you have positively identified as local and disposable. Never run a reset against the linked production project.

After Directive 1 supplies the new forward migration and executable contracts:

```powershell
Set-Location 'C:\STN\The-Styliste'
supabase start
supabase db reset --local --no-seed
supabase db lint --local
$dbContainer = docker ps --filter 'name=supabase_db_' --format '{{.Names}}' | Select-Object -First 1
if (-not $dbContainer) { throw 'Disposable local Supabase database container not found.' }
Get-Content -Raw .\supabase\tests\rls_authority_contract.sql |
  docker exec -i $dbContainer psql -U postgres -d postgres -v ON_ERROR_STOP=1
```

Developer verification required:

- Confirm the container name belongs to the disposable local project before piping SQL.
- Confirm all enabled Edge Functions type-check after the function allowlist changes.
- Confirm owner, stranger, anonymous-authenticated, malformed-input, replay, and concurrency cases actually execute. Comment-only cases are `Blocked`.
- Save redacted output in the verification evidence location; never save tokens or service credentials.

Do not deploy the migrations or functions to the hosted project until local reset, lint, authority contract, and app integration tests pass.

## 5. Review hosted Supabase settings manually

Source configuration does not prove hosted configuration. In the Supabase dashboard for each environment, inspect and record the following without exposing values:

### Data API and database

- Confirm only the reviewed `api` schema is exposed. Do not expose `public` as a workaround.
- Confirm production, staging, and development are separate projects.
- Confirm client roles have no direct write authority over balances, rewards, scores, progression, ownership, inventory outcomes, or timestamps.
- Confirm every enabled Edge Function maps to an approved Early Game Feature ID and reviewed `api` wrapper.
- Disable or remove deployed later-wave functions: player Feed reactions/comments/inspiration, Maison donation, mini-game rewards, IAP validation, Eclipse events, and any unapproved scheduled/live-event job.
- Review Realtime publications. Do not publish global `feed_posts`, Maison, territory, trend, wallet, or private player tables during Early Game.
- Keep Storage buckets disabled/uncreated until owner-path, stranger, blocked-user, MIME, size, malware/content, and signed-URL tests exist.

### Auth and account recovery

- Decide whether anonymous sign-in remains enabled for the closed test. Remember that anonymous users use the `authenticated` Postgres role; RLS must distinguish identity/ownership, not merely role.
- Enable CAPTCHA/bot protection before external sign-ups.
- Review sign-up, sign-in, OTP, password-reset, and anonymous-session rate limits.
- Enable leaked-password protection when password auth is enabled.
- Review password length, password-change reauthentication, session duration, device/session revocation, and recovery behavior.
- Remove obsolete Web/Pages redirect URLs. Keep only authorized mobile/staging callbacks.
- Require MFA for every Supabase organization/staff account. Player MFA may remain optional until the account UI is ready, but sensitive account changes must require recent authentication.
- Configure production SMTP/recovery delivery before public account creation.

### Staff, secrets, and network

- Use individual staff identities and least privilege; no shared administrator account.
- Verify service-role, store, webhook, cron, signing, and database credentials exist only in the appropriate secret store.
- Review hosted network restrictions and database access controls. Local `config.toml` defaults do not configure the hosted project.
- Configure domain-specific freeze switches for currency grants, purchases, trading, messaging, uploads, Gala claims, and other future sensitive operations before those domains launch.

### Backup and response

- Select and document backup/PITR policy appropriate to the economy risk.
- Back up Storage separately if/when Storage is enabled; database backups do not restore deleted Storage objects.
- Perform a restore drill in a non-production project and reconcile the economy ledger afterward.
- Configure redacted monitoring for unusual `401/403/409/429/5xx`, replay attempts, balance anomalies, service-role calls, and endpoint spikes.
- Document incident ownership, secret rotation, evidence preservation, user notification, and recovery steps.

## 6. Inspect credentials and Git history

The static current-tree review did not identify an obvious real service-role key or private key. That is not proof that repository history, CI artifacts, logs, or shared files are clean.

Actions:

1. Install `gitleaks` from its official release or inspect the full-history GitHub Actions scan.
2. Fetch full history and run:

```powershell
Set-Location 'C:\STN\The-Styliste'
git fetch --all --tags --prune
gitleaks git . --redact=100 --no-banner
```

3. Review the history of `android/app/google-services.json`, `.firebaserc`, `firebase.json`, `.env.json`, signing files, Supabase config, and workflow artifacts.
4. Rotate any secret that was ever committed, logged, pasted, uploaded, or shared outside the intended secret store. Deleting it from the current tree does not revoke it.
5. Confirm `.env.json` remains ignored and contains only the public Supabase URL/publishable key required by the mobile client. Never place a service-role key in it.
6. Review repository Actions secrets and Supabase function secrets by name and age; do not export or display their values.

Firebase client keys are not substitutes for authorization, but retired Firebase project configuration still requires owner review and deletion/rotation where appropriate.

## 7. Observe GitHub Actions instead of inferring it

After a reviewable branch/PR exists:

- Open the latest workflow run for that exact commit.
- Confirm the GDD registry job executes and passes.
- Confirm the authority inventory is labeled `Static pass`, not behavioral RLS success.
- Confirm the disposable database reset, lint, executed SQL contract, Edge type-check, secret scan, dependency audit, analyzer, unit tests, explicit integration tests, and Android build are separate results.
- Confirm disabled later-wave functions are not type-checked/deployed as though they are current milestone dependencies.
- Confirm the debug APK job is described as compilation evidence if it has no runtime Supabase configuration.
- Do not approve a release based on green workflow status if device, live Auth/RLS, performance, legal, or penetration gates remain `Blocked`.

The current repository contains uncommitted workflow changes. No workflow execution for those changes was observed in this audit.

## 8. Free disk space before any Android build

Drive C has about 1.27 GB free. The project guard requires at least 5 GB before an Android build.

Developer action:

- Close running emulators, IDE tasks, or browsers that hold generated build files.
- Use Windows Storage settings or another deliberate, recoverable method to free at least 5 GB.
- Do not delete repository source, migrations, the Git directory, user documents, or unknown cache directories.
- After source verification passes, you may run `flutter clean`; this removes generated Flutter build output, not source.
- Recheck free space before building.

Then run the mobile build with public client configuration only:

```powershell
Set-Location 'C:\STN\The-Styliste'
powershell -ExecutionPolicy Bypass -File .\scripts\maintenance\check_build_space.ps1
flutter clean
flutter pub get
flutter build apk --debug --dart-define-from-file=.env.json
```

An APK build is not runtime proof. Do not create or dispatch a Web/Pages build.

## 9. Run integration and device tests after Directives 1–8

Use a disposable local or isolated staging Supabase project. Never run destructive fixtures against production.

### Auth and isolation

- Fresh anonymous session.
- Restored valid session.
- Expired/invalid session.
- Temporary network loss without identity replacement.
- Anonymous-to-linked account upgrade after that feature is approved.
- Owner versus stranger access to every enabled projection and mutation.
- No client can supply another player’s UUID and act for them.

### Kingston core loop

- Luxe-led Founder Trial without developer explanation.
- Force-close/reconnect at each server-confirmed step.
- Same starter garment used for both path samples.
- Actual saved garment differences from the same brief.
- Named-customer, Vex, and Luxe reactions match saved choices.
- Architect diagnosis and two viable recovery choices.
- Both paths can fund the next meaningful action within the approved pacing band.
- House While Away settles once and explains changes.
- Daily Brief cannot require a disabled or paid feature.

### Accessibility and performance

Run on the Galaxy A55 and at least one weaker supported Android device in profile/release mode:

- portrait navigation and one-handed reach;
- largest supported text scaling;
- screen reader semantics/focus order;
- high contrast and color-independent status;
- reduced motion;
- offline, loading, empty, error, and retry states;
- Atelier manipulation, shader/cloth fallback, Store activity, Feed cards, and result screens;
- frame/raster timing, jank, memory, battery/network polling, thermals, and resume behavior.

Record device model, OS, build mode, commit SHA, frame evidence, failures, and reproduction steps. Source inspection or widget tests alone cannot change `PERF-01` from `Blocked`.

## 10. Conduct human proof-of-fun and balance testing

After the recovery slice is stable, recruit a small closed group. Do not use public acquisition yet.

Ask testers to complete the game without coaching and measure:

- meaningful input within 45 seconds;
- Founder Trial within 4–6 minutes;
- causal loop within 8–12 minutes;
- whether two players’ same-brief garments are visibly distinct;
- whether the player understands why customer/Vex opinions differ;
- whether the Architect can diagnose a struggling store quickly;
- whether failure produces an interesting recovery rather than a delay;
- whether a tester voluntarily starts another design/release cycle;
- whether the player can describe what their House represents.

Run the path-parity simulator and compare it with real sessions at 1 hour, 24 hours, and 7 days. Do not tune from intuition alone. Record time to next action, active/idle ratio, House Funds, failure recovery, and drop-off separately for Artisan and Architect. No premium purchase variable is allowed in this test.

If the core loop fails, simplify or revise it. Do not add Milan, multiplayer, monetization, or more currencies to hide the failure.

## 11. Obtain legal and operational review before external testing

The in-app policies are explicit closed-alpha placeholders and are not ready for public players.

Developer-only actions:

- Decide the countries and minimum age for the test.
- Obtain qualified legal review for privacy, terms, age assurance/COPPA risk, GDPR/UK GDPR, CCPA/CPRA applicability, consumer rights, refunds, UGC/IP, DMCA, retention, subprocessors, and breach obligations.
- Establish a real support contact and response process.
- Implement and test access, correction, export, deletion, account recovery, and appeal workflows before promising them.
- Version and publish approved policies at stable URLs and preserve the version each player accepted.
- Do not describe disabled IAP, ads, DMs, Maisons, social Feed, talent pulls, or other deferred systems as active data uses.
- Keep external testing blocked until age/eligibility handling and privacy operations are real, not text-only.

## 12. Independent security review gate

Before public multiplayer, private messaging, player trading, premium currency purchases, or real-money products:

- commission an independent penetration test covering mobile API abuse, RLS/grants, Edge Functions, Auth/account recovery, Storage, Realtime, replay/concurrency, receipt validation, rate limiting, and administrative access;
- resolve all critical/high findings and retest them;
- perform a privileged-function/RLS audit against the deployed schema;
- run an incident/restore exercise; and
- publish a responsible-disclosure process.

No system can be made literally impossible to hack. The release standard is defense in depth, least privilege, small attack surface, detection, containment, evidence, and tested recovery.

## Manual milestone decision

Do not promote beyond **Pre-Alpha / Kingston Proof-of-Fun Recovery** until every promotion gate at the end of `IDE_DIRECTIVES.md` has observed evidence. In particular, do not treat a passing analyzer, CI run, or APK build as proof of fun, F2P parity, security, legal readiness, or 60 fps.
