// ============================================================
//  config/supabase.js — Supabase keys for database & API
//  Use these for direct Supabase client or backend API calls.
// ============================================================

export const supabaseUrl = process.env.REACT_APP_SUPABASE_URL || "https://yteuzaqffybbdfscyhbc.supabase.co";
export const supabaseAnonKey = process.env.REACT_APP_SUPABASE_ANON_KEY || "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl0ZXV6YXFmZnliYmRmc2N5aGJjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIzMDYxMTksImV4cCI6MjA4Nzg4MjExOX0.7iTvCCz4SZ4OSGpBFVZTVRkzdD-XzbeXUyy1FqFGWNk";
export const apiBaseUrl = process.env.REACT_APP_API_URL || "/api";

export const hasSupabase = !!(supabaseUrl && supabaseAnonKey);
