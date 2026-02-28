import React, { useState } from "react";
import {
  Package, Heart, TrendingUp, RefreshCw, Leaf,
  Calendar, User, Tag, Filter, Recycle, ArrowLeft,
  Star, MapPin
} from "lucide-react";
import DashboardLayout from "../components/layout/DashboardLayout";
import LoadingSpinner  from "../components/common/LoadingSpinner";
import ErrorBanner     from "../components/common/ErrorBanner";
import { itemsAPI } from "../services/api";
import useFetch from "../hooks/useFetch";
import { formatINR, statusClasses } from "../utils/helpers";

const CAT_EMOJI = { metal:"🔩",plastic:"🧴","e-waste":"💡",wood:"🌲",glass:"🪟",paper:"📄",textile:"🧵",rubber:"⚙️",ceramic:"🏺",artwork:"🎨",other:"📦" };

/* ── Single item transaction card ── */
const ItemCard = ({ item, type }) => {
  const isSold = type === "sold";
  const date   = isSold ? item.sold_at : item.updated_at;

  return (
    <div className={`card p-5 border-l-4 ${isSold?"border-l-amber-400":"border-l-pink-400"} hover:shadow-lg transition-all group`}>
      {/* Thumbnail + badge */}
      <div className="flex items-start gap-4">
        <div className={`w-16 h-16 rounded-2xl flex items-center justify-center text-2xl shrink-0 overflow-hidden ${isSold?"bg-amber-50 border border-amber-100":"bg-pink-50 border border-pink-100"}`}>
          {item.images?.[0]?.url
            ? <img src={item.images[0].url} alt={item.title} className="w-full h-full object-cover rounded-2xl"/>
            : CAT_EMOJI[item.category]||"📦"}
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-start justify-between gap-2 mb-1.5">
            <p className="font-semibold text-soil-900 text-sm leading-snug">{item.title}</p>
            <span className={`pill text-[10px] shrink-0 ${isSold?"bg-amber-100 text-amber-800 border border-amber-200":"bg-pink-100 text-pink-800 border border-pink-200"}`}>
              {isSold ? "✅ Sold" : "🤝 Donated"}
            </span>
          </div>
          <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-soil-400">
            <span className="flex items-center gap-1 capitalize"><Tag size={10}/>{item.category}</span>
            {item.seller_name && <span className="flex items-center gap-1"><User size={10}/>by {item.seller_name}</span>}
            {item.seller_city && <span className="flex items-center gap-1"><MapPin size={10}/>{item.seller_city}</span>}
            {date && <span className="flex items-center gap-1"><Calendar size={10}/>{new Date(date).toLocaleDateString("en-IN",{day:"numeric",month:"short",year:"numeric"})}</span>}
            {item.green_coins_reward > 0 && (
              <span className="flex items-center gap-1 text-forest-600 font-medium"><Leaf size={10}/>+{item.green_coins_reward} coins</span>
            )}
          </div>
          {isSold && item.price > 0 && (
            <p className="mt-2 font-display font-bold text-craft-600 text-xl leading-none">{formatINR(item.price)}</p>
          )}
          {isSold && item.buyer_name && (
            <p className="text-xs text-soil-500 mt-1">→ Bought by <span className="font-semibold text-soil-700">{item.buyer_name}</span></p>
          )}
        </div>
      </div>
    </div>
  );
};

/* ── KPI summary card ── */
const KPICard = ({ icon:Icon, label, value, color, bg, border }) => (
  <div className={`card p-5 ${bg} border-2 ${border}`}>
    <div className={`w-10 h-10 rounded-xl ${bg} border ${border} flex items-center justify-center mb-3`}>
      <Icon size={20} className={color}/>
    </div>
    <p className={`font-display font-black text-3xl ${color}`}>{value}</p>
    <p className="text-xs text-soil-500 mt-0.5 font-medium">{label}</p>
  </div>
);

/* ── Main ── */
const SoldDonatedPage = ({ user, onNavigate, onLogout }) => {
  const [activeTab, setActiveTab] = useState("sold");
  const [page,      setPage]      = useState(1);
  const [catFilter, setCatFilter] = useState("all");
  const LIMIT = 12;

  // All sold items (platform-wide)
  const { data: soldData, loading: soldLoading, error: soldError, refetch: refetchSold } =
    useFetch(() => itemsAPI.getAll({ status:"sold",   page, limit:LIMIT, ...(catFilter!=="all"?{category:catFilter}:{}) }), [page, catFilter]);

  // All donated items
  const { data: donatedData, loading: donatedLoading, error: donatedError, refetch: refetchDonated } =
    useFetch(() => itemsAPI.getAll({ status:"donated", page:1, limit:50, ...(catFilter!=="all"?{category:catFilter}:{}) }), [catFilter]);

  const soldItems    = soldData?.items    || [];
  const donatedItems = donatedData?.items || [];
  const totalSold    = soldData?.total    || 0;
  const totalDonated = donatedData?.total || donatedItems.length;
  const totalPages   = soldData?.pages    || 1;

  const totalValue = soldItems.reduce((s, i) => s + (i.price || 0), 0);
  const totalCoins = [...soldItems,...donatedItems].reduce((s, i) => s + (i.green_coins_reward || 0), 0);

  const categories = ["all","metal","plastic","e-waste","wood","glass","paper","textile","ceramic","artwork","other"];

  return (
    <DashboardLayout role={user?.role||"user"} user={user} activeTab="sold-donated"
      onTabChange={(tab) => onNavigate(tab)} onLogout={onLogout} onNavigate={onNavigate}>

      {/* Header */}
      <div className="mb-8 flex items-start justify-between flex-wrap gap-4">
        <div>
          <div className="flex items-center gap-2 mb-2">
            <button onClick={() => onNavigate(user?.role||"user")} className="text-soil-400 hover:text-forest-600 text-xs flex items-center gap-1">
              <ArrowLeft size={13}/> Back to Dashboard
            </button>
          </div>
          <h1 className="font-display font-black text-3xl text-soil-900">Sold &amp; Donated Items</h1>
          <p className="text-soil-500 text-sm mt-1">Every transaction that's keeping scrap out of landfills — platform-wide.</p>
        </div>
        <button onClick={() => { refetchSold(); refetchDonated(); }}
          className="btn-outline text-sm py-2 px-4 flex items-center gap-1.5">
          <RefreshCw size={14}/> Refresh
        </button>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <KPICard icon={Package} label="Total Sold"       value={totalSold}   color="text-amber-700"  bg="bg-amber-50"  border="border-amber-200"/>
        <KPICard icon={Heart}        label="Total Donated"    value={totalDonated} color="text-pink-700"  bg="bg-pink-50"   border="border-pink-200"/>
        <KPICard icon={TrendingUp}   label="Value Transacted" value={formatINR(totalValue)} color="text-forest-700" bg="bg-forest-50" border="border-forest-200"/>
        <KPICard icon={Leaf}         label="Coins Rewarded"   value={totalCoins}  color="text-teal-700"  bg="bg-teal-50"   border="border-teal-200"/>
      </div>

      {/* Category filter */}
      <div className="flex flex-wrap gap-2 mb-5 items-center">
        <span className="flex items-center gap-1 text-xs text-soil-500 font-semibold"><Filter size={12}/> Filter by category:</span>
        {categories.map(cat => (
          <button key={cat} onClick={() => { setCatFilter(cat); setPage(1); }}
            className={`px-3 py-1.5 rounded-full text-xs font-semibold capitalize transition-all border ${catFilter===cat?"bg-forest-600 border-forest-600 text-white shadow":"border-soil-200 text-soil-500 hover:border-forest-400 bg-white"}`}>
            {cat === "all" ? "All" : `${CAT_EMOJI[cat]||""} ${cat}`}
          </button>
        ))}
      </div>

      {/* Tabs */}
      <div className="flex gap-1 bg-soil-50 border border-soil-200 rounded-2xl p-1 w-fit mb-6">
        {[
          { id:"sold",    label:`✅ Sold (${totalSold})` },
          { id:"donated", label:`🤝 Donated (${totalDonated})` },
        ].map(t => (
          <button key={t.id} onClick={() => setActiveTab(t.id)}
            className={`px-5 py-2 rounded-xl text-sm font-semibold transition-all ${activeTab===t.id?"bg-white text-soil-900 shadow border border-soil-200":"text-soil-500 hover:text-soil-800"}`}>
            {t.label}
          </button>
        ))}
      </div>

      {/* SOLD */}
      {activeTab === "sold" && (
        soldLoading ? <LoadingSpinner message="Loading sold items…"/>
          : soldError ? <ErrorBanner message={soldError} onRetry={refetchSold}/>
          : soldItems.length === 0
          ? <ErrorBanner variant="empty" message={`No sold items${catFilter!=="all"?` in "${catFilter}"`:""} yet.`}/>
          : <>
              <p className="text-xs text-soil-400 mb-4">
                Showing <span className="font-semibold text-soil-700">{soldItems.length}</span> of <span className="font-semibold text-soil-700">{totalSold}</span> sold items
              </p>
              <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4 mb-6">
                {soldItems.map(item => <ItemCard key={item.id} item={item} type="sold"/>)}
              </div>
              {totalPages > 1 && (
                <div className="flex items-center justify-center gap-3 mt-4">
                  <button onClick={() => setPage(p => Math.max(1,p-1))} disabled={page===1} className="btn-outline text-xs py-1.5 px-4 disabled:opacity-40">← Prev</button>
                  <span className="text-sm text-soil-500 font-medium">Page {page} / {totalPages}</span>
                  <button onClick={() => setPage(p => Math.min(totalPages,p+1))} disabled={page>=totalPages} className="btn-outline text-xs py-1.5 px-4 disabled:opacity-40">Next →</button>
                </div>
              )}
            </>
      )}

      {/* DONATED */}
      {activeTab === "donated" && (
        donatedLoading ? <LoadingSpinner message="Loading donated items…"/>
          : donatedError ? <ErrorBanner message={donatedError} onRetry={refetchDonated}/>
          : donatedItems.length === 0
          ? <ErrorBanner variant="empty" message={`No donated items${catFilter!=="all"?` in "${catFilter}"`:""} yet. Be the first to give!`}/>
          : <>
              <p className="text-xs text-soil-400 mb-4">
                <span className="font-semibold text-soil-700">{donatedItems.length}</span> items donated — each giving scrap a second life
              </p>
              <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
                {donatedItems.map(item => <ItemCard key={item.id} item={item} type="donated"/>)}
              </div>
            </>
      )}

      {/* Platform impact bar */}
      {(soldItems.length > 0 || donatedItems.length > 0) && (
        <div className="mt-12 card p-6 bg-gradient-to-br from-forest-50 to-teal-50 border-forest-200 text-center">
          <Recycle size={28} className="mx-auto mb-3 text-forest-500"/>
          <h2 className="font-display font-bold text-xl text-forest-900 mb-1">Platform Impact</h2>
          <p className="text-soil-500 text-sm max-w-md mx-auto">
            Every sold and donated item on SCRAP-CRAFTERS represents material diverted from landfills.
            Together we're building a circular economy — one scrap at a time.
          </p>
        </div>
      )}
    </DashboardLayout>
  );
};

export default SoldDonatedPage;
