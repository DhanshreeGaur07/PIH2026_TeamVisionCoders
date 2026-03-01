// ============================================================
//  OrderSummaryPage — Order summary + Razorpay placeholder
// ============================================================
import React from "react";
import { ArrowLeft, CreditCard, Shield } from "lucide-react";
import { formatINR } from "../utils/helpers";
import { categoryColors } from "../data/mockData";

const CAT_EMOJI = { metal: "🔩", plastic: "🧴", "e-waste": "💡", wood: "🌲", glass: "🪟", paper: "📄", textile: "🧵", ceramic: "🏺", artwork: "🎨", other: "📦" };

const OrderSummaryPage = ({ cart, onNavigateBack, onNavigate, user }) => {
  const total = cart.reduce((s, i) => s + (i.price || 0) * (i.quantity || 1), 0);

  if (cart.length === 0) {
    return (
      <div className="min-h-screen bg-soil-50 flex flex-col items-center justify-center px-4">
        <header className="absolute top-0 left-0 right-0 px-4 py-4">
          <button type="button" onClick={onNavigateBack} className="flex items-center gap-2 text-soil-600 hover:text-forest-600 text-sm font-medium">
            <ArrowLeft size={18} /> Back
          </button>
        </header>
        <p className="text-soil-600 mb-4">Your cart is empty.</p>
        {onNavigate && <button type="button" onClick={() => onNavigate("artworks")} className="btn-primary">Browse artworks</button>}
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-soil-50">
      <header className="sticky top-0 z-50 bg-white/95 backdrop-blur border-b border-soil-100 shadow-sm">
        <div className="max-w-6xl mx-auto px-4 py-4 flex items-center justify-between">
          <button type="button" onClick={onNavigateBack} className="flex items-center gap-2 text-soil-600 hover:text-forest-600 text-sm font-medium">
            <ArrowLeft size={18} /> Back
          </button>
          <span className="font-display font-black text-soil-900 text-lg">Order Summary</span>
          <span />
        </div>
      </header>

      <main className="max-w-2xl mx-auto px-4 py-8">
        <h1 className="font-display font-black text-2xl text-soil-900 mb-6">Order Summary</h1>

        <ul className="space-y-3 mb-6">
          {cart.map((i) => {
            const cat = categoryColors[i.category] || categoryColors.other;
            return (
              <li key={i.id} className="flex items-center gap-3 p-3 bg-white border border-soil-200 rounded-xl">
                <div className={`w-12 h-12 rounded-lg ${cat.bg} border ${cat.border} flex items-center justify-center text-xl shrink-0`}>
                  {CAT_EMOJI[i.category] || "🎨"}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="font-semibold text-soil-900 text-sm truncate">{i.title}</p>
                  <p className="text-xs text-soil-500">Qty: {i.quantity || 1}</p>
                </div>
                <p className="font-display font-bold text-forest-700">{formatINR((i.price || 0) * (i.quantity || 1))}</p>
              </li>
            );
          })}
        </ul>

        <div className="card p-6 mb-6">
          <p className="font-display font-black text-xl text-soil-900 mb-4">Total: {formatINR(total)}</p>
          {/* Razorpay placeholder — integrate with backend API when ready */}
          <div className="border-2 border-dashed border-forest-200 rounded-xl p-6 bg-forest-50/50">
            <div className="flex items-center gap-3 mb-3">
              <CreditCard size={24} className="text-forest-600" />
              <span className="font-display font-bold text-forest-800">Razorpay Payment Gateway</span>
            </div>
            <p className="text-sm text-soil-600 mb-4">
              Payment API integration: create order on your backend, then open Razorpay checkout with orderId.
            </p>
            <button type="button" disabled className="btn-craft w-full justify-center py-3 opacity-90 cursor-not-allowed">
              Pay {formatINR(total)} (API integration pending)
            </button>
            <p className="text-xs text-soil-500 mt-3 flex items-center gap-1">
              <Shield size={12} /> Secure payment via Razorpay — connect your backend to enable.
            </p>
          </div>
        </div>
      </main>
    </div>
  );
};

export default OrderSummaryPage;
