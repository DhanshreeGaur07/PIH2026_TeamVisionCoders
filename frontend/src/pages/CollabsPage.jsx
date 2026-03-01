// ============================================================
//  CollabsPage.js — Collaborations with eco-ventures & art orgs
//  Updated to include:
//  Twinkle Art, Carbon and Whale, Abhinav Yadav,
//  Angirus Technologies (Udaipur), BPCL
// ============================================================

import React, { useState } from "react";
import {
  Recycle, Users, Building, Palette, Leaf, ArrowRight,
  Globe, Mail, MapPin, Package, LogOut, Flame, Pen,
  Heart, Zap, Star, ChevronRight, Factory, User, ArrowLeft
} from "lucide-react";

/* ═══════════════════════════════════════════
PARTNER DATA
═══════════════════════════════════════════ */
const PARTNERS = [
  /* ── ART & CULTURE ───────────────────────── */
  {
    id: 1,
    category: "art-culture",
    name: "Twinkle Art Foundation",
    tagline: "Transforming scrap into creativity, confidence, and community",
    description:
      "Twinkle Art Foundation conducts free and low-cost art workshops for children, women, and adults across Pune and surrounding regions. Using donated scrap, textile offcuts, paper waste, and metal fragments, they teach painting, sculpture, and mixed-media art. SCRAP-CRAFTERS users can directly route materials to Twinkle Art during checkout, ensuring usable scrap reaches classrooms instead of landfills.",
    location: "Pune, Maharashtra",
    founded: 2015,
    impactTag: "2,800+ learners",
    stats: [
      { val: "2,800+", label: "Learners Trained" },
      { val: "38", label: "Workshops / Year" },
      { val: "12", label: "Community Centres" },
    ],
    tags: ["Upcycled Art", "Children", "Community", "Education"],
    gradient: "from-pink-500 to-rose-600",
    light: "bg-pink-50",
    border: "border-pink-200",
    accent: "text-pink-700",
    icon: Pen,
    website: "https://twinkleart.example.in",
    contact: "hello@twinkleart.example.in",
    materialWanted: ["paper", "textile", "metal", "glass", "art-scrap"],
    featured: true,
  },

  {
    id: 2,
    category: "art-culture",
    name: "Carbon and Whale",
    tagline: "Climate storytelling through art, data, and public engagement",
    description:
      "Carbon and Whale is a climate-focused creative collective working at the intersection of data, art, and environmental advocacy. They create installations, exhibitions, and public interventions using reclaimed materials to communicate climate urgency. Through SCRAP-CRAFTERS, they source safe scrap materials for installations and workshops across India.",
    location: "India (Distributed)",
    founded: 2019,
    impactTag: "Pan-India reach",
    stats: [
      { val: "25+", label: "Public Installations" },
      { val: "18", label: "Cities Reached" },
      { val: "9T", label: "Scrap Reused" },
    ],
    tags: ["Climate Art", "Public Installations", "Advocacy"],
    gradient: "from-indigo-600 to-sky-700",
    light: "bg-indigo-50",
    border: "border-indigo-200",
    accent: "text-indigo-700",
    icon: Palette,
    website: "https://carbonandwhale.example.in",
    contact: "collab@carbonandwhale.example.in",
    materialWanted: ["plastic", "metal", "fabric", "paper"],
  },

  {
    id: 3,
    category: "art-culture",
    name: "Abhinav Yadav",
    tagline: "Independent artist working with scrap-led narratives",
    description:
      "Abhinav Yadav is an independent artist and designer who works extensively with discarded industrial and consumer materials to explore themes of waste, identity, and urban consumption. Through SCRAP-CRAFTERS, Abhinav sources curated scrap lots for installations, gallery work, and workshops with design students.",
    location: "Delhi NCR",
    founded: 2018,
    impactTag: "Independent Artist",
    stats: [
      { val: "40+", label: "Artworks Created" },
      { val: "15", label: "Exhibitions" },
      { val: "6T", label: "Scrap Reused" },
    ],
    tags: ["Independent Artist", "Installations", "Design"],
    gradient: "from-purple-600 to-violet-700",
    light: "bg-purple-50",
    border: "border-purple-200",
    accent: "text-purple-700",
    icon: User,
    website: "https://abhinavyadav.example.in",
    contact: "studio@abhinavyadav.example.in",
    materialWanted: ["metal", "plastic", "industrial-scrap"],
  },

  /* ── INDUSTRIAL / TECH ───────────────────── */
  {
    id: 4,
    category: "industrial",
    name: "Angirus Technologies",
    tagline: "Advanced recycling solutions for industrial waste streams",
    description:
      "Angirus Technologies, based in Udaipur, develops and operates technology-driven solutions for processing industrial plastic, rubber, and composite waste. Their systems focus on material recovery and energy efficiency. SCRAP-CRAFTERS supplies sorted industrial scrap and post-production waste directly to Angirus processing units.",
    location: "Udaipur, Rajasthan",
    founded: 2020,
    impactTag: "Industrial Recycling",
    stats: [
      { val: "1,100T", label: "Waste Processed" },
      { val: "92%", label: "Recovery Rate" },
      { val: "14", label: "Industrial Clients" },
    ],
    tags: ["Industrial Plastic", "Rubber", "Composites"],
    gradient: "from-slate-600 to-slate-800",
    light: "bg-slate-50",
    border: "border-slate-200",
    accent: "text-slate-700",
    icon: Factory,
    website: "https://angirus.example.in",
    contact: "projects@angirus.example.in",
    materialWanted: ["plastic", "rubber", "composite"],
  },

  {
    id: 5,
    category: "industrial",
    name: "Bharat Petroleum (BPCL)",
    tagline: "Circular economy initiatives in fuel and infrastructure",
    description:
      "BPCL collaborates on pilot projects involving plastic waste co-processing, road-laying with plastic-modified bitumen, and responsible waste sourcing. Through SCRAP-CRAFTERS, verified scrap streams are routed into approved BPCL partner programmes aligned with national sustainability and ESG goals.",
    location: "Pan-India",
    founded: 1952,
    impactTag: "PSU Partner",
    stats: [
      { val: "Pan-India", label: "Operational Reach" },
      { val: "1000T+", label: "Plastic Utilised" },
      { val: "ESG", label: "Aligned Projects" },
    ],
    tags: ["Plastic Roads", "Energy", "Infrastructure", "ESG"],
    gradient: "from-orange-600 to-red-700",
    light: "bg-orange-50",
    border: "border-orange-200",
    accent: "text-orange-700",
    icon: Flame,
    website: "https://www.bharatpetroleum.in",
    contact: "sustainability@bpcl.in",
    materialWanted: ["plastic"],
    featured: true,
  },
];

/* ═══════════════════════════════════════════
   CATEGORIES
═══════════════════════════════════════════ */
const CATEGORIES = [
  { id: "all", label: "All Collaborators", icon: Users },
  { id: "art-culture", label: "Art & Culture", icon: Pen },
  { id: "industrial", label: "Industrial & Tech", icon: Factory },
];

/* ═══════════════════════════════════════════
   PARTNER CARD
═══════════════════════════════════════════ */
const PartnerCard = ({ partner }) => {
  const [expanded, setExpanded] = useState(false);
  const Icon = partner.icon;

  return (
    <div className={`card overflow-hidden border-2 ${partner.border} hover:shadow-2xl transition-all duration-300 flex flex-col`}>
      <div className={`bg-gradient-to-r ${partner.gradient} p-6`}>
        <div className="flex justify-between gap-3">
          <div className="flex gap-3">
            <div className="w-12 h-12 rounded-2xl bg-white/20 flex items-center justify-center">
              <Icon size={22} className="text-white" />
            </div>
            <div>
              <h3 className="font-display font-bold text-white text-lg">{partner.name}</h3>
              <p className="text-white/70 text-xs flex items-center gap-1">
                <MapPin size={10} /> {partner.location}
              </p>
            </div>
          </div>
          <span className="pill bg-white/20 text-white text-[10px]">{partner.impactTag}</span>
        </div>
      </div>

      <div className="p-5 flex flex-col flex-1">
        <p className={`font-semibold text-sm ${partner.accent} mb-2`}>{partner.tagline}</p>
        <p className={`text-xs text-soil-600 mb-3 ${expanded ? "" : "line-clamp-3"}`}>
          {partner.description}
        </p>
        <button onClick={() => setExpanded(v => !v)} className={`text-xs ${partner.accent} mb-4`}>
          {expanded ? "Show less ↑" : "Read more ↓"}
        </button>

        <div className={`grid grid-cols-3 gap-2 p-3 rounded-xl ${partner.light} border ${partner.border} mb-4`}>
          {partner.stats.map(s => (
            <div key={s.label} className="text-center">
              <p className={`font-display font-black text-lg ${partner.accent}`}>{s.val}</p>
              <p className="text-[10px] text-soil-500">{s.label}</p>
            </div>
          ))}
        </div>

        <div className="flex flex-wrap gap-1.5 mb-4">
          {partner.tags.map(tag => (
            <span key={tag} className={`pill text-[10px] ${partner.light} ${partner.accent} border ${partner.border}`}>
              {tag}
            </span>
          ))}
        </div>

        <div className="mt-auto flex gap-3 flex-wrap text-xs">
          <a href={`mailto:${partner.contact}`} className={`${partner.accent} flex items-center gap-1`}>
            <Mail size={11} /> Contact
          </a>
          <a href={partner.website} target="_blank" rel="noreferrer" className="text-soil-400 flex items-center gap-1">
            <Globe size={11} /> Website
          </a>
        </div>
      </div>
    </div>
  );
};

/* ═══════════════════════════════════════════
   MAIN PAGE
═══════════════════════════════════════════ */
const CollabsPage = ({ onNavigate, onNavigateBack, user, onLogout }) => {
  const [activeCat, setActiveCat] = useState("all");
  const filtered = activeCat === "all" ? PARTNERS : PARTNERS.filter(p => p.category === activeCat);

  return (
    <div className="min-h-screen bg-[var(--clr-bg)] px-6 py-10">
      <div className="flex items-center justify-between gap-4 mb-6 flex-wrap">
        <button type="button" onClick={onNavigateBack} className="flex items-center gap-2 text-soil-600 hover:text-forest-600 text-sm font-medium">
          <ArrowLeft size={18} /> Back
        </button>
        {user && onLogout && (
          <button type="button" onClick={onLogout} className="btn-outline text-sm py-2 px-4 flex items-center gap-1.5">
            <LogOut size={14} /> Log out
          </button>
        )}
      </div>
      <h1 className="font-display font-black text-4xl mb-6">Collaborations</h1>

      <div className="flex gap-2 mb-8">
        {CATEGORIES.map(c => (
          <button key={c.id} onClick={() => setActiveCat(c.id)}
            className={`px-4 py-2 rounded-xl text-sm font-semibold border ${activeCat === c.id ? "bg-forest-600 text-white" : "bg-white"
              }`}>
            <c.icon size={14} className="inline mr-1" />
            {c.label}
          </button>
        ))}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
        {filtered.map(p => <PartnerCard key={p.id} partner={p} />)}
      </div>
    </div>
  );
};

export default CollabsPage;