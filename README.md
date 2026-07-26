# The Styliste

**The Styliste** is a mobile fashion empire game centered on portrait-first gameplay, where players build a luxury fashion brand from an unknown label into a global cultural powerhouse.

Players will create fashion drops, pursue hype, react to trend shifts, grow their audience, manage capital, expand territories, and compete for status through the Global Feed, Atelier, Maison, and Mogul systems.

## Official Genres

- **Fashion Empire Simulator**
- **Idle / Tycoon Game**
- **Fashion Design Strategy Game**
- **Social Competition Game**
- **Mobile Management Simulation**
- **Narrative-Lite Brand-Building Game**

## Game Description

The Styliste combines fashion creation, idle progression, business strategy, and social dominance into one mobile-first experience.

Players begin as emerging fashion forces and choose how to build their influence:

- **Designer / Artisan Path:** Create drops, master aesthetics, chase Hype Score, and dominate the Global Feed.
- **Architect / Mogul Path:** Build stores, control districts, manage capital, and expand a luxury empire.
- **Maison Path:** Join or establish elite fashion houses for prestige, collaborate on drops, leverage collective power, and gain social status.

The core fantasy is simple:

> Create fashion. Generate hype. Build wealth. Control culture.

## Goal of the Game

The goal of The Styliste is to become the most influential fashion empire in the world.

Players progress by:

- Creating and launching Alpha Drops.
- Increasing their Hype Score.
- Gaining followers and enhancing brand value.
- Expanding income streams.
- Competing on the Global Feed.
- Joining or founding a Maison.
- Controlling districts and markets.
- Navigating crises, trend shifts, rival pressures, and public judgment.

The game focuses not only on financial success but on building cultural power as well.

## Core Gameplay Loop

```text
Design → Drop → Hype → Revenue → Expansion → Prestige → Bigger Drops
```

### Designer Loop

```text
Research Trends → Create Fashion → Launch Drop → Receive Vex Review → Gain Hype → Refine Brand Identity
```

### Mogul Loop

```text
Invest Capital → Open Stores → Control Districts → Increase Cash Flow → Pressure Rivals → Expand Empire
```

### Social Loop

```text
Post to Global Feed → Gain Reactions → Compete for Status → Join Maisons → Influence the Market
```

## Key Features

- **Atelier:** Create fashion pieces and experiment with style, fabric, color, and trend alignment.
- **Hype Score:** The primary public performance metric for drops.
- **Global Feed:** A full-screen, fashion-social arena where drops, highlights, and market reactions are displayed.
- **Vex Reviews:** Critiques that can either boost a drop's success or expose its weaknesses.
- **Maison System:** Prestigious groups for co-drops, social power, and collective dominance.
- **Mogul Systems:** Strategies for managing capital, stores, districts, cash flow, and luxury business.
- **Trend Tsunami:** Rotating fashion meta shifts that reward timely and strategic adaptations.
- **Server-Authoritative Economy:** Rewards, ownership, capital, and progress must be validated through backend protocols.

## Current Status

Current development version: `0.1.0-alpha.1+1` (**unreleased**).

The Styliste is in **Kingston Early Game repository remediation**, not public
Alpha, Beta, or production. The current dirty working tree contains broad
server-authority, RLS, FTUE, route-containment, CI, and verification changes
that have not yet been approved as a commit or GitHub Release.

Current priorities are:

- complete the Supabase-only authentication migration;
- preserve server authority for economy, progression, ownership, Hype, and rewards;
- finish the Luxe-led Kingston Founder Trial and proof-of-fun loop;
- expand owner/stranger/blocked/former-member security tests;
- obtain Android/iOS device, accessibility, and performance evidence; and
- keep Gala, territory, Casting, trading, DMs, AR, ads, and other late-wave
  systems disabled.

## Alpha Rules

The following requirements must be met before any system can be considered production-ready:

- Gameplay must align with `THE_STYLISTE_GDD_v7.md`.
- Economic paths must be server-authoritative.
- No fake local rewards.
- No client-side ownership transfers.
- No pay-to-win progression.
- No placeholder security rules.
- No unverified Supabase schema changes.
- No exposed secrets or real credentials.
- All major systems must pass the applicable verification evidence gates.

## Priority Checks

Run only against an identified local or approved test environment:

```bash
dart format --output=none --set-exit-if-changed .
dart analyze
flutter analyze
flutter test
supabase db lint
```

`supabase db reset` is destructive and must only be used against an explicitly identified disposable database with authorization. An analyzer result is not runtime proof; Flutter tests do not prove Android behavior; an APK build does not prove installation or gameplay correctness; SQL inspection does not prove deployed RLS behavior; and a Git push does not deploy Supabase changes.

## Tech Stack

- **Flutter + Dart:** Mobile client and user interface.
- **Riverpod:** State management solution.
- **go_router:** Application routing.
- **Flame:** Lightweight embedded game-feel scenes.
- **Supabase:** Authoritative backend for gameplay records, ownership, Postgres, RPC, RLS, real-time data synchronization, media storage, economy, progression, and sensitive settlement.
- **Supabase Edge Functions / TypeScript:** Server-side orchestration and validated gameplay operations; PostgreSQL remains authoritative for transactional state.
- **Supabase Auth:** The only approved player identity system across Android
  and iOS, including anonymous founder-trial sessions.
- **Flutter in_app_purchase:** Framework for managing mobile purchases.
- **PostHog:** Optional future analytics solution, subject to privacy controls and legal documentation.
- **CodeRabbit:** Development-only PR review tooling.
- **Custom shaders:** Luxury visual effects and mobile-first polish.

## Documents

- [Canonical Game Design Document v7](THE_STYLISTE_GDD_v7.md)
- [IDE Directives](IDE_DIRECTIVES.md)
- [Manual Tasks](MANUAL_TASKS.md)
- [Project Rules](PROJECT_RULES.md)
- [Verification Protocol](VERIFICATION_PROTOCOL.md)
- [Agent Instructions](Agent.md)
- [Development State](DEVELOPMENT_STATE.md)
- [Changelog](CHANGELOG.md)
- [Release Process](docs/RELEASE_PROCESS.md)

## Supported Client Targets

The current milestone targets Android and iOS only. Flutter Web, Chrome runtime,
and GitHub Pages are deferred by project-owner decision and are not required for
the mobile authentication/readiness commit.

## Versioning, Releases, and Deployments

- `pubspec.yaml` owns the application version.
- `CHANGELOG.md` records unreleased changes and release history.
- `DEVELOPMENT_STATE.md` records current implementation/evidence after every task.
- `docs/releases/` contains version-specific release notes.
- `.github/workflows/draft-release.yml` creates a guarded **draft prerelease**
  only after the current commit has a successful readiness workflow.

Version bumps occur at coherent release boundaries, not after every commit.
GDD v7 is a design-document version and is independent of the application
version.

## Development Direction

Development follows GDD v7 §21 one wave at a time. The current target is the
Kingston proof-of-fun loop: Luxe-led Founder Trial → garment decision → release
→ credible reaction → targeted revision → first-store diagnosis → recovery or
improvement. Canonical multiplayer, Milan, Gala, territory, trading, and other
future systems do not become current implementation scope merely because they
exist in the GDD.

## License

Proprietary. All rights reserved.

SkinTeethNerd Studios © 2026.
