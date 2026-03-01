// ============================================================
//  TaskCard.js  — Helper task card with pickup/dropoff details
// ============================================================
import React from "react";
import { MapPin, CheckCircle, Truck, Clock, Zap, ArrowRight, Package } from "lucide-react";
import Badge from "./Badge";

/**
 * Renders a single helper task with location details and action button.
 * @param {object}   task       - task object from mockData
 * @param {function} onProgress - callback to advance task status
 */
const TaskCard = ({ task, onProgress }) => {
  const isDone = task.status === "delivered";

  /* Status → display config */
  const statusConfig = {
    pending:   { label: "Pending",      badge: "bg-amber-100 text-amber-800 border-amber-200",   btnLabel: "Mark as Collected",  btnClass: "btn-craft" },
    collected: { label: "Collected ✓",  badge: "bg-teal-100  text-teal-800  border-teal-200",    btnLabel: "Mark as Delivered",  btnClass: "btn-primary" },
    delivered: { label: "Delivered ✓✓", badge: "bg-forest-100 text-forest-800 border-forest-200", btnLabel: "Completed",         btnClass: "" },
  };
  const cfg = statusConfig[task.status];

  return (
    <div
      className={`card p-5 border transition-all ${
        isDone ? "border-forest-200 bg-forest-50/40 opacity-80" : "border-soil-200"
      }`}
    >
      {/* Header row */}
      <div className="flex items-start justify-between gap-3 mb-4">
        <div className="flex flex-wrap items-center gap-2">
          <span className={`pill border ${cfg.badge}`}>{cfg.label}</span>
          {task.urgent && !isDone && (
            <span className="pill border bg-red-50 text-red-700 border-red-200">
              <Zap size={10} /> Urgent
            </span>
          )}
        </div>
        <div className="text-right shrink-0">
          <p className="text-forest-600 font-display font-bold text-lg leading-none">+{task.reward}</p>
          <p className="text-[10px] text-soil-500 mt-0.5 font-medium">Green Coins</p>
        </div>
      </div>

      {/* Schedule row */}
      <div className="flex items-center gap-4 mb-4 text-xs text-soil-500">
        <span className="flex items-center gap-1"><Clock size={12} />{task.scheduledAt}</span>
        <span className="flex items-center gap-1"><Package size={12} />{task.weight}</span>
        <span className="flex items-center gap-1"><MapPin size={12} />{task.distance}</span>
      </div>

      {/* Pickup → Dropoff */}
      <div className="rounded-2xl border border-soil-100 bg-soil-50 overflow-hidden mb-4">
        {/* Pickup */}
        <div className="flex items-start gap-3 p-3 border-b border-soil-100">
          <div className="w-7 h-7 rounded-full bg-amber-100 border border-amber-200 flex items-center justify-center shrink-0 mt-0.5">
            <MapPin size={13} className="text-amber-600" />
          </div>
          <div>
            <p className="text-[10px] font-semibold text-soil-400 uppercase tracking-wider mb-0.5">Pickup Location</p>
            <p className="text-sm font-semibold text-soil-900">{task.pickup}</p>
            <p className="text-xs text-soil-500 mt-0.5">📦 {task.items}</p>
          </div>
        </div>

        {/* Arrow connector */}
        <div className="flex items-center justify-center py-1 text-soil-300">
          <ArrowRight size={14} className="rotate-90" />
        </div>

        {/* Dropoff */}
        <div className="flex items-start gap-3 p-3">
          <div className="w-7 h-7 rounded-full bg-forest-100 border border-forest-200 flex items-center justify-center shrink-0 mt-0.5">
            <CheckCircle size={13} className="text-forest-600" />
          </div>
          <div>
            <p className="text-[10px] font-semibold text-soil-400 uppercase tracking-wider mb-0.5">Drop-off Location</p>
            <p className="text-sm font-semibold text-soil-900">{task.dropoff}</p>
          </div>
        </div>
      </div>

      {/* Map placeholder */}
      <div className="rounded-xl bg-forest-50 border border-forest-100 h-20 flex items-center justify-center gap-2 text-forest-500 text-sm mb-4">
        <MapPin size={16} />
        <span className="font-medium">Map · Route view</span>
      </div>

      {/* Action button */}
      {!isDone ? (
        <button
          onClick={() => onProgress(task.id)}
          className={`w-full py-3 rounded-2xl font-semibold text-sm flex items-center justify-center gap-2 ${cfg.btnClass}`}
        >
          <Truck size={15} /> {cfg.btnLabel}
        </button>
      ) : (
        <div className="w-full py-3 rounded-2xl bg-forest-50 border border-forest-200 text-forest-700 text-sm font-semibold text-center">
          🎉 Task Completed
        </div>
      )}
    </div>
  );
};

export default TaskCard;
