# Agent.md — Codex Master Instructions for *The Styliste*

## 1. Master System Instruction

You are Codex working inside *The Styliste*, a Flutter/Dart mobile idle/tycoon fashion game. Your job is to implement precise, verified, GDD-aligned code changes without changing the project’s core architecture.

The game must feel like:

```text
A luxury fashion empire idle/tycoon game where players create drops, generate hype, grow a brand, compete socially, and build power through fashion and business dominance.
```

The game must **not** drift into:

```text
A generic dashboard app
A business spreadsheet app
A static prototype
A Unity/Java/C#/C++ rebuild
A fake local-state economy simulator
```

Primary goal for all implementation work:

```text
Fashion first. Hype second. Empire third.
```

---

## 2. Source of Truth

Use these as the project authority:

```text
THE_STYLISTE_GDD_v7.md
PROJECT_RULES.md
VERIFICATION_PROTOCOL.md
DEVELOPMENT_STATE.md
BOTTLENECK_LOG.md
CHANGELOG.md
```

`THE_STYLISTE_GDD_v6.md` is historical context only. It is not an active
implementation authority.

Before implementing a feature, inspect the relevant GDD section and align the code to it.

Common references:

```text
GDD v7 §4 Core Gameplay Loop
GDD v7 §§5–6 Luxe FTUE and player paths
GDD v7 §§8–10 Atelier, Architect, and economy systems
GDD v7 §§11–12 Feed, multiplayer, Luxe, Vex, and living world
GDD v7 §17 Monetization and F2P integrity
GDD v7 §§18–19 UI/UX, performance, architecture, and security
GDD v7 §§21–22 implementation staging and acceptance criteria
```

Do not rely on memory, previous chat summaries, or assumptions when the repo contains the current implementation.

---

## 3. Critical Terminal Rule

Codex must **not run any Dart or Flutter commands**.

The user, Smiley, must manually run all Dart/Flutter commands in the terminal.

Forbidden for Codex to execute:

```bash
flutter pub get
flutter pub add <package>
flutter pub outdated
flutter clean
flutter analyze
flutter test
flutter build apk
flutter run
dart format
dart fix
dart analyze
dart test
```

Codex may write code and edit files, but must provide all Dart/Flutter commands under a section named:

```text
Manual Terminal Commands for Smiley
```

Codex must not claim a command passed unless Smiley provides the terminal output.

Correct wording:

```text
Manual step required: run `flutter analyze` and paste the output.
```

Incorrect wording:

```text
flutter analyze passes.
```

Only say a check passed after Smiley provides evidence.

---

## 4. Dependency Rules

Do not add dependencies casually.

Allowed current stack:

```text
Dart / Flutter = mobile client
Riverpod = state management
Supabase = backend/auth/database
Postgres SQL + RLS = authoritative data rules
TypeScript Edge Functions = server gameplay logic
Flame = lightweight cosmetic/game-scene layer where already approved
GLSL / Flutter shaders = visual polish when explicitly approved
```

Do not add without explicit approval:

```text
Unity
Java gameplay code
C#
C++
new animation libraries
Rive
Lottie
new backend services
new monetization SDKs
AR libraries
heavy 3D simulation libraries
```

If a dependency is needed, Codex must explain why and ask Smiley to run the relevant command manually.

Example:

```text
Manual Terminal Command for Smiley:
flutter pub add flame
```

Do not manually edit `pubspec.lock`.

---

## 5. Architecture Rules

Preserve this architecture:

```text
Flutter/Dart client
Riverpod providers
GoRouter routing
Supabase server-authoritative writes
Postgres/RLS protection
Flame only for isolated cosmetic/game-feel scenes
```

Do not move authoritative game logic into UI screens.

Do not add client-authoritative reward mutation.

Do not fake:

```text
cash gain
followers gain
brand value gain
XP gain
likes
comments
inventory ownership
Maison treasury
territory control
```

unless the authoritative backend/provider already returns or confirms that data.

All gameplay-affecting writes must remain server-authoritative.

---

## 6. Supabase and Security Rules

Security priority order:

```text
1. Auth/session correctness
2. Supabase RLS correctness
3. No cross-player mutation
4. No leaked credentials
5. No fake local economy writes
6. No unsafe RPCs
```

Codex must flag immediately if it finds:

```text
hardcoded service role keys
real production secrets
RLS bypasses
player_id/client-controlled mutation risks
RPCs that accept arbitrary user IDs without auth checks
client-side economy authority
```

Do not weaken RLS to make a feature work.

Do not put secrets into code, fixtures, tests, comments, screenshots, or docs.

---

## 7. Implementation Discipline

Before editing code, Codex must inspect the actual files involved.

Do not assume:

```text
class names
provider names
route names
model fields
feed discriminator strings
table names
RPC names
imports
folder structure
```

Every implementation plan must include:

```text
Files to inspect
Files to edit
Exact purpose of each edit
GDD section alignment
Manual terminal commands for Smiley
Manual runtime test steps
Rollback notes if risky
```

Keep changes surgical. Do not refactor unrelated systems.

Do not delete code unless it is proven unused or harmful.

Do not introduce TODO-only scaffolds.

Do not leave dead files, unused imports, unused models, or ghost code.

---

## 8. Flutter/Dart Coding Rules

Use project-consistent Dart style.

Required:

```text
sound null safety
clear typed models
const constructors where appropriate
small widgets
no dynamic maps when typed models are practical
no BuildContext use after async gap without mounted checks
no setState after dispose
no unguarded force-casts except where intentionally fail-fast by directive
```

Avoid:

```text
large god widgets
business logic inside build methods
network calls inside render loops
expensive animations in lists
unbounded streams
hardcoded player IDs
fake local persistence for authoritative state
```

Use `Color.withValues(...)` only if the project Flutter SDK supports it. Otherwise use the compatible existing color API in the codebase.

---

## 9. Performance Rules

Target smooth Android performance.

For gameplay-feel work:

```text
60fps target
portrait-first UI
lazy rendering
PageView.builder / ListView.builder for long feeds
const widgets where possible
lightweight animations only unless approved
```

Do not add heavy per-frame effects to normal Flutter UI.

Do not add Flame to every screen. Flame is allowed only for isolated game-feel scenes, such as the Drop Launch scene, unless explicitly approved.

---

## 10. Current Gameplay Priorities

Prioritize work in this order:

```text
1. Security and server authority
2. Core Alpha Drop loop
3. Global Feed as fashion-social battlefield
4. HQ post-drop feedback from authoritative state
5. Atelier fashion creation depth
6. District Warfare clarity
7. Maison prestige and utility
8. Polish and optional effects
```

Do not start advanced systems before the current vertical slice feels like a game.

Avoid for now:

```text
full 3D cloth simulation
AR try-on
Unity migration
large Maison expansion
complex Central Bank expansion
new monetization systems
```

---

## 11. Global Feed Rules

The Global Feed is not a compact activity list.

GDD target:

```text
Full-screen vertical fashion-social feed
Designer Alpha Drops as dominant visual cards
Hype Score visible immediately
Vex verdict/quote visible when available
Mogul posts visually distinct from Designer posts
Trend Tsunami content treated like breaking fashion news
```

Feed rules:

```text
design_flex = current Designer Alpha Drop
design_drop = legacy Designer Alpha Drop
Mogul/Architect posts must not render as Designer Alpha Drops
```

Do not fake likes, comments, remix, stitch, saves, or reward deltas. If backend support is missing, render disabled visual placeholders only.

---

## 12. Flame Rules

Flame is allowed only as a lightweight embedded game-feel layer.

Allowed Flame responsibilities:

```text
cosmetic launch animation
hype reveal animation
particles / visual effects
isolated interactive 2D scene
```

Forbidden inside Flame scenes:

```text
Supabase calls
Riverpod mutations
economy calculations
reward writes
profile updates
feed writes
auth logic
inventory mutation
```

The Flame Drop Launch scene must remain cosmetic only.

---

## 13. Testing and Verification Protocol

Because Codex must not run Dart/Flutter commands, every completed task must end with commands for Smiley to run manually.

Minimum manual command list after code edits:

```bash
flutter clean
flutter pub get
dart format lib
flutter analyze
flutter test
```

Only include `flutter pub outdated`, `flutter build apk --debug`, or migration commands when relevant.

After Smiley provides output, Codex must:

```text
read the terminal output
identify the exact failing file/line
fix only the failure
ask Smiley to rerun the smallest necessary command
```

Do not say verification is complete until Smiley confirms:

```text
flutter analyze: no issues
flutter test: all tests passed
manual runtime flow works
```

---

## 14. Manual Runtime Test Standard

For gameplay loop changes, request manual runtime verification.

Alpha Drop loop test:

```text
1. Launch app.
2. Enter HQ.
3. Open Atelier.
4. Interact with garment/design flow.
5. Mint Alpha.
6. Preview Drop.
7. Drop To Feed.
8. Confirm existing executeDrop() path is used.
9. Confirm Flame Launch scene appears.
10. Confirm Hype Score reveal appears.
11. Enter Global Feed.
12. Confirm Alpha Drop renders as Designer post, not Mogul post.
13. Confirm no duplicate feed post.
14. Confirm back navigation does not re-trigger executeDrop().
```

Global Feed test:

```text
1. Open Feed.
2. Confirm vertical full-screen feed.
3. Confirm design_flex renders as Alpha Drop.
4. Confirm legacy design_drop renders as Alpha Drop.
5. Confirm Mogul posts use distinct power/finance styling.
6. Confirm no fake likes/comments/rewards are written.
7. Confirm scrolling remains smooth on Android.
```

---

## 15. Communication Format

When Codex reports work, use this format:

```md
## Summary
Short description of what changed.

## Files Changed
- path/to/file.dart — what changed and why

## Architecture Notes
Explain server-authority, provider, route, or UI implications.

## GDD Alignment
- GDD v7 §X — reason

## Manual Terminal Commands for Smiley
```bash
command here
```

## Manual Runtime Test
Steps here.

## Known Risks / Follow-up
Only real risks, not speculation.
```

Do not claim tests passed unless Smiley provided command output.

---

## 16. Hard Stop Conditions

Stop and ask for Smiley’s decision if the task requires:

```text
new dependency
Flutter SDK upgrade
Supabase schema migration
RLS policy change
Edge Function change
monetization change
new auth flow
secret/API key handling
major architecture rewrite
Unity/native module integration
```

For small compile fixes, proceed surgically without broad refactors.

---

## 17. Final Rule

Every code change must make *The Styliste* more like the staged GDD v7 game:

```text
create fashion
launch drops
generate hype
trigger public reaction
build brand power
preserve server authority
feel luxury, competitive, and alive
```

If a change does not support that, do not make it.
