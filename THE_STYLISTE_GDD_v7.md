# The Styliste — Canonical Game Design Document v7

Status: canonical product and implementation specification
Audience: design, engineering, art, narrative, QA, analytics, and operations
Scope: vertical slice, Alpha, Launch, and clearly labelled expansion

## Table of Contents

1. [Product Vision](#1-product-vision)
2. [Design Pillars](#2-design-pillars)
3. [Audience and Player Fantasy](#3-audience-and-player-fantasy)
4. [Core Gameplay Loop](#4-core-gameplay-loop)
5. [First Session and First Week](#5-first-session-and-first-week)
6. [Player Paths and Progression](#6-player-paths-and-progression)
7. [World, Cities, and Customer Segments](#7-world-cities-and-customer-segments)
8. [Designer Systems](#8-designer-systems)
9. [Mogul Systems](#9-mogul-systems)
10. [Economy and Simulation](#10-economy-and-simulation)
11. [Social Feed and Multiplayer](#11-social-feed-and-multiplayer)
12. [Narrative, Luxe, Vex, and Rivalry](#12-narrative-luxe-vex-and-rivalry)
13. [Crisis and Reputation Systems](#13-crisis-and-reputation-systems)
14. [Live Events and Competitive Play](#14-live-events-and-competitive-play)
15. [Talent and Staff](#15-talent-and-staff)
16. [Idle Progression, Joint Venture, and Ascension](#16-idle-progression-joint-venture-and-ascension)
17. [Monetization and F2P Integrity](#17-monetization-and-f2p-integrity)
18. [UI/UX, Accessibility, and Performance](#18-uiux-accessibility-and-performance)
19. [Technical Architecture and Security](#19-technical-architecture-and-security)
20. [Analytics and Product Metrics](#20-analytics-and-product-metrics)
21. [Scope and Release Roadmap](#21-scope-and-release-roadmap)
22. [Feature Acceptance Criteria](#22-feature-acceptance-criteria)
23. [Glossary](#23-glossary)
24. [Version 7 Changelog](#24-version-7-changelog)

## 1. Product Vision

The Styliste is a portrait-first fashion empire simulation in which creative identity,
business strategy, social reputation, and narrative relationships continuously affect one
another. The player rises from an unknown creator to a global fashion house by making
decisions whose consequences are remembered by customers, rivals, characters, markets,
and the community.

The game preserves the Aurelian Radiance identity: luxurious, editorial, cinematic, and
strategically precise. Atelier, Ledger, Feed, Luxe, Vex, Maisons, rivalries, crises, and
the Aurelian Gala are connected surfaces of one remembered brand history, not isolated
menus. The memorable differentiator is:

> The player does not merely collect fashion. The player authors a brand history that the
> economy, characters, rivals, and community remember.

The governing product promise is that the player can always understand what happened,
why it happened, what changed, who reacted, and what strategic action is available next.
This document is self-contained and supersedes active mechanic ambiguity in the prior
specification. Its continuity requirements are incorporated directly into the sections
below.

## 2. Design Pillars

### 2.1 Consequences over menus

Every major action creates consequences in at least two connected systems. Additional
screens do not create depth; lasting, understandable consequences do.

### 2.2 Explainable authority

The server owns reality. The client presents choices, previews, cached reads, and
server-confirmed results. No important score, currency, demand, reward, relationship,
ranking, or elapsed-time result is silently reconstructed on the client.

### 2.3 Fashion as art and business

The Artisan and Architect paths are independently satisfying and mutually influential.
Creative identity can alter commercial opportunity; commercial choices can alter the
meaning and reach of creative work.

### 2.4 A brand with memory

Important designs, deals, crises, relationships, rivalries, and victories persist in the
Story Archive. Luxe remembers meaningful choices. Vex develops an opinion of the brand's
history rather than scoring one isolated screen.

### 2.5 Strategy defeats spending

Purchases may improve expression, collection, presentation, and bounded convenience.
They may not raise competitive ceilings, determine scores, control markets, or erase
consequences.

### 2.6 Accessible editorial quality

The product uses a coherent Aurelian design system rather than interchangeable game UI.
Portrait-first ergonomics, readable hierarchy, screen-reader semantics, scalable text,
reduced motion, and measured performance are product requirements.

### 2.7 Voluntary engagement

Retention comes from mastery, identity, uncertainty, social meaning, collection,
unfinished strategy, and narrative anticipation. It must not depend on sleep disruption,
deceptive urgency, harmful streak loss, required advertisements, or external social spam.

## 3. Audience and Player Fantasy

### 3.1 Audience entry points

- Fashion designers and artists author a visual language, material philosophy, and house
  history.
- Tycoon and strategy players manage price, demand, suppliers, inventory, staffing,
  cities, risk, and long-term market position.
- Social and competitive players read the Feed, respond to rivals, submit to the Gala,
  and build a recognizable public identity.
- Casual players can follow clear objectives, enjoy style and characters, and make
  meaningful choices without prior fashion-industry knowledge.

### 3.2 The two fantasies

The Artisan fantasy is to make a point of view visible: choose a silhouette, material,
construction, audience, and ethical posture, then see customers and critics interpret it.

The Architect fantasy is to build a durable house: open stores, place stock, manage
suppliers, negotiate risk, shape demand, and turn a creative identity into an empire.

Both paths share Brand Rank, currencies, history, and world state. Neither path is a
cosmetic tutorial for the other.

## 4. Core Gameplay Loop

The canonical loop is:

```text
read the world
  → choose a creative or business direction
  → accept a tradeoff
  → commit resources
  → release, sell, negotiate, or respond
  → receive an authoritative result
  → watch customers, Luxe, Vex, rivals, and the Feed react
  → adapt the brand strategy
```

Every vertical-slice feature must expose its input, decision, tradeoff, authoritative
calculation, result explanation, consequence, and next action. Every major system must
feed at least two others:

- Atelier choices affect demand, Vex, customers, crises, Feed identity, and rivals.
- Pricing affects margin, accessibility, loyalty, Luxe Trust, Brand Heat, and inventory.
- Supplier choices affect quality, lead time, sustainability, crisis risk, and Founder
  Rep.
- Crisis responses affect sales, relationships, Feed discussion, valuation, and later
  narrative scenes.
- Rival actions create strategic responses rather than unavoidable penalties.

No major mechanic exists only as a timer or currency sink. No result is shown without its
major causes and the next available decision.

## 5. First Session and First Week

### 5.1 Onboarding promise

The required onboarding path lasts approximately three minutes and flows through seven
connected moments: world and brand fantasy; brand name; starter HQ city; market
positioning; lightweight founder identity; Artisan or Architect choice; immediate entry
into the first playable decision. Full avatar refinement remains available after the
first completed loop.

The Aurelian Sanctuary opening is cinematic but never blocks the first decision behind a
long sequence of standalone screens. The player always has a valid next action.

### 5.2 Artisan first session

```text
choose brand identity
  → select silhouette, material, audience, price tier, and one ethical tradeoff
  → complete the first design interaction
  → receive a server projection
  → mint and release the design
  → receive sales, Hype, Vex, Luxe, and Feed reactions
  → choose how to respond
  → unlock the next persistent objective
```

### 5.3 Architect first session

```text
choose brand identity
  → open the first store
  → select city, format, price tier, and inventory posture
  → receive the authoritative first sales result
  → react to demand, margin, or stockout information
  → receive Luxe, rival, and Feed reactions
  → unlock the next persistent objective
```

The first-store action is a server-backed atomic operation with an idempotency key. A
fresh player receives the starter store prerequisites and a usable CTA; a Ledger empty
state must never strand the player.

### 5.4 First-week promise

| Period | Required experience |
|---|---|
| First five minutes | Identity, path choice, and first meaningful tradeoff |
| First session | One complete causal loop |
| Day 1 return | Persistent consequences and one new opportunity |
| Days 2–3 | First rival action and first supply or audience decision |
| Days 4–5 | First authored crisis or collaboration |
| Days 6–7 | First chapter, broader social competition, and early Signature Direction |

By the end of week one every player has made at least three meaningful tradeoffs,
released or sold something, received an explained result, developed an early identity,
met Luxe as a character, received a Vex opinion, encountered Maison Vanta, faced a
crisis or opportunity, responded to the market, created a Story Archive history, and
understood what to pursue next.

No objective requires likes, votes, purchases, advertisements, or another player's
cooperation. Existing players receive historical objective backfill. Progress cannot be
completed through local state manipulation.

## 6. Player Paths and Progression

### 6.1 Shared and path-specific layers

- **Brand Rank (1–100):** shared account progression and feature access.
- **Path Mastery:** separate Artisan and Architect expertise.
- **Brand Identity:** persistent strategic traits earned through repeated choices.
- **Founder Rep:** long-term leadership, integrity, and reliability reputation.
- **Brand Heat:** short-term public relevance.
- **Followers:** audience scale, never a score substitute.
- **Market Share:** economic control in a city.
- **Luxe Trust:** relationship state with Luxe.
- **Legacy:** noncompetitive Ascension prestige.

Every stat has one definition, one server owner, and one visible explanation when it
changes. Rank rewards grant options, tools, capacity, cosmetics, and strategic breadth;
they do not create uncapped or unbeatable permanent multipliers. Casual and Expert modes
never alter reward multipliers, idle rates, event rewards, score ceilings, crisis
severity, or competitive eligibility.

### 6.2 Progression tests

The free path can reach every gameplay role and the full Hype range. No rank reward or
purchase creates an unreachable competitive ceiling. Progression is meaningful through
new decisions, capacity, information, identity, and narrative consequence rather than
exponential inflation.

## 7. World, Cities, and Customer Segments

### 7.1 Launch cities

Kingston has a strong cultural pulse, word-of-mouth, originality, credible storytelling,
streetwear, music, events, and collaboration opportunities. Paris emphasizes prestige,
critics, runway, heritage, quality, luxury, and collector demand, with severe response
to weak execution or false exclusivity. Tokyo emphasizes innovation, craftsmanship,
subculture, digital fashion, precision, novelty, limited drops, and collaborations.

Every city supports every segment. City strengths and risks are data-driven; no city is
objectively superior. Segment weights, reference prices, economic conditions, and trend
affinities are server configuration, not client constants.

### 7.2 Customer segments

- **Trendseekers:** relevance, novelty, social proof, and timing.
- **Collectors:** quality, rarity, story, craftsmanship, and prestige.
- **Everyday Stylists:** price-value fit, wearability, trust, availability, and loyalty.

City identity is fictional worldbuilding, not a stereotype about real-world wealth or
taste. Additional cities follow vertical-slice validation.

## 8. Designer Systems

### 8.1 Canonical design grammar

Every design session contains silhouette, material, construction technique, palette,
target segment, price tier, production difficulty, sustainability posture, and production
quantity. Each option declares its visual identity, segment effect, quality potential,
production cost, production time, supplier requirement, demand effect, exclusivity
effect, crisis risk, and sustainability impact.

No option is strictly superior in every context. An avant-garde silhouette raises
originality and prestige potential while narrowing reach. A rare material raises quality
and collector appeal while increasing cost and supply risk. Simplified construction lowers
cost and lead time while lowering the craft ceiling. Accessible pricing raises reach and
loyalty while reducing margin or exclusivity. Limited quantity raises scarcity and
stockout risk. Ethical supply raises trust and resilience at a short-term cost.

### 8.2 Atelier interaction

Verlet cloth is the tactile visual center. The interaction influences authored design
state or presentation, but it is not a repetitive reflex gate and remains meaningful on a
simplified visual fallback. The Atelier screen shows the current objective, the decision
being made, the projected tradeoff, and the resources at risk before commit.

### 8.3 Hype Score

All components are normalized to 0–100 and calculated by the server from frozen,
validated inputs:

```text
Base_Design_Score =
    0.22 × Aesthetic_Cohesion
  + 0.16 × Material_Quality
  + 0.16 × Construction_Execution
  + 0.16 × Originality
  + 0.12 × Audience_Fit
  + 0.10 × Cultural_Timing
  + 0.08 × Responsibility

Context_Adjustment = Trend_Context + City_Context + Release_Timing + Crisis_Context
Hype_Score = clamp(round(Base_Design_Score + Context_Adjustment), 0, 100)
```

`Context_Adjustment` is bounded from −15 to +15. Score bands are 0–34 Miss, 35–54
Developing, 55–69 Noticed, 70–84 Breakout, 85–94 Alpha, and 95–100 Iconic. Talent,
cosmetics, purchases, advertisements, and Season Pass entitlements never add points.
Talent can reveal projections, reduce uncertainty, unlock an alternative tradeoff, or
provide a free-progression-equivalent archetype.

Every result returns a structured explanation: what happened, why it happened, what
changed, who reacted, and what the player can do next. The client displays the
server-provided breakdown.

## 9. Mogul Systems

The minimum complete Mogul system includes stores, customer segments, city demand,
selected price, reference price, inventory, suppliers, lead time, quality variance,
campaigns, stockouts, overstock, loyalty, operating cost, margin, cash flow, and market
share.

The Architect chooses a city, store format, price posture, inventory posture, supplier
mix, campaign, and response to demand. The system surfaces the tradeoff before commit;
the result explains the major causes and presents at least one valid next action.

The first store is a progression-critical flow. Empty Ledger and HQ states must offer a
reachable, appropriately labelled action to open it when prerequisites are satisfied.
No client-created store, inventory, price, currency, or reward is accepted as authority.

## 10. Economy and Simulation

### 10.1 Demand and settlement

```text
Price_Response = clamp(
  pow(Reference_Price / Actual_Price, Segment_Elasticity),
  0.25,
  2.00
)

Potential_Demand = Base_Demand
  × Segment_Fit
  × Trend_Fit
  × Quality_Modifier
  × Brand_Heat_Modifier
  × Price_Response
  × Campaign_Modifier
  × Economic_Modifier
  × Availability_Modifier

Fulfilled_Units = min(round(Potential_Demand), Inventory_Available)
Revenue = Fulfilled_Units × Actual_Price
Gross_Profit = Revenue − Product_Cost − Campaign_Cost
  − Store_Operating_Cost − Logistics_Cost
```

Sales never exceed inventory and inventory never becomes negative. During a surge the
player can raise price, maintain price to build loyalty, increase production, create
scarcity, redirect stock, launch a campaign, or preserve inventory for another city.
Each option creates different short- and long-term consequences. The system does not
punish a player merely for maintaining an accessible price during a viral moment.

### 10.2 Currencies and ledger

- **House Funds:** earned soft currency for production, stores, campaigns, staffing, and
  upgrades.
- **Luxe Credits:** purchased premium currency for cosmetics, premium presentation, and
  optional bundles.
- **Aurelian Seals:** earned-only prestige currency for legacy cosmetics and status.

Temporary event currencies are allowed only with documented purpose, automatic retirement,
and server settlement. The append-only economic ledger records authority, rule version,
idempotency key, timestamp, causes, and resulting balance. Duplicate grants and negative
balances are rejected.

## 11. Social Feed and Multiplayer

The Global Feed is a gameplay surface. Cards may create trend opportunities, customer
reactions, Vex reviews, Luxe responses, rival moves, collaboration offers, supplier
competition, crisis developments, plagiarism disputes, Maison objectives, Gala
invitations, and market shifts.

Every actionable card answers: “What can the player do because this happened?” NPC
brands and authored reactions keep the first week lively without requiring a large live
population. Expired opportunities cannot be accepted; duplicate actions are idempotent;
blocked users cannot interact through alternate surfaces; player content cannot alter
authoritative calculations.

Public profiles, Feed posts, Gala entries, and leaderboard data use controlled public
access. External sharing may support discovery, but external likes, screenshots, QR
scans, or social-platform engagement never directly grant Hype, ranked power, rare
materials, or economic advantage. Verified referrals can grant cosmetics after a retained
user milestone.

Reporting, blocking, moderation review, and player support are first-class launch
surfaces. Reports identify the reported content or interaction, reason, evidence, and
status; block state applies across Feed, direct messages, profiles, and multiplayer
surfaces. Moderation outcomes and support resolutions are auditable, explainable, and
never used as hidden competitive modifiers.

## 12. Narrative, Luxe, Vex, and Rivalry

### 12.1 Luxe: The First Cut

Luxe is a persistent character and relationship, not a reward timer. Trust changes
primarily through decisions. Season One chapters are:

1. The House Opens — identity and ambition.
2. The First Risk — creative or financial tradeoff.
3. Vanta’s Shadow — first rival intervention.
4. The Cost of Hype — accessibility, ethics, or profit conflict.
5. The Receipts — crisis truth and accountability.
6. Crown or Community — prestige versus loyalty.
7. The House Remembers — consequence and future direction.

Luxe remembers positioning, ethics, pricing, collaborator treatment, repeated aesthetic
direction, rival interactions, and whether the player chooses prestige, accessibility,
control, or community. Daily check-ins may grant small bounded rewards but never replace
relationship choices or grant permanent multipliers. Dialogue and Archive entries only
reference events that occurred.

### 12.2 Vex: persistent critic history

Vex tracks originality, execution, restraint, cultural relevance, and integrity. The
authoritative system considers the current result, prior reviews, repeated choices,
revisions, derivative work, trend chasing, crisis behavior, Maison context, and rival
context. Classification and opinion shifts are server-owned.

An optional AI service may turn structured results into short editorial prose behind a
trusted boundary. It never determines Hype, rewards, penalties, market outcomes, event
placement, or moderation. Vex distinguishes a new observation from a historical
pattern, and the player can inspect the evidence behind a review.

### 12.3 Rivalry and Archive

Maison Vanta, founded by Seraphine Vale, is the first persistent rival house. Rivals
observe player choices, adapt their offers and responses, and create decisions. They do
not impose unavoidable losses. The Story Archive stores designs, deals, crises,
relationships, rival actions, Gala results, and meaningful consequences in chronological
context.

## 13. Crisis and Reputation Systems

Crises are authored decision sequences involving a claim, evidence, time window,
stakeholders, and possible resolutions. The player sees the credibility, cost,
relationship, and market tradeoff before committing. A resolution returns a structured
explanation and writes a permanent Archive entry.

A crisis cannot be resolved twice. Client clock changes cannot bypass deadlines. Choices
produce different later scenes. No response fabricates evidence or targets another player
with an accusation. The visual recovery ritual after resolution must not erase narrative
consequences. Founder Rep, Brand Heat, Luxe Trust, sales, Feed discussion, and rival
behavior may change, but each delta names its cause.

The crisis screen defines loading, evidence-unavailable, offline, error, disabled,
expired, resolved, and next-action states. It never hides a meaningful consequence behind
decorative motion.

## 14. Live Events and Competitive Play

### 14.1 Trend cadence

- **Daily Trend Pulse:** small city or segment movement, with a maximum effect of
  approximately ±5%.
- **72-Hour Trend Wave:** a forecast aesthetic with 24-hour warning and 72-hour active
  period; maximum Hype context adjustment is +8. It affects audience interest, Feed
  discussion, and city demand without making off-trend work invalid.
- **Seasonal Trend Tsunami:** a rare authored live event that changes several markets and
  creates shared objectives, rival activity, and narrative consequences.

Players may follow, reinterpret, oppose, preserve inventory, pre-position stock,
counter-program, or collaborate. Trend bonuses cannot overpower design quality. Events
use server time, immutable rule versions, and frozen settlement inputs. Multiplicative
stacking is not used.

### 14.2 Aurelian Gala

The Aurelian Gala is a weekly skill-based tournament:

| Phase | Time |
|---|---|
| Theme reveal | Monday |
| Creation period | Monday–Thursday |
| Submission lock | Friday |
| Anonymous judging and voting | Saturday |
| Results and Archive | Sunday |

```text
Final_Gala_Score =
    0.35 × Theme_Interpretation
  + 0.25 × Design_Execution
  + 0.20 × Originality_And_Brand_Identity
  + 0.10 × Strategic_Brief
  + 0.10 × Normalized_Community_Vote
```

Community voting is anonymous during voting, normalized for audience size, rate-limited,
weighted against suspicious account clusters, and unable to determine the winner alone.
Paid cosmetics, talent editions, follower count, advertisements, and spending do not
modify score. There is one eligible submission per account; scores freeze at settlement;
claims are idempotent; a new skilled account can place highly; brigading cannot dominate.

### 14.3 Authored fashion calendar and Maison legacy

Fashion Week and other authored calendar events are seasonal decision spaces with
published themes, deadlines, judging rules, and consequence summaries. Maison Wars,
district influence, and legacy watermarks express house identity and city history without
granting hidden combat power or paid competitive modifiers. District state, event
placement, and legacy rewards are server-settled and replayable from immutable inputs.

## 15. Talent and Staff

### 15.1 Staff Contracts

Gameplay staff are earned through progression, quests, events, House Funds, reputation,
and negotiation. They provide horizontal strategic archetypes and tradeoffs. Every
functional archetype has a deterministic free acquisition path. Recruitment state is
server-authoritative.

### 15.2 Icon Editions

Monetized collectible editions may provide portraits, animations, voice lines, entrance
cinematics, VFX, Atelier presentation, Feed frames, and HQ appearances. They never
provide Hype points, idle multipliers, valuation multipliers, Feed-ranking bonuses,
market-share bonuses, event score, or an exclusive strategic archetype.

If random cosmetic acquisition remains, one pity standard applies: Featured Icon Edition
by 40 pulls and selected premium rarity by 80 pulls. Counters persist across equivalent
banners, odds are published, and duplicate conversion grants cosmetic-only value.

## 16. Idle Progression, Joint Venture, and Ascension

### 16.1 Idle progression

Offline accumulation runs for up to 24 hours. Buffer Stock upgrades may extend the cap to
36 hours. Earnings stop when Buffer Stock is full; there is no punitive decay after the
cap. Active play improves efficiency through strategy, not login coercion. Settlement
uses server time, one idempotency key, and one authoritative ledger entry per period.

### 16.2 Casual and Expert

Modes change presentation and control depth only. Casual Mode automates advanced choices
using transparent defaults. Expert Mode exposes detailed controls and forecasts. Both
use the same outcomes, rates, rewards, ceilings, crisis severity, and eligibility.

### 16.3 Joint Venture

At Rank 50, the secondary path unlocks as a new division with initial secondary
throughput of 60%. Path-specific mastery progresses it to 100%. There is no instant
doubling of the economy. The original path remains narratively dominant, and both
divisions use one shared economic ledger.

### 16.4 Aurelian Ascension

At Rank 100, the player creates a permanent Hall of Sovereigns legacy statue, preserves
the existing empire, unlocks optional Legacy Challenges and a parallel New House run,
and carries cosmetics, Archive history, and one Classic Alpha design. Ascension grants
prestige and replayability without permanent Hype, idle, market, or ranked multipliers;
it does not reset the main empire and matchmaking remains normalized.

## 17. Monetization and F2P Integrity

The constitution is:

> Players may purchase expression, collection, presentation, and bounded convenience.
> Players may not purchase victory, market control, superior score ceilings, exclusive
> strategic power, or immunity from consequences.

The storefront may include cosmetics, an eight-week Season Pass, Luxe outfits, founder
and avatar cosmetics, HQ themes, Feed frames, garment visual effects, Vex card
treatments, Icon Editions, and optional bounded production convenience outside ranked
windows. The resale platform fee is an in-game economy sink, not studio revenue.

There are no interstitial advertisements at launch. Rewarded advertising is deferred
until after launch review. There are no monetized score or idle multipliers, paid Feed
visibility, paid valuation bonuses, competitive advertising boosts, premium economic
Blueprints, tradable paid power, or permanent streak multipliers. Prices, contents,
probabilities, purchase confirmation, cancellation, and entitlement restoration are
explicit. Receipts are verified server-side and rewards are idempotent.

## 18. UI/UX, Accessibility, and Performance

### 18.1 Binding UI/UX authority

All UI/UX design and implementation for The Styliste must follow the repository’s
`frontend-design` skill together with the established Flutter design system. The skill
governs visual direction, hierarchy, typography, composition, interaction states, motion,
accessibility, mobile ergonomics, and anti-generic design standards.

The skill is the primary UI/UX design methodology for this GDD. It must improve, not
replace, the repository’s Flutter architecture, Riverpod patterns, Aurelian visual
identity, portrait-first layout, accessibility requirements, 60 fps target, and low-end
Android fallbacks. No new font, color, effect, spacing rule, or component convention is
valid until integrated into the existing token system.

Every major interface has a clear aesthetic concept, a primary action, and an explicit
hierarchy. Every screen defines loading, empty, error, disabled, offline, unavailable,
and success states. Every gameplay result communicates what happened, why it happened,
and what the player can do next. Monetization is visually secondary to gameplay.

Artisan and Architect have distinct visual identities within one coherent brand system:
Artisan emphasizes tactile material, silhouette, authorship, and editorial reveal;
Architect emphasizes spatial planning, ledger clarity, supply flow, and controlled
decision density. Both use the existing Aurelian palette, typography, spacing, surfaces,
buttons, cards, modals, and navigation conventions.

### 18.2 Surface evaluation

The frontend-design audit covers these required surfaces:

- **Onboarding:** a cinematic Aurelian Sanctuary opening with a three-minute path,
  reachable thumb-zone actions, resumable state, text expansion, and a direct first
  decision.
- **Atelier:** an editorial workbench with tactile cloth feedback, visible tradeoffs,
  server projection, safe commit, and a simplified visual fallback.
- **Ledger:** a calm, high-legibility financial record with explainable deltas,
  actionable first-store empty state, loading/error/offline handling, and no decorative
  treatment that obscures values.
- **HQ:** the strategic home with immediate gameplay information first, current objective
  second, resources and alerts next, navigation after that, and promotional information
  last.
- **Feed:** a fashion-editorial consequence wall where every actionable card names the
  opportunity and next move; authored NPC activity prevents an empty first week.
- **Luxe:** a character-led relationship presentation where history and consequence are
  legible; check-in rewards never overpower narrative decisions.
- **Vex:** an editorial critic card with evidence, opinion history, and clear separation
  between authoritative classification and optional prose.
- **Crises:** focused evidence and decision framing, explicit stakes, no double-submit,
  expired/offline/error states, and a permanent consequence receipt.
- **Gala:** a weekly runway-like flow with schedule, submission lock, anonymous judging,
  score breakdown, settlement confirmation, and Archive result.

### 18.3 Interaction, motion, and accessibility

Use existing Flutter and Riverpod architecture, semantic labels, logical traversal order,
visible focus, non-color state indicators, sufficient contrast, scalable text, minimum
touch targets, safe areas, left- and right-handed ergonomics, localization-safe layouts,
captions or alternatives for meaningful audio, reduced motion, and reduced transparency
where supported.

Motion communicates selection, causality, hierarchy, success, error, and high-value
reveals. It uses existing Flutter animation APIs and tokenized duration/easing. It never
blocks input or hides a loading delay. Reduced motion preserves meaning through instant
state changes and concise feedback. Reward animation remains skippable after critical
information is visible.

### 18.4 Performance contract

The target is 60 fps with an approximately 16.7 ms frame budget. The Samsung Galaxy A55
is the primary reference device. Profile or release-mode evidence is required before a
performance claim. Lower-end devices use reduced cloth nodes, static Feed garment
previews, simplified particles, reduced blur, and shader fallbacks. No live cloth
simulation runs on every Feed card; no large animated blur layer runs during active
interaction; network activity never blocks touch feedback. Animation complexity is
proportional to device performance, battery, thermal cost, and screen importance.

Visual effects are isolated and profiled; image cache dimensions are bounded; expensive
painting and decoding are not repeated in `build`; controllers and listeners are
disposed. No second design system or package is introduced when the existing stack can
solve the problem.

## 19. Technical Architecture and Security

### 19.1 Canonical stack

**Client:** Flutter and Dart, Riverpod, portrait-first layout. The client owns
presentation, input, previews, and cached read state.

**Backend:** Supabase Auth, PostgreSQL, Row Level Security, Supabase Realtime, Supabase
Storage, PostgreSQL functions for transactional consistency, and Supabase Edge Functions
for trusted orchestration and external services.

**Platform services:** Google Play Billing and StoreKit with server-side receipt
verification; Play Integrity and Apple App Attest or equivalent device-integrity signals;
platform push providers; analytics with data minimization.

AI services may generate bounded presentation text behind trusted Edge Functions. AI does
not own gameplay state, settlement, scoring, rewards, moderation, or competitive results.

The current Flutter integration preserves `AurelianTheme`/`AurelianPalette`, reusable
presentation widgets, `MainShell` navigation, and feature modules under
`lib/features/`. The current Supabase implementation is the evidence baseline for
authority, not permission to expose client totals.

### 19.2 Server-authority matrix

| Domain | One authoritative owner | Client responsibility |
|---|---|---|
| Currency and ledger | PostgreSQL transaction and ledger | Display confirmed balance |
| Inventory and stores | PostgreSQL functions/RLS | Submit intent and render state |
| Designs and Hype | PostgreSQL calculation rules | Collect input and show breakdown |
| Scores and rewards | Settlement function with rule version | Display frozen result |
| Progression/objectives | PostgreSQL progression events | Render current objective |
| Feed actions/followers | RLS plus idempotent RPC or Edge orchestration | Request action and show status |
| Event entries and votes | Event settlement functions | Submit eligible entry/vote |
| Market share | PostgreSQL settlement | Display confirmed share |
| Purchases and talent ownership | Receipt verification service and database | Start purchase and restore |
| Crisis and rival state | Server event state and immutable timestamps | Render choices and history |

### 19.3 Security requirements

Require server timestamps, immutable calculation-rule versions, idempotency keys,
append-only economic events, transactional currency and inventory mutation, row locking
for contested state, request validation, rate limiting, purchase verification, RLS,
audit logs, anti-Sybil signals, suspicious-vote analysis, replay protection, secure
secret storage, and server-authoritative event settlement. There are no trusted client
totals, client-determined rewards, or client-determined elapsed times.

Data is classified as public, shared, private, or administrative. Public profiles, Feed
posts, Gala entries, and leaderboards are intentionally controlled cross-player reads;
private and administrative data never becomes public through a broad policy. Every
player-owned table has tested RLS. No service credential reaches the client. Sensitive
mutations have one server owner and retryable mutations are idempotent.

Current calculation and mutation paths include the `process_idle_income` PostgreSQL RPC,
atomic first-store and upgrade operations, feed reaction orchestration, Gala submission
and voting functions, crisis functions, and server-side purchase verification. A client
must not invoke a retired or duplicate authority path. Implementation verification also
follows `PROJECT_RULES.md` and
`VERIFICATION_PROTOCOL.md`.

## 20. Analytics and Product Metrics

Track each metric with a numerator, denominator, time window, event version, and data
minimization review:

- onboarding completion and time to first meaningful decision;
- first Artisan loop, first Architect loop, and first consequence response;
- Day 1 and Day 7 return, objective completion, and Feed action rate;
- Luxe chapter completion, rival-response rate, crisis decision distribution, and Gala
  participation;
- economy inflation, stockout rate, overstock rate, and market-share movement;
- F2P versus payer competitive performance;
- crash-free sessions, frame-time performance, and accessibility-setting usage.

Engagement is healthy when it is voluntary and rooted in mastery, identity, uncertainty,
social meaning, and consequence. Prohibit fake countdowns, false scarcity, punitive sleep
disruption, progress-destroying streak loss, disguised advertisements, confusing offers,
required social spam, paywalls inside active crises, and rewards dependent on harassment
or external engagement manipulation. Competitive parity is measured, not merely asserted.

## 21. Scope and Release Roadmap

### Vertical Slice

Onboarding; persistent first-week objectives; first Artisan loop; first Architect loop;
design grammar; first-store flow; Kingston, Paris, and Tokyo; three customer segments;
pricing, demand, suppliers, and inventory; Feed reactions; Luxe Season One opening; Vex
history; Maison Vanta; one branching crisis; and consequence explanations.

### Alpha

Expanded stores; campaigns; basic Maisons; basic collaborations; Aurelian Gala; broader
Luxe season; multiple rival actions; limited live Trend Waves; Staff Contracts; and Story
Archive depth.

### Launch

Complete first narrative season; expanded cities; Maison Wars; advanced supply chains;
wholesale; Fashion Week; equity and IPO systems; Season Pass; Icon Editions; and full
moderation and support.

### Post-Launch

AR Try-On; Street Snaps; resale; advanced B2B; deeper digital-product-passport
simulation; digital fashion; repair and longevity services; endorsement and
collaboration contracts; district influence and legacy watermarks; larger live events;
additional rival houses; and additional Luxe seasons.

### Deferred pending validation

Voice chat; real-time shared Atelier; live runway streaming; hostile player takeovers;
player-owned public equities; external engagement rewards; blockchain and related
tokenized systems.

Standalone reflex mini-games and reward loops that would make social spam, streak loss,
or external engagement economically compulsory are intentionally removed from the
canonical design. Their useful decision value is represented by Atelier, supply,
crisis, Feed, and event choices. Detailed digital-product-passport compliance and
advanced wholesale rules remain Post-Launch until their legal, operational, and
performance contracts are validated.

Every feature has exactly one status. No vertical-slice dependency requires a deferred
concept. A route or screen alone is not completion. Roadmap order prioritizes depth,
causal clarity, and first-week reliability over breadth.

## 22. Feature Acceptance Criteria

Every active feature is documented using this contract:

1. Player goal.
2. Entry condition.
3. Inputs.
4. Decision and tradeoff.
5. Authoritative calculation and owner.
6. Success and failure.
7. Consequences and affected systems.
8. What happened, why, what changed, who reacted, and next action.
9. Loading, empty, error, disabled, offline, unavailable, and success states.
10. Offline behavior and resume behavior.
11. Security and RLS requirements.
12. Accessibility and localization requirements.
13. Performance budget and low-device fallback.
14. Analytics events with numerator, denominator, and time window.
15. Objective pass/fail acceptance criteria.

A feature is complete only when its causal loop works in profile or release mode and the
server-confirmed result is understandable. A route, schema, provider, or visual surface
alone is insufficient. Every Vertical Slice feature identifies its server authority,
supports non-happy-path states, prevents duplicate mutation, and explains its result.

## 23. Glossary

| Term | Meaning |
|---|---|
| Artisan | Designer starting path |
| Architect | Mogul starting path |
| Brand Rank | Shared account progression from 1 to 100 |
| Path Mastery | Separate Artisan and Architect expertise |
| Hype Score | Server-calculated performance of one released design |
| Brand Heat | Short-term public relevance |
| Founder Rep | Long-term leadership and integrity reputation |
| Followers | Audience scale |
| Market Share | Economic control in a city |
| Luxe Trust | Persistent relationship state with Luxe |
| House Funds | Earned soft currency |
| Luxe Credits | Purchased premium currency |
| Aurelian Seals | Earned-only prestige currency |
| Alpha | Hype Score from 85 to 94 |
| Iconic | Hype Score from 95 to 100 |
| Aurelian Gala | Weekly strategy-based fashion tournament |
| Maison Vanta | First persistent rival house |
| Seraphine Vale | Founder of Maison Vanta |
| The First Cut | Luxe Season One |
| Trend Pulse | Daily minor demand movement |
| Trend Wave | Forecast 72-hour aesthetic movement |
| Trend Tsunami | Rare seasonal live meta event |
| Aurelian Ascension | Noncompetitive legacy and replayability system |

## 24. Version 7 Changelog

Version 7 consolidates the product vision into one self-contained specification and
establishes the causal loop as the organizing rule. It makes the first week persistent
and server-backed; turns Atelier, Mogul, Feed, Luxe, Vex, crises, rivals, and Gala into
connected consequence systems; normalizes scoring and economy formulas; separates Staff
Contracts from Icon Editions; defines idle, modes, Joint Venture, Ascension, and fair
monetization; replaces mixed authority with Supabase and PostgreSQL ownership; adds a
server-authority matrix and anti-cheat contract; and separates vertical-slice,
Alpha, Launch, Post-Launch, and deferred scope.

The continuity review preserves or explicitly dispositions the remaining unique
concepts: moderation and support are Launch requirements; Fashion Week, Maison and
district legacy, endorsement contracts, repair and longevity services, resale, digital
product passports, and advanced wholesale are staged; standalone reflex mini-games and
harmful external-engagement reward loops are removed because their intended value is
covered by the core causal loop.

This version also adopts the repository’s `frontend-design` skill as the primary UI/UX
methodology while preserving the established Flutter design system and Aurelian visual
identity. It adds required states, result explanations, accessibility behavior, motion
fallbacks, low-performance fallbacks, and measurable 60 fps evidence requirements for
Onboarding, Atelier, Ledger, HQ, Feed, Luxe, Vex, crises, Gala, and all future major
interfaces.

Binding implementation references: `PROJECT_RULES.md` and
`VERIFICATION_PROTOCOL.md`.
