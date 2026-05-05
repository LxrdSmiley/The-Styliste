The Styliste – Game Design Document (GDD)

1. Game Overview
Portrait-first mobile hybrid idle + tycoon fashion empire simulator. Players build a real-world fashion brand from zero to global dominance. Core fantasy: "I could do that better than Off-White/Supreme/Gucci." Two distinct paths (chosen at start): Designer (creative/hype) or Mogul (profit/scale). Idle progression + live social feed + real-market rivalry + equity markets + regulations.

2. Core Gameplay Loops

Designer Loop: Research trends → design/iterate → drop on feed → chase hype/feedback → refine signature style.
Mogul Loop: Analyze market → optimize supply/stores/bank/equity → launch campaigns → scale profit → expand empire.
Idle income runs 24/7. Real-world stakes: events like "Paris Eclipse" = market saturation by rivals → lose cool factor → pivot via cash/marketing or breakout design. Daily trend pulse quests and cross-path synergy via partnerships/Maisons.

3. Player Progression Paths

Designer Path (Creative Track): Starts in Atelier. Unlock fabric/tech tiers via design sessions. Progress by creating/ranking "Alpha" pieces (hype score). Milestones: city unlocks, signature style perks, global trendsetter status. Idle hype generates passive followers/income.
Mogul Path (Business Track): Starts in Ledger. Unlock store/supply/bank/equity tiers via profit targets. Progress by scaling overhead, negotiating deals, expanding locations/shares. Milestones: market control, partnership slots, empire prestige. Idle revenue scales with assets owned.
Both paths share Brand Rank 1-100. Cross-path synergy via partnerships/Maisons. Path chosen at onboarding; one-time switch costs premium currency.

3.1 Brand Rank Milestones (1–100 shared system)

1–10: Tutorial complete. Unlock basic Atelier/Ledger tools, first local city store, starter idle income.
11–20: Partnerships enabled. City expansion slot +1. Idle hype/revenue +20%.
21–30: First Maison invite. Global feed verification badge. Co-drop access.
31–40: Supply chain tier 2 + basic loans. Signature style/ledger perk (path-specific). Market saturation resistance +25%.
41–50: International city unlocks + online stores. Hype multiplier on flex posts. Auto-partner search.
51–60: Advanced Maison leadership roles + equity trading/IPO unlock. Premium capsule drops. Idle treasury bonus.
61–70: Rival event immunity in 2 cities + stock investments. Brand prestige aura (feed visibility boost).
71–80: Empire mode: multi-Maison alliances + joint IPOs. 2x city dominance bonuses.
81–90: Legendary Alpha piece or mega-store chain + public stock offering. Global trendsetter status.
91–100: Full dominance. Permanent 3x idle multiplier, exclusive global events, "Icon" title on feed, Legacy Snapshot unlock.
Progress via combined design/profit actions + idle time. Path-specific bonuses stack on shared rank.

3.2 Brand Rank Pacing

Early Game (1–25): Fast onboarding. Reach Rank 25 in 3–7 days casual play. Frequent unlocks, tutorial rewards, quick idle ramps.
Mid Game (26–65): Steady strategic growth. 1–3 ranks/week regular play. Systems fully open; focus on decisions, social, partnerships.
Late Game (66–100): Prestige-focused. Slow, satisfying pace (2–6+ months for top ranks). Heavy idle scaling, empire optimization, rival dominance + equity plays.
Sources: 35% active actions, 35% idle (scales higher late-game), 20% social, 10% events. Daily streaks + weekly challenges boost casual players. Idle/active ratio shifts from 40/60 early to 60/40 late.

3.3 Idle Progression Mechanics

Offline earnings (up to 24h) based on Brand Rank, owned assets (stores/supply/designs), Maison treasury share, and path multipliers.
Auto-scales: early game 40% idle contribution → late game 70%.
Passive boosters: completed Alpha pieces add permanent hype multiplier; stores generate compounding revenue.
Daily streak protection & auto-reinvest (one-tap "Empire Mode").
Soft cap with decay timer; active play resets and accelerates.

3.4 Idle Soft Cap Mechanics

Full-rate offline earnings for the first 24 hours.
Soft decay after 24h: linear drop to 40% efficiency.
Active play (any session) resets decay and grants Momentum buff (100% rate for 12h).

3.5 Legacy Snapshot (Rank 100)

Optional one-time snapshot of entire empire (designs, stores, equity, followers, Maisons).
Saved for future playthrough comparison, nostalgia viewing, and bragging rights on global feed.
Unlocks permanent cosmetic flair and small legacy bonuses on new runs.

3.6 Onboarding Flow (7 Cinematic Screens)

1. Obsidian Gate: Noir rain background, Maison insignia, biometric fingerprint scan with haptic heartbeat. Full-bleed black with gold particle scan beam. Sets world tone.
2. Origin Script: Poetic 6-line manifesto with typewriter effect and Luxe narration. Example line: "Every empire starts with a stitch. Every icon starts with a choice." Player taps to progress.
3. Sovereign Registry: Brand name input with live global feed preview showing how the brand name appears publicly.
4. Brand Selection: HQ city choice (New York, Paris, Tokyo, London, Lagos, Milan) + tier cards (Underground, Emerging, Established). City affects starting market and aesthetic.
5. Identity/Avatar Customizer: Full 3D avatar customization.
6. Career Path Selection: Split-screen choice between Artisan (Designer) and Architect (Mogul). Animated branching visual with distinct aesthetics for each path.
7. Specialization Selection: Role + tier confirmation with shatter animation. Luxe appears for the first time to congratulate the choice.
Luxe appears on every screen as guide. All screens are cinematic, haptic-rich, and irreversible where appropriate.

4. Design Mechanics

Atelier UI: Portrait-first canvas with rotatable 3D garment model. Layer-based editor: silhouette base, fabric swatches, textures, trims, prints, hardware.
Creation Flow: Drag-drop elements from unlocked library. Real-time physics preview (drape, fit, movement). Color wheel + pattern generator. AI trend suggestions.
Design Stats: Auto-calculated hype score, sell potential, cultural impact. "Alpha" pieces require perfect balance for legendary status.
Session Types: Quick sketch (idle boost) or deep session (manual tweaks + higher quality). Timers/resource costs for advanced tools.
Progression Ties: Unlock fabric/tech tiers via Brand Rank. Designs feed directly into feed posts, co-drops, and idle sales. Signature style perks apply globally.

4.2 Atelier Physics Simulation

Real-time cloth simulation on rotatable 3D avatar using optimized Verlet integration.
Per-fabric parameters: density, stiffness, elasticity, friction, drape coefficient, bend resistance.
Dynamic behaviors: gravity drape, stretch/compression, wrinkles, bounce, self-collision, body collision.
Avatar animations: idle pose, walk cycle, spin, wind gusts (adjustable intensity).
Instant recalculation on any layer/fabric/trim change.
Touch controls: pinch to rotate model, drag for temporary wind/pose.
Mobile-optimized with adaptive LOD and shader fallback for 60 fps target.

4.3 Avatar Customization

Body Types: 8 presets (Slim, Athletic, Curvy, Plus-Size, Tall, Petite, Muscular, Hourglass) — directly affect cloth drape, stretch, and fit physics.
Skin Tones: 24 realistic shades with warm/cool undertones.
Hair: 30+ styles & colors.
Face Presets: 12 combinations (eye shape, nose, lips, jawline).
Poses: 10 dynamic preview poses (walk cycle, spin, idle, runway strut).
Accessories: Jewelry, glasses, hats, scarves (non-interfering with garment layers).
All changes instantly update physics simulation.

4.4 AR Garment Try-On

Light AR mode in Atelier: preview designs on real-world camera feed.
Shareable screenshots/videos for viral social posting. Auto-populates a feed post draft with garment name, hype score, and brand tag on share.
Unlocked early; boosts follower growth and hype.
AR Drop Badge: Shared AR posts receive a special badge on the Global Feed, boosting post visibility by 40%.
"I'd Wear This" Reaction: Dedicated reaction type on AR posts that counts directly toward the hype score.
Viral Moment Bonus: AR posts with 100+ reactions trigger +15% global followers for 6 hours.

4.5 Main HQ Dashboard

Shared: Portrait layout. Brand name + rank badge header with animated prestige aura at higher tiers. Follower count ticker (live, animated) + idle income meter with pulse animation. Luxe shortcut button for daily check-in and contextual tips. Global Feed preview strip showing latest 3 posts from the network. Notification bell with deep-linked alerts + quick-nav bottom nav tabs (Atelier/Ledger/Feed/Maison/Bank).
Artisan (Designer) View: Large rotatable 3D garment preview (live physics) — rotating hero piece from the most recent design session; tap to enter Atelier. Recent Drops Panel showing last 3 collections with hype scores and sales velocity. Hype Meter + Trend Pulse Widget. One-tap Quick Sketch.
Architect (Mogul) View: Live profit graph (animated 7-day revenue curve) + animated City Heatmap showing revenue intensity globally. Equity ticker. Power Move Buttons — up to 3 one-tap high-impact actions (Flash Sale, Supplier Raid, Campaign). Supply Chain Health Bar indicator. Cash flow summary.

5. Mogul Mechanics

Ledger UI: Portrait dashboard with live profit graphs, cost breakdowns, market heatmaps, store manager, and one-tap sliders for overhead/pricing.
Store Ops: Physical flagships (city hype/loyalty) + online e-commerce (volume/scalability). Auto-sell idle with separate dashboards; tied to supply chain and marketing.
Deal Negotiation: Quick risk/reward sessions for vendor deals, endorsements, expansions. Direct profit multipliers.
Progression Ties: Scales via Brand Rank (store/supply/bank/equity tiers). Assets boost idle revenue; pairs with Designer co-drops for hype multipliers.

5.1 Supply Chain Logistics

Tiered global suppliers unlocked via Brand Rank/profit (Local → Regional → International → Luxury).
Three categories: Raw Materials, Manufacturing, Logistics Partners.
Each supplier rated on Quality, Cost, Reliability, Prestige.
Contract system: duration, exclusivity, volume commitments.
Logistics sliders: route selection, shipping method (air/sea), tariff/risk level.
Real-time global events (strikes, trade disputes, shortages) dynamically shift prices/availability.
Idle upgrades: warehouses, tracking, sustainable sourcing (hype bonus).
Maison/partnership synergy: pooled access + major discounts.

5.2 Supplier Negotiation Risks

Deal Failure: 40% chance of lost time/resources + temporary supply shortage (idle revenue -30% for 24h).
Hidden Tariffs: Locked high fees if risk slider pushed; +25% costs until renegotiated.
Quality Drop: Lowball offer triggers defective batch (hype penalty on sales, -15% sell rate).
Supplier Backlash: Over-negotiation risks blacklist (tier downgrade for 48h, no volume discounts).
Event Multiplier: Real-time global events (trade war, strike) amplify all risks/rewards by 2x.
Reward Flip: Successful high-risk roll grants exclusivity or 50% cost cut for 7 days.

5.3 Inventory Management

Ledger UI Panel: Real-time global stock grid (per city/store). Color-coded alerts: green (optimal), yellow (low), red (critical shortage/overstock).
Auto-Restock: Idle system auto-orders based on sales forecast sliders; manual override for surges.
Overstock Penalty: Excess inventory incurs daily storage fees (scales with tier) + hype decay if unsold >7 days.
Shortage Penalty: Stockouts cause immediate lost sales (-revenue) and hype damage (-15% global feed visibility).
Optimization Tools: Bulk transfer between stores, liquidation sales (quick cash but hype hit), predictive AI forecasts.
Synergy: Maison/shared partnerships auto-balance inventory across members; reduces fees by 40%.
Progression Tie: Brand Rank unlocks larger warehouses, faster restock speeds, and risk-free buffer stock.

5.4 Marketing Mechanics

Campaign Builder with presets/custom, budget sliders, ROI forecasts.
Effects: +30–100% sales/hype (24–72h), feed visibility surge.
Risks: Over-spend = hype fatigue (-48h engagement); mistimed = rival counters.
Synergy: Maison pooling = 40% lower cost, city/global scale.
Progression: Brand Rank unlocks premium channels (Fashion Week, billboards, celebs).

5.4.1 Campaign Builder Details

One-tap presets: Social Blast (low-cost feed boost), Influencer Drop (targeted hype), Runway Event (prestige spike), Targeted Ads (geo-specific sales).
Custom mode: Drag elements, set budget/duration/audience (cities/paths/Maisons).
Live preview: ROI graph, risk meter, projected sales/hype.
Launch from Ledger; auto-ties to inventory forecast.

5.5 Central Bank & Equity System

Borrow tiered loans (credit score tied to Brand Rank/reputation); pay off debt.
Issue/sell shares publicly (stock ticker on global feed) or privately.
Invest in other brands/Maisons for dividends + voting rights.
Portfolio dashboard, hostile takeovers, joint IPOs with partners.
Market volatility events add risk/reward. Integration with stores for revenue-backed shares.

5.6 Equity Trading Mechanics

IPO unlocked at Brand Rank 60.
Dynamic valuation based on revenue, hype score, market share, Brand Rank, and recent performance.
Public Stock Marketplace with live ticker on global feed.
Issue common/preferred shares; set dividend payout ratios.
Buy/sell shares publicly or privately; portfolio dashboard.
Dividends paid as passive income.
Voting rights at 10%+ ownership.
Hostile takeover at 51%+ ownership.
Shares usable as loan collateral. Risks: dilution, market crashes.

5.7 Interactive 3D Map

Stylized 2.5D globe with soft cinematic lighting, gentle rotation, and parallax tilt.
Pulsing city pins, animated customer flow particles, dynamic heatmap with smooth color gradients.
Tap city → cinematic fly-in with motion blur and particle effects.
Visual Effects: Fly-In Animation — camera sweeps from space into player's HQ city with gold light-trail streak on open. Customer Flow Particles — animated micro-dot streams between cities visualizing trade routes and sales momentum. Market Heatmap Overlay — toggle between revenue density (lime gradient) and hype density (gold gradient). Rival Markers — rival brands shown as red glow nodes; tap to view current threat level and city power. Maison Territory — Maison-controlled cities outlined with white aura and shared name badge.
Mogul View: Drag-drop stores, Power Move buttons (Flash Sale, Hostile Takeover, Price War), full logistics lines, revenue heatmap + profit streams, competitor acquisition and supply raid events.
Designer View: Influence waves from designs, creative event placement (Viral Drop, Pop-Up Event), hype/trend heatmap + follower flow, trend cascade events and runway activations.
Real-time Supabase sync for market share, sales, and follower impact.

5.8 Ledger Mini-Games

Price War Blitz: Tap-rhythm on price sliders.
Flash Sale Frenzy: Swipe to catch falling customers.
Supplier Raid: Drag-and-drop resource pull.
Hostile Takeover: Tug-of-war ownership bar.
Power Move Combo: Drag icons into correct sequence for escalating multipliers.
Staff Rally: Tap-rhythm on staff icons to build morale.
All mini-games are 8–15 seconds, thumb-friendly, with haptic feedback, screen shake, and direct Ledger impact.

6. Social & Multiplayer Systems
6.1 Global Live Feed: Real-time posts of player designs/collections, hype, market flexes. Interactions: like, comment, DM, react, direct collab requests. Global Flex: auto-broadcast successes (e.g. "Your brand owns Tokyo") visible to all; triggers rival alerts and hype multipliers.

6.2 Partnerships

Instant formation via feed DM or Collab button.
Optimal: Designer + Mogul synergy (art + scale).
Benefits: co-drop limited capsules (auto-sell faster), shared supply chains/stores/marketing costs, joint Maison ownership for city dominance.
Visible on global feed; creates rival events and hype boost.

6.2.1 Profit Splits (Partnerships)

Negotiated at formation (any ratio, 50/50 default).
Applies to all joint revenue: co-drops, shared stores, supply chains, marketing.
Real-time idle distribution to both wallets.
Adjustable anytime by mutual agreement.
Publicly displayed on feed and profiles for transparency/hype.

6.3 Maisons
Guild-like player houses; create or join via feed invites, search, or public recruitment.

5–20 members (mix of Designers + Moguls optimal).
Pool resources: shared treasury, supply-chain discounts, marketing fund (idle income multiplier scales with size).
Co-own and upgrade stores in cities; split revenue automatically.
City dominance: collective market control grants exclusive bonuses, rival protection, and global flex.
Joint capsules/drops and Maison-only events with hype multiplier.
Internal chat + private feed; visible prestige on global feed.
Leadership roles and voting for decisions; mutual agreement to leave or dissolve.

6.3.1 Maison Leadership Roles

Founder/Leader: Full control—invite/kick, dissolve Maison, appoint roles, treasury veto.
Creative Director (max 2): Approves co-drops, sets design themes; Designer-preferred (hype multiplier).
Executive Director (max 2): Manages treasury, stores, profit splits; Mogul-preferred (revenue bonus).
Brand Director (max 2): Handles recruitment, global feed posts, marketing; any path.
Roles appointed by Leader or elected by majority vote (30-day terms). Major decisions require 2/3 leadership approval. Visible on global feed for prestige.

6.3.2 City Dominance Bonuses

2x revenue from all co-owned stores in the city (idle distribution to Maison treasury).
Exclusive supply-chain discount (30% lower costs for all members).
Automatic hype multiplier on global feed posts (+50% engagement/likes).
Rival protection: rivals cannot trigger market saturation events in the city.
Unlock Maison-only limited capsule drops with premium pricing.
Global flex badge on all member profiles; auto-broadcasts city ownership.

6.4 Expanded Social Media / Multiplayer Features

Global + regional live feeds with trending hashtags, story replies, and viral challenges.
Real-time multiplayer: co-hosted Fashion Week runway events, live bidding on rare supplier contracts.
Leaderboards (city/global, per path, Maison rankings).
Player market for trading rare fabrics, store slots, or endorsement contracts.
Cross-player rival "beef" mode with public diss tracks and bet-based challenges.
Voice chat / group DMs inside Maisons and partnerships.

6.5 Additional Social & Multiplayer Hooks

Live runway streaming with real-time audience reactions and voting.
Weekly themed challenges with community voting and prizes.
Follower system with engagement metrics that drive passive hype/sales.
Public drama feed showing alliances, rivalries, and betrayals.
Collaborative capsules and real-time shared Atelier for partners.
Stock ticker integration for public share sales and investments.

6.6 Player Reporting System

Access Points: Long-press any feed post, three-dot menu on profiles, in-chat report, leaderboard/rival list.
Reporting Flow: One-tap modal with categories (Harassment, Cheating/Botting/Hacking, Spam, Inappropriate Content, Copyright/IP Theft, Guidelines Violation, Other) + optional description and screenshot.
Backend: Stored in Supabase player_reports table with reporter/reported IDs, reason, evidence, and status.
Anti-Abuse: Cooldown and rate limiting. Immediate notification to developer.
Player Feedback: Luxe confirmation message; players can view report history in Support tab.

7. Rival Mechanics

Market share % contested in every major city (players vs NPC + active player rivals).
Eclipse Events ("Paris Eclipse", "Tokyo Takeover"): rival dominance causes your hype/revenue loss.
Rivalry actions: price undercutting, targeted marketing, supplier poaching, hype-jacking.
Feed rivalry: public flexing, dissing, callouts.
Counterplay: counter-campaigns, superior Alpha drops, anti-rival alliances, temporary truces.
Rivalry Score builds over time; high score = special events + bigger victory rewards.
Dominating rivals grants bonus idle income, prestige titles, temporary city control bonuses.

7.1 Deepened Rival Counterplay Tactics

Timed Alpha counter-drops to steal hype.
Geo-targeted counter-campaigns to reclaim cities.
Supplier/influencer poaching reversal.
Temporary Maison anti-rival alliances.
Feed callouts/diss for public swing.
PR/crisis management investments.

7.2 Fashion Event System

Seasonal calendar (Spring/Summer, Fall/Winter).
Major global events: Paris/Milan/NY/Tokyo/London Fashion Weeks.
Player participation: submit collections, host pop-ups/runway shows.
Rewards: hype/sales multipliers, prestige, contracts.
Risks: high costs, prestige loss on failure.
Ties to real trends for immersion.

7.3 Seasonal Event Systems

Live real-time seasonal calendar (Spring/Summer, Fall/Winter + Pre-Season, Resort).
Major global events with unique themes (Sustainable Innovation, Streetwear Revolution, Heritage Revival, Digital Fashion Future).
Event types: Themed Collection Challenges, Market Domination Races, Maison Competitions, Celebrity Pop-ups, Global Leaderboards.
Rewards: Massive temporary multipliers (hype, sales, followers, stock), exclusive materials, badges, equity boosts.
Duration: 14–28 days. Risks: high investment, rival sabotage, trend misalignment. Strong cross-path synergy encouraged.

7.4 Holiday Fashion Events

Time-limited, high-impact events tied to real-world holidays and cultural moments (Valentine's Day, Halloween, Christmas/Holiday Season, Lunar New Year, Pride Month, Black Friday, etc.).
Themed challenges with specific design briefs, color palettes, or concepts.
Massive global feed exposure and special leaderboards.
Exclusive holiday materials, patterns, and capsules.
Major boosts to followers, sales, hype, and stock value.
High risk/high reward: significant marketing investment required with potential for huge returns or backlash if poorly executed.
Strong synergy with Celebrity Endorsements and Talent Management.

8. Realism & Simulation Systems
8.1 Seasonal Trend Cycles

Game follows a real-time yearly calendar with 4 major seasons plus Pre-Season forecasting windows.
Trend Forecasting Tool available in Atelier and Ledger (higher Brand Rank = better prediction accuracy).
Trending categories include colors, silhouettes, fabrics, and cultural aesthetics.
Designing in line with trends grants major hype and sales multipliers.
Misaligned designs receive "outdated" or "off-trend" penalties.

8.2 Sustainability & Ethical Fashion

Every material, fabric, and manufacturing choice has a visible Sustainability Score and Carbon Footprint.
Premium eco-materials cost more but boost hype, loyalty, and media favor.
Unlockable certifications (Organic, Fair Trade, Carbon Neutral) provide prestige and marketing advantages.
Choice between "Fast Fashion" (cheap, fast, low hype) vs "Slow Fashion" (expensive, sustainable, high prestige).

8.3 Celebrity Endorsement System

Tiered roster: Micro-Influencers, Rising Stars, A-List Celebrities, Global Icons.
Contract types: One-off campaign (1-4 weeks), Seasonal Ambassador (3-6 months), Long-term Brand Face (6-12+ months).
Contract Negotiation: Mini-game in Ledger with 3-round bidding: sliders for fee, duration, exclusivity, creative control, morality clauses, performance bonuses. Success meter based on Brand Heat match, trend alignment, celebrity mood.
Influencer Collaboration Tiers: Nano (cheap/authentic/local), Micro (targeted/co-design), Mid (balanced/campaign), Macro (viral/takeover), Mega (global/flex — up to 300% hype).
Benefits: massive short-term hype multiplier (up to 300%), sales boost, feed visibility surge, stock price lift, prestige.
Revised Risks: Scandal chance 5–25% (scales with length/fee mismatch/low compliance); backlash (hype fatigue -30% after 4 weeks); ghosting (low talent morale); positive glow-up (+50% sales if aligned). Mitigation via PR, clauses, reputation buffer. Visible in negotiation preview.
Synergies: pairs with marketing, photoshoots, talent, runway events, Alpha drops. Visible global feed flex.

8.4 Intellectual Property Protection

Pay to Trademark key designs or collections.
Risk of design theft by rivals/NPC brands.
Counterplay includes public callouts and legal action (lawsuits).
Protected designs gain "Signature" status with extra hype value.

8.5 Global Economic Volatility

Dynamic events: Inflation spikes, recessions, currency fluctuations, luxury market booms.
Events affect production costs, consumer spending, and pricing per city.
Mitigation via city diversification and stockpiling.

8.6 Customer Demographics & Loyalty

Each city has unique customer segments with distinct preferences.
Loyalty meters per city/segment – consistent quality increases repeat buyers and premium pricing.
Detailed demographic analytics available in the Ledger.

8.7 Media & PR System

Fashion media outlets, critics, and publications provide reviews and ratings.
Positive reviews create hype multipliers; negative coverage causes damage.
Players can run PR campaigns or crisis management.

8.8 Additional Realism Features

Talent management: hire/manage stylists, models, marketers (skills, salary, morale).
Photoshoot & lookbook production for hype boosts.
Wholesale/retailer licensing deals.
Dynamic demand curves and pricing engine per city.
Brand heat/reputation meter (affected by consistency, scandals, trends).
Quality control with defect risks.

8.9 Fashion Industry Regulations

Compliance meter for labor laws, environmental standards, advertising rules, import/export tariffs/quotas, and IP enforcement.
High compliance grants reputation/loyalty/media bonuses and lower costs.
Violations trigger fines, reputation damage, temporary restrictions.

8.10 Talent Management System

Hiring Marketplace: Scrollable portrait grid of available talent (stylists, models, photographers, marketers, PR agents, store managers). Filter by expertise, salary, loyalty. One-tap hire with salary negotiation slider.
Stats Breakdown: Expertise (Creativity / Influence / Execution), Loyalty (0-100), Morale (0-100), Salary (ongoing idle cost), Special Traits (e.g. "Trendsetter" +hype, "Negotiator" +supply deals).
Assignment Dashboard: Drag talent to slots — Atelier (design boost), Campaigns, Photoshoots, Retail Stores, Events. Real-time visual feedback on impact.
Morale/Loyalty Engine: Affected by pay raises, successful events, workload balance, Brand Heat, scandals. High Morale = multipliers on assigned tasks; low = errors, strikes, or defection to rivals.
Training & Upgrades: Spend resources/Brand Rank to level stats or unlock traits. Mini-training sessions with quick mini-games.
Risk Events: Rival poaching attempts, burnout strikes, celebrity scandals involving your talent.
Maison Synergy: Shared talent pool — pool resources for collective boosts across members.
Integration: Directly feeds Staff Rally mini-game, affects Celebrity contract success rate, follower growth, and Ledger idle revenue.

8.11 Follower System

Brands and Maisons gain followers from real players (feed interactions, likes, collabs, events) and AI/NPC (auto based on hype, quality, trends, events).
Follower count directly influences: perks (bonuses), quirks (unique traits), hype/popularity (sales/feed boost), power (leaderboard rank, city dominance), trust (loan rates, investor appeal).
Other boosts: idle income scaling, talent attraction, partnership invites, stock valuation, endorsement success rate.

8.11.1 Follower Acquisition Mechanics

Real players: Feed interactions (likes/shares/comments = 1-10 followers each), co-drops/partnerships (+50-300), event wins/runway votes (+100-1000), viral challenges.
AI/NPC: Passive daily growth (0.5-3% of current followers) scaled by hype score, trend match, marketing spend, city dominance, media coverage, celebrity endorsements.
Triggers: IPO hype spikes, scandal recovery PR, Maison collective boosts.
Caps/Multipliers: Tiered by Brand Rank; higher totals unlock perks, quirks, leaderboard power, trust.

8.11.2 Follower Engagement Strategies

High-quality content drops (collections, lookbooks, BTS).
Interactive polls, Q&A, design voting.
Giveaways, early-access capsules, UGC contests.
Community challenges.
Live Atelier/runway sessions and AMAs.

8.11.3 Follower Retention Tactics

Loyalty tiers with escalating perks (discounts, exclusives, badges).
Personalized rewards and shoutouts.
Brand storytelling and feedback implementation.
Consistent cadence and recovery campaigns.
Transparent updates and crisis management.

8.12 Luxe Mentor System

Backstory: Once Lucien Voss, legendary anonymous "Shadow Stylist." Disappeared after industry betrayal and uploaded consciousness to become Luxe — a witty, stylish, slightly sassy 2D animated fox (silk scarf, gold glasses) who now guides every new Sovereign.
Role: Personal mentor who speaks directly to the player. Appears in onboarding, daily check-ins, contextual tips, and milestone moments.
Daily Check-Ins: Automatic on first app open. Personalized message + 1–2 tips + small reward (idle boost or cosmetic). Optional 5-second quick action for bonus. Skippable after 3 seconds.
Tone: Encouraging, playfully teasing, proud of player success.
Daily Check-In Streak Rewards:
Day 1: "You showed up. That's how every empire starts, darling." → +2h idle boost
Day 3: "Three days in — rivals are already nervous. I can tell." → +500 in-game currency
Day 7: "A week of consistency. The fashion world is watching." → Rare fabric swatch (cosmetic)
Day 14: "Fourteen days. You're not a fluke — you're a force." → Luxe outfit accessory unlock
Day 30: "A month. A full cycle. You've graduated from hopeful to inevitable." → Permanent +5% idle multiplier
Day 60: "Two months. Legends are built in moments like this." → Exclusive Maison banner cosmetic
Day 100: "One hundred days. I've seen empires rise and fall. Yours is rising." → Legacy Badge + 3x idle boost (24h)

8.13 Brand Story Archive

Viewable timeline of all key drops, events, milestones, and achievements.
Nostalgia feature with shareable highlights and replay value.
Highlight Reel: Auto-generated 30-second recap video of top milestones, shareable to external platforms.
Milestone Cards: Stylised image exports for each major achievement (first Alpha, first city domination, IPO day).
Brand Story Link: Public permalink to a read-only archive view, shareable with non-players.
Share to Feed: One-tap post for any archive entry, visible to all players with engagement reactions.

8.14 Push Notifications & Permissions

Clear permission request on first launch with Luxe explanation.
Notification types: daily check-in reminders, live event starts, rival attacks/Eclipse alerts, stock movements, follower milestones, Luxe tips, seasonal/holiday events.
Smart frequency: max 2–3 per day, personalized and never spammy.
Deep-linking to relevant screens.

8.15.1 Firebase Auth & Google Play Services

Anonymous-first sign-in on first launch. All progress tied to the anonymous UID and persists across sessions on the same device. Zero friction at launch.
Progressive account linking — at Rank 5, first Maison join, or first IAP, Luxe prompts linking via Google, Apple, or email. Framed as securing the empire, not a requirement.
Google Play Games (Android): Achievements, leaderboards, cloud save sync, and Play Games identity as optional auth method.
Conflict Resolution: If an anonymous session is linked to an existing account, the player sees a side-by-side save comparison and chooses which to keep.
Firebase App Check enforced on all API calls (Play Integrity on Android, DeviceCheck on iOS). Short-lived JWT tokens with silent refresh.
Cross-device persistence and progress preservation.

8.15.2 Additional Security Solutions

Layer
Solution
Anti-Inflation Detection
Server-side statistics flag revenue or follower counts deviating >3σ from historical trend. Auto-investigation queue triggers.
Device Attestation
Play Integrity API (Android) and Apple DeviceCheck (iOS) verify device integrity before any sensitive transaction.
Clock Spoofing Prevention
All time-sensitive calculations resolved server-side using server timestamps — client clock is ignored entirely.
Behavioral Analysis
Passive session heuristics track tap velocity, patterns, and action sequences to flag bot-like behaviour.
CAPTCHA
Invisible reCAPTCHA v3 on account creation, IAP flows, and bulk actions. Fallback to v2 on low trust scores.
Anti-Automation / Bots
Rate limiting on all game action APIs. Burst detection with progressive cooldowns. Honeypot endpoints.
Anti-DDoS
Cloudflare enterprise-tier DDoS protection with adaptive rate limiting and IP reputation scoring.
Payment Fraud
Stripe Radar + server-side receipt validation for all IAP (Google Play Billing / Apple StoreKit 2). Refund abuse tracking.
Session Hijacking
Device fingerprint + JWT binding. Concurrent session detection with forced re-auth on suspicious parallel logins.
Data Exfiltration
Supabase RLS ensures players can only read/write their own data. No cross-player data exposure in any API response.


8.16 Support & Feedback System

Profile → Support tab.
Ticket form with issue category dropdown, subject, description, severity level, and screenshot attachment (up to 3). Auto-populates device info. Confirmation with estimated response time delivered via Luxe.
Ticket history with status badges: Open · In Progress · Resolved · Closed. Thread view per ticket. Reopen option available for 14 days after resolution.
Submissions stored in Supabase with immediate email notification to developer.
In-app pulse surveys: 3–5 questions triggered contextually post-event, post-milestone, or post-hostile-takeover. Anonymous option. Max once per 7-day window.
Milestone-triggered feedback prompts at Rank 10, 25, 50, first Maison, first co-drop, and first IPO. Luxe delivers: "Quick question before you conquer Milan — what's the one thing that could make this better?"
Optional general feedback form always accessible.

8.17 Real Fashion Industry Trends

Procedurally injected into Trend Forecasting Tool, seasonal events, Luxe tips, and AI suggestions.
2026 trends include: AI + Digital Fashion, Circular & Regenerative Fashion, Quiet Luxury vs Dopamine Dressing, Gender-Fluid & Inclusive Sizing, Supply Chain Transparency, Resale & Vintage Revival, Celebrity Micro-Trends.

8.18 Security & Anti-Cheat

Server-authoritative idle calculations.
Anomaly detection on sudden spikes.
Device attestation (Play Integrity / App Attest).
Server-side time validation (NTP).
Behavioral analysis + CAPTCHA.
Rate limiting and request signing.
Code obfuscation + runtime integrity checks.
Cloudflare WAF + DDoS mitigation.
Payment fraud prevention and session hijacking protection.

8.19 Legal & Compliance Documents

Community Guidelines / Code of Conduct
Cookie Policy
DMCA / Copyright & IP Infringement Policy
Refund Policy
Data Processing Agreement (DPA) / GDPR Addendum
Children's Privacy Policy (COPPA)
Accessibility Statement
Marketing & Advertising Policy

9. Balance & Monetization

Progression Philosophy: Strategic depth with meaningful choices. Brand Rank pacing per 3.2.
Income Split: Idle/active 40/60 early → 55/45 late. Soft caps + 24h decay encourage daily play without burnout.
Path Parity: Designer hype scales match Mogul profit via symmetric cross-synergy.
Risk/Reward: Rivals, events, stock volatility, regulations, loans, equity, talent morale, celebrity risks, follower dynamics, seasonal/holiday events scale dynamically with Brand Rank.
Economy Sinks/Sources: Maintenance, tariffs, overstock, interest, salaries vs sales/dividends/idle scaling.
Replayability: Dual distinct loops with full cross-path synergy. One-time premium path switch. Legacy mode at Rank 100 resets progress with permanent bonuses for new runs. Procedural trends/events ensure variety across playthroughs.
Social/Multiplayer: Leaderboards and partnerships reward skill/cooperation, no paywalls.

9.1 Monetization Strategy

Luxe Credits (IAP): Buyable premium currency for speed-ups, cosmetic packs, and convenience bundles — including extra idle time and instant restock.
Monthly Season Pass: Recurring premium pass with exclusive fabrics, permanent boosts, Luxe skins, early event access, and bonus daily rewards.
Rewarded Ads: Optional voluntary ads for small boosts (extra idle hours, resources, cosmetics). Never mandatory, never intrusive.
Cosmetic Shop: Permanent one-time purchases for avatar/Luxe outfits, UI themes, particle effects, and animated flair.
Limited-Time Event Bundles: Holiday/seasonal packs with themed cosmetics and minor convenience items.
All core progression, follower growth, market power, and competitive elements remain 100% F2P. No pay-to-win mechanics.

9.2 Monetization Implementation (Technical)

Use official in_app_purchase Flutter package for cross-platform support.
Google Play Billing (Android): Integrated via Google Play Services.
Apple StoreKit (iOS): Native integration.
Anonymous users can purchase; account linking preserves progress.
All purchases are server-verified via Supabase Cloud Functions.
Revenue tracking for analytics and fraud prevention.

10. Legal & Company Information

Developer: SkinTeethNerd (SkinTeethNerd Studios)
App Name: The Styliste
App Description: "Portrait-first fashion empire simulator. Design, dominate, and rise from underground hype to global icon in the ultimate idle tycoon experience."
Mission & Vision: To empower players to build authentic fashion empires while experiencing the real-world glamour, drama, and business of the industry.
Data Compliance: GDPR / CCPA compliant. Minimal data collection. Full Privacy Policy, Terms & Conditions, and End-User License Agreement.
Message from the Developer: "Hey, I'm SkinTeethNerd. The Styliste is my love letter to fashion and strategy. Build something legendary — I can't wait to see what you create."

10.1 Full Legal & Compliance Documents
The following documents are required before public launch, accessible in-app (Settings → Legal) and on the public website.

Community Guidelines / Code of Conduct: Defines acceptable behaviour on the Global Feed, in Maisons, and in DMs. Prohibits harassment, hate speech, impersonation, and spam. Violation ladder: warning → mute → Maison removal → account suspension.
Cookie Policy: Discloses all cookies and tracking technologies. Compliant with EU ePrivacy Directive and GDPR. Opt-out mechanism in app settings and cookie banner on web.
DMCA / Copyright & IP Infringement Policy: Outlines procedures for reporting copyright infringement in player content. Provides DMCA takedown request form, designated agent contact, and counter-notification process. Repeat infringer policy defined.
Refund Policy: Defines conditions for IAP refunds (technical failures, unauthorised purchases by minors). Directs players to platform-native refund flows. Internal refund request process with 5 business day SLA.
Data Processing Agreement (DPA) / GDPR Addendum: Covers sub-processors (Firebase, Supabase, Stripe, Cloudflare), data retention schedules, 72-hour breach notification, and data subject rights fulfilment (access, deletion, portability).
Children's Privacy Policy (COPPA): The Styliste is rated 12+. Does not knowingly collect personal data from children under 13. Documents age-gate mechanism, parental consent flow, and data deletion procedures. COPPA and UK AADC compliant.
Accessibility Statement: Commits to WCAG 2.1 AA targets. Documents features: dynamic text size, high-contrast mode, reduced motion toggle, screen-reader labels on all interactive elements. Lists known gaps and remediation roadmap.
Marketing & Advertising Policy: Governs all external marketing communications. Confirms The Styliste displays no third-party advertisements in the game client. Documents influencer/affiliate disclosure requirements. CAN-SPAM and GDPR marketing consent compliant.

11. Key Design Pillars

Real-world grounded economy/terminology with seasonal trends, sustainability scores, celebrity risks, regional preferences, material volatility, store ops, equity markets, regulations, talent, endorsements, follower dynamics, and seasonal/holiday events.
Player-driven social economy via feed, collabs, flexing, and stock trading.
Dual-path replayability with full cross-path synergy.
Idle progression + active creative/business decisions.

This GDD contains the complete vision. Any LLM can now generate consistent assets, features, or code from this document.