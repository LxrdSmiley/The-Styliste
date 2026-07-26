# Flutter Web Testing and GitHub Pages Preview

## Product boundary

The Styliste remains a portrait-first Android/iOS game. Flutter Web exists for
local testing and an optional public staging preview. Browser behavior does not
prove Android/iOS installation, performance, purchases, notifications, or
release readiness.

## Implemented repository support

- `web/` contains the Flutter Web bootstrap, manifest, and favicon.
- `lib/main.dart` initializes Supabase with a public publishable key on mobile
  and Web.
- Supabase Auth owns the anonymous founder-trial identity on every platform.
- telemetry identifies Web without importing `dart:io`.
- mobile in-app purchases return an honest disabled state on Web.
- Firebase Auth, App Check, Messaging, configuration, and the FCM Edge Function
  have been removed from the active source tree.
- `.github/workflows/pages.yml` builds and uploads `build/web`; it no longer
  publishes `docs/pages`.

Source inspection is a **Static pass** only. Flutter compilation and runtime
remain **Blocked** until Smiley runs the required commands and records results.

## Local browser testing

GitHub Pages is unnecessary for local testing. Use an ignored local define file
containing only the approved development/staging Supabase URL and publishable
key, then run:

```bash
flutter clean
flutter pub get
flutter run -d chrome --dart-define-from-file=.env.json
```

Do not place a service-role key, database password, webhook secret, signing key,
purchase secret, or production credential in `.env.json`.

Observe and record:

1. startup and anonymous Supabase session creation;
2. Founder Trial navigation and refresh persistence;
3. owner-only profile/economy reads and denied cross-player access;
4. Realtime reconnect behavior;
5. route refresh/back/forward behavior;
6. unsupported purchase and notification states;
7. keyboard, screen-reader, text-scale, reduced-motion, and narrow viewport use;
8. browser console/network errors; and
9. frame, memory, and shader behavior on the supported browser set.

## Public Pages preview

The workflow is deliberately manual. Before dispatching **Deploy Flutter Web
Preview to GitHub Pages**, configure these GitHub repository/environment
variables:

```text
PREVIEW_ENVIRONMENT=staging
PREVIEW_SUPABASE_URL=https://<staging-project>.supabase.co
PREVIEW_SUPABASE_PUBLISHABLE_KEY=<staging publishable key>
```

The publishable key is public client configuration and will be embedded in the
browser bundle. RLS and grants provide authorization. Never substitute a secret
or service-role key.

Select `deploy_preview=true` only after the local browser and release web-build
checks pass. The workflow executes the equivalent of:

```bash
flutter build web --release \
  --base-href "/The-Styliste/" \
  --dart-define=APP_ENV=preview \
  --dart-define=SUPABASE_URL="<staging URL>" \
  --dart-define=SUPABASE_PUBLISHABLE_KEY="<staging publishable key>"
```

It uploads `build/web` through the official Pages artifact/deployment actions.
The retired project-status site is no longer a deployment source.

## Required Supabase operator checks

- use a separate staging project, not production;
- enable anonymous sign-ins only for the approved preview period;
- review anonymous-user RLS because anonymous users have the `authenticated`
  Postgres role;
- keep the anonymous-sign-in rate limit conservative;
- add CAPTCHA/Turnstile before broader public acquisition traffic;
- configure the Pages origin and localhost redirect URLs before adding any auth
  method that uses redirects;
- confirm Storage and Realtime policies independently; and
- monitor and clean abandoned anonymous staging accounts.

## Evidence labels

- Web files/workflow inspected: **Static pass**.
- `flutter build web` observed: **Passed** for compilation only.
- `flutter run -d chrome` flow observed: **Passed** for that browser/environment.
- Pages workflow completed: **Passed** for deployment only.
- Public URL tested: **Passed** for the exact tested browser and flow only.

None of these labels promote mobile, RLS, purchase, notification, performance,
penetration, Alpha, Beta, or production readiness automatically.
