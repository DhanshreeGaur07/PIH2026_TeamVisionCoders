// ============================================================
//  CartPage — Cart list + proceed to order summary
// ============================================================
import React from "react";
import { ArrowLeft, ShoppingBag, Trash2 } from "lucide-react";
import { formatINR } from "../utils/helpers";
import { categoryColors } from "../data/mockData";

const CAT_EMOJI = { metal: "🔩", plastic: "🧴", "e-waste": "💡", wood: "🌲", glass: "🪟", paper: "📄", textile: "🧵", ceramic: "🏺", artwork: "🎨", other: "📦" };

const CartPage = ({ cart, onRemoveFromCart, onNavigate, onNavigateBack }) => {
  const total = cart.reduce((s, i) => s + (i.price || 0) * (i.quantity || 1), 0);

  return (
    <div className="min-h-screen bg-soil-50">
      <header className="sticky top-0 z-50 bg-white/95 backdrop-blur border-b border-soil-100 shadow-sm">
        <div className="max-w-6xl mx-auto px-4 py-4 flex items-center justify-between">
          <button type="button" onClick={onNavigateBack} className="flex items-center gap-2 text-soil-600 hover:text-forest-600 text-sm font-medium">
            <ArrowLeft size={18} /> Back
          </button>
          <span className="font-display font-black text-soil-900 text-lg">Cart</span>
          <button type="button" onClick={() => onNavigate("artworks")} className="btn-outline text-sm py-2 px-4">Artworks</button>
        </div>
      </header>

      <main className="max-w-4xl mx-auto px-4 py-8">
        <h1 className="font-display font-black text-2xl text-soil-900 mb-6 flex items-center gap-2">
          <ShoppingBag size={28} /> Your cart
        </h1>

        {cart.length === 0 ? (
          <div className="card p-12 text-center">
            <p className="text-soil-500 mb-4">Your cart is empty.</p>
            <button type="button" onClick={() => onNavigate("artworks")} className="btn-primary">Browse artworks</button>
          </div>
        ) : (
          <>
            <ul className="space-y-4 mb-8">
              {cart.map((i) => {
                const cat = categoryColors[i.category] || categoryColors.other;
                return (
                  <li key={i.id} className="card p-4 flex items-center gap-4">
                    <div className={`w-16 h-16 rounded-xl ${cat.bg} border ${cat.border} flex items-center justify-center text-2xl shrink-0`}>
                      {i.images?.[0]?.url ? <img src={i.images[0].url} alt="" className="w-full h-full object-cover rounded-xl" /> : (CAT_EMOJI[i.category] || "🎨")}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-semibold text-soil-900 truncate">{i.title}</p>
                      <p className="text-sm text-soil-500">{i.seller_name}</p>
                    </div>
                    <p className="font-display font-bold text-forest-700">{formatINR((i.price || 0) * (i.quantity || 1))}</p>
                    <button type="button" onClick={() => onRemoveFromCart(i.id)} className="p-2 text-soil-400 hover:text-red-600" aria-label="Remove">
                      <Trash2 size={18} />
                    </button>
                  </li>
                );
              })}
            </ul>
            <div className="card p-6 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
              <p className="font-display font-black text-xl text-soil-900">Total: {formatINR(total)}</p>
              <button type="button" onClick={() => onNavigate("order-summary")} className="btn-craft w-full sm:w-auto justify-center py-3 px-6">
                Proceed to order summary
              </button>
            </div>
          </>
        )}
      </main>
    </div>
  );
};

export default CartPage;
