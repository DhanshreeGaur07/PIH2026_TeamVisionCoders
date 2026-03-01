import React from "react";

/**
 * Renders a single KPI card.
 * @param {React.ReactNode} icon   - Lucide icon component
 * @param {string}          label  - metric label
 * @param {string|number}   value  - display value
 * @param {string}          sub    - sub-label (e.g. "This month")
 * @param {string}          accent - "green" | "amber" | "teal" | "rose"
 */
const accentMap = {
  green: {
    icon:   "bg-forest-100 text-forest-600",
    border: "border-forest-200",
    value:  "text-forest-700",
    glow:   "from-forest-50 to-white",
  },
  amber: {
    icon:   "bg-amber-100 text-amber-700",
    border: "border-amber-200",
    value:  "text-amber-700",
    glow:   "from-amber-50 to-white",
  },
  teal: {
    icon:   "bg-teal-100 text-teal-700",
    border: "border-teal-200",
    value:  "text-teal-700",
    glow:   "from-teal-50 to-white",
  },
  rose: {
    icon:   "bg-rose-100 text-rose-600",
    border: "border-rose-200",
    value:  "text-rose-700",
    glow:   "from-rose-50 to-white",
  },
};

const StatCard = ({ icon: Icon, label, value, sub, accent = "green" }) => {
  const a = accentMap[accent] || accentMap.green;

  return (
    <div
      className={`card p-5 bg-gradient-to-br ${a.glow} border ${a.border} flex flex-col gap-3`}
      role="region"
      aria-label={label}
    >
      {/* Icon + sub-label row */}
      <div className="flex items-center justify-between">
        <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${a.icon}`}>
          {Icon && <Icon size={20} strokeWidth={2} />}
        </div>
        {sub && (
          <span className="text-[11px] font-semibold text-soil-500 bg-soil-100 px-2 py-0.5 rounded-full border border-soil-200">
            {sub}
          </span>
        )}
      </div>

      {/* Value */}
      <div>
        <p className={`text-2xl font-display font-bold ${a.value} leading-tight`}>{value}</p>
        <p className="text-xs text-soil-600 mt-0.5 font-medium">{label}</p>
      </div>
    </div>
  );
};

export default StatCard;
