// ============================================================
//  Sidebar.js  —  Role-specific left navigation
// ============================================================
import React from "react";
import {
  Layout, ShoppingBag, Palette, Package,
  Truck, Settings, HelpCircle, Leaf, BarChart2,
  Heart, Box, Users
} from "lucide-react";

const NAV_ITEMS = {
  artist: [
    { id: "my-artworks", icon: Palette, label: "My Artworks" },
    { id: "requests", icon: Package, label: "My Requests" },
    { id: "available-waste", icon: Box, label: "Available Waste" },
  ],
  user: [
    { id: "sell", icon: Package, label: "Sell Waste" },
    { id: "donate", icon: Heart, label: "Donate Items" },
    { id: "buy-request", icon: ShoppingBag, label: "Buy/Req Crafts" },
  ],
  helper: [
    { id: "pickup-delivery", icon: Truck, label: "Pickup & Delivery" },
    { id: "transported", icon: Recycle, label: "Waste Transported" },
  ],
  organisation: [
    { id: "waste-utilised", icon: BarChart2, label: "Waste Utilised" },
    { id: "requests-status", icon: HelpCircle, label: "Requests Status" },
  ],
};

const SHARED_ITEMS = [];

const Sidebar = ({ role, activeTab, onTabChange, onNavigate }) => {
  const items = NAV_ITEMS[role] || NAV_ITEMS.user;

  const activeStyle = {
    artist: "bg-amber-50  text-amber-800  border-amber-200",
    user: "bg-forest-50 text-forest-800 border-forest-200",
    helper: "bg-teal-50   text-teal-800   border-teal-200",
    organisation: "bg-indigo-50 text-indigo-800 border-indigo-200",
  }[role] || "bg-forest-50 text-forest-800";

  const btnClass = (isActive) =>
    `w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all text-left ${isActive
      ? `${activeStyle} border font-semibold`
      : "text-soil-600 hover:bg-soil-50 hover:text-soil-900 border border-transparent"
    }`;

  return (
    <aside className="hidden lg:flex flex-col w-56 shrink-0 border-r border-soil-100 bg-white/80 backdrop-blur min-h-full py-6 px-3 gap-1">

      {/* Role-specific navigation */}
      <p className="px-3 py-1 text-[10px] font-bold text-soil-400 uppercase tracking-widest mb-1">Dashboard</p>
      {items.map(({ id, icon: Icon, label }) => (
        <button key={id} onClick={() => onTabChange(id)}
          className={btnClass(activeTab === id)}
          aria-current={activeTab === id ? "page" : undefined}>
          <Icon size={16} strokeWidth={activeTab === id ? 2.5 : 2} />{label}
        </button>
      ))}

      {/* Shared pages */}
      {SHARED_ITEMS.length > 0 && (
        <>
          <div className="my-3 border-t border-soil-100" />
          <p className="px-3 py-1 text-[10px] font-bold text-soil-400 uppercase tracking-widest mb-1">Platform</p>
          {SHARED_ITEMS.map(({ id, icon: Icon, label, page }) => (
            <button key={id} onClick={() => onNavigate(page)}
              className={btnClass(activeTab === id)}>
              <Icon size={16} strokeWidth={2} />{label}
            </button>
          ))}
        </>
      )}

      {/* Help */}
      <div className="mt-auto pt-4 border-t border-soil-100">
        <button className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm text-soil-400 hover:text-soil-700 hover:bg-soil-50 transition-colors text-left">
          <HelpCircle size={16} /> Help &amp; Support
        </button>
      </div>
    </aside>
  );
};

export default Sidebar;
