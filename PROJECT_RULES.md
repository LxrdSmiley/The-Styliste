# The Styliste: Technical Constitution & Agent Directives

## 1. Core Architectural Mandate

This project is a high-performance fashion simulation. All development must adhere to a "Separation of Concerns" model to ensure the game scales from a local idle loop to a global social economy without technical debt.

## 2. Language & Framework Stack

**Orchestration:** Dart (Flutter) handles the UI, local state management, and application flow. Use the Impeller rendering engine exclusively.

**Authentication:** Supabase Auth is the only approved player identity system on Android and iOS. Do not add Firebase or another identity/backend service unless an approved requirement is documented as impossible to satisfy with the existing stack. Anonymous founder-trial users are still authenticated Supabase users and must remain constrained by ownership RLS, server authority, rate limits, and abuse controls.

**Authoritative data & economy:** Supabase/PostgreSQL is authoritative for gameplay records, ownership, RLS, economy, progression, player equity, market saturation, and sensitive settlement. No sensitive economic math or trusted gameplay state should happen on the client side.

**Server authority:** Every sensitive mutation must validate authenticated ownership, inputs, server timestamps, and current state on the server. Concurrent mutations require appropriate transactions or row locks. Retryable mutations require idempotency keys and replay protection. Rewards, currencies, inventory, progression, scores, and ownership must not be client-selected.

**Database security:** Player-facing tables require intentional RLS. Policies must validate ownership on inserts and both existing and new rows on updates. Cross-player reads, writes, deletes, blocked-user interactions, and Maison role escalation must be explicitly constrained. Sensitive functions require schema-qualified references, a safe explicit `search_path`, and restricted execution grants; public or normal-user execution is prohibited unless directly justified.

**Physics & Visuals:** GLSL (Shaders) must handle all garment drape, Verlet integration, and real-time cloth physics. Do not perform high-frequency math on the main Dart thread.

**Global Events:** TypeScript (Supabase Edge Functions) may orchestrate global events, trend decay, and cross-player rivalries, while PostgreSQL remains authoritative for transactional state and settlement.

## 3. State Management & Data Integrity

Use Riverpod as the single reactive state-management framework. Do not add Bloc or another state-management framework.

All "Mogul" path transactions must be server-authoritative to prevent local save-file manipulation.

Implement a "Source of Truth" hierarchy: Database > Edge Functions > Local State > UI.

Create reuse inside the established application architecture: Flutter widgets, Riverpod providers, validation utilities, result models, Supabase RPC wrappers, idempotency helpers, loading/error states, and test fixtures. Do not create a generic package, universal framework, or cross-project abstraction until at least two implemented Styliste features require the same behavior.

## 4. Performance Constraints

Maintain a consistent 60 fps, including complex design sessions. Use portrait-first layouts, reduced-motion behavior, and lower-end Android fallbacks for cloth, shaders, particles, image decoding, and other expensive visual effects. Performance claims require profile-mode or device evidence.

Offload heavy asset processing to background isolates.

Prioritize memory efficiency for portrait-mode mobile hardware.

## 5. Agent Interaction Protocol

**Reference the GDD:** Always check `THE_STYLISTE_GDD_v7.md` for the product vision, mechanics, narrative, brand identity, and release scope. GDD v6 is historical context only and is not an active source of truth.

**Follow the Rules:** Always check this file for the "how" (technical stack, performance limits).

**Repository memory:** Treat `THE_STYLISTE_GDD_v7.md`, this file, `VERIFICATION_PROTOCOL.md`, `DEVELOPMENT_STATE.md`, `BOTTLENECK_LOG.md`, `CHANGELOG.md`, and chronological Supabase migrations as the project memory. Chat transcripts are not authoritative. Update `DEVELOPMENT_STATE.md` after every Codex task.

**UI/UX authority:** For UI/UX, accessibility, layout, motion, HUD, visual hierarchy, responsive behavior, or performance-sensitive visual work, load and follow the repository’s `frontend-design` skill while preserving the established Flutter design system, Aurelian identity, Riverpod patterns, portrait-first layout, and performance constraints. Do not read or use `ui_ux_design.md`.

**Verification boundary:** Documentation of a security, RLS, authority, accessibility, or performance requirement does not prove that the implementation satisfies it. Report static inspection, runtime behavior, database/RLS validation, device behavior, and performance evidence separately.

**No Hallucinations:** If a requested feature violates the performance mandate (e.g., cloth physics in Dart), suggest a shader-based or low-level alternative immediately.

## 6. Repository Versioning and Publication

The application version in `pubspec.yaml` is the only authoritative product
version. The GDD version, database migration timestamps, GitHub Release tags,
and build numbers serve different purposes and must not be substituted for the
application version.

After every implementation task:

- update `DEVELOPMENT_STATE.md` with the exact scope and evidence;
- update `CHANGELOG.md` when player-facing behavior, security posture, public
  documentation, deployment behavior, or release tooling changed;
- update `README.md` only when its current status, supported platforms,
  verification evidence, or run instructions materially changed;
- keep release notes under `docs/releases/` synchronized with the active
  prerelease version; and
- run `scripts/check_release_metadata.ps1` before proposing a release.

Version numbers are not bumped for every commit. Use Semantic Versioning while
the game is pre-1.0: patch prereleases for fixes, minor prereleases for coherent
playable slices, and `1.0.0` only after the first public-launch gates in GDD v7
§§21–22 have Passed evidence.

Flutter Web and GitHub Pages are deferred and are not current build, CI,
verification, release, or deployment targets. Do not build, run, stage, publish,
or configure them without a separate authorization that restores the necessary
browser security and verification gates. Web evidence is not required for the
current Android/iOS mobile milestone.

## Background Task Cleanup

At the end of every completed, failed, cancelled, or interrupted directive, terminate all background processes, jobs, agents, watchers, servers, builds, test runners, and shell sessions started by the IDE agent for that directive.

Required behavior:

- Track every background task started during execution.
- Stop child agents and parallel audit workers.
- Stop Flutter, Dart, Gradle, Supabase, Node, test, build, watcher, emulator, and development-server processes started by the agent.
- Stop PowerShell jobs, terminal jobs, and detached subprocesses started by the agent.
- Wait for each task to exit and verify that it is no longer running.
- Perform cleanup before issuing the final completion report.
- Report any task that could not be terminated.

Safety restrictions:

- Terminate only processes and tasks that the agent started or can conclusively associate with the current directive.
- Never kill unrelated user terminals, IDE processes, operating-system services, database services, browsers, emulators, builds, or processes started outside the current directive.
- Never use broad commands such as `taskkill /IM <process> /F`, `Stop-Process -Name <name>`, or `killall <name>` unless every matching process was created by the agent and its identity has been verified.
- Prefer tracked process IDs, job IDs, child-process handles, terminal IDs, or session IDs.
- Do not terminate a process that contains uncommitted work or user-controlled interactive state.
- Cleanup must not reset, discard, stash, or modify repository files.

A directive is not complete while an agent-created background task remains active, unless termination is unsafe or impossible. In that case, report the exact task, process ID, command, reason, and required manual termination step.
