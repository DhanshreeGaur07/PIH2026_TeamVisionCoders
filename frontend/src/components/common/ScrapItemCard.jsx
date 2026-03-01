// ============================================================
//  ScrapItemCard.js  — Marketplace product card
// ============================================================
import React, { useState } from "react";
import { ShoppingCart, Leaf, Eye } from "lucide-react";
import Badge from "./Badge";
import { categoryColors } from "../../data/mockData";

/**
 * Displays a single scrap item available in the marketplace.
 * @param {object} item  - scrap item object from mockData
 */
const ScrapItemCard = ({ item }) => {
  const [added, setAdded] = useState(false);
  const cat = categoryColors[item.category] || categoryColors.other;

  const handleAdd = () => {
    setAdded(true);
    setTimeout(() => setAdded(false), 2000);
  };

  return (
    <div className="card group overflow-hidden flex flex-col">
      {/* Emoji thumbnail */}
      <div
        className={`flex items-center justify-center h-28 text-5xl ${cat.bg} border-b ${cat.border} transition-transform duration-300 group-hover:scale-105`}
      >
        {item.image}
      </div>

      {/* Body */}
      <div className="p-4 flex flex-col gap-2 flex-1">
        <div className="flex items-start justify-between gap-2">
          <h3 className="font-semibold text-sm text-soil-900 leading-tight flex-1">{item.title}</h3>
          <Badge
            text={item.category}
            variant="custom"
            className={`${cat.bg} ${cat.text} ${cat.border} shrink-0`}
          />
        </div>

        <p className="text-xs text-soil-500">
          by <span className="font-semibold text-soil-700">{item.seller}</span>
          &nbsp;·&nbsp;{item.weight}
        </p>

        {/* Green coins */}
        <div className="flex items-center gap-1 text-forest-600 text-xs font-medium">
          <Leaf size={11} />
          <span>+{item.coins} Green Coins</span>
        </div>

        {/* Price + CTA */}
        <div className="flex items-center justify-between mt-auto pt-3 border-t border-soil-100">
          <span className="text-forest-700 font-display font-bold text-lg">
            ₹{item.price}
          </span>
          <button
            onClick={handleAdd}
            className={`flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-xl transition-all ${
              added
                ? "bg-forest-600 text-white scale-95"
                : "btn-primary py-1.5 px-3 text-xs"
            }`}
            aria-label={`Add ${item.title} to cart`}
          >
            <ShoppingCart size={13} />
            {added ? "Added!" : "Buy"}
          </button>
        </div>
      </div>
    </div>
  );
};

export default ScrapItemCard;
