// helpers.js — Shared utility functions

export const formatINR = (amount) =>
  new Intl.NumberFormat("en-IN", { style: "currency", currency: "INR", maximumFractionDigits: 0 }).format(amount || 0);

export const truncate = (str = "", n = 40) =>
  str.length > n ? str.slice(0, n) + "…" : str;

export const getGreeting = () => {
  const h = new Date().getHours();
  if (h < 12) return "Good morning";
  if (h < 18) return "Good afternoon";
  return "Good evening";
};

export const clamp = (val, min, max) => Math.min(Math.max(val, min), max);

export const statusClasses = (status) => ({
  // item statuses
  active:       "bg-forest-100 text-forest-800 border-forest-200",
  sold:         "bg-amber-100  text-amber-800  border-amber-200",
  donated:      "bg-pink-100   text-pink-800   border-pink-200",
  pending:      "bg-amber-100  text-amber-800  border-amber-200",
  collected:    "bg-teal-100   text-teal-800   border-teal-200",
  delivered:    "bg-forest-100 text-forest-800 border-forest-200",
  archived:     "bg-stone-100  text-stone-600  border-stone-200",
  cancelled:    "bg-red-100    text-red-700    border-red-200",
  // listing types
  sell:         "bg-amber-50   text-amber-700  border-amber-200",
  scrap:        "bg-forest-50  text-forest-700 border-forest-200",
  donate:       "bg-pink-50    text-pink-700   border-pink-200",
  // legacy
  Sold:         "bg-amber-100  text-amber-800  border-amber-200",
  Donated:      "bg-pink-100   text-pink-800   border-pink-200",
  Listed:       "bg-amber-50   text-amber-700  border-amber-200",
  Pending:      "bg-amber-100  text-amber-800  border-amber-200",
  Completed:    "bg-forest-50  text-forest-700 border-forest-200",
})[status] || "bg-stone-100 text-stone-600 border-stone-200";
