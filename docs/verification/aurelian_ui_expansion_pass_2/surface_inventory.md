# Aurelian UI Expansion Pass 2 — Implemented Surface Inventory

Date: 2026-07-29
Starting commit: `c4405414195f5bcdff87b31848c3425a17e76e85`
Evidence classification: **Static pass**
Runtime and physical-device behavior: **Blocked** until separately observed

This inventory records what is implemented at the starting commit. It does not
enable dead or future-wave code. Reachability is governed by
`lib/core/router/app_router.dart` and `featureRegistryProvider`.

## Reachable routes and screen families

| Route or condition | Primary UI | Owner / authority | Implemented states at baseline | Expansion-pass requirement |
|---|---|---|---|---|
| App startup | `TheStyliste`, `AurelianSessionGate`, `_SessionRestoring` | `supabaseSessionBootstrapProvider`, `supabaseAuthActionsProvider` | Restoring, safe failure, session expired, retry | Make local/server status explicit without exposing backend detail |
| `/onboarding/aurelian-gate` | `AurelianGateScreen`, `_SanctuaryInvitation` | Local age-gate state and preferences | Ready, checking, age denied | Strengthen fashion-authorship and Kingston opening while preserving legal clarity |
| Age confirmation dialog | `_AgeGateDialog` | Local dialog result | Pending, accepted, denied | Preserve focus escape, clear action hierarchy, and 48dp targets |
| `/onboarding/origin-script` | `OriginScriptScreen` | Local route progression | Luxe introduction, continue | Add concise professional context without a slideshow |
| `/onboarding/sovereign-registry` | `SovereignRegistryScreen` | `onboardingProvider` local draft | Empty, editing, validation-ready | Make House naming ceremonial while retaining visible labels and preserved input |
| `/onboarding/founder-trial` | `FounderTrialScreen` | `founderTrialProvider`; authenticated server intent | Loading, step progression, retryable error, submitting through provider, confirmed, restored | Visually contrast Artisan/Architect lenses, equal ceiling, state provenance, and consequence |
| `/hq` | `HqScreen`, `HqFoundationView` | `hqPlayerStreamProvider`, `hqBrandStreamProvider`, objective providers | Loading, empty, retryable error, content, unavailable boundary | Establish House/city/next-action/capsule/blocker/evidence hierarchy without dashboard tiles |
| `/atelier` | `AtelierScreen` | Local editor state; trend and objective providers | Local editing, trend loading/error, readiness disabled/confirmed, deferred notices | Keep garment central and move dense detail into compact contextual inspectors |
| `/atelier/capsule` | `CapsuleWorkspaceScreen` | `capsuleFoundationProvider`; existing Edge/RPC/database authority | Loading, empty, editing, submitting, confirmed, restored, offline, retryable error, unavailable | Enrich brief, three-role coherence, server-derived readiness, receipts, and sampling stop |
| `/empire` | `LedgerScreen` | `ledgerStoresStreamProvider`, `hqBrandStreamProvider`, `firstStoreProvider` | Loading, empty, projection, first-store submitting/error/confirmed receipt | Present supported operations visually without simulating unsupported business systems |
| `/feed` | `FeedScreen` | Feed projections and local view mode | Loading, empty, retryable error, editorial content, held mutations | Strengthen who/what/why/change/next-action hierarchy without fabricating reactions |
| `/house` | `ProfileScreen` | `hqPlayerStreamProvider` | Loading, retryable error, authoritative identity, unavailable future identity | Present verified House data and clear access to settings/legal |
| `/house/settings` | `SettingsScreen` | Local preferences and account action service | Loading preference restore, editing, confirmation dialog | Consolidate grouped controls, descriptions, and destructive separation |
| Legal document navigator | `LegalDocumentScreen` | Static legal document model | Read-only content and back | Preserve legibility, text scaling, and Aurelian hierarchy |
| Unknown or disabled location | `FeatureUnavailableScreen` | Router / feature registry only | Unavailable | Explain scope boundary and return route without starting providers |

## Canonical five-destination shell

| Index | Label | Route | Stateful branch retained | Gameplay authority |
|---:|---|---|---|---|
| 0 | HQ | `/hq` | Yes | None in navigation |
| 1 | Atelier | `/atelier` | Yes | None in navigation |
| 2 | Empire | `/empire` | Yes | None in navigation |
| 3 | Feed | `/feed` | Yes | None in navigation |
| 4 | House | `/house` | Yes | None in navigation |

`StatefulShellRoute.indexedStack` preserves destination state. Back from a
non-HQ destination returns to HQ; it does not silently mutate progression.

## Dialog and sheet inventory

| Host | Surface | Implemented purpose | Mutation boundary |
|---|---|---|---|
| Opening Sanctuary | Age confirmation dialog | Confirm legal age eligibility | Local preference only |
| Founder Path legacy source | Confirmation dialog | Historical/deferred source only | Not reachable in Gate A |
| Empire | `FirstStoreDialog` | Submit one bounded first-store intent | Existing authenticated provider/Edge/RPC path |
| Empire | Receipt dialog | Show confirmed server result | Read-only result |
| Feed | `FeedCommentSheet` | Read projected comments and explain held commenting | Comment mutation unavailable |
| Feed | `FeedRequestsSheet` | Read projected requests and explain held decisions | Approve/deny/collab mutations unavailable |
| Settings | Sign-out/account confirmation | Confirm account action | Existing auth action only |
| Legal | Full-screen document navigator | Read privacy/terms material | No gameplay mutation |
| First objective overlay | Luxe objective dialog | Explain validated next objective | Existing objective event boundary |
| Reporting | Report modal | Existing moderation entry point in preserved source | Not added to Gate A reachability by this pass |

## Reliability-state family

The canonical component is `AurelianStatePanel`.

| Required state | Baseline component kind | Baseline use | Expansion action |
|---|---|---|---|
| Loading | `loading` | Startup, HQ, capsule, Empire, Feed, House, settings | Retain and state what is being restored |
| Empty | `empty` | HQ, Empire, Feed, capsule | Retain with truthful next action |
| Editing | Missing explicit kind | Screen-local forms | Add explicit canonical kind and local-authority cue |
| Submitting | Missing explicit kind | Provider booleans/loading | Add explicit canonical kind and safe-retry/input-preservation cue |
| Confirmed | `confirmed` | Founder Trial, Atelier, capsule | Retain with server-confirmed cue |
| Restored | `restored` | Founder Trial and capsule receipts | Retain with original-receipt cue |
| Offline | `offline` | Capsule/reliability messages | Expand consistently where recovery is supported |
| Retryable error | `retryableError` | Startup, HQ, capsule, Empire, Feed, House | Retain; never show raw backend errors |
| Terminal error | `terminalError` | Canonical component available | Add to applicable terminal boundaries only |
| Permission denied | `permissionDenied` | Age gate; component available | Distinguish eligibility/authorization from technical failure |
| Session expired | `sessionExpired` | Session gate | Retain with auditable retry |
| Maintenance | `maintenance` | Component available | Use only when the app actually reports maintenance |
| Disabled | `disabled` | Readiness and held Feed actions | Retain non-color cue and disabled semantics |
| Unavailable | `unavailable` | Future boundaries and disabled routes | Retain with explicit no-request-started copy |

## Deferred drop-route contract

The routes below resolve directly to `FeatureUnavailableScreen`:

- `/atelier/drop-preview`
- `/atelier/drop-launch`

They do not import the preserved drop screen implementations, initialize their
providers, fetch data, or offer launch/reward actions.

## Dead and future-wave source inventory

The following implemented source families are not reachable through the Gate A
registry and will be inventoried only:

- AR try-on and camera-dependent presentation.
- Archive market and settlement.
- Ascension and Hall of Sovereigns.
- Bank, equity, territory, district map, and advanced world map.
- Casting and talent acquisition.
- Crisis/Kintsugi, Gala, minigames, and competitive reward flows.
- Maison governance and district surfaces.
- Marketplace, shop, and Aurelian storefront.
- Production, manufacturing, sampling, collection launch, Vex result, and
  later-city implementations.

Their presence is not evidence of an enabled Feature ID or authorized
mutation. The expansion pass must not cosmetically promote or deep-link them.

## Starting deterministic evidence

The inherited presentation was rendered at 390×844 logical pixels with fixed
fixtures and bundled fonts into:

`docs/verification/aurelian_ui_expansion_pass_2/captures/before/`

The capture test observed 24 passing cases. These files are deterministic
source renders, not physical-device, TalkBack, performance, or release
evidence.
