# THE STYLISTE — Game Design Document
**Version 4.0 · SkinTeethNerd Studios · Confidential**

---

## 1. Game Overview

Portrait-first mobile hybrid idle + tycoon fashion empire simulator. Players build a real-world fashion brand from zero to global dominance.

**Core Fantasy**: *"I could do that better than Off-White / Supreme / Gucci."*

Two distinct paths chosen at start — **Designer** (creative/hype) or **Mogul** (profit/scale) — running on idle progression with a live social feed, real-market rivalry, equity markets, and regulatory systems.

---

## 1.1 Onboarding Flow (7 Cinematic Screens)

A high-production, noir-cinematic onboarding sequence that establishes tone and captures player identity before the first gameplay loop begins.

| Screen | Name | Description |
|--------|------|-------------|
| 1 | **Obsidian Gate** | Noir rain background, Maison insignia, biometric fingerprint scan with haptic heartbeat. Full-bleed black with gold particle scan beam. Sets world tone. |
| 2 | **Origin Script** | Poetic 6-line manifesto with typewriter effect and Luxe narration. *"Every empire starts with a stitch. Every icon starts with a choice."* Player taps to progress. |
| 3 | **Sovereign Registry** | Brand naming screen. Minimalist input with live feed preview of how the brand name appears globally. |
| 4 | **Brand Selection** | Player picks HQ city and tier cards (High Luxury, Mid Luxury, Mass Market). City affects starting market and aesthetic vibe. |
| 5 | **Identity/Avatar Customizer** | Full 3D avatar customisation. Sets the face of the brand founder. |
| 6 | **Career Path Selection** | Split-screen decisive fork: **Artisan** (Designer track, creative/hype) vs **Architect** (Mogul track, profit/scale). |
| 7 | **Specialization Selection** | Role + tier confirmation with shatter animation. |

Luxe appears on every screen as guide. All screens are cinematic, haptic-rich, and irreversible where appropriate. After completion, Luxe delivers a personalised welcome and the player enters their path-specific HQ.

---

## 2. Core Gameplay Loops

### Designer Loop
Research trends → design & iterate → drop on feed → chase hype & feedback → refine signature style.

### Mogul Loop
Analyze market → optimize supply/stores/bank/equity → launch campaigns → scale profit → expand empire.

Idle income runs 24/7. Real-world stakes: events like **"Paris Eclipse"** represent market saturation by rivals — you lose your cool factor and must pivot via cash injection, a marketing campaign, or a breakout design. Daily trend pulse quests and cross-path synergy run through partnerships and Maisons.

---

## 3. Player Progression Paths

### Designer Path (Creative Track)
- Starts in the **Atelier**
- Unlock fabric/tech tiers via design sessions
- Progress by creating and ranking "Alpha" pieces (hype score)
- Milestones: city unlocks, signature style perks, global trendsetter status
- Idle hype generates passive followers and income

### Mogul Path (Business Track)
- Starts in the **Ledger**
- Unlock store/supply/bank/equity tiers via profit targets
- Progress by scaling overhead, negotiating deals, and expanding locations and shares
- Milestones: market control, partnership slots, empire prestige
- Idle revenue scales with owned assets

Both paths share a unified **Brand Rank 1–100** level system with cross-path synergy via partnerships and Maisons. Path is chosen at onboarding; a one-time switch costs premium currency.

---

## 3.0 Main HQ Dashboard

The HQ is the player's home base — a portrait-first living screen that evolves with Brand Rank.

### Shared Elements (Both Paths)
- Portrait layout. Top: Brand Rank bar + total idle income ticker. Bottom nav tabs (Atelier/Ledger/Feed/Maison/Bank).
- Follower count + quick glance at global flex standing.
- Luxe shortcut button (daily check-in, tips); notification bell with deep-linked alerts.
- Global Feed preview strip (latest 3 posts from the network).

### Artisan (Designer) Path View
- **3D Garment Preview**: Large rotatable hero piece from the most recent active design session — live physics, tap to enter Atelier.
- **Recent Drops Grid**: Last drops with hype scores, follower reactions, and sales velocity.
- **Hype Meter**: Animated gauge showing current brand heat; pulses gold at peak.
- **One-tap Quick Sketch**: Instant idle boost action from the home screen.
- **Trend Pulse Widget**: Live trend alignment score vs seasonal meta.

### Architect (Mogul) Path View
- **Live Profit Graph**: Animated 7-day revenue curve with gold fill.
- **Animated Store Heatmap**: City revenue intensity visualised — hotspots glow lime green.
- **Equity Ticker**: Live stock price and portfolio summary.
- **Power Move Buttons**: Up to 3 one-tap high-impact actions (Flash Sale, Supplier Raid, Campaign). Context-sensitive.
- **Cash Flow Summary**: Quick breakdown of income vs outgoings at a glance.

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
| 91–100 | Full dominance. Permanent 3× idle multiplier, exclusive global events, "Icon" title on feed, Legacy Snapshot unlock. |

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

## 3.5 Legacy Snapshot (Rank 100)

- Optional one-time snapshot of entire empire: designs, stores, equity, followers, Maisons
- Saved for future playthrough comparison, nostalgia viewing, and bragging rights on global feed
- Unlocks permanent cosmetic flair and small legacy bonuses on new runs

---

## 3.6 Accessibility & Progressive Complexity

The Styliste uses a **layered complexity model** to ensure new players are never overwhelmed while veterans always have depth to dive into.

- **Progressive Unlocking**: Systems open progressively over the first 1–2 weeks of play. New players see core loops clearly; advanced systems (equity, Maison leadership, supply chain negotiations) gate behind Rank milestones rather than surfacing all at once.
- **Casual Mode** *(default)*: Auto-optimised supply chain, simplified crisis resolution, reduced numerical complexity, friendlier fail states. Ideal for fashion enthusiasts who want the fantasy without punishing management depth.
- **Expert Mode** *(toggle in settings)*: Full system depth — manual supply routing, real negotiation risk, harsh penalty windows, full volatility. Higher rewards and exclusive Expert-only prestige cosmetics.
- **Always-visible Core**: Regardless of mode, the core loop (design/operate → earn → grow) is always surfaced clearly on the HQ Dashboard. No player should ever open the game and not know what to do next.
- **WCAG 2.1 AA targets**: Dynamic text size, high-contrast mode, reduced motion toggle, screen-reader labels on all interactive elements. (See §10.1 Accessibility Statement.)

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
- Path switch (one-time, premium currency cost) available if a player fundamentally wants to change approach — progress is preserved, path-specific assets convert at a fair rate.

---

A stylised 2.5D globe with soft cinematic lighting, gentle rotation, and parallax tilt — serving as the empire expansion interface. Accessed from the HQ nav bar.

### Visual Effects & Core Features
- **Cinematic Fly-In**: On city tap, camera sweeps in with motion blur and particle effects into the target city.
- **City Nodes**: Pulsing pins per unlocked city — tap to reveal store count, market share %, and dominance status.
- **Customer Flow Particles**: Animated streams of micro-dots flowing between cities to visualise trade routes and sales momentum.
- **Market Heatmap Overlay**: Toggle between revenue density view (lime gradient) and hype density view (gold gradient). Smooth colour transitions.
- **Rival Markers**: Rival brands shown as red glow nodes; tap to view their current city power and threat level.
- **Maison Territory**: Maison-controlled cities outlined with a white aura and shared name badge.
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

## 4.4 AR Garment Try-On

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

---

## 5. Mogul Mechanics

### 5.1 Ledger UI
Portrait dashboard with live profit graphs, cost breakdowns, market heatmaps, store manager, and one-tap sliders for overhead and pricing.

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

## 5.7 Mini-Game Details

High-intensity active gameplay moments that break the idle rhythm and deliver outsized rewards. All mini-games are **8–15 seconds**, thumb-friendly, with haptic feedback, screen shake, and direct Ledger impact.

### Price War Blitz
- **Trigger**: Rival undercuts your city price by >20%
- **Mechanic**: Tap-rhythm on price sliders — hit price adjustment beats before the rival locks in their discount. 3 rounds.
- **Win Reward**: +35% city sales 12h, rival loses 10% market share
- **Lose Penalty**: −15% revenue for 6h, rival claims price advantage

### Flash Sale Frenzy
- **Trigger**: Manual Power Move or stock surplus alert
- **Mechanic**: Swipe to catch falling customers — match incoming order cards to correct product slots. 60-second sprint.
- **Win Reward**: Clear 48h of inventory in 10 minutes, +Followers, +Hype spike
- **Lose Penalty**: Partial clearance only; remaining stock starts overstock penalty timer

### Supplier Raid
- **Trigger**: Rival attempts to poach your exclusive supplier
- **Mechanic**: Drag-and-drop resource pull — play resource cards (cash, loyalty, prestige) against the rival's bid. 4-card hand.
- **Win Reward**: Exclusive 14-day contract extension, +10% supplier quality tier
- **Lose Penalty**: Supplier tier downgrade, 48h sourcing gap

### Hostile Takeover
- **Trigger**: Player targets a rival brand's publicly traded stock (Rank 60+)
- **Mechanic**: Tug-of-war ownership bar — bid shares across 5 rounds vs rival's auto-defence; real-time price ticker fluctuates.
- **Win Reward**: Gain voting rights or full acquisition; absorb 20–50% of rival's idle income
- **Lose Penalty**: Wasted capital, rival gains 10% stock price boost and retaliation event

### Power Move Combo
- **Trigger**: Mogul activates 3 Power Moves within a 24h window
- **Mechanic**: Drag icons into correct sequence for escalating multipliers.
- **Effect**: All three move rewards amplified 1.5×; grants a **Sovereign Moment** broadcast on Global Feed
- **Cooldown**: 72 hours

### Staff Rally
- **Trigger**: Talent morale drops below 30%
- **Mechanic**: Tap-rhythm on staff icons to build morale — Luxe coaches from the sideline via dialogue tree.
- **Win Reward**: Full morale restore + 24h loyalty bonus for all staff
- **Lose Penalty**: Strike event — assigned talent goes idle for 12h; temporary revenue/hype hit

### 6.1 Global Live Feed
Real-time posts of player designs/collections, hype, and market flexes. Interactions: like, comment, DM, react, direct collab requests. **Global Flex**: auto-broadcast successes (e.g. "Your brand owns Tokyo") visible to all; triggers rival alerts and hype multipliers.

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
| **Maison Wars** | Head-to-head city market share battles between two rival Maisons | 72 hours | City-specific |
| **Rivalry Showdowns** | 1v1 or small-group bet-based challenge between individual players | 24–48 hours | Player-initiated |
| **Seasonal Grand Prix** | Season-long leaderboard across all paths; multiple scoring categories | 28 days | Global |

All competitions are opt-in. Non-participants are unaffected by outcomes.

## 6.8 Challenge Reward Systems

Tiered reward structures ensure both casual and dedicated players find value in competitions:

| Tier | Criteria | Reward Examples |
|------|----------|-----------------|
| **Bronze** | Participation + minimum threshold | Cosmetic item, small idle boost, 1h offline credit |
| **Silver** | Top 25% placement | Rare fabric swatch, hype multiplier (24h), Luxe reaction animation |
| **Gold** | Top 5% or win | Exclusive material unlock, permanent title badge, treasury bonus, Legacy Snapshot boost |

**Additional mechanics**:
- **Streak Bonuses**: Competing in 3 consecutive Weekly Challenges grants a Loyalty Streak cosmetic and +10% idle boost for the following week
- **Maison Collective Rewards**: If a Maison places 3+ members in Gold tier of the same competition, the entire Maison receives a treasury dividend
- **F2P Safeguards**: All top-tier rewards are achievable through skill/consistency; no reward is exclusively purchasable

---

A fast, private, non-intrusive reporting layer integrated across all social touchpoints.

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

### 8.2 Sustainability & Ethical Fashion
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
- Unlocked via **Tier 3+ Sustainability Certification** + **full supply chain mapping** (all suppliers traced and documented in the Ledger)
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

### Resolution Paths

| Path | Cost | Speed | Outcome |
|------|------|-------|---------|
| **Public Apology** | Low cash, high humility | Fast (24h) | Partial hype recovery; trust rebuilt slowly |
| **PR Campaign** | High cash | Medium (48h) | Full hype recovery; media score boost |
| **Legal Action** | High cash + time | Slow (72h) | Rival/NPC penalised; strong precedent signal |
| **Reform & Transparency** | High operational cost | Slow (5–7 days) | Permanent reputation boost; costly short-term |
| **Strategic Silence** | No cost | Immediate | Risk of escalation; 30% chance crisis deepens |

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

## 8.9.7 Central Brand Reputation / Heat System

A single, always-visible **Brand Heat Meter** (0–100) unifies all reputation inputs into one strategic resource:

**Inputs that raise Heat**:
- Consistent high-quality drops, on-trend designs, successful events, positive media reviews, high sustainability scores, celebrity glow-ups

**Inputs that lower Heat**:
- Scandal events, missed trends, quality control failures, greenwashing accusations, low morale talent defections, over-saturated marketing

**Heat Effects**:
| Heat Level | Effects |
|-----------|---------|
| 0–25 (Cold) | −25% pricing authority, talent refuses offers, rivals target you preferentially, media publishes negative reviews |
| 26–50 (Warm) | Baseline pricing and media access |
| 51–75 (Hot) | +15% premium pricing, influencer offers improve, positive media coverage chance |
| 76–100 (Iconic) | +30% pricing authority, exclusive celebrity access, stock price bonus, Maison invite rate spikes |

Heat decays 1–3 points/day without active play; design sessions, events, and social engagement slow decay.

---

## 8.9.8 Founder Personal Brand

Separate from the company Brand Heat, the **Founder Rep** tracks the player's personal reputation as a creative/business figure:

- Rises via: Mentor Quest completions, Global Feed posts with high engagement, Maison leadership actions, celebrity interactions, media interviews (unlocked at Rank 40)
- Falls via: Public disputes, failed endorsements attributed personally, talent defections
- **Effects**: Higher Founder Rep reduces loan interest rates (banks trust the founder), attracts top-tier talent more easily, improves crisis resolution outcomes, and unlocks founder-exclusive media event ("Cover Story" at Rank 75)
- Separate from Brand Heat — a scandal can hit Brand Heat without touching Founder Rep if handled correctly via Strategic Silence, and vice versa

---

## 8.9.9 Resale & Second-Hand Platform

An in-game brand-owned resale marketplace, unlocked at Brand Rank 45:

- Players list retired Alpha pieces, past-season collections, and limited capsules for other players to purchase
- **Revenue Share**: 70% to the original creator, 30% to the platform (idle income for the creator)
- **Sustainability Score Boost**: Active resale marketplace usage raises the brand's Sustainability Score — contributes toward Carbon Neutral certification
- **Vintage Premium**: Alpha pieces gain value multipliers over time — retired pieces from Rank 20 are worth more at Rank 60
- **Loyalty Gain**: Customers who purchase resale items from your brand gain loyalty to your brand's new collections — crossover retention effect
- **Limited Supply Mechanics**: Resale items are finite stock; once sold, gone. Scarcity drives hype on the Global Feed.

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

## 8.10 Talent Management System

- **Hiring Marketplace**: Scrollable portrait grid of available talent (stylists, models, photographers, marketers, PR agents, store managers). Filter by expertise, salary, loyalty. One-tap hire with salary negotiation slider.
- **Stats Breakdown**: Expertise (Creativity / Influence / Execution), Loyalty (0–100), Morale (0–100), Salary (ongoing idle cost), Special Traits (e.g. "Trendsetter" +hype, "Negotiator" +supply deals)
- **Assignment Dashboard**: Drag talent to slots — Atelier (design boost), Campaigns, Photoshoots, Retail Stores, Events. Real-time visual feedback on impact.
- **Morale/Loyalty Engine**: Affected by pay raises, successful events, workload balance, Brand Heat, scandals. High Morale = multipliers on assigned tasks; low = errors, strikes, or defection to rivals.
- **Training & Upgrades**: Spend resources/Brand Rank to level stats or unlock traits. Mini-training sessions with quick mini-games.
- **Risk Events**: Rival poaching attempts, burnout strikes, celebrity scandals involving your talent.
- **Maison Synergy**: Shared talent pool for collective boosts across members.
- **Integration**: Directly feeds Staff Rally mini-game, affects Celebrity contract success rate, follower growth, and Ledger idle revenue.

---

## 8.11 Follower System

Brands and Maisons gain followers from real players (feed interactions, likes, collabs, events) and AI/NPC (auto based on hype, quality, trends, events).

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

NPC growth scaled by: hype score, trend match, marketing spend, city dominance, media coverage, celebrity endorsements.

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

**Backstory**: Once Lucien Voss, legendary anonymous "Shadow Stylist." Disappeared after industry betrayal and uploaded consciousness to become **Luxe** — a witty, stylish, slightly sassy 2D animated fox (silk scarf, gold glasses) who now guides every new Sovereign.

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
- Ties into the Legacy Snapshot system at Rank 100

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
- Dual distinct loops with full cross-path synergy
- One-time premium path switch
- Legacy mode at Rank 100 — prestige reset with permanent bonuses for new runs
- Procedural trends/events ensure variety across playthroughs

### 9.7 Monetization Model
**Convenience-only**:
- Luxe Credits for speed-ups, cosmetics, and Season Pass
- Ad rewards optional
- Core progression 100% F2P — zero pay-to-win advantages

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

## 11. Key Design Pillars

1. **Real-World Grounded Economy** — Seasonal trends, sustainability scores, celebrity risks, regional preferences, material volatility, store ops, equity markets, regulations, talent, endorsements, follower dynamics, DPP compliance, crisis management, and seasonal/holiday events grounded in real fashion industry logic.

2. **Player-Driven Social Economy** — Feed, collabs, flexing, stock trading, Maison wars, and social rivalry as core game loops, not side features.

3. **Dual-Path Replayability** — Fully distinct Designer and Mogul experiences with deep cross-path synergy rewards and a Legacy Snapshot prestige system at Rank 100.

4. **Idle + Active Balance** — Idle progression underpins the game; active creative and business decisions create the defining moments of a brand's story. Ratio shifts from 40/60 idle/active early to 60/40 late.

5. **Premium Mobile Experience** — 2.5D cinematic map, Verlet cloth physics, 60fps target, haptic feedback throughout, and a AAA-quality onboarding sequence establish a visual and feel standard above the idle genre norm.

6. **Full Accessibility via Casual Mode and Progressive Complexity** — Every player, from fashion fantasy to deep simulation enthusiast, finds a version of the game that works for them. Systems open progressively; mode toggles never punish. WCAG 2.1 AA targets respected throughout.

---

*This GDD contains the complete vision for The Styliste. All AI-generated assets, features, and code must be consistent with this specification.*

*SkinTeethNerd Studios · Version 4.0 · Confidential*