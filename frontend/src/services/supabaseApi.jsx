// ============================================================
//  services/supabaseApi.js — Backend/Supabase API helpers
//  Placeholder for Supabase REST or your backend API calls.
// ============================================================

import { supabaseUrl, supabaseAnonKey, apiBaseUrl } from "../config/supabase";

/**
 * Call your backend API (e.g. create order, Razorpay).
 * Uses REACT_APP_API_URL when set.
 */
export async function backendFetch(endpoint, options = {}) {
  const url = endpoint.startsWith("http") ? endpoint : `${apiBaseUrl.replace(/\/$/, "")}/${endpoint.replace(/^\//, "")}`;
  const headers = {
    "Content-Type": "application/json",
    ...(options.headers || {}),
  };
  const token = typeof localStorage !== "undefined" ? localStorage.getItem("sc_token") : null;
  if (token) headers.Authorization = `Bearer ${token}`;
  const res = await fetch(url, { ...options, headers });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.message || "Request failed");
  return data;
}

/**
 * Razorpay order creation (call your backend).
 * Backend should create Razorpay order and return { orderId, amount, currency }.
 */
export async function createRazorpayOrder(payload) {
  return backendFetch("orders/create", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

/** Supabase client factory (add @supabase/supabase-js when ready) */
export function getSupabaseClient() {
  if (!supabaseUrl || !supabaseAnonKey) return null;
  // When you add: import { createClient } from "@supabase/supabase-js";
  // return createClient(supabaseUrl, supabaseAnonKey);
  return null;
}
