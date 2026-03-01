// ============================================================
//  ArtistDashboard.js  — Personalised artist dashboard
//  Restricted: My Artworks, My Requests, Available Waste
// ============================================================
import React, { useState } from "react";
import {
  TrendingUp, Award, ShoppingBag, Star, Palette, Plus,
  RefreshCw, Leaf, Package, Eye, Tag, Calendar, Box, HelpCircle
} from "lucide-react";
import DashboardLayout from "../components/layout/DashboardLayout";
import StatCard from "../components/common/StatCard";
import ScrapItemCard from "../components/common/ScrapItemCard";
import UploadForm from "../components/common/UploadForm";
import LoadingSpinner from "../components/common/LoadingSpinner";
import ErrorBanner from "../components/common/ErrorBanner";
import { itemsAPI, usersAPI } from "../services/api";
import { getGreeting, statusClasses, formatINR } from "../utils/helpers";
import useFetch from "../hooks/useFetch";

const CAT_EMOJI = { metal: "🔩", plastic: "🧴", "e-waste": "💡", wood: "🌲", glass: "🪟", paper: "📄", textile: "🧵", ceramic: "🏺", artwork: "🎨", other: "📦" };

const ArtistProfile = ({ profile, stats }) => (
  <div className="card bg-gradient-to-br from-amber-50 to-orange-50 border-amber-200 p-6 mb-8 relative overflow-hidden">
    <div className="absolute top-0 right-0 w-48 h-48 bg-amber-100 rounded-full -translate-y-20 translate-x-20 opacity-30 pointer-events-none" />
    <div className="relative flex flex-wrap items-start gap-5">
      <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-amber-400 to-orange-500 flex items-center justify-center text-white text-2xl font-display font-black shadow-lg shrink-0 overflow-hidden">
        {profile.avatar_url ? <img src={profile.avatar_url} alt="" className="w-full h-full object-cover" /> : profile.name?.[0]?.toUpperCase()}
      </div>
      <div className="flex-1 min-w-0">
        <div className="flex flex-wrap items-center gap-2 mb-1">
          <h2 className="font-display font-black text-xl text-soil-900">{profile.name}</h2>
          <span className="pill bg-amber-100 text-amber-800 border-amber-200 text-[10px] font-bold">🎨 ARTIST</span>
          {profile.is_verified && <span className="pill bg-forest-100 text-forest-700 border border-forest-200 text-[10px]">✓ Verified</span>}
        </div>
        {profile.speciality && <p className="text-sm text-amber-700 font-semibold capitalize mb-1">Speciality: {profile.speciality}</p>}
        {profile.bio && <p className="text-xs text-soil-500 leading-relaxed max-w-lg line-clamp-2">{profile.bio}</p>}
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

const ArtistDashboard = ({ user, onNavigate, onLogout, onNavigateBack }) => {
  const [activeTab, setActiveTab] = useState("my-artworks");
  const [showUpload, setShowUpload] = useState(false);

  const { data: profileData, loading: profileLoading } = useFetch(() => usersAPI.getById(user.id), [user.id]);
  const { data: statsData, loading: statsLoading, refetch: refetchStats } = useFetch(() => usersAPI.getStats(user.id), [user.id]);
  const { data: myItemsData, loading: myItemsLoading, error: myItemsError, refetch: refetchMyItems } = useFetch(() => itemsAPI.getMy(), [user.id]);
  const { data: marketData, loading: marketLoading, error: marketError, refetch: refetchMarket } = useFetch(() => itemsAPI.getAll({ listing_type: "scrap", status: "active", limit: 30 }), []);

  const profile = profileData?.user || user;
  const stats = statsData?.stats;
  const myItems = myItemsData?.items || [];
  const scrapItems = marketData?.items || [];

  const artworks = myItems.filter(i => i.category === "artwork");
  const activeArtworks = artworks.filter(i => i.status === "active");
  const soldArtworks = artworks.filter(i => i.status === "sold");

  // Requests that artist made or received
  const requests = myItems.filter(i => i.status === "pending" && i.category !== "artwork");

  const handleUpload = async (data, files) => {
    await itemsAPI.create({ ...data, category: "artwork" }, files);
    await Promise.all([refetchMyItems(), refetchStats()]);
    setShowUpload(false);
  };

  return (
    <DashboardLayout role="artist" user={user} activeTab={activeTab} onTabChange={setActiveTab} onLogout={onLogout} onNavigate={onNavigate} onNavigateBack={onNavigateBack}>

      <div className="mb-6 flex flex-wrap items-center justify-between gap-3">
        <div>
          <p className="text-soil-400 text-sm font-medium mb-0.5">{getGreeting()}, {user.name?.split(" ")[0]} 🎨</p>
          <h1 className="font-display font-black text-3xl text-soil-900">Artist Studio</h1>
        </div>
      </div>

      {profileLoading ? <div className="card h-28 animate-pulse bg-amber-50 mb-8" /> : <ArtistProfile profile={profile} stats={stats} />}

      {/* Tabs */}
      <div className="flex gap-1 bg-soil-50 border border-soil-200 rounded-2xl p-1 w-fit mb-6">
        {[{ id: "my-artworks", label: "🖼️ My Artworks" }, { id: "requests", label: "📋 My Requests" }, { id: "available-waste", label: "📦 Available Waste" }].map(t => (
          <button key={t.id} onClick={() => setActiveTab(t.id)}
            className={`px-4 py-2 rounded-xl text-sm font-semibold transition-all ${activeTab === t.id ? "bg-amber-500 text-white shadow" : "text-soil-500 hover:text-soil-800"}`}>
            {t.label}
          </button>
        ))}
      </div>

      {activeTab === "my-artworks" && (
        <div className="space-y-6">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <div>
              <h2 className="font-display font-bold text-xl text-soil-900">My Artworks</h2>
              <p className="text-xs text-soil-400 mt-0.5">{activeArtworks.length} active · {soldArtworks.length} sold</p>
            </div>
            <div className="flex gap-2">
              <button onClick={refetchMyItems} className="text-xs text-soil-400 hover:text-amber-600 flex items-center gap-1"><RefreshCw size={12} /> Refresh</button>
              <button onClick={() => setShowUpload(!showUpload)} className="btn-craft text-sm py-2 px-4 flex items-center gap-1.5"><Plus size={14} /> Add Artwork</button>
            </div>
          </div>

          {showUpload && <div className="mb-6"><UploadForm mode="sell" onCancel={() => setShowUpload(false)} onSubmit={handleUpload} /></div>}

          {myItemsLoading ? <LoadingSpinner message="Loading your artworks…" /> : myItemsError ? <ErrorBanner message={myItemsError} /> : artworks.length === 0 ? (
            <div className="card p-16 text-center text-soil-400">
              <Palette size={40} className="mx-auto mb-4 opacity-40" />
              <p className="font-display font-bold text-lg text-soil-700">No artworks yet</p>
              <p className="text-sm mt-2">Publish your first upcycled masterpiece.</p>
            </div>
          ) : (
            <div className="grid gap-3">
              {artworks.map(item => (
                <div key={item.id} className="card p-4 flex items-center gap-4 hover:border-amber-200 transition-all border-soil-100">
                  <div className="w-14 h-14 rounded-2xl bg-amber-50 flex items-center justify-center text-2xl shrink-0 overflow-hidden">
                    {item.images?.[0]?.url ? <img src={item.images[0].url} alt="" className="w-full h-full object-cover" /> : "🎨"}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-soil-900 text-sm">{item.title}</p>
                    <div className="flex flex-wrap items-center gap-2 mt-1 text-[11px] text-soil-400">
                      <span className="flex items-center gap-1"><Calendar size={10} />{new Date(item.created_at).toLocaleDateString()}</span>
                      {item.views > 0 && <span className="flex items-center gap-1"><Eye size={10} />{item.views} views</span>}
                    </div>
                  </div>
                  <div className="text-right shrink-0">
                    {item.price > 0 && <p className="font-display font-bold text-craft-600 text-lg">{formatINR(item.price)}</p>}
                    <span className={`pill border text-[10px] ${statusClasses(item.status)}`}>{item.status}</span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {activeTab === "requests" && (
        <div className="space-y-6">
          <div className="flex items-center justify-between">
            <h2 className="font-display font-bold text-xl text-soil-900">My Requests</h2>
            <button onClick={() => alert("Make request feature coming soon!")} className="btn-outline text-sm py-2 px-4">Make Supply Request</button>
          </div>
          {myItemsLoading ? <LoadingSpinner /> : myItemsError ? <ErrorBanner message={myItemsError} /> : requests.length === 0 ? (
            <div className="card p-16 text-center text-soil-400">
              <HelpCircle size={40} className="mx-auto mb-4 opacity-40" />
              <p className="font-display font-bold text-lg text-soil-700">No active requests</p>
            </div>
          ) : (
            <div className="grid gap-3">
              {requests.map(req => (
                <div key={req.id} className="card p-4 flex items-center justify-between gap-4 border-amber-100">
                  <div>
                    <p className="font-semibold text-soil-900 text-sm">{req.title}</p>
                    <p className="text-[11px] text-soil-400 mt-1 capitalize">{req.category}</p>
                  </div>
                  <span className="pill bg-amber-100 text-amber-800 border-amber-200 text-[10px]">Pending</span>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {activeTab === "available-waste" && (
        <div className="space-y-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="font-display font-bold text-xl text-soil-900">Available Waste Materials</h2>
            <button onClick={refetchMarket} className="text-xs text-soil-400 hover:text-amber-600 flex items-center gap-1"><RefreshCw size={12} /> Refresh</button>
          </div>
          {marketLoading ? <LoadingSpinner message="Loading materials…" /> : marketError ? <ErrorBanner message={marketError} /> : scrapItems.length === 0 ? (
            <div className="card p-16 text-center text-soil-400">
              <Box size={40} className="mx-auto mb-4 opacity-40" />
              <p className="font-display font-bold text-lg text-soil-700">No materials right now</p>
            </div>
          ) : (
            <div className="grid grid-cols-2 sm:grid-cols-3 xl:grid-cols-4 gap-4">
              {scrapItems.map(item => <ScrapItemCard key={item.id} item={item} onBuy={refetchMarket} />)}
            </div>
          )}
        </div>
      )}

    </DashboardLayout>
  );
};

export default ArtistDashboard;
