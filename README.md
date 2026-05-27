# The Styliste

**The Styliste** is a portrait-first mobile fashion empire game where players build a luxury fashion brand from an unknown label into a global cultural powerhouse.

Players create fashion drops, chase hype, react to trend shifts, grow their audience, manage capital, expand territory, and compete for status through the Global Feed, Atelier, Maison, and Mogul systems.

## Official Genres

- **Fashion Empire Simulator**
- **Idle / Tycoon Game**
- **Fashion Design Strategy Game**
- **Social Competition Game**
- **Mobile Management Sim**
- **Narrative-Lite Brand-Building Game**

## Game Description

The Styliste blends fashion creation, idle progression, business strategy, and social dominance into one mobile-first experience.

The player starts as an emerging fashion force and chooses how to build power:

- **Designer / Artisan path** â€” create drops, master aesthetics, chase Hype Score, and dominate the Global Feed.
- **Architect / Mogul path** â€” build stores, control districts, manage capital, and expand a luxury empire.
- **Maison path** â€” join or build elite fashion houses for prestige, co-drops, collective power, and social status.

The core fantasy is simple:

> Create fashion. Generate hype. Build wealth. Control culture.

## Goal of the Game

The goal of The Styliste is to become the most influential fashion empire in the world.

Players progress by:

- Creating and launching Alpha Drops.
- Raising Hype Score.
- Gaining followers and brand value.
- Expanding income streams.
- Competing on the Global Feed.
- Joining or building a Maison.
- Controlling districts and markets.
- Surviving crises, trend shifts, rival pressure, and public judgment.

The game is not only about making money. It is about building cultural power.

## Core Gameplay Loop

```text
Design â†’ Drop â†’ Hype â†’ Revenue â†’ Expansion â†’ Prestige â†’ Bigger Drops
```

### Designer Loop

```text
Research trends â†’ Create fashion â†’ Launch drop â†’ Get Vex review â†’ Gain hype â†’ Refine brand identity
```

### Mogul Loop

```text
Invest capital â†’ Open stores â†’ Control districts â†’ Increase cashflow â†’ Pressure rivals â†’ Expand empire
```

### Social Loop

```text
Post to Global Feed â†’ Gain reactions â†’ Compete for status â†’ Join Maisons â†’ Influence the market
```

## Key Features

- **Atelier** â€” create fashion pieces, experiment with style, fabric, color, and trend alignment.
- **Hype Score** â€” the main public performance score for drops.
- **Global Feed** â€” full-screen fashion-social arena where drops, flexes, and market reactions appear.
- **Vex Reviews** â€” editorial critic-style feedback that can boost or expose a drop.
- **Maison System** â€” prestige groups for co-drops, social power, and collective dominance.
- **Mogul Systems** â€” capital, stores, districts, cashflow, and luxury business strategy.
- **Trend Tsunami** â€” rotating fashion meta shifts that reward smart timing and adaptation.
- **Server-Authoritative Economy** â€” rewards, ownership, capital, and progression must be validated through backend logic.

## Current Status

The Styliste is currently in **alpha remediation**.

The repository contains broad feature coverage for the v6 GDD, but several gameplay, legal, security, and verification items are still alpha blockers.

Current focus:

- Security hardening.
- Supabase schema drift repairs.
- Server-authoritative economy validation.
- Global Feed visual alignment.
- Atelier and fashion fantasy improvements.
- HQ identity and post-drop feedback.
- District Warfare and Maison prestige improvements.
- Removing scaffolds, dead code, placeholder logic, and unsafe client-side mutations.

## Alpha Rules

The following are required before any system is considered production-ready:

- Gameplay must align with `THE_STYLISTE_GDD_v6.md`.
- Economy paths must be server-authoritative.
- No fake local rewards.
- No client-side ownership transfer.
- No pay-to-win progression.
- No placeholder security rules.
- No unverified Supabase schema changes.
- No exposed secrets or real credentials.
- All major systems must pass verification.

## Priority Checks

Run manually:

```bash
dart analyze
flutter analyze
flutter test
supabase db reset
supabase db lint
```

## Tech Stack

- **Flutter / Dart** â€” mobile client and UI.
- **Riverpod** â€” state management.
- **go_router** â€” app routing.
- **Flame** â€” lightweight embedded game-feel scenes.
- **Supabase PostgreSQL** â€” authoritative database.
- **Supabase RLS** â€” data access protection.
- **Supabase Edge Functions / TypeScript** â€” server-authoritative gameplay logic.
- **Firebase Auth** â€” authentication.
- **Firebase Messaging** â€” push notifications.
- **Firebase App Check** â€” abuse protection.
- **Custom shaders** â€” luxury visual effects and mobile-first polish.

## Documents

- [Game Design Document v6](THE_STYLISTE_GDD_v6.md)
- [IDE Directives](IDE_DIRECTIVES.md)
- [Manual Tasks](MANUAL_TASKS.md)
- [Project Rules](PROJECT_RULES.md)
- [Verification Protocol](VERIFICATION_PROTOCOL.md)
- [Agent Instructions](Agent.md)

## Development Direction

The projectâ€™s main directive is to reach full GDD v6 alignment across:

| Area | Target |
|---|---:|
| Core architecture | 100% |
| Server-authoritative drop loop | 100% |
| Atelier presence | 100% |
| Flame launch moment | 100% |
| HQ identity | 100% |
| Global Feed | 100% |
| Fashion fantasy | 100% |
| District Warfare | 100% |
| Maison prestige | 100% |
| Overall GDD feel | 100% |

## License

Proprietary. All rights reserved.

SkinTeethNerd Studios © 2026.
