import React, { useState, useEffect } from "react";
import {
  Recycle, Palette, Leaf, Globe, ArrowRight, ChevronDown,
  Award, Star, Users, Package, ArrowLeft
} from "lucide-react";
import { platformStats } from "../data/mockData";

/* ── Flow step data ── */
const FLOW_STEPS = [
  { emoji: "🗑️", label: "Collect", desc: "Gather waste materials from homes & streets" },
  { emoji: "✨", label: "Transform", desc: "Sort, clean and categorise by material type" },
  { emoji: "🎨", label: "Create", desc: "Artists craft extraordinary pieces from scraps" },
  { emoji: "💰", label: "Earn", desc: "Fair income for pickers, artists & sellers" },
  { emoji: "🌱", label: "Sustain", desc: "Close the loop — zero waste circular economy" },
];

/* ── Feature cards ── */
const FEATURES = [
  { icon: Recycle, color: "bg-forest-100 text-forest-600 border-forest-200", title: "Smart Recycling", desc: "AI-assisted categorisation ensures maximum reuse value for every material." },
  { icon: Palette, color: "bg-amber-100  text-amber-700  border-amber-200", title: "Artist Network", desc: "500+ verified creators turning discarded materials into stunning artworks." },
  { icon: Leaf, color: "bg-teal-100   text-teal-700   border-teal-200", title: "Green Coins", desc: "Earn rewards on every sustainable action — sell, donate, collect or create." },
  { icon: Globe, color: "bg-lime-100   text-lime-700   border-lime-200", title: "Circular Economy", desc: "Every transaction closes the loop — turning waste into wealth & wisdom." },
];

const LandingPage = ({ onNavigate, onNavigateBack }) => {
  const [scrolled, setScrolled] = useState(false);
  const [activeIcon, setActiveIcon] = useState(0);
  const [activeStep, setActiveStep] = useState(0);

  /* Sticky nav on scroll */
  useEffect(() => {
    const fn = () => setScrolled(window.scrollY > 40);
    window.addEventListener("scroll", fn);
    return () => window.removeEventListener("scroll", fn);
  }, []);

  /* Cycle animated hero icons */
  useEffect(() => {
    const t = setInterval(() => setActiveIcon(p => (p + 1) % 3), 2200);
    return () => clearInterval(t);
  }, []);

  /* Auto-advance flow steps */
  useEffect(() => {
    const t = setInterval(() => setActiveStep(p => (p + 1) % FLOW_STEPS.length), 1800);
    return () => clearInterval(t);
  }, []);

  const heroIcons = [
    { icon: Recycle, bg: "bg-forest-100 border-forest-200", fg: "text-forest-600", label: "Reconstruct" },
    { icon: Palette, bg: "bg-amber-100  border-amber-200", fg: "text-amber-600", label: "Create Art" },
    { icon: Award, bg: "bg-teal-100   border-teal-200", fg: "text-teal-600", label: "Earn Coins" },
  ];

  return (
    <div className="min-h-screen bg-[var(--clr-bg)]">

      {/* ───────────── TOP NAV ───────────── */}
      <header
        className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${scrolled ? "bg-white/95 backdrop-blur-lg shadow-sm border-b border-soil-100" : ""
          }`}
      >
        <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
          <div className="flex items-center gap-4">
            {/* Logo */}
            <div className="flex items-center gap-2">
              <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-forest-500 to-forest-700 flex items-center justify-center shadow-md">
                <Recycle size={18} className="text-white" />
              </div>
              <span className="font-display font-black text-soil-900 text-lg tracking-tight">
                SCRAP<span className="text-forest-600">·</span>CRAFTERS
              </span>
            </div>

            {/* Nav links (desktop) */}
            <nav className="hidden md:flex items-center gap-6 text-sm font-medium text-soil-600">
              <a href="#how" className="hover:text-forest-600 transition-colors">How It Works</a>
              <a href="#features" className="hover:text-forest-600 transition-colors">Features</a>
              <a href="#impact" className="hover:text-forest-600 transition-colors">Impact</a>
              <button type="button" onClick={() => onNavigate("artworks")} className="hover:text-forest-600 transition-colors bg-transparent border-0 cursor-pointer text-inherit font-inherit p-0">Artworks</button>
              <button type="button" onClick={() => onNavigate("collaborations")} className="hover:text-forest-600 transition-colors bg-transparent border-0 cursor-pointer text-inherit font-inherit p-0">Our Collaborations</button>
            </nav>
          </div>

          {/* Auth buttons */}
          <div className="flex items-center gap-2">
            <button
              onClick={() => onNavigate("auth")}
              className="btn-outline text-sm py-2 px-4"
            >
              Sign In
            </button>
            <button
              onClick={() => onNavigate("auth")}
              className="btn-primary text-sm py-2 px-5"
            >
              Log In <ArrowRight size={14} />
            </button>
          </div>
        </div>
      </header>

      {/* ───────────── HERO ───────────── */}
      <section className="relative pt-36 pb-24 px-6 overflow-hidden">
        {/* Background video placeholder */}
        <div className="absolute inset-0 w-full h-full z-0 opacity-20 pointer-events-none">
          <video autoPlay loop muted playsInline className="w-full h-full object-cover" src="/assets/hero-video.mp4" />
        </div>

        {/* Background decorations */}
        <div className="hero-blob w-96 h-96 bg-forest-400 top-10 -left-32 z-0" />
        <div className="hero-blob w-80 h-80 bg-craft-400  top-40 right-0 z-0" />
        <div className="hero-blob w-64 h-64 bg-teal-400   bottom-0 left-1/2 z-0" />

        {/* Subtle leaf pattern overlay */}
        <div className="absolute inset-0 bg-leaf-pattern opacity-60 pointer-events-none z-0" />

        <div className="relative max-w-5xl mx-auto text-center z-10">

          {/* Badge */}
          <div className="inline-flex items-center gap-2 bg-white border border-forest-200 rounded-full px-4 py-2 text-sm font-medium text-forest-700 shadow-sm mb-8 animate-slide-up">
            <Leaf size={14} className="text-forest-500" />
            India's First Circular Economy Marketplace
          </div>

          {/* Main headline */}
          <h1
            className="font-display font-black text-5xl sm:text-6xl md:text-7xl lg:text-8xl text-soil-900 leading-[0.93] tracking-tight mb-6 animate-slide-up"
            style={{ animationDelay: "0.1s", opacity: 0, animationFillMode: "forwards" }}
          >
            Turn Waste<br />
            <span
              className="relative inline-block text-forest-600"
              style={{ WebkitTextStroke: "1px #178040" }}
            >
              into Worth.
              {/* Underline squiggle */}
              <svg className="absolute -bottom-2 left-0 w-full" height="8" viewBox="0 0 300 8" fill="none" preserveAspectRatio="none">
                <path d="M0 6 Q75 0 150 5 Q225 10 300 4" stroke="#178040" strokeWidth="2.5" strokeLinecap="round" fill="none" />
              </svg>
            </span>
          </h1>

          <p
            className="text-lg sm:text-xl text-soil-600 max-w-2xl mx-auto mb-10 leading-relaxed animate-slide-up"
            style={{ animationDelay: "0.2s", opacity: 0, animationFillMode: "forwards" }}
          >
            From discarded materials to extraordinary creations — SCRAP-CRAFTERS connects
            rag-pickers, artists &amp; conscious consumers in a living circular economy.
          </p>

          {/* Animated icon trio */}
          <div className="flex items-end justify-center gap-6 sm:gap-10 mb-12">
            {heroIcons.map((hi, i) => {
              const Icon = hi.icon;
              const isActive = activeIcon === i;
              return (
                <div
                  key={i}
                  className={`flex flex-col items-center gap-2 transition-all duration-500 ${isActive ? "-translate-y-3 scale-110" : ""}`}
                >
                  <div
                    className={`w-16 h-16 sm:w-20 sm:h-20 rounded-2xl border-2 ${hi.bg} ${hi.fg} flex items-center justify-center transition-all duration-500 ${isActive ? "shadow-lg shadow-forest-200" : ""}`}
                  >
                    <Icon size={30} strokeWidth={isActive ? 2 : 1.5} />
                  </div>
                  <span className={`text-xs font-semibold transition-colors duration-300 ${isActive ? hi.fg : "text-soil-400"}`}>
                    {hi.label}
                  </span>
                </div>
              );
            })}
          </div>

          {/* CTA buttons */}
          <div
            className="flex flex-wrap items-center justify-center gap-3 animate-slide-up"
            style={{ animationDelay: "0.3s", opacity: 0, animationFillMode: "forwards" }}
          >
            <button
              onClick={() => onNavigate("auth")}
              className="btn-craft text-sm py-3 px-6 shadow-md"
            >
              <Palette size={16} /> Join as an Artist
            </button>
            <button
              onClick={() => onNavigate("auth")}
              className="btn-primary text-sm py-3 px-6 shadow-md"
            >
              <Users size={16} /> Join as an Organisation
            </button>
            <button
              onClick={() => onNavigate("auth")}
              style={{ background: "#0f6e5a" }}
              className="btn-primary text-sm py-3 px-6 shadow-md"
            >
              <Recycle size={16} /> Join as an Agent
            </button>
          </div>
        </div>

        {/* Scroll hint */}
        <div className="flex flex-col items-center gap-2 mt-16 text-soil-400">
          <span className="text-xs font-medium">Scroll to explore</span>
          <div className="w-5 h-8 border-2 border-soil-200 rounded-full flex justify-center pt-1.5 animate-bounce-soft">
            <div className="w-1.5 h-1.5 rounded-full bg-forest-500" />
          </div>
        </div>
      </section>

      {/* ───────────── FLOW SECTION ───────────── */}
      <section id="how" className="py-24 px-6 bg-white">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-16">
            <span className="pill pill-green mb-4 inline-flex"><Leaf size={12} /> How It Works</span>
            <h2 className="font-display font-black text-4xl sm:text-5xl text-soil-900 mb-4">
              Waste → Art → <span className="text-forest-600">Income</span>
            </h2>
            <p className="text-soil-500 max-w-xl mx-auto">
              A five-step circular journey powered by people, creativity, and technology.
            </p>
          </div>

          {/* Desktop flow */}
          <div className="hidden md:flex items-stretch justify-between gap-0">
            {FLOW_STEPS.map((step, i) => {
              const isActive = activeStep === i;
              return (
                <React.Fragment key={i}>
                  <div
                    onClick={() => setActiveStep(i)}
                    className={`flex flex-col items-center gap-3 p-6 rounded-3xl cursor-pointer transition-all duration-400 flex-1 text-center ${isActive
                      ? "bg-forest-50 border-2 border-forest-200 shadow-md -translate-y-2"
                      : "hover:bg-soil-50 border-2 border-transparent"
                      }`}
                  >
                    <div className={`text-4xl transition-transform duration-300 ${isActive ? "scale-125" : ""}`}>{step.emoji}</div>
                    <div className={`w-7 h-7 rounded-full border-2 flex items-center justify-center text-xs font-bold font-mono transition-all ${isActive ? "bg-forest-600 border-forest-600 text-white" : "border-soil-300 text-soil-500"}`}>
                      {i + 1}
                    </div>
                    <h3 className={`font-display font-bold text-base ${isActive ? "text-forest-700" : "text-soil-700"}`}>{step.label}</h3>
                    <p className={`text-xs leading-relaxed ${isActive ? "text-forest-600" : "text-soil-400"}`}>{step.desc}</p>
                  </div>

                  {i < FLOW_STEPS.length - 1 && (
                    <div className="flex items-center px-1">
                      <ArrowRight size={20} className="text-soil-300" />
                    </div>
                  )}
                </React.Fragment>
              );
            })}
          </div>

          {/* Mobile flow */}
          <div className="md:hidden space-y-4">
            {FLOW_STEPS.map((step, i) => (
              <div key={i} className="flex items-start gap-4 p-4 rounded-2xl bg-soil-50 border border-soil-100">
                <div className="text-3xl shrink-0">{step.emoji}</div>
                <div>
                  <div className="flex items-center gap-2 mb-1">
                    <span className="w-5 h-5 rounded-full bg-forest-600 text-white text-xs flex items-center justify-center font-bold">{i + 1}</span>
                    <h3 className="font-semibold text-soil-900">{step.label}</h3>
                  </div>
                  <p className="text-sm text-soil-500">{step.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ───────────── FEATURES ───────────── */}
      <section id="features" className="py-24 px-6 bg-[var(--clr-bg)]">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="font-display font-black text-4xl sm:text-5xl text-soil-900 mb-4">
              Why <span className="text-forest-600">SCRAP-CRAFTERS?</span>
            </h2>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
            {FEATURES.map(({ icon: Icon, color, title, desc }, i) => (
              <div
                key={i}
                className="card p-6 hover:shadow-[0_12px_40px_rgba(23,128,64,0.12)] group"
                style={{ animationDelay: `${i * 0.1}s` }}
              >
                <div className={`w-12 h-12 rounded-2xl border ${color} flex items-center justify-center mb-4 group-hover:scale-110 transition-transform`}>
                  <Icon size={22} strokeWidth={1.8} />
                </div>
                <h3 className="font-display font-bold text-soil-900 mb-2">{title}</h3>
                <p className="text-sm text-soil-500 leading-relaxed">{desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ───────────── IMPACT STATS ───────────── */}
      <section id="impact" className="py-20 px-6 bg-gradient-to-br from-forest-700 to-forest-900 relative overflow-hidden">
        <div className="absolute inset-0 bg-leaf-pattern opacity-10" />
        <div className="relative max-w-5xl mx-auto">
          <div className="text-center mb-12">
            <h2 className="font-display font-black text-4xl text-white mb-3">Our Impact</h2>
            <p className="text-forest-200 text-sm">Numbers that matter — for people and the planet.</p>
          </div>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8 text-center">
            {[
              { value: platformStats.itemsRecycled, label: "Items Recycled", icon: Recycle },
              { value: platformStats.artists, label: "Creative Artists", icon: Palette },
              { value: platformStats.incomeGenerated, label: "Income Generated", icon: Award },
              { value: platformStats.wasteDiverted, label: "Waste Diverted", icon: Leaf },
            ].map(({ value, label, icon: Icon }, i) => (
              <div key={i} className="flex flex-col items-center gap-2">
                <div className="w-12 h-12 rounded-2xl bg-white/10 border border-white/20 flex items-center justify-center text-forest-200 mb-2">
                  <Icon size={22} />
                </div>
                <p className="font-display font-black text-3xl text-white">{value}</p>
                <p className="text-forest-200 text-sm font-medium">{label}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ───────────── FINAL CTA ───────────── */}
      <section className="py-24 px-6 text-center bg-white">
        <div className="max-w-2xl mx-auto">
          <div className="text-5xl mb-4">🌿</div>
          <h2 className="font-display font-black text-4xl text-soil-900 mb-4">
            Ready to Make a<br /><span className="text-forest-600">Difference?</span>
          </h2>
          <p className="text-soil-500 mb-8 text-lg">
            Join thousands of Indians building a circular economy — one scrap at a time.
          </p>
          <button
            onClick={() => onNavigate("auth")}
            className="btn-primary text-base py-4 px-10 shadow-lg hover:shadow-xl hover:shadow-forest-200"
          >
            Start Your Journey <ArrowRight size={18} />
          </button>
        </div>
      </section>

      {/* ───────────── FOOTER ───────────── */}
      <footer className="bg-soil-900 text-soil-300 py-10 px-6">
        <div className="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-2">
            <div className="w-7 h-7 rounded-lg bg-forest-600 flex items-center justify-center">
              <Recycle size={14} className="text-white" />
            </div>
            <span className="font-display font-bold text-white">SCRAP·CRAFTERS</span>
          </div>
          <p className="text-soil-500 text-xs text-center">
            © 2025 SCRAP-CRAFTERS. Building a circular India, one scrap at a time.
          </p>
          <div className="flex gap-4 text-xs text-soil-500">
            <a href="#" className="hover:text-forest-400 transition-colors">Privacy</a>
            <a href="#" className="hover:text-forest-400 transition-colors">Terms</a>
            <a href="#" className="hover:text-forest-400 transition-colors">Contact</a>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default LandingPage;