// ============================================================
//  CollabsPage.js — Collaborations with eco-ventures & art orgs
//  Includes: Plastic→Bricks, Plastic→Fuel/Roads,
//            Art Culture orgs (incl. Twinkle Art),
//            E-Waste recyclers
// ============================================================
import React, { useState } from "react";
import {
  Recycle, Users, Building, Palette, Leaf, ArrowRight,
  Globe, Mail, MapPin, Package, LogOut, Flame, Pen,
  Heart, Zap, Star, ChevronRight
} from "lucide-react";

/* ═══════════════════════════════════════════
   PARTNER DATA
═══════════════════════════════════════════ */
const PARTNERS = [
  // ── Plastic → Bricks ──────────────────────────────────────────────
  {
    id: 1, category: "plastic-bricks",
    name: "MillBrick Innovations",
    tagline: "Turning plastic waste into durable, affordable bricks",
    description: "MillBrick collects post-consumer plastic from platforms like SCRAP-CRAFTERS and processes it into interlocking construction bricks — 40% lighter than concrete, fully weatherproof, and load-bearing up to 3 storeys. Every tonne of plastic waste produces approximately 2,500 bricks. They source HDPE, LDPE, and PP plastics through our helper network.",
    location: "Pune, Maharashtra", founded: 2019,
    impactTag: "850T plastic diverted",
    stats: [{ val:"850T", label:"Plastic Processed" },{ val:"2.1M", label:"Bricks Produced" },{ val:"14", label:"Partner Cities" }],
    tags: ["HDPE","LDPE","PP Plastic","Construction"],
    gradient: "from-blue-600 to-blue-800",
    light: "bg-blue-50", border: "border-blue-200", accent: "text-blue-700",
    icon: Building,
    website: "https://millbrick.example.in", contact: "partner@millbrick.example.in",
    materialWanted: ["plastic","composite"],
  },
  {
    id: 2, category: "plastic-bricks",
    name: "GreenBlock India",
    tagline: "Sustainable modular housing from recycled plastics",
    description: "GreenBlock manufactures eco-friendly hollow construction blocks from mixed plastic waste. Their patented cold-press technology requires no heat, cutting energy use by 60% vs conventional block-making. Used in affordable housing projects across Maharashtra and Karnataka. We route plastic donations directly to their intake centres.",
    location: "Nashik, Maharashtra", founded: 2021,
    impactTag: "300+ homes built",
    stats: [{ val:"300+", label:"Homes Built" },{ val:"580T", label:"Plastic Upcycled" },{ val:"₹2.4Cr", label:"Farmer Income Generated" }],
    tags: ["Mixed Plastic","PET","HDPE","Housing"],
    gradient: "from-teal-600 to-teal-800",
    light: "bg-teal-50", border: "border-teal-200", accent: "text-teal-700",
    icon: Building,
    website: "https://greenblock.example.in", contact: "info@greenblock.example.in",
    materialWanted: ["plastic","rubber"],
  },

  // ── Plastic → Coal Tar / Fuel ─────────────────────────────────────
  {
    id: 3, category: "coal-tar",
    name: "PyroGreen Energy",
    tagline: "Converting plastic waste into usable fuel through pyrolysis",
    description: "PyroGreen operates industrial pyrolysis units that thermally decompose non-recyclable plastic at 400–500°C in an oxygen-free environment to produce diesel-equivalent fuel, combustible gas, and carbon black. The process handles PVC, multilayer plastics, and other streams that conventional recyclers reject — channelled via our scrap marketplace.",
    location: "Aurangabad, Maharashtra", founded: 2018,
    impactTag: "120,000 L fuel/month",
    stats: [{ val:"120KL", label:"Fuel per Month" },{ val:"400T", label:"Plastic Processed" },{ val:"82%", label:"Energy Recovery" }],
    tags: ["PVC","Multi-layer","Non-recyclable","Pyrolysis"],
    gradient: "from-orange-600 to-orange-800",
    light: "bg-orange-50", border: "border-orange-200", accent: "text-orange-700",
    icon: Flame,
    website: "https://pyrogreen.example.in", contact: "ops@pyrogreen.example.in",
    materialWanted: ["plastic","rubber","composite"],
  },
  {
    id: 4, category: "coal-tar",
    name: "RoadSense Technologies",
    tagline: "Plastic-modified bitumen for longer-lasting Indian roads",
    description: "RoadSense blends shredded PET and PP plastic with bitumen/coal tar to produce a modified road-laying compound that increases road life by 3×, reduces rutting, and prevents pothole formation. They work directly with municipal corporations and NHAI contractors. Our scrap marketplace directly supplies them with sorted PET and PP feedstock.",
    location: "Mumbai, Maharashtra", founded: 2017,
    impactTag: "780 km roads laid",
    stats: [{ val:"780km", label:"Roads Paved" },{ val:"3×", label:"Longer Road Life" },{ val:"1,200T", label:"Plastic Used" }],
    tags: ["PET","PP","Road Construction","Bitumen"],
    gradient: "from-stone-600 to-stone-800",
    light: "bg-stone-50", border: "border-stone-200", accent: "text-stone-700",
    icon: Zap,
    website: "https://roadsense.example.in", contact: "procurement@roadsense.example.in",
    materialWanted: ["plastic"],
  },

  // ── Art & Culture ─────────────────────────────────────────────────
  {
    id: 5, category: "art-culture",
    name: "Twinkle Art Foundation",
    tagline: "Nurturing creative expression for children and adults alike",
    description: "Twinkle Art Foundation runs free weekend art workshops across underprivileged communities in Pune, using upcycled scrap materials to teach painting, sculpture, and mixed media. Founded on the belief that art heals, they've trained over 2,800 children and 400 adult learners. SCRAP-CRAFTERS donates scrap material directly to their studios — users can mark items as \"Donate to Twinkle Art\" at checkout.",
    location: "Pune, Maharashtra", founded: 2015,
    impactTag: "2,800+ learners",
    stats: [{ val:"2,800+", label:"Students Trained" },{ val:"38", label:"Free Workshops/Year" },{ val:"12", label:"Community Centres" }],
    tags: ["Children","Upcycled Art","Free Workshops","Community"],
    gradient: "from-pink-500 to-rose-600",
    light: "bg-pink-50", border: "border-pink-200", accent: "text-pink-700",
    icon: Pen,
    website: "https://twinkleart.example.in", contact: "hello@twinkleart.example.in",
    materialWanted: ["artwork","textile","paper","metal","glass"],
    featured: true,
  },
  {
    id: 6, category: "art-culture",
    name: "Kala Samvad Collective",
    tagline: "Where traditional craft meets contemporary upcycled expression",
    description: "Kala Samvad brings together traditional artisans and modern artists to create collaborative exhibitions from recycled materials. They run a residency programme where artists spend 2 weeks sourcing scrap from our marketplace and transforming it into exhibition-grade pieces. The collective advocates loudly for sustainable art practices.",
    location: "Bengaluru, Karnataka", founded: 2016,
    impactTag: "60 exhibitions held",
    stats: [{ val:"60", label:"Exhibitions" },{ val:"180", label:"Resident Artists" },{ val:"14T", label:"Scrap Transformed" }],
    tags: ["Residency","Traditional Craft","Exhibitions","Sustainable Art"],
    gradient: "from-purple-600 to-violet-700",
    light: "bg-purple-50", border: "border-purple-200", accent: "text-purple-700",
    icon: Palette,
    website: "https://kalasamvad.example.in", contact: "residency@kalasamvad.example.in",
    materialWanted: ["metal","glass","ceramic","textile","wood"],
  },
  {
    id: 7, category: "art-culture",
    name: "Green Canvas Initiative",
    tagline: "Art therapy and wellness through eco-conscious creation",
    description: "Green Canvas runs art therapy sessions in hospitals, schools, and correctional facilities using only recycled and natural materials sourced through SCRAP-CRAFTERS and partner platforms. Their evidence-backed programmes show measurable improvements in mental health outcomes. They welcome material donations from our users — every textile and paper offcut finds a therapeutic use.",
    location: "Chennai, Tamil Nadu", founded: 2020,
    impactTag: "1,200 therapy sessions",
    stats: [{ val:"1,200", label:"Therapy Sessions" },{ val:"34", label:"Partner Hospitals" },{ val:"95%", label:"Positive Outcomes" }],
    tags: ["Art Therapy","Hospitals","Mental Health","Donations Welcome"],
    gradient: "from-emerald-600 to-green-700",
    light: "bg-emerald-50", border: "border-emerald-200", accent: "text-emerald-700",
    icon: Heart,
    website: "https://greencanvas.example.in", contact: "therapy@greencanvas.example.in",
    materialWanted: ["paper","textile","glass","ceramic"],
  },

  // ── E-Waste & Metal Recyclers ─────────────────────────────────────
  {
    id: 8, category: "ewaste",
    name: "CirQuit Recyclers",
    tagline: "Certified e-waste processing with maximum material recovery",
    description: "CirQuit is a certified e-waste dismantler recovering gold, silver, copper, and rare earth metals from old electronics. They pay competitive rates for bulk e-waste and partner with SCRAP-CRAFTERS to route circuit boards and components through certified smelting facilities rather than landfills. Artists on our platform can sell e-waste directly to CirQuit.",
    location: "Bengaluru, Karnataka", founded: 2014,
    impactTag: "40T e-waste/month",
    stats: [{ val:"40T", label:"E-waste/Month" },{ val:"98%", label:"Material Recovery" },{ val:"220kg", label:"Gold Recovered/yr" }],
    tags: ["PCB","Circuit Boards","Metals","Certified"],
    gradient: "from-cyan-600 to-cyan-800",
    light: "bg-cyan-50", border: "border-cyan-200", accent: "text-cyan-700",
    icon: Recycle,
    website: "https://cirquit.example.in", contact: "bulk@cirquit.example.in",
    materialWanted: ["e-waste","metal"],
  },
];

const CATEGORIES = [
  { id:"all",           label:"All Partners",          icon:Users },
  { id:"plastic-bricks",label:"Plastic → Bricks",       icon:Building },
  { id:"coal-tar",      label:"Plastic → Fuel & Roads", icon:Flame     },
  { id:"art-culture",   label:"Art & Culture",           icon:Pen     },
  { id:"ewaste",        label:"E-Waste & Metals",        icon:Recycle   },
];

/* ── Partner Card ── */
const PartnerCard = ({ partner }) => {
  const [expanded, setExpanded] = useState(false);
  const Icon = partner.icon;

  return (
    <div className={`card overflow-hidden border-2 ${partner.border} hover:shadow-2xl transition-all duration-300 flex flex-col`}>
      {/* Gradient header */}
      <div className={`bg-gradient-to-r ${partner.gradient} p-6`}>
        <div className="flex items-start justify-between gap-3">
          <div className="flex items-center gap-3">
            <div className="w-13 h-13 rounded-2xl bg-white/20 backdrop-blur flex items-center justify-center p-2.5 shrink-0">
              <Icon size={24} className="text-white"/>
            </div>
            <div>
              <div className="flex items-center gap-2 flex-wrap">
                <h3 className="font-display font-bold text-white text-lg leading-tight">{partner.name}</h3>
                {partner.featured && (
                  <span className="pill bg-yellow-400/90 text-yellow-900 text-[9px] font-bold border-0">⭐ FEATURED</span>
                )}
              </div>
              <p className="text-white/70 text-xs mt-0.5 flex items-center gap-1">
                <MapPin size={10}/>{partner.location} · Est. {partner.founded}
              </p>
            </div>
          </div>
          <span className="pill bg-white/20 text-white border-white/30 border text-[10px] font-semibold shrink-0 backdrop-blur">
            {partner.impactTag}
          </span>
        </div>
      </div>

      {/* Body */}
      <div className="p-5 flex-1 flex flex-col">
        <p className={`font-semibold text-sm ${partner.accent} mb-2`}>{partner.tagline}</p>
        <p className={`text-xs text-soil-600 leading-relaxed mb-3 ${expanded?"":"line-clamp-3"}`}>
          {partner.description}
        </p>
        <button onClick={() => setExpanded(v => !v)}
          className={`text-xs font-semibold ${partner.accent} hover:underline mb-4 self-start`}>
          {expanded ? "Show less ↑" : "Read more ↓"}
        </button>

        {/* Stats */}
        <div className={`grid grid-cols-3 gap-2 p-3 rounded-2xl ${partner.light} border ${partner.border} mb-4`}>
          {partner.stats.map(s => (
            <div key={s.label} className="text-center">
              <p className={`font-display font-black text-xl ${partner.accent}`}>{s.val}</p>
              <p className="text-soil-500 text-[10px] leading-tight">{s.label}</p>
            </div>
          ))}
        </div>

        {/* Tags */}
        <div className="flex flex-wrap gap-1.5 mb-4">
          {partner.tags.map(tag => (
            <span key={tag} className={`pill text-[10px] ${partner.light} ${partner.accent} border ${partner.border}`}>{tag}</span>
          ))}
        </div>

        {/* Materials wanted */}
        <div className={`p-3 rounded-xl ${partner.light} border ${partner.border} mb-5`}>
          <p className="text-xs font-semibold text-soil-600 mb-2 flex items-center gap-1">
            <Package size={11}/> Materials they accept:
          </p>
          <div className="flex flex-wrap gap-1">
            {partner.materialWanted.map(m => (
              <span key={m} className="pill bg-white border border-soil-200 text-soil-600 text-[10px] capitalize">{m}</span>
            ))}
          </div>
        </div>

        {/* Contact links */}
        <div className="flex items-center gap-3 flex-wrap mt-auto">
          <a href={`mailto:${partner.contact}`}
            className={`flex items-center gap-1.5 text-xs font-semibold ${partner.accent} hover:underline`}>
            <Mail size={11}/>{partner.contact}
          </a>
          <span className="text-soil-200">·</span>
          <a href={partner.website} target="_blank" rel="noreferrer"
            className="flex items-center gap-1 text-xs text-soil-400 hover:text-soil-700">
            <Globe size={11}/> Website <ArrowRight size={9}/>
          </a>
        </div>
      </div>
    </div>
  );
};

/* ── Main Page ── */
const CollabsPage = ({ user, onNavigate, onLogout }) => {
  const [activeCat, setActiveCat] = useState("all");

  const filtered = activeCat === "all" ? PARTNERS : PARTNERS.filter(p => p.category === activeCat);
  const totalByCategory = {
    "plastic-bricks": PARTNERS.filter(p => p.category==="plastic-bricks").length,
    "coal-tar":        PARTNERS.filter(p => p.category==="coal-tar").length,
    "art-culture":     PARTNERS.filter(p => p.category==="art-culture").length,
    "ewaste":          PARTNERS.filter(p => p.category==="ewaste").length,
  };

  return (
    <div className="min-h-screen bg-[var(--clr-bg)] flex flex-col">
      {/* Navbar */}
      <header className="sticky top-0 z-50 bg-white/90 backdrop-blur-lg border-b border-soil-100 shadow-sm">
        <div className="max-w-7xl mx-auto px-4 py-3 flex items-center gap-4">
          <button onClick={() => onNavigate("landing")} className="flex items-center gap-2 shrink-0">
            <div className="w-8 h-8 rounded-xl bg-gradient-to-br from-forest-500 to-forest-700 flex items-center justify-center shadow-sm">
              <Recycle size={16} className="text-white"/>
            </div>
            <span className="font-display font-bold text-soil-900 text-sm hidden sm:block tracking-tight">
              SCRAP<span className="text-forest-600">·</span>CRAFTERS
            </span>
          </button>
          <div className="ml-auto flex items-center gap-2">
            {user && (
              <>
                <button onClick={() => onNavigate(user.role)}
                  className="text-xs font-medium text-soil-500 hover:text-forest-700 px-3 py-1.5 rounded-lg hover:bg-forest-50 transition-colors flex items-center gap-1">
                  ← Dashboard
                </button>
                <button onClick={() => onNavigate("sold-donated")}
                  className="text-xs font-medium text-soil-500 hover:text-amber-700 px-3 py-1.5 rounded-lg hover:bg-amber-50 transition-colors hidden sm:flex items-center gap-1">
                  Sold &amp; Donated
                </button>
                <button onClick={onLogout}
                  className="flex items-center gap-1 text-xs text-soil-400 hover:text-red-500 hover:bg-red-50 px-2 py-1.5 rounded-lg transition-colors">
                  <LogOut size={13}/> Logout
                </button>
              </>
            )}
            {!user && (
              <button onClick={() => onNavigate("auth")} className="btn-primary text-xs py-2 px-4">
                Join Now
              </button>
            )}
          </div>
        </div>
      </header>

      <main className="flex-1 max-w-7xl mx-auto w-full px-4 sm:px-6 py-10">

        {/* Hero */}
        <div className="relative rounded-3xl overflow-hidden bg-gradient-to-br from-forest-800 via-forest-700 to-teal-700 p-8 sm:p-14 mb-10">
          <div className="absolute inset-0 opacity-5"
            style={{ backgroundImage:"radial-gradient(circle at 30% 50%, white 1px, transparent 1px)", backgroundSize:"40px 40px" }}/>
          <div className="relative z-10 max-w-2xl">
            <span className="inline-flex items-center gap-2 bg-white/15 border border-white/25 rounded-full px-4 py-1.5 text-white/80 text-xs font-semibold mb-5">
              <Users size={13}/> Platform Collaborations
            </span>
            <h1 className="font-display font-black text-4xl sm:text-5xl text-white mb-4 leading-tight">
              Together, We Close<br/>
              <span className="text-forest-300">The Loop.</span>
            </h1>
            <p className="text-forest-100 text-sm sm:text-base leading-relaxed mb-8 max-w-lg">
              SCRAP-CRAFTERS works with manufacturers, artists, and social organisations to ensure every piece of scrap finds a meaningful second life — whether as a brick, a road, a painting, or a moment of healing.
            </p>
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
              {[
                { val:`${PARTNERS.length}`, label:"Partner Orgs" },
                { val:"4",                 label:"Indian States" },
                { val:"2,000T+",           label:"Waste Diverted" },
                { val:"6,000+",            label:"Lives Touched" },
              ].map(s => (
                <div key={s.label} className="bg-white/10 border border-white/20 rounded-2xl p-3 text-center backdrop-blur">
                  <p className="font-display font-black text-white text-2xl">{s.val}</p>
                  <p className="text-forest-200 text-xs mt-0.5">{s.label}</p>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Category filters */}
        <div className="flex flex-wrap gap-2 mb-8">
          {CATEGORIES.map(({ id, label, icon:Icon }) => (
            <button key={id} onClick={() => setActiveCat(id)}
              className={`flex items-center gap-2 px-4 py-2.5 rounded-2xl border text-sm font-semibold transition-all ${
                activeCat===id
                  ? "bg-forest-600 text-white border-forest-600 shadow"
                  : "bg-white text-soil-600 border-soil-200 hover:border-forest-400 hover:text-forest-700"
              }`}>
              <Icon size={14}/>{label}
              {id !== "all" && (
                <span className={`ml-1 px-1.5 py-0.5 rounded-full text-[10px] font-bold ${activeCat===id?"bg-white/20 text-white":"bg-soil-100 text-soil-500"}`}>
                  {totalByCategory[id]}
                </span>
              )}
              {id === "art-culture" && activeCat !== id && (
                <span className="pill bg-pink-100 text-pink-700 border border-pink-200 text-[9px] py-0 px-1.5 ml-1">incl. Twinkle Art</span>
              )}
            </button>
          ))}
        </div>

        {/* Partner count */}
        <p className="text-sm text-soil-500 mb-6">
          Showing <span className="font-semibold text-soil-800">{filtered.length}</span> partner{filtered.length!==1?"s":""}{activeCat!=="all"?` in "${CATEGORIES.find(c=>c.id===activeCat)?.label}"`:""}.
        </p>

        {/* Partner grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
          {filtered.map(p => <PartnerCard key={p.id} partner={p}/>)}
        </div>

        {filtered.length === 0 && (
          <div className="card p-16 text-center text-soil-400">
            <Users size={36} className="mx-auto mb-4 opacity-40"/>
            <p className="font-display font-bold text-xl">No partners in this category yet.</p>
          </div>
        )}

        {/* CTA */}
        <div className="mt-14 card p-8 sm:p-12 text-center bg-gradient-to-br from-forest-50 to-teal-50 border-forest-200">
          <div className="w-14 h-14 rounded-2xl bg-forest-600 flex items-center justify-center mx-auto mb-4 shadow-lg">
            <Leaf size={28} className="text-white"/>
          </div>
          <h2 className="font-display font-black text-2xl sm:text-3xl text-forest-900 mb-2">Want to collaborate?</h2>
          <p className="text-soil-500 text-sm max-w-md mx-auto mb-6">
            If your organisation works with recycled materials, upcycled art, community art therapy, or circular economy manufacturing, we'd love to partner. Let's build something meaningful together.
          </p>
          <div className="flex flex-wrap items-center justify-center gap-3">
            <a href="mailto:partnerships@scrapcrafters.in"
              className="btn-primary inline-flex justify-center py-3 px-8 text-base">
              <Mail size={16}/> Get in Touch
            </a>
            {user && (
              <button onClick={() => onNavigate(user.role)}
                className="btn-outline py-3 px-8 text-base">
                ← Back to Dashboard
              </button>
            )}
          </div>
        </div>
      </main>
    </div>
  );
};

export default CollabsPage;