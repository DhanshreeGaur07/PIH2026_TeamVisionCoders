// ============================================================
//  ArtworksPage.js — Public gallery of artworks uploaded by artists
// ============================================================
import React from "react";
import { Recycle, Palette, ArrowLeft } from "lucide-react";
import useFetch from "../hooks/useFetch";
import { itemsAPI } from "../services/api";
import LoadingSpinner from "../components/common/LoadingSpinner";
import ErrorBanner from "../components/common/ErrorBanner";
import { formatINR } from "../utils/helpers";
import { categoryColors } from "../data/mockData";

const CAT_EMOJI = {
  metal: "🔩",
  plastic: "🧴",
  "e-waste": "💡",
  wood: "🌲",
  glass: "🪟",
  paper: "📄",
  textile: "🧵",
  ceramic: "🏺",
  artwork: "🎨",
  other: "📦",
};

const ArtworksPage = ({ onNavigate, onNavigateBack, user }) => {
  const { data, loading, error, refetch } = useFetch(
    () =>
      itemsAPI.getAll({
        category: "artwork",
        status: "active",
        limit: 48,
      }),
    []
  );

  const items = data?.items || [];
  const totalWasteKg = items.reduce((s, i) => s + (i.waste_used_kg || 0), 0);

  return (
    <div className="min-h-screen bg-soil-50">
      <header className="sticky top-0 z-50 bg-white/95 backdrop-blur border-b border-soil-100 shadow-sm">
        <div className="max-w-6xl mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <button
              type="button"
              onClick={onNavigateBack}
              className="flex items-center gap-2 text-soil-600 hover:text-forest-600 transition-colors text-sm font-medium"
            >
              <ArrowLeft size={18} />
              Back
            </button>

            <div className="flex items-center gap-2">
              <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-forest-500 to-forest-700 flex items-center justify-center shadow-md">
                <Recycle size={18} className="text-white" />
              </div>
              <span className="font-display font-black text-soil-900 text-lg tracking-tight">
                SCRAP<span className="text-forest-600">·</span>CRAFTERS
              </span>
            </div>
          </div>

          <div className="flex items-center gap-2">
            {user && (
              <button type="button" onClick={() => onNavigate("cart")} className="btn-outline text-sm py-2 px-4">Cart</button>
            )}
            <button
              type="button"
              onClick={() => onNavigate("auth")}
              className="btn-primary text-sm py-2 px-5"
            >
              {user ? "Account" : "Sign In"}
            </button>
          </div>
        </div>
      </header>

      <main className="max-w-6xl mx-auto px-4 py-10">
        <div className="flex flex-wrap items-start justify-between gap-4 mb-8">
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-2xl bg-amber-100 border border-amber-200 flex items-center justify-center">
              <Palette size={24} className="text-amber-700" />
            </div>
            <div>
              <h1 className="font-display font-black text-2xl text-soil-900">Artworks</h1>
              <p className="text-soil-500 text-sm">Pieces created by artists from scrap and recycled materials</p>
            </div>
          </div>
          {!loading && items.length > 0 && totalWasteKg > 0 && (
            <div className="bg-forest-50 border border-forest-200 rounded-2xl px-5 py-3">
              <p className="text-forest-800 font-display font-bold text-lg">Waste utilised</p>
              <p className="text-forest-600 text-sm"><strong>{totalWasteKg.toFixed(1)} kg</strong> of recycled material in these artworks</p>
            </div>
          )}
        </div>

        {loading ? (
          <LoadingSpinner message="Loading artworks…" />
        ) : error ? (
          <ErrorBanner message={error.message} onRetry={refetch} />
        ) : items.length === 0 ? (
          <div className="card p-16 text-center">
            <Palette
              size={48}
              className="mx-auto mb-4 text-soil-300"
              strokeWidth={1.5}
            />
            <h2 className="font-display font-bold text-soil-700 text-xl mb-2">
              No artworks yet
            </h2>
            <p className="text-soil-400 text-sm max-w-md mx-auto">
              Our artists are busy turning scrap into art. Check back soon or
              sign in to list your own.
            </p>
            <button onClick={onNavigateBack} className="btn-outline mt-6">Back</button>
          </div>
        ) : (
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">
            {items.map((item) => {
              const cat = categoryColors[item.category] || categoryColors.other;
              return (
                <button
                  key={item.id}
                  type="button"
                  onClick={() => onNavigate("artwork-detail", { artworkId: item.id })}
                  className="card overflow-hidden group hover:shadow-lg transition-all flex flex-col text-left cursor-pointer border-0"
                >
                  <div
                    className={`h-36 flex items-center justify-center text-4xl overflow-hidden border-b ${cat.border} ${cat.bg}`}
                  >
                    {item.images?.[0]?.url || (item.image && item.image.startsWith("http")) ? (
                      <img
                        src={item.images?.[0]?.url || item.image}
                        /* 
                          To use a Supabase image URL from your database, you can do something like:
                          src={item.supabase_image_url || `https://[YOUR_PROJECT_REF].supabase.co/storage/v1/object/public/artworks/${item.image_path}`}
                        */
                        alt={item.title}
                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                      />
                    ) : (
                      <div className="flex items-center justify-center w-full h-full text-6xl">
                        {item.image || CAT_EMOJI[item.category] || "🎨"}
                        {/* 
                          Example Supabase Image URL configuration (commented out):
                          <img src={`https://your-supabase-url.supabase.co/storage/v1/object/public/artworks/${item.id}.jpg`} alt={item.title} className="w-full h-full object-cover" />
                        */}
                      </div>
                    )}
                  </div>

                  <div className="p-3 flex flex-col flex-1">
                    <p className="font-semibold text-soil-900 text-sm truncate">
                      {item.title}
                    </p>
                    <p className="text-xs text-soil-400 mt-1 capitalize">
                      {item.category} · {item.seller_name || "Artist"}
                    </p>

                    <div className="mt-auto pt-2 flex items-center justify-between">
                      <span className="font-display font-bold text-forest-700">
                        {item.price > 0 ? formatINR(item.price) : "Free"}
                      </span>
                      <span className={`pill border text-[10px] ${cat.bg} ${cat.text} ${cat.border}`}>
                        {item.category}
                      </span>
                    </div>
                  </div>
                </button>
              );
            })}
          </div>
        )}
      </main>
    </div>
  );
};

export default ArtworksPage;