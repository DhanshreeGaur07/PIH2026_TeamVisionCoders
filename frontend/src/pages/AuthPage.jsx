// ============================================================
//  AuthPage.js  —  Login / Register using real API
// ============================================================
import React, { useState } from "react";
import { Recycle, Leaf, Eye, EyeOff, AlertCircle, ArrowLeft } from "lucide-react";

const ROLES = [
  { id: "user", emoji: "👤", label: "User", desc: "List and donate your scrap items" },
  { id: "artist", emoji: "🎨", label: "Artist", desc: "Buy scrap and sell your upcycled art" },
  { id: "helper", emoji: "♻️", label: "Agent", desc: "Pick up and deliver scrap for coins" },
  { id: "organisation", emoji: "🏢", label: "Organisation", desc: "Buys scraps and use them for sustainable projects" }
];

const AuthPage = ({ onNavigate, onNavigateBack, onAuthSuccess, auth }) => {
  const [mode, setMode] = useState("login");      // "login" | "signup"
  const [showPw, setShowPw] = useState(false);
  const [role, setRole] = useState("user");
  const [form, setForm] = useState({ name: "", email: "", password: "" });
  const [localErr, setLocalErr] = useState("");

  const set = (k) => (e) => setForm(f => ({ ...f, [k]: e.target.value }));

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLocalErr("");

    if (mode === "signup" && !form.name.trim()) { setLocalErr("Name is required."); return; }
    if (!form.email.trim()) { setLocalErr("Email is required."); return; }
    if (form.password.length < 6) { setLocalErr("Password must be at least 6 characters."); return; }

    try {
      if (mode === "login") {
        const user = await auth.login(form.email, form.password);
        onAuthSuccess(user);
      } else {
        const user = await auth.register({ name: form.name, email: form.email, password: form.password, role });
        onAuthSuccess(user);
      }
    } catch (err) {
      setLocalErr(err.message || "Something went wrong. Please try again.");
    }
  };

  const error = localErr || auth.error;

  return (
    <div className="min-h-screen flex">

      {/* ── Left panel — decorative ── */}
      <div className="hidden lg:flex flex-col justify-between w-[42%] bg-gradient-to-br from-forest-900 via-forest-800 to-forest-700 p-12 relative overflow-hidden">
        {/* Background texture */}
        <div className="absolute inset-0 opacity-10"
          style={{ backgroundImage: "url(\"data:image/svg+xml,%3Csvg width='40' height='40' viewBox='0 0 40 40' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M20 0C9 0 0 9 0 20s9 20 20 20 20-9 20-20S31 0 20 0zm0 36c-8.8 0-16-7.2-16-16S11.2 4 20 4s16 7.2 16 16-7.2 16-16 16z' fill='%23ffffff'/%3E%3C/svg%3E\")" }} />

        {/* Logo */}
        <div className="flex items-center gap-3 relative z-10">
          <div className="w-10 h-10 rounded-2xl bg-white/20 backdrop-blur flex items-center justify-center">
            <Recycle size={20} className="text-white" />
          </div>
          <span className="font-display font-bold text-white text-lg tracking-tight">
            SCRAP<span className="text-forest-300">·</span>CRAFTERS
          </span>
        </div>

        {/* Hero text */}
        <div className="relative z-10 space-y-6">
          <div className="inline-flex items-center gap-2 bg-white/15 border border-white/20 rounded-full px-4 py-2 text-white/80 text-sm font-medium">
            <Leaf size={14} /> India's Circular Economy Marketplace
          </div>
          <h2 className="font-display font-black text-4xl text-white leading-tight">
            Turn Waste into<br />
            <span className="text-forest-300">Wonder.</span>
          </h2>
          <p className="text-forest-100 text-sm leading-relaxed max-w-xs">
            Join thousands of artists, helpers, and eco-conscious users transforming scrap into beautiful, sustainable creations.
          </p>

          {/* Stats */}
          <div className="grid grid-cols-3 gap-3 pt-2">
            {[
              { val: "12K+", label: "Items Recycled" },
              { val: "3.2K", label: "Artists" },
              { val: "₹8L+", label: "Income Generated" },
            ].map(s => (
              <div key={s.label} className="bg-white/10 border border-white/20 rounded-2xl p-3 text-center">
                <p className="font-display font-black text-white text-xl">{s.val}</p>
                <p className="text-forest-200 text-xs mt-0.5">{s.label}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Floating leaves */}
        <div className="absolute bottom-8 right-8 w-24 h-24 rounded-full bg-forest-600/30 blur-2xl" />
        <div className="absolute top-1/3 right-4 w-16 h-16 rounded-full bg-white/10 blur-xl" />
      </div>

      {/* ── Right panel — form ── */}
      <div className="flex-1 flex items-center justify-center px-6 py-12 bg-[var(--clr-bg)]">
        <div className="w-full max-w-md">
          <button type="button" onClick={onNavigateBack} className="flex items-center gap-2 text-soil-500 hover:text-forest-600 text-sm font-medium mb-6">
            <ArrowLeft size={18} /> Back
          </button>

          {/* Mobile logo */}
          <div className="flex items-center gap-2 mb-8 lg:hidden">
            <div className="w-8 h-8 rounded-xl bg-forest-600 flex items-center justify-center">
              <Recycle size={15} className="text-white" />
            </div>
            <span className="font-display font-bold text-soil-900">SCRAP·CRAFTERS</span>
          </div>

          {/* Mode toggle */}
          <div className="flex bg-soil-100 border border-soil-200 rounded-2xl p-1 mb-7">
            {["login", "signup"].map(m => (
              <button key={m} onClick={() => { setMode(m); setLocalErr(""); auth.setError(null); }}
                className={`flex-1 py-2.5 rounded-xl text-sm font-semibold capitalize transition-all ${mode === m ? "bg-white text-soil-900 shadow-sm border border-soil-200" : "text-soil-500 hover:text-soil-800"
                  }`}>
                {m === "login" ? "Sign In" : "Create Account"}
              </button>
            ))}
          </div>

          <h1 className="font-display font-black text-2xl text-soil-900 mb-1">
            {mode === "login" ? "Welcome back 👋" : "Join the movement 🌿"}
          </h1>
          <p className="text-soil-500 text-sm mb-6">
            {mode === "login"
              ? "Sign in to your SCRAP·CRAFTERS account."
              : "Create your account to start your eco-journey."}
          </p>

          {/* Error banner */}
          {error && (
            <div className="flex items-start gap-2.5 bg-red-50 border border-red-200 rounded-2xl p-4 mb-5">
              <AlertCircle size={16} className="text-red-500 shrink-0 mt-0.5" />
              <p className="text-sm text-red-700">{error}</p>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">

            {/* Name — signup only */}
            {mode === "signup" && (
              <div>
                <label className="block text-xs font-semibold text-soil-600 mb-1.5 uppercase tracking-wide">
                  Full Name
                </label>
                <input
                  value={form.name}
                  onChange={set("name")}
                  placeholder="Your full name"
                  className="input-field"
                  autoComplete="name"
                />
              </div>
            )}

            {/* Email */}
            <div>
              <label className="block text-xs font-semibold text-soil-600 mb-1.5 uppercase tracking-wide">
                Email Address
              </label>
              <input
                type="email"
                value={form.email}
                onChange={set("email")}
                placeholder="you@example.com"
                className="input-field"
                autoComplete="email"
              />
            </div>

            {/* Password */}
            <div>
              <label className="block text-xs font-semibold text-soil-600 mb-1.5 uppercase tracking-wide">
                Password
              </label>
              <div className="relative">
                <input
                  type={showPw ? "text" : "password"}
                  value={form.password}
                  onChange={set("password")}
                  placeholder="Min 6 characters"
                  className="input-field pr-10"
                  autoComplete={mode === "login" ? "current-password" : "new-password"}
                />
                <button type="button" onClick={() => setShowPw(v => !v)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-soil-400 hover:text-soil-700">
                  {showPw ? <EyeOff size={16} /> : <Eye size={16} />}
                </button>
              </div>
            </div>

            {/* Role selector — signup only */}
            {mode === "signup" && (
              <div>
                <label className="block text-xs font-semibold text-soil-600 mb-2 uppercase tracking-wide">
                  I am a…
                </label>
                <div className="grid grid-cols-3 gap-2">
                  {ROLES.map(r => (
                    <button type="button" key={r.id} onClick={() => setRole(r.id)}
                      className={`p-3 rounded-2xl border-2 text-center transition-all ${role === r.id
                        ? "border-forest-500 bg-forest-50 shadow-sm"
                        : "border-soil-200 bg-white hover:border-forest-300"
                        }`}>
                      <div className="text-2xl mb-1">{r.emoji}</div>
                      <p className={`text-xs font-bold ${role === r.id ? "text-forest-700" : "text-soil-700"}`}>{r.label}</p>
                      <p className="text-[10px] text-soil-400 mt-0.5 leading-tight hidden sm:block">{r.desc}</p>
                    </button>
                  ))}
                </div>
              </div>
            )}

            {/* Submit */}
            <button type="submit" disabled={auth.loading}
              className="btn-primary w-full justify-center py-3.5 mt-2 text-base disabled:opacity-60 disabled:cursor-not-allowed">
              {auth.loading
                ? <><span className="animate-spin inline-block mr-2">⟳</span> {mode === "login" ? "Signing in…" : "Creating account…"}</>
                : mode === "login" ? "Sign In" : "Create Account"
              }
            </button>

            {/* Sign in with Google — placeholder */}
            <div className="mt-4">
              <button type="button" disabled className="w-full flex items-center justify-center gap-2 py-3 rounded-2xl border-2 border-soil-200 bg-soil-50 text-soil-500 cursor-not-allowed text-sm font-medium">
                <span className="w-5 h-5 rounded-full bg-white border border-soil-200 flex items-center justify-center text-xs">G</span>
                Sign in with Google
              </button>
            </div>
          </form>

          {/* Divider / toggle */}
          <p className="text-center text-sm text-soil-500 mt-5">
            {mode === "login" ? "Don't have an account? " : "Already have an account? "}
            <button onClick={() => { setMode(mode === "login" ? "signup" : "login"); setLocalErr(""); }}
              className="font-semibold text-forest-600 hover:underline">
              {mode === "login" ? "Create one" : "Sign in"}
            </button>
          </p>

          <button onClick={onNavigateBack} className="w-full text-center text-xs text-soil-400 hover:text-soil-600 mt-4 transition-colors">
            ← Back
          </button>
        </div>
      </div>
    </div>
  );
};

export default AuthPage;
