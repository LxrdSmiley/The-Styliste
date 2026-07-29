# The Styliste development state

Last updated: 2026-07-29
Updated by: Codex Founder Trial remote-unblock task

## Authority and milestone

- Canonical authority: `THE_STYLISTE_GDD_v8.md`, then the ranked companion
  authorities in `docs/verification/authority_inventory.json`, followed by
  `PROJECT_RULES.md` and `VERIFICATION_PROTOCOL.md`.
- Current milestone: Gate A Wave 2A — Kingston Capsule Foundation with the
  complete reachable Aurelian UI expansion.
- Starting SHA: `c4405414195f5bcdff87b31848c3425a17e76e85`.
- Implementation branch: `codex/aurelian-ui-expansion-pass-2`.
- Implementation SHA: `717e41faecda9798b4a29eb01f8cba85ab7aac2f`.
- Active Feature ID: `LOOP-02`.
- Release promotion: `Blocked`.

## Current evidence status

| Evidence | Status | Latest result |
|---|---|---|
| Local source verification | `Passed` | Formatting covers 229 files; analysis has no issues; 135 Flutter tests passed. |
| Deterministic visual evidence | `Passed` | 24 before-renders, 44 after-renders, and four contact sheets are committed and indexed. |
| Local security verification | `Passed` | Gitleaks 8.30.1 scanned 101 commits and the final 11.38 MB working tree with zero findings. |
| Migration integrity | `Passed` | 61/61 raw-byte hashes and 9/9 tamper scenarios passed. |
| Local database authority | `Passed` | Reset, lint, 12 pgTAP files / 108 assertions, four 20-session economic cases, and 19-entry API inventory passed. |
| Edge verification | `Passed` | 17 entry points type-check and 16 identity/contract tests pass. |
| Remote migration deployment | `Passed` | The authorized 13-migration `--include-all` push completed without seeds or role-file changes; remote history now matches 61/61 local versions. |
| Remote Founder Trial Function | `Passed` | `founder-trial` is `ACTIVE` with JWT verification enabled; an unauthenticated request returned HTTP 401. |
| Remote Data API boundary | `Passed` | The hosted service now exposes the reviewed `api` schema. A redacted probe no longer returns `PGRST106`; unauthenticated schema access reaches the database boundary and is denied with HTTP 401. |
| Remote Auth configuration | `Static pass` | The CLI configuration command synchronized the repository Auth settings while applying the Data API correction. Anonymous sign-in is enabled and email sign-up is disabled, but remote Auth runtime scenarios were not executed. |
| Remote database advisors | `Passed` | The linked advisor run exited 0 with 0 errors and 75 warnings (52 security, 23 performance); warnings remain non-release evidence requiring later review. |
| Galaxy A55 Founder Trial | `Blocked` | Pre-deployment attempts returned HTTP 404. The first post-deployment attempts authenticated successfully but failed with HTTP 400 because PostgREST rejected the unexposed `api` schema with HTTP 406 / `PGRST106`. The post-correction device retry still requires Smiley observation. |
| Implementation branch publication | `Passed` | Normal upstream push of implementation SHA succeeded. |
| GitHub Actions | `Blocked` | GitHub reported zero matching branch runs; no workflow was dispatched. |
| Android/iOS builds | `Blocked` | Creator direction; not performed. |
| Flutter Web build/runtime | `Blocked` | Directive boundary; not performed. |
| Physical-device accessibility | `Blocked` | Not performed. |
| Physical-device performance | `Blocked` | Not performed. |
| Remote Supabase | `Passed` | The explicitly authorized project received the 13 pending migrations; the inventory is now 61/61. |
| Deployment | `Passed` | The 13 migrations and `founder-trial` Function were deployed. The reviewed Data API and repository Auth configuration were also synchronized; the broader configuration write is disclosed in B-041. |
| Final visual approval | `Blocked` | Pending Smiley review of expansion-pass renders. |
| Production release | `Blocked` | Device, staging, human, and release evidence remain required. |

## Completed work

### UI/UX skill usage — HQ null-projection hotfix

- Skills discovered: `flutter-expert`, `visual-testing`,
  `accessibility-compliance`, plus the previously installed Aurelian UI skills.
- Skills invoked: `flutter-expert`, `visual-testing`,
  `accessibility-compliance`.
- Recommendations accepted: Dart null-safe boundary parsing, a focused
  regression fixture matching the remote payload, preservation of the
  established House Pulse presentation, and a player-safe reliability state
  instead of a framework error surface.
- Recommendations rejected: new visual baselines, a new UI package, and a
  House Pulse redesign; this defect does not require those changes.
- Authority for rejection: GDD v8, existing Aurelian components, the current
  Riverpod/repository boundary, and minimal hotfix scope.

- Expanded every currently reachable Gate A screen family with stronger
  Aurelian hierarchy, editorial context, progress/consequence evidence,
  progressive disclosure, and player-safe reliability states.
- Preserved the exact shell order: HQ, Atelier, Empire, Feed, House.
- Made Atelier and the three-look capsule visually garment-centered through
  pattern-cutting linework, role-specific silhouettes, bounded inspectors, and
  explainable readiness.
- Kept Founder Trial Artisan/Architect presentation distinct with equal
  gameplay ceilings and server-confirmed/restored receipts.
- Added all 14 required shared reliability states with explicit authority,
  preservation, retry safety, and next action.
- Added 320–412 px, large-text, reduced-motion, semantics, route, overflow,
  provider-state, and restoration coverage.
- Installed and locked the four requested standalone accessibility,
  responsive-layout, design-system, and visual-testing skills.
- Preserved Riverpod ownership and Supabase authority; no database, migration,
  RPC, Edge, policy, ledger, progression, or reward implementation changed.
- Published implementation commit
  `717e41faecda9798b4a29eb01f8cba85ab7aac2f` to the dedicated branch.
- Updated the standalone Supabase CLI from 2.104.0 to checksum-verified 2.110.0
  and refreshed the official Supabase agent skills.
- Applied the explicitly authorized 13 pending migrations to the configured
  remote project using `--include-all`, without seeds or role-file changes.
- Deployed only the `founder-trial` Edge Function with JWT verification
  enabled and confirmed all 61 migration versions match remotely.
- Confirmed the original A55 failure was a missing remote endpoint: captured
  pre-deployment Founder Trial requests returned HTTP 404.
- Confirmed the next failure was hosted Data API drift: authenticated Edge
  requests reached the Founder Trial RPC but PostgREST returned HTTP 406 /
  `PGRST106` because `api` was not exposed.
- Activated the reviewed hosted `api` schema boundary and confirmed anonymous
  callers reach its permission boundary instead of the schema-selection error.
- Recorded that the CLI configuration command also synchronized repository
  Auth settings even though it was invoked with a piped negative response
  intended only to inspect the diff.

## Blocked work

- Smiley's final review of the expansion-pass renders.
- Android/iOS compilation, installation, signing, physical accessibility, and
  Galaxy A55-class performance.
- Flutter Web compilation/runtime unless separately reauthorized.
- Authenticated A55 completion of the Founder Trial path after the hosted Data
  API correction.
- Full deployed Supabase Auth/RLS/Realtime/Storage/Edge isolation,
  penetration testing, and release-eligible CI beyond this focused deployment.
- Legal/privacy, Jamaican/Caribbean cultural, fashion-industry, final
  art/audio, representative-player, retention, monetization, and release
  review.

## Next safe action

Smiley taps **Begin the Founder Trial** or **Retry the same step** once on the
existing Galaxy A55 screen and reports whether it advances from step 0/6 to
step 1/6. After that focused runtime check, the visual-review task in
`MANUAL_TASKS.md` remains.

## Prohibited scope

No direct push to `master`, force-push, pull request, workflow dispatch,
additional deployment or remote Supabase/configuration operation, tag,
release, secret material, client-owned authority, or release-readiness claim
is authorized by this record.
