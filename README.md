# The Styliste

Portrait-first mobile hybrid idle and tycoon fashion empire simulator.

The Styliste is currently in alpha remediation. The repository contains broad
feature coverage for the v6 GDD, but several gameplay, legal, security, and
verification items are still alpha blockers. Treat the GDD and
`IDE_DIRECTIVES.md` as the acceptance source for what is production-ready.

## Current Status

- Alpha audit in progress.
- Security hardening and schema drift repairs are being applied before gameplay polish.
- Server-authoritative economy paths are required for capital, hype, rewards, and ownership transfer.
- Several aspirational modules are disabled or unavailable in alpha until they have real implementation and tests.

## Priority Checks

```bash
dart analyze
flutter analyze
flutter test
supabase db reset
supabase db lint
```

## Tech Stack

- Flutter, Dart, Riverpod, and go_router
- Supabase PostgreSQL, RLS, and Edge Functions
- Firebase Auth, Firebase Messaging, and App Check
- Custom shaders and mobile-first UI surfaces

## Documents

- [Game Design Document v6](THE_STYLISTE_GDD_v6.md)
- [IDE Directives](IDE_DIRECTIVES.md)
- [Manual Tasks](MANUAL_TASKS.md)
- [Project Rules](PROJECT_RULES.md)
- [Verification Protocol](VERIFICATION_PROTOCOL.md)

## License

Proprietary. All rights reserved. SkinTeethNerd Studios (c) 2026.
