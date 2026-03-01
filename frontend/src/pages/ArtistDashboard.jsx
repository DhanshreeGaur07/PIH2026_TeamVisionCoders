import React, { useState } from "react";
import {
  TrendingUp, Award, ShoppingBag, Star, Palette, Plus,
  RefreshCw, Leaf, Package, Eye, Users,
  Calendar, Tag, ExternalLink
} from "lucide-react";
import DashboardLayout from "../components/layout/DashboardLayout";
import StatCard        from "../components/common/StatCard";
import ScrapItemCard   from "../components/common/ScrapItemCard";
import UploadForm      from "../components/common/UploadForm";
import LoadingSpinner  from "../components/common/LoadingSpinner";
import ErrorBanner     from "../components/common/ErrorBanner";
import { itemsAPI, usersAPI } from "../services/api";
import { getGreeting, statusClasses, formatINR } from "../utils/helpers";
import useFetch from "../hooks/useFetch";

const CATEGORIES = ["all","metal","plastic","e-waste","wood","paper","textile","glass","ceramic","artwork","other"];
const CAT_EMOJI  = { metal:"🔩",plastic:"🧴","e-waste":"💡",wood:"🌲",glass:"🪟",paper:"📄",textile:"🧵",ceramic:"🏺",artwork:"🎨",other:"📦" };

/* ── Personalised profile card (only this artist's own data) ── */
const ArtistProfile = ({ profile, stats }) => (
  <div className="card bg-gradient-to-br from-amber-50 to-orange-50 border-amber-200 p-6 mb-8 relative overflow-hidden">
    <div className="absolute top-0 right-0 w-48 h-48 bg-amber-100 rounded-full -translate-y-20 translate-x-20 opacity-30 pointer-events-none" />
    <div className="relative flex items-start gap-5 flex-wrap">
      {/* Avatar */}
      <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-amber-400 to-orange-500 flex items-center justify-center text-white text-2xl font-display font-black shadow-lg shrink-0 overflow-hidden">
        {profile.avatar_url
          ? <img src={profile.avatar_url} alt="" className="w-full h-full object-cover"/>
          : profile.name?.[0]?.toUpperCase()}
      </div>
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2 mb-1 flex-wrap">
          <h2 className="font-display font-black text-xl text-soil-900">{profile.name}</h2>
          <span className="pill bg-amber-100 text-amber-800 border border-amber-200 text-[10px] font-bold">🎨 ARTIST</span>
          {profile.is_verified && <span className="pill bg-forest-100 text-forest-700 border border-forest-200 text-[10px]">✓ Verified</span>}
        </div>
        {(profile.speciality) && <p className="text-sm text-amber-700 font-semibold capitalize mb-1">Speciality: {profile.speciality}</p>}
        {profile.bio && <p className="text-xs text-soil-500 leading-relaxed max-w-lg line-clamp-2">{profile.bio}</p>}
        <div className="flex items-center gap-3 mt-2 flex-wrap text-[11px] text-soil-400">
          {profile.city && <span>📍 {profile.city}, {profile.state}</span>}
          {profile.created_at && <span>🗓 Joined {new Date(profile.created_at).toLocaleDateString("en-IN",{month:"short",year:"numeric"})}</span>}
          {stats?.role_stats?.rating > 0 && <span className="text-amber-600 font-semibold">⭐ {stats.role_stats.rating} ({stats.role_stats.rating_count} reviews)</span>}
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

/* ── Main ── */
const ArtistDashboard = ({ user, onNavigate, onLogout }) => {
  const [activeTab,  setActiveTab]  = useState("marketplace");
  const [catFilter,  setCatFilter]  = useState("all");
  const [showUpload, setShowUpload] = useState(false);

  // Only this artist's profile
  const { data: profileData, loading: profileLoading } =
    useFetch(() => usersAPI.getById(user.id), [user.id]);

  // Only this artist's stats
  const { data: statsData, loading: statsLoading, refetch: refetchStats } =
    useFetch(() => usersAPI.getStats(user.id), [user.id]);

  // Only this artist's own uploaded items (API enforces auth)
  const { data: myItemsData, loading: myItemsLoading, error: myItemsError, refetch: refetchMyItems } =
    useFetch(() => itemsAPI.getMy(), [user.id]);

  // Platform-wide scrap marketplace
  const { data: marketData, loading: marketLoading, error: marketError, refetch: refetchMarket } =
    useFetch(
      () => itemsAPI.getAll({ listing_type:"scrap", status:"active", limit:24, ...(catFilter!=="all"?{category:catFilter}:{}) }),
      [catFilter]
    );

  const profile    = profileData?.user || user;
  const stats      = statsData?.stats;
  const myItems    = myItemsData?.items || [];
  const scrapItems = marketData?.items  || [];

  const soldItems    = myItems.filter(i => i.status === "sold");
  const activeItems  = myItems.filter(i => i.status === "active");
  const donatedItems = myItems.filter(i => i.status === "donated");

  const handleUpload = async (data, files) => {
    await itemsAPI.create(data, files);
    await Promise.all([refetchMyItems(), refetchStats()]);
    setShowUpload(false);
  };

  return (
    <DashboardLayout role="artist" user={user} activeTab={activeTab}
      onTabChange={setActiveTab} onLogout={onLogout} onNavigate={onNavigate}>

      {/* Welcome bar */}
      <div className="mb-6 flex items-center justify-between flex-wrap gap-3">
        <div>
          <p className="text-soil-400 text-sm font-medium mb-0.5">{getGreeting()}, {user.name?.split(" ")[0]} 🎨</p>
          <h1 className="font-display font-black text-3xl text-soil-900">Artist Studio</h1>
        </div>
        <div className="flex gap-2 flex-wrap">
          <button onClick={() => onNavigate("sold-donated")} className="btn-outline text-sm py-2 px-4 flex items-center gap-1.5">
            <Package size={14}/> Sold &amp; Donated
          </button>
          <button onClick={() => onNavigate("collaborations")} className="btn-outline text-sm py-2 px-4 flex items-center gap-1.5">
            <Users size={14}/> Collaborations
          </button>
          <button onClick={() => setShowUpload(v => !v)} className="btn-craft text-sm py-2.5 px-5 flex items-center gap-1.5">
            <Plus size={14}/> New Listing
          </button>
        </div>
      </div>

      {/* Upload form */}
      {showUpload && (
        <div className="mb-8">
          <UploadForm mode="sell" onCancel={() => setShowUpload(false)} onSubmit={handleUpload}/>
        </div>
      )}

      {/* Artist profile card (personalised) */}
      {profileLoading
        ? <div className="card h-28 animate-pulse bg-amber-50 mb-8"/>
        : <ArtistProfile profile={profile} stats={stats}/>
      }

      {/* Stats */}
      {statsLoading
        ? <div className="grid grid-cols-2 xl:grid-cols-4 gap-4 mb-8">{[...Array(4)].map((_,i) => <div key={i} className="card h-28 animate-pulse bg-soil-50"/>)}</div>
        : <div className="grid grid-cols-2 xl:grid-cols-4 gap-4 mb-8">
            <StatCard icon={TrendingUp} label="Total Earnings"  value={formatINR(stats?.role_stats?.total_earnings || 0)} sub="All Time"       accent="amber"/>
            <StatCard icon={Award}      label="Green Coins"     value={stats?.green_coins ?? profile.green_coins ?? 0}    sub="Current Balance" accent="teal"/>
            <StatCard icon={ShoppingBag} label="Artworks Sold"  value={stats?.role_stats?.artworks_sold || soldItems.length} sub="All Time"   accent="green"/>
            <StatCard icon={Star}        label="My Rating"      value={stats?.role_stats?.rating ? `${stats.role_stats.rating} ★` : "New"} sub={`${stats?.role_stats?.rating_count || 0} reviews`} accent="amber"/>
          </div>
      }

      {/* Tabs */}
      <div className="flex gap-1 bg-soil-50 border border-soil-200 rounded-2xl p-1 w-fit mb-6">
        {[{ id:"marketplace",label:"🛒 Marketplace" },{ id:"my-listings",label:"🖼️ My Artworks" },{ id:"activity",label:"📊 Activity" }].map(t => (
          <button key={t.id} onClick={() => setActiveTab(t.id)}
            className={`px-4 py-2 rounded-xl text-sm font-semibold transition-all ${activeTab===t.id?"bg-amber-500 text-white shadow":"text-soil-500 hover:text-soil-800"}`}>
            {t.label}
          </button>
        ))}
      </div>

      {/* MARKETPLACE */}
      {activeTab === "marketplace" && (
        <>
          <div className="flex flex-wrap gap-2 mb-5 items-center">
            {CATEGORIES.map(cat => (
              <button key={cat} onClick={() => setCatFilter(cat)}
                className={`px-3 py-1.5 rounded-full text-xs font-semibold capitalize transition-all border ${catFilter===cat?"bg-amber-500 border-amber-500 text-white shadow":"border-soil-200 text-soil-500 hover:border-amber-400 bg-white"}`}>
                {cat==="all" ? "All Scrap" : `${CAT_EMOJI[cat]||""} ${cat}`}
              </button>
            ))}
            <button onClick={refetchMarket} className="ml-auto flex items-center gap-1 text-xs text-soil-400 hover:text-amber-600">
              <RefreshCw size={12}/> Refresh
            </button>
          </div>
          {marketLoading ? <LoadingSpinner message="Loading scrap marketplace…"/>
            : marketError ? <ErrorBanner message={marketError} onRetry={refetchMarket}/>
            : scrapItems.length === 0 ? <ErrorBanner variant="empty" message="No scrap items found. Try a different category."/>
            : <>
                <p className="text-xs text-soil-400 mb-4">
                  <span className="font-semibold text-soil-700">{marketData?.total || scrapItems.length}</span> items available
                  {catFilter!=="all" && <span className="ml-1 text-amber-600 font-medium">in "{catFilter}"</span>}
                </p>
                <div className="grid grid-cols-2 sm:grid-cols-3 xl:grid-cols-4 gap-4">
                  {scrapItems.map(item => <ScrapItemCard key={item.id} item={item} onBuy={refetchMarket}/>)}
                </div>
              </>
          }
        </>
      )}

      {/* MY ARTWORKS */}
      {activeTab === "my-listings" && (
        <>
          <div className="flex items-center justify-between mb-5 flex-wrap gap-3">
            <div>
              <h2 className="font-display font-bold text-xl text-soil-900">My Listings</h2>
              <p className="text-xs text-soil-400 mt-0.5">{activeItems.length} active · {soldItems.length} sold · {donatedItems.length} donated</p>
            </div>
            <button onClick={refetchMyItems} className="text-xs text-soil-400 hover:text-amber-600 flex items-center gap-1">
              <RefreshCw size={12}/> Refresh
            </button>
          </div>

          {myItemsLoading ? <LoadingSpinner message="Loading your artworks…"/>
            : myItemsError ? <ErrorBanner message={myItemsError} onRetry={refetchMyItems}/>
            : myItems.length === 0
            ? <div className="card p-16 text-center">
                <Palette size={40} className="mx-auto mb-4 text-soil-300" strokeWidth={1.5}/>
                <p className="font-display font-bold text-soil-700 text-xl">No listings yet</p>
                <p className="text-soil-400 text-sm mt-2 mb-5">Create your first listing to start selling artwork made from scrap.</p>
                <button onClick={() => setShowUpload(true)} className="btn-craft mx-auto"><Plus size={14}/> Create Listing</button>
              </div>
            : <div className="space-y-3">
                {myItems.map(item => (
                  <div key={item.id} className="card p-4 flex items-center gap-4 hover:border-amber-200 hover:shadow-md transition-all">
                    <div className="w-14 h-14 rounded-2xl bg-amber-50 border border-amber-100 flex items-center justify-center text-2xl shrink-0 overflow-hidden">
                      {item.images?.[0]?.url ? <img src={item.images[0].url} alt="" className="w-full h-full object-cover"/> : CAT_EMOJI[item.category]||"🎨"}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-semibold text-soil-900 text-sm truncate">{item.title}</p>
                      <div className="flex items-center gap-2 mt-1 flex-wrap text-[11px] text-soil-400">
                        <span className="flex items-center gap-1 capitalize"><Tag size={10}/>{item.category}</span>
                        <span>·</span>
                        <span className="flex items-center gap-1"><Calendar size={10}/>{new Date(item.created_at).toLocaleDateString("en-IN",{day:"numeric",month:"short"})}</span>
                        {item.views > 0 && <><span>·</span><span className="flex items-center gap-1"><Eye size={10}/>{item.views} views</span></>}
                        {item.buyer_name && <><span>·</span><span className="text-amber-600 font-medium">→ {item.buyer_name}</span></>}
                      </div>
                    </div>
                    <div className="text-right shrink-0">
                      {item.price > 0 && <p className="font-display font-bold text-craft-600 text-lg">{formatINR(item.price)}</p>}
                      <span className={`pill border text-[10px] ${statusClasses(item.status)}`}>{item.status}</span>
                    </div>
                  </div>
                ))}
              </div>
          }
        </>
      )}

      {/* ACTIVITY */}
      {activeTab === "activity" && (
        <div className="space-y-8">
          <section>
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-display font-bold text-xl text-soil-900">Recent Sales</h2>
              {soldItems.length > 0 && (
                <p className="text-xs text-soil-400">Total: <span className="font-bold text-amber-700">{formatINR(soldItems.reduce((s,i)=>s+(i.price||0),0))}</span></p>
              )}
            </div>
            {myItemsLoading ? <LoadingSpinner/>
              : soldItems.length === 0 ? <ErrorBanner variant="empty" message="No sales yet. Keep creating and listing!"/>
              : <div className="space-y-3">
                  {soldItems.map(item => (
                    <div key={item.id} className="card p-4 flex items-center justify-between gap-4 hover:border-amber-200">
                      <div className="flex items-center gap-3 min-w-0 flex-1">
                        <div className="w-11 h-11 rounded-xl bg-amber-50 border border-amber-100 flex items-center justify-center text-xl shrink-0 overflow-hidden">
                          {item.images?.[0]?.url ? <img src={item.images[0].url} alt="" className="w-full h-full object-cover"/> : CAT_EMOJI[item.category]||"🎨"}
                        </div>
                        <div className="min-w-0">
                          <p className="font-semibold text-soil-900 text-sm truncate">{item.title}</p>
                          <p className="text-xs text-soil-400">Sold to <span className="font-medium text-soil-700">{item.buyer_name||"Unknown"}</span>{item.sold_at && ` · ${new Date(item.sold_at).toLocaleDateString("en-IN",{day:"numeric",month:"short"})}`}</p>
                        </div>
                      </div>
                      <div className="shrink-0 text-right">
                        <p className="font-display font-bold text-amber-700 text-lg">{formatINR(item.price)}</p>
                        <div className="flex items-center gap-1 text-forest-600 text-[10px] justify-end"><Leaf size={9}/>+{item.green_coins_reward} coins</div>
                      </div>
                    </div>
                  ))}
                </div>
            }
          </section>

          <section>
            <h2 className="font-display font-bold text-xl text-soil-900 mb-4">Active Listings ({activeItems.length})</h2>
            {activeItems.length === 0 ? <ErrorBanner variant="empty" message="No active listings."/>
              : <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  {activeItems.map(item => (
                    <div key={item.id} className="card p-4 hover:border-amber-200">
                      <p className="font-semibold text-soil-900 text-sm truncate mb-3">{item.title}</p>
                      <div className="grid grid-cols-3 gap-2 text-center">
                        <div className="bg-soil-50 rounded-xl p-2">
                          <p className="font-display font-bold text-craft-600">{formatINR(item.price)}</p>
                          <p className="text-[10px] text-soil-400">Price</p>
                        </div>
                        <div className="bg-soil-50 rounded-xl p-2">
                          <p className="font-display font-bold text-soil-700">{item.views||0}</p>
                          <p className="text-[10px] text-soil-400">Views</p>
                        </div>
                        <div className="bg-forest-50 rounded-xl p-2">
                          <p className="font-display font-bold text-forest-700">+{item.green_coins_reward}</p>
                          <p className="text-[10px] text-soil-400">Coins</p>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
            }
          </section>

          <section>
            <h2 className="font-display font-bold text-xl text-soil-900 mb-4">Quick Links</h2>
            <div className="grid grid-cols-2 gap-3">
              {[
                { label:"View All Sold & Donated", page:"sold-donated",   icon:Package, cls:"from-amber-50 to-orange-50 border-amber-200 text-amber-700"  },
                { label:"Explore Collaborations",  page:"collaborations", icon:Users,   cls:"from-forest-50 to-teal-50 border-forest-200 text-forest-700" },
              ].map(({ label, page, icon:Icon, cls }) => (
                <button key={page} onClick={() => onNavigate(page)}
                  className={`card p-5 bg-gradient-to-br ${cls} border flex items-center justify-between hover:shadow-md transition-all group`}>
                  <span className="font-semibold text-sm text-left flex items-center gap-2"><Icon size={16}/>{label}</span>
                  <ExternalLink size={16} className="opacity-50 group-hover:opacity-100 shrink-0"/>
                </button>
              ))}
            </div>
          </section>
        </div>
      )}
    </DashboardLayout>
  );
};

export default ArtistDashboard;
