const BASE_URL = process.env.REACT_APP_API_URL || "/api";

/* ── Internal: read JWT from localStorage ── */
const getToken = () => localStorage.getItem("sc_token");

/**
 * request()  — Base fetch wrapper with auth headers + error handling
 */
const request = async (endpoint, options = {}) => {
  const token = getToken();
  const headers = {
    "Content-Type": "application/json",
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
    ...(options.headers || {}),
  };

  if (options.body instanceof FormData) {
    delete headers["Content-Type"];
  }

  const response = await fetch(`${BASE_URL}${endpoint}`, { ...options, headers });
  const data = await response.json();

  if (!response.ok) {
    const error = new Error(data.message || "An error occurred");
    error.statusCode = response.status;
    error.errors = data.errors;
    throw error;
  }

  return data;
};

/* ── AUTH ── */
export const authAPI = {
  register: (data) => request("/auth/register", { method: "POST", body: JSON.stringify(data) }),
  login: (data) => request("/auth/login", { method: "POST", body: JSON.stringify(data) }),
  getMe: () => request("/auth/me"),
  updateMe: (data) => request("/auth/me", { method: "PUT", body: JSON.stringify(data) }),
  changePassword: (data) => request("/auth/change-password", { method: "PUT", body: JSON.stringify(data) }),
};

/* ── ITEMS ── */
export const itemsAPI = {
  getAll: (params = {}) => {
    const qs = new URLSearchParams(
      Object.fromEntries(Object.entries(params).filter(([, v]) => v !== undefined && v !== ""))
    ).toString();
    return request(`/items${qs ? `?${qs}` : ""}`);
  },
  getMy: () => request("/items/my"),
  getById: (id) => request(`/items/${id}`),
  create: (data, files = []) => {
    const form = new FormData();
    Object.entries(data).forEach(([k, v]) => {
      if (v !== undefined && v !== null)
        form.append(k, typeof v === "object" ? JSON.stringify(v) : v);
    });
    files.forEach((f) => form.append("images", f));
    return request("/items", { method: "POST", body: form });
  },
  update: (id, data) => request(`/items/${id}`, { method: "PUT", body: JSON.stringify(data) }),
  delete: (id) => request(`/items/${id}`, { method: "DELETE" }),
  buy: (id) => request(`/items/${id}/buy`, { method: "POST" }),
  donate: (id) => request(`/items/${id}/donate`, { method: "POST" }),
};

/* ── TASKS ── */
export const tasksAPI = {
  getAll: (type = "mine") => request(`/tasks?type=${type}`),
  getById: (id) => request(`/tasks/${id}`),
  create: (data) => request("/tasks", { method: "POST", body: JSON.stringify(data) }),
  assign: (id) => request(`/tasks/${id}/assign`, { method: "PUT" }),
  progress: (id, data = {}) => request(`/tasks/${id}/progress`, { method: "PUT", body: JSON.stringify(data) }),
  cancel: (id, reason) => request(`/tasks/${id}/cancel`, { method: "PUT", body: JSON.stringify({ reason }) }),
};

/* ── USERS ── */
export const usersAPI = {
  getAll: (params = {}) => {
    const qs = new URLSearchParams(params).toString();
    return request(`/users${qs ? `?${qs}` : ""}`);
  },
  getById: (id) => request(`/users/${id}`),
  getStats: (id) => request(`/users/${id}/stats`),
  getMyTransactions: () => request("/users/me/transactions"),
};

/* ── AUTH STORAGE HELPERS ── */
export const saveAuth = (token, user) => {
  localStorage.setItem("sc_token", token);
  localStorage.setItem("sc_user", JSON.stringify(user));
};

export const clearAuth = () => {
  localStorage.removeItem("sc_token");
  localStorage.removeItem("sc_user");
};

export const getSavedUser = () => {
  try { return JSON.parse(localStorage.getItem("sc_user") || "null"); }
  catch { return null; }
};
