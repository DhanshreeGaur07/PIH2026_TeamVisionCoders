// ============================================================
//  config/supabase.js — Supabase keys for database & API
//  Use these for direct Supabase client or backend API calls.
// ============================================================

export const supabaseUrl = process.env.REACT_APP_SUPABASE_URL || "";
export const supabaseAnonKey = process.env.REACT_APP_SUPABASE_ANON_KEY || "";
export const apiBaseUrl = process.env.REACT_APP_API_URL || "/api";

export const hasSupabase = !!(supabaseUrl && supabaseAnonKey);
