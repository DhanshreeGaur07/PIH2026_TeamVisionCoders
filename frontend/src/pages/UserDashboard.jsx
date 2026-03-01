// ============================================================
//  UserDashboard.js  — Personalised user dashboard
//  Restricted to: Selling Waste, Donating Items, Buying/Req Crafts
// ============================================================
import React, { useState } from "react";
import {
  Package, TrendingUp, Heart, Leaf, Eye, Plus,
  RefreshCw, ShoppingBag, ExternalLink, Users, MapPin, Calendar,
  Tag, User
} from "lucide-react";
import DashboardLayout from "../components/layout/DashboardLayout";
import StatCard from "../components/common/StatCard";
import UploadForm from "../components/common/UploadForm";
import LoadingSpinner from "../components/common/LoadingSpinner";
import ErrorBanner from "../components/common/ErrorBanner";
import { itemsAPI, usersAPI } from "../services/api";
import { getGreeting, statusClasses, formatINR } from "../utils/helpers";
import useFetch from "../hooks/useFetch";

const CAT_EMOJI = { metal: "🔩", plastic: "🧴", "e-waste": "💡", wood: "🌲", glass: "🪟", paper: "📄", textile: "🧵", ceramic: "🏺", artwork: "🎨", other: "📦" };

const UserProfile = ({ profile, stats }) => (
  <div className="card bg-gradient-to-br from-forest-50 to-teal-50 border-forest-200 p-6 mb-8 relative overflow-hidden">
    <div className="absolute top-0 right-0 w-48 h-48 bg-forest-100 rounded-full -translate-y-20 translate-x-20 opacity-30 pointer-events-none" />
    <div className="relative flex flex-wrap items-start gap-5">
      <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-forest-500 to-teal-600 flex items-center justify-center text-white text-2xl font-display font-black shadow-lg shrink-0 overflow-hidden">
        {profile.avatar_url ? <img src={profile.avatar_url} alt="" className="w-full h-full object-cover" /> : profile.name?.[0]?.toUpperCase()}
      </div>
      <div className="flex-1 min-w-0">
        <div className="flex flex-wrap items-center gap-2 mb-1">
          <h2 className="font-display font-black text-xl text-soil-900">{profile.name}</h2>
          <span className="pill bg-forest-100 text-forest-800 border-forest-200 text-[10px] font-bold">👤 USER</span>
          {profile.is_verified && <span className="pill bg-teal-100 text-teal-700 border border-teal-200 text-[10px]">✓ Verified</span>}
        </div>
        {profile.email && <p className="text-xs text-soil-500 mb-1">{profile.email}</p>}
        <div className="flex flex-wrap items-center gap-3 mt-1 text-[11px] text-soil-400">
          {profile.city && <span className="flex items-center gap-1"><MapPin size={10} />{profile.city}, {profile.state}</span>}
          {profile.created_at && <span className="flex items-center gap-1"><Calendar size={10} />Joined {new Date(profile.created_at).toLocaleDateString("en-IN", { month: "short", year: "numeric" })}</span>}
        </div>
      </div>
      <div className="shrink-0">
        <div className="inline-flex items-center gap-2 bg-forest-700 text-white rounded-2xl px-4 py-2.5 shadow-md">
          <Leaf size={16} />
          <div>
            <p className="font-display font-black text-xl leading-none">{profile.green_coins ?? 0}</p>
            <p className="text-forest-200 text-[10px]">Green Coins</p>
          </div>
        </div>
      </div>
    </div>
  </div>
);

const ItemRow = ({ item }) => (
  <div className="card p-4 flex items-center gap-4 hover:border-forest-200 transition-all border-soil-100">
    <div className="w-12 h-12 rounded-xl bg-soil-50 flex items-center justify-center text-2xl shrink-0 overflow-hidden">
      {item.images?.[0]?.url ? <img src={item.images[0].url} alt="" className="w-full h-full object-cover" /> : CAT_EMOJI[item.category] || "📦"}
    </div>
    <div className="flex-1 min-w-0">
      <p className="font-semibold text-soil-900 text-sm truncate">{item.title}</p>
      <div className="flex flex-wrap items-center gap-2 mt-1 text-[11px] text-soil-400">
        <span className="flex items-center gap-1 capitalize"><Tag size={10} />{item.category}</span>
        <span>·</span>
        <span className="flex items-center gap-1"><Calendar size={10} />{new Date(item.created_at).toLocaleDateString()}</span>
      </div>
    </div>
    <div className="flex items-center gap-2 shrink-0">
      {item.price > 0 && <span className="font-display font-bold text-craft-600">{formatINR(item.price)}</span>}
      <span className={`pill border text-[10px] ${statusClasses(item.status)}`}>{item.status}</span>
    </div>
  </div>
);

const UserDashboard = ({ user, onNavigate, onLogout, onNavigateBack }) => {
  const [activeTab, setActiveTab] = useState("sell");
  const [showSellForm, setShowSellForm] = useState(false);
  const [showDonateForm, setShowDonateForm] = useState(false);

  const { data: profileData, loading: profileLoading } = useFetch(() => usersAPI.getById(user.id), [user.id]);
  const { data: statsData, loading: statsLoading, refetch: refetchStats } = useFetch(() => usersAPI.getStats(user.id), [user.id]);
  const { data: myItemsData, loading: myItemsLoading, error: myItemsError, refetch: refetchMyItems } = useFetch(() => itemsAPI.getMy(), [user.id]);

  // Platform-wide artworks for "buy-request"
  const { data: artworksData, loading: artworksLoading, error: artworksError, refetch: refetchArtworks } = useFetch(() => itemsAPI.getAll({ category: "artwork", status: "active", limit: 24 }), []);

  const profile = profileData?.user || user;
  const stats = statsData?.stats;
  const myItems = myItemsData?.items || [];
  const artworks = artworksData?.items || [];

  const sellItems = myItems.filter(i => i.status !== "donated" && (!i.listing_type || i.listing_type === "scrap"));
  const donatedItems = myItems.filter(i => i.status === "donated" || i.listing_type === "donation");

  const handleFormSubmit = async (data, files) => {
    await itemsAPI.create(data, files);
    await Promise.all([refetchMyItems(), refetchStats()]);
    setShowSellForm(false);
    setShowDonateForm(false);
  };

  return (
    <DashboardLayout role="user" user={user} activeTab={activeTab} onTabChange={setActiveTab} onLogout={onLogout} onNavigate={onNavigate} onNavigateBack={onNavigateBack}>

      <div className="mb-6 flex flex-wrap items-center justify-between gap-3">
        <div>
          <p className="text-soil-400 text-sm font-medium mb-0.5">{getGreeting()}, {user.name?.split(" ")[0]} 👤</p>
          <h1 className="font-display font-black text-3xl text-soil-900">User Dashboard</h1>
        </div>
        <button onClick={refetchMyItems} className="btn-outline text-sm py-2 px-4 flex items-center gap-1.5"><RefreshCw size={14} /> Refresh</button>
      </div>

      {profileLoading ? <div className="card h-28 animate-pulse bg-forest-50 mb-8" /> : <UserProfile profile={profile} stats={stats} />}

      {/* Tabs */}
      <div className="flex gap-1 bg-soil-50 border border-soil-200 rounded-2xl p-1 w-fit mb-6">
        {[{ id: "sell", label: "📦 Sell Waste" }, { id: "donate", label: "🤝 Donate Items" }, { id: "buy-request", label: "🛒 Buy/Req Crafts" }].map(t => (
          <button key={t.id} onClick={() => setActiveTab(t.id)}
            className={`px-4 py-2 rounded-xl text-sm font-semibold transition-all ${activeTab === t.id ? "bg-forest-600 text-white shadow" : "text-soil-500 hover:text-soil-800"}`}>
            {t.label}
          </button>
        ))}
      </div>

      {activeTab === "sell" && (
        <div className="space-y-6">
          <div className="flex items-center justify-between">
            <h2 className="font-display font-bold text-xl text-soil-900">Sell Waste Materials</h2>
            <button onClick={() => setShowSellForm(!showSellForm)} className="btn-primary text-sm py-2 px-4 shadow-sm"><Plus size={14} /> Add Scrap Listing</button>
          </div>

          {showSellForm && <div className="mb-6"><UploadForm mode="sell" onCancel={() => setShowSellForm(false)} onSubmit={handleFormSubmit} /></div>}

          {myItemsLoading ? <LoadingSpinner message="Loading your sales…" /> : myItemsError ? <ErrorBanner message={myItemsError} /> : sellItems.length === 0 ? (
            <div className="card p-16 text-center text-soil-400">
              <Package size={36} className="mx-auto mb-3 opacity-40" />
              <p className="font-semibold text-lg">No active sales.</p>
              <p className="text-sm mt-1">Start turning your waste into worth.</p>
            </div>
          ) : (
            <div className="grid gap-3">{sellItems.map(item => <ItemRow key={item.id} item={item} />)}</div>
          )}
        </div>
      )}

      {activeTab === "donate" && (
        <div className="space-y-6">
          <div className="flex items-center justify-between">
            <h2 className="font-display font-bold text-xl text-soil-900">Donate Items</h2>
            <button onClick={() => setShowDonateForm(!showDonateForm)} className="btn-primary text-sm py-2 px-4 shadow-sm"><Plus size={14} /> Make Donation</button>
          </div>

          {showDonateForm && <div className="mb-6"><UploadForm mode="donate" onCancel={() => setShowDonateForm(false)} onSubmit={handleFormSubmit} /></div>}

          {myItemsLoading ? <LoadingSpinner message="Loading donations…" /> : myItemsError ? <ErrorBanner message={myItemsError} /> : donatedItems.length === 0 ? (
            <div className="card p-16 text-center text-soil-400">
              <Heart size={36} className="mx-auto mb-3 opacity-40" />
              <p className="font-semibold text-lg">No donations yet.</p>
              <p className="text-sm mt-1">Donate your scrap to earn Green Coins.</p>
            </div>
          ) : (
            <div className="grid gap-3">{donatedItems.map(item => <ItemRow key={item.id} item={item} />)}</div>
          )}
        </div>
      )}

      {activeTab === "buy-request" && (
        <div className="space-y-6">
          <div className="flex items-center justify-between">
            <h2 className="font-display font-bold text-xl text-soil-900">Buy &amp; Request Crafts</h2>
            <div className="flex gap-2">
              <button onClick={() => alert("Request feature coming soon!")} className="btn-outline text-sm py-2 px-4 shadow-sm">✉️ Request Custom Craft</button>
              <button onClick={refetchArtworks} className="text-sm text-soil-400 hover:text-forest-600"><RefreshCw size={14} /></button>
            </div>
          </div>
          <p className="text-soil-500 text-sm mb-4">Discover beautiful artworks and functional items made entirely from upcycled waste by our verified artists.</p>

          {artworksLoading ? <LoadingSpinner message="Loading crafts…" /> : artworksError ? <ErrorBanner message={artworksError} /> : artworks.length === 0 ? (
            <div className="card p-16 text-center text-soil-400">
              <ShoppingBag size={36} className="mx-auto mb-3 opacity-40" />
              <p className="font-semibold text-lg">No crafts available.</p>
            </div>
          ) : (
            <div className="grid grid-cols-2 sm:grid-cols-3 xl:grid-cols-4 gap-4">
              {artworks.map(item => (
                <div key={item.id} className="card overflow-hidden group hover:shadow-lg transition-all border-soil-100 flex flex-col">
                  <div className="h-32 bg-soil-50 border-b border-soil-100 flex items-center justify-center text-5xl">
                    {item.images?.[0]?.url ? <img src={item.images[0].url} alt="" className="w-full h-full object-cover group-hover:scale-105 transition-transform" /> : CAT_EMOJI[item.category] || "🎨"}
                  </div>
                  <div className="p-3 flex-1 flex flex-col">
                    <p className="font-semibold text-soil-900 text-sm truncate">{item.title}</p>
                    <p className="text-xs text-soil-400 mt-1 capitalize">{item.category} · {item.seller_name}</p>
                    <div className="flex items-center justify-between mt-auto pt-2">
                      <span className="font-display font-bold text-forest-700">{formatINR(item.price)}</span>
                      <button onClick={() => onNavigate("artwork-detail", { artworkId: item.id })} className="text-xs text-forest-600 font-semibold hover:underline">View →</button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

    </DashboardLayout>
  );
};

export default UserDashboard;
