<p align="center">
  <img src="scrapcrafters/assets/logo/logo.jpeg" alt="ScrapCrafters Logo" width="120" height="120" style="border-radius: 20px;" />
</p>

<h1 align="center">♻️ ScrapCrafters</h1>

<p align="center">
  <strong>AI-Powered Circular Economy Platform</strong><br>
  Turn Scrap Into Value — Connecting Users, Dealers, Artists & Industries
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.11-blue?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/FastAPI-Python-green?logo=fastapi" alt="FastAPI" />
  <img src="https://img.shields.io/badge/Supabase-PostgreSQL-darkgreen?logo=supabase" alt="Supabase" />
  <img src="https://img.shields.io/badge/React-18-blue?logo=react" alt="React" />
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License" />
</p>

---

## 📋 Table of Contents

- [About](#-about)
- [Key Features](#-key-features)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Database Schema](#-database-schema)
- [API Endpoints](#-api-endpoints)
- [Getting Started](#-getting-started)
- [Environment Variables](#-environment-variables)
- [UN SDG Alignment](#-un-sdg-alignment)
- [Team](#-team)

---

## 🌍 About

**ScrapCrafters** is an AI-powered circular economy platform that transforms waste management into a value-driven ecosystem. It connects four key stakeholders — **Users**, **Scrap Dealers**, **Artists**, and **Industries** — through an intelligent marketplace powered by geo-spatial matching, a Scrap Coin economy, and real-time supply chain tracking.

Users donate scrap → Dealers & Artists pick it up → Artists upcycle into products → Industries source raw materials → **Everyone earns Scrap Coins**.

### 🎯 Problem Statement

India generates **62 million tonnes** of waste annually, with only **20%** being formally processed. Informal scrap collectors lack access to fair markets, artists lack raw material sourcing, and industries face unreliable supply chains. ScrapCrafters bridges these gaps with technology.

---

## ✨ Key Features

### For Users 🧍
- **Donate Scrap** with photo upload, weight, and GPS-based pickup location (Google Maps)
- **Earn Scrap Coins** for every donation (rate varies by scrap type)
- **Track Donations** in real-time (pending → accepted → completed)
- **Buy Upcycled Products** from the Artist Marketplace using Scrap Coins

### For Scrap Dealers 🤝
- **Accept Nearby Pickups** with AI-powered geo-spatial matching
- **Manage Inventory** by scrap type (iron, plastic, copper, glass, e-waste)
- **Fulfill Industry Requirements** for bulk scrap demand
- **Complete Pickups** and earn Scrap Coins per kg collected

### For Artists 🎨
- **Pick Up Scrap** for upcycling into creative products
- **List Products** on the Marketplace with photos and pricing
- **Stock Management** with real-time quantity tracking
- **Earn from Sales** in Scrap Coins or direct payments

### For Industries 🏭
- **Post Scrap Requirements** with type, quantity, and price per kg
- **Track Fulfillment** progress with real-time progress bars
- **Purchase Scrap Coins** via Razorpay for bulk procurement
- **Get Matched** with dealers who have the right inventory

### Platform-Wide 🌐
- **Scrap Coin Economy** — 1 Coin = ₹0.10 (₹1 = 10 Coins)
- **Wallet System** with deposit, earn, spend, and purchase history
- **Geo-Spatial Matching** for nearby pickup requests
- **Neo-Brutalism UI** — modern, bold, premium design with Space Grotesk font
- **Responsive Design** — works on Android, Web, and Desktop

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Client Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Flutter App   │  │ React Web    │  │ Flutter Web  │  │
│  │ (Android)     │  │ (Marketing)  │  │ (Dashboard)  │  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  │
└─────────┼─────────────────┼─────────────────┼───────────┘
          │                 │                 │
          ▼                 ▼                 ▼
┌─────────────────────────────────────────────────────────┐
│              FastAPI Backend (Python)                    │
│  /auth  /scrap  /industry  /products  /coins  /contracts│
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│                  Supabase (PostgreSQL)                   │
│  profiles • scrap_requests • dealer_inventory           │
│  industry_requirements • products • transactions        │
│  artist_contracts • requirement_fulfillments            │
│  + Auth • Storage • RLS Policies                        │
└─────────────────────────────────────────────────────────┘
```

---

## 🛠 Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Mobile App** | Flutter 3.11+ (Dart) | Cross-platform Android + Web app |
| **UI Design** | Neo-Brutalism + Space Grotesk | Bold borders, hard shadows, flat colors |
| **Maps** | Google Maps Flutter | GPS-based pickup location selection |
| **Backend API** | FastAPI (Python) | RESTful API with automatic OpenAPI docs |
| **Database** | Supabase (PostgreSQL) | Auth, DB, Storage, RLS policies |
| **Payments** | Razorpay | Scrap Coin purchase (INR → Coins) |
| **Marketing Web** | React 18 + TailwindCSS | Landing page and public website |
| **State Mgmt** | Provider (Flutter) | Reactive state management |
| **Animations** | flutter_animate + SpinKit | Micro-animations and loading states |

---

## 📁 Project Structure

```
PAN_INDIA_1.0/
├── backend/                    # FastAPI Backend
│   ├── main.py                 # App entry point
│   ├── config.py               # Supabase client config
│   ├── models.py               # Pydantic request/response models
│   ├── schema.sql              # Database schema (run in Supabase)
│   ├── requirements.txt        # Python dependencies
│   └── routers/
│       ├── auth.py             # Email/password authentication
│       ├── scrap.py            # Scrap donation & pickup flow
│       ├── industry.py         # Industry requirements & fulfillment
│       ├── products.py         # Artist product CRUD & purchasing
│       ├── coins.py            # Scrap Coin wallet & transactions
│       └── contracts.py        # Artist-User contract management
│
├── scrapcrafters/              # Flutter Mobile + Web App
│   ├── lib/
│   │   ├── main.dart           # App entry with dotenv + Supabase init
│   │   ├── config/
│   │   │   └── supabase_config.dart  # Reads from .env
│   │   ├── theme/
│   │   │   └── app_theme.dart  # Neo-brutalism design system
│   │   ├── widgets/
│   │   │   ├── glass_card.dart # Reusable bordered card widget
│   │   │   ├── shimmer_loading.dart  # Skeleton loading
│   │   │   └── loading_overlay.dart  # Full-screen loader
│   │   ├── providers/          # State management (Provider)
│   │   │   ├── auth_provider.dart
│   │   │   ├── scrap_provider.dart
│   │   │   ├── product_provider.dart
│   │   │   ├── industry_provider.dart
│   │   │   └── coin_provider.dart
│   │   └── screens/
│   │       ├── landing/landing_page.dart    # Pre-login landing
│   │       ├── auth/login_screen.dart       # Email login
│   │       ├── auth/signup_screen.dart      # Role-based signup
│   │       ├── user/user_dashboard.dart     # User home + stats
│   │       ├── user/donate_scrap_screen.dart # Google Maps donation
│   │       ├── user/wallet_screen.dart      # Coin wallet
│   │       ├── partner/dealer_dashboard.dart # Dealer: inventory + pickups
│   │       ├── partner/artist_dashboard.dart # Artist: products + pickups
│   │       ├── industry/industry_dashboard.dart # Industry: requirements
│   │       ├── marketplace/marketplace_screen.dart # Product grid
│   │       └── common/profile_screen.dart   # User profile editor
│   ├── assets/logo/logo.jpeg   # App launcher icon
│   ├── .env                    # Environment variables
│   └── pubspec.yaml            # Flutter dependencies
│
├── frontend/                   # React Marketing Website
│   ├── src/
│   │   ├── pages/              # 12 React page components
│   │   ├── components/         # Reusable UI components
│   │   ├── services/           # Supabase client
│   │   └── hooks/              # Custom React hooks
│   └── package.json
│
├── ml/                         # ML Models (scrap classification)
├── .env                        # Root environment variables
├── .env.example                # Template for env vars
└── README.md                   # ← You are here
```

---

## 🗄 Database Schema

### Tables Overview

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `profiles` | All users (4 roles) | name, email, role, scrap_coins, location |
| `scrap_requests` | Scrap donations | user_id, partner_id, scrap_type, weight_kg, status, lat/lng |
| `dealer_inventory` | Dealer stock tracking | dealer_id, scrap_type, quantity_kg |
| `industry_requirements` | Bulk scrap demand | industry_id, scrap_type, required_kg, fulfilled_kg, price_per_kg |
| `requirement_fulfillments` | Dealer → Industry supply | requirement_id, dealer_id, quantity_kg |
| `products` | Artist marketplace | artist_id, name, price_coins, image_url, stock_quantity |
| `artist_contracts` | User → Artist orders | user_id, artist_id, description, status |
| `transactions` | Coin wallet ledger | user_id, type, amount, description |

### User Roles

| Role | Capabilities |
|------|-------------|
| `user` | Donate scrap, earn coins, buy products, view wallet |
| `dealer` | Accept pickups, manage inventory, fulfill industry requirements |
| `artist` | Accept pickups, create products, sell on marketplace |
| `industry` | Post scrap requirements, buy coins, track fulfillment |

---

## 🔌 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| **Auth** | | |
| POST | `/auth/signup` | Register with email, password, role |
| POST | `/auth/login` | Sign in with email/password |
| GET | `/auth/profile/{user_id}` | Get user profile |
| **Scrap** | | |
| POST | `/scrap/donate` | Create scrap donation request |
| GET | `/scrap/requests/available` | Get nearby pending pickups |
| PUT | `/scrap/requests/{id}/accept` | Partner accepts a pickup |
| PUT | `/scrap/requests/{id}/complete` | Mark pickup completed |
| **Industry** | | |
| POST | `/industry/requirements` | Post scrap requirement |
| GET | `/industry/requirements` | List requirements |
| POST | `/industry/requirements/{id}/fulfill` | Dealer fulfills requirement |
| **Products** | | |
| POST | `/products` | Create product listing |
| GET | `/products` | List all available products |
| POST | `/products/{id}/purchase` | Buy product with coins |
| **Coins** | | |
| GET | `/coins/balance/{user_id}` | Get coin balance |
| POST | `/coins/purchase` | Buy coins via Razorpay |
| GET | `/coins/transactions/{user_id}` | Transaction history |

📖 Full API docs available at `http://localhost:8080/docs` (Swagger UI)

---

## 🚀 Getting Started

### Prerequisites

- **Python** 3.10+
- **Flutter** 3.11+
- **Node.js** 18+ (for marketing website)
- **Supabase** account (free tier works)
- **Google Maps API Key** (for Android map)

### 1. Clone the Repository

```bash
git clone https://github.com/DhanshreeGaur07/PIH2026_TeamVisionCoders.git
cd PIH2026_TeamVisionCoders
```

### 2. Setup Environment Variables

```bash
cp .env.example .env
# Edit .env with your Supabase and API keys
```

### 3. Setup Database

1. Go to your [Supabase Dashboard](https://supabase.com/dashboard) → SQL Editor
2. Run `backend/schema.sql` to create all tables
3. Run `backend/db_geo_update.sql` for geo-spatial functions

### 4. Start Backend

```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8080 --reload
```

API will be live at `http://localhost:8080` with docs at `/docs`.

### 5. Setup Flutter App

```bash
cd scrapcrafters

# Create .env file with your keys
cat > .env << EOF
GOOGLE_MAP_KEY=your_google_maps_api_key
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
API_BASE_URL=http://10.0.2.2:8080
WEB_API_BASE_URL=http://localhost:8080
EOF

# Install dependencies
flutter pub get

# Run on Android
flutter run

# Run on Web
flutter run -d chrome
```

### 6. Setup Marketing Website (Optional)

```bash
cd frontend
npm install
npm start
```

---

## 🔐 Environment Variables

### Root `.env`

| Variable | Description |
|----------|-------------|
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_ANON_KEY` | Supabase anonymous key |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service role key (backend) |
| `SUPABASE_JWT_SECRET` | JWT secret for auth |

### Flutter `.env` (`scrapcrafters/.env`)

| Variable | Description |
|----------|-------------|
| `GOOGLE_MAP_KEY` | Google Maps API key for Android |
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_ANON_KEY` | Supabase anonymous key |
| `API_BASE_URL` | Backend API URL (Android: `http://10.0.2.2:8080`) |
| `WEB_API_BASE_URL` | Backend API URL (Web: `http://localhost:8080`) |

---

## 🌱 UN SDG Alignment

ScrapCrafters directly contributes to **5 UN Sustainable Development Goals**:

| SDG | Goal | How We Contribute |
|-----|------|-------------------|
| **8** | Decent Work & Economic Growth | Creating livelihoods for scrap dealers, artists, and local communities |
| **9** | Industry, Innovation & Infrastructure | AI-powered smart matching and circular supply chain infrastructure |
| **11** | Sustainable Cities & Communities | Reducing urban waste through community-driven scrap management |
| **12** | Responsible Consumption & Production | Promoting upcycling, reuse, and responsible material lifecycle |
| **13** | Climate Action | Reducing landfill waste and lowering carbon footprint through recycling |

---

## 🎨 Design Philosophy

ScrapCrafters uses a **Neo-Brutalism** design language:

- **Light backgrounds** (`#FAFAF9`) for clean readability
- **Bold 2px borders** with hard offset shadows (3px, 3px)
- **Space Grotesk** font for premium typography
- **Flat, muted color palette** — no gradients, no glass effects
- **Micro-animations** via `flutter_animate` for polished UX

---

## 💰 Scrap Coin Economy

| Scrap Type | Coins per kg | Description |
|-----------|-------------|-------------|
| Iron/Metal | 30 | Ferrous and non-ferrous metals |
| Plastic | 20 | All types of recyclable plastic |
| Copper | 40 | High-value copper scrap |
| Glass | 20 | Recyclable glass containers |
| E-Waste | 50 | Electronic waste (highest value) |
| Other | 10 | Miscellaneous recyclables |

**Coin Purchase:** ₹1 = 10 Scrap Coins (via Razorpay payment gateway)

---

## 👥 Team

**Team Vision Coders** — PAN INDIA Hackathon 2026

---

<p align="center">
  Made with ♻️ by Team Vision Coders<br>
  <em>Built for PAN INDIA Hackathon 2026</em>
</p>
