import React from "react";
import { Recycle } from "lucide-react";

/**
 * @param {string}  size    - "sm" | "md" | "lg"
 * @param {string}  message - optional loading text
 * @param {boolean} fullPage - center in full viewport height
 */
const LoadingSpinner = ({ size = "md", message, fullPage = false }) => {
  const sizeMap = { sm: 16, md: 28, lg: 44 };
  const iconSize = sizeMap[size] || 28;

  const content = (
    <div className="flex flex-col items-center gap-3">
      <div
        className="rounded-full bg-forest-100 border-2 border-forest-200 flex items-center justify-center animate-spin-slow"
        style={{ width: iconSize * 1.8, height: iconSize * 1.8 }}
      >
        <Recycle size={iconSize} className="text-forest-600" strokeWidth={1.8} />
      </div>
      {message && (
        <p className="text-sm font-medium text-soil-500 animate-pulse">{message}</p>
      )}
    </div>
  );

  if (fullPage) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[var(--clr-bg)]">
        {content}
      </div>
    );
  }

  return (
    <div className="flex items-center justify-center py-16">
      {content}
    </div>
  );
};

export default LoadingSpinner;
