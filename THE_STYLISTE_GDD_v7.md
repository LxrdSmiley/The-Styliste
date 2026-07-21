# The Styliste — Canonical Game Design Document v7

Status: canonical product and implementation specification
Audience: design, engineering, art, narrative, QA, analytics, and operations
Scope: solo-developer proof-of-fun, Early Game/FTUE, Alpha, Beta, Late Game, End Game, and clearly labelled deferred expansion
Revision note: v7 idle-tycoon, Luxe Quest System, ethical monetization, competitive multiplayer, living NPC/AI world, Luxe-led FTUE, implementation-phase staging, Supabase high-assurance security, solo-developer feasibility, and production UI/UX architecture pass; canonical version remains v7

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
12. [Narrative, Luxe, Vex, Rivalry, and the Living Fashion World](#12-narrative-luxe-vex-rivalry-and-the-living-fashion-world)
13. [Crisis and Reputation Systems](#13-crisis-and-reputation-systems)
14. [Live Events and Competitive Play](#14-live-events-and-competitive-play)
15. [Talent and Staff](#15-talent-and-staff)
16. [Idle Progression, Joint Venture, and Ascension](#16-idle-progression-joint-venture-and-ascension)
17. [Monetization and F2P Integrity](#17-monetization-and-f2p-integrity)
18. [UI/UX, Accessibility, and Performance](#18-uiux-accessibility-and-performance)
19. [Technical Architecture and Security](#19-technical-architecture-and-security)
20. [Analytics and Product Metrics](#20-analytics-and-product-metrics)
21. [Implementation Staging and Release Roadmap](#21-implementation-staging-and-release-roadmap)
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
specification. Baseline continuity is retained from `THE_STYLISTE_GDD_v6.md` §§1–12.

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
unfinished strategy, narrative anticipation, and rewarding voluntary objectives. It must not
depend on sleep disruption, deceptive urgency, harmful streak loss, required advertisements,
external social spam, or quests designed around purchases. Missing a Daily Brief or Weekly
Commission never removes previously earned progress, currency, trust, or access.

### 2.8 Build the machine, then direct it

The player begins close to the work, learns each operation through meaningful decisions,
and then earns automation that removes repetition without removing strategy. Automation
must expose the policy it follows, the capacity it controls, the mistakes it can make, and
the intervention available to the player. Progress is visible in the Atelier, stores, staff,
supply network, HQ, Ledger, and world map rather than existing only as larger numbers.

### 2.9 Competition creates mobility, not permanent castes

Competitive systems create stories, rivalries, status, and strategic pressure without turning
early arrival, lifetime wealth, roster size, or spending into permanent rule over the world.
Rankings emphasize current-season execution; territory benefits are bounded and costly to
maintain; new players receive protected entry, separate placement, and viable catch-up routes;
and seasonal resets preserve trophies and history while reopening competitive opportunity.
No purchase grants ranking points, territory strength, additional eligible Gala entries, or a
higher competitive ceiling.

### 2.10 Simulated society, not synthetic authority

NPCs and AI make the fashion world legible, reactive, opinionated, and socially alive. They do not
replace the rules of the game. Customer demand, Hype, sales, contracts, territory, Gala scoring,
rewards, and competitive outcomes remain deterministic or bounded server calculations using
validated structured inputs. AI may interpret those results into dialogue, criticism, negotiation,
reports, and character behavior, but it cannot invent authoritative facts or secretly change an
outcome.

NPCs have declared tastes, interests, budgets, loyalties, relationships, memories, and constraints.
Different NPCs may disagree about the same garment for understandable reasons. Fashion criticism
addresses the work, price, execution, brand claims, and context; it never attacks the player's body,
identity, protected characteristics, or presumed real-world worth. All AI-generated presentation has
a safe deterministic fallback so the simulation remains playable during service failure or on a
low-performance device.

### 2.11 Solo-first production discipline

The canonical vision is larger than the first shippable product. Development assumes one primary
developer using AI-assisted implementation, limited capital, limited operations capacity, and no
guaranteed launch population. The project therefore optimizes for a small, complete, maintainable game
before a broad live-service platform.

Every feature has three independent states:

- **Canonical:** approved as part of the long-term world.
- **Implemented:** built, secured, tested, and maintainable in the current codebase.
- **Enabled:** available to players in the current live build.

Canonical status does not authorize implementation, and implementation does not authorize exposure.
The default decision is to delay breadth until the existing loop is fun, stable, secure, affordable to
operate, and supportable by one developer. A smaller polished release is preferred over simultaneous
implementation of cities, social systems, trading, AI, live events, and monetization.

At any time, active development is limited to one primary gameplay feature, one supporting
backend/security feature, and one polish or usability feature. After a wave locks, adding one major
feature requires removing, postponing, or materially simplifying another. Features that fail a fun,
performance, security, moderation, cost, or maintainability gate are simplified or deferred rather than
protected because they appear in the canonical vision.

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
major causes and the next available decision. Continuity references: v6 §§2, 4.1, 5,
and 8.

## 5. First Session and First Week

### 5.1 Luxe-led onboarding promise and Founder Trial

Luxe owns the first-time user experience as the player's in-world assistant, mascot, and first
trusted relationship. The FTUE must feel like Luxe is helping the player open a fashion house, not
like an external tutorial layer explaining buttons. Luxe speaks from verified game state, points to
one relevant action at a time, and immediately connects every instruction to the player's emerging
brand identity.

The player reaches a meaningful input within **45 seconds**, completes the Founder Trial within
approximately **4–6 minutes**, and completes the first full causal loop within approximately
**8–12 minutes**. Cinematic presentation may continue around these actions but may not delay them.
Full avatar refinement, optional lore, advanced settings, and nonessential profile choices remain
available after the first completed loop.

#### 5.1.1 Luxe-led FTUE sequence

The canonical first-session sequence is:

1. **The Sanctuary wakes:** Luxe introduces the fantasy in one concise exchange and asks for the
   House name. Accessibility, text size, reduced motion, captions, and audio controls are reachable
   before the first animated sequence.
2. **Founder intent:** Luxe asks one lightweight question about what the player wants the House to
   represent. The answer seeds narrative framing and starter recommendations but does not create a
   hidden permanent bonus.
3. **One shared starter garment:** Luxe places one unfinished garment on the Atelier workbench so
   both path samples operate on the same visible object and feel connected.
4. **Artisan sample:** the player changes one proportion, assigns one material or palette choice,
   and sees the garment update immediately. Luxe explains one visible tradeoff using plain language.
5. **Architect sample:** the player chooses one audience, price posture, and inventory response for
   that same garment, then sees a short commercial projection and one visible store consequence.
6. **World reaction:** a small customer cohort responds, one representative customer reacts, and
   Vex gives one concise critique. Luxe summarizes disagreement without declaring one universal
   taste correct.
7. **Targeted response:** the player chooses either one design revision or one commercial response.
   Luxe previews the expected tradeoff but does not select the answer.
8. **Specialization decision:** Luxe compares the two fantasies using the player's own actions and
   asks which path should lead first. Luxe may recommend a path, but the recommendation names its
   evidence and can be ignored.
9. **First Main Quest:** Luxe opens the first persistent objective, explains the next reachable
   action, and releases the player into the normal game surface.
10. **First return:** on the next eligible return, Luxe delivers the first House While Away receipt,
    explains one consequence, and offers one immediate intervention rather than only a claim button.

The Founder Trial therefore prevents a blind permanent path choice. The selected primary
specialization determines onboarding emphasis, early Main Quests, initial tools, and narrative
framing; it does not permanently remove the other path. The secondary path remains available through
bounded support actions and collaboration until Joint Venture unlocks its full division at Rank 50.

A player receives one free primary-path reassignment before completing the first seven active days
or reaching Rank 10, whichever comes first. Reassignment preserves currency, designs, stores,
Archive history, cosmetics, quest rewards, and account progression; it changes only path-specific
tutorial state, early unlock ordering, and unspent path mastery. No purchase is required to correct
an early path decision.

#### 5.1.2 Luxe guidance modes and adaptive assistance

At any time during the FTUE, the player may choose one of three persistent guidance preferences:

- **Guide me:** Luxe provides step-by-step prompts, highlights the current action, and explains the
  result before advancing.
- **Brief me:** Luxe explains the objective and tradeoff, then leaves the interaction open.
- **Let me work:** Luxe remains available through an **Ask Luxe** control and intervenes only for a
  blocked state, critical warning, or requested explanation.

The player may switch modes without penalty. Luxe tracks tutorial knowledge as server-owned state so
completed explanations do not repeat across devices, reinstalls, reconnects, or path reassignment.
Luxe may offer one escalating hint after inactivity or repeated failure, but never performs an
irreversible action, spends currency, changes a design, accepts a contract, or makes a purchase for
the player.

Luxe's contextual help supports three requests on every major early surface:

1. **What am I deciding?**
2. **Why does it matter?**
3. **What can I do next?**

Hints reference only information the player has legitimately unlocked. They may reveal a relevant
cause or explain a visible system, but may not expose hidden competitive information, undiscovered
content, or an optimal answer.

#### 5.1.3 FTUE tone, failure, resume, and protection rules

Luxe is supportive but not falsely flattering. When a first design or store decision is weak, Luxe
acknowledges the useful intent, names the specific problem, and offers a recoverable next action.
Tutorial mistakes do not reduce Luxe Trust, create debt, consume premium currency, trigger public
embarrassment, or permanently damage the House.

The FTUE must:

- resume from the last confirmed decision after disconnect, process death, or device change;
- provide a direct skip for repeated explanatory dialogue while preserving required decisions;
- avoid shop prompts, paid bundles, advertisements, leaderboards, DMs, territory, and competitive
  pressure until the first complete loop is finished;
- prevent notification permission prompts until the player has experienced the value of a return;
- use captions and non-audio equivalents for all important Luxe communication;
- avoid forced gestures that conflict with assistive technology or reduced-motion settings;
- keep the current objective, direct action, and Ask Luxe control reachable from every FTUE surface;
- preserve player-authored choices rather than resetting them to demonstrate a tutorial outcome.

A Luxe-led FTUE is accepted only when representative new players can explain the difference between
Artisan and Architect play, identify why their first result occurred, locate the next action without
external help, and describe Luxe as useful rather than obstructive. High skip rate, repeated path
confusion, tutorial abandonment, or players treating Luxe as a shop mascot blocks Alpha promotion.

The Aurelian Sanctuary opening remains cinematic but never blocks the first decision behind a long
sequence of standalone screens. The player always has a valid next action, and path choice is
presented as a first specialization rather than an irreversible identity test.

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
| First six minutes | Identity, both Founder Trial samples, first specialization, first meaningful tradeoff, and Luxe's first Main Quest |
| First session | One complete causal loop and the first visible operation under player control |
| Day 1 return | Offline receipt, persistent consequences, Daily Briefs, one new opportunity, and first assistant automation |
| Days 2–3 | First rival action, first supply or audience decision, and first automation policy choice |
| Days 4–5 | First authored crisis or collaboration, first capacity bottleneck, and Weekly Commission preview |
| Days 6–7 | First chapter, first Weekly Commission capstone, broader social competition, early Signature Direction, and first department-level automation preview |

By the end of week one every player has made at least three meaningful tradeoffs,
released or sold something, received an explained result, developed an early identity,
met Luxe as an assistant and character, completed Main Quests and voluntary Daily
Briefs, received a Vex opinion, encountered Maison Vanta, faced a crisis or opportunity,
responded to the market, created a Story Archive history, and understood what to pursue next.

No objective requires likes, votes, purchases, advertisements, or another player's
cooperation. Existing players receive historical objective backfill. Progress cannot be
completed through local state manipulation. The first week must not contain a period longer
than two normal sessions without a new decision type, visible upgrade, automation step,
narrative consequence, or reachable objective. Continuity: v6 §§1.1, 3.7, and 3.9.

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
- **Competitive Rating:** current-season, mode-specific placement; never a lifetime wealth score.
- **Maison Standing:** current-season group performance across culture, commerce, operations,
  territory, collaboration, and reputation.

Every stat has one definition, one server owner, and one visible explanation when it
changes. Rank rewards grant options, tools, capacity, cosmetics, and strategic breadth;
they do not create uncapped or unbeatable permanent multipliers. Casual and Expert modes
never alter reward multipliers, idle rates, event rewards, score ceilings, crisis
severity, or competitive eligibility.

### 6.2 Progression tests

The free path can reach every gameplay role and the full Hype range. No rank reward or
purchase creates an unreachable competitive ceiling. Progression is meaningful through
new decisions, capacity, information, identity, and narrative consequence rather than
exponential inflation. Continuity: v6 §§3.1–3.9 and 8.9.7–8.9.8.


### 6.3 Path specialization, support actions, and regret protection

The primary path is a specialization, not a permanent content lock.

- Before Joint Venture, an Artisan may perform bounded commercial support actions such as selecting
  an audience, approving a price band, reviewing a partner's rollout, and operating the starter
  store through Luxe-guided defaults.
- Before Joint Venture, an Architect may perform bounded creative support actions such as choosing a
  brief, selecting among visible garment revisions, defining a collection story, and reviewing an
  Artisan partner's design rationale.
- Support actions expose the fantasy and vocabulary of the secondary path without granting its full
  mastery tree, throughput, ranked contribution ceiling, or advanced controls.
- The Founder Trial and free early reassignment are mandatory. After the free reassignment window,
  players may continue the primary path, collaborate with the secondary path, or progress toward
  Joint Venture; the game does not sell path correction as a premium rescue.
- Quest generation, matchmaking, and recommendations may use the current specialization but must
  not punish experimentation or require a path-exclusive purchase.

Path satisfaction is measured separately from path retention. A high rate of early reassignment,
abandonment after selection, or players reporting that they chose without understanding the fantasy
blocks further path-specific content expansion until onboarding is revised.

### 6.4 Unlock cadence and goal hierarchy

The progression plan uses three simultaneous horizons:

- **Immediate goal:** reachable within the current session, normally 2–8 minutes, such as
  adjusting price, completing a design, hiring an assistant, resolving a bottleneck, claiming
  an explained offline result, or finishing one Daily Brief step.
- **Session goal:** normally completed within 10–25 minutes, such as releasing a collection,
  improving one operation, completing a Daily Brief board, advancing a Main Quest, opening a
  campaign, or preparing for a trend.
- **Strategic goal:** normally completed across several days or weeks, such as entering a new
  city, completing a Weekly Commission, developing a Signature Direction, automating a
  department, defeating a rival plan, completing a Luxe chapter, reaching Joint Venture, or
  preparing for Ascension.

During the first 30 days, the player receives a meaningful unlock, decision type, authored
consequence, or visible empire upgrade at least once every two normal sessions. Currency-only
rewards do not satisfy this requirement. The intended cadence is:

| Window | Required progression beat |
|---|---|
| First session | First complete loop, first Main Quest milestone, first upgrade, and Operations Assistant preview |
| Day 1 | Daily Brief board, first Operations Assistant, and offline return receipt |
| Days 2–3 | First automation policy, rival response, and supply or audience specialization |
| Days 4–7 | Weekly Commission board, first department preview, crisis or collaboration, and Signature Direction |
| Week 2 | Second city or equivalent strategic expansion and first Department Manager |
| Weeks 3–4 | Multi-operation policy control, deeper staff specialization, and Gala or Maison objective |
| Rank 50 | Joint Venture unlock |
| Rank 100 | Aurelian Ascension eligibility |

Exact ranks, costs, and durations are server-configured and validated through playtests, but
this cadence is a product contract. A locked feature must show the requirement, expected
benefit, and nearest actionable step.

## 7. World, Fashion Cities, and Customer Segments

### 7.1 Global fashion-world principle

The Styliste is not limited to three fashion markets. The canonical world must be capable of
representing every city with a sustained, meaningful fashion ecosystem. Milan is a mandatory core
city and may not be treated as an optional cosmetic backdrop. Canonical inclusion does not mean that
every city ships at full simulation depth on day one; it means the world model, data contracts,
content pipeline, map, economy, narrative, and live-operations plan are built to admit qualified
cities without redesigning the game.

Kingston remains the proof-of-fun reference city and cultural home of the opening experience. Its
priority does not diminish Milan, Paris, London, New York, Tokyo, or later regional fashion centers.
No city is a reskin, an objectively superior endgame destination, or a stereotype about the people
who live there.

### 7.2 Fashion City Registry and qualification

A city may enter the canonical Fashion City Registry when research demonstrates a sustained fashion
ecosystem and the team can give it a distinct, respectful gameplay identity. Qualification considers:

- recurring fashion weeks, trade events, showrooms, markets, or recognized local fashion calendars;
- active designers, artisans, manufacturers, suppliers, retailers, buyers, stylists, media, schools,
  subcultures, or fashion institutions;
- a distinct relationship between creativity, commerce, production, culture, and public identity;
- enough reliable research and local consultation to avoid shallow imitation;
- meaningful city-specific choices for both Artisan and Architect players;
- a viable customer, district, supplier, property, narrative, event, and NPC configuration;
- localization, legal, cultural, moderation, and accessibility readiness.

Each registered city has exactly one maturity state:

| State | Meaning |
|---|---|
| **Reference City** | Complete proving ground used to validate new city systems |
| **Production City** | Fully playable economy, districts, NPCs, events, stories, and multiplayer rules |
| **World-Market City** | Appears through contracts, buyers, trends, Feed activity, Gala qualification, and travel opportunities before full simulation |
| **Content Prototype** | Internal data and scenarios used for validation but not promised as a complete player destination |
| **Canonical Backlog** | Confirmed future candidate awaiting research, capacity, or validation |

A city cannot be marketed as fully playable while it only has World-Market or prototype depth.

### 7.3 Foundational city roster

The initial canonical roster is organized by gameplay readiness rather than prestige hierarchy.

#### Opening reference

- **Kingston:** cultural pulse, originality, music and streetwear connections, credible storytelling,
  collaboration, community response, and high-value word-of-mouth.

#### Mandatory foundational global capitals

- **Milan:** craftsmanship, luxury production, industrial coordination, material and manufacturing
  networks, ready-to-wear commerce, buyers, showrooms, and disciplined execution.
- **Paris:** prestige, couture, critics, runway institutions, heritage, quality expectations, luxury,
  and collector demand, with strong consequences for weak execution or false exclusivity.
- **London:** experimentation, emerging talent, education, subculture, press attention, creative risk,
  and rapid shifts between underground credibility and global visibility.
- **New York:** commercial scale, media, celebrity styling, department-store and direct-to-consumer
  opportunity, speed, accessibility, brand building, and demanding operational economics.
- **Tokyo:** innovation, craftsmanship, precision, subculture, novelty, limited drops, collaboration,
  technology, and digital-fashion opportunity.

Milan must reach Production City status no later than the first launch city wave. Paris, London, New
York, and Tokyo must exist in the world model from the early production roadmap and progress toward
full city status through validation rather than being omitted because of launch scope.

#### Initial regional expansion registry

The initial non-exhaustive registry includes cities such as Seoul, Shanghai, Beijing, Hong Kong,
Mumbai, Delhi, Lagos, Accra, Johannesburg, Cape Town, São Paulo, Mexico City, Bogotá, Buenos Aires,
Copenhagen, Stockholm, Berlin, Antwerp, Florence, Rome, Madrid, Barcelona, Amsterdam, Istanbul,
Tbilisi, Dubai, Beirut, Dakar, Nairobi, Sydney, Melbourne, Los Angeles, Miami, Toronto, and Montreal.

Inclusion in this registry is not a claim that the cities are interchangeable or that these are the
only serious fashion centers. Research may add, merge, postpone, or reprioritize cities. Local
creators and consultants should influence city identity before production lock.

### 7.4 Canonical city gameplay contract

Every Production City must define:

- districts, property classes, leases, rents, operating costs, territory rules, and protected entry
  opportunities;
- customer-segment weights, price references, income distributions, needs, category demand, and
  loyalty behavior;
- local designers, suppliers, manufacturers, buyers, wholesalers, landlords, critics, media,
  institutions, stylists, celebrities, regulators, mentors, and rival Houses;
- materials, craftsmanship traditions, manufacturing strengths, logistics routes, lead times, and
  supply risks;
- fashion calendars, events, showrooms, market weeks, cultural moments, and monthly Gala pathways;
- trend channels, press behavior, collaboration structures, counterculture, and customer discovery;
- legal, labor, advertising, sustainability, import, retail, and reputational pressures;
- Artisan opportunities that change creative decisions and Architect opportunities that change
  commercial strategy;
- city-specific crises, narrative arcs, Maison objectives, territory contests, and Archive history;
- localization, cultural review, performance budget, content-maturity status, and live-operations
  ownership.

A city fails acceptance if its main difference is a background, color palette, name, or flat numerical
modifier. Players should be able to identify a city from the strategic decisions it produces.

### 7.5 City entry and expansion loop

Players do not unlock cities only by reaching an arbitrary rank. Entering a new Production City is a
multi-step market-entry project:

```text
research the city
  → choose an audience and positioning
  → establish supplier, buyer, or landlord relationships
  → create or source a city-entry capsule
  → choose a store, wholesale, pop-up, digital, or partnership route
  → commit inventory and operating capital
  → receive local customer, critic, rival, and institutional response
  → adapt, retreat, specialize, or expand
```

Artisans establish relevance through design intent, local audience understanding, collaboration, and
creative adaptation. Architects establish viability through property, contracts, supply, pricing,
logistics, staffing, and risk management. A successful entry requires both cultural and commercial
credibility; copying the same optimal collection and store plan into every city must underperform.

Players may choose different expansion routes. The world is not a single linear ladder from a
"weaker" city to a "better" one. Cross-city operations introduce currency, logistics, timing,
inventory, identity, and reputation tradeoffs without making any real population a caricature.

### 7.6 Customer segments

- **Trendseekers:** relevance, novelty, social proof, and timing.
- **Collectors:** quality, rarity, story, craftsmanship, and prestige.
- **Everyday Stylists:** price-value fit, wearability, trust, availability, and loyalty.

Every city supports every segment. City strengths and risks are data-driven; no city is objectively
superior. Segment weights, reference prices, economic conditions, trend affinities, property markets,
and supply networks are server configuration, not client constants.

City identity is researched fictional worldbuilding, not a stereotype about real-world wealth,
taste, ethnicity, class, or behavior. Continuity: v6 World Map, §§5.3, 8.1, and 8.9.11.

### 7.7 City uniqueness and promotion gates

A city advances from World-Market City to Production City only when it passes a documented
**City Difference Test**. The test must answer, with playable evidence:

1. What design decisions become more valuable, risky, or culturally legible here?
2. What commercial pressures, property conditions, supply structures, or customer behaviors are
   meaningfully different here?
3. Which relationships and institutions matter here that do not matter in the same way elsewhere?
4. What can an Artisan pursue here that cannot be reproduced by changing a flat modifier?
5. What can an Architect build, negotiate, rescue, or control here that requires a different plan?
6. What city-specific failure, recovery, event, or narrative could only credibly happen here?

Each candidate city is tested with at least three contrasting House strategies. Copying the strongest
Kingston or Milan plan unchanged into the candidate city must produce a legible disadvantage or
missed opportunity; the game may not force failure merely to prove difference. Target players should
identify the city from its decisions and consequences without relying on skyline art, flags, names,
or color treatment.

A city promotion package requires a strategy matrix, local research record, cultural review,
production budget, live-content owner, low-device performance plan, and comparison against every
existing Production City. If the new destination cannot add a distinct Artisan and Architect loop,
it remains a World-Market City until the design improves. Production capacity permits only one major
city promotion wave at a time unless the previous city's retention, economy, content cadence, and
quality targets remain stable.

### 7.8 Customer population model

The three customer segments are populations, not three universal personalities. Each simulated
customer archetype combines:

- segment and city;
- disposable budget and price sensitivity;
- silhouette, palette, material, construction, and style affinities;
- wearability, novelty, prestige, sustainability, and exclusivity priorities;
- trend sensitivity and resistance;
- social influence and likelihood to like, comment, review, recommend, or remain silent;
- brand awareness, loyalty, trust, purchase history, and remembered service outcomes;
- size, accessibility, and availability requirements represented without body shaming;
- current need state, purchase frequency, and category interest.

The server resolves demand in aggregate and may instantiate representative customers for receipts,
reviews, Feed reactions, loyalty stories, and service events. It does not run one generative-model
call per customer or per sale. Named recurring customers preserve bounded memory and may become
loyalists, collectors, critics, defectors, ambassadors, or recovery stories based on actual events.
Their reactions must remain consistent with their declared preferences and the player's history.


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

### 8.2 Atelier interaction and skill expression

The Atelier is a constrained garment-construction workspace, not a menu that asks the player to
select a silhouette and press release. Verlet cloth is the tactile visual center, but every gesture
must alter inspectable authored design state and remain usable through a simplified low-device and
accessibility fallback.

A complete garment category defines editable **construction zones** such as bodice, sleeve, collar,
waist, hem, panel, pocket, trim, closure, and surface-treatment regions. Depending on the category,
the player may:

- drag bounded proportion handles to change length, width, taper, volume, shoulder line, waist,
  sleeve profile, hem shape, and controlled asymmetry;
- adjust drape, structure, stiffness, gathering, layering, and silhouette tension within material and
  construction limits;
- add, remove, resize, or reposition approved panels, seams, pockets, collars, cuffs, closures,
  trims, and surface details;
- assign materials and colorways by garment zone rather than only to the whole garment;
- position, scale, rotate, mirror, crop, and repeat approved patterns or graphics on declared zones;
- build bounded layer relationships and resolve visible conflicts such as clipping, impossible
  closures, unsupported weight, or inaccessible construction;
- compare the current revision with prior versions, undo safely, save a draft, and branch a revision
  without destroying the released original;
- respond to customer or critic feedback by opening the exact affected zone and revising one
  material factor rather than rebuilding the entire piece.

The system deliberately avoids unrestricted professional 3D modelling. Category-specific constraints,
snapping, construction rules, previews, and Luxe guidance keep the interaction understandable on a
phone while preserving visible authorship. Casual Mode may offer coherent starting shapes and smart
constraints; Expert Mode may expose finer controls. Both modes produce the same score ceiling and
server-owned design state.

Before commit, the Atelier shows the objective, visible garment state, changed zones, cost and
production consequences, audience projection range, construction warnings, and resources at risk.
Projection uncertainty remains; the UI does not reveal a single optimal recipe.

### 8.2.1 Design Signature and visual authorship

The server stores a versioned **Design Blueprint** containing all player-authored geometry parameters,
zone assignments, materials, palette relationships, construction details, pattern transforms,
accessibility alternatives, and revision lineage. Hype and NPC interpretation use this blueprint and
the rendered validity checks; the client cannot submit a score or an unvalidated visual state.

Repeated choices may form a visible **Design Signature** such as disciplined tailoring, sculptural
volume, modular utility, restrained palettes, expressive pattern placement, or material contrast.
The Signature is descriptive evidence from the player's history, not a permanent score bonus or a
label the player is forced to maintain.

A garment-creation implementation fails acceptance if players given the same brief and resources
produce materially identical results, if visible changes do not alter stored design state, if a
statistically strong but visibly broken garment can pass validation, or if players cannot identify
which authored decision distinguishes their garment from another player's work.

### 8.2.2 Revision loop

Every released design preserves its immutable original version. When a result exposes a weakness,
the player may create a revision that targets proportion, material, construction, palette, audience,
price, quantity, or presentation. The comparison view shows the changed factors, expected tradeoffs,
new production requirements, and which prior reactions remain relevant. Revision consumes normal
resources and time but is never locked behind premium currency.

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
cosmetics, purchases, advertisements, and House Pass entitlements never add points.
Talent can reveal projections, reduce uncertainty, unlock an alternative tradeoff, or
provide a free-progression-equivalent archetype.

Every result returns a structured explanation: what happened, why it happened, what
changed, who reacted, and what the player can do next. The client displays the
server-provided breakdown. Continuity: v6 §§4.1–4.2, 8.9.3–8.9.5, 8.10, and 8.11.

### 8.4 Fashion-taste evaluation and NPC interpretation

The simulation separates **authoritative design evaluation**, **NPC taste interpretation**, and
**generated presentation**.

**Layer 1 — Authoritative design state**

The server stores and evaluates the garment's structured design grammar: silhouette, proportion,
palette relationships, material, construction, finish, originality, audience fit, production
quality, price tier, responsibility posture, trend context, and brand-history context. This layer
owns Hype and all economic inputs.

**Layer 2 — NPC taste model**

Each relevant NPC or audience archetype applies published or inspectable preference weights to the
frozen design state. A traditional luxury editor may value construction, material, restraint, and
heritage coherence. A Kingston trendsetter may value originality, cultural timing, styling, and
credible story. An Everyday Stylist may value wearability, price-value fit, availability, and trust.
The same garment can therefore receive admiration, indifference, or criticism without contradiction.

An initial bounded interpretation may use:

```text
NPC_Design_Affinity = clamp(
    Weighted_Style_Fit
  + Quality_And_Execution
  + Brand_And_Relationship_Context
  + Price_And_Accessibility_Fit
  + Trend_And_City_Context
  + Seeded_Bounded_Variance,
  0,
  100
)
```

`Seeded_Bounded_Variance` may create human variation but cannot reverse a clearly incompatible or
compatible result by itself. The seed, rule version, design version, and material NPC inputs are
stored for reproducibility.

**Layer 3 — Presentation**

A template system or optional AI service converts the structured interpretation into a like,
reaction, review, negotiation line, Feed comment, critic paragraph, or spoken debrief. Generated text
must cite at least one actual evaluated factor, may express uncertainty, and cannot invent a material,
sale, scandal, relationship, or historical event that is absent from server state.

NPC reactions may create bounded secondary consequences such as awareness, loyalty, Brand Heat,
segment sentiment, or an opportunity card. They do not recursively feed unlimited likes back into
Hype, and raw NPC reaction volume is never a competitive score. The player can inspect representative
reasons behind positive and negative sentiment.

For player-imported images, textures, or presentation assets, AI vision may support moderation,
tag suggestions, search, and optional descriptive assistance. It does not authoritatively judge the
garment's Hype, Gala score, sales, or originality.

## 9. Mogul Systems

### 9.1 Commercial core

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

### 9.2 Artisan–Architect Collection Contracts

An Artisan and Architect may form a server-authoritative Collection Contract that converts
creative work into a shared commercial operation. The contract declares:

- design ownership and permitted use;
- production budget and funding responsibility;
- production quantity, quality target, supplier posture, and delivery window;
- target cities, stores, customer segments, pricing authority, and campaign responsibility;
- revenue share, loss allocation, cancellation conditions, and contract duration;
- Maison exclusivity, if any, and the rights retained when either player leaves a Maison.

Both players preview and confirm identical terms before activation. Material changes require both
parties to approve a new version. Revenue and costs settle automatically through the authoritative
ledger; neither party can withhold earned proceeds, change the split retroactively, seize the
other player's design, or cancel after settlement to escape a loss. Templates make common
agreements understandable, while Expert Mode may expose additional bounded terms.

Contracts create separate Artisan and Architect contribution records. The Artisan receives
creative and authorship credit; the Architect receives commercial and operational credit; both
may contribute to Maison objectives and leaderboards without duplicating the underlying revenue.

### 9.3 Store asset market

Eligible stores may be bought, sold, leased, franchised, renovated, or transferred to a Maison
through an official market. A store's server-generated valuation considers location, format,
lease state, revenue history, margin, customer loyalty, upgrades, capacity, operating cost,
reputation, local competition, and territory context.

Required market protections are:

- listings use House Funds only; Luxe Credits and real-money player transfers are prohibited;
- every listing settles through escrow and an append-only ownership history;
- listing prices remain inside a server-configured valuation band unless the asset enters an
  authored auction or distressed-sale flow;
- direct gifts, one-unit sham sales, circular trades, and suspicious linked-account transfers are
  rejected or held for review;
- listing, purchase, relisting, and rapid-flip cooldowns limit manipulation;
- buyers see valuation drivers, liabilities, lease duration, recent performance, active contracts,
  territory exposure, and transaction fees before committing;
- personal starter stores and progression-critical stores are protected from accidental sale;
- Maison purchases above a configured treasury threshold require two authorized approvals;
- leaving or being removed from a Maison never transfers a player's personal store without an
  explicit, previously approved sale contract.

Leasing and franchising provide lower-cost entry for developing Architects. A lease grants bounded
operating rights without ownership. A franchise contract defines brand standards, inventory,
fees, revenue share, duration, and termination conditions. No market transaction may create an
unreachable competitive ceiling for players who choose not to trade.

### 9.4 Architect multiplayer strategy

Architects are the multiplayer coordination backbone. Their shared and competitive systems include:

- **Wholesale contracts:** sell collections through department stores, independent boutiques,
  Maison networks, and other player stores under declared volume, price, quality, and deadline terms.
- **Production contracts:** manufacture another player's collection for a fee using declared
  capacity, quality, risk, and delivery commitments.
- **Trade routes:** connect facilities, warehouses, stores, cities, and Maison members through
  choices among speed, cost, resilience, sustainability, and exposure to disruption.
- **Franchise networks:** license a brand to eligible operators while preserving clear ownership,
  standards, fees, and exit rights.
- **Market bidding:** compete for time-limited leases, supplier capacity, event retail space,
  distribution rights, and pop-up locations using House Funds in bounded server-run auctions.
- **Corporate projects:** coordinate a flagship store, city entry, production hub, Fashion Week,
  heritage-brand rescue, sustainability initiative, or global collection across multiple members.
- **Commercial crises:** respond to supplier collapse, recalls, counterfeit activity, lease
  disputes, demand shocks, logistics disruption, inventory failures, and competitor price pressure.

Every system has at least two viable strategic responses and exposes its risks before commitment.
Premium purchases cannot improve bids, contract outcomes, route efficiency, territory settlement,
or commercial leaderboard scores.

### 9.5 Negotiable NPC commercial ecosystem

Architect gameplay uses relationship-bearing NPC institutions rather than static shop menus.
Commercial NPCs expose their interests, capacity, risk, and current position before the player
commits.

- **Suppliers and manufacturers** have specialties, capacity, quality variance, ethics, resilience,
  lead time, geographic exposure, financial health, negotiation style, and relationship history.
  They may offer volume discounts, credit, exclusive materials, emergency capacity, sustainable
  alternatives, or risky low-cost terms. Strikes, shortages, defects, insolvency, and logistics
  disruption emerge from authored or simulated states rather than arbitrary punishment.
- **Retail buyers and wholesalers** represent department stores, boutiques, marketplaces, regional
  distributors, and Maison networks. They evaluate audience fit, sell-through, reliability,
  production capacity, quality, pricing, identity, and reputation. Contracts may contain volume,
  margin, exclusivity, customization, delivery, return, and regional-rights terms.
- **Investors and lenders** offer loans, revenue share, equity, milestone capital, or rescue finance
  based on risk, performance, reputation, governance, and strategic fit. Capital creates obligations,
  board influence, repayment, dilution, deadlines, or ethical restrictions rather than free money.
- **Landlords and property agents** negotiate leases, renewals, fit-out terms, rent, district access,
  and distressed opportunities. No NPC landlord may remove a progression-critical store without a
  forecast, grace period, and viable recovery action.
- **Brokers and agents** introduce suppliers, buyers, collaborators, stores, investors, and special
  opportunities. They reduce search friction or expand the option set but cannot guarantee outcomes
  or sell hidden competitive certainty.

Negotiation uses bounded choices, declared stakes, and server-owned settlement. Optional generated
dialogue may give the negotiation personality, but acceptance thresholds and resulting terms come
from structured rules. Every consequential offer includes a plain-language contract summary and a
comparison with at least one viable alternative or the option to walk away.

### 9.6 Empire direction and active visual play

Architect gameplay follows a repeatable **diagnose → intervene → observe → adapt** loop. Financial
clarity is necessary, but a spreadsheet or static dashboard cannot be the entire interaction.
Every major commercial system must have a visual operating surface that reveals cause and lets the
player act on it.

Required representations include:

- stores with visible customer flow, queue pressure, conversion, stock availability, display focus,
  service strain, and closing-state summaries;
- a city demand map showing segment interest, price sensitivity, local awareness, competitor
  pressure, and territory context without presenting one automatic answer;
- warehouses and trade routes that visibly show inventory movement, delay, unused capacity,
  bottlenecks, route risk, and rerouting choices;
- store floor and display planning through bounded placement or priority zones that affect discovery,
  service, category mix, and operational cost;
- negotiation scenes in which character goals, leverage, alternatives, and relationship history are
  visible alongside the contract terms;
- renovations and recovery projects that visibly transform a distressed location across stages;
- time-bounded operating incidents such as sellouts, delivery failures, demand surges, staff absence,
  or competitor openings that offer two or more viable responses and remain asynchronous enough for
  mobile play.

The player may pause, accelerate presentation, or delegate routine execution after earning
appropriate automation. Repetitive tapping, keeping the screen open, or manually repeating an
already solved action never creates uncapped advantage.

A normal 5–10 minute Architect session must support at least one complete diagnosis and intervention.
Examples include reallocating stock after reading a heat map, renegotiating a supplier after a
capacity warning, rescuing an underperforming store, adjusting a display and price posture, or
rerouting a delayed launch. The result should produce visible change before or during the next
settlement rather than only a larger number in the Ledger.

An Architect surface fails acceptance if players cannot identify the dominant problem from the
presented evidence, if the optimal action is always the same, if the visual layer merely decorates a
spreadsheet, or if the only satisfying moment is claiming currency.

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

### 10.3 Economy pacing and tuning contract

The economy must create frequent agency without allowing runaway compounding. Server
configuration owns costs, rates, caps, and event modifiers. Tuning begins from the following
target bands and may change only with documented telemetry or playtest evidence:

| Measure | Early game | Mid game | Late game |
|---|---:|---:|---:|
| Time to first meaningful purchase | 3–8 minutes | — | — |
| Typical time between meaningful purchases | 5–15 minutes | 15–45 minutes | 1–4 normal sessions |
| Standard capacity-upgrade payback | 15–35 active minutes | 1–3 days of mixed play | 3–10 days of mixed play |
| Idle share of efficient total income | 45–65% | 50–70% | 55–75% |
| Active-strategy advantage over unattended defaults | 20–50% | 20–45% | 15–40% |
| Healthy stockout rate | 5–20% | 5–15% | 3–12% |
| Healthy overstock exposure | 5–20% of inventory value | 5–15% | 3–12% |

A meaningful purchase changes capacity, information, choice, presentation, risk, or access.
Tiny percentage upgrades may exist as supporting sinks but cannot dominate the upgrade map.
The player should normally see at least two viable uses for a scarce resource: expansion
versus efficiency, quality versus reach, safety versus upside, or automation versus direct
control.

Income growth uses controlled curves, bounded modifiers, and diminishing returns rather than
unrestricted multiplier stacking. No single staff member, campaign, city, product, trend,
paid entitlement, or prestige reward may become the universal best answer. Every major
economic modifier declares its source, duration, stacking category, cap, and counterplay.

Economy health is reviewed by cohort and progression band using median currency balance,
source-to-sink ratio, purchase latency, upgrade payback, stockout, overstock, bankruptcy or
soft-lock rate, idle-versus-active earnings, and Gini-style concentration of market control.
If players cannot afford a valid action after a normal session, the game provides a recoverable
operating choice rather than forcing payment or passive waiting.

### 10.4 Bottlenecks and recoverability

Every operation may be limited by at least one legible bottleneck: demand, inventory, production
capacity, material supply, staffing, store capacity, logistics, cash flow, reputation, or
information. The HQ and Ledger identify the current primary bottleneck and show at least two
responses when available.

A poor decision may reduce efficiency or delay expansion, but the main empire cannot enter an
irrecoverable failure state. Recovery options may include a smaller production run, stock
transfer, price adjustment, basic contract, delayed campaign, temporary credit line with an
explicit cost, asset downgrade, or authored Luxe assistance. Recovery never erases narrative
consequences and never requires premium currency.

## 11. Social Feed and Multiplayer

### 11.1 Global Feed

The Global Feed is a gameplay surface. Cards may create trend opportunities, customer
reactions, Vex reviews, Luxe responses, rival moves, partnership offers, supplier
competition, crisis developments, plagiarism disputes, Maison objectives, Gala
invitations, territory contests, store listings, and market shifts.

Every actionable card answers: “What can the player do because this happened?” NPC brands,
customers, critics, buyers, staff, influencers, suppliers, journalists, and institutions keep the
world lively without requiring a large live population. NPC accounts are clearly marked and never
impersonate human players. Their likes, comments, reviews, and reactions are generated from frozen
structured causes and cannot be purchased, botted, or directly counted as ranked power.

A healthy Feed uses varied behavior: many customers view silently; some react; fewer comment; still
fewer purchase, recommend, complain, or become recurring named followers. Comment generation uses
persona, taste, relationship, and event context; it avoids generic praise, repetition, fabricated
facts, player-directed insults, body judgment, and engagement bait. The Feed may summarize large
population sentiment while exposing a small number of representative reactions and their causes.

Expired opportunities cannot be accepted; duplicate actions are idempotent; blocked users cannot
interact through alternate surfaces; player content cannot alter authoritative calculations. NPC
engagement creates only bounded awareness and sentiment effects and cannot produce a self-reinforcing
Hype loop.

Public profiles, Feed posts, Gala entries, and leaderboard data use controlled public
access. External sharing may support discovery, but external likes, screenshots, QR
scans, or social-platform engagement never directly grant Hype, ranked power, rare
materials, territory strength, or economic advantage. Verified referrals can grant
cosmetics after a retained-user milestone.

### 11.2 Player-created Maisons

A Maison is a persistent player-created fashion empire with a launch cap of **10 members**.
Each Maison has a name, emblem, identity statement, headquarters, Story Archive, member roster,
role permissions, recruitment policy, contribution ledger, seasonal record, territory holdings,
shared projects, and internal communication.

A Maison may be open, application-only, invite-only, or closed. Players may create a Maison,
invite eligible players, review applications, request to join a Maison with capacity, withdraw an
application, accept an invitation, leave voluntarily, or be removed under transparent rules.
Search and recommendations may use path, preferred role, language, region, activity window, and
competitive intent, but never spending history.

Suggested roles are Founder, Creative Director, Commercial Director, Production Director,
Logistics Director, Marketing Director, Treasurer, Officer, and Member. Roles grant only declared
administrative permissions. A Maison does not need every role filled, and no role grants a hidden
simulation multiplier.

One account designates one Ranked House and one Ranked Maison per competitive season. Additional
House slots may join social spaces or run unranked collaborations, but they cannot multiply ranked
contributions, territory claims, Gala entries, or seasonal rewards.

### 11.3 Maison governance and member protection

Maison leadership must not be able to confiscate personal progress or erase earned rewards.
Required governance rules are:

- personal currency, designs, stores, staff, and Archive history remain personal unless a specific
  server contract transfers a defined asset;
- all shared contributions show their destination, use, approval state, and permanent ledger entry;
- treasury withdrawals and large purchases use role permissions and two-person approval above a
  server-configured threshold;
- leaders cannot distribute ranked rewards manually; eligible rewards settle automatically;
- contribution requirements, inactivity policy, recruitment policy, and role permissions are
  visible before joining;
- a member cannot be kicked during a locked competitive settlement window; removal queued during
  the lock takes effect afterward;
- members who qualified before a roster lock retain their earned event reward even if they leave
  after lock or leadership changes;
- a recently joined member has restricted treasury and asset permissions until a probation period
  ends;
- an inactive or deleted founder enters a documented succession process rather than permanently
  trapping the Maison;
- repeated kick-and-reinvite behavior, reward denial attempts, coercive contribution rules, and
  treasury abuse are auditable and enforceable moderation violations.

Maisons may use nonbinding polls or binding votes for doctrine selection, large treasury projects,
headquarters direction, territory priorities, and leadership succession. The interface clearly
states whether a vote is advisory or authoritative.

### 11.4 Maison headquarters and shared projects

Members build a shared headquarters through bounded contributions of House Funds, materials,
completed contracts, designs, operational achievements, quests, territory activity, Gala results,
and reputation milestones. Headquarters progression unlocks social and strategic breadth such as
showrooms, project slots, role tools, Archive exhibits, internal analytics, event staging, and
additional collaboration capacity. It does not increase Hype ceilings, Gala scores, or uncapped
income multipliers.

A Maison selects one major Corporate Project at a time. Projects require both creative and
commercial work and may include a flagship opening, city entry, production hub, Fashion Week,
shared collection, community initiative, heritage-house recovery, or sustainability programme.
Each project exposes phases, contribution limits, responsibilities, deadline, risks, and individual
credit. Raw member count cannot finish a project instantly; contribution caps and phase gates keep
small active Maisons viable.

### 11.5 Partnerships and collaboration

Artisans and Architects may partner within or outside a Maison through Collection Contracts defined
in §9.2. Multi-member Maison collections use the same contract principles: ownership, funding,
responsibility, revenue, risk, and exit rights are explicit before work begins.

A collection may contain work from several Artisans and commercial execution from several
Architects, but contribution scoring is capped and normalized. At launch, no more than six members'
scored contributions count toward one ranked Maison collection or Gala entry. Other members may
serve as substitutes, advisors, voters, logistics support, or contributors to a separate project.
This prevents a full 10-person roster from receiving a simple numerical advantage over a smaller
Maison.

### 11.6 Cooperative social life and belonging

Maisons need reasons to matter between competitive events. The following activities are
noncompetitive, optional, and designed to build relationships without creating mandatory labor:

- opt-in draft review in which members may annotate declared garment zones or answer structured
  questions; the creator controls visibility and may ignore feedback;
- shared mood boards, collection references, planning canvases, internal lookbooks, and Archive
  exhibitions;
- bounded gifts of ordinary, nonpremium materials from a daily social allowance; no rare, ranked,
  paid, or progression-critical asset may be transferred through gifting;
- assistance requests for production, research, translation, styling, or store preparation with
  contribution caps, automatic credit, and no leader-controlled reward seizure;
- Maison polls, doctrine discussions, celebration posts, personal milestones, anniversaries,
  retrospectives, and member spotlights;
- mentorship and practice scenarios that reward explanation, completion, and newcomer independence
  rather than permanent dependency;
- unranked internal runways, design prompts, recovery workshops, and collaborative lookbooks with no
  entry fee or competitive-power reward.

Social participation cannot be required for Main Quest completion, baseline progression, core
materials, idle efficiency, or competitive eligibility. Leaders cannot impose automated penalties
for missing voluntary activities. Social rewards emphasize ordinary materials, Archive recognition,
bounded Aurelian Seals, and presentation items; they cannot be converted into an uncapped Maison
score or economy multiplier.

The product measures belonging through voluntary return, repeat collaboration, helpful feedback,
member tenure, and safety outcomes rather than message volume. Spam, performative check-ins, forced
donations, and coercive contribution quotas are not considered healthy engagement.

### 11.7 Communication and player safety

The supported launch communication model is private but bounded:

1. Maison announcements and project comments;
2. Maison group chat;
3. recruitment and application messages;
4. contract-negotiation threads;
5. direct messages between mutual friends, Maison members, or active contract parties.

Unsolicited global DMs are not supported. Every communication surface provides block, mute, report,
report-message, leave-conversation, and privacy controls. Blocking applies across DMs, recruitment,
Feed interaction, contract invitations, and Maison invitations.

Safety requirements include profanity and harmful-content filtering, spam and rate limits, link and
contact-information restrictions, duplicate-message detection, age-appropriate privacy defaults,
moderation retention, appealable enforcement, device and account anti-abuse signals, and a staff
review console. A reported user cannot evade a block through another House slot. Competitive
rewards never depend on sending messages, recruiting strangers, or participating in public chat.

### 11.8 Competitive seasons, leagues, and leaderboards

Competitive multiplayer runs in server-authoritative **eight-week seasons**. Trophies, Archive
history, earned cosmetics, and Hall records remain permanent; seasonal ratings, territory control,
and most competitive placement reset or compress so the next season remains contestable.

There is no primary leaderboard based on lifetime wealth or lifetime revenue. Required individual
House and Maison boards include:

- Overall Seasonal Standing;
- Cultural Influence;
- Commercial Performance;
- Operational Excellence;
- Territorial Influence;
- Gala Prestige;
- Founder Reputation;
- Rising House and Rising Maison;
- city-specific standings.

The normalized Maison score is initially structured as:

```text
Maison_Season_Score =
    0.25 × Cultural_Influence
  + 0.25 × Commercial_Performance
  + 0.15 × Operational_Excellence
  + 0.15 × Territorial_Influence
  + 0.10 × Collaboration_Execution
  + 0.10 × Reputation_And_Integrity
```

Every component is normalized to 0–100 inside the relevant league and season. Revenue, followers,
territory count, and roster size are inputs only through bounded submetrics; they are never direct
uncapped score totals. Duplicate economic activity is counted once. Spending, premium ownership,
and paid utility products contribute zero points.

Players and Maisons are placed into Rising, Bronze, Silver, Gold, and Sovereign competitive
divisions using current-season qualification, prior placement, account integrity, and active-roster
strength. Rising divisions protect first-season competitors and verified rebuilding Maisons.
Promotion and demotion use disclosed thresholds and a limited placement series rather than one
surprise result.

### 11.9 Anti-snowballing and newcomer mobility

The multiplayer economy must prevent success from compounding into permanent exclusion. Launch
protections include:

- **Newcomer protection:** a new House receives a protected onboarding district, trade safeguards,
  and exclusion from hostile territory loss during its initial protected progression window. The
  player may opt into full competition early after a clear warning.
- **Rising competition:** first-season Houses and Maisons receive their own ranked boards, Gala
  division, placement rewards, and promotion route; suspected alternate accounts are excluded.
- **Seasonal compression:** rating and territory partially reset every season while trophies and
  history remain.
- **Bounded territory value:** total direct economic benefit from territory is capped, local, and
  excluded from Gala scoring. No territory benefit may exceed approximately 5% in one economic
  category without a specific balance review.
- **Diminishing control:** upkeep, contest exposure, and influence decay rise after the second
  controlled district. The initial hard cap is four concurrently controlled districts per Maison,
  adjustable by active population and telemetry.
- **Roster normalization:** only a fixed number of best eligible contributions count in each ranked
  project; inactive or larger rosters do not multiply score automatically.
- **Catch-up contracts:** trailing players receive optional, skill-based recovery contracts,
  distressed leases, mentorship objectives, and underserved-market opportunities—not hidden result
  bonuses or free victories.
- **Protected essentials:** starter stores, core suppliers, required story access, and basic market
  participation cannot be monopolized by older players.
- **No winner-only power:** seasonal and Gala rewards emphasize status, premium presentation,
  bounded currency, and Archive prestige; they do not grant permanent sales, Hype, territory, bid,
  or scoring multipliers.
- **Concentration review:** economy and live-operations teams monitor wealth concentration,
  territory concentration, repeated top-three occupancy, new-player loss rate, and cross-cohort
  resentment signals. Corrective action prioritizes caps, access, matchmaking, and new strategic
  counters rather than arbitrary hidden rubber-banding.

Mentorship permits experienced players to help new members through declared onboarding milestones.
Mentor rewards are bounded, cannot be farmed repeatedly from linked accounts, and never require the
new player to spend, surrender assets, or remain in a Maison.

### 11.10 District territory control

Territory represents influence over **city districts**, not permanent ownership of whole cities.
Every city contains districts with different customer mixes, store opportunities, costs, trends,
and cultural identities. All players retain access to core city gameplay regardless of control.

A weekly territory cycle uses six phases:

1. **Forecast:** eligible districts, rules, current controller, upkeep, and scoring categories are
   published.
2. **Declaration:** a Maison selects a bounded number of districts to defend or contest.
3. **Preparation:** members assign stores, collections, inventory, routes, campaigns, and community
   projects.
4. **Response:** competing Maisons may adjust strategy within declared limits.
5. **Settlement:** the server scores cultural fit, commercial execution, customer loyalty,
   operational reliability, local reputation, and bounded strategic objectives.
6. **Control:** the winner receives temporary influence, visible branding, and declared local
   benefits until the next settlement or until influence decays below the control threshold.

Control is never lost through an unannounced overnight attack. Contest windows, lock times,
settlement inputs, and likely consequences are visible. A home district remains protected from full
removal, and starter districts cannot be contested. Neglected territory decays. Large holdings cost
more to maintain and expose the Maison to more simultaneous counterplay.

Territory benefits may include small local logistics savings, earlier local trend information,
special nonexclusive contracts, district presentation, and access to local event variants. Control
cannot block another player from opening a basic store, completing a Main Quest, obtaining a core
material, entering the Gala, or accessing a required city.

### 11.11 Maison Wars and rivalry formats

Maison Wars are scheduled, opt-in competitive campaigns rather than unrestricted attacks. Supported
formats include Market War, Cultural War, Supply Race, Expansion Race, Fashion Week, Recovery
Challenge, and Corporate Project Race. Each publishes its rules, eligible roster, resource budget,
scoring dimensions, lock time, counterplay, reward range, and settlement receipt before entry.

Most formats require both Artisan and Architect contributions, but path-specialist Maisons remain
viable through alternative objectives. A balanced Maison receives strategic breadth, not a hidden
score multiplier. Matchmaking uses division, current-season performance, active eligible roster,
and recent opponent history. Repeated mismatches trigger a review and rematch protection.

## 12. Narrative, Luxe, Vex, Rivalry, and the Living Fashion World

### 12.1 Luxe: assistant, mascot, and The First Cut

Luxe is the player's persistent in-world assistant, mascot, strategic guide, and relationship—not
merely a reward presenter. Luxe also owns the canonical FTUE behavior defined in §5.1, including guidance
modes, Ask Luxe, tutorial-memory state, safe failure, path comparison, and the first-return debrief. Luxe introduces systems, delivers Main Quests, Daily Briefs, Weekly
Commissions, automation explanations, House While Away reports, bottleneck warnings, and
recommended next actions. Luxe may advise, summarize, celebrate, challenge, or question the
player, but never silently chooses an irreversible action or alters an authoritative result.

Luxe Trust changes primarily through meaningful decisions, not quest completion volume. Season
One chapters are:

1. The House Opens — identity and ambition.
2. The First Risk — creative or financial tradeoff.
3. Vanta’s Shadow — first rival intervention.
4. The Cost of Hype — accessibility, ethics, or profit conflict.
5. The Receipts — crisis truth and accountability.
6. Crown or Community — prestige versus loyalty.
7. The House Remembers — consequence and future direction.

Luxe remembers positioning, ethics, pricing, collaborator treatment, repeated aesthetic
direction, rival interactions, quest choices, and whether the player chooses prestige,
accessibility, control, or community. Luxe's tone and recommendations may respond to this
history, but quest requirements, reset rules, and reward value remain fair across relationship
states. Dialogue and Archive entries only reference events that occurred.

### 12.2 Luxe Quest System

The Luxe Quest System gives every player a clear reason to act now, return later, and pursue a
larger ambition. Quests must teach or exercise real systems, create useful decisions, and connect
to the player's current empire. They are not isolated chores layered on top of gameplay.

#### 12.2.1 Quest lanes

**Main Quests — House Path**

- Main Quests are authored, persistent progression objectives delivered by Luxe.
- They introduce systems, advance narrative chapters, unlock features, and mark major empire
  milestones. They do not expire.
- The player normally has one primary Main Quest and may have one optional branch representing a
  creative, commercial, ethical, or relationship choice.
- A Main Quest cannot require a random drop, another player's cooperation, a purchase, an
  advertisement, external sharing, or success in ranked competition.
- Existing players receive retroactive credit or an equivalent replacement objective when a new
  Main Quest targets progress they have already completed.

**Daily Briefs**

- Luxe presents three Daily Briefs based on the player's unlocked systems, current bottleneck,
  recent behavior, available time horizon, and path identity.
- A healthy board contains one quick objective, one core-loop objective, and one choice-oriented
  or optimization objective. All three should normally be completable within 10–25 minutes of
  intentional play or through one natural idle cycle plus a brief return decision.
- One Daily Brief may be rerolled free each day. A replacement must remain achievable and may not
  offer a lower reward tier.
- Daily Briefs may include designing for a declared segment, resolving a stockout, adjusting an
  automation policy, transferring inventory, using a different supplier posture, completing a
  sale target, reviewing the Ledger, or responding to an eligible Feed opportunity.
- They may not require repetitive tapping, leaving the application open, exact real-time login,
  spending premium currency, viewing an advertisement, external engagement, harassment, or an
  action unavailable to the account.

**Weekly Commissions**

- Luxe offers four Weekly Commissions. Completing any three earns the weekly capstone; the fourth
  is an optional bonus objective and is not required for the best guaranteed weekly reward.
- Weekly objectives require several meaningful actions across normal sessions and should total
  approximately 60–120 minutes of intentional play over seven days, with idle progress counting
  where the underlying system naturally supports it.
- The board must include at least two different gameplay systems and cannot require seven
  consecutive daily logins.
- Typical commissions include completing and selling a themed mini-collection, improving an
  operation's waste or margin, serving two customer segments, preparing for and responding to a
  trend, completing a Luxe chapter beat, or resolving several automation exceptions.
- Competitive participation may appear as an optional alternative, but winning, ranking highly,
  receiving votes, or depending on another player is never mandatory.

#### 12.2.2 Reward structure and premium-currency generosity

Quest rewards use a visible mix of House Funds, Brand Rank progress, Path Mastery, materials,
production capacity items, Aurelian Seals, cosmetics, and Luxe Credits. The majority of repeatable
quest value remains earned gameplay resources; premium currency is a satisfying bounded bonus.

Initial launch tuning targets, all server-configurable and subject to economy validation, are:

| Source | Initial Luxe Credit target | Frequency and cap |
|---|---:|---|
| Complete all three Daily Briefs | 1 on standard days; 2 on up to two highlighted days | Maximum 9 per account week |
| Complete the Weekly Commission capstone | 10–14 | Once per account week |
| Optional fourth Weekly Commission | 2–4 or equivalent collectible value | Once per account week |
| Major Main Quest or chapter milestone | 5–25 | One-time, milestone dependent |
| Authored event quest | 0–8 | Event dependent; never required for core progression |

The repeatable free earn distribution should normally produce approximately **5–10 Luxe Credits
for casual participation, 12–20 for a regular player, and 22–28 for a highly engaged player per
account week**. A total of **30–35** is reserved for clearly identified celebration or authored
event weeks rather than routine output. One-time Main Quest rewards, service compensation, and
refunds are excluded from the repeatable target.

Store pricing and free earnings are validated together. A consistently engaged free player should
normally be able to obtain a small premium item in roughly **3–4 weeks**, a standard premium item
in **6–8 weeks**, and a premium animated or high-production item in **12–16 weeks**. A complete
seasonal collection is not expected to be obtainable entirely from one free reward cycle. Premium
items may rotate, but ordinary first-party items return on a disclosed cadence so monetization does
not depend on permanent one-time-only fear of missing out.

Premium quest rewards follow these rules:

- no quest requires premium spending to earn premium currency;
- payer status, House Pass ownership, advertisements, and purchase history do not multiply the
  base Luxe Credit reward;
- premium currency never increases Hype, ranked score, market-share ceilings, or authoritative
  competitive power;
- completed rewards are granted idempotently and appear in the economic ledger with the quest,
  rule version, and cause;
- reward previews are exact before the player commits time or resources;
- a quest reward cannot be silently reduced because the player owns a related cosmetic or has a
  high currency balance.

#### 12.2.3 Reset, completion, and anti-compulsion rules

Daily and weekly timing uses authoritative server time and an account quest timezone chosen from
the player's region. Daily Briefs reset at 04:00 account-local time; Weekly Commissions reset each
Monday at 04:00. Timezone changes have a cooldown and cannot generate duplicate boards or rewards.

There are no reward streaks that grow indefinitely or punish a missed day. Missing a day or week
does not remove Luxe Trust, previous rewards, Main Quest progress, or future reward value.
Completed but unclaimed quest rewards are automatically claimed to the authoritative ledger at
reset and summarized on the next return.

Quest generation must:

- validate that every objective is reachable with the player's unlocked systems and resources;
- exclude actions blocked by an active outage, unresolved migration, account restriction, or
  inaccessible multiplayer dependency;
- prevent contradictory objectives and avoid assigning the same behavior as the dominant Daily
  Brief more than two consecutive days;
- preserve partial progress after reconnect and reject duplicate completion claims;
- offer an equivalent accessible objective when an interaction cannot be completed with reduced
  motion, assistive technology, or the device's performance fallback;
- never secretly scale difficulty upward because the player spends money or owns premium items.

#### 12.2.4 Luxe presentation and quest feedback

Luxe introduces each board as a concise strategic brief, explains why an objective matters, and
gives a short debrief when it completes. The quest surface shows:

1. objective and narrative framing;
2. exact progress and completion condition;
3. relevant system and direct action link;
4. time remaining for Daily or Weekly quests;
5. exact rewards;
6. optional strategic hint;
7. completion receipt and what changed.

Luxe may prioritize a quest that addresses the player's current bottleneck, but the player can
ignore it without hidden penalties. Quest notifications are optional, respect quiet hours, and
never exceed one Daily Brief reminder and one Weekly Commission reminder per reset period. Luxe
must feel like a competent partner who understands the house, not a notification machine or shop
salesperson.

### 12.3 Vex: persistent critic history

Vex tracks originality, execution, restraint, cultural relevance, and integrity. The
authoritative system considers the current result, prior reviews, repeated choices,
revisions, derivative work, trend chasing, crisis behavior, Maison context, and rival
context. Classification and opinion shifts are server-owned.

An optional AI service may turn structured results into short editorial prose behind a
trusted boundary. It never determines Hype, rewards, penalties, market outcomes, event
placement, or moderation. Vex distinguishes a new observation from a historical
pattern, and the player can inspect the evidence behind a review.

### 12.4 Rivalry and Archive

Maison Vanta, founded by Seraphine Vale, is the first persistent rival house. Rivals
observe player choices, adapt their offers and responses, and create decisions. They do
not impose unavoidable losses. The Story Archive stores designs, deals, crises,
relationships, rival actions, Gala results, and meaningful consequences in chronological
context.

### 12.5 Living Fashion World: NPC and AI ecosystem

#### 12.5.1 Purpose and authority boundary

NPCs make the world active before, between, and beyond player interactions. They create customers,
commercial counterparties, colleagues, critics, rivals, institutions, opportunities, conflict, and
memory. They are not an invisible difficulty slider and do not receive permission to alter the
rules.

The server owns every NPC's authoritative identity, role, goals, resources, knowledge, preferences,
relationships, memories, cooldowns, contracts, inventory, and legal actions. A rules engine or
bounded planner selects eligible actions. Optional AI services may express those actions through
short prose, dialogue, summaries, and variants. Every consequential generated statement is grounded
in a structured event payload and is replaceable by a deterministic authored line.

AI never owns:

- Hype, demand, sales, price response, quality, originality, or customer settlement;
- Gala scores, judging weights, finalist selection, territory, leaderboards, or rewards;
- inventory, currency, stores, contracts, staff ownership, or elapsed time;
- moderation verdicts without human-review and policy support;
- player relationships, reputation changes, or crises that are not present in server state.

#### 12.5.2 NPC identity, taste, goals, and memory

Important named NPCs use a common profile contract:

1. role and institution;
2. city, market, and customer context;
3. fashion-taste weights and explicit dislikes;
4. budget, resources, capacity, authority, and risk tolerance;
5. short-term objective and long-term ambition;
6. relationship state with the player, Maison, and relevant NPCs;
7. remembered evidence from designs, deals, service, crises, claims, and repeated behavior;
8. knowledge boundary defining what the NPC can reasonably know;
9. communication style and safe fallback lines;
10. valid actions, cooldowns, exit conditions, and authoritative owner.

Memory is evidence-based and bounded. NPCs may recognize patterns such as repeated late delivery,
consistent accessible pricing, improved construction, overreliance on one silhouette, ethical
recovery, or broken promises. They cannot remember events that did not occur or infer private player
messages, spending, or protected personal information.

#### 12.5.3 Customers, loyalists, and collectors

Customer populations purchase, reject, browse, return, review, recommend, complain, and change
loyalty according to the demand model and their preferences. Representative named customers may:

- become early supporters, collectors, everyday loyalists, trend amplifiers, or former fans;
- recognize a recurring design language or criticize stagnation;
- respond to price, availability, stockouts, quality, service recovery, sustainability, and brand
  claims;
- request restocks, broader sizing, repairs, accessible alternatives, or a premium edition;
- migrate to a rival after repeated disappointment and return after credible improvement;
- create a bounded word-of-mouth opportunity without guaranteeing virality.

Returns and complaints identify a real cause. Customers do not randomly punish a successful design,
and no critique evaluates a player's real body or identity. The game represents fashion access and
fit through product availability, declared size coverage, comfort, and service rather than shame.

#### 12.5.4 Suppliers and manufacturers

Supplier NPCs form persistent commercial relationships. They may reward reliability, accurate
forecasting, fair negotiation, long-term volume, ethical conduct, or successful recovery. They may
also prioritize another Maison, reduce capacity, renegotiate, fail inspection, face disruption, or
exit the market.

A supplier offer declares quality range, capacity, cost, lead time, minimum order, geography,
sustainability evidence, exclusivity, credit terms, failure risk, and remedies. Hidden traits may
exist only where the player has a fair investigation or due-diligence path. A supplier cannot be
secretly perfect or fraudulent solely to force a desired story result.

Manufacturers track workload, skill, equipment, defect risk, labor posture, and delivery history.
Architects may reserve capacity, diversify production, finance an upgrade, audit quality, negotiate
priority, or accept a lower-cost risk. Artisans may build a craft relationship that unlocks new
techniques or more faithful execution, never a paid Hype bonus.

#### 12.5.5 Retail buyers, wholesalers, and commercial clients

NPC buyers represent department stores, independent boutiques, luxury retailers, online platforms,
regional distributors, costume departments, and institutional clients. They issue briefs, negotiate
terms, compare proposals, place trial orders, renew successful contracts, and end unreliable
relationships.

Their decisions consider declared factors: customer fit, expected sell-through, margin, quality,
brand coherence, reliability, capacity, timing, territory, exclusivity, reputation, and prior
performance. Rejection includes at least one material reason and, where appropriate, a route to
improve or pursue a better-fit buyer.

#### 12.5.6 Critics, editors, and cultural institutions

Vex is the persistent flagship critic. Additional critics and outlets represent different credible
lenses such as traditional luxury, streetwear, experimental design, craftsmanship, sustainability,
commercial wearability, youth culture, and local cultural context.

Critics may review releases, compare the current work with the Archive, attend shows, question a
claim, recognize improvement, or create a debate. They influence the audience segments that trust
them; they do not directly overwrite Hype or determine Gala outcomes. Their criteria are visible,
their history is inspectable, and disagreement is expected.

Museums, fashion councils, schools, magazines, and archives may offer exhibitions, grants,
residencies, preservation requests, research briefs, and legitimacy challenges. Institutional
approval grants opportunity and history, not universal proof that one style is objectively best.

#### 12.5.7 Influencers, public figures, stylists, and celebrity clients

Influencer NPCs have audience composition, engagement quality, personal style, values, reliability,
controversy exposure, commercial terms, and brand compatibility. A smaller aligned figure may create
better conversion and loyalty than a larger mismatched celebrity. Paid and organic endorsements are
clearly distinguished.

Stylists and public figures may request garments for award shows, performances, tours, magazine
covers, premieres, campaigns, or private appearances. A request declares deadline, budget, prestige,
creative control, exclusivity, fit requirements, production risk, and publicity terms. Success may
create Hype, relationships, sales opportunities, and Archive moments; failure follows actual missed
requirements rather than hidden dice.

No NPC endorsement guarantees a viral outcome. Public-figure controversy creates choices about
continuing, pausing, renegotiating, or ending the relationship, with evidence and proportional
consequences.

#### 12.5.8 Staff, executives, and workplace culture

Staff are characters and operational agents, not collectible multipliers. Designers, pattern makers,
buyers, store managers, marketers, accountants, lawyers, publicists, quality specialists, production
leads, and logistics managers may have skill, workload, confidence, ambition, loyalty, values,
relationships, and development goals.

Staff may identify risks, propose alternatives, make bounded mistakes, improve through experience,
request resources or promotion, disagree with a decision, leave for another opportunity, recover
from failure, mentor others, or become a future executive. Their behavior uses declared workload and
relationship causes. A paid staff skin or Icon Edition never changes the functional profile.

Workplace choices affect retention, quality, Founder Rep, crisis risk, and succession. The player may
not solve every disagreement by spending premium currency. Abusive management is not rewarded as the
unambiguously optimal strategy.

#### 12.5.9 Rival founders and AI-controlled Maisons

AI-controlled Maisons keep cities, auctions, Feed activity, commercial markets, territory, and
storylines active while the human population grows. Each has a coherent doctrine, resource base,
leadership style, preferred customer, operating strengths, weaknesses, risk tolerance, and memory.
Possible doctrines include luxury scarcity, mass accessibility, cultural movement, sustainable
craft, aggressive franchising, technical innovation, acquisition, and trend speculation.

NPC Maisons obey the same authoritative constraints as players: money, inventory, capacity, lead
time, contracts, territory upkeep, cooldowns, reputation, and event eligibility. They do not see
private player information, future random events, hidden bids, or unreleased trend results. Difficulty
changes planning depth, forecasting error, and willingness to take risk—not unlimited resources or
rule immunity.

NPC Maisons may occupy unfilled market and territory roles, but their concentration is capped and
their holdings contract as healthy human competition becomes available. They may enter Gala
exhibitions and qualification benchmarks, but they cannot take one of the limited top-three premium
reward placements from an eligible human House or Maison Crown Final.

#### 12.5.10 Investors, lenders, landlords, and governance actors

Investors and lenders evaluate risk, governance, growth, cash flow, reputation, collateral, and
strategic fit. They may provide loans, equity, revenue-share finance, milestone capital, bridge
funding, or rescue terms. Every offer exposes repayment, dilution, control rights, covenants,
reporting, deadlines, default consequences, and exit conditions.

Landlords and property agents control leases, renewals, fit-out support, rent, auctions, district
access, and distressed-store opportunities. They may negotiate and remember reliability, but they
cannot secretly target a player based on spending status or remove protected progression without a
recovery route.

Board members, partners, and governance NPCs may challenge risky expansion, ethics, debt,
reputation, or founder control. Their influence comes from a contract or ownership state the player
accepted, not from arbitrary interruption.

#### 12.5.11 Journalists, media, regulators, and inspectors

Journalists and outlets investigate or report launches, leadership, labor, claims, sustainability,
counterfeiting, financial trouble, collaborations, rival disputes, and crises. A story requires an
actual event, claim, evidence state, or credible investigation trigger. Players may provide evidence,
give an interview, correct the record, admit fault, refuse comment, make restitution, or pursue a
new action.

Regulators and inspectors enforce product quality, worker safety, advertising truth, environmental
claims, financial rules, consumer protection, intellectual property, and event standards. Inspection
risk follows the player's industry exposure and choices; it is not a random tax. Findings name the
rule, evidence, remedy, appeal path, and consequence.

AI-generated journalism cannot fabricate quotations, accusations, evidence, crimes, or real-person
claims. High-severity allegations use authored templates and human-reviewed content rules.

#### 12.5.12 Brokers, agents, mentors, and event professionals

Brokers and agents connect players to suppliers, stores, buyers, collaborators, stylists, investors,
and events. Their value is access, curation, negotiation support, or time saved—not hidden outcome
control.

Mentor NPCs teach advanced systems through contextual challenges, post-result diagnosis, and
alternative strategies. They may inspect a weak collection, explain store underperformance,
recommend a pricing test, introduce a supplier, or set a scenario objective. Mentors provide no
exclusive permanent competitive multiplier.

Event organizers, curators, backstage coordinators, hosts, judges, and guests make the Aurelian Gala
and Fashion Week feel like produced cultural events. Gala judges publish their scoring priorities
before submission. AI may write commentary from the frozen score breakdown, but cannot calculate or
change the score.

#### 12.5.13 Counterfeiters, fraud actors, and external threats

NPC counterfeit networks, deceptive vendors, opportunistic brokers, and other bad actors may copy
successful work, sell low-quality replicas, misrepresent materials, create customer confusion, or
trigger legal and supply investigations. These conflicts create choices among authentication,
customer education, legal action, platform takedown, redesign, supplier investigation, insurance,
and public response.

Bad actors obey evidence, cost, reach, risk, and enforcement rules. The game does not normalize
harassment, targeted abuse, identity attacks, bribery as mandatory progress, or false accusations
against real players. Player-versus-player sabotage remains prohibited outside declared competitive
systems.

#### 12.5.14 AI content quality, safety, and consistency contract

All generated NPC content must pass the following contract:

- use only a server-provided structured context and approved character profile;
- distinguish verified fact, NPC opinion, forecast, rumor, and uncertainty;
- mention concrete garment, price, service, relationship, or event factors when criticizing;
- never invent server state, rewards, purchases, messages, relationships, evidence, or player intent;
- never insult or sexualize the player, shame a body, infer protected traits, or target identity;
- avoid repetitive generic comments, imitation of living designers, copyrighted slogans, and
  undisclosed product promotion;
- respect blocks, privacy settings, age controls, moderation decisions, localization, and reduced
  social exposure settings;
- provide a deterministic authored fallback for outage, timeout, safety rejection, or unsupported
  locale;
- log model version, prompt-template version, grounding identifiers, safety outcome, and generated
  content identifier without storing unnecessary private data;
- support report, review, removal, correction, and character-consistency testing.

Generated content is limited in length and frequency. It is cached, deduplicated, and rate-limited.
The client never sends service credentials or treats generated prose as authority. The player may
reduce NPC comment density or disable generated prose while retaining all gameplay information.

#### 12.5.15 Population simulation and content cadence

The world simulation uses layered fidelity:

- aggregate populations settle demand, awareness, loyalty, and sentiment;
- archetype cohorts generate interpretable segment outcomes;
- named NPCs carry persistent relationships and story memory;
- generated prose is reserved for high-value moments, representative Feed reactions, negotiations,
  major reviews, crises, and event presentation.

This avoids excessive cost, latency, repetition, and unstable behavior. The game must remain lively
through authored templates, simulation events, and NPC schedules even if every generative service is
disabled. NPC activity should create opportunities and decisions, not flood the player with noise.
The default daily experience targets a small number of high-signal reactions and at least one
materially actionable world development rather than dozens of disposable comments.

#### 12.5.16 NPC role maturity and release tiers

All roles in the Living Fashion World are canonical, but they do not need equal depth on the same
release date. Role maturity is staged to protect quality:

- **Core simulation tier:** customer cohorts, representative named customers, suppliers,
  manufacturers, Vex, Luxe, Maison Vanta, Feed reactions, and contextual mentors. These prove the
  central loop and must work without generative AI.
- **Commercial and social tier:** retail buyers, wholesalers, staff relationships, additional
  critics, AI-controlled Maisons, landlords, event professionals, and one bounded influencer or
  stylist pipeline. These deepen both paths after the core loop validates.
- **Institutional and expansion tier:** investors, lenders, governance actors, cultural
  institutions, broader celebrity campaigns, brokers, investigative media, regulators, advanced
  counterfeit networks, and long-form NPC relationship arcs.

A role advances to the next maturity level only after its lower-fidelity version produces
understandable choices, consistent consequences, acceptable content variety, safe output, and
measurable player value. Adding more generated dialogue is not considered a maturity increase unless
the underlying simulation and choices improve.

#### 12.5.17 Reaction hierarchy and attention budget

NPC attention is scarce by design. The game separates simulation volume from presentation volume:

1. **Silent population:** most customers affect demand, awareness, loyalty, and sentiment without
   producing an individual notification.
2. **Aggregate signal:** the result receipt summarizes statistically meaningful movement by segment,
   city, and reason.
3. **Representative reactions:** a small sample of likes, comments, reviews, complaints, or purchase
   stories illustrates distinct causes rather than repeating the same sentiment.
4. **Named relationships:** recurring customers, buyers, suppliers, staff, critics, and rivals react
   only when their history, goals, or relationship makes the moment meaningful.
5. **Editorial moments:** Luxe, Vex, major journalists, Gala judges, or narrative characters receive
   the highest presentation priority and should not be drowned out by routine comments.

Each release or settlement receives a server-configured **Reaction Budget** based on importance,
novelty, relationship relevance, player settings, and recent repetition. The default post-release
surface should normally show one aggregate summary, two to five representative reactions, and no
more than one high-value editorial response at a time. Exceptional Gala, crisis, viral, or narrative
moments may exceed this budget through a clearly grouped event digest rather than notification spam.

Duplicate sentiment, generic praise, reactions that add no new cause, and low-value notifications are
collapsed. The player may reduce comment density, mute categories, or review a later digest without
losing economic information or rewards. No quest asks the player to read a minimum number of NPC
comments.

The system fails acceptance if players routinely skip all reactions, cannot distinguish important
characters from ambient population, report that comments feel fabricated or repetitive, or receive
more presented reactions without gaining a new decision or understanding.

## 13. Crisis and Reputation Systems

Crises are authored decision sequences involving a claim, evidence, time window,
stakeholders, and possible resolutions. The player sees the credibility, cost,
relationship, and market tradeoff before committing. A resolution returns a structured
explanation and writes a permanent Archive entry.

Crisis actors may include customers, staff, suppliers, buyers, journalists, regulators, investors,
landlords, public figures, rivals, or counterfeit operations. Every crisis identifies which claims
are verified, disputed, unknown, or opinion; what each actor reasonably knows; and what evidence the
player can inspect or seek. Generated dialogue may express the actor's position but cannot create the
underlying evidence or severity.

A crisis cannot be resolved twice. Client clock changes cannot bypass deadlines. Choices
produce different later scenes. No response fabricates evidence or targets another player
with an accusation. The visual recovery ritual after resolution must not erase narrative
consequences. Founder Rep, Brand Heat, Luxe Trust, sales, Feed discussion, and rival
behavior may change, but each delta names its cause.

### 13.1 Failure-to-recovery contract

A failed design, release, store, contract, event, territory attempt, or commercial decision must
create a **Recovery Loop**, not only remove currency and time. The settlement identifies the dominant
causes, what remains salvageable, which consequences are permanent, and at least two viable next
responses when the House remains operational.

Supported recovery actions include:

- revise the weak garment zone, construction choice, audience fit, quantity, or presentation;
- reprice, markdown, bundle, hold, or redirect inventory to a better segment or city;
- accept a transparent wholesale rescue, consignment, outlet, licensing, or acquisition offer;
- convert excess stock into a limited rework, archive piece, material recovery, donation, or public
  community initiative where appropriate;
- renegotiate delivery, refinance within responsible limits, replace a supplier, reroute logistics,
  reduce scope, or pause expansion;
- rehabilitate a distressed store through staffing, layout, assortment, pricing, service, or local
  relationship changes;
- acknowledge a mistake, disclose evidence, compensate affected customers, or pursue a longer
  reputation-recovery arc;
- allow another player or NPC Architect to acquire, operate, or help recover an asset under a fair
  contract.

Recovery offers expose their cost, rights, obligations, likely outcomes, and relationship effects.
No premium purchase, advertisement, subscription, or paid staff edition is presented as the primary
way to escape a loss. The player cannot erase every consequence, but one ordinary failure must not
trigger an irreversible debt spiral, permanent competitive exclusion, or loss of progression-critical
access.

Some failures create durable history, new rivals, changed customer expectations, staff reactions,
or reduced trust. Those consequences become future decisions and story material. A successful
recovery may create a respected comeback, operational mastery, customer loyalty, or a distinctive
House philosophy; it does not retroactively convert the original failure into a hidden reward.

The crisis screen defines loading, evidence-unavailable, offline, error, disabled,
expired, resolved, and next-action states. It never hides a meaningful consequence behind
decorative motion. Continuity: v6 §§8.9.2 and 12.2.1.

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

### 14.2 Monthly Aurelian Gala

The Aurelian Gala is the game's largest recurring fashion event: a **monthly**, asynchronous,
skill-based fashion show where individual Houses and player-created Maisons present original
collections. The event celebrates design, identity, commercial storytelling, and collaboration
without allowing lifetime wealth, roster size, or spending to buy placement.

#### 14.2.1 Event tracks and divisions

The Gala contains two parallel tracks:

- **House Showcase:** one eligible collection from an individual player's designated Ranked House;
- **Maison Grand Showcase:** one eligible collection from a Maison, with up to six scored member
  contributors and a locked support roster.

Each track uses Rising, Bronze, Silver, Gold, and Sovereign divisions. A House or Maison enters one
division per month based on its competitive rating, prior Gala result, account integrity, and
current eligible strength. First-season competitors begin in Rising unless anti-Sybil review finds
an experienced alternate account. The **Crown Final** compares the highest-qualified Sovereign
finalists and produces the global top three for each track.

One account may submit only one House Showcase entry and contribute scored work to only one Maison
Grand Showcase entry per month. Paid House slots cannot multiply eligibility or rewards.

#### 14.2.2 Monthly cadence

| Phase | Timing | Required experience |
|---|---|---|
| Theme reveal and registration | Week 1 | Luxe introduces the theme, rubric, divisions, standardized resources, and deadlines |
| Creation and partnership | Weeks 1–2 | Artisans create pieces; Architects plan collection, production story, audience, and rollout |
| Runway staging and submission | Week 3 | Entrants select 3–6 pieces, sequence the show, write the strategic brief, and lock the entry |
| Anonymous judging and integrity review | Early Week 4 | Server scoring, randomized community comparison, moderation, and anti-collusion checks |
| Grand showcase and results | Final days of the month | Runway presentation, finalists, top three, rewards, score breakdown, and Archive entry |

The schedule is asynchronous. No participant must be online at a specific minute to remain eligible.
A locked entry may be previewed but not materially changed after the deadline. An outage or verified
platform failure uses documented extension or compensation rules for the affected cohort.

#### 14.2.3 Standardized competitive instance

Every entry is built inside a Gala instance with an equal, division-appropriate event budget and
access to the required functional design options. Main-House wealth, territory, paid staff,
subscription status, premium tools, advertisements, and economic multipliers do not increase the
Gala budget or score ceiling.

Players retain their earned aesthetic identity and may use owned presentation cosmetics, but those
assets contribute no score. Premium visual assets are labelled as presentation-only during judging.
The Gala instance cannot drain the main House into an unrecoverable state, and its rewards do not
require premium expenditure.

Maison entries contain 3–6 pieces. At most six members receive scored contribution slots; additional
members may advise, act as substitutes before lock, help with non-scored project tasks, or receive a
bounded eligible-roster reward. Raw roster size never adds points.

#### 14.2.4 Scoring

```text
Final_Gala_Score =
    0.25 × Theme_Interpretation
  + 0.20 × Design_Execution
  + 0.20 × Originality_And_Brand_Identity
  + 0.15 × Collection_Cohesion_And_Runway_Story
  + 0.10 × Strategic_Rollout_Brief
  + 0.10 × Normalized_Community_Vote
```

For a Maison entry, `Strategic_Rollout_Brief` evaluates the Architect contribution: audience,
pricing posture, production rationale, channel plan, city logic, and declared tradeoffs. It does not
score projected revenue or the Maison's existing wealth. For a House entry, the same category scores
the founder's commercial reasoning.

All components are normalized to 0–100 under one frozen monthly rule version. Trend bonuses cannot
overpower quality or originality. Vex may present the final editorial critique but does not determine
the authoritative score.

#### 14.2.5 Judges, audience, and event-world presentation

Each Gala uses a disclosed panel of NPC judges with complementary lenses such as execution,
originality, cultural interpretation, wearability, responsibility, storytelling, and commercial
clarity. Their published priorities explain how they interpret the frozen scoring rubric; they do
not add hidden weights or override the server result.

NPC buyers, critics, stylists, customers, hosts, and guests may react to finalists and create
post-Gala opportunities. Their comments are grounded in the score breakdown and design state. NPC
exhibition entries may enrich the show or establish a benchmark, but cannot take a top-three human
premium reward placement. A winner receives attention and opportunities, not an uncapped permanent
advantage in the next Gala.

#### 14.2.6 Community voting and anti-collusion

Community voting is anonymous until settlement, randomized, pairwise or small-set comparative,
rate-limited, and normalized so audience size cannot determine the result. Voters do not see creator
names, Maison names, follower counts, territory, spending indicators, or current rank during voting.

The integrity system detects reciprocal vote rings, linked-account clusters, device farms, rapid
low-information voting, coordinated brigading, harassment, and reward trading. Suspicious votes are
down-weighted or removed under an auditable rule. Community voting can influence close results but
cannot determine a winner alone.

Entrants cannot buy votes, require Maison members to vote a specific way, trade store assets for
votes, or condition contracts on Gala support. Enforcement may invalidate votes, remove an entry,
withhold rewards during review, or suspend competitive eligibility, with an appeal path.

#### 14.2.7 Rewards

The Gala must feel materially rewarding without creating a permanent competitive aristocracy.
Initial server-configurable targets are:

| Placement | House Crown Final | Maison Crown Final, per eligible locked member |
|---|---|---|
| 1st | 120 Luxe Credits, monthly Crown premium item, large Aurelian Seal award, trophy and Archive feature | 60 Luxe Credits, Maison Crown premium item, large Aurelian Seal award, HQ trophy and Archive feature |
| 2nd | 80 Luxe Credits, premium finalist item, Aurelian Seals, trophy and Archive feature | 40 Luxe Credits, premium finalist item, Aurelian Seals, HQ trophy and Archive feature |
| 3rd | 50 Luxe Credits, premium finalist item, Aurelian Seals, trophy and Archive feature | 25 Luxe Credits, premium finalist item, Aurelian Seals, HQ trophy and Archive feature |

The Gala uses a recognition ladder so the monthly event remains worthwhile outside the global top
three:

- **Valid Showcase:** every eligible locked entry that passes moderation and integrity review receives
  a small participation grant, Archive record, score breakdown, and progress toward a non-power Gala
  milestone track.
- **Personal Best:** an entry that materially exceeds the House's prior comparable score receives a
  one-time monthly recognition badge and bounded Aurelian Seals; alternate accounts and deliberately
  suppressed prior scores are excluded.
- **Division Finalist:** the highest-qualified field in each division receives a finalist frame,
  larger Seals, and a bounded presentation reward.
- **Division Top Three:** receive smaller Luxe Credit amounts, division trophies, Aurelian Seals, and
  premium presentation items. Rising rewards remain meaningful while anti-Sybil controls prevent
  experienced-account farming.
- **Crown Final Top Three:** receive the major rewards listed above.
- **Category Laureates:** independent rubric categories recognize Best Construction, Best Color
  Story, Most Original, Best Commercial Collection, Best Responsible Direction, Best Emerging House,
  Best Artisan–Architect Collaboration, Vex Critics' Selection, and Customer Choice. Category names
  may rotate with the theme.
- **Maison Contribution:** eligible locked members receive a visible contribution receipt and bounded
  reward based on completed declared work; leadership cannot redirect it.

One entry may earn several titles but receives only the highest Luxe Credit placement reward plus at
most one category presentation item and one category Seal grant. Category awards do not stack into a
premium-currency farming route, add score after judging, or override the Crown ranking. Customer
Choice is normalized and anti-collusion reviewed; Vex Selection is derived from a frozen published
rubric rather than generated prose.

The Gala milestone track records participation, improvement, finalist appearances, category range,
and discipline mastery. It grants Archive exhibits, runway presentation assets, and Aurelian Seals,
not future score, Hype, sales, territory, or bidding power. Most serious participants should leave
with useful feedback and visible progress, while Crown winners remain exceptional.

Any House Funds component is rank-banded and expressed as a bounded number of normal efficient-play
days rather than one fixed amount that becomes trivial for veterans and destabilizing for newcomers.
Gala rewards never grant permanent Hype, sales, idle, territory, bid, market-share, staff, or future
Gala-score multipliers. Premium items are presentation, collection, and status rewards.

Maison rewards settle automatically from the locked eligible roster and contribution ledger. A
Founder cannot redirect the prize, exclude a qualified member, or keep the group pool. A member who
qualified before lock retains the earned reward even if they leave after lock.

#### 14.2.8 Repeated-winner controls and competitive mobility

The same House or Maison may win repeatedly through skill, but the system monitors repeated top-three
occupancy, division movement, judge-score concentration, roster poaching, and newcomer finalist
rates. Corrective controls may include promotion, stronger division placement, varied themes,
standardized option rotations, additional strategic counters, and broader finalist fields. The game
does not secretly reduce a winner's score or grant hidden outcome bonuses to challengers.

A prior Crown winner retains status and history but receives no automatic score bonus in later
months. Every month begins with a new theme, frozen rules, standardized event resources, and an
independent settlement.

## 15. Talent and Staff

### 15.1 Staff Contracts

Gameplay staff are earned through progression, Luxe Quests, events, House Funds, reputation,
and negotiation. They provide horizontal strategic archetypes and tradeoffs. Every
functional archetype has a deterministic free acquisition path. Recruitment state is
server-authoritative.

### 15.2 Staff character and relationship contract

Every functional staff archetype defines skill, workload capacity, development path, decision
rights, values, ambition, reliability, relationship state, and eligible mistakes. Staff advice and
automation exceptions cite actual operational evidence. Promotions, compensation, training,
workload, credit, workplace culture, and leadership choices affect retention and performance through
bounded rules.

Optional AI dialogue may give staff a voice, summarize a report, or explain disagreement. It cannot
secretly change staff effectiveness, loyalty, departure, or a crisis. Staff never read private DMs,
purchase history, or information outside their role. A deterministic report and response path always
exists.

### 15.3 Earned automation ladder

Automation removes repeated execution only after the player understands the operation. The
canonical ladder is:

| Stage | Player experience | Automation capability | Required player control |
|---|---|---|---|
| 0. Founder-operated | Player performs or confirms the operation | None | Every meaningful decision |
| 1. Operations Assistant | Player has completed the operation successfully | Repeats a transparent default within a small capacity | May pause, inspect, or override |
| 2. Specialist | Player has encountered the operation's main tradeoffs | Optimizes one declared objective with a drawback | Chooses objective and risk tolerance |
| 3. Department Manager | Player has upgraded capacity and staff | Coordinates several linked operations | Sets policy, budget, thresholds, and exceptions |
| 4. Executive Policy | Multi-city or late-game progression | Applies bounded rules across divisions | Reviews exceptions, reallocates resources, and changes strategy |

Automation is unlocked by demonstrated use, Brand Rank, staff, capacity, and House Funds—not
by waiting alone. Every automated operation displays its policy, last actions, performance,
capacity, exceptions, and estimated difference from direct control. The server settles all
automated outcomes from frozen rules and authoritative state.

Required launch policy controls include:

- reorder point and target Buffer Stock;
- maximum acceptable unit cost and supplier-risk posture;
- price floor, price ceiling, and stockout response;
- campaign budget and audience priority;
- inventory-transfer threshold between stores;
- quality-control threshold and hold-for-review rule.

Automation cannot make irreversible narrative, crisis, collaboration, premium-currency, Gala,
Ascension, or brand-identity decisions. Those always require explicit player commitment. Poorly
configured automation may create bounded inefficiency, missed opportunity, overstock, or a
reviewable exception; it may not silently destroy rare assets or create an unrecoverable state.

### 15.4 Icon Editions

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

Idle settlement simulates the last confirmed production plans, inventory, store policies,
staff automation, demand rules, active events, and bounded random variance. It does not invent
new irreversible decisions while the player is absent. Expired campaigns, exhausted stock,
capacity limits, price rules, and supply constraints are honored. The result is identical
regardless of device clock, repeated login, reinstall, or interrupted claim.

### 16.2 Offline return receipt

A return after at least 15 minutes away opens a concise, skippable **House While Away** receipt.
It contains:

1. authoritative time away and time simulated;
2. units produced, shipped, sold, returned, held, or lost to bounded spoilage where applicable;
3. revenue, costs, gross profit, and resulting House Funds;
4. inventory changes, stockouts, overstock, delayed supply, and unused capacity;
5. staff and automation actions with any policy exceptions;
6. trend, city, rival, Luxe, Vex, Feed, crisis, or narrative developments that legally occurred;
7. comparison with the previous equivalent period and the main causes of the difference;
8. one to three recommended next actions, each linked to the relevant surface.

The default view prioritizes the result, biggest change, and next action. An expandable Ledger
breakdown exposes the complete settlement receipt. Reward animation never delays access to the
information or the claim. The player may inspect the empire before claiming only when doing so
cannot alter the frozen result.

If Buffer Stock filled before the cap, the receipt states when and why production stopped and
shows the lost-opportunity estimate without shaming the player. No return flow uses doubled
rewards, advertisement prompts, premium claims, or false urgency at launch.

### 16.3 Active intervention value

Idle play preserves progress; active play creates superior outcomes through information and
decisions. During a normal active session, the player can improve expected performance by
responding to bottlenecks, changing policy, timing releases, reallocating inventory, negotiating,
revising designs, handling exceptions, and reacting to rivals or trends. Active play must not be
required to prevent punitive loss while sleeping or working.

The intended efficient-income relationship is governed by §10.3. Active advantage comes from
better strategy and reduced waste, not a permanent login multiplier. Repetitive tapping, screen
time, or leaving the application open provides no uncapped economic benefit.

### 16.4 Casual and Expert

Modes change presentation and control depth only. Casual Mode automates advanced choices
using transparent defaults. Expert Mode exposes detailed controls and forecasts. Both
use the same outcomes, rates, rewards, ceilings, crisis severity, and eligibility.

### 16.5 Joint Venture

At Rank 50, the secondary path unlocks as a new division with initial secondary
throughput of 60%. Path-specific mastery progresses it to 100%. There is no instant
doubling of the economy. The original path remains narratively dominant, and both
divisions use one shared economic ledger.

### 16.6 Aurelian Ascension

At Rank 100, the player creates a permanent Hall of Sovereigns legacy statue, preserves
the existing empire, unlocks optional Legacy Challenges and a parallel New House run,
and carries cosmetics, Archive history, and one Classic Alpha design. Ascension grants
prestige and replayability without permanent Hype, idle, market, or ranked multipliers;
it does not reset the main empire and matchmaking remains normalized.

### 16.7 Institutional Legacy and recurring endgame purpose

The endgame asks **what kind of fashion institution the House has become**, not only how much wealth it
has accumulated. After Rank 100, the player chooses one optional seasonal **Legacy Mandate** at a
time. Mandates create long-horizon identity goals with different creative, commercial, social, and
narrative requirements.

Supported Mandate families include:

- establish a recognizable design movement across several collections without repeating one formula;
- build a resilient multi-city production and distribution network under disruption;
- become a respected luxury, accessible, experimental, community, sustainable, or craftsmanship-led
  institution through consistent choices and accepted tradeoffs;
- mentor emerging Houses and document their independence without controlling their assets;
- rehabilitate distressed stores, suppliers, heritage brands, or failed collections;
- complete historical collection archives and preserve important design lineages;
- master different Gala disciplines and category awards rather than only total placement;
- create lasting Artisan–Architect partnerships, Maison institutions, and fair governance records;
- complete difficult scenario campaigns, rival arcs, city-entry challenges, and crisis recoveries;
- influence a seasonal fashion conversation through credible work, customer response, and public
  choices without purchasing trend authority.

Mandates provide authored objectives, Archive chapters, status titles, Hall exhibits, cosmetic and
presentation rewards, scenario access, and bounded Aurelian Seals. They grant no permanent ranked,
Gala, Hype, sales, idle, territory, contract, or market multiplier. Players may change Mandates at a
season boundary without losing completed history.

The Hall of Sovereigns shows the player's design signatures, commercial philosophy, cities shaped,
major recoveries, collaborations, protégés, rivalries, Gala disciplines, and consequential choices.
It should communicate a unique institutional biography rather than a list of currencies.

Endgame acceptance requires several viable identities. Telemetry or playtests showing that nearly all
advanced players pursue one optimal Mandate, repeat one collection strategy, or play only to increase
valuation blocks additional endgame rewards until the strategic field is broadened.

## 17. Monetization and F2P Integrity

### 17.1 Constitution and product boundaries

The monetization constitution is:

> Players may pay to experience more, create more, organize more, replay more, collect more,
> and express more. Players may not pay to outperform better strategy.

Purchases may provide expression, additional authored content, creative capacity, organization,
replayability, collection, and bounded convenience. They may not raise Hype or Gala score, alter
market-share ceilings, improve authoritative demand formulas, increase idle rates, grant superior
staff archetypes, reveal exclusive strategic information, erase consequences, or determine a
competitive result.

Monetized entitlements fall into four declared classes:

1. **Consumable:** Luxe Credits and clearly described limited-use presentation items.
2. **Durable unlock:** Creative Studio Pro, Operations Suite, additional House slots, story
   expansions, and scenario packs.
3. **Time-bound access:** Founder Club and other subscriptions with continuing value.
4. **Seasonal access:** House Pass, licensed collaboration passes, and larger narrative seasons.

Every offer states its class, exact contents, duration, renewal behavior, regional price, refund and
restoration path, and whether an entitlement remains usable after expiration. Digital purchases use
the platform billing system, server-side receipt verification, idempotent grants, and entitlement
restoration. The economic ledger records premium-currency issuance and consumption without exposing
payment data to gameplay services.

Luxe may explain that optional content exists when contextually relevant, but Luxe is not a sales
agent. Quest completion, House While Away reports, crises, losses, insufficient funds, and emotional
story scenes never open an immediate purchase prompt. Monetization remains visually secondary to
play and cannot impersonate a gameplay objective, system alert, character message, or reward claim.

### 17.2 Luxe Credits, free earnings, and catalogue pacing

Luxe Credits are purchasable and boundedly earnable through Main Quests, Daily Briefs, Weekly
Commissions, authored events, and explicit service compensation. The repeatable quest economy
follows §12.2.2: normal weekly output is approximately 5–10 for casual participation, 12–20 for a
regular player, and 22–28 for a highly engaged player; 30–35 is reserved for exceptional event
weeks.

Luxe Credits may purchase cosmetics, presentation treatments, selected collection content, House
Pass access where platform policy permits, and other products that obey this section. Luxe Credits
may not purchase ranked attempts, Gala votes, Hype, market share, sales multipliers, idle multipliers,
crisis outcomes, stronger staff, exclusive forecasts, or immunity from economic risk.

Catalogue pacing targets are:

| Premium value tier | Free-player acquisition target |
|---|---:|
| Small accessory, frame, or presentation treatment | 3–4 engaged weeks |
| Standard outfit, HQ treatment, or collection item | 6–8 engaged weeks |
| Premium animated or high-production item | 12–16 engaged weeks |
| Complete seasonal collection | Not fully obtainable from one free reward cycle |

The catalogue must release desirable optional content faster than a free player can collect all of
it while still allowing deliberate saving to produce meaningful purchases. Currency balance does
not change prices, quest difficulty, odds, or offer quality. Premium-currency sinks are reviewed for
clarity and value; intentional confusion, excessive currency fragmentation, and near-miss pricing are
prohibited.

### 17.3 Launch monetization stack

#### 17.3.1 Luxe Credits and premium catalogue

The base premium catalogue contains founder and avatar presentation, Luxe outfits, HQ themes, Feed
frames, Atelier and garment visual effects, Vex card treatments, runway presentation, Archive
layouts, and Icon Editions. Icon Editions remain presentation-only as defined in §15.3.

A clearly labelled first-purchase Founder Pack may offer a favourable fixed bundle of Luxe Credits,
a permanent Founder profile treatment, one Creative Studio sample pack, and one declared cosmetic
set. It provides no exclusive gameplay role, economy modifier, competitive advantage, or permanent
progression multiplier. A player who never buys the Founder Pack loses no mechanic or story access.

#### 17.3.2 House Pass

The **House Pass** is the primary seasonal product and normally runs for eight weeks. Progress comes
from ordinary play, Luxe Quests, authored seasonal objectives, and eligible event participation.
Purchasing the pass never creates purchase-only quests and retroactively grants earned premium-track
rewards for the active season.

The free track may contain House Funds, materials, Aurelian Seals, bounded Luxe Credits, Story Archive
entries, and standard collection rewards. The premium track may contain an additional authored side
story, extra Luxe commissions, premium presentation and collection rewards, bounded Luxe Credits,
unranked scenario access, Creative Studio trial access, and House-history collectibles.

The premium track never grants Hype points, market share, superior demand, stronger staff, improved
idle settlement, additional Gala entries, higher competitive ceilings, or exclusive strategic
archetypes. Paid tier skips, when offered, advance reward-track position only; they do not complete
Main Quests, narrative decisions, ranked objectives, or skill-based challenges.

#### 17.3.3 Creative Studio Pro

**Creative Studio Pro** is a durable Artisan-oriented utility unlock. It may provide:

- additional saved garment drafts, private folders, mood boards, and collection workspaces;
- advanced lookbook, brand-book, and runway-presentation builders;
- high-resolution still export and short presentation-video export;
- collection comparison, historical design search, and additional staging configurations;
- additional noncompetitive presentation templates and private organization tools.

It does not modify Hype components, reveal a higher-confidence score projection than the best free
progression-equivalent tool, provide exclusive materials with gameplay effects, or bypass production
cost, time, quality, or audience tradeoffs. Free accounts retain enough draft capacity and export
ability to complete every gameplay role and share a basic presentation.

#### 17.3.4 Operations Suite

**Operations Suite** is a durable Architect-oriented utility unlock. It may provide:

- additional saved automation-policy presets and dashboard configurations;
- bulk inventory actions that submit the same validated individual intents;
- expanded transaction-history filters and longer private analytics retention;
- scheduled noncompetitive reports and additional notification controls;
- additional store-layout templates and side-by-side comparison views;
- automatic collection of already-completed non-choice rewards.

It reorganizes existing information and reduces repetitive administration. It may not reveal secret
demand data, improve forecast accuracy beyond free progression, increase settlement efficiency,
remove automation drawbacks, create superior policies, or execute an irreversible choice without
confirmation.

#### 17.3.5 Additional House slot

Every account receives one main House. Aurelian Ascension unlocks one parallel New House run without
purchase. At launch, the player may purchase one additional House slot for an independent brand and
economy. Additional slots permit experimentation with another identity, city posture, and path
strategy; they do not transfer currency, inventory, Hype, Market Share, quest progress, or ranked
advantage to another House.

Purchased slots are durable and restorable. Deleting a House requires an explicit confirmation and
recovery window. Cross-House cosmetics and Archive identity may be shared where declared, but
economic state remains isolated. Daily Brief, Weekly Commission, House Pass, event, and repeatable
Luxe Credit caps are account-level rather than multiplied by the number of Houses. A Main Quest may
track House-specific progression, but repeatable premium rewards cannot be farmed by switching Houses.

### 17.4 Post-retention monetization

The following products launch only after retention, economy health, competitive parity, and player
comprehension meet documented gates.

#### 17.4.1 Founder Club

**Founder Club** is an optional monthly subscription that provides continuing content and utility.
It may include:

- one monthly side story or rotating unranked scenario;
- a bounded monthly Luxe Credit grant;
- one additional House slot while subscribed;
- additional draft storage, private Archive organization, and automation-preset capacity;
- expanded lookbook and report exports;
- access to a rotating archive of previous unranked events;
- one additional free Daily Brief reroll;
- removal of optional rewarded-ad prompts where advertising is active.

It never provides sales, Hype, idle, valuation, market-share, Gala, staff, or ranked multipliers.
Subscription lapse never deletes designs, Houses, Archive records, or reports. Existing content above
the free creation cap becomes read-only until capacity is reduced or access resumes; the player is
warned before renewal and before any access-state change. A House occupying the subscription-only
slot is preserved but paused from simulation and offline accrual until the slot is restored or the
player moves that House into an available durable slot.

#### 17.4.2 Narrative expansion packs

Paid narrative expansions are self-contained optional campaigns built around Luxe, Vex, rival
houses, cities, collaborations, or crises. Each pack may include authored scenes, new decisions,
special economic scenarios, environments, Archive entries, and unranked challenge modes.

The free game contains a complete primary campaign and functional conclusion. An expansion may
continue or deepen a story but may not contain a missing resolution that the base game falsely
presents as included. Expansion decisions may affect that expansion's Archive and presentation;
they cannot buy a better outcome in shared competitive systems.

#### 17.4.3 Premium scenario packs

Scenario packs are replayable, isolated tycoon challenges with declared starting resources, rules,
objectives, constraints, and scoring. Examples include rescuing a failing couture house, entering a
new city with limited capital, surviving a supply-chain collapse, recovering from a plagiarism
crisis, or building an ethical brand under strict cost limits.

Paid scenarios do not modify the main House economy. Their leaderboards are separate, normalized,
or periodically available through free rotation so purchase does not control the central competitive
identity of the game.

#### 17.4.4 Optional rewarded advertising

There are no interstitial advertisements at launch. Rewarded advertising remains deferred until a
post-launch review demonstrates that it can be added without degrading retention, pacing, trust, or
purchase value.

When enabled, a player may voluntarily view no more than three meaningful rewarded ads per account
day for bounded rewards such as one additional Daily Brief reroll, a small House Funds grant, one
quest replacement, a temporary Creative Studio trial, or one additional unranked scenario attempt.
Advertisements never double offline earnings, grant Luxe Credits as a routine source, modify Hype,
Market Share, crises, Gala entries, votes, score, or ranked rewards. Refusing or disabling ads does
not slow the baseline economy or trigger repeated prompts.

### 17.5 Later-stage products and partnerships

#### 17.5.1 Licensed collaborations

Licensed fashion, entertainment, music, or cultural collaborations may fund or sell an optional
branded narrative event, design brief, unranked challenge, NPC appearance, Feed storyline, or
expanded event pass. Sponsorship is clearly disclosed. Branded content receives no hidden Hype,
Gala, demand, or Feed-ranking advantage, and the player can continue normal progression without
participating.

Licensed items disclose whether and when they can return. Contractually limited availability is
not described as permanent player ownership unless the entitlement is genuinely durable.

#### 17.5.2 Creator marketplace

A player-creator marketplace is deferred until moderation, intellectual-property handling, fraud
prevention, age controls, tax and payout obligations, reporting, customer support, and secure
settlement are validated. Approved creator goods may include presentation templates, boutique
layouts, lookbook formats, runway scenes, brand-profile layouts, and other non-authoritative assets.

The initial marketplace uses controlled Luxe Credit transactions and platform-approved settlement.
The studio may retain a disclosed transaction fee. Creator content cannot modify gameplay formulas,
contain unreviewed executable behavior, impersonate official rewards, or introduce paid competitive
power. Real-money creator cash-out is a separate later decision and is not implied by launch scope.

#### 17.5.3 Large narrative seasons

Large narrative seasons may be sold as premium content after the base campaign and smaller expansion
model prove sustainable. Each season declares included chapters, playable systems, duration, and
whether access is permanent or time-bound. Core technical fixes, accessibility support, balance
updates, and required story continuity are never paywalled as seasonal content.

### 17.6 Storefront, offers, and player protection

The storefront may use direct purchases, Luxe Credit packs, the House Pass, clear bundles, and a
single first-purchase offer. Offers are grouped by player goal rather than obscured behind multiple
currencies. A bundle displays the normal price and contents of every included item; percentage value
claims use a real, currently available comparison.

Ordinary first-party rotating items return on a disclosed cadence. Limited licensed items are marked
as such. There are no fake countdowns, false scarcity, surprise price increases, loot boxes required
for progression, purchase-gated quests, negative-balance offers, or prices personalized according to
spending vulnerability. Earned quest milestones may occasionally unlock a disclosed discount, but
the quest remains complete and fully rewarded without purchase.

Random cosmetic acquisition, if retained for Icon Editions, follows the published pity and duplicate
rules in §15.3. Direct purchase alternatives are preferred for major collections. Premium purchases
never appear as the only solution to a stockout, failed crisis, lost Gala entry, or inefficient
operation.

### 17.7 Monetization review gates

Before launch and each material economy update, product, economy, analytics, QA, and trust review:

- free Luxe Credit issuance, balances, sinks, and time-to-desired-item distribution;
- House Pass completion for free and premium players without paid skips;
- payer versus nonpayer Hype, Market Share, Gala placement, idle efficiency, and progression speed;
- subscription retention, lapse behavior, entitlement restoration, refunds, and duplicate grants;
- storefront comprehension, accidental-purchase rate, offer exposure, and refund complaints;
- catalogue release rate versus free earning rate and currency stockpiling;
- conversion by product without targeting financial distress, repeated loss, or emotional story beats;
- whether Creative Studio Pro and Operations Suite remain utilities rather than strategic power;
- whether paid scenarios, Houses, and expansions remain economically isolated where specified.

No monetization product ships when it creates a statistically or mechanically superior competitive
ceiling, a required purchase for core progression, an unclear entitlement, or a material reduction
in the quality of the unpaid game.

## 18. UI/UX, Accessibility, and Performance

### 18.1 Binding UI/UX authority

All UI/UX design and implementation for The Styliste must follow the repository’s
`frontend-design` skill together with the established Flutter design system. The skill
governs visual direction, hierarchy, typography, composition, interaction states, motion,
accessibility, mobile ergonomics, and anti-generic design standards.

The skill is the primary UI/UX design methodology for this GDD. It must improve, not
replace, the repository’s Flutter architecture, Riverpod patterns, Aurelian visual
identity, portrait-first layout, accessibility requirements, 60 fps target, and low-end
Android fallbacks. No new font, color, effect, spacing rule, icon convention, navigation
pattern, or component family is valid until integrated into the existing token system.

Every major interface has a clear aesthetic concept, one dominant player goal, a primary
action, and an explicit information hierarchy. Every screen defines loading, empty, error,
disabled, offline, unavailable, success, reconnect, and destructive-confirmation states.
Every gameplay result communicates what happened, why it happened, what changed, who
reacted, and what the player can do next. Monetization is visually secondary to gameplay.

Artisan and Architect have distinct visual identities within one coherent brand system:
Artisan emphasizes tactile material, silhouette, authorship, and editorial reveal;
Architect emphasizes spatial planning, operational movement, ledger clarity, supply flow,
and controlled decision density. Both use the existing Aurelian palette, typography,
spacing, surfaces, buttons, cards, modals, navigation, motion, and accessibility conventions.

For solo development, UI completion means a small reusable system works across several
features. A unique one-off screen, duplicated component, or visually polished mockup that
cannot support loading, error, accessibility, and low-device states is not complete.

### 18.2 Navigation and information architecture

The canonical portrait-first shell uses no more than five primary destinations:

| Primary destination | Player question | Required contents |
|---|---|---|
| **HQ** | What needs my attention now? | Luxe, Main Quest, urgent issue, recent result, essential resources, current opportunity, and one recommended action |
| **Atelier** | What am I creating or revising? | Garment creation, collections, design versions, revisions, materials, and Artisan progression |
| **Empire** | How is the business operating? | Stores, production, inventory, suppliers, staff, routes, finances, contracts, and Architect progression |
| **Feed** | How is the world reacting and changing? | Customers, critics, rivals, trends, opportunities, public consequences, Gala notices, and later social activity |
| **House** | Who are we and what have we built? | Founder profile, House identity, Story Archive, achievements, settings, staff overview, and later Maison membership |

No major system receives a permanent bottom-navigation tab solely because it exists.
Quests, Gala, contracts, territory, store market, staff, automation, crises, subscriptions,
Ascension, and Legacy Mandates open from the primary destination that best matches the
player's current intent.

| Contextual system | Canonical entry points |
|---|---|
| Luxe Quests | HQ through Luxe; direct deep link from relevant task |
| House While Away | HQ on return; permanent receipt in Empire/Ledger |
| Vex | Feed and result receipts; history in House Archive |
| Suppliers and buyers | Empire; opportunity cards in Feed |
| Monthly Gala | HQ when actionable; Feed for public event; House for past entries |
| Maisons | House; contextual project and contract links from Feed or Empire |
| Territory | Empire world map; urgent contest notices in HQ and Feed |
| Store market | Empire; qualified opportunity cards in Feed |
| Crises | HQ urgency card; affected system surface; Archive after resolution |
| Monetization | Storefront entry in House or contextual catalogue link; never primary navigation |
| Ascension and Legacy | House after eligibility; HQ only when a meaningful decision is pending |

Navigation requirements:

- the player can reach the current Main Quest action in no more than two intentional taps from HQ;
- system back behavior returns to the prior meaningful state rather than resetting the surface;
- deep links restore the correct tab, entity, filter, and scroll context;
- reconnect and process restoration preserve uncommitted local editing state where safe;
- badges communicate only actionable change and are rate-limited to prevent notification noise;
- future or disabled systems remain absent rather than showing dead navigation;
- promotional badges cannot visually outrank crises, completed work, expiring player-owned actions,
  or security/account notices;
- one-handed reach, safe areas, and thumb zones are tested on small and large phones.

### 18.3 Screen hierarchy and progressive disclosure

Every gameplay screen follows this priority unless a documented exception passes usability review:

1. **Current situation:** what is happening now.
2. **Primary decision or action:** what the player can do immediately.
3. **Projection or consequence:** what the major tradeoff is before commitment.
4. **Secondary information:** supporting values, history, comparisons, and alternatives.
5. **Optional depth:** advanced controls, formulas, audit details, and expert analysis.
6. **Commercial content:** relevant offers only after gameplay information.

Each screen normally presents one dominant primary CTA and no more than two visually competing
secondary CTAs. Additional actions use menus, expandable sections, or bottom sheets. Irreversible,
expensive, public, contractual, or premium actions require a confirmation that states the exact
cost, ownership, duration, affected systems, and cancellation or recovery behavior.

Complexity uses progressive disclosure:

- Casual presentation shows the decision, main tradeoff, recommended default, and consequence.
- Expert presentation may expose forecasts, distributions, component values, history, and policies.
- Expanding detail never changes the authoritative outcome or unlocks paid strategic information.
- Important warnings are written in plain language and do not rely only on color or iconography.
- Tables and dense ledgers remain scrollable, filterable, and secondary to visual operating feedback.
- The current objective, resource at risk, and next valid action remain visible or one tap away.

A screen is rejected when players must inspect several panels to identify the main problem, when
multiple highlighted actions compete for attention, or when cosmetic motion obscures the causal
relationship between action and result.

### 18.4 Reusable component system

The IDE agent must compose screens from reviewed reusable components. Components are tokenized,
accessible, state-complete, and independently testable. The minimum library is:

**Foundation and navigation**

- `AurelianScaffold`
- primary tab shell and contextual app bar
- section header and breadcrumb/context label
- responsive safe-area container
- tokenized divider, surface, badge, chip, tooltip, and icon button

**Actions and decisions**

- primary, secondary, tertiary, destructive, and disabled buttons
- decision comparison card
- tradeoff indicator
- projected-outcome panel
- cost and ownership confirmation sheet
- choice receipt and undo/recovery notice

**Progress and resources**

- currency and resource display
- objective card
- progress meter
- rank/mastery receipt
- stat-change receipt
- timer with absolute reset or expiry time
- capacity, stock, workload, and risk indicators

**Fashion and world response**

- garment preview card
- material/palette swatch control
- garment-zone selector
- version comparison viewer
- customer reaction card
- Vex critique card
- Luxe guidance and briefing card
- Feed opportunity and consequence card

**Architect operations**

- store-performance card
- inventory row
- demand segment card
- supplier/buyer relationship card
- route and shipment status card
- contract summary card
- incident and bottleneck card
- before/after intervention comparison

**System and reliability states**

- loading skeleton
- empty-state action panel
- offline and reconnect state
- permission or eligibility state
- inline validation and error summary
- retry state
- completed/settled receipt
- feature-disabled state for internal builds only

Every component declares:

- purpose and prohibited use;
- visual and semantic variants;
- required data and ownership state;
- loading, empty, error, disabled, offline, success, and reduced-motion behavior;
- keyboard/focus and screen-reader order;
- localization and text-scaling behavior;
- performance budget and image/animation limits;
- analytics events when interaction is meaningful;
- golden, widget, accessibility, and state tests where applicable.

The IDE agent may not create a second component that duplicates an existing component with minor
styling differences. A new component requires evidence that composition or an approved variant cannot
satisfy the use case.

### 18.5 Luxe interface behavior

Luxe is the primary assistant and mascot, not a permanent modal, advertisement host, or automatic
player. Luxe appears in four interface modes:

1. **Ambient:** a small HQ presence that acknowledges meaningful change without blocking input.
2. **Guidance:** contextual FTUE, unfamiliar-system, recovery, and accessibility assistance.
3. **Briefing:** Main Quests, Daily Briefs, Weekly Commissions, House While Away, crises, and major
   opportunities.
4. **Ask Luxe:** player-initiated explanations of the current decision, cause, risk, or next action.

Luxe behavior requirements:

- Luxe never covers the active garment, primary CTA, critical value, contract term, or error message.
- Noncritical Luxe prompts collapse, snooze, or dismiss without reward loss.
- Luxe uses an interruption budget: no repeated full-screen appearance for minor actions and no
  dialogue after every tap.
- The player can switch among **Guide me**, **Brief me**, and **Let me work** at any time.
- Luxe remembers completed explanations so the same tutorial is not repeated unless requested.
- Luxe differentiates advice from authority and never implies that a recommendation is mandatory.
- Luxe cannot spend currency, change a design, accept a contract, submit a Gala entry, purchase an
  item, move inventory, or perform any irreversible action.
- Monetization mentions are contextual, factual, dismissible, and never delivered during failure,
  grief, account recovery, crisis pressure, or repeated loss.
- Reduced-motion and screen-reader modes preserve Luxe's meaning without requiring avatar animation.
- When Luxe is unavailable, all required information remains available in deterministic UI text.

### 18.6 Proof-of-fun core screens

The solo-developer proof-of-fun build prioritizes six screens. Later screens cannot displace these
until they pass task-based usability and performance gates.

#### 18.6.1 Sanctuary and Founder Trial

The FTUE supports House naming, founder intent, shared starter garment, miniature Artisan action,
miniature Architect action, customer and Vex response, targeted correction, path recommendation,
path selection, skip, resume, accessibility setup, and first Main Quest handoff. Meaningful input
occurs within 45 seconds; the Founder Trial targets 4–6 minutes; the first complete causal loop targets
8–12 minutes.

#### 18.6.2 HQ

HQ displays, in order:

1. Luxe and the current situation;
2. one Main Quest or urgent recovery action;
3. one recent result or unresolved consequence;
4. essential resources and capacity;
5. one recommended next action;
6. secondary alerts and optional navigation;
7. promotional content last, if any.

HQ is not a complete analytics dashboard. Detailed finance, inventory, Archive, and social history
belong to their contextual surfaces.

#### 18.6.3 Atelier

The garment remains the visual center. Editing categories occupy reachable lower controls; the
selected tool opens in a bottom sheet or compact inspector. Undo, redo, compare, save version,
projection, and safe commit remain consistently located. Advanced values are expandable. Luxe help
is available but collapsed. The interface supports direct or equivalent zone-level manipulation,
before/after comparison, visual validity warnings, and low-device fallbacks without surrounding the
garment with permanent toolbars.

#### 18.6.4 Empire store operation

The first store visually answers:

- Are customers entering?
- Which segment is responding?
- What is selling or failing to sell?
- What is out of stock or overstocked?
- Where is money or time being lost?
- Which intervention is available now?

Customer movement, stock state, bottlenecks, and before/after changes appear before detailed ledger
tables. A player can diagnose and perform one meaningful intervention in a short session.

#### 18.6.5 Release result and reaction

A release result displays:

1. overall outcome;
2. units, margin, Hype, loyalty, reputation, and relevant progression changes;
3. the main positive and negative causes;
4. bounded customer reactions;
5. Vex evidence-based critique when eligible;
6. Luxe's concise summary;
7. revise, reposition, recover, or continue actions.

The result remains available as a permanent receipt. Celebration never delays access to critical
information or the next action.

#### 18.6.6 House While Away

The return surface shows time simulated, revenue, costs, units sold, inventory change, stockouts,
automation actions, bottlenecks, material world developments, and one recommended intervention. It is
skippable, never doubles rewards through mandatory advertising, and links to the complete immutable
settlement in Empire/Ledger.

### 18.7 Path-specific visual and interaction language

**Artisan surfaces** feel tactile, editorial, spacious, material-focused, and author-led. They use
large garment previews, direct manipulation, fabric and construction detail, version comparisons,
and restrained numerical density. Projection and scoring support creative judgment rather than
replacing it.

**Architect surfaces** feel precise, controlled, operational, and visibly alive. They use customer
flows, demand maps, inventory motion, routes, store layouts, negotiations, financial deltas, and
before/after intervention evidence. They do not become spreadsheet-only interfaces or repetitive
claim screens.

The shared Aurelian system ensures that switching paths does not feel like entering a different app.
Common components, gestures, confirmation patterns, result receipts, and Luxe behavior remain
consistent while composition and information density adapt to the fantasy.

### 18.8 Surface evaluation

The frontend-design audit covers these required surfaces:

- **Luxe-led FTUE:** a cinematic Aurelian Sanctuary opening with meaningful input within 45
  seconds, a 4–6 minute Founder Trial, a complete first causal loop within 8–12 minutes,
  Guide me/Brief me/Let me work assistance modes, Ask Luxe, reachable thumb-zone actions,
  resumable server-owned tutorial state, dialogue skip without decision loss, path-comprehension
  confirmation, accessibility controls before animation, safe failure, and no monetization or
  competitive pressure before the loop completes.
- **Atelier:** an editorial workbench with zone-level proportion, material, palette, pattern,
  construction-detail, comparison, branching revision, tactile cloth feedback, visible tradeoffs,
  server projection, safe commit, and a simplified visual fallback.
- **Ledger and Operations:** a calm, high-legibility financial record connected to visual stores,
  customer flow, demand maps, warehouses, routes, negotiations, renovations, and incident response;
  explainable deltas, actionable first-store empty state, loading/error/offline handling, and no
  decorative treatment that obscures values.
- **HQ:** the strategic home with immediate gameplay information first, current objective second,
  resources and alerts next, navigation after that, and promotional information last.
- **House While Away:** a skippable offline receipt with time simulated, profit, inventory,
  bottlenecks, automation actions, important world developments, comparison, and linked next actions;
  detailed settlement remains available in the Ledger.
- **Feed:** a fashion-editorial consequence wall where every actionable card names the opportunity
  and next move; authored NPC activity prevents an empty first week.
- **Luxe:** a character-led assistant and relationship presentation where history,
  recommendations, House While Away reports, and consequence are legible.
- **Luxe Quests:** an editorial brief board for Main Quests, Daily Briefs, and Weekly Commissions with
  exact progress, rewards, reset time, reroll state, direct action links, completion receipts, and no
  storefront-first treatment.
- **Storefront:** a secondary, calm catalogue organized by expression, content, creative tools,
  management tools, and replayability; every product shows price, entitlement type, duration,
  contents, restoration behavior, and competitive-power exclusion before purchase.
- **House Pass:** a season overview with free and premium tracks, retroactive premium claims, exact
  remaining time, no purchase-only objectives, and clear separation from Main Quest progress.
- **Founder Club:** a subscription explanation with continuing monthly value, renewal date, lapse
  behavior, restore controls, and no gameplay-multiplier claims.
- **Vex:** an editorial critic card with evidence, opinion history, and clear separation between
  authoritative classification and optional prose.
- **Crises:** focused evidence and decision framing, explicit stakes, no double-submit,
  expired/offline/error states, and a permanent consequence receipt.
- **Maisons:** recruitment, application, roles, permissions, contribution ledger, headquarters,
  projects, roster locks, governance, safety controls, and clear personal-versus-shared ownership.
- **Territory:** district forecast, declaration, preparation, response, settlement, control, upkeep,
  influence decay, protected districts, bounded benefits, and no surprise loss state.
- **Store Market:** valuation explanation, liabilities, escrow, lease or franchise terms, ownership
  history, cooldowns, two-person Maison approval, fraud holds, and safe cancellation states.
- **Messaging:** Maison, recruitment, contract, and bounded direct-message surfaces with mute, block,
  report, privacy, rate-limit, and enforcement states.
- **Gala:** a monthly runway event with House and Maison tracks, divisions, standardized resources,
  submission lock, anonymous judging, community comparison, integrity review, Crown Final, automatic
  reward settlement, score breakdown, and Archive result.

### 18.9 Interaction, motion, accessibility, and localization

Use existing Flutter and Riverpod architecture, semantic labels, logical traversal order,
visible focus, non-color state indicators, sufficient contrast, scalable text, minimum
touch targets, safe areas, left- and right-handed ergonomics, localization-safe layouts,
captions or alternatives for meaningful audio, reduced motion, and reduced transparency
where supported.

Motion communicates selection, causality, hierarchy, success, error, and high-value reveals. It uses
existing Flutter animation APIs and tokenized duration/easing. It never blocks input, hides a loading
delay, or becomes the only evidence that state changed. Reduced motion preserves meaning through
instant state changes and concise feedback. Reward animation remains skippable after critical
information is visible.

Accessibility controls are available before the FTUE cinematic. Text scaling, screen-reader use,
color-vision differences, motor limitations, hearing differences, reduced motion, reduced
transparency, and one-handed play are tested on the core screens. Garment controls provide an
equivalent precise alternative to gestures. Charts and maps include textual summaries. Timed actions
show absolute expiry and provide appropriate accommodations where competition integrity permits.

### 18.10 Performance contract

The target is 60 fps with an approximately 16.7 ms frame budget. The Samsung Galaxy A55 is the primary
reference device, with at least one materially weaker Android test profile. Profile or release-mode
evidence is required before a performance claim. Lower-end devices use reduced cloth nodes, static
Feed garment previews, simplified particles, reduced blur, lower preview resolution, limited
background motion, and shader fallbacks.

No live cloth simulation runs on every Feed card; no large animated blur layer runs during active
interaction; network activity never blocks touch feedback; and scrolling lists do not render
unbounded animated media. Animation complexity is proportional to device performance, battery,
thermal cost, and screen importance.

Visual effects are isolated and profiled; image cache dimensions are bounded; expensive painting and
decoding are not repeated in `build`; controllers and listeners are disposed; list virtualization is
used; and large state changes are partitioned to avoid unnecessary rebuilds. No second design system
or package is introduced when the existing stack can solve the problem.

Each proof-of-fun screen has a measured frame, memory, startup, image, and network budget. A screen
that meets visual review but stutters, overheats, exhausts memory, or delays input on the target
profile does not pass.

### 18.11 Phase-specific UI delivery

#### Early Game / FTUE

Build and polish only:

- token system and five-destination shell;
- reusable foundation, decision, result, Luxe, garment, store, and reliability components;
- Sanctuary/Founder Trial;
- HQ;
- Atelier;
- first Empire store;
- release result;
- House While Away;
- basic Feed and House identity/Archive surfaces;
- complete accessibility, offline, error, and low-device states for those surfaces.

No full social, territory, marketplace, subscription, or End Game screen is produced during this
wave. Wireframes may document future routing, but production UI waits for the matching feature gate.

#### Alpha

Add quests, supplier and buyer relationships, staff, automation, collection management, campaign and
multi-store views, Vex history, richer Feed filters, city-entry presentation, content-authoring
support surfaces, and improved operational analytics. Alpha must first stabilize the component
library rather than creating screen-specific variants.

#### Beta

Add public profiles, friends, leaderboards, individual monthly Gala, limited collaboration contracts,
and basic Maison surfaces only after the corresponding authorization, moderation, and population
gates pass. Social interfaces must include block, report, privacy, loading, empty, and enforcement
states from their first enabled build.

#### Late Game

Add multi-city command, advanced logistics, territory, store market, franchise, Maison governance,
advanced finance, and live-event operations only after core navigation and information density remain
usable with real accumulated accounts.

#### End Game

Add Ascension, Legacy Mandates, Hall of Sovereigns, historical empire comparison, and mature Archive
navigation. End Game interfaces emphasize identity and history rather than presenting only larger
numbers.

### 18.12 Usability and UI release gates

Before a wave is promoted, representative players must complete the following without developer
instruction:

- enter and complete or safely resume the FTUE;
- explain the Artisan and Architect difference after the Founder Trial;
- create, save, revise, and release a garment;
- diagnose one struggling store and perform a meaningful intervention;
- understand why a result occurred and identify the next action;
- find the current Main Quest from any primary destination;
- understand the House While Away receipt;
- recover from offline, loading, validation, and server-error states;
- increase text size and complete the core loop;
- use reduced motion and receive equivalent information;
- navigate the core loop comfortably with one hand;
- distinguish gameplay, social, and commercial content;
- dismiss or reduce Luxe guidance without losing required information.

Required measures include task completion, time on task, backtracking, wrong-action rate, abandonment,
error recovery, Ask Luxe use, guidance dismissal, screen-reader completion, text-overflow defects,
frame-time distribution, memory, crash-free sessions, and qualitative comprehension. Analytics may
identify friction but may not replace observed usability testing.

Release is blocked when:

- fewer than the approved test threshold complete a core task without outside explanation;
- players routinely miss the primary CTA or cannot explain the main tradeoff;
- Luxe is perceived as obstructive, repetitive, or commercial pressure;
- the Atelier or store interface requires precision unavailable on the target phone;
- increased text size hides actions or values;
- important state depends only on color, animation, or audio;
- a screen introduces a new pattern when an approved component would suffice;
- later-wave UI development delays correction of a failed Early Game core screen.

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
| Luxe quests and rewards | PostgreSQL quest assignment, progress, reset, and reward functions | Display Luxe framing, progress, and claim receipt |
| Idle settlement and return receipt | PostgreSQL settlement plus immutable receipt | Display receipt and linked actions |
| Staff automation and policies | PostgreSQL policy state and settlement functions | Configure policy and render audit trail |
| Feed actions/followers | RLS plus idempotent RPC or Edge orchestration | Request action and show status |
| Maison membership, roles, and governance | PostgreSQL membership state, permission functions, roster locks, and audit ledger | Request actions and render confirmed state |
| Maison treasury and shared projects | Transactional PostgreSQL functions with approval thresholds and contribution ledger | Preview, approve, contribute, and display receipts |
| Player contracts and revenue splits | Versioned contract records plus transactional settlement functions | Negotiate terms, confirm identical version, and display settlement |
| Store market, leasing, and franchising | Valuation service, escrow transactions, ownership history, and anti-fraud review | List, bid, accept, cancel, and render verified terms |
| Territory declaration and settlement | Server event state, frozen district rules, influence ledger, and scheduled settlement | Submit eligible strategy and display forecast/result |
| Messaging and moderation | Authorized conversation membership, rate limits, filtering, reports, blocks, and moderation storage | Compose, read, block, mute, report, and show enforcement state |
| Event entries and votes | Event settlement functions | Submit eligible entry/vote |
| Monthly Gala scoring and rewards | Frozen monthly rule version, standardized event instance, integrity review, settlement, and automatic reward ledger | Create, preview, lock, vote, and display breakdown |
| Market share | PostgreSQL settlement | Display confirmed share |
| Purchases and talent ownership | Receipt verification service and database | Start purchase and restore |
| House Pass and seasonal entitlements | Receipt verification plus season entitlement tables | Display tracks, progress, and claims |
| Subscriptions and lapse state | Platform subscription status plus server entitlement service | Display status, renewal, and read-only fallback |
| House slots and paid content ownership | Server entitlement and isolated House records | Create or select an entitled House |
| Creator marketplace transactions | Moderated catalogue plus server settlement and audit ledger | Browse, purchase, report, and render approved assets |
| Crisis and rival state | Server event state and immutable timestamps | Render choices and history |
| NPC identity, taste, goals, memory, and relationships | PostgreSQL NPC state and versioned rules | Render profile, evidence, and reactions |
| NPC demand, contracts, purchases, bids, and actions | PostgreSQL settlement or trusted orchestration | Submit player response and display result |
| AI-generated dialogue and commentary | Non-authoritative trusted presentation service | Display labelled prose with fallback and report controls |

### 19.3 NPC simulation and AI presentation architecture

Authoritative NPC state is stored in PostgreSQL and advanced through versioned rules, scheduled
simulation jobs, transactional functions, or trusted Edge Function orchestration. The client renders
NPC state and submits player intents; it does not choose NPC outcomes.

The AI presentation pipeline receives a minimal structured payload containing approved character
identity, tone, relevant design or event factors, relationship evidence, knowledge boundary, locale,
length limit, and permitted response type. It returns presentation text only. The trusted service:

- validates grounding identifiers and rejects missing or conflicting state;
- selects an authored template fallback before calling an external model;
- uses prompt-template and model versioning;
- applies pre-generation and post-generation safety checks;
- prevents tool access, arbitrary database queries, secret access, and cross-player data leakage;
- caches and deduplicates safe results;
- applies cost, latency, frequency, and per-account budgets;
- records trace metadata sufficient for QA, appeal, and rollback;
- supports feature flags, model rollback, regional disablement, and full no-AI operation.

NPC planners may rank eligible actions, but every proposed action passes the same server validation,
resource, cooldown, contract, visibility, and anti-cheat checks as an equivalent player intent. A
planner cannot create currency, inventory, evidence, relationship history, bids, territory strength,
or event eligibility.

### 19.4 Security objective, threat model, and non-negotiable boundary

The security objective is **high-assurance defense in depth**, not the impossible claim that an
internet-connected service can never be compromised. The product must assume that mobile clients can
be modified, requests can be replayed, tokens can be stolen, devices can be rooted, traffic can be
scripted, dependencies can contain vulnerabilities, staff accounts can be targeted, and mistakes can
occur. No single control—including RLS—is treated as sufficient.

The required security posture is:

- prevent unauthorized access by default and fail closed;
- minimize the data and privileges available to every client, service, employee, and process;
- make all valuable state server-authoritative and transactionally verifiable;
- detect suspicious behavior quickly and contain it before it spreads;
- preserve an immutable record sufficient to reconstruct economic and administrative actions;
- restore safely from destructive bugs, compromised credentials, or malicious mutations;
- protect one player's private information from every other player without exception;
- expose only explicitly public or relationship-scoped projections required by gameplay;
- require independent security review before public multiplayer, premium currency, trading, or DMs.

The threat model explicitly includes:

- broken object-level authorization, IDOR, and cross-player row access;
- modified clients, memory editors, request tampering, fake clocks, and spoofed totals;
- premium-currency minting, duplicate reward claims, forged receipts, refund abuse, and ledger edits;
- replayed RPCs, race conditions, double spending, auction manipulation, and inventory duplication;
- SQL injection, unsafe dynamic SQL, insecure functions, exposed views, and overly broad grants;
- leaked publishable, secret, service-role, database, signing, webhook, or third-party credentials;
- session theft, credential stuffing, account takeover, recovery abuse, and malicious device farms;
- Sybil accounts, collusion, vote manipulation, store-transfer laundering, and off-platform trading;
- unauthorized Storage enumeration, malicious uploads, oversized files, and content-policy evasion;
- Realtime channel leakage, unauthorized subscriptions, and hidden data in broadcast payloads;
- privilege escalation through moderator, support, developer, CI/CD, or Supabase organization access;
- dependency compromise, malicious build artifacts, secret leakage, and unsigned production changes;
- denial-of-service, automated scraping, spam, expensive-query abuse, and AI-cost exhaustion;
- accidental deletion, broken migrations, corrupted settlement rules, and compromised backups.

### 19.5 Data classification and schema isolation

Player data is separated by purpose and access class. A broad `profiles` table containing both public
and private information is prohibited.

| Class | Examples | Player access rule |
|---|---|---|
| **Private player data** | email-linked application state, settings, device/session preferences, private inventory details, private drafts, wallet history, moderation reports, support records | Only the owning player through narrowly authorized interfaces; no other player may select, infer, subscribe to, or mutate it |
| **Public projection** | display name, approved avatar, House name, public biography, public garments, public achievements | Read-only projection containing explicitly approved fields; never a direct view of the private account row |
| **Relationship-scoped data** | DMs, contracts, Maison rooms, shared projects, private draft reviews | Only confirmed participants with current authorization; removal or blocking revokes future access immediately |
| **Competitive public data** | leaderboard position, Gala entry, territory result, public store listing | Only frozen, minimal settlement projections; no hidden economy, identity, device, fraud, or private profile fields |
| **Administrative data** | fraud signals, moderation evidence, audit events, security incidents, support notes | No player access; access limited to separately authenticated authorized staff and fully audited |
| **Secret system data** | service keys, signing material, webhook secrets, provider credentials, internal risk rules | Never stored in exposed schemas, client bundles, analytics, logs, or user-readable errors |

The canonical database layout uses:

- an exposed `api` schema containing only reviewed tables, safe projections, and RPC entry points;
- one or more unexposed `private`, `security`, `ledger`, `moderation`, and `ops` schemas for authoritative
  data and privileged helpers;
- Supabase-managed `auth` and `storage` schemas without broad custom access;
- explicit Data API schema exposure and explicit `GRANT` statements in the same migration as RLS;
- `REVOKE ALL ... FROM PUBLIC, anon, authenticated` as the starting posture for new objects;
- no production table becoming accessible merely because it exists in `public` or was created by a
  migration tool.

A player's raw private profile is never used as the public profile. Public fields are copied or
projected through a reviewed allowlist. Private columns must remain private even when the player has a
public House, participates in a Maison, lists a store, enters the Gala, or appears on a leaderboard.

Authorized support or moderation access is an operational exception, not another player's access.
Such access requires a work reason, least-privilege role, strong authentication, expiration where
possible, and an immutable audit record.

### 19.6 RLS constitution

RLS is mandatory on every table in an exposed schema and is used as defense in depth on sensitive
private tables where practical. Each policy is written per operation and per role; blanket policies
such as “all authenticated users” are prohibited.

Required policy rules:

1. `TO authenticated` proves only that a token exists; every policy also proves ownership,
   membership, public status, or a specific server-controlled permission.
2. Owner policies use `(select auth.uid()) = user_id` or an equivalent indexed ownership key.
3. `UPDATE` policies include both `USING` and `WITH CHECK`; ownership columns cannot be reassigned by
   the client.
4. Direct client `INSERT`, `UPDATE`, or `DELETE` is denied for currency, inventory, rewards, scores,
   progression, contracts, store ownership, territory, purchases, entitlements, and moderation state.
5. Columns used in RLS predicates are indexed and policy performance is tested under production-scale
   row counts.
6. Authorization never trusts `raw_user_meta_data`, user-editable JWT metadata, request body roles, or
   client-supplied owner IDs. Server-controlled authorization data lives in `app_metadata` or
   authoritative role tables.
7. Views exposed to players use `security_invoker = true`, select only approved columns, and inherit
   the caller's RLS. Unreviewed or definer-rights views are revoked from `anon` and `authenticated`.
8. Table owners and privileged roles are not used by normal application paths. `FORCE ROW LEVEL
   SECURITY` is used where it strengthens the intended model and does not break trusted operations.
9. Anonymous access is denied unless a specific public feature has a documented need and abuse model.
10. Policies are simple, testable, named by intent, version-controlled, and accompanied by positive
    and negative tests for owner, stranger, former member, blocked user, moderator, and anonymous
    identities.

Canonical owner-only pattern:

```sql
alter table api.player_private enable row level security;
alter table api.player_private force row level security;

create policy player_private_select_own
on api.player_private
for select
to authenticated
using ((select auth.uid()) = user_id);

create policy player_private_update_own_safe_fields
on api.player_private
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);
```

The actual implementation additionally restricts updateable columns or routes updates through a
validated RPC. The policy above is a pattern, not permission to expose wallet, authority, role,
moderation, or progression columns.

Canonical relationship-scoped rule:

```text
A conversation, contract, Maison room, or shared project is readable only when a current,
non-revoked participant record exists for auth.uid(), the participant is not blocked from that
surface, and the requested row belongs to the same authorized parent object.
```

Membership checks that would create recursive RLS are implemented through a narrowly scoped helper in
an unexposed schema. Any genuinely necessary `SECURITY DEFINER` helper must:

- live outside exposed schemas;
- set a fixed safe `search_path`;
- validate `auth.uid()` and all object identifiers itself;
- return only a boolean or minimal result;
- avoid dynamic SQL where possible;
- have `EXECUTE` revoked from `PUBLIC` and granted only to required roles;
- be covered by explicit abuse and cross-tenant tests;
- never exist solely to silence a permission error.

### 19.7 Server-authoritative mutation boundary

The mobile client is considered untrusted. It may propose an intent but never submit an authoritative
balance, reward, elapsed duration, score, owner, price settlement, inventory result, vote weight, or
premium entitlement.

Every sensitive mutation must pass through one canonical PostgreSQL function or trusted Edge Function
that:

- derives the actor from the verified session rather than a body-supplied user ID;
- validates current ownership, membership, eligibility, rule version, resource availability, and
  cooldown;
- accepts an idempotency key and rejects duplicate or conflicting use;
- uses server time and immutable event/rule versions;
- acquires row or advisory locks where concurrent actions could double spend or transfer the same asset;
- changes all related rows in one transaction;
- writes an append-only audit/economic event before returning success;
- returns a server-generated receipt containing causes and resulting state;
- exposes generic public errors while recording detailed internal diagnostics securely.

Sensitive tables have no general client write policy. There is one current authority path per domain;
retired RPCs and duplicate settlement functions have execution revoked and are removed after migration
safety windows.

### 19.8 Currency, inventory, reward, and purchase integrity

House Funds, Luxe Credits, Aurelian Seals, inventory, rewards, and entitlements use append-only
transaction ledgers with immutable event IDs, actor, source, amount or asset delta, rule version,
idempotency key, timestamp, related object, and resulting balance or version.

Required invariants include:

- no negative balances unless a specifically modeled debt product permits them;
- no direct player update or delete on ledger events or authoritative balances;
- unique receipt, platform transaction, quest claim, event reward, and idempotency identifiers;
- atomic debit-and-credit settlement for trades, escrow, revenue splits, and refunds;
- compensating entries rather than rewriting history;
- balance reconciliation jobs comparing materialized balances with ledger totals;
- automatic quarantine of impossible grants, duplicate purchases, or balance discontinuities;
- purchase entitlement only after server-side verification with Apple or Google;
- webhook signatures verified from the raw body before processing;
- refund and chargeback state able to revoke unconsumed entitlements or create a controlled negative
  entitlement balance without corrupting unrelated progression;
- premium currency never accepted from client cache, local storage, push payload, or analytics event.

No general-purpose “set balance,” “grant item,” or “become owner” endpoint exists in production.
Administrative compensation uses a separate dual-controlled tool, reason code, bounded amount,
approval threshold, and immutable audit event.

### 19.9 Authentication, sessions, and account takeover protection

Supabase Auth is configured for high-assurance account protection:

- strong password requirements and leaked-password rejection where supported;
- CAPTCHA or equivalent bot protection on signup, sign-in, recovery, and other abused flows;
- tuned Auth rate limits and generic responses that do not reveal whether an account exists;
- PKCE-based sign-in flows where applicable;
- short-lived access tokens with rotated one-time refresh tokens;
- secure refresh-token storage using Android Keystore and iOS Keychain through an audited secure-storage
  implementation; tokens are never stored in plaintext preferences, logs, crash reports, or analytics;
- device/session management allowing players to inspect and revoke active sessions;
- session revocation after password reset, suspected takeover, moderation lock, or support-assisted
  recovery;
- reauthentication before email/password change, account deletion, recovery-factor change, high-value
  asset transfer, large treasury action, or other declared sensitive action;
- optional player MFA at launch, with strong encouragement after valuable assets are acquired;
- mandatory MFA and separate staff accounts for developers, owners, moderators, support agents, and
  anyone with production or Supabase organization access;
- AAL2 enforcement for privileged staff and for player actions designated high risk when the account
  has an enrolled second factor;
- no authorization decisions based on user-editable metadata.

Account recovery must favor ownership proof and safety over speed. Support cannot manually transfer an
account based only on a display name, screenshot, purchase claim, or knowledge of public profile data.

### 19.10 Edge Functions, RPCs, webhooks, and API hardening

Authenticated Edge Functions keep JWT verification enabled and operate with a user-scoped Supabase
client whenever possible so RLS remains active. A service/secret client is created only inside a narrow
trusted operation and never returned, serialized, logged, or reused in the mobile client.

Every Edge Function declares one auth mode:

- **user:** valid player JWT and caller-scoped authorization;
- **secret:** named server-to-server secret with a narrow purpose;
- **none:** only for a documented public health endpoint or signed external webhook whose provider
  signature is independently verified.

Additional requirements:

- validate request schema, content type, size, identifiers, enum values, and nesting depth;
- reject unknown fields on sensitive endpoints;
- use strict CORS rules for administrative web tools and never treat CORS as authorization;
- apply per-IP, per-account, per-device-risk, and per-object rate limits as appropriate;
- cap fan-out, recursion, payload size, runtime, database work, AI calls, and downstream requests;
- set statement timeouts and prevent unbounded scans or user-controlled sort/filter explosions;
- use parameterized SQL only; dynamic SQL requires a security review;
- verify webhook signatures and replay windows before parsing business fields;
- keep secrets in Supabase project secrets or an approved secrets manager, never source control;
- separate production, staging, and development secrets and rotate them on role change or suspected leak;
- return no stack trace, SQL text, secret, policy detail, internal identifier, or another player's data.

### 19.11 Realtime security

Realtime is treated as a data-distribution channel, not an authorization mechanism. A client may
subscribe only to rows already authorized through RLS or to a private channel whose membership is
verified server-side.

Requirements:

- no broad subscription to private player, wallet, inventory, DM, contract, moderation, or fraud tables;
- private channels for Maison rooms, conversations, contract negotiations, and staff tools;
- minimal payloads with public IDs and approved fields only;
- authorization rechecked after membership removal, blocking, account restriction, or role change;
- presence data limited to what the feature needs and never used to reveal hidden online status;
- rate limits and backpressure for reactions, typing indicators, presence, and broadcasts;
- no secret, email, device identifier, risk score, internal note, or raw private row in a Realtime event;
- reconnect cannot replay an action mutation; it may only refresh confirmed state.

### 19.12 Storage and user-generated asset security

All player uploads use private buckets by default. Public display uses reviewed derivatives or
short-lived signed URLs, not permanent access to original private files.

Storage policies enforce:

- path ownership derived from `auth.uid()` and server-created object records;
- upload eligibility, object ownership, Maison/contract sharing, and moderation state;
- explicit `SELECT`, `INSERT`, and `UPDATE` permissions required for upsert behavior;
- file count, size, MIME, extension, pixel dimensions, duration, and rate limits;
- server-side content-type verification rather than trusting the filename or client header;
- image transcoding and metadata stripping before public use;
- malware and unsafe-content scanning where the asset type requires it;
- randomized non-guessable object paths and no directory-listing behavior;
- deletion tombstones and moderation holds where legal or safety review requires retention;
- separation of private originals, moderated public derivatives, system assets, and staff evidence.

Database backup restoration does not by itself restore deleted Storage objects. Storage assets require
an independent backup and recovery plan matched to their importance.

### 19.13 Device integrity and anti-cheat risk scoring

Google Play Integrity, Apple App Attest or equivalent signals, emulator/root indicators, version
attestation, and request behavior may contribute to a server-side risk score. Device signals never
become the sole authorization control and never replace RLS, session validation, or economic
invariants.

Risk responses are graduated:

1. observe and increase logging;
2. require reauthentication or stronger verification;
3. rate-limit or disable high-risk trading, voting, messaging, or premium actions;
4. quarantine suspicious rewards or transfers for review;
5. restrict competitive participation;
6. suspend the account when evidence reaches the documented threshold.

The system avoids punishing legitimate players merely for device age, accessibility software, network
instability, or unsupported integrity signals. Every enforcement action has a reason code and appeal
path where appropriate.

### 19.14 Administrative and organizational security

Production access uses least privilege and separate identities:

- Supabase organization MFA is mandatory;
- no shared staff accounts;
- owner, developer, database, support, moderation, analytics, and billing access are separated;
- production database access is exceptional, time-bounded where possible, and logged;
- support and moderation tools expose only the fields required for the current case;
- staff cannot mint currency or transfer assets through raw SQL as a normal workflow;
- high-impact compensation, ban reversal, key rotation, migration, and restore actions require a
  second approver or documented break-glass process;
- break-glass credentials are offline, rotated after use, and trigger an incident review;
- development and staging use separate Supabase projects and synthetic or irreversibly sanitized data;
- production data is never copied to personal devices, chat systems, issue trackers, or test projects;
- departing staff lose Supabase, repository, CI/CD, secrets, analytics, and support access immediately.

Network restrictions are applied to direct database connections where supported. They are not treated
as protection for HTTPS Data, Auth, Storage, Realtime, or Edge APIs, which remain secured by their own
authorization controls.

### 19.15 Logging, detection, fraud response, and auditability

Security monitoring collects minimal, useful signals without logging passwords, tokens, secrets,
message bodies unnecessarily, or full sensitive payloads.

Alerting covers:

- abnormal Luxe Credit, seal, item, or entitlement issuance;
- duplicate or high-velocity claims and purchases;
- unusual RPC failure/success ratios and authorization denials;
- cross-account store, treasury, contract, or inventory movement patterns;
- linked-account voting, bidding, gifting, and reward concentration;
- impossible progression speed, clock behavior, version mismatch, or inventory creation;
- repeated access to nonexistent or unauthorized object IDs;
- sudden staff privilege changes or administrative data exports;
- secret use from unexpected environments;
- migration, policy, function, grant, or exposed-schema changes;
- Realtime subscription anomalies, message spam, upload abuse, and AI-cost spikes.

Economic and administrative audit events are append-only and retained according to a documented
policy. Security tooling can freeze a domain—premium grants, store transfers, Gala claims, DMs, or
all sensitive mutations—without taking the entire game offline.

### 19.16 Backups, disaster recovery, and continuity

Production requires tested recovery, not merely enabled backups.

- Use an appropriate paid Supabase plan with automatic daily database backups before public monetary
  or multiplayer release.
- Enable Point-in-Time Recovery when the value and volume of live economic state justify its cost.
- Maintain encrypted off-platform logical backups on a defined schedule for catastrophic provider or
  project loss scenarios.
- Back up critical Storage objects independently because database backups contain Storage metadata but
  not deleted object contents.
- Protect backup credentials separately from production runtime secrets.
- Run scheduled restore drills into an isolated project and record recovery time and recovery point
  evidence.
- Define recovery objectives for Auth-linked profile state, wallets, ledgers, purchases, contracts,
  messages, public assets, and moderation evidence.
- After restore, reconcile ledgers, entitlements, platform receipts, scheduled events, and Storage
  objects before reopening mutations.
- Never overwrite the only known-good environment during a recovery rehearsal.

### 19.17 Secure development lifecycle and release gates

Security is tested continuously, not added at launch.

Every schema or API change requires:

- migration review including explicit grants, RLS enablement, policies, indexes, functions, views, and
  rollback behavior;
- Supabase database/security advisors with all material findings resolved or explicitly accepted;
- automated RLS tests using multiple identities and negative cases for every exposed table and Storage
  bucket;
- tests proving strangers cannot access owner-only data, former members cannot retain access, and
  blocked participants lose authorized social access;
- transaction and concurrency tests for double spend, replay, duplicate claim, escrow, auction, and
  reward settlement;
- static analysis, dependency audit, lockfile enforcement, secret scanning, and signed/reproducible
  release processes where practical;
- API fuzzing and abuse tests for malformed, oversized, duplicated, out-of-order, and unauthorized
  requests;
- performance testing to ensure security policies do not create denial-of-service conditions;
- penetration testing before Beta multiplayer, before real-money launch, and after material authority
  redesigns;
- an independent review of RLS, privileged functions, purchase verification, and administration before
  general availability;
- a documented vulnerability intake and responsible-disclosure process.

A migration fails CI if it creates an exposed table without explicit RLS, an exposed definer-rights
view, a public executable privileged function, a direct client write path to authoritative economy,
or an unindexed high-volume ownership predicate.

### 19.18 Incident response and player protection

The incident plan defines severity, owner, communication, containment, recovery, evidence retention,
and post-incident work. The minimum response toolkit can:

- revoke user and staff sessions;
- rotate publishable, secret, database, webhook, signing, and third-party credentials;
- disable one function, RPC, Realtime channel, purchase product, trade surface, or competitive event;
- freeze suspicious balances or assets without deleting evidence;
- stop new account creation, DMs, uploads, transfers, votes, or reward claims independently;
- deploy a known-good rule or migration version;
- restore to a safe point and reconcile post-restore transactions;
- notify affected players accurately when required;
- issue compensation through audited, bounded grants;
- preserve logs and forensic evidence while respecting privacy.

Every serious incident produces a blameless postmortem, root-cause fix, regression tests, access and
secret review, and a decision on whether players require notice, restoration, or compensation.
Security claims in player-facing material must be accurate; the product never advertises itself as
“unhackable.”

### 19.19 Phase-specific security implementation

Security foundations are implemented before the feature that depends on them:

- **Early Game / FTUE:** schema isolation, owner-only private profile RLS, secure Auth/session storage,
  authoritative ledger, idempotent core RPCs, explicit grants, secret separation, basic monitoring,
  backup plan, RLS tests, and no direct economy writes.
- **Alpha:** full Storage policy model, staff role separation, staging/production isolation, automated
  policy testing, security advisors, fraud instrumentation, recovery rehearsal, social schemas kept
  closed, and moderation tooling prototype.
- **Beta:** independent penetration test; public-profile projections; Maison, contract, store-market,
  Gala, DM, Realtime, escrow, receipt, entitlement, anti-Sybil, and moderation policies; mandatory
  staff MFA; production incident runbook; automatic backups; and release-blocking cross-player privacy
  tests.
- **Late Game:** territory, large treasury, finance, franchising, advanced trade, AI, and live-ops abuse
  models; stronger anomaly detection; PITR decision; mature key rotation and disaster drills.
- **End Game / post-launch:** recurring external review, responsible disclosure, periodic threat-model
  refresh, restore drills, dependency and access recertification, and security regression testing for
  every expansion.

No multiplayer, premium currency, trading, private messaging, or public user-generated-content feature
may be enabled because its UI is complete. It remains disabled until its entire authorization,
monitoring, moderation, fraud, backup, and incident-response gate passes.

## 20. Analytics and Product Metrics

Track each metric with a numerator, denominator, time window, event version, and data
minimization review:

- Luxe-led FTUE entry, time to first meaningful input, each Founder Trial step, guidance-mode
  selection and switching, Ask Luxe use, hint escalation, dialogue skip, reconnect/device resume,
  first-loop completion, path-comprehension confirmation, first Main Quest handoff, first-return
  debrief, tutorial abandonment point, and perceived Luxe helpfulness;
- primary-tab use, contextual deep-link success, Main Quest tap distance, navigation backtracking,
  wrong-destination rate, abandoned screens, CTA comprehension, confirmation cancellation, error recovery,
  loading and offline duration, component-state failures, Luxe obstruction/dismissal/snooze, guidance density,
  text-scaling defects, screen-reader task completion, one-handed usability, reduced-motion use, frame-time
  distribution, memory pressure, thermal fallback activation, and crash-free sessions by core surface;
- first Artisan loop, first Architect loop, and first consequence response;
- Day 1 and Day 7 return, objective completion, and Feed action rate;
- Luxe chapter completion, rival-response rate, crisis decision distribution, and Gala
  participation;
- Main Quest progression, Daily Brief assignment/completion/reroll, Weekly Commission selection,
  capstone completion, quest abandonment, direct-action use, and time-to-complete by objective;
- Luxe Credit issuance by quest lane, free weekly earn distribution, premium-cosmetic time-to-earn,
  quest-driven purchase conversion, payer versus nonpayer quest difficulty, and reward-led inflation;
- product view-to-purchase, House Pass free and premium completion, paid-skip usage, Founder Pack
  conversion, Founder Club start/renew/cancel/lapse, entitlement restoration, refund rate, and
  accidental-purchase indicators;
- Creative Studio Pro and Operations Suite adoption, utility use, free-versus-paid task completion,
  and evidence that either product does not alter Hype, Market Share, idle efficiency, or Gala outcomes;
- additional House creation, cross-House transfer rejection, paid-content completion, scenario
  replay, expansion engagement, rewarded-ad opt-in and fatigue, and catalogue source-to-sink health;
- Maison creation, application, acceptance, rejection, member tenure, role distribution, roster size,
  contribution concentration, leadership succession, kick timing, treasury approvals, treasury abuse
  reports, project completion, and small-versus-full-roster performance;
- collaboration contract proposal, negotiation, acceptance, cancellation, dispute, settlement,
  revenue split, delivery success, and repeat-partner rate by Artisan and Architect path;
- store listing, valuation deviation, sale, lease, franchise, failed escrow, rapid flip, linked-account
  rejection, fraud hold, dispute, and new-player market participation;
- territory declaration, contest participation, control duration, upkeep, concentration, repeated
  ownership, challenger success, protected-district use, economic-benefit cap, and new-player loss rate;
- message send, reply, mute, block, report, enforcement, spam rejection, harmful-content detection,
  response time, repeat-offender rate, and user safety survey outcomes with privacy minimization;
- competitive division distribution, promotion, demotion, matchmaking gap, repeated top-three
  occupancy, payer-versus-nonpayer placement, old-versus-new cohort outcomes, and resentment or churn
  following competitive losses;
- monthly Gala registration, creation, lock, judging, voting, integrity flag, finalist conversion,
  score distribution, contribution distribution, repeated winners, Rising finalist rate, reward
  issuance, post-event retention, and economic impact;
- economy inflation, source-to-sink ratio, purchase latency, upgrade payback, stockout rate,
  overstock exposure, recoverability, and market-share movement;
- offline receipt open, skip, detail-expand, claim, linked-next-action rate, Buffer Stock cap
  frequency, and idle-versus-active earning ratio;
- automation unlock, policy selection, override, exception, pause, efficiency, and player
  comprehension by automation stage;
- time between meaningful unlocks and sessions without a new decision, consequence, or visible
  upgrade;
- primary-path confidence, early reassignment, path abandonment after FTUE, support-action use,
  and Joint Venture intent;
- design-zone edit depth, blueprint diversity, revision targeting, undo/branch use, same-brief visual
  variance, invalid-render rejection, and Design Signature diversity;
- Architect diagnosis accuracy, intervention selection, time-to-visible-change, store-surface use,
  heat-map and route-map comprehension, and satisfaction before currency claim;
- Gala valid-entry, personal-best, finalist, category-award, division-placement, contribution-receipt,
  non-winner return, and reward-stacking rejection;
- cooperative draft review, mood-board use, assistance completion, ordinary-material gift limits,
  unranked showcase participation, mentorship independence, voluntary return, and coercion reports;
- failure cause comprehension, recovery option selection, recovery completion, debt-spiral incidence,
  premium-rescue exposure, comeback retention, and repeated-failure frustration;
- City Difference Test results, cross-city strategy reuse, city identification without art labels,
  city-specific path engagement, and production-city promotion stability;
- Reaction Budget consumption, aggregate-to-representative ratio, important-character notice,
  notification dismissal, digest use, player density settings, and reaction-overload survey;
- Legacy Mandate selection, switching, diversity, completion, Hall engagement, endgame retention, and
  valuation-only behavior;
- active feature count by scope ring, post-lock additions, one-in-one-out compliance, disabled-feature
  rate, ownership gaps, moderation/content/support cost, and gate-based delays;
- F2P versus payer competitive performance;
- crash-free sessions, frame-time performance, and accessibility-setting usage.

- NPC reaction coverage, repetition, silence rate, like/comment/purchase ratios, cause visibility,
  sentiment distribution, named-customer retention, loyalty movement, and reaction-to-action rate;
- fashion-taste consistency across identical inputs, disagreement quality across distinct personas,
  explanation accuracy, unsupported-claim rate, generated-text fallback rate, safety rejection,
  report, correction, deletion, latency, cache hit, and cost per high-value interaction;
- supplier, buyer, investor, landlord, staff, journalist, regulator, broker, mentor, influencer, and
  stylist offer acceptance, rejection reasons, relationship movement, concentration, opportunity
  fairness, recovery outcomes, and path-specific engagement;
- AI Maison economy integrity, information parity, territory concentration, auction behavior,
  human-versus-NPC win rate, NPC reward displacement, difficulty fairness, and automatic contraction
  as human population grows;
- player trust in NPC judgment, perceived fashion credibility, perceived repetition, perceived bias,
  usefulness of criticism, and whether players understand that AI prose does not determine scores;

Track security without collecting unnecessary player content:

- RLS denial and cross-object access attempts by endpoint, object class, app version, and risk cohort;
- duplicate/replay/idempotency conflicts, ledger reconciliation failures, impossible grants, and
  quarantined premium transactions;
- account-takeover indicators, recovery outcomes, session revocations, MFA adoption, and credential
  abuse rates without logging secrets or passwords;
- suspicious trade, vote, treasury, store, contract, message, upload, and device-cluster patterns;
- staff access, privilege change, compensation grant, break-glass use, policy migration, key rotation,
  backup success, restore-drill result, and incident containment time;
- false-positive enforcement, appeal overturn, legitimate-player friction, and security-control
  performance cost.

Engagement is healthy when it is voluntary and rooted in mastery, identity, uncertainty,
social meaning, and consequence. Prohibit fake countdowns, false scarcity, punitive sleep
disruption, progress-destroying streak loss, disguised advertisements, confusing offers,
required social spam, paywalls inside active crises, purchase-gated quests, compulsive quest
streaks, purchase prompts attached to losses or vulnerable story moments, personalized pricing based
on spending vulnerability, and rewards dependent on harassment or external engagement manipulation. Competitive parity is measured, not merely asserted.

### 20.1 NPC and fashion-judgment validation gates

Before AI-generated NPC presentation expands beyond a limited test, the product must pass a curated
fashion-judgment evaluation set covering coherent and incoherent palettes, silhouette proportion,
material and construction tradeoffs, wearability, experimental work, cultural context, price-value
fit, sustainability claims, repeated design language, and intentionally niche work.

The evaluation set is reviewed by a mixed panel of fashion-informed reviewers and target players.
The objective is not to create one universal taste score. It is to verify that:

- authoritative factors respond predictably to intentional design changes;
- distinct NPC taste profiles disagree for legible reasons;
- comments accurately reference the frozen design and history;
- criticism is useful enough to guide revision;
- no city, culture, segment, or aesthetic is systematically treated as inherently superior;
- modular combinations that look visibly broken cannot exploit unrelated numerical bonuses;
- a visually coherent niche design can succeed with its intended audience without needing mass
  approval;
- deterministic fallback content preserves the same material meaning as generated prose.

Unsupported factual claims, invented history, unexplained reversals, repetitive generic comments,
unsafe criticism, and authority leakage are release-blocking defects.

### 20.2 Fun and differentiation validation gates

The following are go/no-go gates, not aspirational analytics:

- **Artisan intentionality:** players can explain which design decision caused a result and can make a
  targeted revision rather than guessing at hidden preferences.
- **Artisan tactility:** the creation interaction feels like shaping and presenting a garment, not
  completing a statistical form.
- **Architect agency:** a short session contains at least one consequential choice among viable
  commercial responses, not only collection, waiting, or dashboard maintenance.
- **Architect readability:** players can diagnose a store, contract, or supply failure from the
  evidence and propose a recovery action without consulting an external guide.
- **Partnership value:** Artisan–Architect cooperation changes the plan and outcome for both players;
  it is not merely a duplicated reward claim.
- **NPC credibility:** representative players describe NPC reactions as specific, varied, and
  consistent with character taste more often than generic or random.
- **Social mobility:** a legitimate new House can reach meaningful competition, contracts, and Gala
  recognition without receiving hidden victories or serving as content for veterans.
- **Failure quality:** a failed release, contract, store, or event creates a recoverable strategic
  story and useful next decision rather than only lost time and currency.
- **Identity:** after a short playtest, players can describe their House's style, strategy, and
  history in terms that differ from another player's House.
- **Differentiation:** target players can name the Artisan–Architect dependency, remembered brand
  history, or living fashion society as a reason the game feels unlike a generic idle tycoon.
- **Creation variance:** players using the same brief and resources produce visibly distinct,
  technically valid garments and can identify the authored differences.
- **Architect visual agency:** players diagnose and improve a business from the operating surface;
  satisfaction is not concentrated only in Ledger claims.
- **Gala breadth:** non-winning serious participants report useful feedback, attainable recognition,
  and motivation to return, while Crown placement remains prestigious.
- **Social belonging:** voluntary cooperative activity predicts repeat collaboration and Maison
  retention without requiring forced donations, spam, or competitive labor.
- **Path confidence:** players understand both fantasies before specialization, and early regret or
  reassignment remains within an approved threshold.
- **Recovery engagement:** after a meaningful failure, players select a recovery strategy and remain
  curious about the consequence rather than perceiving only punishment or a payment prompt.
- **City difference:** players identify a Production City by its decisions and cannot apply one
  unchanged optimal strategy across cities.
- **Reaction signal:** players notice important NPCs, read representative feedback, and do not report
  routine reaction overload.
- **Endgame plurality:** advanced players pursue several institutional identities and long-term goals;
  lifetime valuation is not the only meaningful objective.
- **Scope discipline:** milestone reviews show that every active feature has an owner, gate, support
  plan, and player-value evidence; failed systems are simplified or delayed rather than surrounded by
  additional features.
- **Solo feasibility:** the active build can be understood, operated, secured, updated, and recovered by
  one primary developer using documented tools and automation. A feature fails this gate when it needs
  continuous manual moderation, content production, live balancing, or incident response that the current
  project cannot actually provide.

Failure of one of these gates blocks expansion into additional cities, NPC roles, competitive modes,
or monetized utilities until the underlying interaction is revised.

## 21. Implementation Staging and Release Roadmap

### 21.0 Solo-developer delivery constitution

This roadmap is written for one primary developer using AI-assisted or “vibe-coded” implementation.
The complete GDD remains the canonical destination, but the IDE agent must optimize for the smallest
coherent release that proves the distinctive fantasy. It may not interpret the full feature registry as
a request to build everything concurrently.

#### 21.0.1 Binding release strategy

The product advances through the following practical releases:

| Release | Required product | Explicitly excluded | Success proof |
|---|---|---|---|
| **Disposable prototype** | Kingston; one garment category; one store; Luxe; Vex; three customer archetypes; two suppliers; one buyer; one trend; one failure and recovery; deterministic reactions | Real multiplayer, monetization, generative AI, territory, trading, DMs, multiple Production Cities | Players voluntarily repeat design → release → reaction → revision → store intervention |
| **Solo Alpha** | Complete single-House Artisan and Architect starter loops; secure Supabase economy; offline progression; quests; staff and basic automation; authored NPC world; AI rival Houses; Kingston depth | Live player economy, public DMs, territory, Maison Wars, subscriptions, ads | Retention, economy, security, performance, and content tools are stable without social dependency |
| **Controlled Beta** | Public profiles; friends; seasonal leaderboards; monthly individual Gala; limited Artisan–Architect contracts; basic player-created Maisons only after social gates; Milan focused expansion | Store marketplace, broad DMs, territory, Maison Wars, advanced finance, creator marketplace | Fair competition, safe collaboration, manageable support burden, and payer parity |
| **First public launch** | One excellent complete city plus one focused expansion city or market-entry campaign; full first narrative season; stable core loops; monthly Gala; basic Maisons if validated; cosmetics and one House Pass | Any feature lacking proven player value, moderation capacity, security review, or rollback | A complete maintainable game that can fund later expansion |
| **Post-launch expansion** | Additional cities one at a time; deeper Maisons; marketplace systems; territory; private messaging; advanced contracts; broader AI and live events only as validated | Simultaneous multi-system expansion | Measured demand, operating capacity, and revenue justify each addition |

A public launch may ship with Kingston as the only full Production City and Milan as a focused
market-entry destination if building two equally deep cities would compromise quality. Every other
fashion city may remain canonical through buyers, trends, contracts, Gala representation, and Feed
presence until promoted individually.

#### 21.0.2 Work-in-progress limits

The implementation queue may contain no more than:

1. one primary player-facing gameplay feature;
2. one supporting backend, security, or data feature; and
3. one polish, accessibility, performance, or tooling feature.

The IDE agent must refuse scope bundling such as “build Maisons, DMs, trading, Gala, territory, and
three cities.” It decomposes the request, selects the earliest authorized dependency, and leaves all
other features `deferred` or `foundation_only`.

#### 21.0.3 Thin-first depth rules

Initial implementations must be narrow but complete:

- one deep garment category before several shallow categories;
- deterministic authored reactions before generative AI;
- one store format before leasing, franchising, and auctions;
- basic Maison membership and objectives before treasury politics, territory, and wars;
- an individual monthly Gala before the Maison Gala track;
- public profiles and group communication before private DMs;
- direct cosmetic purchases and one House Pass before subscriptions, ads, or multiple utility products;
- one promoted city at a time after the current city passes its difference, retention, content, and
  performance gates.

“Thin” means focused and fully functional. It does not permit placeholder economies, insecure local
authority, broken failure states, or unfinished user journeys.

#### 21.0.4 Solo operations and cancellation rules

A feature is postponed or removed when any of the following is true:

- it requires more moderation or support than the developer can provide;
- it creates unacceptable fraud, security, privacy, or compliance exposure;
- it cannot maintain the target device performance;
- players do not understand or voluntarily use it;
- it duplicates an existing system without improving the core loop;
- it delays the proof-of-fun or first public release without clear evidence of value;
- its ongoing content, inference, storage, bandwidth, or operational cost is not sustainable;
- no reliable automated test, rollback, remote-disable path, or recovery procedure exists.

The developer may permanently retire a canonical feature. The GDD is a controlled product strategy,
not a contractual obligation to ship every idea.

#### 21.0.5 Population-independent launch

The first public build must remain enjoyable with a small population. NPC customers, suppliers,
buyers, critics, rivals, Gala entrants, and commercial partners provide baseline activity. Human
multiplayer enhances the world but may not be required to complete the core campaign, earn progression,
recover from failure, or experience credible competition. Human-only systems remain disabled until
concurrency and matchmaking data justify them.

#### 21.0.6 Cost and maintainability budget

Every enabled feature declares:

- estimated monthly infrastructure and third-party cost;
- expected moderation, support, content, and live-operations workload;
- database growth and retention policy;
- monitoring and alert ownership;
- rollback and remote-disable procedure;
- deterministic fallback for paid AI or external services; and
- the minimum player or revenue threshold required to justify continued operation.

A feature is not release-ready when its code works but its ongoing cost or operational burden is
unknown.

### 21.1 Staging vocabulary

This roadmap uses two separate labels. They must never be treated as synonyms:

1. **Implementation Wave** — when engineering, content, QA, operations, and backend work is allowed
   to begin.
2. **Player Unlock Band** — when a completed feature becomes available in progression.

A feature may require foundation work in an earlier wave while remaining hidden from players until a
later unlock band. Example: Joint Venture database ownership and event schemas may be prepared in
Alpha, the live feature may be implemented in Beta, and players unlock it at Rank 50. The client may
not expose an unfinished route merely because its schema exists.

The canonical implementation waves are:

| Code | Wave | Primary player band | Purpose |
|---|---|---|---|
| **EG** | Early Game / FTUE Foundation | First session through Rank 10 and first seven active days | Prove creation, commerce, reaction, recovery, Luxe guidance, idle return, and basic progression |
| **A** | Alpha | Approx. Ranks 1–30 | Stabilize the single-House core, Kingston depth, staff, automation, quests, NPC relationships, city entry, and economy |
| **B** | Beta | Approx. Ranks 1–60 | Add controlled multiplayer, Maisons, contracts, Gala, seasonal competition, scoped communication, store market, and monetization validation |
| **LG** | Late Game | Approx. Ranks 61–99 | Add territory, Maison Wars, mature global operations, advanced finance, executive automation, deeper cities, and live-service pressure |
| **END** | End Game | Rank 100+, Ascension, and post-launch mastery | Add Legacy Mandates, parallel Houses, historical goals, advanced expansions, and carefully validated creator/live-service systems |

Exact ranks remain server-configurable. The stated bands describe intended complexity and player
readiness, not hard-coded client constants. **Alpha Wave** always refers to the development wave;
**Alpha** by itself may still refer to the 85–94 Hype Score band in gameplay text.

### 21.2 IDE-agent implementation contract

The IDE agent must follow these rules:

- Every implementation task references a **Feature ID**, **Implementation Wave**, **Player Unlock
  Band**, dependencies, acceptance criteria, server owner, analytics events, and feature flag.
- The agent implements only the currently authorized wave unless an earlier foundation is explicitly
  marked as required for a later feature.
- Earlier foundation work must be inert, migration-safe, server-owned, and hidden behind a default-off
  feature flag until its activation wave.
- A screen, route, model, mock value, local timer, or database table does not count as implementation
  unless the complete causal loop and failure states are connected.
- Client code may collect intent, preview bounded outcomes, render cached reads, and display
  server-confirmed results. It may not become the authority for currency, inventory, demand, elapsed
  time, rewards, rankings, quests, relationships, territory, contracts, or competitive settlement.
- All migrations are additive or safely reversible. A later-wave schema may not break the current
  wave's playable build.
- Features marked **Do not expose** remain absent from navigation, notifications, quests, and
  monetization even if partial code exists.
- Every phase promotion requires the relevant §20.1, §20.2, economy, performance, accessibility,
  security, moderation, and operational gates.
- When a feature fails its gate, the agent simplifies, disables, or removes it. It does not add more
  rewards, currencies, dialogue, or adjacent systems to hide the failure.
- Every completed task updates the implementation manifest with `not_started`, `foundation_only`,
  `in_progress`, `playable`, `validated`, `enabled`, or `deferred`.

The repository implementation manifest uses this minimum schema:

| Feature ID | Wave | Unlock band | Status | Feature flag | Owner | Dependencies | Validation evidence |
|---|---|---|---|---|---|---|---|
| Example: `FTUE-03` | EG | First session | `in_progress` | `ftue_founder_trial` | Client + Backend | `ART-01`, `MOG-01`, `LUXE-01` | Test/build/telemetry links |

### 21.3 Master feature staging registry

The following registry is authoritative. “Expand” means a previously playable system gains depth;
“operate” means no major new architecture is expected, but balancing, content, moderation, and live
support continue.

#### 21.3.1 Product, progression, world, and core loops

| Feature ID | Feature | Primary build wave | Player unlock band | Required earlier foundation / gate |
|---|---|---:|---:|---|
| P-01 | Product vision and remembered brand-history promise | EG | FTUE onward | Binding design review; no isolated-menu implementation |
| P-02 | Consequences, explainable authority, strategy-over-spending pillars | EG | All bands | Server ownership and result-explanation contract |
| P-03 | Accessible editorial design system | EG | All bands | Tokens, semantics, reduced motion, low-device fallbacks |
| P-04 | Voluntary engagement and anti-compulsion rules | EG | All bands | Quest, notification, monetization, and analytics reviews |
| LOOP-01 | Canonical design/commercial causal loop | EG | FTUE onward | Must pass Artisan and Architect proof-of-fun gates |
| FTUE-01 | Luxe-led Sanctuary opening and House naming | EG | First 45 seconds | Accessibility controls available before animation |
| FTUE-02 | Founder intent and shared starter garment | EG | First session | No hidden permanent stat bonus |
| FTUE-03 | Artisan and Architect Founder Trial samples | EG | First 4–6 minutes | One shared garment; visible consequence in both samples |
| FTUE-04 | Luxe guidance modes, Ask Luxe, adaptive hints, resume state | EG | FTUE through first week | Server-owned tutorial knowledge and safe recovery |
| FTUE-05 | First Main Quest and first House While Away return lesson | EG | First session / Day 1 | Quest and idle settlement must already be authoritative |
| PROG-01 | Brand Rank, Path Mastery, identity, Heat, Rep, Followers, Market Share, Luxe Trust | EG | FTUE onward | One definition and one server owner per stat |
| PROG-02 | Competitive Rating and Maison Standing | B | Beta competition | Seasonal normalization and anti-snowballing validation |
| PROG-03 | Early path reassignment and secondary support actions | EG | Through Rank 10 / pre-JV | Preserve all shared assets and progression |
| PROG-04 | Immediate, session, and strategic goal hierarchy | EG | All bands | Server-configured unlock cadence and telemetry |
| PROG-05 | Joint Venture progression preparation | A foundation; B playable | Unlock at Rank 50 | Shared ledger, separate mastery, throughput cap |
| WORLD-01 | Global Fashion City Registry | A | World map after core loop | Research status and city maturity metadata |
| WORLD-02 | Kingston Reference/Production City | EG core; A depth | Early Game | Pass City Difference Test and low-device performance |
| WORLD-03 | Milan Production City | A foundation; B production | Midgame city entry | Kingston gates, one complete market-entry loop |
| WORLD-04 | Paris, London, New York, Tokyo World-Market presence | A | Midgame preparation | Contracts, trends, buyers, Feed, Gala pathways |
| WORLD-05 | Promotion of additional fashion cities | LG / END | Late and End Game | One city at a time; research and difference gates |
| WORLD-06 | Customer segments and cohort model | EG | First release onward | Transparent segment preferences and demand inputs |
| WORLD-07 | Named customer/loyalist persistence | A | Early-to-mid game | Cohort system stable; reaction budget enforced |

#### 21.3.2 Atelier, fashion judgment, Architect play, and economy

| Feature ID | Feature | Primary build wave | Player unlock band | Required earlier foundation / gate |
|---|---|---:|---:|---|
| ART-01 | Design grammar: silhouette, material, construction, palette, audience, price, ethics, quantity | EG | Founder Trial onward | No option universally superior |
| ART-02 | Zone-level garment shaping and tactile Atelier interaction | EG core; A expand | Early Game | Same-brief creation variance and mobile usability |
| ART-03 | Panels, seams, trims, closures, patterns, layering, asymmetry | A | Early-to-mid game mastery | Blueprint versioning and performance budget |
| ART-04 | Design Blueprint, undo, branching versions, targeted revision | EG core; A depth | First release onward | Server-confirmed saved state and revision lineage |
| ART-05 | Design Signature and House visual language | A | After repeated releases | Descriptive only; no permanent score multiplier |
| ART-06 | Hype Score and structured result breakdown | EG | First release onward | Frozen validated inputs and bounded context adjustment |
| ART-07 | Deterministic NPC taste interpretation | EG core; A expand | First release onward | Curated fashion-judgment set |
| ART-08 | AI-generated fashion prose | LG optional | Selected high-value moments after public-launch validation | Grounding, fallback, moderation, cost, consistency gates |
| MOG-01 | First store, customer flow, price, inventory, margin, stockout, loyalty | EG | Founder Trial / first session | Atomic first-store operation and visible diagnosis |
| MOG-02 | Diagnose → intervene → observe → adapt operating loop | EG core; A expand | Early Game | Short-session visible response test |
| MOG-03 | Campaigns, multi-store management, warehouse and route visualization | A | Midgame | Economy pacing and performance validation |
| MOG-04 | Artisan–Architect Collection Contract mock | EG prototype | Prototype only | Must prove cooperation changes the plan |
| MOG-05 | Live Collection Contracts | B | Maison/midgame | Escrow, ownership, risk, cancellation, revenue split |
| MOG-06 | Store leasing and controlled listings | LG / post-launch | Late Game | Valuation, escrow, anti-alt, population, support, and ownership history |
| MOG-07 | Store sales, franchising, distressed acquisition, market bidding | LG | Late Game | Liquidity, fraud, concentration, and recovery gates |
| MOG-08 | Wholesale, production, logistics, and distribution contracts | B limited NPC/player pilots; LG depth | Mid-to-late game | Contract settlement, population, fraud, and counterparty reputation |
| MOG-09 | Advanced finance: loans, equity, IPO, governance | LG conditional | Late Game | Architect fun, debt recovery, and anti-pay-to-win gates |
| ECO-01 | Demand and sales settlement | EG | First release onward | Inventory cannot go negative; causes visible |
| ECO-02 | House Funds, Luxe Credits, Aurelian Seals, append-only ledger | EG foundation | House Funds early; premium later | One transaction owner and idempotency |
| ECO-03 | Early economy pacing, upgrade cadence, and payback bands | EG | Early Game | Simulated and playtested before Alpha promotion |
| ECO-04 | Midgame and multiplayer economy tuning | A / B | Midgame | Sources/sinks, contract and Maison concentration review |
| ECO-05 | Late-game inflation, territory upkeep, and advanced finance tuning | LG | Late Game | No permanent runaway compounding |
| ECO-06 | Bottlenecks, failure, salvage, and recovery loops | EG | First week onward | At least two viable responses; no premium rescue |

#### 21.3.3 Feed, Maisons, communication, competition, and territory

| Feature ID | Feature | Primary build wave | Player unlock band | Required earlier foundation / gate |
|---|---|---:|---:|---|
| SOC-01 | Authored NPC Global Feed and actionable consequence cards | EG | First release onward | Reaction Budget and direct next action |
| SOC-02 | Player Feed profiles and controlled public identity | B | Beta social unlock | Moderation, privacy, block/report, anti-spam |
| SOC-03 | Player-created Maisons, recruitment, applications, 10-member cap | B | Midgame | One ranked House/Maison per account and roster locks |
| SOC-04 | Maison roles and basic permissions | B; treasury/succession LG | Maison creation / Late Game governance | Personal-asset protection first; treasury requires dual approval and operations capacity |
| SOC-05 | Basic Maison HQ and shared objectives | B conditional; LG expand | Mid-to-late game | Population, contribution fairness, and bounded benefits |
| SOC-06 | Mood boards, draft reviews, mentoring, exhibitions, bounded material help | B | Maison membership | Optional participation; no forced labor |
| SOC-07 | Maison announcements and group chat | B conditional | Maison membership | Human moderation capacity, filtering, reporting, rate limits, retention |
| SOC-08 | Friends-, recruitment-, and contract-scoped DMs | LG / post-launch conditional | After safety tutorial | Proven moderation capacity, block/report, minor protections, no links by default |
| SOC-09 | Voice chat | END deferred | Not exposed | Requires separate safety and operations approval |
| COMP-01 | Seasonal divisions and multidimensional leaderboards | B | Beta ranked unlock | Rising protection and normalized current-season scoring |
| COMP-02 | Anti-snowballing, catch-up, concentration caps, rematch protection | B | All ranked modes | Telemetry must show newcomer mobility |
| COMP-03 | District territory control | LG | Late Game | Population, upkeep, decay, starter protection, cap |
| COMP-04 | Maison Wars and rivalry formats | LG | Late Game | Scheduled, opt-in, published rules, no surprise losses |
| COMP-05 | Monthly Aurelian Gala House track | B | Beta monthly event | Standardized resources and broad recognition |
| COMP-06 | Monthly Aurelian Gala Maison track | B late conditional / LG | Maison event unlock | Individual Gala proven; roster-normalized contribution, population, and anti-collusion |
| COMP-07 | Gala Crown Finals, category awards, repeated-winner controls | B core; LG tune | Monthly event | Automatic settlement and no future power rewards |

#### 21.3.4 Luxe, quests, narrative, NPC society, crises, and live events

| Feature ID | Feature | Primary build wave | Player unlock band | Required earlier foundation / gate |
|---|---|---:|---:|---|
| LUXE-01 | Luxe assistant, mascot, context help, result debriefs, relationship memory | EG | First screen onward | Grounded state; no silent decisions or shop pressure |
| LUXE-02 | Main Quests | EG | FTUE onward | Persistent, authored, retroactive completion support |
| LUXE-03 | Daily Briefs, free reroll, auto-claim, anti-compulsion | EG | Day 1 | Reachability validation and exact reward preview |
| LUXE-04 | Weekly Commissions and capstone | A | Days 4–7 onward | Multi-system variety and weekly reward cap |
| LUXE-05 | Seasonal and Maison quest variants | B | Beta social seasons | No required wins, votes, purchases, or cooperation |
| NAR-01 | Luxe Season One opening and early chapters | EG / A | First week onward | Choices stored in Archive and reflected accurately |
| NAR-02 | Complete first narrative season | B | Mid-to-late progression | Authored key scenes; AI cannot own emotional spine |
| VEX-01 | Vex first critique and persistent opinion history | EG | First release onward | Evidence inspection and structured inputs |
| RIVAL-01 | Maison Vanta authored rival | EG core; A expand | First week onward | Rival creates decisions, not unavoidable loss |
| ARCHIVE-01 | Story Archive history | EG | First complete loop onward | Only confirmed events; searchable depth later |
| NPC-01 | Customer cohorts and representative reactions | EG | First release onward | Most population remains aggregate/silent |
| NPC-02 | Suppliers, manufacturers, buyers, wholesalers | EG core; A expand | Early-to-mid game | Capacity, memory, negotiation, no static best choice |
| NPC-03 | Staff characters, mentors, critics, event professionals | A | Midgame | Persistent bounded memory and role-specific utility |
| NPC-04 | Influencers, stylists, celebrity clients | A/B authored; LG deepen | Mid-to-late game | Authored templates first; audience fit and controversy risk; no automatic success |
| NPC-05 | AI-controlled rival Maisons | B limited; LG mature | Ranked population support | Same economy, information parity, contraction rules |
| NPC-06 | Investors, lenders, landlords, governance actors | LG | Late Game | Advanced finance and recovery gates |
| NPC-07 | Journalists, regulators, inspectors, counterfeit threats | A authored; LG systemic | Crisis unlock onward | Evidence-based, no fabricated accusations |
| NPC-08 | Brokers, agents, cultural institutions | LG | Late Game | Distinct opportunities and bounded information advantage |
| NPC-09 | AI presentation service | LG optional | Selected post-launch moments | Deterministic fallback, authority isolation, sustainable cost, and disable switch |
| CRISIS-01 | First branching crisis and recovery | EG | Days 4–5 | No irreversible trap; explicit evidence and causes |
| CRISIS-02 | Expanded commercial, ethical, staff, and media crises | A / B | Midgame | Different later scenes and recovery paths |
| CRISIS-03 | Institutional, territory, finance, and multiplayer crises | LG | Late Game | No harassment incentives or paid immunity |
| EVENT-01 | Daily Trend Pulse | EG / A | First week | Bounded effect and readable cause |
| EVENT-02 | Forecast 72-hour Trend Wave | A | Midgame | Warning period and no mandatory trend chasing |
| EVENT-03 | Seasonal Trend Tsunami and large live events | LG | Late Game | Live-ops capacity and non-compulsive scheduling |

#### 21.3.5 Staff, automation, idle, modes, and endgame

| Feature ID | Feature | Primary build wave | Player unlock band | Required earlier foundation / gate |
|---|---|---:|---:|---|
| STAFF-01 | Earned staff contracts and free strategic archetypes | A | Early-to-mid game | Horizontal tradeoffs; deterministic free path |
| STAFF-02 | Staff personality, workload, loyalty, promotion, departure | A core; LG depth | Midgame onward | No hidden punishment; explainable changes |
| AUTO-01 | Operations Assistant | EG | Day 1 | Transparent bounded default and audit trail |
| AUTO-02 | Specialist automation | A | Early-mid game | One declared objective and visible drawback |
| AUTO-03 | Department Manager and multi-operation policies | A / B | Midgame | Player-set policy, exception queue, override |
| AUTO-04 | Executive Policies | LG | Late Game | Bounded rules; no remove-all-strategy automation |
| IDLE-01 | Authoritative offline accumulation and Buffer Stock | EG | Day 1 | Server time, cap, one ledger settlement |
| IDLE-02 | House While Away receipt and linked interventions | EG | First return | Show earnings, costs, bottlenecks, events, next action |
| IDLE-03 | Active intervention value | EG / A tune | All bands | Active strategy improves quality, not coercive login |
| MODE-01 | Casual and Expert presentation/control modes | A | After first loop | Same rates, ceilings, rewards, and eligibility |
| END-01 | Joint Venture live division | B | Rank 50 | Shared ledger; 60% initial throughput to 100% mastery |
| END-02 | Aurelian Ascension | END foundation may begin LG | Rank 100 | Preserve main empire; no permanent ranked multiplier |
| END-03 | Legacy Mandates and Hall of Sovereigns biography | END | Rank 100+ | Multiple viable identities; history over wealth |
| END-04 | Parallel New House run and additional isolated Houses | END | Post-Ascension / entitlement | Economically isolated; one ranked House per season |

#### 21.3.6 Monetization, UI, technology, analytics, and operations

| Feature ID | Feature | Primary build wave | Player unlock band | Required earlier foundation / gate |
|---|---|---:|---:|---|
| MON-01 | Monetization constitution and competitive-power exclusions | EG | All bands | Binding automated and manual tests |
| MON-02 | Premium wallet and earn-rate instrumentation | A foundation | After core retention proof | Wallet exists before offers; no purchase prompt in FTUE |
| MON-03 | Luxe Credit catalogue and one-time Founder Pack | B / launch | After first complete loop; offer timing validated | Receipt verification, restoration, exact contents |
| MON-04 | Eight-week House Pass | B | Seasonal Beta | Free complete path; no score/economic power |
| MON-05 | Creative Studio Pro | LG / post-launch conditional | After Atelier mastery and demand proof | Creation/storage/export utility only |
| MON-06 | Operations Suite | LG / post-launch conditional | After multi-store mastery and demand proof | Organization convenience only; no secret forecasts |
| MON-07 | Additional House slot | LG entitlement; END use deepens | Late Game / post-Ascension | Economic isolation, support burden, and reward caps |
| MON-08 | Founder Club subscription | LG / post-retention | Late Game or post-launch | Continuing value, fair lapse, no multipliers |
| MON-09 | Narrative expansions and scenario packs | LG / END | Post-core campaign | Complete free primary story; isolated economies |
| MON-10 | Rewarded advertising | LG optional | Post-retention only | Capped, voluntary, no offline doubling or competition |
| MON-11 | Licensed collaborations | END | Post-launch | Clear sponsorship disclosure and no hidden advantage |
| MON-12 | Creator marketplace | END deferred | Not exposed until approved | Moderation, IP, fraud, economy, and platform review |
| UI-01 | Aurelian tokens and five-destination portrait navigation shell | EG | FTUE onward | Two-tap Main Quest access, restoration, thumb reach, no second design system |
| UI-02 | State-complete reusable component library | EG core; A stabilize | As systems unlock | Variants, semantics, accessibility, performance, and no duplicate components |
| UI-03 | Sanctuary, HQ, Atelier, first store, release result, House While Away | EG | FTUE onward | Task-based proof-of-fun, all reliability states, low-device profile |
| UI-04 | Luxe Ambient, Guidance, Briefing, and Ask Luxe modes | EG | FTUE onward | Interruption budget, dismissibility, memory, no authority or sales pressure |
| UI-05 | Artisan and Architect path-specific visual operating language | EG core; A complete | Path unlock onward | Creative tactility and visual diagnose-intervene-observe play |
| UI-06 | Quests, suppliers, staff, automation, collections, city entry, Vex history | A | Matching Alpha unlocks | Component reuse and progressive disclosure |
| UI-07 | Public profiles, friends, leaderboards, Gala, contracts, basic Maison | B | Matching Beta unlocks | Privacy, moderation, block/report, payer-neutral clarity |
| UI-08 | Multi-city, territory, store market, franchise, advanced Maison and finance | LG | Matching Late Game unlocks | Density, role permission, fraud and recovery clarity |
| UI-09 | Ascension, Legacy Mandates, Hall of Sovereigns, historical Archive | END | Rank 100+ | Identity and history over raw-number presentation |
| UI-10 | Accessibility, usability, golden/widget/state testing and UI analytics gates | EG foundation; each wave | All bands | Release-blocking core-task and performance evidence |
| PERF-01 | 60 fps target and Galaxy A55 reference profile | EG | All bands | Profile/release evidence and low-end fallbacks |
| TECH-01 | Flutter/Riverpod client and Supabase/PostgreSQL authority | EG | All bands | Client sends intents only |
| TECH-02 | Ledger, idempotency, RLS, immutable rule versions | EG | All bands | Release-blocking security foundation |
| TECH-03 | Multiplayer, escrow, messaging, anti-Sybil, moderation architecture | A foundation; B active | Beta social systems | Load, abuse, retry, appeal, and audit tests |
| TECH-04 | NPC simulation and AI presentation boundary | A deterministic foundation; LG AI optional | As NPC tiers unlock | Grounding, fallback, privacy, cost ceiling, disable switch |
| SEC-01 | Threat model, data classification, and security ownership | EG | Internal/all bands | Release-blocking written model and owner |
| SEC-02 | Private schema isolation, explicit Data API exposure, grants, and safe projections | EG | All bands | Fail-closed schema and migration tests |
| SEC-03 | Owner-only RLS, relationship policies, blocked/former-member revocation | EG core; B social expansion | Matching surfaces | Positive and negative identity matrix |
| SEC-04 | Append-only ledgers, authoritative RPCs, idempotency, locks, reconciliation | EG | All economic bands | No direct client authority writes |
| SEC-05 | Auth hardening, secure token storage, reauthentication, session revocation, player/staff MFA | EG foundation; A/B enforce | Account and sensitive actions | ATO and recovery tests |
| SEC-06 | Edge Function, webhook, API validation, rate limits, secret isolation | EG core; A expand | Matching endpoints | Auth-mode, replay, abuse, and leak tests |
| SEC-07 | Storage and Realtime access control, private channels, upload scanning | A foundation; B active | UGC and social unlocks | Cross-player and malformed-upload tests |
| SEC-08 | Device-risk, anti-cheat, anti-Sybil, trade/vote/purchase fraud controls | A instrumentation; B active | Competitive/market systems | Graduated response and appeal |
| SEC-09 | Supabase organization MFA, staff least privilege, dual control, break-glass | A | Internal only | Access review and immutable audit |
| SEC-10 | Security monitoring, domain freeze switches, incident response | EG foundation; B production | Internal only | Alert, containment, and recovery exercise |
| SEC-11 | Daily backups, Storage backup, restore drills, PITR decision | A foundation; B production; LG mature | Internal only | Measured RPO/RTO and ledger reconciliation |
| SEC-12 | RLS/Storage tests, advisors, SAST, dependency/secret scans, API abuse CI gates | EG foundation; A complete | Internal only | CI blocks unsafe migrations and releases |
| SEC-13 | Independent penetration test and privileged-function/RLS audit | B | Before public multiplayer and real money | Critical/high findings resolved |
| SEC-14 | Responsible disclosure, recurring threat-model and access recertification | END/post-launch | Internal/public policy | Scheduled review and remediation ownership |
| DATA-01 | Core funnel, FTUE, economy, retention, performance analytics | EG | Internal only | Numerator, denominator, window, version, privacy |
| DATA-02 | Fashion-judgment validation set | A | Before AI expansion | Mixed fashion-informed and target-player review |
| DATA-03 | Multiplayer fairness, concentration, fraud, moderation metrics | B | Beta social systems | Newcomer mobility and payer parity |
| DATA-04 | Late-game inflation, territory, endgame identity metrics | LG / END | Matching systems | No one dominant identity or permanent caste |
| OPS-01 | Content tools for quests, NPCs, cities, Gala, crises, offers | A foundation; B production | Internal only | Versioned config, preview, rollback, audit |
| OPS-02 | Moderation console, support, appeals, enforcement | A prototype; B production | Before player communication | Human process and response ownership |
| OPS-03 | Live-operations scheduling and incident controls | B foundation; LG production | Seasonal/live systems | Quiet hours, rollback, compensation, disable switch |

### 21.4 Early Game / FTUE implementation wave

The Early Game wave is the mandatory proof-of-fun core. It is not a reduced version of every future
system. It contains only what is required to prove that the first House is enjoyable.

During this wave the work-in-progress limit is absolute: one Atelier/Architect gameplay task, one
Supabase authority or security task, and one Luxe/UI/performance task. No social or monetization
foundation is allowed unless it is required to keep the current schema migration-safe.

#### Must ship

- Luxe-led FTUE, Founder Trial, guidance modes, Ask Luxe, resume, path reassignment, first Main Quest.
- One Kingston garment category with meaningful zone-level shaping, material, palette, details, and
  targeted revision.
- One visually diagnosable store, one customer cohort, one representative customer, one Vex critique,
  two suppliers, one buyer, one trend context, and one short crisis with two recovery paths.
- First-store settlement, demand, price, inventory, margin, stockout, loyalty, House Funds, ledger,
  Brand Rank, Path Mastery, Luxe Trust, and Story Archive.
- Operations Assistant, one transparent policy, offline cap, House While Away receipt, Daily Briefs,
  and one direct return intervention.
- Deterministic NPC presentation; no generative AI dependency.
- A mocked or limited partnership test only where necessary to validate Artisan–Architect value.
- Core analytics, accessibility, low-device profile, feature flags, and result explanations.
- Security foundation: private/exposed schema separation, explicit grants, owner-only profile RLS,
  authoritative ledgers and RPCs, idempotency, secure session storage, secret separation, automated RLS
  tests, basic anomaly alerts, backup plan, and remote freeze switches.

#### Do not expose

Maisons, open player Feed, DMs, store trading, ranked leaderboards, Gala, territory, Maison Wars,
premium shop, House Pass, subscriptions, ads, advanced finance, multiple Production Cities, voice
chat, creator marketplace, and broad generative dialogue.

#### Promotion gate

Players voluntarily repeat the design → release → reaction → revision/commercial response loop;
Artisans produce visibly different garments; Architects diagnose and improve a store; Luxe is
understood and not obstructive; failures create useful recovery; and the build meets performance,
security, economy, and accessibility requirements.

### 21.5 Alpha implementation wave

Alpha turns the proven first-House loop into a stable single-player and asynchronous world.

Alpha remains population-independent and must be distributable to testers without live Maisons,
player trading, DMs, or paid AI. It is the first candidate for a maintainable solo-developer build.

#### Build and expand

- Kingston depth, additional garment controls, Design Signatures, campaigns, multi-store operation,
  warehouse/route visualization, staff, Specialists, Department Manager prototype, Weekly
  Commissions, broader Luxe chapters, Vex history, Maison Vanta, named customers, persistent supplier
  and buyer relationships, mentors, critics, staff personalities, and expanded crises.
- Milan market-entry foundation and World-Market representations for Paris, London, New York, Tokyo.
- Content authoring tools, moderation-console prototype, player/social schemas kept disabled,
  premium-wallet instrumentation kept offer-free, AI presentation architecture kept disabled by
  default, and multiplayer load/security foundations.
- Complete Storage and Realtime policy prototypes, staff least-privilege roles, mandatory organization
  MFA, staging/production isolation, security advisors, dependency/secret scanning, fraud telemetry,
  restore rehearsal, and CI rejection of unsafe grants, views, functions, or missing RLS.
- Casual/Expert modes, economy pacing through approximately Rank 30, and the complete Alpha analytics
  suite.

#### Do not expose

Live Maisons, unrestricted player messaging, territory, Maison Wars, live store sales, advanced
finance, subscription, ads, creator marketplace, or End Game systems.

#### Promotion gate

The single-House game retains players without multiplayer or monetization pressure; Weekly quests do
not feel compulsory; city entry changes decisions; staff and automation reduce repetition without
removing strategy; and content production can sustain Beta.

### 21.6 Beta implementation wave

Beta introduces controlled human interdependence and validates fair monetization.

#### Build and expose gradually

Beta is split into ordered slices. A later slice cannot begin merely because its schema exists.

**Beta Slice 1 — asynchronous competition:**

- public House profiles, friends, seasonal divisions, Rising protection, multidimensional
  leaderboards, and the monthly **individual House Gala** with category awards and automatic rewards;
- Milan as a focused Production City or market-entry expansion, deeper World-Market activity, AI rival
  Houses, live Joint Venture at Rank 50, and the complete first narrative season;
- limited Artisan–Architect Collection Contracts using escrow and predefined communication, without a
  general player marketplace or unrestricted messaging.

**Beta Slice 2 — basic Maisons, only after Slice 1 is stable:**

- player-created Maisons, recruitment, a 10-member cap, basic roles, optional shared objectives,
  announcements, and group chat only when real moderation capacity exists;
- shared HQ presentation and the Maison Gala track only after population, contribution fairness, and
  anti-collusion gates pass;
- treasury transfers, complex succession, store trading, private DMs, and territory remain disabled.

**Security and monetization:**

- activate cross-player RLS and private-channel authorization only after a full identity-matrix test;
  complete independent penetration testing, purchase/webhook review, account-recovery testing, backup
  verification, incident-response exercise, and critical/high remediation;
- launch monetization is limited to the Luxe Credit cosmetic catalogue, one-time Founder Pack, and one
  eight-week House Pass after retention and fairness gates. Creative Studio Pro, Operations Suite,
  subscriptions, ads, and additional House slots remain post-launch experiments;
- no monetization surface appears in the FTUE.

#### Keep disabled unless separately validated

Store leasing or sales, broad or private DMs, territory, Maison Wars, advanced loans/equity/IPO,
rewarded ads, Founder Club, utility subscriptions, additional House slots, creator marketplace, voice
chat, and generative AI presentation.

#### Promotion gate

New players can earn recognition; older players cannot permanently dominate; Maison leadership cannot
steal assets; contracts settle safely; moderation and support can handle abuse; Gala remains credible;
free and paying players have equal competitive ceilings; and the multiplayer population is large
enough for the intended modes.

### 21.7 Late Game implementation wave

Late Game is a **post-launch expansion programme**, not part of the minimum public release. It expands
mature Houses into global institutions only after Beta social, economy, moderation, population,
revenue, and solo-operations gates pass. Features enter one at a time; the developer may permanently
leave any item disabled.

#### Build and expose

- Territory cycles, upkeep, influence decay, concentration caps, protected districts, Maison Wars,
  advanced HQ projects, store sales, franchising, distressed acquisitions, market bidding, trade
  routes, corporate projects, wholesale networks, and advanced commercial crises.
- Executive Policies, mature AI rival Maisons, investors, lenders, landlords, brokers, institutions,
  regulators, counterfeit threats, advanced staff succession, and more Production Cities one at a
  time.
- Trend Tsunamis, Fashion Week, larger live events, Founder Club, narrative expansions, scenario
  packs, and optional capped rewarded ads after post-retention review.
- Economy, inflation, territory, and concentration tuning through Rank 99.
- Expand fraud models for territory, finance, franchising, treasury, AI-cost abuse, and large trades;
  run key-rotation and disaster-recovery drills; decide and enable PITR according to measured economic
  risk; recertify all privileged access.

#### Never permit

Purchased territory strength, paid score ceilings, surprise overnight destruction, unbounded
compound advantages, forced social labor, or debt that requires a purchase to escape.

#### Promotion gate

The world remains mobile for new and rebuilding Houses; territory creates decisions rather than
permanent ownership; late-game Architects have active visual play; live operations are sustainable;
and no advanced system destabilizes the core economy.

### 21.8 End Game implementation wave

End Game answers what the House becomes after maximum rank. It must create identity and replayability,
not merely larger numbers.

#### Build and expose

- Aurelian Ascension, Hall of Sovereigns, Legacy Mandates, historical collections, mentoring legacies,
  institutional identities, parallel New House runs, additional economically isolated Houses, and
  season-boundary legacy choices.
- Advanced narrative expansions, premium scenario campaigns, additional rival Houses and Luxe
  seasons, mature global city waves, and carefully validated creator/community systems.
- Licensed collaborations may enter here after disclosure and fairness review.
- Maintain recurring external security review, responsible disclosure, quarterly access and secret
  recertification, restore drills, threat-model refresh, and regression testing for every expansion.
- Creator marketplace, real-time shared Atelier, live runway streaming, voice chat, hostile takeovers,
  and similar high-risk systems remain deferred until separately approved, even if technically
  associated with End Game.

#### End Game acceptance

At least several viable institutional identities exist; wealth is not the only respected outcome;
Ascension preserves the player's main history; replay does not generate ranked multipliers; veterans
have meaningful goals without treating newer players as resources; and one optimal Legacy Mandate
does not dominate.

### 21.9 Deferred and explicit-hold registry

The following are canonical ideas but **must not be implemented or exposed** without a new written
approval and their own safety, platform, economy, moderation, performance, and fun review:

- voice chat;
- unrestricted public DMs or external-link sharing;
- creator cash-out or real-money player trading;
- creator marketplace;
- live runway streaming;
- real-time shared Atelier editing;
- hostile player takeovers;
- player-owned public equities;
- external engagement rewards;
- blockchain or tokenized ownership;
- any AI service that determines authoritative gameplay outcomes;
- any premium product that changes score, territory, market control, idle rate, or competitive ceiling.

### 21.10 Phase promotion and rollback rules

Every wave has exactly one approved build target. Features not listed for that wave remain disabled.
Promotion requires:

- all applicable acceptance criteria in §22;
- passing §20.1 fashion judgment and §20.2 fun gates;
- economy simulation and live telemetry within approved bands;
- crash, frame-time, battery, memory, network, and low-device evidence;
- accessibility review;
- security and RLS verification, including stranger/former-member/blocked-user negative tests,
  privileged-function review, economic replay/concurrency tests, secret and dependency scans, backup
  evidence, and incident-response readiness;
- moderation and support readiness for every social surface;
- documented content-production and live-operations ownership;
- a rollback or remote-disable path;
- evidence that the new wave is more enjoyable, not merely larger.
- a solo-operations review showing that monthly costs, moderation, support, content workload, alerts,
  backups, and incident response are sustainable for one primary developer; and
- confirmation that only one primary gameplay feature, one backend/security feature, and one polish
  feature are active after promotion.

A phase review reports scope added, scope removed, unresolved dependencies, operational burden, and
gate evidence. One-in, one-out scope control applies after each wave locks. A failed gate blocks the
feature and may block the wave; schedule pressure or monetization need does not override the failure.

## 22. Feature Acceptance Criteria

Every active feature is documented using this contract. Every implementation task also declares its
§21 Feature ID, Implementation Wave, Player Unlock Band, dependency gate, feature flag, and current
manifest status. The IDE agent may not mark a feature complete without this metadata.

1. Player goal.
2. Entry condition.
3. Inputs.
4. Decision and tradeoff.
5. Authoritative calculation and owner.
6. Success, failure, and at least one recovery or safe exit path.
7. Consequences and affected systems.
8. What happened, why, what changed, who reacted, and next action.
9. Loading, empty, error, disabled, offline, unavailable, and success states.
10. Offline behavior and resume behavior.
11. Security and RLS requirements.
12. Accessibility and localization requirements.
13. Performance budget and low-device fallback.
14. Quest lane, eligibility, assignment, exact progress, reset, reroll, reward, auto-claim,
    Luxe presentation, and anti-compulsion rules where relevant.
15. Automation eligibility, policy, audit trail, exceptions, and player override where relevant.
16. Economy pacing target, cost, payback, resource alternatives, and recoverability where relevant.
17. Idle settlement inputs, cap behavior, immutable receipt, and resume behavior where relevant.
18. Monetization entitlement type, exact contents, price, duration, restoration, expiration,
    lapse behavior, free alternative, and competitive-power exclusion where relevant.
19. Storefront states, purchase confirmation, cancellation, refund, duplicate grant, offline
    recovery, parental or platform restriction, and accessibility behavior where relevant.
20. Multiplayer eligibility, division, roster normalization, newcomer protection, seasonal reset,
    reward settlement, anti-snowball cap, and payer-neutral outcome where relevant.
21. Maison ownership, role permission, treasury approval, roster lock, departure, succession,
    personal-asset protection, voluntary social participation, and anti-coercion behavior where relevant.
22. Contract versioning, identical confirmation, escrow, valuation, fraud hold, cancellation,
    settlement, dispute, and ownership history where relevant.
23. Communication authorization, privacy, block, mute, report, filtering, rate limit, retention,
    moderation, and appeal behavior where relevant.
24. NPC role, preference profile, resources, knowledge boundary, relationship evidence, memory,
    valid actions, cooldown, authoritative owner, fallback, and exit conditions where relevant.
25. NPC taste inputs, rule version, seeded variance, representative explanation, secondary-effect cap,
    and prohibition on recursive Hype or ranked-power feedback where relevant.
26. AI grounding payload, model and template version, safety checks, deterministic fallback, privacy,
    cost and latency budget, report and correction path, and proof that generated prose owns no
    authoritative outcome where relevant.
27. NPC economy parity, information parity, resource constraints, human-population replacement rule,
    reward-displacement prohibition, and anti-concentration checks for AI-controlled competitors.
28. Customer, supplier, buyer, critic, influencer, staff, investor, media, regulator, mentor, event,
    or threat-specific success, failure, relationship, recovery, and explanation states where relevant.
29. Garment blueprint zones, authored geometry and styling state, visual validity, revision lineage,
    same-brief differentiation, and low-device equivalent controls where relevant.
30. Architect diagnosis evidence, visual operating surface, viable interventions, visible response,
    delegation boundary, and prohibition on spreadsheet-only or repetitive-tap play where relevant.
31. Gala track, division, standardized resource budget, entry lock, anonymous judging, voting,
    integrity review, valid-entry, personal-best, finalist, category, division and Crown recognition,
    reward-stacking cap, automatic distribution, repeated-winner monitoring, and Archive result.
32. Founder Trial samples, path-specialization explanation, support-action access, early reassignment,
    preserved progress, and payer-neutral regret protection where relevant.
33. Failure cause receipt, salvage state, two viable recovery options where possible, persistent
    consequence, anti-debt-spiral protection, and absence of paid rescue pressure where relevant.
34. City Difference Test, strategy matrix, cultural review, path-specific distinction, cross-city
    comparison, production ownership, and promotion gate where relevant.
35. Reaction Budget, silent/aggregate/representative/named/editorial hierarchy, deduplication, digest,
    density controls, and no information or reward loss when reducing comments where relevant.
36. Legacy Mandate identity, multiple viable endgame routes, Hall biography, reward-power exclusion,
    and season-boundary switching where relevant.
37. Feature ID, Implementation Wave, Player Unlock Band, manifest status, feature owner, operational
    burden, gate evidence, disable switch, and one-in-one-out scope decision where relevant.
38. Applicable §20.1 fashion-judgment and §20.2 fun-validation evidence before scope promotion or launch.
39. Analytics events with numerator, denominator, time window, event version, and privacy review.
40. Objective pass/fail acceptance criteria.
41. Data classification, exposed schema, explicit grant, owner/public/relationship/admin access matrix,
    RLS `USING` and `WITH CHECK`, indexed predicates, view security mode, function privilege, and
    stranger/former-member/blocked-user negative tests.
42. Sensitive mutation authority, idempotency, immutable rule version, server time, transaction and
    lock behavior, append-only audit event, duplicate/replay handling, reconciliation, and domain-freeze
    behavior.
43. Authentication assurance, secure token storage, session revocation, reauthentication, account
    recovery, rate limits, CAPTCHA, Edge Function auth mode, webhook signature, Storage/Realtime
    authorization, secret handling, and staff least privilege.
44. Security logging and privacy minimization, backup and Storage recovery, restore reconciliation,
    incident owner, containment switch, key rotation, player-notice decision, independent review, and
    unresolved-risk acceptance.
45. Primary destination, contextual entry point, back/deep-link behavior, state restoration, badge priority,
    one-handed reach, and proof that the current Main Quest action is reachable within the approved tap budget.
46. Screen hierarchy, dominant CTA, progressive disclosure, tradeoff visibility, destructive confirmation,
    commercial-content priority, and proof that representative players can identify the main action and risk.
47. Reusable component ID, approved variant, all reliability states, semantics, text scaling, localization,
    performance budget, analytics, and evidence that no duplicate component was introduced.
48. Luxe interface mode, interruption budget, prior-explanation memory, dismiss/snooze behavior, guidance-mode
    preference, fallback text, obstruction test, and prohibition on authority or pressure selling.
49. Proof-of-fun screen task completion, time on task, wrong-action rate, backtracking, error recovery,
    one-handed use, reduced motion, increased-text completion, frame-time, memory, and qualitative comprehension.
50. Phase-specific UI authorization, matching feature dependency, future-surface exclusion, feature-flag state,
    and proof that later-wave interface production did not delay a failed Early Game screen.

A Luxe-led FTUE is incomplete unless QA can verify first meaningful input within 45 seconds,
Founder Trial completion and comprehension, all three guidance modes, Ask Luxe behavior, server-owned
tutorial knowledge, reconnect/device resume, dialogue skip without choice loss, path reassignment,
accessibility alternatives, absence of monetization and competitive pressure, safe tutorial failure,
first Main Quest handoff, first House While Away lesson, and analytics for every major step. Luxe may
not spend, commit, accept, purchase, or make an irreversible decision for the player.

A feature is complete only when its causal loop works in profile or release mode and the
server-confirmed result is understandable. A route, schema, provider, or visual surface
alone is insufficient. Every active-wave feature identifies its server authority,
supports non-happy-path states, prevents duplicate mutation, and explains its result. An
idle or automation feature is incomplete unless QA can reproduce its settlement, inspect its
policy and audit trail, verify its cap and failure behavior, override it safely, and understand
its economic effect. A quest system is incomplete unless QA can verify eligibility, reset,
reroll, partial progress, offline progress, automatic claim, exact reward settlement, duplicate
protection, accessibility alternatives, and payer-neutral difficulty. An upgrade chain is
incomplete unless its purchase cadence and payback fall within an approved progression band or
has an explicitly documented exception. A monetization product is incomplete unless QA can verify
price and contents, purchase and cancellation, receipt validation, restoration, refund handling,
expiration or lapse, duplicate protection, platform restriction, offline recovery, economic
isolation, and every declared competitive-power exclusion.
A multiplayer feature is incomplete unless QA can verify cohort and division
placement, permissions, roster locks, anti-Sybil behavior, personal-asset protection, settlement,
appeal or dispute handling, new-player access, concentration caps, payer neutrality, and failure
states under disconnect, retry, leadership change, account restriction, and moderation action. A
Gala release is incomplete unless a new eligible House can reach a fair standardized entry, a full
Maison cannot gain raw roster-size score, blocked or linked accounts cannot manipulate votes or
rewards, and valid-entry through Crown rewards settle automatically without granting future
competitive power. An Atelier release is incomplete unless distinct players can author visibly
distinct valid garments from the same brief and make targeted revisions. An Architect release is
incomplete unless a player can diagnose, intervene, and observe a visible operational response in a
short session. A city is incomplete unless it passes the City Difference Test. A social feature is
incomplete if participation becomes required labor or leaders can coerce contributions. An endgame
feature is incomplete if its reward creates permanent competitive power or nearly all players select
one optimal identity. A milestone is incomplete if its Implementation Wave, unlock band, Feature ID,
owner, disable plan, operational cost, dependencies, and fun-gate evidence are undocumented.
A security-sensitive feature is incomplete if QA cannot prove that an owner can perform every allowed
action while a stranger, former member, blocked participant, anonymous caller, modified client, replayed
request, and over-privileged endpoint cannot. UI completion, a passing happy-path test, or the presence
of RLS does not satisfy this requirement. Multiplayer, premium currency, trading, DMs, UGC, and public
competition remain disabled until their authorization, fraud, backup, monitoring, moderation, and
incident gates pass.

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
| Luxe Credits | Purchasable and boundedly earnable premium currency |
| Aurelian Seals | Earned-only prestige currency |
| Alpha | Hype Score from 85 to 94 |
| Iconic | Hype Score from 95 to 100 |
| Aurelian Gala | Monthly fashion show with House and Maison tracks, divisions, standardized resources, and Crown Finals |
| Maison Vanta | First persistent rival house |
| Seraphine Vale | Founder of Maison Vanta |
| The First Cut | Luxe Season One |
| Trend Pulse | Daily minor demand movement |
| Trend Wave | Forecast 72-hour aesthetic movement |
| Trend Tsunami | Rare seasonal live meta event |
| Founder Trial | Two short onboarding samples that demonstrate Artisan and Architect play before specialization |
| Design Blueprint | Versioned authoritative garment state containing authored zones, geometry, materials, styling, and revision lineage |
| Design Signature | Descriptive pattern in a House's repeated creative choices; never a permanent score bonus |
| Recovery Loop | Failure response that explains causes and creates salvage, revision, or strategic recovery choices |
| Reaction Budget | Server-configured limit and priority hierarchy for presented NPC reactions |
| Gala Category Laureate | Theme-specific recognition outside overall placement, with bounded non-power rewards |
| Legacy Mandate | Optional seasonal endgame identity goal that builds institutional history without competitive multipliers |
| City Difference Test | Required evidence that a Production City changes Artisan and Architect decisions beyond art or flat modifiers |
| Implementation Wave | The authorized development stage in which a feature may be built or expanded |
| Player Unlock Band | The progression stage at which a completed feature becomes visible to players |
| Early Game / FTUE Foundation | First implementation wave proving the initial House loop through Rank 10 and the first week |
| Alpha Wave | Single-House stabilization and core-system expansion through approximately Rank 30 |
| Beta Wave | Controlled multiplayer and monetization-validation wave through approximately Rank 60 |
| Late Game Wave | Global institutional and competitive expansion for approximately Ranks 61–99 |
| End Game Wave | Rank 100+, Ascension, Legacy Mandates, and post-launch mastery systems |
| Ask Luxe | Contextual help control explaining the current decision, why it matters, and the next action |
| Luxe Guidance Mode | Player-selected Guide me, Brief me, or Let me work level of tutorial assistance |
| RLS | PostgreSQL Row Level Security policies that restrict each operation to authorized rows; one layer of defense, not the entire security model |
| Public Projection | Minimal reviewed player-facing record containing only explicitly public fields, separate from the private profile |
| Relationship-Scoped Data | Data readable only by current authorized participants such as a DM, contract, or Maison room |
| Security Invoker View | View that runs with the caller's privileges and respects underlying RLS |
| AAL2 | Supabase Auth session assurance level indicating successful second-factor verification |
| Append-Only Ledger | Immutable sequence of economic events used to derive and reconcile balances and ownership |
| Break-Glass Access | Emergency privileged access that is separately protected, audited, time-bounded where possible, and reviewed after use |
| Domain Freeze | Remote ability to stop one risky mutation class, such as premium grants or transfers, without disabling the entire game |
| Aurelian Ascension | Noncompetitive legacy and replayability system |
| NPC Taste Profile | Server-owned preference weights used to interpret structured design state |
| Named NPC | Persistent simulated character with evidence-based bounded memory |
| Customer Cohort | Aggregate population used for demand, loyalty, awareness, and sentiment settlement |
| NPC Maison | AI-controlled fashion empire constrained by the same economy and competition rules |
| AI Presentation Service | Non-authoritative service that turns structured results into bounded prose |
| Grounding Payload | Validated server context that limits what generated NPC content may state |
| Fashion-Taste Interpretation | NPC-specific opinion derived from frozen garment and context factors |
| Living Fashion World | Customers, institutions, counterparties, staff, rivals, and media that react to history |
| Luxe Quest System | Luxe-delivered Main Quests, Daily Briefs, and Weekly Commissions |
| Main Quest | Persistent authored objective that advances progression, systems, or narrative |
| Daily Brief | One of three short voluntary account-day objectives selected for current systems |
| Weekly Commission | Multi-session objective; completing any three of four earns the weekly capstone |
| Weekly Capstone | Guaranteed reward for completing three Weekly Commissions in one account week |
| Quest Timezone | Server-authoritative account timezone used for quest reset boundaries |
| Operations Assistant | First earned automation stage that repeats a transparent bounded default |
| Specialist | Automation stage that optimizes one declared objective with a visible drawback |
| Department Manager | Automation stage coordinating linked operations under player-set policies |
| Executive Policy | Late-game bounded rules applied across divisions with exception review |
| Buffer Stock | Capacity that determines how long an operation can continue while the player is away |
| House While Away | Authoritative offline settlement receipt and linked return actions |
| House Pass | Eight-week seasonal free and premium reward track without competitive power |
| Founder Pack | One-time fixed introductory bundle without exclusive gameplay access |
| Creative Studio Pro | Durable Artisan-oriented creation, organization, and export utility unlock |
| Operations Suite | Durable Architect-oriented administration and information-organization utility unlock |
| Founder Club | Optional subscription providing continuing content and bounded utility, never power |
| Additional House Slot | Durable entitlement for an economically isolated parallel brand |
| Narrative Expansion | Optional self-contained authored campaign beyond the complete free primary story |
| Scenario Pack | Isolated replayable tycoon challenge that does not alter the main House economy |
| Licensed Collaboration | Clearly disclosed optional branded content without hidden gameplay advantage |
| Creator Marketplace | Deferred moderated exchange for approved non-authoritative player-created assets |
| Maison | Player-created fashion empire with a launch cap of 10 members |
| Ranked House | The one House on an account eligible for ranked contribution during a season |
| Collection Contract | Versioned Artisan–Architect agreement covering ownership, funding, production, rollout, risk, and revenue |
| Maison Standing | Current-season normalized group performance across six competitive dimensions |
| Rising Division | Protected first-season competitive placement for legitimate new or rebuilding participants |
| District Territory | Temporary Maison influence over a bounded city district; never exclusive city ownership |
| Territory Cycle | Weekly forecast, declaration, preparation, response, settlement, and control process |
| Crown Final | Monthly Gala final producing the global top three in the House or Maison track |
| Gala Instance | Standardized isolated event state that equalizes functional resources and excludes paid power |
| Store Escrow | Server-controlled asset and currency settlement preventing unilateral or fraudulent transfer |
| Maison War | Scheduled opt-in competitive campaign with published rules, roster, budget, scoring, and rewards |

## 24. Version 7 Changelog

Version 7 consolidates the product vision into one self-contained specification and
establishes the causal loop as the organizing rule. It makes the first week persistent
and server-backed; turns Atelier, Mogul, Feed, Luxe, Vex, crises, rivals, and Gala into
connected consequence systems; normalizes scoring and economy formulas; separates Staff
Contracts from Icon Editions; defines idle, modes, Joint Venture, Ascension, and fair
monetization; replaces mixed authority with Supabase and PostgreSQL ownership; adds a
server-authority matrix and anti-cheat contract; and separates vertical-slice,
Alpha, Launch, Post-Launch, and deferred scope.

This version also adopts the repository’s `frontend-design` skill as the primary UI/UX
methodology while preserving the established Flutter design system and Aurelian visual
identity. It adds required states, result explanations, accessibility behavior, motion
fallbacks, low-performance fallbacks, and measurable 60 fps evidence requirements for
Onboarding, Atelier, Ledger, HQ, Feed, Luxe, Vex, crises, Gala, and all future major
interfaces.

The v7 idle-tycoon completeness pass retains the v7 designation and adds a player-earned
automation ladder, first-30-day unlock cadence, economy pacing and recoverability contracts,
active-versus-idle value targets, immutable offline settlement rules, the House While Away
return receipt, automation authority and analytics, roadmap requirements, glossary terms, and
feature acceptance criteria. These additions close the gap between the existing fashion
strategy simulation and a complete idle-tycoon progression experience without weakening
consequence, fairness, server authority, or voluntary engagement.

The v7 Luxe Quest System pass retains the v7 designation and defines Luxe as the in-world
assistant, mascot, and quest director. It adds persistent Main Quests, three Daily Briefs with a
free reroll, four Weekly Commissions with a three-objective capstone, server-authoritative reset
and reward settlement, automatic claim, eligibility and variety protections, premium-currency
earn targets, payer-neutral difficulty, quest UI, analytics, roadmap scope, glossary terms, and
acceptance criteria. Repeatable free Luxe Credit earnings are intentionally useful but bounded: normal output targets
5–10 Credits for casual participation, 12–20 for regular play, and 22–28 for highly engaged play,
with 30–35 reserved for exceptional event weeks. No quest requires purchases, advertisements,
external engagement, consecutive logins, or competitive victory.

The v7 monetization completeness pass retains the v7 designation and implements the full
non-pay-to-win product stack. It defines Luxe Credit pacing, the eight-week House Pass, Founder Pack,
Creative Studio Pro, Operations Suite, one additional isolated House slot, Founder Club, narrative
expansions, premium scenarios, optional capped rewarded advertising, licensed collaborations,
creator marketplace requirements, and large narrative seasons. It also adds entitlement classes,
storefront protections, platform receipt and restoration ownership, lapse behavior, monetization
analytics, roadmap gates, UI surfaces, glossary terms, and acceptance criteria while preserving the
rule that spending never raises competitive or economic ceilings.

The v7 competitive multiplayer pass retains the v7 designation and adds player-created Maisons
with a 10-member cap, recruitment and applications, role-based governance, personal-asset protection,
shared headquarters, contribution ledgers, Artisan–Architect Collection Contracts, regulated store
sales, leasing and franchising, Architect wholesale and logistics systems, bounded private messaging,
eight-week seasonal leagues, multidimensional leaderboards, newcomer and anti-snowball protections,
district territory control, scheduled Maison Wars, multiplayer authority and moderation contracts,
and analytics for concentration, safety, fraud, fairness, and cohort mobility. It converts the
Aurelian Gala from a weekly tournament into a monthly House and Maison fashion show with divisions,
standardized event resources, anonymous judging, anti-collusion controls, Crown Finals, meaningful
top-three premium rewards, automatic member settlement, and no permanent competitive power.

This revision also establishes the Living Fashion World. It adds structured customer populations,
NPC taste profiles, representative Feed behavior, persistent suppliers and manufacturers, buyers and
wholesalers, critics and institutions, influencers and stylists, celebrity clients, staff character
contracts, AI-controlled rival Maisons, investors and lenders, landlords, journalists, regulators,
brokers, mentors, event professionals, and counterfeit threats. It separates authoritative simulation
from NPC interpretation and generated presentation; forbids AI from determining Hype, sales, Gala,
territory, rankings, rewards, evidence, or moderation facts; and adds grounding, deterministic
fallbacks, safety, privacy, parity, cost, quality, analytics, roadmap, and acceptance requirements.

The same pass adds NPC role maturity tiers and release-blocking validation for fashion judgment,
Artisan intentionality and tactility, Architect agency and readability, partnership value, NPC
credibility, newcomer mobility, failure quality, player identity, and differentiation. Canonical
breadth no longer implies that every role must ship at full depth before the core loops prove fun.

The roadmap now begins with a disposable Kingston proof-of-fun prototype before the production
vertical slice. Three-city breadth, live multiplayer, open communication, monetization, and broad AI
content cannot substitute for a satisfying garment creation, reaction, revision, store diagnosis,
and Artisan–Architect cooperation loop.

This revision also replaces the closed three-city assumption with a Global Fashion City framework.
Milan is now a mandatory foundational Production City for the first launch wave. Kingston remains the
proof-of-fun reference city, while Paris, London, New York, and Tokyo enter the early world model and
progress through explicit maturity states. A Fashion City Registry, qualification test, city gameplay
contract, market-entry loop, non-exhaustive regional expansion roster, cultural-research requirement,
and post-launch promotion program allow every qualified fashion ecosystem to enter the world without
forcing shallow launch breadth or city reskins.

The v7 fun-completeness pass retains the v7 designation and converts the ten remaining design
risks into binding systems and gates. It adds the Founder Trial, early path reassignment and support
actions; zone-level garment authorship, Design Blueprints, Design Signatures, and targeted revisions;
visual Architect diagnose-intervene-observe play; Gala participation, personal-best, finalist,
category, division, contribution, and Crown recognition; voluntary cooperative Maison life;
Failure-to-Recovery contracts; City Difference Tests; NPC Reaction Budgets; Institutional Legacy
Mandates; and a four-ring scope-control constitution. It also expands UI, analytics, roadmap,
acceptance, glossary, and release-blocking validation so breadth cannot substitute for fun.

This v7 revision also restructures the entire specification into Early Game/FTUE, Alpha, Beta,
Late Game, and End Game implementation waves. It adds a master Feature ID registry, separates build
wave from player unlock band, defines IDE-agent execution and feature-flag rules, establishes explicit
do-not-expose boundaries, and adds phase promotion and rollback gates. The FTUE is now fully led by
Luxe through the Sanctuary opening, shared Founder Trial garment, adaptive guidance modes, Ask Luxe,
server-owned tutorial knowledge, safe failure, resume behavior, path comprehension, and first-return
debrief.

The v7 Supabase security completeness pass retains the v7 designation and replaces the informal
“top-tier security” goal with a high-assurance, testable defense-in-depth architecture. It adds a
formal threat model; private, public-projection, relationship, administrative, and secret data classes;
private schema isolation and explicit Data API exposure; owner-only and relationship-scoped RLS rules;
security-invoker views; hardened privileged functions; append-only currency and ownership ledgers;
server-authoritative transactional mutation; Auth, session, MFA, recovery, Edge Function, webhook,
Realtime, Storage, device-risk, staff-access, monitoring, incident-response, backup, PITR, secure-SDLC,
penetration-test, and responsible-disclosure requirements. It also adds phased SEC feature IDs, CI and
release gates, analytics, glossary terms, and explicit proof that no other player can access another
player's private data while required public and shared gameplay uses minimal controlled projections.
The document explicitly rejects any promise that an internet service is literally impossible to hack.

The v7 solo-developer feasibility pass retains the v7 designation and makes one-person, AI-assisted
development a binding production constraint. It separates canonical, implemented, and enabled status;
defines disposable prototype, Solo Alpha, Controlled Beta, first public launch, and post-launch
expansion targets; imposes strict work-in-progress limits; establishes thin-first depth, cancellation,
population-independent launch, and operating-cost rules; narrows Beta to asynchronous competition and
basic conditional Maisons; delays store trading, private DMs, territory, broad generative AI, utility
subscriptions, and additional House slots; and permits the first public release to ship with Kingston
as the only complete Production City and Milan as a focused expansion when necessary.

The v7 production UI/UX architecture pass retains the v7 designation and converts interface guidance
into a solo-developer implementation contract. It establishes a five-destination information
architecture, contextual routing, screen-priority rules, progressive disclosure, a finite state-complete
component library, four Luxe interface modes, six proof-of-fun core screens, distinct but coherent
Artisan and Architect interaction languages, phase-specific UI authorization, accessibility and
low-device requirements, task-based usability gates, granular UI Feature IDs, acceptance criteria,
and analytics. Full social, territory, marketplace, and End Game surfaces cannot enter production
before the core FTUE, HQ, Atelier, store, result, and offline-return experiences pass.

Binding continuity references: `THE_STYLISTE_GDD_v6.md` §§1–12,
`PROJECT_RULES.md`, and `VERIFICATION_PROTOCOL.md`.
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
specification. Baseline continuity is retained from `THE_STYLISTE_GDD_v6.md` §§1–12.

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
major causes and the next available decision. Continuity references: v6 §§2, 4.1, 5,
and 8.

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
completed through local state manipulation. Continuity: v6 §§1.1, 3.7, and 3.9.

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
exponential inflation. Continuity: v6 §§3.1–3.9 and 8.9.7–8.9.8.

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
taste. Additional cities follow vertical-slice validation. Continuity: v6 World Map,
§§5.3, 8.1, and 8.9.11.

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
server-provided breakdown. Continuity: v6 §§4.1–4.2, 8.9.3–8.9.5, 8.10, and 8.11.

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
decorative motion. Continuity: v6 §§8.9.2 and 12.2.1.

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
must not invoke a retired or duplicate authority path. Continuity: v6 §§6, 8.15, and
9.9; implementation verification also follows `PROJECT_RULES.md` and
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
simulation; digital fashion; larger live events; additional rival houses; and
additional Luxe seasons.

### Deferred pending validation

Voice chat; real-time shared Atelier; live runway streaming; hostile player takeovers;
player-owned public equities; external engagement rewards; blockchain and related
tokenized systems.

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

This version also adopts the repository’s `frontend-design` skill as the primary UI/UX
methodology while preserving the established Flutter design system and Aurelian visual
identity. It adds required states, result explanations, accessibility behavior, motion
fallbacks, low-performance fallbacks, and measurable 60 fps evidence requirements for
Onboarding, Atelier, Ledger, HQ, Feed, Luxe, Vex, crises, Gala, and all future major
interfaces.

Binding continuity references: `THE_STYLISTE_GDD_v6.md` §§1–12,
`PROJECT_RULES.md`, and `VERIFICATION_PROTOCOL.md`.
