The Styliste: Technical Constitution & Agent Directives
1. Core Architectural Mandate
This project is a high-performance fashion simulation. All development must adhere to a "Separation of Concerns" model to ensure the game scales from a local idle loop to a global social economy without technical debt.

2. Language & Framework Stack
Orchestration: Dart (Flutter) handles the UI, local state management, and application flow. Use the Impeller rendering engine exclusively.

Data & Economy: PostgreSQL (Supabase) is the source of truth for all "Mogul" path logic, player equity, and market saturation. No sensitive economic math should happen on the client side.

Physics & Visuals: FLSL/GLSL (Shaders) must handle all garment drape, Verlet integration, and real-time cloth physics. Do not perform high-frequency math on the main Dart thread.

Global Events: TypeScript (Supabase Edge Functions) manages the "Paris Eclipse" events, global trend decay, and cross-player rivalries.

3. State Management & Data Integrity
Use a robust, reactive state management pattern (e.g., Riverpod or Bloc) to keep the UI in sync with the underlying simulation engine.

All "Mogul" path transactions must be server-authoritative to prevent local save-file manipulation.

Implement a "Source of Truth" hierarchy: Database > Edge Functions > Local State > UI.

4. Performance Constraints
Maintain a consistent 60fps, even during complex design sessions.

Offload heavy asset processing to background isolates.

Prioritize memory efficiency for portrait-mode mobile hardware.

5. Agent Interaction Protocol
Reference the GDD: Always check the THE_STYLISTE_GDD_v3.md for the "what" (creative vision, mentor dialogue, brand vibes).

Follow the Rules: Always check this file for the "how" (technical stack, performance limits).

No Hallucinations: If a requested feature violates the performance mandate (e.g., cloth physics in Dart), suggest a shader-based or low-level alternative immediately.