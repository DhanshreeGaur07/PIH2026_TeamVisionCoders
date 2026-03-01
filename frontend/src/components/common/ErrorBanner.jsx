// ============================================================
//  ErrorBanner.js  — Inline error / empty-state display
// ============================================================
import React from "react";
import { AlertCircle, RefreshCw } from "lucide-react";

/**
 * @param {string}   message  - error text
 * @param {Function} onRetry  - optional retry callback
 * @param {string}   variant  - "error" | "empty"
 */
const ErrorBanner = ({ message, onRetry, variant = "error" }) => {
  const isError = variant === "error";
  return (
    <div
      className={`rounded-2xl border p-6 flex flex-col items-center gap-3 text-center ${
        isError
          ? "bg-red-50 border-red-200"
          : "bg-soil-50 border-soil-200"
      }`}
    >
      <AlertCircle
        size={28}
        className={isError ? "text-red-400" : "text-soil-400"}
        strokeWidth={1.5}
      />
      <p className={`text-sm font-medium ${isError ? "text-red-700" : "text-soil-600"}`}>
        {message || "Something went wrong."}
      </p>
      {onRetry && (
        <button
          onClick={onRetry}
          className="flex items-center gap-1.5 text-xs font-semibold text-forest-600 hover:text-forest-800 transition-colors"
        >
          <RefreshCw size={12} /> Try again
        </button>
      )}
    </div>
  );
};

export default ErrorBanner;
