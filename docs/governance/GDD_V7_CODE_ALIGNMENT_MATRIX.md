# Historical GDD v7 Code Alignment Matrix

> Historical archive only. This record must not be used as an active product,
> Feature ID, release, or implementation authority. GDD v8 and the active
> authority inventory govern current work.

This matrix is the executable scope register for Directive 1X. It targets the
Kingston Early Game milestone, not the complete future product. `KEEP`, `FIX`,
`QUARANTINE`, `DEFER`, `REMOVE`, and `BLOCKED` describe the required disposition;
they are not claims of behavioral proof. Static checks are labelled as static
evidence. The disposable local database and Edge gates below were executed;
Smiley-run Flutter gates remain open.

## Player runtime and navigation

| Feature ID | GDD requirement | Active implementation | Contradiction | Severity | Required action | Test evidence | Final status |
|---|---|---|---|---|---|---|---|
| FTUE-01 | Luxe-led Sanctuary opening with meaningful input inside 45 seconds | `/onboarding/aurelian-gate` starts a seven-screen Aurelian onboarding sequence | Luxe does not own the active opening | P0 | Replace the critical path with the Kingston Sanctuary flow | UI/Flutter validation not run; frontend skill absent | BLOCKED |
| FTUE-02 | Founder intent, one shared Kingston garment, and no hidden permanent stat bonus | Origin, brand, city/tier, avatar, and path screens run before gameplay | City/tier/avatar and blind path choice are obsolete critical-path inputs | P0 | Replace with Founder intent and the shared garment | UI/Flutter validation not run; frontend skill absent | BLOCKED |
| FTUE-03 | Artisan and Architect samples before specialization | Career path is selected before either causal sample | Permanent framing precedes evidence from both play styles | P0 | Implement both samples and defer specialization until after consequences | Database contract is incomplete; UI skill absent | BLOCKED |
| FTUE-04 | Luxe guidance modes, Ask Luxe, adaptive hints, and server-owned resume state | No canonical active Luxe guidance/resume loop | Required Kingston tutorial memory is missing | P1 | Add the minimum server-owned guidance state and player surface | No behavioral evidence | BLOCKED |
| FTUE-05 | First Main Quest and authoritative first return | Local `FirstObjectiveMarkers` records tab visits; server projection contains a limited objective list | Local presentation markers can imply progress and the required quest/return loop is incomplete | P1 | Keep local markers presentational only; settle progression and return receipts on the server | Static API contract only; no database execution | FIX |
| UI-01 | Five primary Kingston destinations answer distinct player questions | HQ, Atelier, Empire, Feed, and House branches are active | Shell is structurally aligned, but downstream surfaces contain unresolved contradictions | P1 | Retain the five destinations while fixing their contracts | Router trace; Flutter gates pending | KEEP |
| UI-02 | Later-wave destinations are unavailable in Kingston | Maison, Bank, Equity, districts, events, AR, shop, Gala, Archive market, casting, and crisis constants resolve to `/unavailable` | No active route implementation is reachable through these constants | P0 | Preserve compile-safe quarantine and guard the feature registry | Static route inspection only | KEEP |
| UI-03 | Player-facing error and unavailable states remain accessible | `/unavailable` provides a deterministic fallback | Visual/accessibility quality cannot be reviewed without the required skill | P2 | Retain functionally; conduct skill-led UI review later | Frontend skill absent | BLOCKED |
| PERF-01 | No hidden off-screen polling | HQ, brand, Feed, objectives, and stores poll API views every 30 seconds | Indexed shell/provider lifecycles may keep polling when not visible | P2 | Convert active reads to lifecycle-aware refresh/receipts after UI review | Flutter/profile evidence unavailable | DEFER |

## Active providers, repositories, and gameplay mutations

| Feature ID | GDD requirement | Active implementation | Contradiction | Severity | Required action | Test evidence | Final status |
|---|---|---|---|---|---|---|---|
| SEC-01 | Client submits Founder Trial intent; Edge derives the actor | `SovereignGenesisGateway` invokes `founder-trial` without an actor field; Edge accepts brand/career intent only | Actor boundary and payload are aligned, but the obsolete visual FTUE still precedes this data path | P0 | Keep actor derivation and fixed starting conditions; redesign the player-facing specialization flow after the UI gate is available | Edge identity 13/13 pass; Kingston SQL contract pass; Flutter pending | FIX |
| ART-01 | One persisted `DesignBlueprint` drives rendering, submission, lineage, and scoring | Atelier start/mint persists a minimal blueprint; release submits a separate starter blueprint | Editable zones, construction, proportions, undo/redo, targeted lineage, and single-source rendering are incomplete | P1 | Implement the canonical blueprint contract after UI skill is available | Static contract only; Flutter pending | BLOCKED |
| ART-02 | Final Hype and rewards are server-owned | `drop-design` returns a server receipt; the provider strictly requires server Hype, Feed, Vex, and timestamp fields | Flutter compilation and presentation remain unverified | P0 | Retain strict receipt parsing and verify through Smiley-run Flutter tests | Edge identity 13/13 pass; Kingston SQL contract pass; Flutter pending | FIX |
| ART-03 | Scoring validates choices and compatibility without count exploitation | `private.release_design_v2` validates session ownership and frozen starter catalog IDs and averages option signals | Full material compatibility, rendered-blueprint parity, and lineage are not implemented | P0 | Retain the count-safe frozen rule and complete the canonical blueprint/compatibility model later | Kingston SQL contract pass; 20-way design release pass | FIX |
| ART-04 | Vex is opt-in | Drop state sends `vex_opt_in`; Edge and SQL require it and omit Vex when false | Flutter UI behavior is unverified | P1 | Retain the end-to-end contract and verify both visual branches with the UI skill | Edge 13/13 pass; Kingston SQL contract pass; Flutter pending | FIX |
| MOG-01 | Architect loop exposes price, inventory, demand, margin, stock, and recovery | First-store intent accepts store type, price tier, and inventory; the screen displays server fields | No repeated inspect/intervene/settle/recover operation exists | P1 | Keep first-store authority and implement a minimal server-derived intervention receipt | DB/Flutter pending | FIX |
| MOG-02 | First store is atomic, Kingston-only, and debt-free | `open-first-store` creates one Kingston store under a player lock at zero opening cost | Backend authority is aligned; Flutter presentation is unverified | P0 | Retain House Funds semantics and deterministic lock/replay behavior | Kingston SQL contract pass; 20-way first-store pass | KEEP |
| ECO-02 | House Funds, gross revenue, costs, and net result are distinct | Forward migration adds `house_funds`, lifetime gross/cost/net, and separated idle-source fields; active settlements update them | A temporary `total_revenue` projection alias remains for an unverified legacy Flutter model | P0 | Keep the alias isolated to read compatibility and remove it after skill-led UI/model migration | DB lint pass; Kingston SQL contract pass; 20-way economic pass | FIX |
| ECO-03 | Economic requests are idempotent with exact/conflicting replay behavior | Edge requires UUID keys; SQL stores hashes/versioned receipts; active nonvisual callers retain one key across uncertain retry | Flutter compilation and retry lifecycle remain unverified | P0 | Retain conflict rejection and verify caller state with Smiley-run tests | Edge 13/13 pass; Kingston SQL replay pass; 20-way economic pass | FIX |
| IDLE-01 | Idle production is server-timed and returns a House While Away receipt | SQL derives elapsed time, settles House Funds/lifetime metrics, preserves source-separated rates, and returns a typed receipt | Player-facing House While Away presentation is unavailable | P0 | Retain settlement authority; implement presentation only after the UI skill is available | Kingston SQL contract pass; 20-way idle pass | FIX |
| IDLE-02 | Idle lifecycle is not owned by Architect HQ | `IdleEngineService` is global and retains one settlement UUID across uncertain retry | Flutter compilation/lifecycle behavior remains unverified | P1 | Retain and verify with Smiley-run tests/profile evidence | SQL replay/concurrency pass; Flutter pending | FIX |
| QUEST-01 | Objectives require only available systems and are server-confirmed | Objective projection contains first design/drop/result, first store/decision/result, and Feed participation | “Feed participation” is ambiguous while player-social actions are quarantined; local tab markers remain | P1 | Replace with deterministic NPC-result review and server-confirmed events | DB/Flutter pending | FIX |
| FEED-01 | Early Feed is an owner-scoped deterministic NPC Industry Feed | Active provider reads only `api.feed_projection`, which exposes current-player event posts | Isolation is aligned; the projection is not yet a complete NPC causal feed | P1 | Preserve owner isolation; add deterministic NPC/customer/Luxe/Vex receipts | RLS authority contract pass; Kingston SQL contract pass | FIX |
| FEED-02 | No player-social Feed mutations in Kingston | Feed actions fail closed; social reads for comments/follows/collaboration were still live | Later-wave social data remained reachable from the active Feed screen | P0 | Return empty quarantined data and remove default-schema calls from the active provider | Static source guard; Flutter pending | QUARANTINE |
| REPORT-01 | Reports use a verified reporter and bounded server validation | `submit-player-report` is allowlisted and actor-derived | Target player is resource input, not actor authority; full rate-limit matrix is not part of the new Kingston suite | P1 | Retain; preserve existing hardening tests and add focused replay/rate tests when reporting is player-reachable | Edge identity 13/13 pass; security hardening 15/15 pass | KEEP |
| MINI-01 | Mini-game rewards are unavailable until server proof exists | Reward claims fail closed and endpoint is disabled | Dormant caller methods remain in Ledger/provider surfaces | P1 | Preserve fail-closed behavior; remove reachability only with analyzer/coverage evidence | Static containment tests exist; Flutter rerun pending | QUARANTINE |
| STORE-02 | Store upgrades/trading are later-wave | Upgrade provider returns a Kingston-unavailable error | Client-side upgrade formula remains as ghost compatibility code | P2 | Keep unreachable for now; remove only after analyzer/coverage proof | No reachability proof | DEFER |
| FIN-01 | Advanced finance is not in Kingston | Economy repository still contains campaign/equity/default-schema methods | Active Kingston routes do not call them, but the repository surface remains dangerous | P1 | Split the Early Game repository and quarantine later-wave methods | Caller trace only | DEFER |

## Edge Function surface

| Feature ID | GDD requirement | Active implementation | Contradiction | Severity | Required action | Test evidence | Final status |
|---|---|---|---|---|---|---|---|
| SEC-01 | Founder Trial is actor-derived, versioned, and replay-safe | `founder-trial` → `api.server_founder_trial_intent_v1`; payload permits brand/career intent only | Evidence-gated advancement remains fail-closed rather than implemented | P0 | Retain fixed starting conditions and fail-closed advance until causal proof exists | Static allowlist pass; Edge 13/13 pass; SQL contract pass | FIX |
| SEC-03 | Atelier mutations use one verified authority path | `drop-design` → `api.server_design_intent_v1` → `private.release_design_v2` | Starter scoring is count-safe, but the complete DesignBlueprint contract is absent | P0 | Retain Edge boundary and frozen starter rule; complete blueprint later | Static allowlist pass; Edge 13/13 pass; SQL/concurrency pass | FIX |
| SEC-04 | First-store mutation is atomic and Kingston-only | `open-first-store` → `api.server_open_first_store_v1`; receipt uses House Funds and separated idle sources | No backend authority contradiction remains in current scope | P0 | Retain route and tested receipt | Static allowlist pass; Edge 13/13 pass; SQL/concurrency pass | KEEP |
| SEC-06 | Idle settlement ignores client clock and amount | `calculate-idle-income` → `api.server_settle_idle_income_v1`; SQL derives time and source rates | Player-facing receipt display remains blocked | P0 | Retain route and typed receipt; add UI later | Static allowlist pass; Edge 13/13 pass; SQL/concurrency pass | KEEP |
| SEC-02 | Tutorial progress is server-confirmed | `progression-event` accepts two verifiable acknowledgement keys | It does not cover the complete Founder Trial/Main Quest causal loop | P1 | Retain narrow events; add evidence-backed events only as systems land | Static allowlist pass; Edge 13/13 pass; SQL contract pass | KEEP |
| SEC-12 | Moderation report actor is server-derived | `submit-player-report` → `api.server_submit_player_report_v1` | No active authority contradiction found | P1 | Retain; extend focused rate/replay coverage before player reachability | Static allowlist pass; Edge 13/13 pass; security hardening pass | KEEP |
| SOC-01 | Player-social endpoints are disabled | `feed-react`, `feed-comment`, and `feed-inspiration` have `enabled=false` | Source remains for later milestones | P0 | Keep disabled and without active callers | Static allowlist pass | QUARANTINE |
| ART-05 | Superseded mutation entry points are closed | `mint-design` has `enabled=false`; start/mint route through `drop-design` | Function source remains | P1 | Keep disabled; remove only after deployment history review | Static allowlist pass | QUARANTINE |
| MINI-02 | Economic mini-game rewards are disabled | `claim-mini-game-reward` has `enabled=false` | Dormant callers remain | P0 | Keep disabled and fail closed | Static allowlist pass | QUARANTINE |
| STORE-03 | Later-wave transactions are disabled | `process-transaction` has `enabled=false` | Source remains | P0 | Keep disabled | Static allowlist pass | DEFER |
| MAISON-01 | Maison donations are not available in Kingston | `maison-donate` has `enabled=false` | Dormant caller remains | P0 | Keep disabled and remove active navigation | Static allowlist pass | QUARANTINE |
| MON-01 | IAP cannot affect Kingston power | `validate-iap` has `enabled=false` | Dormant caller remains | P0 | Keep disabled; no production secrets or purchases | Static allowlist pass | QUARANTINE |
| LIVE-01 | Later-wave scheduled jobs are off | `trend-decay` and `eclipse-event-tick` have `enabled=false` | Source remains and JWT verification is off, but runtime is disabled | P0 | Preserve disable switches and add CI allowlist protection | Static allowlist pass | DEFER |
| NOTIFY-01 | Unapproved notification runtime is not deployed | `send-fcm-notification` source was removed and has no config entry | Deletion is inherited work and requires attribution before adoption | P1 | Exclude until history/reachability is proven | Status/diff evidence only | DEFER |

## Database authority and exposed API

| Feature ID | GDD requirement | Active implementation | Contradiction | Severity | Required action | Test evidence | Final status |
|---|---|---|---|---|---|---|---|
| SEC-07 | Gameplay Data API exposes only reviewed `api` relations | `db.schemas=["api"]`; `public` is not exposed; predecessor migrations no longer restore raw grants | Complete reset applied migrations, but the CLI returned 1 on a later Storage health timeout | P0 | Preserve boundary; treat replay as applied-with-service-health-warning, not a clean command pass | Static authority pass; migration list complete; RLS/Kingston contracts pass | KEEP |
| SEC-08 | Privileged implementations are private and service-only | `private.authority_*_v1` plus service-only `api.server_*_v1` wrappers | No contradiction in current executable privilege checks | P0 | Retain and guard privileges | RLS contract pass; immediate containment 44/44 pass | KEEP |
| SEC-09 | Actor mapping is unambiguous and private | `private.auth_player_identities` requires unique auth and player IDs; resolver rejects missing/ambiguous mappings | Protected historical tests require direct `public.platform_auth_mappings` access and now fail against the API-only boundary | P0 | Keep protected files unchanged; resolve their obsolete public-access expectation under separate authorization | Kingston SQL identity cases pass; protected suites fail by expected public revocation | BLOCKED |
| SEC-10 | Economic receipts are immutable and conflict-aware | `ledger.kingston_operation_receipts` stores request hash/result; trigger rejects update/delete | No contradiction in tested Kingston mutations | P0 | Retain replay contract and append-only trigger | Kingston SQL replay pass; Edge conflict 409 pass; 20-way pass | KEEP |
| SEC-11 | Locks are deterministic and transactions remain short | Per-actor advisory lock precedes row locks in authority functions | No deadlock or failed transaction observed across four 20-session races | P0 | Retain deterministic order | 20-way founder/design/store/idle pass | KEEP |
| API-01 | Player summary is owner scoped | `api.player_summary` → `private.read_player_summary()` → current identity | No contradiction in current contract | P1 | Retain | RLS and Kingston SQL contracts pass | KEEP |
| API-02 | Brand summary is owner scoped and economically unambiguous | `api.brand_summary` projects House Funds, lifetime gross/cost/net, idle sources, plus a temporary legacy alias | Temporary alias remains for the unverified Flutter model | P0 | Remove alias after skill-led model/UI migration | Kingston SQL contract pass; Flutter pending | FIX |
| API-03 | Founder Trial state is owner scoped | `api.founder_trial_state` reads current trial | Evidence-gated stages beyond initialization remain fail-closed | P1 | Implement only when server-verifiable causal evidence exists | Kingston SQL contract pass | FIX |
| API-04 | Design reads expose only owned state | `api.owned_designs` and `api.design_session_state` are owner scoped | Full blueprint validation remains incomplete | P1 | Retain isolation; extend verified blueprint fields | Kingston SQL contract and design concurrency pass | FIX |
| API-05 | Feed is deterministic and owner scoped | `api.feed_projection` exposes current-player event posts | It is an event log, not the required complete NPC Industry Feed | P1 | Extend with deterministic NPC/customer causes, not public player posts | RLS/Kingston SQL contracts pass | FIX |
| API-06 | Objectives are owner scoped and authoritative | `api.first_week_objectives` exposes current-player rows | Objective set does not yet prove the full Kingston loop | P1 | Replace unavailable-system objectives and add Main Quest/return state | RLS/Kingston SQL contracts pass | FIX |
| API-07 | Store reads are owner scoped and causal | `api.store_summary` exposes current-player stores | Missing repeated diagnosis/intervention settlement history | P1 | Retain and extend with authoritative intervention/result receipts | Kingston SQL and first-store concurrency pass | FIX |
| API-08 | Progression and receipt projections are owner scoped | `api.progression_state`, design/store/idle receipt views call current identity readers | Historical progression test expects the superseded public wrapper and fails | P0 | Retain API-only contract; update historical test only under separate review | RLS/Kingston contracts pass; historical progression suite fails on public revocation | BLOCKED |
| DB-01 | Published migrations are immutable | `001_initial_schema.sql` and `20260713122917_vertical_slice_first_hour.sql` contain inherited edits | Those changes cannot be adopted or committed as migration rewrites | P0 | Exclude them and supersede required behavior with a new forward migration | Git diff evidence | QUARANTINE |

## Platform services and future systems

| Feature ID | GDD requirement | Active implementation | Contradiction | Severity | Required action | Test evidence | Final status |
|---|---|---|---|---|---|---|---|
| REALTIME-01 | Realtime is used only with reviewed owner-safe tables and lifecycle controls | `[realtime].enabled=false`; active projections poll | No live publication is enabled | P0 | Keep disabled for Kingston | Config/static check | KEEP |
| STORAGE-01 | Storage paths require explicit product need and owner policy | `[storage].enabled=false`, including S3, analytics, and vector storage | No Kingston Storage path is active | P0 | Keep disabled | Config/static check | KEEP |
| SOCIAL-02 | Public profiles, DMs, collaboration, and follows are later-wave | Source/models remain but active Edge mutations are disabled | Active Feed UI still presents social affordances; provider data is quarantined | P0 | UI removal awaits frontend skill; keep data fail closed | Static source trace; UI pending | BLOCKED |
| COMP-01 | Gala, territory, districts, and marketplace are not in Kingston | Routes resolve unavailable and authority providers fail closed | Dormant source remains | P0 | Preserve quarantine | Authority containment/static route evidence | QUARANTINE |
| TALENT-01 | Casting purchases are not in Kingston | Casting provider is unavailable and route is unavailable | Dormant screens/models remain | P0 | Preserve quarantine | Static source trace | QUARANTINE |
| AI-01 | Generative AI is not part of the Kingston disposable prototype | No enabled generative-AI endpoint was found | No contradiction in active allowlist | P0 | Keep absent | Edge allowlist static pass | KEEP |
| MON-02 | Payment never changes score, recovery, rank, Gala, territory, or progression | IAP endpoint and premium runtime are disabled | Full F2P parity needs later behavioral proof | P1 | Keep payments disabled throughout Kingston proof-of-fun | Static allowlist only | KEEP |

## Gate interpretation

- A `Static pass` proves repository text/configuration agrees with a guard; it
  does not prove PostgreSQL privileges, transactions, Edge runtime behavior, or
  Flutter behavior.
- The unlinked disposable database applied every migration and is healthy after
  restart; the latest reset command itself returned `1` only because Storage
  missed its health deadline. Migration listing, database lint, current RLS and
  Kingston contracts, the 44-test immediate-containment suite, the 15-test
  security-hardening suite, and all four 20-way economic races passed.
- Historical tests that require authenticated direct `public` relation or RPC
  access fail under the final API-only boundary. The protected identity tests
  were not modified; their contract conflict remains explicit.
- A fresh detached checkout of local HEAD passes the committed database and
  Edge scopes but fails the Early Game static guard because the matching
  nonvisual Flutter caller corrections are still uncommitted. Dirty-tree static
  success is not branch-readiness evidence.
- Flutter/UI rows cannot advance to aligned while the repository's required
  `frontend-design` skill is absent and Smiley-run format/analyze/test/build
  output has not been observed.
- No row authorizes production access, migration deployment, a push to
  `master`, a merge, signing, or distribution.
