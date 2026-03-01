import React, { useState } from "react";
import {
  Recycle, Search, Bell, LogOut, Palette, User,
  Menu, X, Leaf, Users, Package
} from "lucide-react";

const ROLE_CONFIG = {
  artist: { label: "Artist",  icon: Palette,  pill: "bg-amber-100  text-amber-800  border-amber-200",  avatar: "bg-amber-500"  },
  user:   { label: "User",    icon: User,     pill: "bg-forest-100 text-forest-800 border-forest-200", avatar: "bg-forest-500" },
  helper: { label: "Helper",  icon: Recycle,  pill: "bg-teal-100   text-teal-800   border-teal-200",   avatar: "bg-teal-600"   },
};

const Navbar = ({ role, user, onLogout, onNavigate }) => {
  const [mobileOpen, setMobileOpen] = useState(false);
  const cfg     = ROLE_CONFIG[role] || ROLE_CONFIG.user;
  const RoleIcon = cfg.icon;
  const displayName = user?.name || "User";
  const coins       = user?.green_coins ?? 0;

  return (
    <header className="sticky top-0 z-50 bg-white/90 backdrop-blur-lg border-b border-soil-100 shadow-sm">
      <div className="max-w-7xl mx-auto px-4 py-3 flex items-center gap-4">

        {/* Logo */}
        <button onClick={() => onNavigate("landing")}
          className="flex items-center gap-2 shrink-0 group" aria-label="Home">
          <div className="w-8 h-8 rounded-xl bg-gradient-to-br from-forest-500 to-forest-700 flex items-center justify-center shadow-sm group-hover:shadow-md transition-all">
            <Recycle size={16} className="text-white" />
          </div>
          <span className="font-display font-bold text-soil-900 text-sm hidden sm:block tracking-tight">
            SCRAP<span className="text-forest-600">·</span>CRAFTERS
          </span>
        </button>

        {/* Search — artist + user */}
        {role !== "helper" && (
          <div className="flex-1 max-w-sm hidden md:flex items-center gap-2 bg-soil-50 border border-soil-200 rounded-xl px-3 py-2 focus-within:border-forest-400 focus-within:bg-white transition-all">
            <Search size={14} className="text-soil-400 shrink-0" />
            <input className="bg-transparent text-sm text-soil-800 placeholder-soil-400 outline-none flex-1"
              placeholder="Search items, categories…" />
          </div>
        )}

        <div className="ml-auto flex items-center gap-2">
          {/* Quick nav links */}
          <button onClick={() => onNavigate("sold-donated")}
            className="hidden md:flex items-center gap-1 text-xs font-medium text-soil-500 hover:text-forest-700 hover:bg-forest-50 px-2 py-1.5 rounded-lg transition-colors">
            <Package size={13}/> Sold &amp; Donated
          </button>
          <button onClick={() => onNavigate("collaborations")}
            className="hidden md:flex items-center gap-1 text-xs font-medium text-soil-500 hover:text-forest-700 hover:bg-forest-50 px-2 py-1.5 rounded-lg transition-colors">
            <Users size={13}/> Collaborations
          </button>

          {/* Role pill */}
          <span className={`hidden sm:flex pill border ${cfg.pill} gap-1`}>
            <RoleIcon size={11}/>{cfg.label}
          </span>

          {/* Bell */}
          <button className="relative w-8 h-8 flex items-center justify-center rounded-lg text-soil-500 hover:text-forest-600 hover:bg-forest-50 transition-colors">
            <Bell size={16}/>
            <span className="absolute top-1 right-1 w-2 h-2 rounded-full bg-craft-500 border-2 border-white"/>
          </button>

          {/* Coins */}
          <div className="hidden sm:flex items-center gap-1 bg-forest-50 border border-forest-100 rounded-xl px-2.5 py-1.5 text-xs font-semibold text-forest-700">
            <Leaf size={12}/><span>{coins}</span>
          </div>

          {/* Avatar */}
          <div className={`w-8 h-8 rounded-full ${cfg.avatar} text-white text-xs font-bold flex items-center justify-center cursor-default shadow-sm`}
            title={displayName}>
            {displayName.charAt(0).toUpperCase()}
          </div>

          {/* Logout */}
          <button onClick={onLogout}
            className="hidden sm:flex items-center gap-1 text-xs font-medium text-soil-400 hover:text-red-500 hover:bg-red-50 px-2 py-1.5 rounded-lg transition-colors">
            <LogOut size={13}/> Logout
          </button>

          {/* Mobile hamburger */}
          <button onClick={() => setMobileOpen(!mobileOpen)}
            className="sm:hidden w-8 h-8 flex items-center justify-center rounded-lg text-soil-500">
            {mobileOpen ? <X size={16}/> : <Menu size={16}/>}
          </button>
        </div>
      </div>

      {/* Mobile drawer */}
      {mobileOpen && (
        <div className="sm:hidden bg-white border-t border-soil-100 px-4 py-4 flex flex-col gap-3 animate-slide-up">
          <button onClick={() => { onNavigate("sold-donated"); setMobileOpen(false); }}
            className="flex items-center gap-2 text-sm text-soil-700 hover:text-forest-700">
            <Package size={15}/> Sold &amp; Donated
          </button>
          <button onClick={() => { onNavigate("collaborations"); setMobileOpen(false); }}
            className="flex items-center gap-2 text-sm text-soil-700 hover:text-forest-700">
            <Users size={15}/> Collaborations
          </button>
          <div className="flex items-center justify-between pt-2 border-t border-soil-100">
            <span className={`pill border ${cfg.pill} gap-1`}><RoleIcon size={11}/>{cfg.label}</span>
            <button onClick={onLogout} className="flex items-center gap-1 text-xs text-red-500 font-medium">
              <LogOut size={12}/> Logout
            </button>
          </div>
        </div>
      )}
    </header>
  );
};

export default Navbar;