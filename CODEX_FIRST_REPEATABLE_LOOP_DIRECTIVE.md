# CODEX_FIRST_REPEATABLE_LOOP_DIRECTIVE.md

## Status

Approved with one hard gate:

```text
Runtime work must not start until ui/initial-prototype-assembly passes verification, smoke QA, and is merged.
```

The main Codex goal is now:

```text
Make The Styliste's first repeatable mobile loop a real game loop:

Create Drop -> Publish -> Earn -> Upgrade / Claim -> Unlock Next Visible Thing
```

This matches the external audit's core warning: the current strongest hook is the Designer drop loop, but the surrounding empire systems risk feeling larger than the playable loop currently supports. The fix is a brutally clear first 5 minutes: one clear action, one satisfying result, one visible upgrade, and one reason to return.

---

## Directive 0: Canonical directive cleanup

On:

```text
ui/initial-prototype-assembly
```

Do only:

```text
1. Remove untracked GAMEPLAY_DIRECTIVE.md.
2. Add CODEX_FIRST_REPEATABLE_LOOP_DIRECTIVE.md.
3. Use the stricter First Repeatable Loop directive as the canonical gameplay directive.
4. Do not modify runtime code.
5. Do not modify IDE_DIRECTIVES.md or MANUAL_TASKS.md unless they are already tracked and explicitly required.
```

Commit:

```text
docs: add first repeatable loop directive
```

Allowed files:

```text
CODEX_FIRST_REPEATABLE_LOOP_DIRECTIVE.md
```

If `GAMEPLAY_DIRECTIVE.md` is untracked, delete it locally and do not commit it.

Test:

```bash
git status --short
git diff --check
```

Acceptance:

```text
Only the canonical directive file is staged/committed.
No runtime files changed.
No Supabase files changed.
No test files changed.
```

---

## Directive 1: Branch gate before runtime work

After the directive cleanup commit, stop.

Smiley runs:

```bash
git status --short
flutter analyze
flutter test
supabase db reset --local
supabase db lint --local
supabase test db
```

Manual smoke test:

```text
onboarding -> HQ -> Atelier -> mint -> Drop Preview -> Vex/no Vex -> Drop Launch -> Feed -> HQ feedback
```

If green:

```bash
git checkout master
git merge ui/initial-prototype-assembly
git checkout -b gameplay/first-repeatable-loop
```

Do not begin runtime work on `ui/initial-prototype-assembly`.

---

## Directive 2: Codex mini-agent structure

Codex may create mini agents, but mini agents are audit/planning workers first.

Required mini-agent output:

```text
files inspected
blockers found
exact proposed fix
risk level
tests required
human decision required: yes/no
```

Mini agents must not edit overlapping files simultaneously.

Main Codex agent applies final changes sequentially after reviewing findings.

---

## Directive 3: Commit 1 - audit only

On:

```text
gameplay/first-repeatable-loop
```

Commit:

```text
docs: audit first repeatable loop blockers
```

Create:

```text
docs/audits/FIRST_REPEATABLE_LOOP_AUDIT.md
```

Audit sections:

```text
1. Idle income invocation
2. Brand Rank / XP progression
3. Mogul first playable action
4. First objective clarity
5. Route / dead gameplay audit
6. First-loop regression test plan
```

No runtime changes.

Codex must stop after this commit if any of these require design choice:

```text
idle backend function is missing entirely
Brand Rank needs schema design beyond Ranks 1-10
open_first_store conflicts with existing store economy
route cleanup risks deleting future systems
```

---

## Directive 4: Commit 2 - idle income authority

Commit:

```text
fix: align idle income invocation with backend authority
```

Goal:

```text
IdleEngineService must call the actual server-authoritative idle income backend path.
```

Likely required fix:

```text
Call process_idle_income as a Supabase RPC, not through client.functions.invoke.
Normalize returned table/object shape into IdleIncomeResult.
```

Allowed files after audit:

```text
lib/core/services/idle_engine_service.dart
lib/core/constants/supabase_constants.dart
test/**
supabase/tests/**
```

Forbidden:

```text
no new idle math
no client-side revenue writes
no new monetization
no fake offline income
```

Test requirements:

```text
Flutter/unit test for call shape or result normalization.
Supabase test if backend shape needs assertion.
```

---

## Directive 5: Commit 3 - early Brand Rank progression

Commit:

```text
feat: add server-authoritative early Brand Rank progression
```

Goal:

```text
A player can rank up through normal server-confirmed drop XP.
```

Scope:

```text
Ranks 1-10 only
1000 XP = one rank
brand_rank = clamp(floor(total_xp / 1000) + 1, 1, 10)
```

Required server output:

```text
current_rank
xp_delta
rank_progress_percent
rank_up_occurred
```

Rules:

```text
server calculates rank
client displays only confirmed values
no paid acceleration
no Rank 11+ unlock expansion
no client-side XP/rank writes
```

Test:

```text
drop grants XP
XP threshold increments rank
rank progress remains bounded
rank does not skip incorrectly
duplicate drop does not duplicate rank reward
```

---

## Directive 6: Commit 4 - Mogul first playable action

Commit:

```text
feat: add Mogul first playable economy action
```

Decision:

```text
Use Option B: open_first_store action.
```

Goal:

```text
Mogul path has one real server-authoritative first action instead of a dead Ledger.
```

Backend behavior:

```text
create exactly one starter store for the authenticated owned player if they have no stores
type = ecommerce
city = player.hq_city
tier = 1
revenue_per_hour = 500
market_share = 0
capital cost = 0 for first playable scope
idempotent
```

Allowed implementation areas after audit:

```text
supabase/migrations/**
supabase/tests/**
supabase/functions/process-transaction/**
lib/features/ledger/**
lib/features/hq/widgets/hq_architect_view.dart
lib/features/ftue/**
```

Forbidden:

```text
no fake local stores
no client revenue mutation
no District/Equity/Gala hooks
no broad Ledger redesign
```

Test:

```text
first call creates one owned starter store
second call does not duplicate
cross-player store creation fails
Ledger empty state CTA triggers server path
Realtime/store stream remains source of truth
```

---

## Directive 7: Commit 5 - first objective clarity and route scope

Commit:

```text
refactor: clarify first objectives and locked systems
```

Designer first objective:

```text
Open Atelier -> Mint Alpha -> Drop to Feed -> Return HQ -> Next Objective
```

Mogul first objective:

```text
Open Ledger -> Open First Store -> See Asset -> Return HQ -> Next Objective
```

Required cleanup:

```text
remove stale premium path-switching copy
hide or lock late-game first-session distractions
remove active CTAs into disconnected mini-games
keep future systems as locked previews only when needed
```

Future-locked systems:

```text
Maison expansion
District
Gala
Equity / IPO
AR
hostile takeovers
storefront monetization
disconnected mini-games
```

Do not delete large future systems without approval.

---

## Directive 8: Commit 6 - first-loop regression tests

Commit:

```text
test: cover first repeatable loop progression
```

Required tests:

```text
idle RPC invocation/result shape
first drop XP/rank update
bounded rank progress
first-store creation idempotency
Designer objective routing
Mogul first action CTA
Drop Preview duplicate-submit guard
first-loop route reachability
inactive systems not presented as active first-session objectives
```

Update:

```text
docs/audits/FIRST_REPEATABLE_LOOP_AUDIT.md
```

with:

```text
covered by automated tests
covered by Supabase tests
manual-only verification
remaining deferred systems
```

---

# ACCEPTANCE_CRITERIA.md

## First-loop promise

A new player must complete:

```text
HQ -> Atelier -> Mint Alpha -> Drop Preview -> Vex/no Vex -> Drop Launch -> Feed -> HQ Feedback -> Claim/Earn/Upgrade -> Next Objective
```

## Must be true

```text
first Vex/drop result reachable quickly
first reward is server-confirmed
Brand Rank progresses server-side
idle income claim path works
Mogul has one real first playable action
HQ shows what changed
HQ shows what to do next
advanced systems are hidden or locked
no duplicate drops
no duplicate rewards
no fake final metrics
```

## Must not happen

```text
raw Supabase/RPC/JWT/null/500 errors shown to player
client writes followers, XP, rank, heat, revenue, rewards, or stores directly
Maison/District/Gala/Equity appears as active first-session gameplay
paid mechanics affect competitive progression
Codex adds broad polish before fixing loop foundations
```

---

# MANUAL_TASKS.md

## Smiley runs all verification

Codex does not claim local command success unless Smiley provides output.

Smiley runs after each implementation commit:

```bash
git diff --check
flutter analyze
flutter test
supabase db reset --local
supabase db lint --local
supabase test db
```

## Required manual smoke test after implementation

```text
1. Launch app.
2. Complete onboarding.
3. Enter HQ as Designer.
4. Open Atelier.
5. Mint Alpha.
6. Drop to Feed.
7. Confirm Vex/Feed result.
8. Return HQ.
9. Confirm XP/rank/heat/follower/idle deltas are server-confirmed.
10. Confirm next objective appears.
11. Start or switch to Architect/Mogul path.
12. Complete Open First Store.
13. Confirm Ledger/HQ shows real owned store or revenue change.
14. Claim idle income.
15. Confirm no raw backend errors.
16. Confirm no duplicate drop/reward.
```

## Current decision

```text
Proceed with the canonical directive cleanup first.
Runtime work waits until ui/initial-prototype-assembly is verified, smoke-tested, and merged.
Codex's main goal is the first repeatable mobile loop, not broad empire expansion.
```
