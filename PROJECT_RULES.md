# The Styliste: Technical Constitution & Agent Directives

## 1. Core Architectural Mandate

This project is a high-performance fashion simulation. All development must adhere to a "Separation of Concerns" model to ensure the game scales from a local idle loop to a global social economy without technical debt.

## 2. Language & Framework Stack

**Orchestration:** Dart (Flutter) handles the UI, local state management, and application flow. Use the Impeller rendering engine exclusively.

**Authentication:** Firebase Auth is the active identity integration. The current implementation bridges Firebase identity tokens into Supabase Auth. Firebase App Check provides device/app attestation support only; it is not complete anti-cheat protection. Firebase Messaging is notification delivery only.

**Authoritative data & economy:** Supabase/PostgreSQL is authoritative for gameplay records, ownership, RLS, economy, progression, player equity, market saturation, and sensitive settlement. No sensitive economic math or trusted gameplay state should happen on the client side.

**Server authority:** Every sensitive mutation must validate authenticated ownership, inputs, server timestamps, and current state on the server. Concurrent mutations require appropriate transactions or row locks. Retryable mutations require idempotency keys and replay protection. Rewards, currencies, inventory, progression, scores, and ownership must not be client-selected.

**Database security:** Player-facing tables require intentional RLS. Policies must validate ownership on inserts and both existing and new rows on updates. Cross-player reads, writes, deletes, blocked-user interactions, and Maison role escalation must be explicitly constrained. Sensitive functions require schema-qualified references, a safe explicit `search_path`, and restricted execution grants; public or normal-user execution is prohibited unless directly justified.

**Physics & Visuals:** GLSL (Shaders) must handle all garment drape, Verlet integration, and real-time cloth physics. Do not perform high-frequency math on the main Dart thread.

**Global Events:** TypeScript (Supabase Edge Functions) may orchestrate global events, trend decay, and cross-player rivalries, while PostgreSQL remains authoritative for transactional state and settlement.

## 3. State Management & Data Integrity

Use a robust, reactive state management pattern (e.g., Riverpod or Bloc) to keep the UI in sync with the underlying simulation engine.

All "Mogul" path transactions must be server-authoritative to prevent local save-file manipulation.

Implement a "Source of Truth" hierarchy: Database > Edge Functions > Local State > UI.

## 4. Performance Constraints

Maintain a consistent 60 fps, including complex design sessions. Use portrait-first layouts, reduced-motion behavior, and lower-end Android fallbacks for cloth, shaders, particles, image decoding, and other expensive visual effects. Performance claims require profile-mode or device evidence.

Offload heavy asset processing to background isolates.

Prioritize memory efficiency for portrait-mode mobile hardware.

## 5. Agent Interaction Protocol

**Reference the GDD:** Always check `THE_STYLISTE_GDD_v7.md` for the product vision, mechanics, narrative, brand identity, and release scope. GDD v6 is historical context only and is not an active source of truth.

**Follow the Rules:** Always check this file for the "how" (technical stack, performance limits).

**UI/UX authority:** For UI/UX, accessibility, layout, motion, HUD, visual hierarchy, responsive behavior, or performance-sensitive visual work, load and follow the repository’s `frontend-design` skill while preserving the established Flutter design system, Aurelian identity, Riverpod patterns, portrait-first layout, and performance constraints. Do not read or use `ui_ux_design.md`.

**Verification boundary:** Documentation of a security, RLS, authority, accessibility, or performance requirement does not prove that the implementation satisfies it. Report static inspection, runtime behavior, database/RLS validation, device behavior, and performance evidence separately.

**No Hallucinations:** If a requested feature violates the performance mandate (e.g., cloth physics in Dart), suggest a shader-based or low-level alternative immediately.

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
