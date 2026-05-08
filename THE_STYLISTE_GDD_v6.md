# THE STYLISTE — Game Design Document
**Version 6.0 · SkinTeethNerd Studios · Confidential**

---

## 1. Game Overview

Portrait-first mobile hybrid idle + tycoon fashion empire simulator. Players build a real-world fashion brand from zero to global dominance.

**Core Fantasy**: *"I could do that better than Off-White / Supreme / Gucci."*
**Tagline**: *"Your ideas. Your empire. Your rules."*

**Aurelian Radiance Palette**: Ivory (#FFFFF0) · Champagne Gold (#F7E7CE) · Soft Rose (#FFB7C5)

Two distinct paths chosen at start — **Designer** (creative/hype) or **Mogul** (profit/scale) — running on idle progression with a live social feed, real-market rivalry, equity markets, and regulatory systems.

---

## 1.1 Onboarding Flow — The Aurelian Sanctuary (7 Cinematic Screens)

A high-production, Aurelian Radiance cinematic onboarding sequence that establishes tone and captures player identity before the first gameplay loop begins.

| Screen | Name | Description |
|--------|------|-------------|
| 1 | **Aurelian Gate** | Minimalist White Marble Hall backdrop, Maison insignia, biometric fingerprint scan with haptic heartbeat. A **matte silk ribbon** drifts across the frame driven by Verlet Physics, settling as the player's touch is detected. Full-bleed ivory with a **liquid gold ripple** that pulses and expands in sync with each heartbeat vibration. Sets world tone. |
| 2 | **Origin Script** | Poetic 6-line manifesto rendered via **Light-Etched Calligraphy** — letters fade in like reflections appearing on glass, with Luxe narration. *"Every empire starts with a stitch. Every icon starts with a choice."* Player taps to progress. |
| 3 | **Sovereign Registry** | Brand naming screen. Minimalist input with live feed preview of how the brand name appears globally. |
| 4 | **Brand Selection** | Player picks HQ city and tier cards (High Luxury, Mid Luxury, Mass Market). City affects starting market and aesthetic vibe. |
| 5 | **Identity/Avatar Customizer** | Full 3D avatar customisation. Sets the face of the brand founder. |
| 6 | **Career Path Selection** | Split-screen decisive fork: **Artisan** (Designer track, creative/hype) vs **Architect** (Mogul track, profit/scale). |
| 7 | **Ascension Confirmation** | Role + tier confirmation with a **Radiant White-Out** effect — the screen floods with pure champagne-gold light before dissolving into the HQ. |

Luxe appears on every screen as guide. All screens are cinematic, haptic-rich, and irreversible where appropriate. After completion, Luxe delivers a personalised welcome and the player enters their path-specific HQ.

---

## 2. Core Gameplay Loops

### Designer Loop
Research trends → design via Verlet Physics Atelier → drop on Global Feed → chase Hype → refine Signature style. Every session is an act of cultural authorship.

### Mogul Loop
Read the room → make the **Power Move** → own the block → scale the empire. The Architect doesn't manage; they dictate terms. From the Golden Hour boardroom of the penthouse Ledger, every decision — a hostile acquisition, a supplier lock-in, a flash sale timed to a rival's stumble — is a stroke of financial theatre. The business is the art.

Idle income runs 24/7. Real-world stakes: events like **"Paris Eclipse"** represent market saturation by rivals — you lose your cool factor and must pivot via capital injection, a media campaign, or a breakout design co-signed by your partner. Daily trend pulse quests and cross-path synergy run through partnerships and Maisons.

---

## 3. Player Progression Paths

### Designer Path — The Artisan
- Commands the **Atelier**: a sun-drenched studio where every fabric choice is a declaration and every drop is a cultural event.
- Unlock fabric, technique, and effect tiers through creative sessions — each one compounding into a richer design vocabulary.
- Progress by creating and ranking **Alpha pieces** — scored by the Hype Score formula, judged by the feed, remembered in the Archive.
- Milestones: city unlocks, Signature Style perks, global trendsetter status, Aurelian Gala glory.
- Idle hype runs like a reputation that works while you sleep — generating passive followers and income from the brand's cultural gravity.

### Mogul Path — The Architect
- Commands the **Ledger**: a glass-walled penthouse boardroom where capital is deployed like a creative act and every deal is a power statement.
- Unlock store, supply, bank, and equity tiers through bold profit targets — each one expanding the empire's footprint and financial leverage.
- Progress by orchestrating deals, acquiring territory, and engineering market dominance — the Architect's art is systemic and sovereign.
- Milestones: district control, partnership slots, hostile acquisitions, IPO launches, empire-wide prestige.
- Idle revenue scales with owned assets — the empire earns while the Architect plans the next move.

Both paths share a unified **Brand Rank 1–100** level system with cross-path synergy via partnerships and Maisons. Path is chosen at onboarding. At **Rank 50**, a **Joint Venture** mode unlocks — players can activate both path systems simultaneously, managing the Atelier and the Ledger in parallel. This is a late-game expansion, not a reset; all prior progress is preserved and both idle streams compound together.

---

## 3.0 Main HQ Dashboard

The HQ is the player's home base — a portrait-first living screen that evolves with Brand Rank. The visual environment is a **Glass-Walled Penthouse** bathed in **Golden Hour** lighting — warm champagne-gold sunlight streaming through floor-to-ceiling windows, ivory marble surfaces, soft rose accents. The HQ visually ascends (higher floors, bigger windows, richer materials) as Brand Rank increases.

### Shared Elements (Both Paths)
- Portrait layout. Top: Brand Rank bar + total idle income ticker. Bottom nav tabs (Atelier/Ledger/Feed/Maison/Bank).
- **Brand Heat Meter**: A persistent horizontal gradient bar displayed immediately beneath the Brand Rank progress bar — always visible, always active. Renders as a cool-grey-to-champagne-gold gradient (0–100). At 76–100 (Iconic), the bar emits a slow gold pulse. At 0–25 (Cold), hairline Obsidian cracks appear along its edges, mirroring the HQ Tarnish state. Tap to open the Brand Heat breakdown panel (§8.9.7) showing all active inputs, decay rate, and current effects. This meter is the empire's vital sign — never hidden, never collapsible.
- Follower count + quick glance at global flex standing.
- Luxe shortcut button (daily check-in, tips); notification bell with deep-linked alerts.
- Global Feed preview strip (latest 3 posts from the network).

### Artisan (Designer) Path View
- **3D Garment Preview**: Large rotatable hero piece from the most recent active design session — live physics, tap to enter Atelier.
- **Recent Drops Grid**: Last drops with hype scores, follower reactions, and sales velocity.
- **Hype Meter**: Animated gauge rendered as a **Sun-Dial / Eclipse** — a circular dial that fills with pure white light as brand heat rises, tipping into Champagne Gold at peak. No pulse; a slow, solar sweep.
- **One-tap Quick Sketch**: Instant idle boost action from the home screen.
- **Trend Pulse Widget**: Live trend alignment score vs seasonal meta.

### Architect (Mogul) Path View
- **Empire Pulse Graph**: Animated 7-day revenue curve rendered as a rising champagne-gold arc — live, breathing, responsive.
- **Territory Heatmap**: Districts and cities rendered as a radiant aerial glow — yours burn brightest; rivals carry the Obsidian Tarnish mark.
- **Equity Console**: Stock price, portfolio value, 24h movement — all surfaced as live Aurelian data streams.
- **Power Move Slots**: Up to 3 bold, tactile one-tap commands — **Capital Strike**, **Lock the Block**, **Crown Play**. Context-sensitive; surface based on live market conditions.
- **Cash Flow Ribbon**: Real-time idle income ticker — the empire always earns.

---

## 3.1 Brand Rank Milestones (1–100 Shared System)

| Rank | Milestone |
|------|-----------|
| 1–10 | Tutorial complete. Basic Atelier/Ledger tools, first local city store, starter idle income. |
| 11–20 | Partnerships enabled. City expansion slot +1. Idle hype/revenue +20%. |
| 21–30 | First Maison invite. Global feed verification badge. Co-drop access. |
| 31–40 | Supply chain Tier 2 + basic loans. Path-specific signature perk. Market saturation resistance +25%. |
| 41–50 | International city unlocks + online stores. Hype multiplier on flex posts. Auto-partner search. |
| 51–60 | Advanced Maison leadership roles + equity/IPO unlock. Premium capsule drops. Idle treasury bonus. |
| 61–70 | Rival event immunity in 2 cities + stock investments. Brand prestige aura (feed visibility boost). |
| 71–80 | Empire mode: multi-Maison alliances + joint IPOs. 2× city dominance bonuses. |
| 81–90 | Legendary Alpha piece or mega-store chain + public stock offering. Global trendsetter status. |
| 91–100 | Full dominance. Permanent 3× idle multiplier, exclusive global events, "Icon" title on feed, **Aurelian Ascension** unlock. |

Progress via combined design/profit actions + idle time. Path-specific bonuses stack on shared rank.

---

## 3.2 Brand Rank Pacing

| Phase | Ranks | Timeline | Notes |
|-------|-------|----------|-------|
| Early Game | 1–25 | 3–7 days casual | Fast onboarding, frequent unlocks, quick idle ramps |
| Mid Game | 26–65 | 1–3 ranks/week | Systems fully open; focus on decisions, social, partnerships |
| Late Game | 66–100 | 2–6+ months | Prestige-focused; heavy idle scaling, empire optimization |

**XP Sources**
- 35% active actions
- 35% idle (scales higher late-game)
- 20% social
- 10% events

Daily streaks and weekly challenges boost casual players. Idle/active ratio shifts from 40/60 early to 60/40 late.

---

## 3.3 Idle Progression Mechanics

- Offline earnings (up to 24h) based on Brand Rank, owned assets (stores/supply/designs), Maison treasury share, and path multipliers
- Auto-scales: early game 40% idle contribution → late game 70%
- Passive boosters: completed Alpha pieces add permanent hype multiplier; stores generate compounding revenue
- Daily streak protection and auto-reinvest via one-tap "Empire Mode"
- Soft cap with decay timer; active play resets and accelerates

### 3.4 Idle Soft Cap Mechanics
- Full-rate offline earnings for the first 24 hours
- Soft decay after 24h: linear drop to 40% efficiency
- Active play (any session) resets decay and grants **Momentum Buff** (100% rate for 12h)

---

## 3.5 Aurelian Ascension (Rank 100)

- Optional one-time **Ascension** at Rank 100 — the player's empire is not reset but memorialised. The entire brand's history (designs, stores, equity, followers, Maisons) is converted into a **Golden Statue** permanently displayed in the **Hall of Sovereigns** — a shared prestige gallery visible to all players.
- The Golden Statue is a 3D sculptural render of the player's most iconic Alpha piece, plated in the Aurelian Radiance palette, bearing the brand name and Ascension date.
- Unlocks a new run with **stackable Aurelian Boons**: **+50% Idle Income & Hype Score** on all future runs, plus the ability to **carry over one "Classic" Alpha Piece** from the Ascended empire — a heirloom piece that enters the new run with its full legacy hype score intact.
- Permanent cosmetic flair: Aurelian frame on all Global Feed posts; "Sovereign" title on profile; exclusive Maison banner skin.

---

## 3.6 Accessibility & Progressive Complexity — The Layered Architecture

The Styliste is designed as a luxury experience first and a simulation second. Casual fashion fans should never feel like they walked into an industry boardroom by accident. The game's complexity is **opt-in** at every layer.

- **Progressive Unlocking**: Systems surface progressively over the first 1–2 weeks of play. The core loop — design or deal, earn, grow — is always the loudest signal. Advanced systems (equity markets, supply chain negotiations, Digital Product Passport compliance, hostile acquisitions) gate behind Rank milestones and never surface uninvited.
- **Casual Mode** *(default for all new players)*: Auto-optimised supply chain. Simplified crisis cards with clear outcomes. No numerical complexity visible unless the player seeks it. Fail states are gentle redirects, not punishments. DPP compliance is automated via the Seal of Approval passive system — the player never sees a compliance field. Ideal for anyone who wants the empire fantasy without the operations manual.
- **Expert Mode** *(toggle in Settings → Experience)*: Full simulation depth. Manual supply routing. Real negotiation risk and penalty windows. Full Hype Score formula visibility with live variable breakdowns. Manual DPP audit. Supply chain volatility at maximum. Higher event reward multipliers and exclusive Expert-only prestige cosmetics reward the commitment.
- **Empire Mode** *(unlocks at Rank 71, applies to both modes)*: The dashboard doesn't add new screens — it **ascends**. The HQ penthouse renders in a higher floor; the city view expands; multi-Maison alliance tools surface as a new Command Floor overlay. The transition is visual and ambient — the empire gets bigger, the view gets wider, and the tools reorganise around what matters most at that scale. No new menus. No tutorial interruptions. Just the natural weight of the empire being felt.
- **Always-visible Core**: Regardless of mode or rank, the HQ Dashboard always surfaces three things clearly: what to do next, how the empire is doing right now, and where Luxe is. No player opens the game into uncertainty.

**Mode Comparison — Concrete Differences**

| Setting | Casual Mode *(default)* | Expert Mode *(opt-in via Settings → Experience)* |
|---------|------------------------|--------------------------------------------------|
| Supply Chain Management | Auto-optimised. Seal of Approval passive system handles DPP compliance silently. | Manual routing across all tiers. Full disruption risk. DPP manual audit available. |
| Crisis Resolution | 3 simplified outcome cards (Apologise / PR Spend / Reform). Stakes visible in plain language. | All 5 resolution paths with full consequence modelling, Founder Rep impact preview, and escalation probability. |
| Idle Efficiency | **+15% base idle rate** to compensate for lower active-play depth. Decay timer extended to 30h. | Standard idle rates. Event reward multipliers **×1.5**. Exclusive Expert-only prestige cosmetics. |
| Hype Score Display | Simplified "Heat Gauge" — a gradient bar, no formula shown. | Full `Hype_Score = (Aesthetic_Alignment × Material_Quality) + Sovereign_Talent_Multiplier` formula visible with live variable breakdown per session. |
| Pricing Engine | 4 preset price tiers with automated demand response. | Full elasticity curve per city, live demand forecast, manual price input within any range. |
| Fashion Week Seating | Auto-assigned by Brand Rank. | Negotiable via active Critic Relationship investment (§8.9.12). |
| Fail States | Gentle redirects — no permanent damage from a single poor decision. Tarnish effects are muted at Phase 1 max. | Full Tarnish cascade (Phase 1–3). Unresolved crises escalate to Eclipse Events. Reputation Debt mechanic active. |
| Brand Heat Formula Visibility | Shown as a colour gradient only. Inputs listed contextually. | Full input weighting table visible in the Brand Heat breakdown panel. |

The toggle is located at **Settings → Experience → Mode**. Switching modes at any time preserves all progress — no penalty, no reset, no content loss. Expert players converting to Casual retain their empire but lose the Event reward multiplier; Casual players converting to Expert gain it immediately. Luxe acknowledges the switch with a personalised line.

---

## 3.7 Post-Onboarding "What's Next" Dashboard

Immediately after the final onboarding screen (Specialization), the player lands on a one-time **What's Next** screen before their first HQ view:

- **Split visual**: Designer loop vs Mogul loop illustrated side by side with animated previews
- **First-week goal list**: 3 concrete objectives (e.g. "Complete your first design session", "Open your first store", "Post to the Global Feed")
- **Brand Rank progress bar**: Rank 1 → 10 with milestone rewards shown ahead
- **Luxe guidance**: Short personalised prompt based on chosen path — e.g. *"Your Atelier is waiting, darling. Let's make something that breaks the internet."* (Designer) or *"The Ledger is open. Time to turn coin into empire."* (Mogul)
- Dismissible; returns to HQ. Not shown again after first session.

---

## 3.8 F2P Progression Strategies

Key strategies that keep free-to-play players competitive and engaged long-term:

- **Daily Streaks**: Luxe check-in rewards scale with streak length; streak protection item available as a free milestone reward at Rank 15
- **Maison Synergy**: Joining a Maison at Rank 21+ grants shared idle income multipliers and supply discounts that rival paid speed-ups
- **Smart Event Participation**: Seasonal and holiday events grant materials, boosts, and cosmetics equal to or better than IAP equivalents — rewarding consistent login
- **Path Specialisation**: Early focus on one path's systems compounds faster than trying to master both; Luxe guides F2P players toward this via contextual tips
- **Reputation Farming**: High Brand Reputation reduces loan interest, unlocks better suppliers, and attracts top talent — all F2P-achievable through consistent play
- **Efficient Upgrades**: Prioritising idle multipliers over cosmetics ensures F2P players' offline income keeps pace with the game's scaling
- **Community Trading**: Player marketplace for rare fabrics and store slots lets F2P players trade time-earned assets for currency

---

## 3.9 Path Specialisation

- **Designer (Artisan)**: Early game focus on creative output and hype generation compounds into a dominant social presence and high follower count — which directly feeds stock valuation, endorsement success, and late-game Maison influence. Specialise early.
- **Mogul (Architect)**: Early focus on profit targets, store expansion, and supply chain efficiency scales idle income exponentially. Margin optimisation in mid-game unlocks equity systems faster than general play.
- **Late-game balance required**: By Rank 60+, both paths require cross-path investment (Designers need some Ledger depth; Moguls need some Hype management) to unlock the highest-tier milestones and sustain city dominance.
- **Joint Venture (Rank 50)**: At Rank 50, both path systems unlock simultaneously — but the UI doesn't double in complexity. It **evolves**. The HQ Dashboard merges the Artisan and Architect views into a single **Command Floor** layout: the Atelier's 3D garment preview occupies the left half; the Ledger's Empire Pulse and Power Move slots occupy the right. Both idle streams display on a unified income ribbon at the bottom. Switching between systems is a single swipe — no loading, no nested menus. The Joint Venture feels like a promotion, not an overhaul. All prior progress is preserved and compounded. No reset, no currency cost — it is the game's single biggest milestone reward, and it should feel like one.
- Path identity is preserved: the player's original path sets their starting multipliers and Luxe's character arc. Joint Venture adds the second path on top — a satellite empire, not a replacement.

---

A stylised 2.5D globe rendered in **high-key, radiant glow** — ivory landmasses, champagne-gold city nodes, soft rose trade routes. Gentle rotation and parallax tilt. Accessed from the HQ nav bar.

### Visual Effects & Core Features
- **Radiant Fly-In**: On city tap, camera sweeps in with warm light bloom and particle effects into the target city.
- **City Nodes**: Pulsing champagne-gold pins per unlocked city — tap to reveal store count, market share %, and dominance status.
- **Customer Flow Particles**: Animated streams of micro-dots flowing between cities to visualise trade routes and sales momentum.
- **Market Heatmap Overlay**: Toggle between revenue density view (lime gradient) and hype density view (gold gradient). Smooth colour transitions.
- **Rival Markers**: Rival brands shown as **Obsidian Tarnish** nodes — dull, cracked-marble markers against the radiant map; tap to view their current city power and threat level.
- **Maison Territory**: Maison-controlled cities outlined with a champagne-gold aura and shared name badge.
- **Real-time Supabase sync**: Market share, sales, and follower impact reflected live.

### Path-Specific Map Features

| Feature | Mogul (Architect) | Designer (Artisan) |
|---------|-------------------|--------------------|
| Primary Action | Drag-drop stores, Power Move buttons, full logistics lines | Influence waves from designs, creative event placement |
| City Tap | Revenue stats + expand/upgrade store | Hype score + launch collection or event |
| Power Moves | Flash Sale, Hostile Takeover, Price War | Influence Wave, Viral Drop, Pop-Up Event |
| Map Overlay | Revenue heatmap + profit streams | Hype/trend heatmap + follower flow |
| Special Events | Competitor acquisitions, supply raids | Trend cascade events, runway activations |

---

### 4.1 Atelier UI
Portrait-first canvas with rotatable 3D garment model. Layer-based editor: silhouette base, fabric swatches, textures, trims, prints, hardware.

**Creation Flow**: Drag-drop elements from unlocked library. Real-time physics preview (drape, fit, movement). Color wheel + pattern generator. AI trend suggestions.

**Design Stats**: Auto-calculated hype score, sell potential, and cultural impact. "Alpha" pieces require perfect balance for legendary status.

**Session Types**:
- **Quick Sketch** — idle boost; low resource cost
- **Deep Session** — manual tweaks + higher quality; timers/resource costs for advanced tools

**Progression Ties**: Unlock fabric/tech tiers via Brand Rank. Designs feed directly into feed posts, co-drops, and idle sales. Signature style perks apply globally.

**Hype Score — The Economic Heartbeat**:

The Hype Score is not a single-use metric. It is the central engine that drives every downstream economic outcome in the game across both paths:

```
Hype_Score = (Aesthetic_Alignment × Material_Quality) + Sovereign_Talent_Multiplier
```

- **Aesthetic_Alignment** — Quantitative match (0.0–1.0) between the garment's design parameters and the current Trend Tsunami metadata. Derived from seasonal trend cycle data updated every 48 hours. A perfect alignment during a live Trend Tsunami window grants a ×1.5 bonus multiplier on top of the base score.
- **Material_Quality** — Base score from the fabric tier used (e.g. Alabaster Silk = 9.5 · Organic Cotton = 6.0 · Standard Cotton = 3.5 · Synthetic = 1.5). Higher tiers compound the alignment multiplier.
- **Sovereign_Talent_Multiplier** — A flat bonus added by any assigned **Tier IV (Aurelian Sovereign)** Creative Director. Ranges from +15 to +40 depending on the Sovereign's specialisation. If no Tier IV talent is assigned, this value is 0.

**Downstream Economic Impacts (Both Paths)**:
- **Follower Acquisition (§8.11)**: Hype Score is the primary coefficient governing NPC/AI follower growth rate and organic feed reach. Score above 80 triggers **Trend Surge** status; above 95 triggers a **Wave Rider** Global Feed badge and accelerated follower growth burst.
- **Idle Revenue Scaling**: Idle earnings per session scale as a direct linear function of Hype Score. Every 10-point band above 50 unlocks a higher idle revenue tier — making Hype Score an active concern for Mogul players as well as Designers.
- **Stock Valuation (§5.6)**: For brands with an active IPO, the Hype Score feeds directly into the dynamic valuation algorithm alongside revenue, market share, and Brand Rank. A high Hype Score creates share price volatility that rewards strategic timing — a viral drop can spike stock price; a scandal Tarnish event can crater it.
- **Endorsement & Talent Attraction**: Higher sustained Hype Scores lower the cost and improve the success rate of talent recruitment pulls and endorsement negotiations.

A score above 80 triggers a **Trend Surge** status; above 95 triggers a **Wave Rider** feed badge and a one-session stock price boost.

---

## 4.2 Atelier Physics Simulation

- Real-time cloth simulation on rotatable 3D avatar using optimised Verlet integration
- Per-fabric parameters: density, stiffness, elasticity, friction, drape coefficient, bend resistance
- Dynamic behaviours: gravity drape, stretch/compression, wrinkles, bounce, self-collision, body collision
- Avatar animations: idle pose, walk cycle, spin, wind gusts (adjustable intensity)
- Instant recalculation on any layer/fabric/trim change
- Touch controls: pinch to rotate model, drag for temporary wind/pose
- Mobile-optimised with adaptive LOD and shader fallback for 60 fps target

---

## 4.3 Avatar Customisation

| Feature | Options |
|---------|---------|
| Body Types | 8 presets (Slim, Athletic, Curvy, Plus-Size, Tall, Petite, Muscular, Hourglass) |
| Skin Tones | 24 realistic shades with warm/cool undertones |
| Hair | 30+ styles and colours |
| Face Presets | 12 combinations (eye shape, nose, lips, jawline) |
| Poses | 10 dynamic preview poses (walk cycle, spin, idle, runway strut) |
| Accessories | Jewellery, glasses, hats, scarves (non-interfering with garment layers) |

All changes instantly update the physics simulation. Body type directly affects cloth drape, stretch, and fit physics.

---

## 4.4 AR Garment Try-On & Street Snaps

- Light AR mode in Atelier: preview designs on real-world camera feed
- Shareable screenshots/videos for viral social posting
- Unlocked early; boosts follower growth and hype
- Bridges the gap between digital tycoon and real-world streetwear culture

**Sharing Mechanics**:
- Tap **Share** to export a 3-second looping AR clip or static screenshot
- Auto-populates a feed post draft with the garment name, hype score, and brand tag
- Shared AR posts gain a special **AR Drop** badge on the Global Feed — boosting visibility by 40%
- Players can react to others' AR Try-Ons with a "I'd Wear This" interaction (counts toward hype)
- AR posts that receive 100+ reactions trigger a **Viral Moment** bonus: +15% global followers for 6 hours

### AR Street Snaps

**AR Street Snaps** extend the Try-On into the real world — players place their full avatar (wearing their designed garments) into their real environment via the camera and take **Street Style photos**.

**How it works**:
- Activate from the AR mode: switch from garment-only preview to **Full Avatar Placement**
- Position your avatar in the real-world scene — street corner, café, park — using pinch/drag controls
- Tap capture for a photo or hold for a 5-second video
- Every Street Snap auto-generates a **game-branded QR code** embedded in the corner of the image — scanning it deep-links to the player's brand profile in-game

**Real-World Social Rewards**:
- Players can share Street Snaps to Instagram, TikTok, or any platform using the native share sheet
- When a shared Street Snap (with active QR code) generates 50+ external engagements (tracked via QR scan count back to the game), the player earns **Street Cred** rewards: rare materials, hype boost, or Legendary talent pull fragments
- A **Viral Street Snap** (500+ QR scans) triggers a special in-game event: the outfit is added to the "Streets Are Talking" section of the Global Feed and earns a one-week featured placement on the Trend Forecasting Tool
- New players who enter the game via a QR code scan are tagged as **referred** — the original player earns an ongoing idle bonus as long as the new player is active (up to 30 days)

---

### 5. The Mogul's Domain

### 5.1 Ledger UI — The Golden Hour Boardroom
The Ledger is the Architect's throne room — a portrait-first penthouse command centre rendered in the same Aurelian Radiance aesthetic as the Atelier. There are no spreadsheets here. There are **live empire readouts**, **power move consoles**, and **market intelligence feeds** displayed across backlit ivory panels with champagne-gold data streams.

- **Empire Pulse Graph**: Animated 7-day revenue arc rendered as a rising sun curve — gold fill, ivory baseline, soft pulse on each new data point.
- **Territory Heatmap**: City and district control visualised as a radiant aerial glow map — your held districts burn brightest; contested districts flicker amber; rivals' zones carry the Obsidian Tarnish mark.
- **Equity Console**: Live stock price displayed as an Aurelian ticker with portfolio net value and 24h movement — IPO launches and hostile acquisition options surface here as premium Power Moves.
- **Three Power Move Slots**: Context-sensitive one-tap commands — each rendered as a bold, tactile card. Current active options surface based on market conditions and rival activity. Examples: **Capital Strike** (flash sale timed to rival's weak moment), **Lock the Block** (rapid district acquisition), **Crown Play** (premium campaign targeting a rival's top demographic).
- **Cash Flow Ribbon**: A persistent bottom-of-screen income stream — real-time idle earnings ticking up with each passing second. The Architect always sees the empire breathing.

### 5.2 Store Operations
- **Physical Flagships** — city hype/loyalty
- **Online E-Commerce** — volume/scalability
- Auto-sell idle with separate dashboards; tied to supply chain and marketing

### 5.3 Deal Negotiation
Quick risk/reward sessions for vendor deals, endorsements, and expansions. Direct profit multipliers.

---

## 5.1 Supply Chain Logistics

- Tiered global suppliers unlocked via Brand Rank/profit: Local → Regional → International → Luxury
- Three categories: Raw Materials, Manufacturing, Logistics Partners
- Each supplier rated on Quality, Cost, Reliability, and Prestige
- Contract system: duration, exclusivity, volume commitments
- Logistics sliders: route selection, shipping method (air/sea), tariff/risk level
- Real-time global events (strikes, trade disputes, shortages) dynamically shift prices/availability
- Idle upgrades: warehouses, tracking, sustainable sourcing (hype bonus)
- Maison/partnership synergy: pooled access + major discounts

### 5.2 Supplier Negotiation Risks

| Risk | Effect |
|------|--------|
| Deal Failure | 40% chance of lost time/resources + supply shortage (idle revenue −30% for 24h) |
| Hidden Tariffs | Locked high fees if risk slider pushed; +25% costs until renegotiated |
| Quality Drop | Lowball offer triggers defective batch (hype penalty, −15% sell rate) |
| Supplier Backlash | Over-negotiation risks blacklist (tier downgrade 48h, no volume discounts) |
| Event Multiplier | Real-time global events amplify all risks/rewards 2× |
| Reward Flip ✓ | Successful high-risk roll grants exclusivity or 50% cost cut for 7 days |

---

## 5.3 Inventory Management

- **Ledger UI Panel**: Real-time global stock grid (per city/store). Colour-coded alerts: green (optimal), yellow (low), red (critical shortage/overstock)
- **Auto-Restock**: Idle system auto-orders based on sales forecast sliders; manual override for surges
- **Overstock Penalty**: Daily storage fees + hype decay if unsold >7 days
- **Shortage Penalty**: Stockouts cause immediate lost sales and −15% global feed visibility
- **Optimisation Tools**: Bulk transfer between stores, liquidation sales (quick cash but hype hit), predictive AI forecasts
- **Synergy**: Maison/shared partnerships auto-balance inventory across members; reduces fees 40%
- **Progression Tie**: Brand Rank unlocks larger warehouses, faster restock speeds, and risk-free buffer stock

---

## 5.4 Marketing Mechanics

- Campaign Builder with presets/custom, budget sliders, ROI forecasts
- **Effects**: +30–100% sales/hype (24–72h), feed visibility surge
- **Risks**: Over-spend = hype fatigue (−48h engagement); mistimed = rival counters
- **Synergy**: Maison pooling = 40% lower cost, city/global scale
- **Progression**: Brand Rank unlocks premium channels (Fashion Week, billboards, celebs)

### 5.4.1 Campaign Builder Details
- One-tap presets: Social Blast, Influencer Drop, Runway Event, Targeted Ads
- Custom mode: drag elements, set budget/duration/audience (cities/paths/Maisons)
- Live preview: ROI graph, risk meter, projected sales/hype
- Launches from Ledger; auto-ties to inventory forecast

---

## 5.5 Central Bank & Equity System

- Borrow tiered loans (credit score tied to Brand Rank/reputation); pay off debt
- Issue/sell shares publicly (stock ticker on global feed) or privately
- Invest in other brands/Maisons for dividends and voting rights
- Portfolio dashboard, hostile takeovers, joint IPOs with partners
- Market volatility events add risk/reward. Integration with stores for revenue-backed shares

### 5.6 Equity Trading Mechanics

- IPO unlocked at Brand Rank 60
- Dynamic valuation based on revenue, hype score, market share, Brand Rank, and recent performance
- Public Stock Marketplace with live ticker on global feed
- Issue common/preferred shares; set dividend payout ratios
- Voting rights at 10%+ ownership; hostile takeover at 51%+ ownership
- Shares usable as loan collateral. Risks: dilution, market crashes

---

## 5.7 Mini-Games

The core loop stays fast and thumb-friendly. Two mini-games are always accessible; the remaining four are **Maison Event exclusives** — rare, high-stakes moments that feel special rather than routine.

### Core Mini-Games (Always Accessible)

#### Price War Blitz
- **Trigger**: Rival undercuts your city price by >20%
- **Mechanic**: Tap-rhythm on price sliders — hit price adjustment beats before the rival locks in their discount. 3 rounds. 8–15 seconds.
- **Win Reward**: +35% city sales 12h, rival loses 10% market share
- **Lose Penalty**: −15% revenue for 6h, rival claims price advantage

#### Flash Sale Frenzy
- **Trigger**: Manual Power Move or stock surplus alert
- **Mechanic**: Swipe to catch falling customers — match incoming order cards to correct product slots. 60-second sprint.
- **Win Reward**: Clear 48h of inventory in 10 minutes, +Followers, +Hype spike
- **Lose Penalty**: Partial clearance only; remaining stock starts overstock penalty timer

Both are 8–15 seconds, thumb-friendly, with haptic feedback, screen shake, and direct Ledger impact.

### Maison Event Exclusives (Rare — Triggered by Maison War, Fashion Week, or Eclipse Events)

| Mini-Game | Trigger Context | Mechanic Summary | Stakes |
|-----------|----------------|-----------------|--------|
| **Supplier Raid** | Maison War: rival targets shared supplier | Drag-and-drop resource pull — 4-card hand vs rival bid | Win: 14-day exclusive contract; Lose: 48h sourcing gap |
| **Hostile Takeover** | Maison Eclipse event (Rank 60+) | Tug-of-war ownership bar — 5 rounds, live price ticker | Win: absorb 20–50% rival idle income; Lose: wasted capital + retaliation |
| **Power Move Combo** | Mogul: 3 Power Moves in 24h during Maison War | Drag icons into sequence for escalating multipliers | All rewards ×1.5; Sovereign Moment broadcast; 72h cooldown |
| **Staff Rally** | Fashion Week: talent morale below 40% at event start | Tap-rhythm on staff icons; Luxe coaches via dialogue tree | Win: full morale + loyalty bonus; Lose: walk-off event, show disruption |

Maison Event mini-games are opt-in for the triggering Maison member and notify the full Maison when active.

### 6.1 Global Live Feed — TikTok-Style Social Network

The Global Feed is the game's social heartbeat — a **full-screen vertical scroll** (portrait-native, swipe-up pagination) that functions as a social network, not a notification list.

**Feed Card Format**:
- Full-bleed 3D garment preview or lookbook image
- Brand name, rank badge, hype score, and Vex critic quote (if reviewed)
- One-tap reactions: ❤️ Like / 🔥 Hype / 👁 Save / 💬 Comment / 📩 DM / 🤝 Collab Request
- Swipe left: dismiss. Swipe right: Save to Lookbook. Double-tap: Like.

**Remix & Stitch System**:
- Any player can **Remix** another player's posted design — takes their silhouette/base and lets you apply your own materials, palette, and trims
- Any player can **Stitch** two existing designs into a new co-creation — combines visual elements from both
- Both require the original creator's **Remix Permission** setting (on by default; toggleable)
- **Profit Share**: Remix drops auto-negotiate a revenue split with the original creator (default 70/30 in original creator's favour; negotiable). Real-time idle distribution to both wallets.
- Remix and Stitch drops are tagged with attribution on the Global Feed — both players gain follower exposure
- **Chain Remixes**: A Remix of a Remix creates a lineage tree visible in the Brand Story Archive — the original creator earns a small royalty from every generation

**Feed Algorithm**:
- Personalised by: followed brands, path type, current Trend Tsunami alignment, Maison affiliations, and recent interactions
- Trending tab: top 24h posts globally + Trend Tsunami wave riders
- Regional tab: city-specific feed filtered to the player's current market focus

### 6.2 Partnerships
- Instant formation via feed DM or Collab button
- Optimal synergy: Designer + Mogul (art + scale)
- **Benefits**: co-drop limited capsules (auto-sell faster), shared supply chains/stores/marketing costs, joint Maison ownership for city dominance
- Visible on global feed; creates rival events and hype boost

#### 6.2.1 Profit Splits
- Negotiated at formation (any ratio, 50/50 default)
- Applies to all joint revenue: co-drops, shared stores, supply chains, marketing
- Real-time idle distribution to both wallets
- Adjustable anytime by mutual agreement
- Publicly displayed on feed and profiles for transparency/hype

---

## 6.3 Maisons

Guild-like player houses; create or join via feed invites, search, or public recruitment.

- 5–20 members (mix of Designers + Moguls optimal)
- Pool resources: shared treasury, supply-chain discounts, marketing fund
- Co-own and upgrade stores in cities; split revenue automatically
- City dominance: collective market control grants exclusive bonuses, rival protection, and global flex
- Joint capsules/drops and Maison-only events with hype multiplier
- Internal chat + private feed; visible prestige on global feed
- Leadership roles and voting for decisions

### 6.3.1 Maison Leadership Roles

| Role | Cap | Path Preference | Power |
|------|-----|-----------------|-------|
| Founder/Leader | 1 | Any | Full control — invite/kick, dissolve, appoint roles, treasury veto |
| Creative Director | 2 | Designer | Approves co-drops, sets design themes; hype multiplier |
| Executive Director | 2 | Mogul | Manages treasury, stores, profit splits; revenue bonus |
| Brand Director | 2 | Any | Handles recruitment, global feed posts, marketing |

Roles appointed by Leader or elected by majority vote (30-day terms). Major decisions require 2/3 leadership approval.

### 6.3.2 City Dominance Bonuses
- 2× revenue from all co-owned stores in the city
- Exclusive supply-chain discount (30% lower costs for all members)
- Automatic hype multiplier on global feed posts (+50% engagement/likes)
- Rival protection: rivals cannot trigger market saturation events in the city
- Maison-only limited capsule drops with premium pricing
- Global flex badge on all member profiles; auto-broadcasts city ownership

### 6.3.3 City Dominance Mechanics (Threshold System)
- **Capture threshold**: 51% combined market share in a city triggers City Dominance status and activates all bonuses above
- **Maintenance floor**: If collective market share drops below 45% (through rival aggression, low activity, or event loss), a 7-day **Grace Period** begins — visible to all Maison members with a countdown timer and Luxe alert
- **Grace Period**: Members have 7 days to recapture share via campaigns, co-drops, or Power Moves before dominance is lost and rival protection drops
- **Rival Challenges**: Any rival Maison with 30%+ share in the same city can formally declare a **Dominance Challenge** — a 72-hour market share war with winner-takes-all city control
- **Solo Dominance**: Solo players (no Maison) can achieve city control at 51% but receive reduced bonus tiers (1.5× revenue, 20% supply discount) and no rival protection — Maison collective strength is the optimal path

---

## 6.4 Expanded Social & Multiplayer Features

- Global + regional live feeds with trending hashtags, story replies, and viral challenges
- Real-time multiplayer: co-hosted Fashion Week runway events, live bidding on rare supplier contracts
- Leaderboards: city/global, per path, Maison rankings
- Player market: trade rare fabrics, store slots, endorsement contracts
- Cross-player rival "beef" mode with public diss tracks and bet-based challenges
- Voice chat and group DMs inside Maisons and partnerships

## 6.5 Additional Social & Multiplayer Hooks

- Live runway streaming with real-time audience reactions and voting
- Weekly themed challenges with community voting and prizes
- Follower system with engagement metrics that drive passive hype/sales
- Public drama feed showing alliances, rivalries, and betrayals
- Collaborative capsules and real-time shared Atelier for partners
- Stock ticker integration for public share sales and investments

## 6.7 Social Competitions

Structured competitive events layered on top of the always-on social feed — driving short-term engagement spikes and Maison rivalry.

| Competition | Format | Duration | Scope |
|-------------|--------|----------|-------|
| **Weekly Challenges** | Themed design brief or business target; community voting for top entries | 7 days | Global / Regional |
| **Maison Wars** | Head-to-head **District Control** battles — Maisons fight for specific city blocks (e.g. SoHo in NYC, Harajuku in Tokyo, Le Marais in Paris, Shoreditch in London), not just whole cities | 72 hours | City-district |
| **Rivalry Showdowns** | 1v1 or small-group bet-based challenge between individual players | 24–48 hours | Player-initiated |
| **Seasonal Grand Prix** | Season-long leaderboard across all paths; multiple scoring categories | 28 days | Global |

All competitions are opt-in. Non-participants are unaffected by outcomes.

### District Control (Maison Wars Expansion)

Cities are subdivided into **named districts**, each with their own aesthetic identity, customer demographic, and hype modifier. Maisons fight for district control rather than whole-city dominance — creating intense micro-rivalries and community identity.

**Example Districts by City**:
| City | Districts |
|------|-----------|
| New York | SoHo (streetwear), Tribeca (luxury), Williamsburg (indie/underground) |
| Tokyo | Harajuku (maximalism), Ginza (high luxury), Shimokitazawa (vintage/artisan) |
| Paris | Le Marais (emerging), Saint-Germain (heritage luxury), Pigalle (hype/street) |
| London | Shoreditch (underground), Mayfair (prestige), Notting Hill (celebrity casual) |

**District Mechanics**:
- Each district has a **Cultural Identity Score** — designing and selling in alignment with the district's aesthetic DNA grants bonus hype. Harajuku rewards maximalism. Mayfair rewards restraint. SoHo rewards the streets. The district knows what it wants, and it remembers who delivered.
- **Controlling a district is not a revenue transaction. It is a claim on fashion history.** When a Maison captures SoHo, they don't just earn revenue bonuses — they become the cultural custodians of that block. The district's aesthetic legacy is now part of their brand story. The **District Badge** is issued to all controlling Maison members and displayed permanently on their Global Feed profile, posts, and brand cards — a neighbourhood-level prestige marker that signals *we own this corner of the world*.
- Multiple Maisons can control different districts in the same city — no district is ever fully settled. The micro-rivalry between Le Marais and Saint-Germain Maisons in Paris is its own ongoing narrative.
- District-level battles are shorter, cheaper, and fiercer than full city wars — more frequent cycles mean more community storytelling, more rivalries, more alliances, and more moments worth posting about.
- **District Legacy**: Districts controlled for 30+ consecutive days earn a **Legacy District** marker — the Maison's name appears as a semi-permanent watermark on that district's map node for all players. This is the closest the game gets to owning a piece of fashion history permanently.

## 6.8 Challenge Reward Systems

Tiered reward structures ensure both casual and dedicated players find value in competitions:

| Tier | Criteria | Reward Examples |
|------|----------|-----------------|
| **Bronze** | Participation + minimum threshold | Cosmetic item, small idle boost, 1h offline credit |
| **Silver** | Top 25% placement | Rare fabric swatch, hype multiplier (24h), Luxe reaction animation |
| **Gold** | Top 5% or win | Exclusive material unlock, permanent title badge, treasury bonus, Aurelian Ascension boost |

**Additional mechanics**:
- **Streak Bonuses**: Competing in 3 consecutive Weekly Challenges grants a Loyalty Streak cosmetic and +10% idle boost for the following week
- **Maison Collective Rewards**: If a Maison places 3+ members in Gold tier of the same competition, the entire Maison receives a treasury dividend
- **F2P Safeguards**: All top-tier rewards are achievable through skill/consistency; no reward is exclusively purchasable

---

## 6.9 The Aurelian Gala — Weekly PvP Tournament

The highest-stakes social event in the game. Run every **Sunday, 48-hour window**.

### Format
- **Designers** submit one **Alpha piece** as their entry, staged on the **Void of Radiance** runway — a hyper-minimal ivory-and-liquid-gold catwalk rendered in high-key lighting where the garment is the sole focus. Judged on hype score, trend alignment, and community votes.
- **Moguls** act as **Sponsors** — they back a Designer entry with a funding pledge (in-game currency). If their sponsored Designer wins, the Mogul earns a major return; if they lose, the pledge is lost.
- Voting is weighted 50% community vote via **Radiance Reactions** (❤️ Adore · ✨ Iconic · 👑 Sovereign · 🤍 Timeless), 50% hype score over 24 hours. Each Radiance Reaction carries a distinct weighted multiplier: Sovereign (×2.0) > Iconic (×1.5) > Timeless (×1.2) > Adore (×1.0).

### Rewards
- **1st Place Designer**: Entry piece displayed on the **loading screen of every player worldwide for 24 hours** — the ultimate social flex. Permanent "Gala Sovereign" badge on profile. +Legendary talent pull ticket. The winning garment is wrapped in the **Sovereign Shroud** — a permanent liquid-gold garment shader applied to that Alpha piece, visible to all players on the Global Feed and in the Hall of Sovereigns.
- **Top 3 Designers**: Exclusive Gala cosmetic (avatar outfit, HQ theme in Aurelian Radiance palette), major hype multiplier (72h), Global Feed feature placement
- **Winning Mogul Sponsor**: 3× return on pledge, "Kingmaker" title for 7 days, portfolio value spike
- **All Participants**: Aurelian Gala participation badge, minor idle boost

### Rules & Social Mechanics
- Submit or sponsor once per week. Entry requires Brand Rank 15+ (Designer) or Rank 20+ (Mogul)
- Luxe provides personalised commentary on your entry and the top winners each week
- Winners become temporary celebrities — other players can DM, collab-request, or challenge them
- Maisons coordinate entries; the Maison with the most Top 10 placements earns a Maison-wide treasury bonus
- All entries archived permanently in the player's Brand Story Archive with their placement

---

## 6.10 Player Reporting System

### Access Points
- Long-press any feed post → "Report Post"
- Player profile → "Report Player" button (three-dot menu)
- In chat/DM → report user or specific message
- Leaderboard, rival list, or search results → report option

### Reporting Flow (3 taps max)
1. One-tap "Report" opens a clean modal
2. Pre-filled categories: Harassment · Cheating/Botting/Hacking · Spam · Inappropriate Content · Copyright/IP Theft · Guidelines Violation · Other
3. Optional short description + screenshot attachment (gallery or in-game capture)
4. Submit → Luxe confirmation: *"Thank you, darling. We'll look into this."*

### Backend
- Reports stored in Supabase table `player_reports` (reporter_id, reported_id, reason, description, screenshot_url, status, timestamp)
- Immediate email notification to SkinTeethNerd Studios
- Status tracking visible to the reporting player in the Support tab

### Anti-Abuse
- 30-second cooldown between reports from the same player
- Rate limiting per device and account
- Automated flagging for high-severity or repeated reports

---

## 7. Rival Mechanics

- Market share % contested in every major city (players vs NPC + active player rivals)
- **Eclipse Events** ("Paris Eclipse", "Tokyo Takeover"): rival dominance causes hype/revenue loss
- Rivalry actions: price undercutting, targeted marketing, supplier poaching, hype-jacking
- Feed rivalry: public flexing, dissing, callouts
- **Counterplay**: counter-campaigns, superior Alpha drops, anti-rival alliances, temporary truces
- Rivalry Score builds over time; high score = special events + bigger victory rewards
- Dominating rivals grants bonus idle income, prestige titles, temporary city control bonuses

### 7.1 Deepened Rival Counterplay Tactics
- Timed Alpha counter-drops to steal hype
- Geo-targeted counter-campaigns to reclaim cities
- Supplier/influencer poaching reversal
- Temporary Maison anti-rival alliances
- Feed callouts/diss for public swing
- PR/crisis management investments

---

## 7.2 Fashion Event System

- Seasonal calendar: Spring/Summer, Fall/Winter + Pre-Season, Resort
- Major global events: Paris / Milan / NY / Tokyo / London Fashion Weeks
- Player participation: submit collections, host pop-ups, run runway shows
- Rewards: hype/sales multipliers, prestige, contracts
- Risks: high costs, prestige loss on failure
- Tied to real trends for immersion

### 7.3 Seasonal Event Details

| Property | Detail |
|----------|--------|
| Unique Themes | Sustainable Innovation, Streetwear Revolution, Heritage Revival, Digital Fashion Future |
| Event Types | Themed Collection Challenges, Market Domination Races, Maison Competitions, Celebrity Pop-ups, Global Leaderboards |
| Rewards | Temporary multipliers (hype, sales, followers, stock), exclusive materials, badges, equity boosts |
| Duration | 14–28 days |

### 7.4 Holiday Fashion Events
- Time-limited, high-impact events tied to real-world holidays (Valentine's Day, Halloween, Christmas, Lunar New Year, Pride Month, Black Friday)
- Themed challenges with specific design briefs, colour palettes, or concepts
- Massive global feed exposure and special leaderboards
- Exclusive holiday materials, patterns, and capsules
- High risk/high reward with strong Celebrity Endorsement synergy

---

## 8. Realism & Simulation Systems

### 8.1 Seasonal Trend Cycles
- Game follows a real-time yearly calendar with 4 major seasons + Pre-Season forecasting windows
- Trend Forecasting Tool in Atelier and Ledger (higher Brand Rank = better accuracy)
- Trending categories: colours, silhouettes, fabrics, and cultural aesthetics
- Designing in line with trends grants major hype and sales multipliers
- Misaligned designs receive "outdated" or "off-trend" penalties

### 8.1.1 Real Fashion Industry Trends Integration (2026 Meta)

The game's trend engine references documented real-world fashion industry movements. These are woven into seasonal events, trend forecasting tools, and design score modifiers:

| Trend | In-Game Mechanic |
|-------|-----------------|
| **AI + Digital Fashion** | Digital-only drops available as NFT-adjacent collectibles on the Global Feed; AI Styling Assistant unlocks at Rank 40 for auto-trend suggestions |
| **Circular / Regenerative Fashion** | Upcycled material tier unlocks; Sustainability Score bonus; dedicated "Second Life" capsule drop event |
| **Quiet Luxury vs Dopamine Dressing** | Seasonal meta swings between restraint (high prestige, low hype) and maximalism (high hype, lower prestige); player must read the shift |
| **Gender-Fluid / Inclusive Sizing** | Designing across all body type presets in a single collection grants Inclusive Design bonus (+20% follower acquisition); unlocks broader customer segments |
| **Supply Chain Transparency** | Enabling "Transparent Sourcing" toggle in Ledger boosts loyalty and media score; penalises brands caught with ethical violations |
| **Resale / Vintage Revival** | Player-to-player marketplace for rare past-season designs; retired Alpha pieces gain "Vintage Premium" value multiplier over time |
| **Celebrity Micro-Trends** | Random weekly micro-trend events tied to fictional celebrity personas (inspired by real archetypes); alignment grants 48-hour viral window |

### 8.1.2 The Trend Tsunami (Live Global Meta System)

Every **48 hours**, the collective design output of the top 1% of active players shapes a **Global Aesthetic** — a user-generated meta that ripples across every market in the game.

**How it works**:
1. The system analyses the most-liked, most-dropped, and highest-hype designs posted to the Global Feed in the past 48 hours among top-tier players
2. The dominant aesthetic cluster (e.g. "Cyber-Goth", "Coastal Quiet Luxury", "Harajuku Maximalism") is declared the **Trend of the Wave**
3. A broadcast goes to all players via Luxe: *"The streets are speaking, darling. This wave belongs to [Aesthetic]. Ride it or get left behind."*
4. For the next 48 hours, designs that align with the Trend of the Wave receive a **+40% hype multiplier** and a special **Wave Rider** badge on the Global Feed
5. Misaligned drops receive a **−10% hype penalty** — not punishing, but meaningful

**Why this matters for retention**:
- The meta is entirely player-driven — no two 48-hour windows are the same
- Creates daily urgency: players check in to see what the Tsunami has declared
- Top 1% players feel real influence over the global game economy — a powerful prestige lever
- Community discussion, Maison strategy meetings, and social rivalry all organise around predicting/shaping the next Tsunami
- Designers try to set the trend; Moguls bet supply and pricing on it — perfect cross-path tension
- Every material, fabric, and manufacturing choice has a visible Sustainability Score and Carbon Footprint
- Premium eco-materials cost more but boost hype, loyalty, and media favour
- Unlockable certifications: Organic, Fair Trade, Carbon Neutral
- **Fast Fashion** (cheap, fast, low hype) vs **Slow Fashion** (expensive, sustainable, high prestige)

### 8.3 Celebrity Endorsement System

**Tiers**: Micro-Influencers → Rising Stars → A-List Celebrities → Global Icons

**Contract Types**:
- One-off campaign (1–4 weeks)
- Seasonal Ambassador (3–6 months)
- Long-term Brand Face (6–12+ months)

**Negotiation**: Mini-game in Ledger with 3-round bidding — sliders for fee, duration, exclusivity, creative control, morality clauses, and performance bonuses.

**Influencer Collaboration Tiers**:

| Tier | Cost | Reach | Effect |
|------|------|-------|--------|
| Nano | Low | Local | Authentic, grassroots |
| Micro | Moderate | Targeted | Co-design, niche hype |
| Mid | Balanced | Regional | Balanced campaign |
| Macro | High | Viral | Feed takeover |
| Mega | Premium | Global | Maximum flex, stock lift |

**Risks**: Scandal (5–25% chance, scales with contract length/fee mismatch); hype fatigue (−30% after 4 weeks); ghosting (low morale); positive glow-up (+50% sales if aligned). Mitigation via PR, morality clauses, reputation buffer.

### 8.4 Intellectual Property Protection
- Pay to trademark key designs or collections
- Risk of design theft by rivals/NPC brands
- Counterplay: public callouts and legal action (lawsuits)
- Protected designs gain "Signature" status with extra hype value

### 8.5 Global Economic Volatility
- Dynamic events: inflation spikes, recessions, currency fluctuations, luxury market booms
- Events affect production costs, consumer spending, and pricing per city
- Mitigation via city diversification and stockpiling

### 8.6 Customer Demographics & Loyalty
- Each city has unique customer segments with distinct preferences
- Loyalty meters per city/segment — consistent quality increases repeat buyers and premium pricing
- Detailed demographic analytics available in the Ledger

### 8.7 Media & PR System
- Fashion media outlets, critics, and publications provide reviews and ratings
- Positive reviews create hype multipliers; negative coverage causes damage
- Players can run PR campaigns or crisis management

### 8.7.1 The AI Critic — Procedural Design Reviews

An AI critic persona — **"Vex"** — integrated with the Luxe mentor system and active from Brand Rank 10+.

**Personality**: Vex is sharp, occasionally brutal, occasionally glowing — never neutral. Where Luxe is warm and encouraging, Vex is the industry's cold eye. Together they represent the duality of fashion: your champion and your harshest judge.

**How it works**:
- After each completed design session, Vex generates a **procedural review** based on visual analysis of the 3D garment model — materials used, silhouette type, colour palette, trim choices, trend alignment, and cultural timing
- Reviews are 2–4 sentences, snarky or celebratory depending on actual design quality metrics
- Reviews appear as a **Critics Corner** card in the feed post when a design is dropped

**Example Vex outputs**:
- *"An oversized deconstructed blazer in dead-season burgundy. Brave or oblivious? The market will decide in about 48 hours. I already know."* (Off-trend, high quality)
- *"This is the piece the Trend Tsunami demanded. Right material, right moment, right silhouette. I hate how correct this is."* (On-trend, perfect execution)
- *"Maximalism isn't a crime. But this? This is evidence."* (Poor composition)

**Mechanics**:
- Vex's review appears on the design's Global Feed card — visible to all players. High-praise reviews generate +15% additional hype; scathing reviews generate curiosity clicks (+10% views but −5% direct sales conversion)
- Players can **Commission a Re-Review** (costs in-game currency) if they update the design — Vex responds to revisions
- Vex's review history is stored in the Brand Story Archive as a critics' log — a source of pride or narrative drama
- Luxe and Vex occasionally "argue" in adjacent pop-ups, creating entertaining dual-perspective moments

### 8.8 Additional Realism Features
- Talent management: hire/manage stylists, models, marketers (skills, salary, morale)
- Photoshoot & lookbook production for hype boosts
- Wholesale/retailer licensing deals
- Dynamic demand curves and pricing engine per city
- Brand heat/reputation meter (affected by consistency, scandals, trends)
- Quality control with defect risks

### 8.9 Fashion Industry Regulations
- Compliance meter for: labour laws, environmental standards, advertising rules, import/export tariffs, IP enforcement
- High compliance grants reputation/loyalty/media bonuses and lower costs
- Violations trigger fines, reputation damage, and temporary restrictions

---

## 8.9.1 Digital Product Passport (DPP)

The **Digital Product Passport** is a real-world EU regulatory requirement (ESPR — Ecodesign for Sustainable Products Regulation) becoming mandatory for textiles. In The Styliste, it functions as a high-stakes unlock for European market access.

**In-Game Mechanic**:
- Unlocked via **Tier 3+ Sustainability Certification** + **active use of eco-tier suppliers** (Tier 3+ across Raw Materials, Manufacturing, and Logistics). No manual data mapping required — the DPP is auto-compiled from existing supplier metadata in the Ledger, making it a **Passive Prestige** reward for good supply choices rather than a compliance chore.
- Grants access to **EU City Market** (Paris, Milan, Amsterdam) — locked to non-DPP brands at Brand Rank 50+
- Adds a **verified traceability badge** to feed posts and store listings — boosts hype, pricing authority (+15% premium tier access), and media score
- Enables **Circular Revenue**: DPP-verified pieces are eligible for the in-game resale marketplace with premium listing status

**Compliance Risks**:
- **Random Audits**: At Rank 50+, EU cities trigger quarterly audit events. Failed audits (inaccurate supply data) result in temporary EU market ban (72h), hype penalty, and fine
- **Falsification Penalty**: If a player enables DPP without completing genuine supply mapping, audit detection chance is 80% — resulting in full EU market ban (7 days) and major reputation hit
- **Data Gaps**: If a supplier is replaced without updating the DPP record, the gap triggers an automated warning before the next audit window

**DPP Reward Tiers**:


| DPP Status | Effect |
|-----------|--------|
| Not enabled | No EU city access above Rank 50 |
| Enabled (partial mapping) | EU cities accessible; audit risk high |
| Enabled (full mapping) | Full EU access, verified badge, +15% premium pricing |
| Enabled + Net Positive cert | Exclusive "Circular Icon" feed badge, editorial coverage event |

---

## 8.9.2 Crisis Management (Expanded)

Crises are high-stakes narrative events triggered by player choices, external events, or scandal probability rolls. They are the game's most dramatic moments and define long-term brand reputation arcs.

### Crisis Triggers
- Celebrity scandal (endorsement-linked)
- Supplier ethical violation (labour or environmental)
- Greenwashing accusation (sustainability certification mismatch)
- Counterfeit design theft (IP system)
- Social media callout (rival or NPC media outlet)
- Financial misconduct (stock manipulation accusation)
- Product defect recall (quality control failure)

### Visual Crisis — The Tarnish Effect

When a crisis is triggered, the **Alabaster marble** aesthetic of the HQ UI visually degrades in real time:
- **Phase 1 (Crisis Triggered)**: Hairline Obsidian cracks appear across marble surfaces and UI panels — subtle, ambient, atmospheric.
- **Phase 2 (Crisis Escalating / Unresolved after 24h)**: Cracks widen and fill with **Obsidian sludge ripples** — a slow, viscous pulse that spreads across the screen edges. The Champagne Gold accents dim. The Sun-Dial Hype Meter flickers.
- **Phase 3 (Crisis Unresolved 48h+)**: Full Tarnish state — UI surfaces appear cracked marble, gold replaced by tarnished bronze, Vex's review frequency increases. Luxe's tone shifts from warm to urgent.
- **Resolution**: Selecting any active resolution path begins the visual repair. Cracks seal as a function of resolution speed — fast paths (PR Campaign) restore quickly; slow paths (Reform) heal incrementally over the full resolution window.

### Resolution Paths

| Path | Cost | Speed | Outcome |
|------|------|-------|---------|
| **Public Apology** | Low cash, high humility | Fast (24h) | Partial hype recovery; trust rebuilt slowly |
| **PR Campaign** | High cash | Medium (48h) | Full hype recovery; media score boost |
| **Legal Action** | High cash + time | Slow (72h) | Rival/NPC penalised; strong precedent signal |
| **Reform & Transparency** | High operational cost | Slow (5–7 days) | Permanent reputation boost; costly short-term |
| **Leak a Rumor** | No cash cost | Immediate | **The Narrative Gamble**: the player authors a curated rumour fragment — a whisper, a planted story, a strategic misdirection — and releases it anonymously into the Global Feed. The game treats it as live content: other players can react, amplify, or counter it in real time. **Success (60%)**: the crisis narrative is hijacked. The feed refocuses on the rumour. The player's own scandal fades. Rival credibility takes a hit if the rumour is adjacent to their brand. Hype spikes as the drama generates engagement. **Failure (40%)**: the rumour is traced back or escalates the original story — a secondary crisis fires at 1.5× the severity of the first, with Vex publicly dissecting the failed spin on the feed. The key tension: silence kills the feed; a Leak keeps the story alive and the player in control of the narrative, however precariously. This is the move of someone who knows the game. |
| **Kintsugi** | High cash + Prestige Tokens | Slow (7 days) | **The Resilience Prestige Path**: instead of erasing the damage, the player transmutes it. Over 7 days, the Obsidian cracks in the Alabaster UI are filled with **liquid gold** — slowly, visibly, one crack per day as a passive resolution animation that other players can see on the player's Global Feed posts and profile. The fully restored HQ is not the same HQ that existed before the crisis — it is **more**. Gold veins run permanently through every marble surface. The **Resilience Prestige** skin is applied globally: feed post frames carry a hairline gold crack pattern; the Brand Story Archive logs the crisis and its transmutation as a chapter. The "Forged in Gold" profile badge is permanent. A **+10% crisis resistance bonus** applies to all future crises. Other players cannot buy this skin. It cannot be unlocked any other way. The scar that becomes the jewel is the rarest flex in the game. Unlocks at Brand Rank 40+. |

### Scaling by Brand Rank
- Low-rank crises are small and local (one city, short duration)
- High-rank crises are global, affect stock price, and can trigger rival opportunism
- At Rank 80+, unresolved crises can trigger **Eclipse Events** — rivals pile in and force a market share contest

### Long-term Narrative Consequences
- Successfully resolved crises leave a **Resilience Badge** on the Brand Story Archive — visible flex
- Repeated crises (3+ unresolved) trigger a **Reputation Debt** mechanic — loan interest rises, talent costs increase, and media score drops persistently until reform actions are completed

---

## 8.9.3 Supply Chain Logistics (Deepened)

Building on the base supply chain system, deeper mechanics reward experienced Moguls and late-game players:

- **Multi-Tier Network**: Raw material → tier 1 manufacturer → tier 2 finishing → logistics partner → distribution. Each tier has independent risk, cost, and quality ratings.
- **Risk Propagation**: A disruption at any tier (e.g. raw material shortage) cascades downstream — inventory gaps appear 24–72h later unless buffer stock is held
- **Dynamic Rerouting**: Manual rerouting mini-game when a tier is disrupted — drag alternative suppliers into place before deadline. Time pressure; reward for speed.
- **Buffer vs JIT Choice**: Players choose between buffer stock (higher storage costs, lower disruption risk) and just-in-time (lower costs, high vulnerability to events)
- **Black-Market Sourcing**: In crisis, an emergency black-market tier appears (unverified suppliers) — solves the shortage immediately but carries high DPP audit risk and 40% quality drop chance
- **Maison Collective Bargaining**: Maisons with 10+ members can negotiate exclusive multi-city supplier contracts unavailable to solo players

---

## 8.9.4 Ethical Sourcing Trends (2026 Meta)

Woven into supply chain decisions, trend events, and Luxe tips:

| Trend | In-Game Effect |
|-------|---------------|
| **Regenerative Materials** | New material tier above Organic — highest hype bonus, scarcest supply, highest cost |
| **Blockchain Traceability** | Optional Ledger upgrade — auto-verifies DPP data, reduces audit risk 60%, costs ongoing idle currency |
| **Living Wages** | Toggle in supplier contracts — raises cost 15–20% but grants Ethical Supplier badge, loyalty bonus, and talent attraction boost |
| **Circular Mandates** | Seasonal regulation events require % of collection to use recycled materials or face EU tariff |
| **Biodiversity Credits** | New currency earned via certified eco-suppliers — tradeable with other players or spent on premium certifications |
| **Local Sourcing Push** | Regional suppliers get periodic "Local Loyalty" bonus events — boosting their quality rating and reducing delivery time |

---

## 8.9.5 Sustainability Certifications (Four Tiers)

| Tier | Certification | Requirements | Benefits | Risk |
|------|--------------|--------------|----------|------|
| 1 | **Organic** | 50%+ organic materials in any collection | +Hype, reduced media criticism | Low |
| 2 | **Fair Trade** | Living wage toggle on ≥3 suppliers | +Loyalty, +Talent attraction, better loan rates | Low |
| 3 | **Carbon Neutral** | Full supply chain mapped + logistics offsets purchased | DPP eligibility, +Premium pricing tier, EU market access | Audit risk if falsified |
| 4 | **Regenerative / Net Positive** | Tier 3 + Regenerative materials + biodiversity credits spent | "Circular Icon" badge, editorial coverage event, exclusive Maison access, highest hype multiplier | Extremely high visibility — any violation is catastrophic |
| ⚠️ | **Fake Tier** | Claiming cert without meeting requirements | Short-term hype boost | 80% detection rate; EU ban, global reputation collapse, rival callout event |

---

## 8.9.6 Sustainability Marketing Best Practices (Luxe Tips)

When a player reaches Tier 3+ certification, Luxe delivers a dedicated marketing guidance session:

- Lead with your highest-tier certification — it's the headline, not the footnote
- Use the "Net Positive" badge on every feed post for maximum hype signal
- Launch **Limited Regenerative Capsules** (low volume, high price, high prestige) for media coverage events
- Partner only with eco-aligned influencers — misaligned celebrities reduce cert credibility by 20%
- Show real traceability — link DPP data to your Global Feed posts for trust multiplier
- Tie collection launches to real-world climate events (Earth Day, UN Fashion Summit events) for bonus hype window
- Offer a **Repair Programme** in the in-game store — drives "Extended Life" pricing perception and sustainability score

---

## 8.9.7 Brand Heat & Founder Rep — One Story, Two Voices

Every empire has two reputations: the brand's, and the founder's. In The Styliste, these are distinct systems that tell the same story from different perspectives — the institution and the person behind it.

**Brand Heat** (0–100) is the empire's ambient temperature — the market's collective read on how relevant, powerful, and desirable the brand is right now. It is the game's **Central Brand Reputation System**: a single, always-visible meter permanently mounted on the HQ Dashboard beneath the Brand Rank bar (see §3.0). It is always-moving, always-consequential, and cannot be hidden or dismissed. Brand Heat is not a background stat — it is the empire's public face. Every player who visits your profile sees your current Heat level. Every supplier, talent agent, and media outlet in the game checks it before responding to your actions.

**Inputs that raise Heat**:
- Consistent high-quality drops, on-trend designs, successful events, positive media reviews, high sustainability scores, celebrity glow-ups, Aurelian Gala placements, District Control wins

**Inputs that lower Heat**:
- Scandal Tarnish events, missed trends, quality control failures, greenwashing accusations, low-morale talent defections, over-saturated marketing

**Heat Effects**:
| Heat Level | Effects |
|-----------|---------|
| 0–25 (Cold) | −25% pricing authority, talent refuses offers, rivals target you preferentially, media publishes negative reviews |
| 26–50 (Warm) | Baseline pricing and media access |
| 51–75 (Hot) | +15% premium pricing, influencer offers improve, positive media coverage chance |
| 76–100 (Iconic) | +30% pricing authority, exclusive celebrity access, stock price bonus, Maison invite rate spikes |

Heat decays 1–3 points/day without active play; design sessions, events, and social engagement slow decay.

---

## 8.9.8 Founder Rep — The Personal Legacy

**Founder Rep** is the other half of the story — not the empire's heat, but the founder's personal legend. Brand Heat can collapse in a crisis; Founder Rep tells the market whether to wait for the comeback or write the obituary.

- Rises via: Mentor Quest completions, Global Feed posts with high engagement, Maison leadership actions, celebrity interactions, media interviews (unlocked at Rank 40), Kintsugi resolutions (the founder who rebuilt publicly becomes more trusted than the founder who never fell)
- Falls via: Public disputes, failed endorsements attributed personally, talent defections, "Leak a Rumor" failures (−8 Founder Rep on traced-back leaks)

**Effects**: Higher Founder Rep reduces loan interest rates; attracts top-tier talent; improves crisis resolution outcomes; and unlocks the founder-exclusive **"Cover Story"** media event at Rank 75.

---

### Founder Rep — Explicit Crisis Integration

Founder Rep is an active mechanical modifier in every crisis resolution path — not background flavour:

| Founder Rep Range | Crisis Resolution Bonus |
|---|---|
| 0–24 | No bonus. Talent morale −5% during active crisis (they don't trust the leader's ability to recover). |
| 25–49 | PR Campaign and Legal Action costs −15%. Partial crisis containment on first tick (−10% to Brand Heat loss rate). |
| 50–74 | All resolution paths cost −25%. Crisis resolution time reduced by 10% per active path. Talent morale unaffected during crisis — loyalty buys stability. |
| 75–100 | Kintsugi path unlocks regardless of Brand Rank (normally requires Rank 40+). All resolution costs −35%. At resolution, Founder Rep converts a portion of the Brand Heat lost during the crisis into a permanent **Resilience Reserve** — a floor that Brand Heat cannot drop below for 14 days post-crisis (floor = 15% of Founder Rep score). |

**Brand Heat vs Founder Rep Separation**: A Tarnish crisis reduces Brand Heat automatically — but it does **not** automatically reduce Founder Rep. The founder's personal reputation is governed by how they *respond*, not by the fact that a crisis occurred. Choosing **Kintsugi** builds Founder Rep (+12 over the 7-day resolution window). Choosing **PR Campaign** is neutral to Founder Rep. Choosing **Leak a Rumor** risks Founder Rep: −8 on failure, +5 on success. This separation is the core of the two-meter design: the brand suffers; the founder chooses whether to suffer with it or grow through it.

---

### Founder Rep — Explicit Deal Integration

Founder Rep modifies all deal negotiations in the Ledger as a standing confidence modifier:

**Loan Rates** (Central Bank & Equity, §5.5):
```
Loan_Interest_Rate = Base_Rate × (1 − (Founder_Rep / 200))
```
At Founder Rep 0: full base rate. At Founder Rep 100: base rate −50%. This makes Founder Rep the most impactful long-term financial lever available to any player — F2P-achievable through consistent play and mentorship completion.

**Supplier Negotiation** (§5.1 / §8.9.3):
- At 50+ Founder Rep: opening bid tolerance +20% — suppliers accept less-favourable terms on the first round because the founder's reputation precedes the meeting.
- At 75+ Founder Rep: one supplier contract renegotiation per season is **free** — the supplier reaches out proactively to maintain the relationship.

**Celebrity Endorsement Negotiation** (§8.3):
- Founder Rep contributes a flat bonus to the success meter in the 3-round negotiation mini-game: `+floor(Founder_Rep / 10)` points added to the success meter start position (max +10).
- At 75+ Founder Rep: A-List celebrities and Global Icons accept offers at 85% of their listed fee without a full negotiation sequence — reputation replaces the middle round.

**The Unified Arc**: The full journey — from the biometric fingerprint scan at the Aurelian Gate, through the first viral drop, through the Tarnish crisis and the Kintsugi recovery, through District Control battles and Aurelian Gala wins, to the final Ascension at Rank 100 — is told simultaneously through Brand Heat and Founder Rep. The brand's heat is the empire's voice. The founder's rep is its soul. Both must be cultivated. Neither can be bought. That is the point.

---

## 8.9.9 Resale & Second-Hand Platform — The Circular Economy

An in-game brand-owned resale marketplace, unlocked at Brand Rank 45. This is not a clearance bin. This is a **secondary market that mirrors the economics of real luxury** — where scarcity, provenance, and legacy hype make older pieces more valuable than newer ones.

**Core Mechanics**:
- Players list retired Alpha pieces, past-season collections, and limited capsules for other players to purchase
- **Revenue Share**: 70% to the original creator, 30% Platform Tax (passive idle income for the creator — the empire earns from its own history)
- **Sustainability Score Boost**: Active resale usage raises the brand's Sustainability Score, contributing toward Carbon Neutral certification

**The Vintage Premium System**:
Alpha pieces do not depreciate. They **appreciate**. A garment created at Rank 20 — with its original design DNA, its historical Hype Score at time of drop, and the cultural moment it was released into — is worth *more* at Rank 60 precisely because it is from the beginning. The early work becomes the archive. The archive becomes the legacy.

- All Alpha pieces gain a **Legacy Multiplier** that compounds at 2% per Brand Rank beyond the rank at which they were created
- Pieces from **Trend Tsunami windows** carry a **Wave Origin** provenance tag — visible to all buyers — which grants an additional 15% Vintage Premium for being part of a cultural moment
- Pieces worn by Aurelian Sovereign talent in campaign posts gain a **Sovereign Provenance** tag — the talent's association becomes part of the piece's market identity
- **Kintsugi Pieces** — Alpha pieces that survived a Tarnish crisis and were repaired via the Kintsugi path — are the rarest resale items in the game. Their "Forged in Gold" provenance is visible to all buyers. Their Vintage Premium is uncapped.

**Secondary Market Effects**:
- Scarcity drives hype on the Global Feed — limited resale stock generates **"This just listed" feed alerts** to players who have interacted with the brand
- Buyers who purchase resale items gain loyalty to the brand's new collections — a crossover retention arc that converts secondary buyers into primary customers
- Early-game content never becomes obsolete: a Rank 20 piece listed at Rank 60 is not old inventory — it is a first-edition. The secondary market is proof that the brand was always worth watching.

---

### Resale — Listing & Discovery Mechanics

**Listing Flow**:
1. From the **Brand Story Archive** or **Atelier** → tap any eligible Alpha piece → "List on Resale Platform"
2. Set **price** (floor: original craft material cost × 1.2 to prevent underselling legacy pieces; ceiling: uncapped) with a live **Vintage Premium preview** showing current Legacy Multiplier and projected demand
3. Set **listing duration**: 24h / 7d / 30d. Longer listings accumulate more views; shorter listings create urgency
4. Optional: toggle **Auction Mode** (unlocked at Brand Rank 60) — see below
5. Confirm → piece moves from Archive to the platform. The listing generates a **feed post draft** (opt-in) with the garment's provenance tags and asking price pre-filled

**Price Floor formula**:
```
Price_Floor = Original_Craft_Cost × 1.2 × Legacy_Multiplier
```
This ensures no Alpha piece can be undersold below its compounded historical value.

**Discovery Feed — The Resale Marketplace Tab**:
- Dedicated tab in the Feed panel, accessible from Brand Rank 45+
- **Filter axes**: City affiliation of creator · Material tier · Brand Rank of creator · Provenance tags (Wave Origin / Sovereign / Kintsugi) · Vintage Premium level (Low / Mid / High / Legendary)
- **Sort options**: Newest listed · Highest Vintage Premium · Lowest price · Creator Brand Rank · Trend alignment to current Trend Tsunami
- Default view: **"Rising Value"** sort — pieces with the highest Legacy Multiplier growth rate surfaced first

**"This Just Listed" Alerts**:
Brands with 500+ followers trigger a push notification to their top 10% most-engaged followers when a new resale piece is listed. The alert includes the piece name, provenance tags, and asking price. This is opt-in for the receiving player (default: on).

**Auction Mode** (Rank 60+):
- Alternative to fixed-price listing. The seller sets a **starting bid** (minimum: Price Floor) and a 24-hour auction window
- Buyers place bids; the highest bid at window close wins the piece and the transaction settles automatically
- Failed auctions (no bids above starting bid) return the piece to the Archive at no cost
- Auctions generate higher feed visibility than fixed-price listings — the bidding activity auto-posts to the Global Feed as a live event card, with real-time bid updates visible to all players who follow the brand

---

## 8.9.10 Repair & Longevity Services

Unlocked at Brand Rank 55 — a dedicated in-game revenue stream rooted in real-world slow fashion economics:

- Players can offer a **Repair Programme** for their Alpha pieces — in-game customers pay a service fee to "restore" garments rather than buying new
- Generates steady low-volume idle income stream (weaker than store revenue but zero supply chain cost)
- **"Extended Life" Marketing Tier**: Brands with active repair programmes unlock a premium positioning tag — boosts Sustainability Score and allows +10% pricing on new drops ("We build things to last")
- Unlocks the **Heritage Collection** drop type — existing older Alpha pieces re-released as restored classics with nostalgia hype bonus
- Synergy with DPP: Repair data is auto-added to the garment's Digital Product Passport, strengthening traceability record and reducing audit risk

---

## 8.9.11 Dynamic Demand & Pricing Engine

Per-city, per-customer-segment demand curves that shift continuously:

- **Demand Drivers**: Brand Hype, trend alignment, economic events (recession drops luxury demand; boom raises it), seasonal windows, marketing campaigns, rival price moves
- **Pricing Sliders**: Players set prices per product tier (Budget → Mid → Premium → Luxury). Price too high = volume drops; price too low = margin collapses and brand prestige takes a hit
- **Real-Time Signals**: Ledger shows demand curve per city with a 48h forecast — accuracy improves with Brand Rank (Rank 60+ gets 7-day forecast)
- **Elasticity by City**: Tokyo and NYC customers are less price-sensitive than Nairobi or São Paulo — premium pricing works better in luxury-native markets
- **Hype-Price Lock**: During a hype spike (viral post, event win), players have a short window to increase prices 10–25% before the market re-equilibrates. Missed windows penalise indecision.

---

### Demand Engine — Concrete Formulas

**Unit Demand per Session**:
```
Demand_Units = Base_Demand × Hype_Modifier × Trend_Modifier × Economic_Modifier × (1 / Price_Elasticity_Coefficient)
```

**Session Revenue**:
```
Revenue_Per_Session = Price_Tier_Value × Demand_Units × Supply_Fulfillment_Rate
```

**Variable Definitions**:

| Variable | Definition | Range |
|----------|-----------|-------|
| `Base_Demand` | `City_Population_Index × Customer_Segment_Affinity` — per-city, per-segment constant set at world generation | City-specific |
| `Hype_Modifier` | `clamp(Hype_Score / 50.0, 0.5, 2.0)` — doubles demand at peak Hype Score (100); halves it at cold baseline (25) | 0.5 – 2.0 |
| `Trend_Modifier` | `1.0 + (Aesthetic_Alignment − 0.5) × 0.8` — ranges from 0.6 (fully off-trend) to 1.4 (perfect alignment) | 0.6 – 1.4 |
| `Economic_Modifier` | Driven by Global Economic Volatility events (§8.5): Recession = 0.6 · Stable = 1.0 · Boom = 1.4 | 0.6 – 1.4 |
| `Price_Elasticity_Coefficient` | City-specific constant: NYC / Tokyo = 0.85 (low sensitivity) · Paris / London = 1.00 · Lagos / São Paulo / Nairobi = 1.35 (high sensitivity) | 0.85 – 1.35 |
| `Price_Tier_Value` | Flat currency value of selected pricing tier per unit: Budget = 50 · Mid = 150 · Premium = 400 · Luxury = 1,200 | 50 – 1,200 |
| `Supply_Fulfillment_Rate` | `min(inventory_available / Demand_Units, 1.0)` — stockouts cap revenue even at peak demand | 0.0 – 1.0 |

**Hype-Price Lock Window**:
```
Price_Surge_Active = (Hype_Score > 75) AND (viral_event_triggered_within_6h)
Max_Price_Surge = 10% + ((Hype_Score − 75) / 25) × 15%   → ranges from +10% to +25% above base Price_Tier_Value
Window_Duration = 6 hours from viral trigger
Penalty_On_Miss = −5% Demand_Units for the following 12h (indecision signals market weakness)
```

In Expert Mode, all variables are displayed live in the Ledger's demand panel during active sessions. In Casual Mode, the system runs silently and the player sees only a simplified "Demand Level" indicator (Low / Medium / High / Surge).

---

## 8.9.12 Fashion Week Politics

Real systemic depth behind the prestigious runway events:

- **Critic Relationships**: Individual named critics (fictional) track their relationship with your brand. Consistent quality builds goodwill; off-trend drops or PR scandals sour it. High goodwill = guaranteed positive review.
- **Seating Politics**: At Fashion Week events, seating assignment is based on Brand Rank, Maison affiliation, and current Founder Rep. Front-row seating guarantees media coverage; back-row risks being cut from reviews entirely.
- **Backstage Drama Events**: Random event triggers during Fashion Week prep — model walkout, fabric disaster, rival sabotage of your show slot. Each requires a mini-decision with hype/reputation stakes.
- **Walk-Off Incidents**: If talent morale is below 40% when a Fashion Week event begins, a walkout event is triggered — immediate show disruption with recovery options (emergency replacement, show delay, public apology)
- **Long-term Opportunities**: Critics who love your brand unlock exclusive editorial event types ("Vogue Archive Feature", "Council Endorsement") that provide permanent hype multipliers

---

## 8.9.13 Wholesale & B2B Contracts

An alternative revenue path for Mogul-focused players, unlocked at Brand Rank 35:

- **Department Store Deals**: Multi-season contracts to supply collections to fictional department stores (e.g. "Chambord" — Paris; "The Crown" — London). High volume, lower margin, guaranteed idle revenue.
- **Exclusivity Periods**: Wholesale contracts can include exclusivity clauses — the brand cannot sell those pieces direct-to-consumer during the contract. Strategic trade-off: stability vs. margin.
- **Retailer Reputation**: Each wholesale partner has a Prestige rating. Landing a deal with a high-prestige retailer boosts Brand Heat even if the margin is thin.
- **Contract Renewal Negotiations**: Every season, wholesale contracts come up for renewal — prices, volumes, and exclusivity terms are renegotiated. Mini-game: 3-round negotiation with risk/reward sliders.
- **Synergy**: Wholesale volume contributes to supply chain scale discounts; higher volume orders unlock better supplier tiers faster.

---

## 8.9.14 Physical vs Digital Fashion Split

Two separate economics, audiences, and design tracks:

| Dimension | Physical Collections | Digital / Metaverse Drops |
|-----------|---------------------|--------------------------|
| Revenue | Store sales, wholesale, licensing | Direct digital sales, NFT-adjacent collectibles |
| Audience | In-city customer segments, loyalty system | Global Feed followers, digital-native customers |
| Hype Type | Trend alignment, quality, sustainability | Virality, exclusivity, novelty |
| Costs | Materials, manufacturing, logistics | Rendering credits, digital platform fees |
| Unlock | From Rank 1 (Physical) | Rank 40 (Digital — AI + Digital Fashion trend) |
| DPP | Required for EU Physical access | Not applicable |
| Synergy | Physical Alpha pieces can spawn a digital twin for sale | Digital drops create "Real World Demand" events — NPCs queue for physical version |

## 8.10 Talent Management System — Collectible Recruitment

Talent is the game's **Gacha-adjacent collectible system** — the primary driver of aspiration spend. Players don't just hire staff; they **collect icons**.

### Recruitment Pool — Four Aurelian Tiers

| Tier | Talent Type | Strategic Impact | Visual Flair | Multiplier | Acquisition |
|------|------------|-----------------|--------------|------------|-------------|
| ⬜ **Rising Star** | Junior Stylist, Floor Manager | Baseline Multipliers | Standard Champagne-Gold portrait | 1.0–1.2× | Standard Ledger hire |
| 🟦 **Maven** | Senior Designer, Campaign Director | +15% Trend Accuracy | Animated ivory portrait frame with **Alabaster Rim-light** and soft rose trim | 1.3–1.6× | Event drops, free weekly pull |
| 🟣 **Global Icon** | Creative Director, Shark Investor | Unlocks A-List Endorsements | Holographic Aurelian Radiance card with **Gold Particle Trail** entrance animation | 1.7–2.2× | Season Pass, Maison War reward |
| 🟡 **Aurelian Sovereign** | Iconic Creative Director, Liquid Gold Mogul | +30% Idle Multiplier + Sovereign Talent Multiplier (+15–+40 flat Hype Score bonus per §4.1) | Full-screen Radiant White-Out reveal cinematic; unique Luxe reaction; Void of Radiance feed flex card. Emits the **Gilded Ripple** — a liquid-gold shader driven by Verlet physics that causes all assigned garments to emanate a softly rippling liquid-gold aura in real time, visible on Global Feed cards and Atelier previews. | 2.5–4.0× | Limited banners, Aurelian Gala event, ultra-rare drop |

**Legendary examples**:
- *Zara Voss* (Global Icon Creative Director) — Hype multiplier ×3.5, triggers a "Viral Cascade" event once per week
- *The Architect* (Global Icon Shark Investor) — Passive IPO valuation +40%, reduces hostile takeover vulnerability
- *Mei Tanaka* (Aurelian Sovereign Shadow Stylist) — Gilded Ripple active, Sovereign Multiplier +35, unlocks Japan exclusive co-drop event

### Competitive Integrity — Maison Wars Balance
**Aurelian Sovereign talent does not create pay-to-win conditions in Maison Wars or District Control battles.** The Sovereign Talent Multiplier (+15–+40 flat Hype Score bonus) applies to passive follower growth and idle revenue scaling — areas of the game governed by long-term compounding, not moment-to-moment competitive action.

In Maison Wars, District Control outcomes are determined by: collective Maison market share (driven by player activity and strategy), campaign timing and spend, co-drop coordination, and Power Move execution. Sovereign talent provides a **prestige and aesthetic advantage** — Gilded Ripple VFX on Global Feed posts, higher feed visibility weighting, stronger endorsement pull-through — but cannot directly purchase city market share, override rival campaigns, or substitute for active player coordination. A fully F2P Maison with superior strategy will defeat a whale-stacked Maison that doesn't play cohesively.

The guiding principle: **whales buy prestige and flair. Skill and coordination buy territory.**
- **Talent Archive**: Visual collection gallery (Pokédex-style) showing all acquired, all discoverable, and rarity odds
- **Duplicate Protection**: Duplicate pulls convert to **Prestige Tokens** — spend to unlock exclusive cosmetics for already-owned talent
- **Pity System**: Guaranteed Global Icon at every 30 pulls; Aurelian Sovereign at every 90 pulls. Counters persist across banners.
- **Rotation Banners**: New Aurelian Sovereign talent introduced monthly, tied to real-world fashion events or seasonal themes. Limited 14-day window.
- **F2P Pull Income**: 1 free pull per week (Ledger), bonus pulls from Mentor Quests, Social Competitions, and daily streak milestones — ensuring F2P players can meaningfully collect without mandatory spend

---

### F2P Parity Guarantee — Explicit Commitments

The Gacha Recruitment system is designed to reach the revenue ceiling of its category without creating pay-to-win conditions. The following table addresses each potential P2W concern explicitly:

| Concern | Reality | F2P Path to Equivalent |
|---------|---------|------------------------|
| **Aurelian Sovereign Hype Score bonus (+15–+40)** | Applies *only* to passive follower growth and idle revenue compounding — not Maison Wars, District Control, Fashion Week voting, or any direct PvP outcome | F2P players with sustained Hype Score 80+ via on-trend design reach functionally equivalent follower growth within 10–15% of Sovereign-boosted brands over a 30-day window |
| **Gilded Ripple VFX on Global Feed posts** | Purely cosmetic — the feed ranking algorithm scores on Hype Score and engagement rate, not VFX quality | F2P brands achieve identical feed placement for equivalent Hype Scores |
| **Limited 14-day rotation banners (FOMO pressure)** | Limited availability creates urgency | All past Aurelian Sovereigns return in a **Vault Banner** every 90 days, accessible via Prestige Tokens earned through consistent F2P play |
| **Pity at 30 / 90 pulls (pull volume advantage for spenders)** | A consistent F2P player earns 4–6 pulls/week from all sources combined | F2P players reach Global Icon pity (30 pulls) in approximately 5–7 weeks of consistent play at no spend |
| **Sovereign Multiplier in stock valuation** | Feeds Hype Score → IPO valuation via the Hype Score formula | F2P brands with strong design discipline and high sustained Hype Score reach equivalent IPO valuation trajectories within one rank tier of Sovereign-boosted brands |
| **Sovereign talent in Maison Wars** | Sovereign Multiplier is a passive compounding advantage, not an active Maison Wars variable | District Control and Maison War outcomes are determined by collective market share, campaign timing, co-drop coordination, and Power Move execution — all F2P-achievable through strategy |
| **Vault of past Sovereigns accessibility** | Prestige Tokens required | Prestige Tokens earned via duplicate pulls (F2P pull income), Mentor Quest Gold rewards, and Aurelian Gala participation — no spend required |

> **The non-negotiable**: No Aurelian Sovereign talent, no gacha pull, and no IAP can directly purchase city market share, override rival campaigns, substitute for active player coordination, or alter the outcome of any competitive event. Competitive results are determined by strategy, coordination, and skill. A fully F2P Maison with superior cohesion will defeat a whale-stacked Maison that does not play together. This is the design. It is enforced at the server level.

### Core Talent Stats (Unchanged)
- **Expertise**: Creativity / Influence / Execution
- **Loyalty (0–100)** and **Morale (0–100)** still apply — Aurelian Sovereign talent with low morale underperforms; management depth remains relevant at all tiers
- **Assignment Dashboard**: Drag talent to slots — Atelier, Campaigns, Photoshoots, Retail Stores, Events
- **Morale/Loyalty Engine**: Pay raises, event wins, workload balance, Brand Heat, scandals all affect performance
- **Training & Upgrades**: Spend resources to level stats or unlock additional traits
- **Risk Events**: Rival poaching (higher risk for Aurelian Sovereigns), burnout strikes, scandal involvement
- **Maison Synergy**: Shared talent pool for collective boosts; Aurelian Sovereign talent shared in a Maison provides Gilded Ripple aura bonus to all members' top-pinned feed designs

---

## 8.11 Follower System

Brands and Maisons gain followers from real players (feed interactions, likes, collabs, events) and AI/NPC (auto based on hype, quality, trends, events).

**Follower Acquisition is directly governed by the Hype Score formula (§4.1)**:
```
Hype_Score = (Aesthetic_Alignment × Material_Quality) + Sovereign_Talent_Multiplier
```
The Hype Score acts as the primary coefficient for NPC/AI follower growth rate and organic feed reach. A higher Hype Score expands the daily NPC growth band and increases the probability of feed algorithm amplification. Idle Revenue scaling per session is calculated as a direct linear function of the current Hype Score — higher scores unlock higher revenue tiers.

**Follower Count Influences**:
- Perks (bonuses) and quirks (unique traits)
- Hype/popularity (sales/feed boost)
- Power (leaderboard rank, city dominance)
- Trust (loan rates, investor appeal)
- Idle income scaling, talent attraction, partnership invites, stock valuation, endorsement success rate

### 8.11.1 Follower Acquisition Mechanics

| Source | Range |
|--------|-------|
| Feed interactions (likes/shares/comments) | 1–10 per interaction |
| Co-drops/partnerships | +50–300 |
| Event wins/runway votes | +100–1,000 |
| AI/NPC passive daily growth | 0.5–3% of current followers |

NPC growth scaled by: **Hype Score (§4.1)** as primary coefficient, with additional modifiers from marketing spend, city dominance, media coverage, and celebrity endorsements.

### 8.11.2 Follower Engagement Strategies
- High-quality content drops (collections, lookbooks, BTS)
- Interactive polls, Q&A, design voting
- Giveaways, early-access capsules, UGC contests
- Community challenges
- Live Atelier/runway sessions and AMAs

### 8.11.3 Follower Retention Tactics
- Loyalty tiers with escalating perks (discounts, exclusives, badges)
- Personalised rewards and shoutouts
- Brand storytelling and feedback implementation
- Consistent cadence and recovery campaigns
- Transparent updates and crisis management

---

## 8.12 Luxe Mentor System (Expanded)

**Backstory**: Once Lucien Voss, legendary anonymous "Liquid Gold Stylist." Disappeared after industry betrayal and uploaded consciousness to become **Luxe** — a witty, stylish, slightly sassy 2D animated fox (silk scarf, gold glasses) who now guides every new Sovereign.

**Role**: Personal mentor who speaks directly to the player. Appears in onboarding, daily check-ins, contextual tips, milestone moments, and Mentor Quests.

### Personality Growth & Memory
- Luxe's tone and dialogue evolve across Brand Ranks — warmer and more peer-like at higher ranks, more mentorly early on
- **Player Memory**: Luxe references past decisions ("You pivoted from streetwear to quiet luxury at Rank 30 — smart move"), creating a personalised narrative thread
- **Custom Outfits**: Luxe's visual appearance updates with earned cosmetics — players can gift Luxe seasonal accessories (Holiday, Pride, Fashion Week variants)
- **Voice Lines**: Short audio stings accompany milestone moments, check-ins, and mini-game wins. Tone-matched to Luxe's character (warm sarcasm, theatrical pride)

### Relationship Meter
- Hidden 0–100 **Trust Score** that rises with daily logins, quest completions, and positive choices
- At Trust milestones (25 / 50 / 75 / 100): Luxe unlocks new dialogue tiers, exclusive cosmetics, and deeper mentor quest chains
- Trust Score is never shown as a number — only surfaced through Luxe's increasingly warm and familiar dialogue

### Multi-Language Support
- Luxe's dialogue and tips localised into: English, French, Spanish, Portuguese, Japanese, Korean, Mandarin, Arabic, German, Italian
- Regional fashion references adapt per locale (e.g. Japanese players get Harajuku/Shibuya cultural references; French players get Marais/Saint-Laurent references)

### Daily Check-Ins
- Automatic on first app open each day
- Personalised message + 1–2 tips + small reward (idle boost or cosmetic)
- Optional 5-second quick action for bonus
- Skippable after 3 seconds

**Check-In Examples by Day Streak**:

| Streak | Luxe Message | Reward |
|--------|-------------|--------|
| Day 1 | *"You showed up. That's how every empire starts, darling."* | +2h idle boost |
| Day 3 | *"Three days in — rivals are already nervous. I can tell."* | +500 in-game currency |
| Day 7 | *"A week of consistency. The fashion world is watching."* | Rare fabric swatch (cosmetic) |
| Day 14 | *"Fourteen days. You're not a fluke — you're a force."* | Luxe outfit accessory unlock |
| Day 30 | *"A month. A full cycle. You've graduated from hopeful to inevitable."* | Permanent +5% idle multiplier |
| Day 60 | *"Two months. Legends are built in moments like this. You're earning yours."* | Exclusive Maison banner cosmetic |
| Day 100 | *"One hundred days. I've seen empires rise and fall, darling. Yours is rising."* | Legacy Check-In Badge + 3× idle boost (24h) |

**Tone**: Encouraging, playfully teasing, proud of player success.

---

## 8.12.1 Mentor Quests

Luxe-issued optional quest chains that provide structured mid-session goals and are a primary source of non-IAP rewards.

### Quest Types
- **Creative Challenges**: Design a piece using a specific material or trend combination
- **Business Milestones**: Hit a revenue target, open a store in a new city, complete a supply negotiation
- **Social Objectives**: Post to the Global Feed, form a partnership, join or contribute to a Maison
- **Personal Growth**: Reach a Trust Score milestone with Luxe, complete a streak, customise your avatar

### Quest Structure
Each quest has:
- A **Brief** from Luxe (narrative, in-character, 2–3 sentences)
- A **Primary Objective** (specific, measurable)
- 1–2 **Stretch Objectives** (optional, for Gold tier reward)
- A **Reward Preview** shown upfront

### Tiered Rewards

| Tier | Criteria | Reward |
|------|----------|--------|
| **Bronze** | Complete Primary Objective | Small idle boost or cosmetic fragment |
| **Silver** | Primary + 1 Stretch Objective | Rare material, hype multiplier, or currency |
| **Gold** | Primary + all Stretch Objectives | Exclusive cosmetic, Luxe dialogue unlock, permanent minor bonus |

### Quest Concrete Examples

| Category | Quest Name | Primary Objective | Stretch |
|----------|-----------|-------------------|---------|
| Creative | *"The Fabric Test"* | Complete a Deep Session using Silk + a seasonal print | Achieve Alpha status on the resulting piece |
| Business | *"First Blood"* | Generate ¥1M in idle revenue in a single session | Do it without spending on marketing |
| Social | *"Empire Intro"* | Post your first design to the Global Feed | Receive 50+ likes |
| Personal | *"Darling, Trust Me"* | Reach Trust Score 25 with Luxe | Log in 5 consecutive days |
| Rivalry | *"Counter-Strike"* | Launch a counter-campaign against a rival | Reclaim market share in the contested city |

---

---

## 8.13 Brand Story Archive

- Viewable timeline of all key drops, events, milestones, and achievements
- Nostalgia feature with shareable highlights and replay value
- Ties into the Aurelian Ascension system at Rank 100

**Sharing Options**:
- **Highlight Reel**: Auto-generated 30-second recap video of top milestones — shareable to external social platforms
- **Milestone Cards**: Individual cards for each major achievement (first Alpha piece, first city domination, IPO day) — tap to export as stylised image
- **Brand Story Link**: Public permalink to a read-only archive view — shareable with non-players
- **Global Feed Post**: One-tap "Share to Feed" for any archive entry — visible to all players with engagement reactions

---

---

## 8.16 Support & Feedback System

An in-app support layer that keeps players in the experience while resolving issues.

### In-App Support Ticket Form
- Accessible via Settings → Help & Support → Submit a Ticket
- Fields: Issue Category (dropdown), Subject, Description, Severity (Low/Medium/High)
- **Screenshot Attachment**: One-tap capture of current screen or gallery upload. Max 3 attachments per ticket.
- Auto-populates device info, OS version, game version, and account ID (with player consent)
- Ticket confirmation with estimated response time displayed by Luxe

### Ticket History
- Full list of past tickets with status badges: Open · In Progress · Resolved · Closed
- Thread view per ticket for back-and-forth with support team
- Reopen option for 14 days after resolution
- Filter by status, date, and category

### In-App Surveys
- Short 3–5 question pulse surveys triggered contextually (e.g. after completing a Fashion Week event, after first hostile takeover)
- Rating scale + optional free text
- Anonymous response option
- Never triggered more than once per 7-day window

### Milestone-Triggered Feedback
- Auto-prompted at key moments: Rank 10, Rank 25, Rank 50, first Maison join, first co-drop, first IPO
- Luxe delivers the request: *"Quick question before you conquer Milan — what's the one thing that could make this better?"*
- Responses feed directly into the developer's live feedback dashboard

---

- On first launch: clear permission request with Luxe explanation ("Stay in the know, darling")
- **Notification Types**: daily check-in reminders, live event starts, rival attacks/Eclipse alerts, stock movements, follower milestones, Luxe tips, seasonal/holiday events
- Smart frequency: max 2–3 per day, personalised and never spammy
- Deep-linking to relevant screens
- All opt-in with clear benefits shown upfront

---

## 8.15 Security & Protection

- **Client-side**: Code obfuscation, root/jailbreak detection, anti-tampering checks, runtime integrity verification
- **Server-side (Supabase)**: Row Level Security (RLS), rate limiting, API key rotation, Cloudflare DDoS protection + WAF
- **Data Protection**: End-to-end encryption for sensitive data, GDPR/CCPA compliant, minimal data collection
- **Anti-Cheat**: Server-authoritative idle calculations, anomaly detection on revenue/follower spikes
- **Legal Safeguards**: Full Privacy Policy, Terms & Conditions, End-User License Agreement drafted and enforced

### 8.15.1 Firebase Auth & Google Play Services Integration

**Authentication Flow**:
- **Anonymous-First Sign-In**: Players begin with an anonymous Firebase session — zero friction at launch. All progress is immediately tied to the anonymous UID and persists across sessions on the same device.
- **Progressive Account Linking**: At milestone triggers (Rank 5, first Maison join, or first IAP attempt), Luxe prompts the player to link a permanent account via Google Play Games (Android), Apple Sign In (iOS), or Email. Framed as securing their empire, not as a requirement.
- **Cross-device persistence and progress preservation**: All game state synced to the linked account; seamless switch between devices post-link.
- **Full Google Play Services integration**: Achievements, leaderboards, cloud save sync, and Play Games identity as an optional auth method.
- **Conflict Resolution**: If an anonymous session is linked to an existing account, the player is shown a side-by-side comparison of both saves and chooses which to keep.

**Auth Security Measures**:
- Firebase App Check enforced on all API calls (Play Integrity on Android, DeviceCheck on iOS)
- Short-lived JWT tokens with silent refresh
- Session hijacking protection via device fingerprint binding
- Account recovery via linked OAuth provider or email verification

### 8.15.2 Additional Security Solutions

| Layer | Solution |
|-------|----------|
| **Anti-Inflation / Anomaly Detection** | Server-side statistical monitoring flags revenue or follower counts that deviate >3σ from the player's historical trend. Auto-investigation queue triggers. |
| **Device Attestation** | Play Integrity API (Android) and Apple DeviceCheck (iOS) verify device integrity before any sensitive transaction. |
| **Clock Spoofing Prevention** | All time-sensitive calculations (idle income, cooldowns, events) resolved server-side using server-side time validation (NTP) — client clock is ignored. |
| **Behavioral Analysis** | Passive session heuristics track tap velocity, session patterns, and action sequences to flag bot-like behavior. |
| **CAPTCHA** | Invisible reCAPTCHA v3 on account creation, IAP flows, and bulk action endpoints. Fallback to v2 challenge on low trust scores. |
| **Anti-Automation / Bot Detection** | Rate limiting on all game action APIs. Burst detection with progressive cooldowns. Request signing on sensitive endpoints. Honeypot endpoints for scraper identification. |
| **Anti-DDoS** | Cloudflare enterprise-tier DDoS protection with adaptive rate limiting and IP reputation scoring. |
| **Payment Fraud Prevention** | Stripe Radar rules + server-side receipt validation for all IAP (Google Play Billing / Apple StoreKit 2). Refund abuse tracking. |
| **Anti-Cheat (Idle)** | All idle calculations authoritative on server. Client submits timestamps; server computes actual earnings. No client value is trusted for economy mutations. |
| **Session Hijacking** | Device fingerprint + JWT binding. Concurrent session detection with forced re-auth on suspicious parallel logins. |
| **Data Exfiltration Prevention** | Supabase RLS policies ensure players can only read/write their own data. No cross-player data exposure in any API response. |

---

## 9. Balance & Monetization

### 9.1 Progression Philosophy
Strategic depth with meaningful choices. Brand Rank pacing per Section 3.2.

### 9.2 Income Split
Idle/active 40/60 early → 55/45 late. Soft caps + 24h decay encourage daily play without burnout.

### 9.3 Path Parity
Designer hype scales match Mogul profit via symmetric cross-synergy.

### 9.4 Risk/Reward Scaling
Rivals, events, stock volatility, regulations, loans, equity, talent morale, celebrity risks, follower dynamics, and seasonal/holiday events all scale dynamically with Brand Rank.

### 9.5 Economy Sinks & Sources

| Sinks | Sources |
|-------|---------|
| Maintenance | Sales |
| Tariffs | Dividends |
| Overstock Storage | Idle Scaling |
| Loan Interest | Partnership Revenue |
| Talent Salaries | Event Rewards |
| Marketing Spend | IPO Proceeds |

### 9.6 Replayability
- Dual distinct loops with full cross-path synergy; **Joint Venture** mode at Rank 50 merges both paths into one supercharged empire
- **Aurelian Ascension** at Rank 100 — prestige reset with stackable Aurelian Boons (+50% Idle/Hype, Classic Alpha Piece carry-over) and Golden Statue immortalisation in the Hall of Sovereigns
- Procedural trends/events ensure variety across playthroughs

### 9.7 Monetization Model — Status + Style Hybrid

The V6 model replaces convenience-only with a **Status + Style Hybrid** — three primary revenue pillars designed to reach the category's revenue ceiling without compromising F2P accessibility:

1. **Gacha Recruitment (Talent / VFX)** — Players pull for Creative Directors across the four Aurelian tiers (Rising Star → Maven → Global Icon → Aurelian Sovereign). Aurelian Sovereign talent emits the Gilded Ripple shader and provides the Sovereign Talent Multiplier (+15–+40) in the Hype Score formula. F2P players earn Recruitment Vouchers via Founder Rep milestones, Maison Collective Rewards, and Aurelian Gala participation. Pity guaranteed at 30 (Global Icon) and 90 (Aurelian Sovereign).

2. **Aurelian Season Pass** — 8-week Battle Pass cycles. Free tier: Vouchers, materials, cosmetic frames. Premium tier: Exclusive **Ivory & Champagne Gold** garment shaders unavailable via any other mechanic, one **Blueprint** per season (one-time rare garment manufacturing license eligible for the Resale Platform), and a Signature Colourway palette unlock.

3. **Resale Commission (30% Platform Tax)** — All player-to-player transactions on the Resale & Second-Hand Platform are subject to a 30% platform tax. Revenue scales automatically with the active economy.

4. **Marble Polish** — A targeted IAP that instantly clears an active Tarnish state, restoring the HQ UI to full Alabaster with a champagne-gold ripple cleanse animation. Positioned as a prestige recovery item, not a crisis bypass — players still choose a resolution path narrative; Marble Polish accelerates the visual restoration only.

> Core progression, follower growth, market power, and competitive mechanics remain 100% F2P. No pay-to-win advantages.

### 9.8 Monetization Strategies

| Strategy | Description |
|----------|-------------|
| **Luxe Credits (IAP)** | Buyable premium currency for speed-ups, cosmetic packs, and convenience bundles (extra idle time, instant restock) |
| **Monthly Season Pass** | Recurring premium pass — three tiers (see 9.9) |
| **Rewarded Ads** | Optional voluntary ads for small boosts (extra idle hours, resources, cosmetics) — never mandatory |
| **Cosmetic Shop** | Permanent one-time purchases for avatar/Luxe outfits, UI themes, particle effects, and animated flair |
| **Limited-Time Event Bundles** | Holiday/seasonal packs with themed cosmetics and minor convenience items |
| **Founder's Pack** | One-time launch bundle: exclusive Luxe skin, starter fabric collection, +24h idle boost, cosmetic HQ theme |
| **Ad-Free Pass** | One-time purchase to permanently remove optional ad prompts for players who prefer a clean experience |

> All core progression, follower growth, market power, and competitive elements remain 100% F2P. No pay-to-win mechanics.

### 9.9 Season Pass Tiers

| Tier | Price | Key Inclusions |
|------|-------|---------------|
| **Basic** | $4.99/month | 3 exclusive fabrics, daily Luxe Credits bonus, Season-exclusive cosmetic |
| **Premium** | $9.99/month | 8 exclusive fabrics, permanent +10% idle multiplier (season duration), Luxe outfit skin, early event access (24h), bonus daily reward track |
| **Founder's** | $19.99/month | All Premium rewards + exclusive HQ theme, permanent title badge ("Founder"), extra Mentor Quest slot, priority support, early access to new features |

Season Pass rewards are **cosmetic and convenience only** — no pass content grants power unavailable to F2P players through consistent play.

### 9.10 Reward Balancing

- **Linear scaling**: Early reward density is high (frequent small wins); late-game rewards are rarer but more impactful — avoids the "dead zone" plateau common in idle games
- **Diminishing returns on speed-ups**: Purchasing speed-ups beyond a daily soft cap yields reduced efficiency — prevents whales from trivially bypassing all progression gates
- **Path parity**: Designer hype rewards and Mogul profit rewards are tuned to reach equivalent Brand Rank pace — no path feels punished
- **F2P safeguards**: Every Premium Season Pass item has a F2P-achievable equivalent earnable within 2–4 weeks of consistent play (different cosmetic variant, same functional bonus)
- **Casual/Expert split**: Casual Mode players receive slightly higher idle efficiency to compensate for lower active-play depth; Expert Mode players receive higher event reward multipliers
- **Weekly caps on event rewards**: Prevents marathon sessions from creating insurmountable gaps between heavy and casual players

### 9.9 Monetization Implementation (Technical)

- Use official `in_app_purchase` Flutter package for cross-platform support
- **Google Play Billing (Android)**: Integrated via Google Play Services
- **Apple StoreKit (iOS)**: Native integration
- Anonymous users can purchase; account linking preserves progress and purchase history
- All purchases are server-verified via Supabase Cloud Functions
- Revenue tracking for analytics and fraud prevention

---

## 10. Legal & Company Information

| | |
|--|--|
| **Developer** | SkinTeethNerd (SkinTeethNerd Studios) |
| **App Name** | The Styliste |
| **App Description** | Portrait-first fashion empire simulator. Design, dominate, and rise from underground hype to global icon in the ultimate idle tycoon experience. |
| **Mission & Vision** | To empower players to build authentic fashion empires while experiencing the real-world glamour, drama, and business of the industry. |

**Message from the Developer**:
> *"Hey, I'm SkinTeethNerd. The Styliste is my love letter to fashion and strategy. Build something legendary — I can't wait to see what you create."*

---

## 10.1 Full Legal & Compliance Documents

The following legal documents are required before public launch and must be accessible in-app (Settings → Legal) and on the public website:

### Community Guidelines / Code of Conduct
Defines acceptable behaviour on the Global Feed, in Maisons, and in direct messages. Prohibits harassment, hate speech, impersonation, spam, and real-money trading outside sanctioned systems. Violations result in escalating sanctions: warning → temporary mute → Maison removal → account suspension.

### Cookie Policy
Discloses all cookies and equivalent tracking technologies used (analytics, session management, advertising preferences). Compliant with EU ePrivacy Directive and GDPR. Includes opt-out mechanism accessible from the app settings and cookie banner on web.

### DMCA / Copyright & IP Infringement Policy
Outlines procedures for reporting copyright infringement of real-world brand designs, imagery, or IP reproduced within player content. Provides DMCA takedown request form and designated agent contact. Includes counter-notification process. Repeat infringer policy with defined consequences.

### Refund Policy
Defines conditions for IAP refunds (technical failures, unauthorised purchases by minors). Directs players to platform-native refund flows (Apple App Store, Google Play). Documents SkinTeethNerd Studios' internal refund request process and response SLA (5 business days).

### Data Processing Agreement (DPA) / GDPR Addendum
Formal DPA for B2B contexts (enterprise or platform partners). Covers sub-processor list (Firebase, Supabase, Stripe, Cloudflare), data retention schedules, breach notification procedures (72-hour GDPR window), and data subject rights fulfilment process (access, deletion, portability).

### Children's Privacy Policy (COPPA)
The Styliste is rated 12+ and does not knowingly collect personal data from children under 13. Documents age-gate mechanism at onboarding, parental consent flow if a minor is detected, and data deletion procedures. COPPA and UK AADC compliant.

### Accessibility Statement
Commits to WCAG 2.1 AA compliance targets. Documents current accessibility features (dynamic text size, high-contrast mode, reduced motion toggle, screen-reader labels on all interactive elements). Lists known gaps and remediation roadmap. Provides contact for accessibility-related support requests.

### Marketing & Advertising Policy
Governs all external marketing communications (ads, influencer partnerships, email campaigns). Confirms The Styliste does not display third-party advertisements within the game client. Documents sponsored content disclosure requirements for any influencer or affiliate partnerships. CAN-SPAM and GDPR marketing consent compliant.

---

## 11. The Manifesto

These are not design pillars. They are commitments.

**I. The empire is real.** Every trend, every tariff, every talent walkout, every resale spike, every rival acquisition is grounded in the actual logic of the global fashion industry. Players don't learn a game. They learn how power moves in the world they already care about.

**II. The feed is the game.** The Global Feed is not a side feature. It is the arena. Every drop, every Vex verdict, every Tarnish crisis, every District Badge, every Aurelian Gala win — they all happen there, in public, in real time, with consequences. The player's brand story is written on the feed. By them and by everyone watching.

**III. Two paths. One standard.** The Artisan creates culture. The Architect captures it. Neither path is subordinate. The Ledger is as radiant as the Atelier. The Power Move is as creative as the Alpha piece. Aesthetic parity between paths is non-negotiable.

**IV. Complexity is earned, never imposed.** Fashion enthusiasts and simulation veterans play the same game. The casual player never encounters a DPP compliance field. The expert player can route supply chains manually across six continents. The same game. Different depths. No one is punished for preferring the surface.

**V. The idle engine never sleeps.** The empire earns while the player lives their life. They return not to repair damage, but to capitalise on what was built. The Buffer Stock model, the passive Hype Score compounding, the Vintage Premium accruing on early Alpha pieces — everything is designed to make the player feel that *time invested was time well spent*, regardless of how long they were away.

**VI. Prestige is not for sale. It is earned, lost, and rebuilt.** Whales can buy flair. They cannot buy a District Badge, a Kintsugi skin, a Wave Rider archive entry, or an Aurelian Ascension Golden Statue. The rarest things in The Styliste require the rarest thing of all: playing the game with intention.

**VII. The arc is the point.** From the liquid gold ripple of the Aurelian Gate to the Golden Statue in the Hall of Sovereigns, every system — every Tarnish crack, every Gala win, every Maison war, every Vex verdict — is a chapter in one story. The player's story. The new standard. Their standard.

*Build something legendary.*

---

---

## 12. V6 Strategic Overhaul — Category Domination Directives

> *To break records and secure the #1 spot in the fashion tycoon category, The Styliste must transcend the "idle" label and become a cultural platform. This section defines the V6 modifications, removals, additions, and monetization expansions required to achieve that.*

---

### 12.1 Modifications — Refining the Friction

**§12.1.1 — Path Specialisation (updates §3.9)**
The Joint Venture system introduced at Brand Rank 50 replaces any legacy path-switching mechanic. Rather than switching paths at a premium currency cost, players at Rank 50 unlock a **Sub-Brand** in the opposite path — a fully managed secondary operation running in parallel. This doubles late-game content depth and eliminates "restart regret." Both idle streams compound; Designer players gain a Ledger sub-brand and vice versa. No reset. No premium cost. The Sub-Brand scales at 60% the rate of the primary path, acting as a lucrative satellite rather than a rival focus.

**§12.1.2 — Buffer Stock System (updates §3.4)**
Production never punishes absence — it builds anticipation. The **Buffer Stock** system replaces any notion of idle decay: while the player is away, the empire keeps manufacturing at full rate until warehouse capacity is reached. The moment it fills, it pauses — not as a penalty, but as a natural market tension. The player returns not to repair damage, but to **liquidate, release, and capitalise**. The pull back to the game is always framed as a victory lap: *your warehouse is full, the market is hungry, it's time to sell*. Warehouse expansion upgrades become one of the most satisfying mid-game spend targets — not because players fear losing income, but because they want to stay longer and earn more between sessions. Urgency without punishment. Anticipation without anxiety.

**§12.1.3 — DPP Compliance → Seal of Approval (updates §8.9.1)**
The Digital Product Passport compliance system is converted into an automated **Seal of Approval** mechanic. Manual data mapping is replaced with a passive research queue. As the Seal of Approval level increases (via idle research investment), garments and supply chain assets automatically inherit higher compliance ratings — unlocking premium market access, reduced regulatory fines, and global distribution bonuses without micro-managing passport fields. Full manual DPP audit mode remains available in Expert Mode for simulation-depth players.

---

### 12.2 Removals — Shedding the Weight

**§12.2.1 — "Strategic Silence" Removed from Crisis Management (updates §8.9.2)**
The "Strategic Silence" option is removed from all crisis response menus. In a social-first game built around the Global Feed, silence is inert — it generates no narrative, no engagement, and no player agency. In its place: **"Leak a Rumor"** — a High Risk / High Reward crisis response. The player plants a curated narrative fragment into the Global Feed. Success: crisis deflected, hype spike, rival credibility hit. Failure: the story spirals, generating a secondary crisis event at 1.5× severity. This keeps the narrative alive and the feed active during crisis moments rather than pausing it.

**§12.2.2 — Staff Rally & Supplier Raid Removed from Standalone Mini-Game Pool (updates §5.7)**
**Staff Rally** and **Supplier Raid** are removed as discrete, triggerable mini-games. Their core mechanical value — morale management and negotiation tension — is folded into the **Global Live Feed** as **Community-Driven Events**:

- **Solidarity Strike** (replaces Staff Rally logic): A server-wide event where all Maison members vote to commit resources to a shared workforce campaign. Collective participation boosts morale across all participating brands simultaneously.
- **Supply Chain Scramble** (replaces Supplier Raid logic): A timed community event where players compete and cooperate to lock down shared global supplier contracts before a deadline. Rewards scale with both individual contribution and collective Maison rank.

This reduces the mini-game menu cognitive load and file size while increasing the social virality of both mechanics.

---

### 12.3 Additions — The Viral Hook

**§12.3.1 — Trend Tsunami**
Every 48 hours, the meta shifts. A live server broadcast designates a specific aesthetic category — *Cyber-Couture*, *Quiet Opulence*, *Moto-Punk*, *Kintsugi Revival*, *Desert Sovereign* — as the current **Trend Tsunami**. Every garment and drop tagged with that aesthetic receives a significant Hype Score multiplier for the duration of the window.

This is not a passive bonus. It is a **live player-driven meta that forces strategic pivots every 48 hours** — the fashion equivalent of a breaking news cycle. Players who read the aesthetic correctly and design-to-prompt within the window earn outsized feed placement, follower growth, and hype. Players who hold relevant pieces in stock can release them at the peak of the wave for maximum market impact. Players who ignore it watch rivals absorb the visibility gains.

**Mechanics**:
- **Announcement**: 6 hours before the window opens, the Global Feed broadcasts the incoming Trend Tsunami theme — a full-bleed animated card with the aesthetic name, a mood palette, and Luxe commentary. Inactive players receive a push notification.
- **Window duration**: 48 hours from activation.
- **Scoring**: Alignment bonus is calculated as a ×1.5 multiplier applied to the Aesthetic_Alignment variable in the Hype Score formula (§4.1).
- **Mogul impact**: Architects can pre-position inventory in relevant cities and trigger timed campaigns during the window — the Trend Tsunami affects not just hype but city-level sales velocity.
- **Post-wave archive**: All Wave Rider-badged drops from each Trend Tsunami are archived in the Global Feed's **Tide Log** — a permanent record of who called the wave and profited. Reputations are built in the Tide Log.

**§12.3.2 — Vex: The AI Lookbook Critic**
The **Luxe Mentor System** is extended with a second AI personality: **Vex** — a razor-tongued critic who operates as the Global Feed's resident arbiter of taste. Vex does not encourage. Vex adjudicates.

Every drop posted to the feed with Vex opt-in enabled receives a **Vex Review Card** — a short-form, Vogue-headline-style verdict generated procedurally from the drop's Hype Score, material tier, trend alignment, cultural timing, and Maison context. The review card is formatted for **real-world social media shareability by design**:

- **Format**: Bold headline (one line, max 12 words) + one-line sub-caption + Vex's signature monogram stamp
- **Typography**: Rendered in a black editorial font on a cream card — ready to screenshot and post as-is to Instagram Stories or TikTok
- **Tone calibration**: Vex's tone shifts with Hype Score — scathing below 40, icily ambivalent at 40–65, reluctantly impressed at 65–80, genuinely reverent at 80+
- **Shareable examples by tier**:
  - *Below 40*: "Bold attempt. Wrong century." / "The fabric understood the assignment. The design did not."
  - *40–65*: "There's something here. It's buried, but it's there."
  - *65–80*: "Quiet luxury? More like loud confusion. But the drape? Immaculate."
  - *80+*: "This drop didn't just arrive — it colonised the feed." / "The new standard. Vex does not say that twice."
- **Engagement mechanic**: Players who share their Vex review card externally (tracked via QR/deeplink) and receive 50+ platform engagements earn a **"Vex Certified"** feed badge on that drop for 48 hours — the in-game equivalent of a critical cosign
- Players can opt in or out of Vex reviews per drop. Opting out is always available; opting in is the flex.

**§12.3.3 — Met Gala Weekly Tournament**
A time-limited, community-wide **PvP prestige event** running every Sunday. The server selects a single weekly theme (e.g., *"Machine Garden"*, *"Blood Diamonds"*, *"Zero Gravity Noir"*). Players submit one design entry. The community votes over 24 hours — likes, hype reactions, and Maison endorsements all contribute to a weighted score. The winner's **avatar and brand name** are displayed on the game's loading screen for every player globally for 24 hours. Second and third place earn limited cosmetic rewards. All participants earn Founder Rep and feed placement. The event recurs weekly with rotating themes generated by the trend engine.

---

### 12.4 Monetization Expansion — Status + Style Model

> The V6 monetization model upgrades from convenience-only to a **Status + Style** hybrid. The goal: reach the revenue ceiling of the category without compromising the F2P experience that drives installs.

**§12.4.1 — Gacha Recruitment System (expands §8.10 Talent Management)**
The Talent Management system is converted into a **Gacha Recruitment** mechanic for Creative Directors and Signature Collaborators. These characters provide visual VFX applied directly to garments — e.g., *"Golden Glow"* light-scatter textures, *"Digital Glitch"* scanline overlays, *"Obsidian Drape"* material sheen — and passive bonuses to H_score, trend velocity, or idle efficiency depending on the Director's specialisation.

**F2P Safeguard:** F2P players accumulate **Recruitment Vouchers** via Founder Rep milestones, Maison Collective Rewards, and Met Gala participation. The pity system guarantees a Rare Director pull at 40 pulls and a Legendary at 80. No Director provides a direct stat advantage unavailable through standard play — only unique VFX and cosmetic bonuses.

**Paid Access:** Premium pulls use **Prestige Credits** (hard currency). Legendary Creative Directors are cosmetic whales — they make your brand look extraordinary without making it mechanically unkillable.

**§12.4.2 — Limited Drop Season Pass**
A seasonal **Battle Pass** structure running in 8-week cycles. Standard tier (free) provides baseline rewards — Vouchers, materials, cosmetic frames. Premium tier (paid) adds a **Blueprint** reward: a one-time manufacturing license for a specific rare garment type, craftable once per season. This Blueprint item is eligible for listing on the **Resale & Second-Hand Platform**, creating secondary market value. Premium tier also includes a **Signature Colourway** — an exclusive palette unlock for the Atelier unavailable via any other means.

**§12.4.3 — Resale Platform Commission ("The Platform Tax")**
The Resale & Second-Hand Platform charges a **30% Platform Tax** on all player-to-player transactions. This applies to Blueprint items, rare materials, limited-edition garments, and Store Slot transfers. The tax is collected automatically on settlement. Revenue from the Platform Tax scales with the game's total active economy — creating a monetization stream that grows with the playerbase rather than requiring new content sprints.

**§12.4.4 — Rewarded Ads (F2P Voluntary Tier)**
F2P players may opt in to **"Hype Boosts"** — short rewarded video ads (15–30 seconds) that grant a 2-hour H_score multiplier, a small Voucher drop, or a temporary idle efficiency boost. Ads are strictly voluntary, capped at 5 per day, and never surfaced during active gameplay moments. The Hype Boost framing keeps the ad mechanic consistent with the game's brand identity.

**§12.4.5 — Recommended Revenue Mix**

| Method | Target Segment | Purpose |
|---|---|---|
| **Gacha (Talent / VFX)** | Whales & Collectors | High-ceiling revenue without P2W power creep |
| **Season Pass (Battle Pass)** | Casual & Mid-Tier | High retention and baseline monthly recurring revenue |
| **Resale Commission (30% Tax)** | All Players | Economy-scaled revenue stream growing with the playerbase |
| **Rewarded Ads (Hype Boosts)** | F2P Segment | Voluntary, brand-consistent ad monetization |

---

*This GDD contains the complete vision for The Styliste. All AI-generated assets, features, and code must be consistent with this specification.*

*SkinTeethNerd Studios · Version 6.0 · Confidential*