# AI Quality & Verification Protocol

This protocol separates documentation, static, runtime, database, security, accessibility, and performance evidence. Documentation or source inspection must not be reported as observed runtime behavior.

## Result labels

Use only these result labels:

- **Passed** — directly observed behavior passed the stated check.
- **Failed** — directly observed behavior failed the stated check.
- **Blocked** — the check could not run because of a tool, environment, credential, device, or service blocker.
- **Static pass** — repository inspection or static tooling passed; runtime behavior remains unverified.
- **Not applicable** — the check does not apply to the feature or environment, with a reason recorded.

Do not use “verified,” “complete,” or “production-ready” as substitutes for these labels.

## 1. Repository and diff inspection

Before implementation or release review:

1. Run `git status --short`, `git diff --check`, `git diff --name-status`, and `git ls-files --others --exclude-standard`.
2. Confirm the intended files are the only files in scope.
3. Inspect the current `THE_STYLISTE_GDD_v7.md`, `PROJECT_RULES.md`, this protocol, `DEVELOPMENT_STATE.md`, and `BOTTLENECK_LOG.md`.
4. Record inherited working-tree changes separately from current directive changes.
5. Search for stale authority, GDD, Firebase, Supabase, RLS, anti-cheat, UI/UX, and performance terminology.

Result: **Static pass** only confirms repository evidence and scope; it does not confirm runtime behavior.

## 2. Formatting and static analysis

Run supported non-destructive checks from the repository:

```text
dart format --output=none --set-exit-if-changed .
dart analyze
flutter analyze
```

Record analyzer warnings, errors, formatter changes, generated-code drift, missing imports, invalid providers, lifecycle issues, unreachable routes, and unsafe null assumptions.

Result: **Static pass** does not prove runtime correctness, database behavior, Android installation, or gameplay completion.

## 3. Automated Flutter tests

Run:

```text
flutter test
```

Record the exact test command, result, failures, skipped tests, test environment, and relevant feature coverage. Flutter tests do not prove Android behavior, physical-device behavior, Supabase deployment behavior, accessibility, or performance.

Result: **Passed** requires directly observed passing test output. Otherwise use **Failed** or **Blocked**.

## 4. Observed Flutter runtime behavior

On a clean install or reset test account, manually observe:

1. Complete onboarding through the HQ entry screen.
2. Confirm HQ shows Brand Rank, Brand Heat, idle/cash feedback, Luxe guidance, and a clear next action.
3. Open Atelier from the Designer first objective.
4. Complete the interaction gate and mint one Alpha.
5. Preview the Alpha and confirm Hype, style signals, and Vex opt-in are visible.
6. Drop the Alpha to Feed and confirm no raw backend errors appear.
7. Confirm the Vex reveal appears before the Flame launch scene when opted in.
8. Confirm the launch scene shows the drop name, Hype, result deltas, and next objective.
9. Enter Global Feed and confirm the new Alpha drop appears.
10. Return to HQ and confirm Brand Heat, latest drop feedback, and next objective reflect the drop.

Supabase Auth, Storage, Realtime, and Edge Function behavior remain separate checks. Authentication success must not be treated as proof of gameplay authority, RLS isolation, Storage isolation, or notification delivery.

Result: **Passed** only for directly observed behavior. A route, widget, provider, or schema alone is **Static pass**, not runtime completion.

## 5. Android build and device/emulator behavior

Run the supported release build when the Android toolchain is available:

```text
flutter build apk --release
```

An APK build does not prove installation, launch, gameplay correctness, signing readiness, store-console configuration, or physical-device behavior. On an emulator or physical Android device, separately observe installation, launch, resume, portrait safe areas, touch behavior, text scaling, and background/restart behavior.

Record device model, Android version, build mode, signing state, and result label.

Result: **Passed** applies only to the directly observed build or device check being reported.

## 5A. Browser and GitHub Pages behavior — deferred

Flutter Web, Chrome runtime, GitHub Pages deployment, and public-browser
behavior are outside the current Android/iOS milestone by project-owner
decision. Do not run or require these checks in current readiness reports.

Result: **Not applicable** for the current milestone. A later, separately
authorized Web target must restore distinct compilation, browser, hosting,
authentication, RLS, Storage, Realtime, accessibility, performance, and
public-configuration checks before any browser-readiness claim.

## 6. Supabase database and migration validation

Use only an identified local or approved test environment. Do not require destructive commands against an unidentified or remote environment.

Non-destructive or environment-approved commands may include:

```text
supabase migration list
supabase functions list
supabase db lint
supabase test db
```

Use `supabase db reset` only when the target is explicitly identified as disposable and the user has authorized the reset. Never infer deployed behavior from migration text alone.

Review chronological migration ordering, function replacement compatibility, constraints, indexes, grants, storage policies, realtime publication, generated types, server timestamps, transactions, locks, and stable result contracts.

Result: **Static pass** is appropriate for visual SQL inspection. **Passed** requires directly observed execution in the identified environment.

## 7. RLS and cross-player isolation

For every player-facing table and sensitive function, test or inspect:

- RLS enabled and intentional public/unauthenticated access.
- `auth.uid()` ownership checks.
- Insert ownership spoofing prevention.
- UPDATE validation of both existing and new rows.
- Cross-player SELECT, UPDATE, DELETE, and mutation denial.
- Blocked-user interaction restrictions across alternate surfaces.
- Maison role boundaries and administrative access.
- Safe `SECURITY DEFINER` search paths and schema-qualified references.
- Restricted execution grants with inappropriate public/anonymous execution revoked.

Result: **Static pass** means the policy text was inspected. **Passed** requires directly observed database tests or approved deployed-environment evidence.

## 8. Replay, duplicate-request, concurrency, and abuse testing

Test server-authoritative mutations for:

- duplicate reward claims;
- duplicate first-store and objective completion;
- repeated Gala votes and event submissions;
- concurrent purchases, sales, upgrades, and crisis resolution;
- client-selected currency, inventory, Hype, reward, progression, or timestamps;
- altered ownership IDs;
- clock changes and repeated idle settlement;
- vote abuse, rate limits, and blocked-user bypass.

Sensitive mutations must use validation, server timestamps, idempotency keys, replay protection, appropriate locks or transactions, and append-only audit evidence.

Result: **Passed** requires directly observed rejection or safe idempotent behavior. Source-only evidence is **Static pass**.

## 9. Accessibility and reduced-motion checks

For onboarding, Atelier, Ledger, HQ, Feed, Luxe, Vex, crises, and Gala, observe:

- semantic labels and logical traversal;
- focus visibility and supported input alternatives;
- touch-target size and contrast;
- text scaling and localization expansion;
- non-color state communication;
- loading, empty, error, disabled, offline, unavailable, and success states;
- reduced-motion behavior and non-animated critical information;
- reduced-transparency behavior where supported.

Result: **Passed** requires direct device or runtime observation. Static semantics inspection is **Static pass**.

## 10. Portrait viewport and mobile ergonomics

Observe supported portrait widths, safe areas, notches/system gestures, one-handed reachability, keyboard behavior where applicable, interruption, backgrounding, and resumed sessions. Critical actions must not require hover, precision gestures, or controls beneath system gestures.

Result: **Passed** requires direct viewport/device observation.

## 11. Performance and lower-end fallback observation

The target is approximately 60 fps with an approximately 16.7 ms frame budget. Profile representative screens in profile or release mode and record frame/raster evidence. Observe lower-end Android fallbacks for cloth nodes, shaders, particles, image decoding, Feed rendering, overdraw, reward animation, and expensive rebuilds.

Do not claim 60 fps, lower-end compatibility, or shader fallback from code inspection alone.

Result: **Passed** requires profile/device evidence; source-only review is **Static pass**; unavailable hardware is **Blocked**.

## 12. Evidence reporting

Every report must include:

- command or manual step;
- environment/device/database identity where relevant;
- exact result label from this protocol;
- observed output or behavior;
- limitations and unresolved uncertainty;
- separation of static, runtime, Android, database, RLS/security, accessibility, and performance evidence.

After every Codex task, update `DEVELOPMENT_STATE.md` with the current checkout,
active Feature ID, completed and blocked work, next safe action, evidence, and
prohibited scope. Add recurring failure prevention to `BOTTLENECK_LOG.md` and
completed player-facing changes to `CHANGELOG.md` when applicable.
