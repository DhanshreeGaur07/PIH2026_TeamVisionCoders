# 🌿 SCRAP-CRAFTERS
### India's First Circular Economy Marketplace
> Turn Waste into Worth — connecting rag-pickers, artists, and conscious consumers.

---

## 🚀 Quick Start

```bash
# 1. Install dependencies
npm install

# 2. Start development server
npm start

# 3. Open http://localhost:3000
```

---

## 📁 File Structure

```
scrap-crafters/
├── public/
│   └── index.html                  # HTML template
│
├── src/
│   ├── index.js                    # ← App entry point (React.createRoot)
│   ├── App.js                      # Root component + page router
│   │
│   ├── styles/
│   │   └── index.css               # Global CSS, CSS variables, Tailwind directives
│   │
│   ├── data/
│   │   └── mockData.js             # All placeholder/mock data
│   │
│   ├── hooks/
│   │   └── useLocalStorage.js      # Custom hook: localStorage-backed state
│   │
│   ├── utils/
│   │   └── helpers.js              # Utility functions (formatINR, statusClasses, etc.)
│   │
│   ├── components/
│   │   ├── common/
│   │   │   ├── StatCard.js         # KPI card (icon + value + sub-label)
│   │   │   ├── Badge.js            # Status / category pill badge
│   │   │   ├── ScrapItemCard.js    # Marketplace product card
│   │   │   ├── UploadForm.js       # Sell/Donate item upload form
│   │   │   └── TaskCard.js         # Helper task card with action buttons
│   │   │
│   │   └── layout/
│   │       ├── Navbar.js           # Sticky top navigation bar
│   │       ├── Sidebar.js          # Left sidebar navigation
│   │       └── DashboardLayout.js  # Full-page layout wrapper
│   │
│   └── pages/
│       ├── LandingPage.js          # Page 1: Marketing / Intro
│       ├── AuthPage.js             # Page 2: Login & Sign-Up
│       ├── ArtistDashboard.js      # Page 3: Artist Dashboard
│       ├── UserDashboard.js        # Page 4: User Dashboard
│       └── HelperDashboard.js      # Page 5: Helper / Rag-Picker Dashboard
│
├── tailwind.config.js              # Tailwind + custom tokens (forest, craft, soil)
├── postcss.config.js
└── package.json
```

---

## 🎨 Design System

### Color Palette
| Token      | Hex       | Usage                              |
|------------|-----------|------------------------------------|
| `forest`   | `#178040` | Primary eco-green, CTAs, success   |
| `craft`    | `#c8831f` | Artist/sell actions, amber warmth  |
| `soil`     | `#a88450` | Muted text, borders, backgrounds   |
| `teal`     | teal-600  | Helper role, secondary actions     |

### Typography
- **Display**: Playfair Display — headlines, numbers, brand name
- **Body**: Plus Jakarta Sans — all UI text
- **Mono**: JetBrains Mono — stats, counters

### Page Navigation
Pages are managed via a single `useState` in `App.js`:
```
landing → auth → artist | user | helper
```
No React Router required. The `navigate(page)` function is passed as a prop.

---

## 🌐 Pages Overview

| Page              | Route Key | Role     |
|-------------------|-----------|----------|
| Landing / Hero    | `landing` | Public   |
| Login / Sign-Up   | `auth`    | Public   |
| Artist Dashboard  | `artist`  | Artist   |
| User Dashboard    | `user`    | User     |
| Helper Dashboard  | `helper`  | Helper   |

---

## ♻️ Key Features
- **Mobile-first** responsive layout throughout
- **Light eco-theme** — parchment, forest green, craft amber
- **Role-based UI** — distinct color identity per role
- **Animated hero** — floating icons, scroll hints, step highlight
- **Marketplace grid** — filterable scrap items with buy action
- **Upload form** — image preview, category select, live submit
- **Task progression** — Pending → Collected → Delivered flow
- **Reusable components** — StatCard, Badge, ScrapItemCard, TaskCard, UploadForm

---

## 📦 Dependencies
```json
{
  "react": "^18.2.0",
  "react-dom": "^18.2.0",
  "react-scripts": "5.0.1",
  "lucide-react": "^0.263.1"
}
```
> Install Tailwind CSS separately: https://tailwindcss.com/docs/guides/create-react-app
