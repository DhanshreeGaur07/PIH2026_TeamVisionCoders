// ============================================================
//  hooks/useAuth.js  — Auth state + login/logout helpers
//
//  Provides: user, token, login(), logout(), loading, error
//  Persists token to localStorage; re-hydrates on page reload.
// ============================================================
import { useState, useCallback, useEffect } from "react";
import { authAPI, saveAuth, clearAuth, getSavedUser } from "../services/api";

/**
 * useAuth()
 * Central authentication hook consumed by App.js and passed
 * down through props (no Context needed at this scale).
 */
const useAuth = () => {
  const [user,    setUser]    = useState(() => getSavedUser());
  const [loading, setLoading] = useState(false);
  const [error,   setError]   = useState(null);

  /* ── On mount: re-validate saved token with server ── */
  useEffect(() => {
    const saved = getSavedUser();
    if (!saved) return;

    // Silently re-fetch /auth/me to confirm token still valid
    authAPI.getMe()
      .then((res) => {
        setUser(res.user);
        saveAuth(localStorage.getItem("sc_token"), res.user);
      })
      .catch(() => {
        // Token expired or invalid — clear storage
        clearAuth();
        setUser(null);
      });
  }, []);

  /* ── register() ── */
  const register = useCallback(async (formData) => {
    setLoading(true);
    setError(null);
    try {
      const res = await authAPI.register(formData);
      saveAuth(res.token, res.user);
      setUser(res.user);
      return res.user;
    } catch (err) {
      setError(err.message);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  /* ── login() ── */
  const login = useCallback(async (email, password) => {
    setLoading(true);
    setError(null);
    try {
      const res = await authAPI.login({ email, password });
      saveAuth(res.token, res.user);
      setUser(res.user);
      return res.user;
    } catch (err) {
      setError(err.message);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  /* ── logout() ── */
  const logout = useCallback(() => {
    clearAuth();
    setUser(null);
    setError(null);
  }, []);

  /* ── refreshUser() — re-fetch /auth/me after profile updates ── */
  const refreshUser = useCallback(async () => {
    try {
      const res = await authAPI.getMe();
      setUser(res.user);
      saveAuth(localStorage.getItem("sc_token"), res.user);
    } catch {
      logout();
    }
  }, [logout]);

  return { user, loading, error, login, logout, register, refreshUser, setError };
};

export default useAuth;
