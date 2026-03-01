import React, { useState } from "react";
import {
  Package, TrendingUp, Heart, Leaf, Eye, Plus,
  RefreshCw, ShoppingBag, ExternalLink, Users, MapPin, Calendar,
  Tag, User
} from "lucide-react";
import DashboardLayout from "../components/layout/DashboardLayout";
import StatCard        from "../components/common/StatCard";
import UploadForm      from "../components/common/UploadForm";
import LoadingSpinner  from "../components/common/LoadingSpinner";
import ErrorBanner     from "../components/common/ErrorBanner";
import { itemsAPI, usersAPI } from "../services/api";
import { getGreeting, statusClasses, formatINR } from "../utils/helpers";
import useFetch from "../hooks/useFetch";

const CAT_EMOJI = { metal:"🔩",plastic:"🧴","e-waste":"💡",wood:"🌲",glass:"🪟",paper:"📄",textile:"🧵",ceramic:"🏺",artwork:"🎨",other:"📦" };

/* ── User profile card ── */
const UserProfile = ({ profile, stats }) => (
  <div className="card bg-gradient-to-br from-forest-50 to-teal-50 border-forest-200 p-6 mb-8 relative overflow-hidden">
    <div className="absolute top-0 right-0 w-48 h-48 bg-forest-100 rounded-full -translate-y-20 translate-x-20 opacity-30 pointer-events-none" />
    <div className="relative flex items-start gap-5 flex-wrap">
      <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-forest-500 to-teal-600 flex items-center justify-center text-white text-2xl font-display font-black shadow-lg shrink-0 overflow-hidden">
        {profile.avatar_url ? <img src={profile.avatar_url} alt="" className="w-full h-full object-cover"/> : profile.name?.[0]?.toUpperCase()}
      </div>
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2 mb-1 flex-wrap">
          <h2 className="font-display font-black text-xl text-soil-900">{profile.name}</h2>
          <span className="pill bg-forest-100 text-forest-800 border border-forest-200 text-[10px] font-bold">👤 USER</span>
          {profile.is_verified && <span className="pill bg-teal-100 text-teal-700 border border-teal-200 text-[10px]">✓ Verified</span>}
        </div>
        {profile.email && <p className="text-xs text-soil-500 mb-1">{profile.email}</p>}
        <div className="flex items-center gap-3 mt-1 flex-wrap text-[11px] text-soil-400">
          {profile.city && <span className="flex items-center gap-1"><MapPin size={10}/>{profile.city}, {profile.state}</span>}
          {profile.created_at && <span className="flex items-center gap-1"><Calendar size={10}/>Joined {new Date(profile.created_at).toLocaleDateString("en-IN",{month:"short",year:"numeric"})}</span>}
          {profile.phone && <span className="flex items-center gap-1"><User size={10}/>{profile.phone}</span>}
        </div>
      </div>
      <div className="shrink-0">
        <div className="inline-flex items-center gap-2 bg-forest-700 text-white rounded-2xl px-4 py-2.5 shadow-md">
          <Leaf size={16}/>
          <div>
            <p className="font-display font-black text-xl leading-none">{profile.green_coins ?? 0}</p>
            <p className="text-forest-200 text-[10px]">Green Coins</p>
          </div>
        </div>
      </div>
    </div>
  </div>
);

/* ── Item list row ── */
const ItemRow = ({ item }) => (
  <div className="card p-4 flex items-center gap-4 hover:border-forest-200 hover:shadow-md transition-all">
    <div className="w-12 h-12 rounded-xl bg-soil-50 border border-soil-100 flex items-center justify-center text-2xl shrink-0 overflow-hidden">
      {item.images?.[0]?.url ? <img src={item.images[0].url} alt="" className="w-full h-full object-cover rounded-xl"/> : CAT_EMOJI[item.category]||"📦"}
    </div>
    <div className="flex-1 min-w-0">
      <p className="font-semibold text-soil-900 text-sm truncate">{item.title}</p>
      <div className="flex items-center gap-2 mt-1 flex-wrap text-[11px] text-soil-400">
        <span className="flex items-center gap-1 capitalize"><Tag size={10}/>{item.category}</span>
        <span>·</span>
        <span className="flex items-center gap-1"><Calendar size={10}/>{new Date(item.created_at).toLocaleDateString("en-IN",{day:"numeric",month:"short"})}</span>
        {item.views > 0 && <><span>·</span><span className="flex items-center gap-1"><Eye size={10}/>{item.views} views</span></>}
        {item.buyer_name && <><span>·</span><span className="text-forest-600 font-medium">→ {item.buyer_name}</span></>}
      </div>
    </div>
    <div className="flex items-center gap-2 shrink-0">
      {item.price > 0 && <span className="font-display font-bold text-craft-600">{formatINR(item.price)}</span>}
      <span className={`pill border text-[10px] ${statusClasses(item.status)}`}>{item.status}</span>
    </div>
  </div>
);

/* ── Main ── */
const UserDashboard = ({ user, onNavigate, onLogout }) => {
  const [activeTab, setActiveTab] = useState("dashboard");
  const [formMode,  setFormMode]  = useState(null); // "sell" | "donate"

  // Only this user's profile
  const { data: profileData, loading: profileLoading } =
    useFetch(() => usersAPI.getById(user.id), [user.id]);

  // Only this user's stats
  const { data: statsData, loading: statsLoading, refetch: refetchStats } =
    useFetch(() => usersAPI.getStats(user.id), [user.id]);

  // Only this user's own listings (backend enforces auth — /api/items/my)
  const { data: myItemsData, loading: myItemsLoading, error: myItemsError, refetch: refetchMyItems } =
    useFetch(() => itemsAPI.getMy(), [user.id]);

  // Platform-wide browse
  const { data: marketData, loading: marketLoading, error: marketError, refetch: refetchMarket } =
    useFetch(() => itemsAPI.getAll({ status:"active", limit:20 }), []);

  const profile  = profileData?.user || user;
  const stats    = statsData?.stats;
  const myItems  = myItemsData?.items || [];
  const allItems = marketData?.items  || [];

  const soldItems    = myItems.filter(i => i.status === "sold");
  const donatedItems = myItems.filter(i => i.status === "donated");
  const activeItems  = myItems.filter(i => i.status === "active");

  const handleFormSubmit = async (data, files) => {
    await itemsAPI.create(data, files);
    await Promise.all([refetchMyItems(), refetchStats()]);
    setFormMode(null);
  };

  const actions = [
    { id:"sell",   emoji:"💰", label:"Sell Item",    desc:"Earn from unused items",     cls:"from-amber-50 to-craft-50 border-amber-200 hover:border-amber-400 text-amber-700" },
    { id:"browse", emoji:"🛒", label:"Browse Items", desc:"Discover upcycled goods",    cls:"from-forest-50 to-teal-50 border-forest-200 hover:border-forest-400 text-forest-700" },
    { id:"donate", emoji:"🤝", label:"Donate Item",  desc:"Give freely, earn coins",    cls:"from-rose-50 to-pink-50 border-rose-200 hover:border-rose-400 text-rose-700" },
  ];

  return (
    <DashboardLayout role="user" user={user} activeTab={activeTab}
      onTabChange={setActiveTab} onLogout={onLogout} onNavigate={onNavigate}>

      {/* Welcome */}
      <div className="mb-6 flex items-center justify-between flex-wrap gap-3">
        <div>
          <p className="text-soil-400 text-sm font-medium mb-0.5">{getGreeting()}, {user.name?.split(" ")[0]} 👤</p>
          <h1 className="font-display font-black text-3xl text-soil-900">My Dashboard</h1>
        </div>
        <div className="flex gap-2 flex-wrap">
          <button onClick={() => onNavigate("sold-donated")} className="btn-outline text-sm py-2 px-4 flex items-center gap-1.5">
            <Package size={14}/> Sold &amp; Donated
          </button>
          <button onClick={() => onNavigate("collaborations")} className="btn-outline text-sm py-2 px-4 flex items-center gap-1.5">
            <Users size={14}/> Collaborations
          </button>
        </div>
      </div>

      {/* User profile card (personalised) */}
      {profileLoading
        ? <div className="card h-28 animate-pulse bg-forest-50 mb-8"/>
        : <UserProfile profile={profile} stats={stats}/>
      }

      {/* Stats */}
      {statsLoading
        ? <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">{[...Array(4)].map((_,i) => <div key={i} className="card h-28 animate-pulse bg-soil-50"/>)}</div>
        : <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
            <StatCard icon={Package}    label="My Listings"  value={stats?.total_listings || myItems.length}   sub="Total"       accent="green"/>
            <StatCard icon={TrendingUp} label="Items Sold"   value={stats?.sold  || soldItems.length}          sub="All Time"    accent="amber"/>
            <StatCard icon={Heart}      label="Donated"      value={stats?.donated || donatedItems.length}     sub="All Time"    accent="rose"/>
            <StatCard icon={Leaf}       label="Green Coins"  value={stats?.green_coins ?? profile.green_coins ?? 0} sub="Balance" accent="teal"/>
          </div>
      }

      {/* Tabs */}
      <div className="flex gap-1 bg-soil-50 border border-soil-200 rounded-2xl p-1 w-fit mb-6">
        {[{id:"dashboard",label:"🏠 Overview"},{id:"listings",label:"📦 My Listings"},{id:"browse",label:"🛒 Browse"}].map(t => (
          <button key={t.id} onClick={() => setActiveTab(t.id)}
            className={`px-4 py-2 rounded-xl text-sm font-semibold transition-all ${activeTab===t.id?"bg-forest-600 text-white shadow":"text-soil-500 hover:text-soil-800"}`}>
            {t.label}
          </button>
        ))}
      </div>

      {/* OVERVIEW */}
      {activeTab === "dashboard" && (
        <>
          {/* 3 Action buttons */}
          <div className="grid grid-cols-3 gap-4 mb-8">
            {actions.map(a => (
              <button key={a.id}
                onClick={() => {
                  if (a.id==="sell"||a.id==="donate") setFormMode(formMode===a.id?null:a.id);
                  else setActiveTab("browse");
                }}
                className={`p-5 sm:p-6 rounded-3xl border-2 bg-gradient-to-br text-left transition-all hover:-translate-y-1 hover:shadow-md ${a.cls} ${formMode===a.id?"ring-2 ring-offset-2 ring-forest-400":""}`}>
                <div className="text-3xl sm:text-4xl mb-3">{a.emoji}</div>
                <p className="font-display font-bold text-sm sm:text-base">{a.label}</p>
                <p className="text-soil-500 text-xs mt-0.5 hidden sm:block">{a.desc}</p>
              </button>
            ))}
          </div>

          {formMode && (
            <div className="mb-8">
              <UploadForm mode={formMode} onCancel={() => setFormMode(null)} onSubmit={handleFormSubmit}/>
            </div>
          )}

          {/* Recent activity (only this user's items) */}
          <div className="flex items-center justify-between mb-3">
            <h2 className="font-display font-bold text-lg text-soil-900">Recent Activity</h2>
            <button onClick={() => onNavigate("sold-donated")} className="text-xs text-forest-600 hover:underline font-medium flex items-center gap-1">
              View all sold &amp; donated →
            </button>
          </div>
          {myItemsLoading ? <LoadingSpinner/>
            : myItems.length === 0
            ? <ErrorBanner variant="empty" message="No activity yet. Sell or donate your first item!"/>
            : <div className="space-y-3">
                {myItems.slice(0,5).map(item => <ItemRow key={item.id} item={item}/>)}
                {myItems.length > 5 && (
                  <button onClick={() => setActiveTab("listings")} className="w-full text-xs text-soil-400 hover:text-forest-600 py-3 text-center">
                    View all {myItems.length} listings →
                  </button>
                )}
              </div>
          }

          {/* Quick links */}
          <div className="grid grid-cols-2 gap-3 mt-8">
            {[
              { label:"Sold & Donated Board", page:"sold-donated",   icon:Package, cls:"from-amber-50 to-orange-50 border-amber-200 text-amber-700" },
              { label:"Our Collaborations",   page:"collaborations", icon:Users,    cls:"from-forest-50 to-teal-50 border-forest-200 text-forest-700" },
            ].map(({ label, page, icon:Icon, cls }) => (
              <button key={page} onClick={() => onNavigate(page)}
                className={`card p-5 bg-gradient-to-br ${cls} border flex items-center justify-between hover:shadow-md transition-all group`}>
                <span className="font-semibold text-sm flex items-center gap-2"><Icon size={16}/>{label}</span>
                <ExternalLink size={16} className="opacity-50 group-hover:opacity-100 shrink-0"/>
              </button>
            ))}
          </div>
        </>
      )}

      {/* MY LISTINGS */}
      {activeTab === "listings" && (
        <>
          <div className="flex items-center justify-between mb-5 flex-wrap gap-3">
            <div>
              <h2 className="font-display font-bold text-xl text-soil-900">My Listings</h2>
              <p className="text-xs text-soil-400 mt-0.5">{activeItems.length} active · {soldItems.length} sold · {donatedItems.length} donated</p>
            </div>
            <div className="flex gap-2">
              <button onClick={refetchMyItems} className="text-xs text-soil-400 hover:text-forest-600 flex items-center gap-1"><RefreshCw size={12}/> Refresh</button>
              <button onClick={() => setFormMode("sell")} className="btn-outline text-xs py-1.5 px-3"><Plus size={12}/> Add</button>
            </div>
          </div>
          {formMode && <div className="mb-6"><UploadForm mode={formMode} onCancel={() => setFormMode(null)} onSubmit={handleFormSubmit}/></div>}

          {myItemsLoading ? <LoadingSpinner message="Loading your listings…"/>
            : myItemsError ? <ErrorBanner message={myItemsError} onRetry={refetchMyItems}/>
            : myItems.length === 0
            ? <div className="card p-16 text-center text-soil-400">
                <Package size={36} className="mx-auto mb-3 opacity-40"/>
                <p className="font-semibold text-lg">No listings yet.</p>
                <p className="text-sm mt-1">Click "Sell Item" to list your first item.</p>
              </div>
            : <div className="space-y-3">{myItems.map(item => <ItemRow key={item.id} item={item}/>)}</div>
          }
        </>
      )}

      {/* BROWSE */}
      {activeTab === "browse" && (
        <>
          <div className="flex items-center justify-between mb-4">
            <h2 className="font-display font-bold text-xl text-soil-900">Browse Available Items</h2>
            <button onClick={refetchMarket} className="text-xs text-soil-400 hover:text-forest-600 flex items-center gap-1"><RefreshCw size={12}/> Refresh</button>
          </div>
          {marketLoading ? <LoadingSpinner message="Loading items…"/>
            : marketError ? <ErrorBanner message={marketError} onRetry={refetchMarket}/>
            : allItems.length === 0 ? <ErrorBanner variant="empty" message="No active items right now."/>
            : <div className="grid grid-cols-2 sm:grid-cols-3 xl:grid-cols-4 gap-4">
                {allItems.map(item => (
                  <div key={item.id} className="card overflow-hidden group hover:shadow-lg transition-all">
                    <div className="h-28 bg-soil-50 border-b border-soil-100 flex items-center justify-center text-4xl overflow-hidden">
                      {item.images?.[0]?.url ? <img src={item.images[0].url} alt="" className="w-full h-full object-cover"/> : CAT_EMOJI[item.category]||"📦"}
                    </div>
                    <div className="p-3">
                      <p className="font-semibold text-soil-900 text-sm truncate">{item.title}</p>
                      <p className="text-xs text-soil-400 mt-1 capitalize">{item.category} · {item.seller_name}</p>
                      <div className="flex items-center justify-between mt-2">
                        <span className="font-display font-bold text-forest-700">{item.price > 0 ? formatINR(item.price) : "Free"}</span>
                        <span className={`pill border text-[10px] ${statusClasses(item.listing_type)}`}>{item.listing_type}</span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
          }
        </>
      )}
    </DashboardLayout>
  );
};

export default UserDashboard;