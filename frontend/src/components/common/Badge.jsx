// ============================================================
//  Badge.js  — Versatile status / category pill
// ============================================================
import React from "react";
import { statusClasses } from "../../utils/helpers";

/**
 * @param {string}          text    - badge label
 * @param {string}          variant - "status" uses statusClasses; "custom" uses className prop
 * @param {string}          className - override classes (used with variant="custom")
 * @param {React.ReactNode} icon    - optional leading icon
 */
const Badge = ({ text, variant = "status", className = "", icon: Icon }) => {
  const classes =
    variant === "status"
      ? `pill border ${statusClasses(text)} ${className}`
      : `pill border ${className}`;

  return (
    <span className={classes}>
      {Icon && <Icon size={11} strokeWidth={2.5} />}
      {text}
    </span>
  );
};

export default Badge;
