# 🌿 SCRAP-CRAFTERS — Frontend

### India's First Circular Economy Marketplace
> **Turn Waste into Wonders** — connecting rag-pickers, artists, organisations, and conscious consumers through a living circular economy.

[![React](https://img.shields.io/badge/React-18.2-61DAFB?logo=react)](https://reactjs.org/)
[![Tailwind CSS](https://img.shields.io/badge/TailwindCSS-3.x-38BDF8?logo=tailwindcss)](https://tailwindcss.com/)
[![Supabase](https://img.shields.io/badge/Supabase-Connected-3ECF8E?logo=supabase)](https://supabase.com/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Environment Variables](#environment-variables)
4. [Project Structure](#project-structure)
5. [Pages & Routing](#pages--routing)
6. [Design System](#design-system)
7. [Components](#components)
8. [SDG Alignment](#sdg-alignment)
9. [Dependencies](#dependencies)
10. [Scripts](#scripts)

---

## 🌍 Overview

SCRAP-CRAFTERS is a full-stack circular-economy platform built for **PIH 2026 – Team VisionCoders**. The frontend is a React SPA (Single-Page Application) that provides distinct role-based dashboards for:

| Role | Description |
|------|-------------|
| 🧑 **User** | Sell / donate waste items, browse and buy artworks |
| 🎨 **Artist** | Showcase & sell upcycled art, track requests and materials |
| 🚚 **Helper** | Manage pickup / delivery tasks, track waste transported |
| 🏢 **Organisation** | Monitor waste utilisation, request status, and platform stats |

---

## 🚀 Quick Start

```bash
# 1. Navigate to the frontend folder
cd frontend

# 2. Install dependencies
npm install

# 3. Copy environment variables
cp .env.example .env
# Fill in your Supabase credentials in .env

# 4. Start the development server
npm start

# 5. Open in browser
# http://localhost:3000
```

---

## 🔐 Environment Variables

Create a `.env` file in the `frontend/` directory based on `.env.example`:

```env
REACT_APP_SUPABASE_URL=https://your-project-ref.supabase.co
REACT_APP_SUPABASE_ANON_KEY=your-anon-key-here
```

> ⚠️ Never expose `SUPABASE_SERVICE_ROLE_KEY` or `SUPABASE_JWT_SECRET` in the frontend. Only variables prefixed with `REACT_APP_` are exposed to the browser.

---

## 📁 Project Structure

```
frontend/
├── public/
│   └── index.html                        # HTML shell — loads Google Fonts, sets meta tags
│
├── src/
│   ├── index.jsx                         # App entry point — ReactDOM.createRoot
│   ├── App.jsx                           # Root router (useState-based page switching)
│   │
│   ├── assets/
│   │   ├── turn_waste_into_wonder.mp4    # Hero background video
│   │   ├── artwork_metal_kinetic.png     # Static artwork image
│   │   ├── artwork_circuit_mandala.png   # Static artwork image
│   │   ├── artwork_wood_frame.png        # Static artwork image
│   │   ├── artwork_copper_chimes.png     # Static artwork image
│   │   ├── artwork_pet_lamp.png          # Static artwork image
│   │   └── artwork_newspaper_sculpture.png
│   │
│   ├── styles/
│   │   └── index.css                     # Global CSS, CSS custom properties, Tailwind layers
│   │
│   ├── data/
│   │   └── mockData.jsx                  # Static mock data (artworks, scrap items, tasks…)
│   │
│   ├── config/
│   │   ├── supabase.jsx                  # Supabase client initialisation (with helpers)
│   │   └── supabaseClient.js             # Raw createClient export
│   │
│   ├── hooks/
│   │   ├── useAuth.jsx                   # Auth state: login, logout, register, refreshUser
│   │   ├── useFetch.jsx                  # Generic async data-fetching hook
│   │   └── useLocalStorage.jsx           # localStorage-backed state hook
│   │
│   ├── services/
│   │   ├── api.jsx                       # Mock API layer (authAPI, itemsAPI, tasksAPI, usersAPI)
│   │   └── supabaseApi.jsx               # Supabase-specific API calls
│   │
│   ├── utils/
│   │   └── helpers.jsx                   # Utility functions (formatINR, statusClasses…)
│   │
│   ├── components/
│   │   ├── common/
│   │   │   ├── StatCard.jsx              # KPI card: icon + value + sub-label
│   │   │   ├── Badge.jsx                 # Status / category pill badge
│   │   │   ├── ScrapItemCard.jsx         # Marketplace product card
│   │   │   ├── UploadForm.jsx            # Sell / Donate item form with image preview
│   │   │   ├── TaskCard.jsx              # Helper task card with progress actions
│   │   │   ├── ErrorBanner.jsx           # Error display with retry button
│   │   │   └── LoadingSpinner.jsx        # Animated loading indicator
│   │   │
│   │   └── layout/
│   │       ├── Navbar.jsx                # Sticky top navigation bar
│   │       ├── Sidebar.jsx               # Left sidebar navigation
│   │       └── DashboardLayout.jsx       # Full-page dashboard layout wrapper
│   │
│   └── pages/
│       ├── LandingPage.jsx               # Public landing page (hero, how-it-works, SDGs, impact)
│       ├── AuthPage.jsx                  # Login & registration (role selection)
│       ├── ArtworksPage.jsx              # Public artwork gallery with static images
│       ├── ArtworkDetailPage.jsx         # Artwork detail + add-to-cart / buy-now
│       ├── CartPage.jsx                  # Shopping cart
│       ├── OrderSummaryPage.jsx          # Order confirmation
│       ├── ArtistDashboard.jsx           # Artist: my artworks, requests, waste materials
│       ├── UserDashboard.jsx             # User: sell/donate waste, buy/request crafts
│       ├── HelperDashboard.jsx           # Helper: pickup/delivery points, transported waste
│       ├── OrganisationDashboard.jsx     # Org: waste utilisation stats, request status
│       ├── SoldDonatedPage.jsx           # History of sold / donated items
│       └── CollabsPage.jsx               # Platform collaborations
│
├── tailwind.config.js                    # Custom design tokens (forest, craft, soil palette)
├── postcss.config.js
├── package.json
└── .env.example                          # Environment variable template
```

---

## 🗺️ Pages & Routing

Navigation is managed entirely via a `useState` in `App.jsx` — no React Router needed at this scale. The `navigate(pageKey, params?)` function is passed down through props.

```
landing
  └─▶ auth ──────────────▶ artworks
                │               └─▶ artwork-detail
                │                       └─▶ cart ──▶ order-summary
                ├──▶ artist        (requires auth)
                ├──▶ user          (requires auth)
                ├──▶ helper        (requires auth)
                ├──▶ organisation  (requires auth)
                ├──▶ sold-donated  (requires auth)
                └──▶ collaborations
```

| Page Key | Component | Auth Required |
|---|---|---|
| `landing` | `LandingPage` | ❌ |
| `auth` | `AuthPage` | ❌ |
| `artworks` | `ArtworksPage` | ❌ |
| `artwork-detail` | `ArtworkDetailPage` | ❌ |
| `cart` | `CartPage` | ❌ |
| `order-summary` | `OrderSummaryPage` | ✅ |
| `artist` | `ArtistDashboard` | ✅ |
| `user` | `UserDashboard` | ✅ |
| `helper` | `HelperDashboard` | ✅ |
| `organisation` | `OrganisationDashboard` | ✅ |
| `sold-donated` | `SoldDonatedPage` | ✅ |
| `collaborations` | `CollabsPage` | ❌ |

---

## 🎨 Design System

### Color Tokens (`tailwind.config.js`)

| Token | Primary Shade | Hex | Usage |
|---|---|---|---|
| `forest` | 600 | `#178040` | Primary green, CTAs, success, eco accent |
| `craft` | 600 | `#c8831f` | Artist/sell actions, amber warmth |
| `soil` | 600 | `#a88450` | Muted text, borders, backgrounds |
| `teal` | 600 | — | Helper role, secondary actions |

### Typography (Google Fonts)

| Font | Weight | Usage |
|---|---|---|
| **Playfair Display** | 600 / 700 / 900 | Headlines, brand name, display numbers |
| **Plus Jakarta Sans** | 300–700 | All body text and UI labels |
| **JetBrains Mono** | 400 / 600 | Stats, counters, code snippets |

### Reusable CSS Classes (in `index.css`)

| Class | Description |
|---|---|
| `.btn-primary` | Forest-green filled button |
| `.btn-outline` | Outline button with hover fill |
| `.btn-craft` | Amber artist action button |
| `.card` | White rounded card with subtle shadow |
| `.pill` | Small category / status badge pill |
| `.pill-green` | Green tinted pill |
| `.hero-blob` | Blurred radial background blob |

---

## 🧩 Components

### Common

| Component | Description |
|---|---|
| `StatCard` | KPI display: icon, large value, sub-label, optional trend |
| `Badge` | Status/category pill with dynamic colour mapping |
| `ScrapItemCard` | Marketplace card: image/emoji, price, category, seller |
| `UploadForm` | Multi-field form for listing scrap items with image preview |
| `TaskCard` | Helper task with Pending→Collected→Delivered action buttons |
| `ErrorBanner` | Full-width error display with retry callback |
| `LoadingSpinner` | Animated spinner with optional message |

### Layout

| Component | Description |
|---|---|
| `Navbar` | Sticky top bar: logo, nav links, user avatar, green-coin counter |
| `Sidebar` | Left navigation panel for dashboards |
| `DashboardLayout` | Wraps Navbar + Sidebar + main content area |

---

## 🌐 SDG Alignment

SCRAP-CRAFTERS actively contributes to the following United Nations Sustainable Development Goals, displayed on the landing page:

| SDG | Title |
|---|---|
| **SDG 12** | Responsible Consumption and Production *(core philosophy)* |
| **SDG 11** | Sustainable Cities and Communities |
| **SDG 8** | Decent Work and Economic Growth |
| **SDG 9** | Industry, Innovation and Infrastructure |
| **SDG 13** | Climate Action |
| **SDG 10** | Reduced Inequalities |
| **SDG 15** | Life on Land |

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `react` | ^18.2.0 | UI framework |
| `react-dom` | ^18.2.0 | DOM renderer |
| `react-scripts` | 5.0.1 | CRA build toolchain |
| `lucide-react` | ^0.263.1 | Icon library |
| `@supabase/supabase-js` | ^2.x | Backend-as-a-Service client |
| `tailwindcss` | ^3.x | Utility-first CSS framework |

---

## 🛠️ Scripts

```bash
npm start       # Start dev server at http://localhost:3000
npm run build   # Create an optimised production build in /build
```

---

## 👩‍💻 Team VisionCoders — PIH 2026

Built with 💚 for a greener, more equitable India.
