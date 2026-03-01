import React, { useState, useEffect } from "react";
import { ArrowLeft, Leaf, ShoppingBag, LogIn } from "lucide-react";
import { itemsAPI } from "../services/api";
import { formatINR } from "../utils/helpers";
import { categoryColors } from "../data/mockData";
import LoadingSpinner from "../components/common/LoadingSpinner";
import ErrorBanner from "../components/common/ErrorBanner";

const CAT_EMOJI = { metal: "🔩", plastic: "🧴", "e-waste": "💡", wood: "🌲", glass: "🪟", paper: "📄", textile: "🧵", ceramic: "🏺", artwork: "🎨", other: "📦" };

const ArtworkDetailPage = ({ artworkId, user, onNavigate, onNavigateBack, onAddToCart }) => {
  const [item, setItem] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!artworkId) return;
    setLoading(true);
    setError(null);
    itemsAPI.getById(artworkId).then((res) => setItem(res.item)).catch((err) => setError(err)).finally(() => setLoading(false));
  }, [artworkId]);

  const handleAddToCart = () => {
    if (!user) { onNavigate("auth"); return; }
    if (item) onAddToCart(item);
    onNavigate("cart");
  };

  const handleBuyNow = () => {
    if (!user) { onNavigate("auth"); return; }
    if (item) onAddToCart(item);
    onNavigate("order-summary");
  };

  if (loading) return <LoadingSpinner message="Loading artwork…" />;
  if (error) return <ErrorBanner message={error.message} onRetry={() => window.location.reload()} />;
  if (!item) return null;

  const cat = categoryColors[item.category] || categoryColors.other;

  return (
    <div className="min-h-screen bg-soil-50">
      <header className="sticky top-0 z-50 bg-white/95 backdrop-blur border-b border-soil-100 shadow-sm">
        <div className="max-w-6xl mx-auto px-4 py-4 flex items-center justify-between">
          <button type="button" onClick={onNavigateBack} className="flex items-center gap-2 text-soil-600 hover:text-forest-600 transition-colors text-sm font-medium">
            <ArrowLeft size={18} /> Back
          </button>
          <span className="font-display font-black text-soil-900 text-lg">SCRAP·CRAFTERS</span>
          <button type="button" onClick={() => onNavigate("cart")} className="btn-outline text-sm py-2 px-4">Cart</button>
        </div>
      </header>
      <main className="max-w-4xl mx-auto px-4 py-8">
        <div className="grid md:grid-cols-2 gap-8">
          <div className={`rounded-2xl border-2 ${cat.border} ${cat.bg} aspect-square flex items-center justify-center text-8xl overflow-hidden`}>
            {item.imageUrl
              ? <img src={item.imageUrl} alt={item.title} className="w-full h-full object-cover" />
              : item.images?.[0]?.url
                ? <img src={item.images[0].url} alt={item.title} className="w-full h-full object-cover" />
                : (CAT_EMOJI[item.category] || "🎨")}
          </div>
          <div>
            <h1 className="font-display font-black text-2xl text-soil-900 mb-2">{item.title}</h1>
            <p className="text-soil-500 text-sm mb-4">{item.seller_name} · {item.medium || item.category}</p>
            {item.waste_used_kg != null && (
              <div className="flex items-center gap-2 mb-4 p-3 bg-forest-50 border border-forest-200 rounded-xl">
                <Leaf size={18} className="text-forest-600" />
                <span className="text-sm font-semibold text-forest-800">Waste utilised: <strong>{item.waste_used_kg} kg</strong> of recycled material</span>
              </div>
            )}
            <p className="font-display font-bold text-forest-700 text-2xl mb-6">{item.price > 0 ? formatINR(item.price) : "Free"}</p>
            {!user ? (
              <div className="space-y-3">
                <p className="text-sm text-soil-600">Sign in to add to cart or buy now.</p>
                <button type="button" onClick={() => onNavigate("auth")} className="btn-primary w-full justify-center py-3 flex items-center gap-2">
                  <LogIn size={18} /> Sign in
                </button>
              </div>
            ) : (
              <div className="flex flex-col sm:flex-row gap-3">
                <button type="button" onClick={handleAddToCart} className="btn-outline flex-1 justify-center py-3 flex items-center gap-2">
                  <ShoppingBag size={18} /> Add to cart
                </button>
                <button type="button" onClick={handleBuyNow} className="btn-craft flex-1 justify-center py-3 flex items-center gap-2">Buy now</button>
              </div>
            )}
          </div>
        </div>
      </main>
    </div>
  );
};

export default ArtworkDetailPage;
