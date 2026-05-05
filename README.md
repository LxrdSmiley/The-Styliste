# The Styliste

**Portrait-first mobile hybrid idle + tycoon fashion empire simulator.**

Build a real-world fashion brand from the ground up. Choose your path — **Designer** (creative genius) or **Mogul** (ruthless entrepreneur) — and rise to global dominance.

---

## ✨ What is The Styliste?

The Styliste is a premium, high-production-value mobile game where players create and scale a fashion empire. It blends deep creative design tools, complex business simulation, live social multiplayer, and realistic fashion industry mechanics.

Core fantasy: *"I could do that better than Off-White, Supreme, or Gucci."*

## 🎯 Key Features

- **Dual Paths** — Designer (Atelier + physics) or Mogul (Ledger + markets) with full cross-path synergy
- **Live Social Economy** — Global feed, partnerships, Maisons (guilds), followers, rival drama, and player reporting
- **Deep Simulation** — Seasonal trends, celebrity endorsements, equity/IPO system, supply chain, talent management, regulations
- **Premium Craftsmanship** — Real-time cloth physics (GLSL Verlet), AR try-on, 3D world map, mini-games, and cinematic onboarding
- **Retention & Virality** — Luxe mentor, daily streaks, seasonal/holiday events, stock ticker, and viral flex mechanics
- **Fair Monetization** — Non-P2W IAP via Google Play Billing & Apple StoreKit (cosmetics, Season Pass, convenience)

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart) + Riverpod + go_router
- **Backend**: Supabase (PostgreSQL + Edge Functions) + Firebase Auth + App Check
- **Monetization**: `in_app_purchase` package (Google Play Billing + Apple StoreKit)
- **Graphics**: Custom GLSL shaders, 3D model viewer
- **Other**: Hive, audioplayers, camera, Google Play Games Services, AdMob

## 🚀 Getting Started

```bash
# Clone the repo
git clone https://github.com/your-org/the-styliste.git
cd the-styliste

# Install dependencies
flutter pub get

# Run the app
flutter run
```

> **Note**: The project is currently in **Phase 0** (fixing 174 broken imports and creating core domain models). Full runnable build expected by end of Phase 1.

## 📁 Project Structure

```
lib/
├── core/                 # Theme, router, services, providers
├── features/             # 27 feature modules (atelier, ledger, feed, equity, etc.)
├── presentation/         # Widgets, screens, overlays
├── shaders/              # GLSL (liquid_chrome, vantablack, shatter)
└── main.dart
```

## 📍 Current Status (2026-05-05)

- ✅ Core architecture wired (Firebase, Supabase, Riverpod, App Check, AdMob)
- 🟡 27 feature directories scaffolded
- 🔴 174 broken imports (Phase 0 in progress)
- 🔴 Major systems (Atelier physics, 3D Map, Equity, Mini-games) not yet implemented

Full status: See `PROJECT_STATUS.md`

## 🗺️ Roadmap

**Phase 0** — Fix broken imports + core models (current)  
**Phase 1** — Runnable on-device build + Onboarding + HQ Dashboard  
**Phase 2** — Designer Path (Atelier + Physics + AR)  
**Phase 3** — Mogul Path (Ledger + Equity + Trading)  
**Phase 4** — Social & Live systems + Polish

## 📜 Official Documents

- [Game Design Document (GDD v3)](THE_STYLISTE_GDD_v3.md) — Single source of truth
- [Project Rules](PROJECT_RULES.md)
- [Verification Protocol](VERIFICATION_PROTOCOL.md)

## 🤝 Contributing

This is currently a solo/architect-led project. Once Phase 1 is stable, contribution guidelines will be added.

## 📄 License

Proprietary — All rights reserved. SkinTeethNerd Studios © 2026

---

**Built with obsession for detail and love for fashion.**

*“Every stitch matters.”*
```

---
