// ============================================================
//  services/api.js  — Mock API layer (frontend-only, no backend)
//
//  Same API surface as before; all data comes from mockData
//  and localStorage (auth). UI works without any server.
// ============================================================

import {
  scrapItems,
  userListings,
  helperTasks,
  artworksSold,
  artworks,
} from "../data/mockData";

/* ── Map mock item to API item shape ── */
const toApiItem = (row, overrides = {}) => ({
  id: row.id,
  title: row.title,
  category: row.category || "other",
  price: row.price ?? 0,
  status: row.status === "available" ? "active" : (row.status?.toLowerCase() || "active"),
  seller_name: row.seller || row.seller_name || "Seller",
  created_at: row.created_at || new Date().toISOString(),
  views: row.views ?? 0,
  green_coins_reward: row.coins ?? row.green_coins_reward ?? 0,
  images: row.images || (row.image ? [{ url: null, emoji: row.image }] : []),
  imageUrl: row.imageUrl || null,
  buyer_name: row.buyer_name || null,
  sold_at: row.sold_at || null,
  updated_at: row.updated_at || new Date().toISOString(),
  waste_used_kg: row.waste_used_kg ?? null,
  medium: row.medium ?? null,
  ...overrides,
});

/* ── Map userListing status to API status ── */
const listingStatus = (s) => {
  const lower = (s || "").toLowerCase();
  if (lower === "pending") return "active";
  if (lower === "sold") return "sold";
  if (lower === "donated") return "donated";
  return "active";
};

/* ── Map helperTask to API task shape ── */
const toApiTask = (t) => ({
  id: t.id,
  status: t.status === "collected" ? "collected" : t.status === "delivered" ? "delivered" : t.status === "pending" ? "pending" : "assigned",
  item_description: t.items,
  requester_name: t.assignedTo?.split(",")[0] || "Requester",
  green_coins_reward: t.reward,
  is_urgent: t.urgent,
  pickup_address: t.pickup,
  dropoff_address: t.dropoff,
  weight_kg: t.weight,
  assigned_helper: t.status !== "pending" ? "Helper" : null,
  scheduled_at: t.scheduledAt,
});

const delay = (ms = 80) => new Promise((r) => setTimeout(r, ms));

/* ── AUTH (mock: any email/password works; role from register form) ── */
const nextId = () => Math.max(1, ...scrapItems.map((i) => i.id), ...userListings.map((i) => i.id)) + 1;

export const authAPI = {
  register: async (data) => {
    await delay();
    const user = {
      id: nextId(),
      name: data.name || "User",
      email: data.email,
      role: data.role || "user",
      green_coins: 0,
      is_verified: false,
      created_at: new Date().toISOString(),
    };
    return { token: "mock-token", user };
  },
  login: async (data) => {
    await delay();
    const email = data?.email || "";
    const user = {
      id: 1,
      name: email.split("@")[0] || "Demo User",
      email: email || "demo@scrapcrafters.in",
      role: "user",
      green_coins: 42,
      is_verified: true,
      created_at: new Date().toISOString(),
    };
    return { token: "mock-token", user };
  },
  getMe: async () => {
    await delay();
    const user = getSavedUser();
    if (!user) throw new Error("Not authenticated");
    return { user };
  },
  updateMe: async (data) => {
    await delay();
    const user = { ...getSavedUser(), ...data };
    return { user };
  },
  changePassword: async () => {
    await delay();
    return {};
  },
};

/* ── ITEMS (mock from mockData) ── */
export const itemsAPI = {
  getAll: async (params = {}) => {
    await delay();
    const { category, status, listing_type, limit = 24, page = 1 } = params || {};
    let list = [...scrapItems.map((i) => toApiItem(i))];
    if (category === "artwork") {
      list = artworks.map((i) => toApiItem(i));
    }
    if (status === "sold") {
      list = artworksSold.map((a, idx) => toApiItem({ id: a.id, title: a.title, category: "artwork", price: a.price, status: "sold", seller: a.buyer, sold_at: a.date }, { status: "sold", buyer_name: a.buyer }));
    }
    if (status === "donated") {
      list = userListings.filter((u) => u.status === "Donated").map((u) => toApiItem({ ...u, status: "donated" }));
    }
    if (category && category !== "all") list = list.filter((i) => i.category === category);
    if (status && status !== "active") list = list.filter((i) => i.status === status);
    const total = list.length;
    const start = (page - 1) * limit;
    const items = list.slice(start, start + limit);
    return { items, total, pages: Math.ceil(total / limit) || 1 };
  },
  getMy: async () => {
    await delay();
    const items = userListings.map((u) => toApiItem({ ...u, status: listingStatus(u.status), created_at: new Date().toISOString() }));
    return { items };
  },
  getById: async (id) => {
    await delay();
    const numId = parseInt(id, 10);
    const fromArtworks = artworks.find((i) => i.id === numId);
    if (fromArtworks) return { item: toApiItem(fromArtworks) };
    const all = [...scrapItems, ...userListings].map((i) => toApiItem(i));
    const item = all.find((i) => i.id === numId);
    if (!item) throw new Error("Item not found");
    return { item };
  },
  create: async () => {
    await delay();
    return { item: toApiItem({ id: nextId(), title: "New item", category: "other", price: 0, status: "active", seller: "You" }) };
  },
  update: async () => {
    await delay();
    return {};
  },
  delete: async () => {
    await delay();
    return {};
  },
  buy: async () => {
    await delay();
    return {};
  },
  donate: async () => {
    await delay();
    return {};
  },
};

/* ── TASKS (mock from helperTasks) ── */
export const tasksAPI = {
  getAll: async (type = "mine") => {
    await delay();
    const tasks = helperTasks.map(toApiTask);
    if (type === "open") return { tasks: tasks.filter((t) => t.status === "pending") };
    return { tasks };
  },
  getById: async (id) => {
    await delay();
    const t = helperTasks.find((x) => x.id === parseInt(id, 10));
    if (!t) throw new Error("Task not found");
    return { task: toApiTask(t) };
  },
  create: async () => {
    await delay();
    return {};
  },
  assign: async () => {
    await delay();
    return {};
  },
  progress: async () => {
    await delay();
    return {};
  },
  cancel: async () => {
    await delay();
    return {};
  },
};

/* ── USERS (mock: profile/stats from current user) ── */
export const usersAPI = {
  getAll: async () => {
    await delay();
    return { users: [] };
  },
  getById: async (id) => {
    await delay();
    const user = getSavedUser();
    const profile = user && (user.id === id || user.id === parseInt(id, 10)) ? user : { id, name: "User", email: "", role: "user", green_coins: 0, created_at: new Date().toISOString() };
    return { user: profile };
  },
  getStats: async (id) => {
    await delay();
    return {
      stats: {
        role_stats: { rating: 4.5, rating_count: 12 },
        total_listings: 4,
        total_sold: 1,
        total_donated: 1,
      },
    };
  },
  getMyTransactions: async () => {
    await delay();
    return { transactions: [] };
  },
};

/* ── AUTH STORAGE HELPERS ── */
export const saveAuth = (token, user) => {
  if (token) localStorage.setItem("sc_token", token);
  if (user) localStorage.setItem("sc_user", JSON.stringify(user));
};

export const clearAuth = () => {
  localStorage.removeItem("sc_token");
  localStorage.removeItem("sc_user");
};

export const getSavedUser = () => {
  try {
    return JSON.parse(localStorage.getItem("sc_user") || "null");
  } catch {
    return null;
  }
};
