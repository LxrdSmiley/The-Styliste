# GDD v8 Kingston Governance Transition Implementation Plan

> **Historical, non-authoritative record.** This inherited plan preserves the
> governance transition context that preceded the approved Wave 2A Aurelian
> redesign. It must not override the current root `IDE_DIRECTIVES.md`,
> `DEVELOPMENT_STATE.md`, `PROJECT_RULES.md`, or `VERIFICATION_PROTOCOL.md`.
> Its former instruction that Codex not run Flutter/Dart commands was
> superseded by the creator-approved local verification directive.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish a durable, evidence-bound GDD v8 governance baseline for
the Kingston proof-of-fun slice without changing gameplay, database authority,
dependencies, or release state.

**Architecture:** GDD v8 and its companion bibles define product intent;
`PROJECT_RULES.md` defines the approved technical stack; and
`VERIFICATION_PROTOCOL.md` separates static, runtime, database, device, and
human evidence. `DEVELOPMENT_STATE.md` is the active implementation record;
the GDD v7 security/audit account remains historical evidence and must not be
discarded to make Gate A appear complete.

**Tech Stack:** Flutter/Dart, Riverpod, Supabase Auth/PostgreSQL/RLS/Storage/
Realtime/RPCs/Edge Functions, Markdown governance records.

## Global Constraints

- Use only Flutter, Dart, Riverpod, Supabase Auth, PostgreSQL, RLS, Storage,
  Realtime, PostgreSQL functions, and Edge Functions.
- Do not add Firebase, another backend, another state-management framework, or
  a second design system.
- The client submits intent only; server-owned state includes identity, money,
  rewards, score, ownership, and time.
- Work only on the Kingston proof-of-fun slice: no additional city, broad
  multiplayer, territory, Maison Wars, marketplace, advanced finance, ads, or
  full monetization.
- Every later implementation task declares GDD v8 Feature ID, wave, player
  unlock band, dependencies, owner, feature flag, acceptance criteria, and
  evidence before code changes begin.
- Codex must not run Dart or Flutter commands. Smiley supplies observed output
  for every Flutter/Dart result.
- Use only `Passed`, `Failed`, `Blocked`, `Static pass`, or `Not applicable`
  as verification labels.

---

## Scope boundary

This plan covers the governance transition and Gate A recovery only. Gates B
(secure foundation), C (UI foundation), D (Kingston vertical slice), and E
(human validation) are independent implementation programs; each requires a
separate approved plan after the baseline is clean. No feature code belongs in
this plan.

### Task 1: Establish the v8 authority record

**Files:**

- Modify: `IDE_DIRECTIVES.md`
- Modify: `MANUAL_TASKS.md`
- Modify: `PROJECT_RULES.md`
- Modify: `Agent.md`
- Modify: `DEVELOPMENT_STATE.md`

**Interfaces:**

- Consumes: the existing `THE_STYLISTE_GDD_v8.md` and its seven companion
  product authorities.
- Produces: one unambiguous authority chain and one current Gate A milestone
  record for future implementation tasks.

- [x] **Step 1: Replace the stale v7 audit decision with the v8 production decision.**

  Required content: name GDD v8 and the seven companion bibles as product
  authority; preserve v6/v7 only as historical context; state that the game is
  design-complete enough to build but not complete, proven fun, or ready for
  promotion.

- [x] **Step 2: Record the Kingston-only scope.**

  Required content: the slice begins with House creation and Luxe, samples both
  Founder Paths, establishes a three-look Kingston capsule, opens one store,
  releases it, receives named reactions, encounters one imperfection, chooses
  one recovery, and archives the result. Explicitly defer cities beyond
  Kingston, social expansion, territory, marketplace, advanced finance, ads,
  and full monetization.

- [x] **Step 3: Record Gate A as the current milestone.**

  Required content in `DEVELOPMENT_STATE.md`: current commit, active Feature ID
  of `None` for this governance-only transition, completed documentation work,
  blocked evidence, next safe action, and prohibited scope. Preserve GDD v7
  security/audit facts below it as historical evidence.

- [ ] **Step 4: Inspect the documentation diff.**

  Run:

  ```powershell
  Set-Location '<repository-root>'
  git diff --check
  git diff --name-status
  git status --short
  ```

  Expected: only the intended governance and plan files are modified; no
  whitespace error; no Feature ID, runtime, database, device, or release claim
  is promoted.

### Task 2: Re-establish the Gate A verification baseline

**Files:**

- Inspect: `pubspec.yaml`
- Inspect: `analysis_options.yaml`
- Inspect: `supabase/config.toml`
- Inspect: `supabase/migrations/`
- Modify after observed results only: `DEVELOPMENT_STATE.md`
- Modify when a recurring prevention is discovered: `BOTTLENECK_LOG.md`

**Interfaces:**

- Consumes: the exact commit selected for Gate A and a positively identified,
  disposable local Supabase environment.
- Produces: independently labeled source, Flutter, Supabase, and device
  evidence. It does not produce a feature promotion.

- [ ] **Step 1: Identify the verification target before destructive database work.**

  Record the branch, commit SHA, local project identity, and confirmation that
  the database is disposable. Do not run a reset against any linked staging or
  production project.

- [ ] **Step 2: Ask Smiley to run the smallest Flutter baseline.**

  ```powershell
  Set-Location '<repository-root>'
  flutter pub get
  dart format --output=none --set-exit-if-changed lib test integration_test
  flutter analyze
  flutter test
  ```

  Expected: record each command separately. A passing formatter or analyzer is
  `Static pass`; `flutter test` is `Passed` only when Smiley supplies the
  passing output for the exact checkout.

- [ ] **Step 3: Run Supabase checks only after the local target is identified.**

  ```powershell
  Set-Location '<repository-root>'
  supabase migration list --local
  supabase db lint --local --level error --fail-on error
  ```

  Expected: preserve the command output and database identity. A migration-text
  review is `Static pass`; successful execution on the identified local target
  is `Passed` for that check only.

- [ ] **Step 4: Update the evidence record without over-promotion.**

  Add the command, environment, exact result label, observed output, and
  limitation to `DEVELOPMENT_STATE.md`. Add a bottleneck entry only if a
  recurring failure received a permanent prevention or automated check.

### Task 3: Authorize the next implementation plan, one gate at a time

**Files:**

- Create: `docs/superpowers/plans/YYYY-MM-DD-gate-b-secure-foundation.md`
  *after Gate A is evidence-backed*
- Create: `docs/superpowers/plans/YYYY-MM-DD-gate-c-ui-foundation.md`
  *after Gate B is accepted*
- Create: `docs/superpowers/plans/YYYY-MM-DD-gate-d-kingston-vertical-slice.md`
  *after Gate C is accepted*
- Modify: `DEVELOPMENT_STATE.md`

**Interfaces:**

- Consumes: completed prerequisite-gate evidence and the exact current
  repository state.
- Produces: one scoped, testable implementation plan at a time; no combined
  multi-gate "big bang" workstream.

- [ ] **Step 1: For Gate B, select only the foundation Feature IDs.**

  Start with `TECH-01`, `TECH-02`, `SEC-01`–`SEC-06`, `ECO-02`, and the
  applicable `IDLE-01` contract. Define the table/function access matrix,
  server actor contract, RLS negative tests, idempotency/replay cases, and
  ledger reconciliation before changing a player-facing screen.

- [ ] **Step 2: For Gate C, select only the UI foundation Feature IDs.**

  Limit the plan to `UI-01`–`UI-04` and the supporting `LUXE-01` presentation
  behavior. Load the repository `frontend-design` skill for player-facing UI
  work. Include portrait, text scaling, reduced motion, loading, offline,
  empty, unavailable, and error states.

- [ ] **Step 3: For Gate D, select only the Kingston causal-loop Feature IDs.**

  Limit the plan to `FTUE-01`–`FTUE-05`, `WORLD-02`, `ART-01`, `ART-02`,
  `ART-04`, `ART-06`, `ART-07`, `MOG-01`, `MOG-02`, `ECO-01`, `ECO-03`,
  `ECO-06`, `LUXE-02`, `VEX-01`, `NPC-01`, `IDLE-02`, and the necessary
  `UI-03` states. Each task must define the server-owned receipt and recovery
  behavior before UI implementation.

- [ ] **Step 4: Hold Gate E for human evidence, not code completion.**

  Prepare a protocol for uncoached representative testers, including timing to
  meaningful input, Founder Trial, causal loop, comprehension of causes,
  recovery quality, voluntary repeat behavior, Galaxy A55-class performance,
  and Jamaican/Caribbean cultural review. Mark unavailable evidence `Blocked`,
  never `Passed`.

## Self-review

- **Spec coverage:** This plan records the v8 authority freeze, correct meaning
  of development, Kingston-only scope, real completion definition, product
  pillars, and Gate A–F ordering. It intentionally does not claim that later
  gates are implemented.
- **Placeholder scan:** No implementation task uses a vague "add validation"
  instruction; each Gate B–E handoff names its specific Feature IDs, boundary,
  or required evidence.
- **Consistency:** The authority hierarchy, static-only evidence, and deferred
  scope agree across `IDE_DIRECTIVES.md`, `MANUAL_TASKS.md`,
  `PROJECT_RULES.md`, `Agent.md`, and `DEVELOPMENT_STATE.md`.

## Execution Handoff

This governance plan is complete. Do not begin Gate B, C, or D in the same
change set. First obtain the Gate A evidence in Task 2, then create and approve
one standalone plan for the next gate.
