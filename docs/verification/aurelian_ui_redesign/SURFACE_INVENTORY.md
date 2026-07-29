# Aurelian reachable-surface inventory

Status: **Redesign implemented; creator visual approval approved for deterministic source renders only**

| Route or surface | Widget | Feature ID | Reachability | Starting visual mode | State coverage at inventory | State owner | Redesign action | Before evidence | After evidence | Test |
|---|---|---|---|---|---|---|---|---|---|---|
| Session bootstrap | `TheStyliste` / `_ObsidianGate` | TECH-01, UI-03 | Conditional | Legacy Obsidian | Loading, terminal error | `supabaseSessionBootstrapProvider` | Redesign | `captures/before/session-*` | `captures/after/session-*` | Auth gate widget tests |
| `/onboarding/aurelian-gate` | `AurelianGateScreen` and age dialog | FTUE-01, UI-03 | Reachable | Early Aurelian | Idle, pressing, complete, age denied | Local state and preferences | Redesign | `captures/before/sanctuary-*` | `captures/after/sanctuary-*` | Semantics/reduced-motion tests |
| `/onboarding/origin-script` | `OriginScriptScreen` | FTUE-01, LUXE-01 | Reachable | Legacy Obsidian | Playing, skipped, complete | Local state | Redesign | `captures/before/luxe-introduction` | `captures/after/luxe-introduction` | Large-text/reduced-motion tests |
| `/onboarding/sovereign-registry` | `SovereignRegistryScreen` | FTUE-02 | Reachable | Legacy Obsidian | Empty, editing, validation, submitting | `onboardingProvider` | Redesign | `captures/before/house-naming` | `captures/after/house-naming` | Form semantics/overflow tests |
| `/onboarding/founder-trial` | `FounderTrialScreen` | FTUE-03, FTUE-04 | Reachable | Legacy Obsidian | Stage, submitting, retry error | `founderTrialProvider` | Redesign | `captures/before/founder-trial-*` | `captures/after/founder-trial-*` | Both-path/provider-state tests |
| `/hq` | `HqScreen`, Artisan/Architect views, Luxe/objective sheets | UI-01, UI-03 | Reachable | Mixed Aurelian | Loading, success, error, guidance | HQ and objective providers | Consolidate/redesign | `captures/before/hq-*` | `captures/after/hq-*` | Path/semantics tests |
| `/atelier` | `AtelierScreen` | ART-01, ART-02, UI-03 | Reachable | Mixed Aurelian | Editing, local gate, server error/retry | Local editor and Riverpod providers | Redesign; remove mint-to-drop reachability | `captures/before/atelier-*` | `captures/after/atelier-*` | Reduced-motion/overflow/route tests |
| `/atelier/capsule` | `CapsuleWorkspaceScreen` | LOOP-02 | Reachable | Styliste foundation | Loading, empty, editing, submitting, confirmed, offline, retry, restored, unavailable | `capsuleFoundationProvider` | Redesign | `captures/before/capsule-*` | `captures/after/capsule-*` | All stages/roles/restoration tests |
| `/atelier/drop-preview` | Shared unavailable state | Deferred | Unavailable route | Deferred implementation currently imported | Must not initialise | Router only | Quarantine; remove implementation import/data path | N/A | `captures/after/drop-preview-unavailable` | No-fetch route test |
| `/atelier/drop-launch` | Shared unavailable state | Deferred | Unavailable route | Deferred implementation currently imported | Must not initialise | Router only | Quarantine; remove implementation import/data path | N/A | `captures/after/drop-launch-unavailable` | No-fetch route test |
| `/empire` | `LedgerScreen` and first-store dialog | MOG-01, ECO-01 | Reachable | Legacy Architect lime | Loading, empty, store list, dialog, submit, error | Ledger/first-store providers | Redesign current behavior only | `captures/before/empire-*` | `captures/after/empire-*` | Dialog/state/large-text tests |
| `/feed` | `FeedScreen`, request sheet, comment sheet, editorial cards | FEED-01, UI-03 | Reachable | Legacy Obsidian | Loading, empty, error, retry, content, sheet input | Feed providers | Redesign current behavior only | `captures/before/feed-*` | `captures/after/feed-*` | Empty/error/sheet semantics tests |
| `/house` | `ProfileScreen` | FTUE-02, UI-01 | Reachable | Early Aurelian unavailable card | Unavailable | Current projection only | Redesign truthful House identity boundary | `captures/before/house` | `captures/after/house` | Navigation/settings test |
| `/house/settings` | `SettingsScreen`, account confirmation | UI-03 | Reachable/deep link | Early Aurelian dark | Editing, confirmation | Preferences and account service | Redesign | `captures/before/settings-*` | `captures/after/settings-*` | Control semantics/large-text tests |
| Legal document navigator | `LegalDocumentScreen` | Unregistered | Conditional | Early Aurelian | Content, back | Static legal documents | Consolidate | `captures/before/legal` | `captures/after/legal` | Scaling/navigation test |
| Unknown/disabled deep link | Shared unavailable state | UI-03 | Conditional | Default Material | Unavailable | Router | Redesign | `captures/before/unavailable` | `captures/after/unavailable` | Safe-route/no-fetch test |
| Five-tab shell | `MainShell` | UI-01 | Reachable | Legacy Obsidian | Selected/unselected/back | `StatefulNavigationShell` | Redesign | `captures/before/navigation` | `captures/after/navigation` | Order, targets, semantics, scaling |

## Dead and deferred source inventory

The following source families are compiled or preserved but are not reachable
from the Gate A registry and will not be cosmetically redesigned or enabled:
AR try-on, archive market, Ascension/Hall of Sovereigns, crisis, Gala, Maison,
district map, casting, marketplace/shop, territory/world map, minigames,
advanced bank/equity, and deferred drop preview/launch implementations.

Their presence is not evidence that their Feature IDs are enabled. No route,
provider, mutation, reward, or simulated success may be added for them in this
redesign.
