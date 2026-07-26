# Stack Decisions

This file records approved and rejected stack choices for The Styliste. It is binding for future implementation work unless a later written migration plan explicitly supersedes it.

## Flutter/Dart Remains Approved

**Decision:** Reject React Native + Expo + TypeScript as a migration target for the current codebase.

The Styliste remains Flutter/Dart because the existing codebase is already stabilized and aligned around Flutter + Supabase. React Native/Expo would require a rewrite, not refinement.

**Cites:** GDD v6 sections 1, 2, 4.5, 8.18; PROJECT_RULES.md sections 1 and 2.

## NativeWind

**Decision:** Not applicable.

NativeWind is a React Native styling layer. The production client is Flutter, not React Native. Do not add Tailwind/NativeWind equivalents unless creating separate marketing or web tooling outside the production mobile client.

**Cites:** GDD v6 section 4.5; PROJECT_RULES.md section 2.

## Zustand

**Decision:** Forbidden for authoritative game state.

Zustand must not be used to resolve, simulate, or persist authoritative economy or progression state. Currency, followers, rank, idle rewards, drop rewards, valuation, and IAP grants must be resolved by Supabase RPCs, Edge Functions, or Postgres transactions, not client state.

Client state may only display server-confirmed values or hold temporary UI state.

**Cites:** GDD v6 sections 3.3, 8.18, 9.1, 9.2; PROJECT_RULES.md section 3.

## Player Identity

**Decision:** Supabase Auth is the only approved player identity system.

Firebase Auth and Firebase App Check are retired from the client. Clerk remains
rejected because a second identity source would complicate anonymous founder
trials, account linking, server-issued ownership, and Supabase RLS. Any future
identity migration requires a separately approved plan and observed parity.

**Cites:** GDD v7 §§19.6–19.9; PROJECT_RULES.md sections 2 and 3.

## Stream Voice Agents

**Decision:** Deferred.

Do not implement voice, livestreaming, or AI voice agents until Global Feed, Maisons, chat/reporting, moderation, and core simulation systems are stable.

**Cites:** GDD v6 sections 6.3, 6.4, 6.5, 6.6.

## PostHog

**Decision:** Approved as optional analytics only.

PostHog may be added later behind privacy controls and legal documentation. Do not track minors, sensitive data, private messages, payment details, or device fingerprints without explicit compliance review.

PostHog is not currently required as a runtime dependency.

**Cites:** GDD v6 sections 8.16, 8.19, 10.1.

## CodeRabbit

**Decision:** Approved as development tooling only.

CodeRabbit may be configured for PR review, lint enforcement, secret scanning reminders, and architecture violation comments. It must not modify runtime architecture.

**Cites:** PROJECT_RULES.md and VERIFICATION_PROTOCOL.md.

## Testing Rule

After stack decision documentation changes, Smiley must run the required Dart/Flutter verification commands manually. Codex must not run Dart or Flutter commands.
