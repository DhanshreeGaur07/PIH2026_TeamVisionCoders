// ============================================================
//  HelperDashboard.js  — Personalised helper dashboard
//  Restricted: Pickup & Delivery points, Waste Transported
// ============================================================
import React, { useState } from "react";
import {
  Truck, Award, Recycle, MapPin, Clock, CheckCircle,
  AlertCircle, Leaf, RefreshCw, Navigation,
  Calendar, Package
} from "lucide-react";
import DashboardLayout from "../components/layout/DashboardLayout";
import StatCard from "../components/common/StatCard";
import LoadingSpinner from "../components/common/LoadingSpinner";
import ErrorBanner from "../components/common/ErrorBanner";
import { tasksAPI, usersAPI } from "../services/api";
import { getGreeting, statusClasses } from "../utils/helpers";
import useFetch from "../hooks/useFetch";

const HelperProfile = ({ profile, stats }) => (
  <div className="card bg-gradient-to-br from-teal-50 to-cyan-50 border-teal-200 p-6 mb-8 relative overflow-hidden">
    <div className="absolute top-0 right-0 w-48 h-48 bg-teal-100 rounded-full -translate-y-20 translate-x-20 opacity-30 pointer-events-none" />
    <div className="relative flex flex-wrap items-start gap-5">
      <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-teal-500 to-cyan-600 flex items-center justify-center text-white text-2xl font-display font-black shadow-lg shrink-0 overflow-hidden">
        {profile.avatar_url ? <img src={profile.avatar_url} alt="" className="w-full h-full object-cover" /> : profile.name?.[0]?.toUpperCase()}
      </div>
      <div className="flex-1 min-w-0">
        <div className="flex flex-wrap items-center gap-2 mb-1">
          <h2 className="font-display font-black text-xl text-soil-900">{profile.name}</h2>
          <span className="pill bg-teal-100 text-teal-800 border-teal-200 text-[10px] font-bold">♻️ HELPER</span>
          {profile.is_available && <span className="pill bg-forest-100 text-forest-700 border border-forest-200 text-[10px]">🟢 Available</span>}
        </div>
        <div className="flex flex-wrap items-center gap-3 mt-1 text-[11px] text-soil-400">
          {profile.city && <span className="flex items-center gap-1"><MapPin size={10} />{profile.city}, {profile.state}</span>}
          {profile.vehicle_type && <span className="flex items-center gap-1">🚲 {profile.vehicle_type}</span>}
          {profile.created_at && <span className="flex items-center gap-1"><Calendar size={10} />Joined {new Date(profile.created_at).toLocaleDateString()}</span>}
        </div>
      </div>
      <div className="shrink-0">
        <div className="inline-flex items-center gap-2 bg-teal-700 text-white rounded-2xl px-4 py-2.5 shadow-md">
          <Leaf size={16} />
          <div>
            <p className="font-display font-black text-xl leading-none">{profile.green_coins ?? 0}</p>
            <p className="text-teal-200 text-[10px]">Green Coins</p>
          </div>
        </div>
      </div>
    </div>
  </div>
);

const HelperDashboard = ({ user, onNavigate, onLogout, onNavigateBack }) => {
  const [activeTab, setActiveTab] = useState("pickup-delivery");

  const { data: profileData, loading: profileLoading } = useFetch(() => usersAPI.getById(user.id), [user.id]);
  const { data: statsData, loading: statsLoading } = useFetch(() => usersAPI.getStats(user.id), [user.id]);

  // This helper's own assigned tasks
  const { data: myTasksData, loading: myTasksLoading, error: myTasksError, refetch: refetchMyTasks } = useFetch(() => tasksAPI.getAll("mine"), [user.id]);

  const profile = profileData?.user || user;
  const stats = statsData?.stats || {};
  const myTasks = myTasksData?.tasks || [];

  const activeTasks = myTasks.filter(t => !["delivered", "cancelled"].includes(t.status));
  const completedTasks = myTasks.filter(t => t.status === "delivered");
  const totalWaste = completedTasks.reduce((s, t) => s + (parseFloat(t.weight_kg) || t.estimated_weight_kg || 0), 0);

  return (
    <DashboardLayout role="helper" user={user} activeTab={activeTab} onTabChange={setActiveTab} onLogout={onLogout} onNavigate={onNavigate} onNavigateBack={onNavigateBack}>

      <div className="mb-6 flex flex-wrap items-center justify-between gap-4">
        <div>
          <p className="text-soil-400 text-sm font-medium mb-0.5">{getGreeting()}, {user.name?.split(" ")[0]} ♻️</p>
          <h1 className="font-display font-black text-3xl text-soil-900">Helper Hub</h1>
        </div>
        <button onClick={refetchMyTasks} className="btn-outline text-sm py-2 px-4 flex items-center gap-1.5"><RefreshCw size={14} /> Refresh</button>
      </div>

      {profileLoading ? <div className="card h-28 animate-pulse bg-teal-50 mb-8" /> : <HelperProfile profile={profile} stats={stats} />}

      {/* Tabs */}
      <div className="flex gap-1 bg-soil-50 border border-soil-200 rounded-2xl p-1 w-fit mb-6">
        {[{ id: "pickup-delivery", label: "🚚 Pickup & Delivery" }, { id: "transported", label: "📦 Waste Transported" }].map(t => (
          <button key={t.id} onClick={() => setActiveTab(t.id)}
            className={`px-4 py-2 rounded-xl text-sm font-semibold transition-all ${activeTab === t.id ? "bg-teal-600 text-white shadow" : "text-soil-500 hover:text-soil-800"}`}>
            {t.label}
          </button>
        ))}
      </div>

      {activeTab === "pickup-delivery" && (
        <div className="space-y-6">
          <h2 className="font-display font-bold text-xl text-soil-900 mb-4">Pickup &amp; Delivery Points</h2>
          {myTasksLoading ? <LoadingSpinner message="Loading your routes…" /> : myTasksError ? <ErrorBanner message={myTasksError} /> : activeTasks.length === 0 ? (
            <div className="card p-16 text-center text-soil-400">
              <Truck size={40} className="mx-auto mb-4 opacity-40" />
              <p className="font-display font-bold text-lg text-soil-700">No active routes</p>
            </div>
          ) : (
            <div className="grid gap-3">
              {activeTasks.map(task => (
                <div key={task.id} className="card p-5 border-2 border-teal-100 shadow-sm">
                  <div className="flex items-center justify-between mb-4">
                    <span className="pill bg-teal-100 text-teal-800 font-bold border-teal-200 text-xs">#{task.id} - {task.status.toUpperCase()}</span>
                    <span className="font-display font-bold text-teal-700">+{task.green_coins_reward} coins</span>
                  </div>

                  <div className="space-y-2 mb-4 bg-soil-50 rounded-2xl p-3 border border-soil-100">
                    <div className="flex items-start gap-2.5">
                      <div className="w-5 h-5 rounded-full bg-forest-100 border-2 border-forest-400 flex items-center justify-center shrink-0 mt-0.5">
                        <div className="w-2 h-2 rounded-full bg-forest-600" />
                      </div>
                      <div>
                        <p className="text-[10px] font-bold text-soil-400 uppercase tracking-wider">Pickup</p>
                        <p className="text-sm font-medium text-soil-800">{task.pickup_address}</p>
                      </div>
                    </div>
                    <div className="w-px h-3 bg-soil-200 ml-[9px]" />
                    <div className="flex items-start gap-2.5">
                      <div className="w-5 h-5 rounded-full bg-craft-100 border-2 border-craft-400 flex items-center justify-center shrink-0 mt-0.5">
                        <MapPin size={10} className="text-craft-600" />
                      </div>
                      <div>
                        <p className="text-[10px] font-bold text-soil-400 uppercase tracking-wider">Drop-off</p>
                        <p className="text-sm font-medium text-soil-800">{task.dropoff_address}</p>
                      </div>
                    </div>
                  </div>
                  <div className="flex items-center gap-3 text-xs text-soil-400">
                    <span className="flex items-center gap-1"><Recycle size={12} /> {task.weight_kg || task.estimated_weight_kg} kg estimated</span>
                    <span className="flex items-center gap-1"><Navigation size={12} /> {task.distance_km || "? "} km</span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {activeTab === "transported" && (
        <div className="space-y-6">
          <div className="flex flex-wrap items-center justify-between gap-3 mb-4">
            <h2 className="font-display font-bold text-xl text-soil-900">Waste Transported</h2>
            <div className="flex items-center gap-1 bg-white border border-teal-200 rounded-xl px-3 py-1.5 shadow-sm">
              <Recycle size={14} className="text-teal-600" />
              <span className="text-sm font-semibold text-teal-700">{totalWaste} kg total</span>
            </div>
          </div>

          {myTasksLoading ? <LoadingSpinner message="Loading your history…" /> : myTasksError ? <ErrorBanner message={myTasksError} /> : completedTasks.length === 0 ? (
            <div className="card p-16 text-center text-soil-400">
              <Package size={40} className="mx-auto mb-4 opacity-40" />
              <p className="font-display font-bold text-lg text-soil-700">No transported waste yet</p>
            </div>
          ) : (
            <div className="grid gap-3">
              {completedTasks.map(task => (
                <div key={task.id} className="card p-4 flex items-center gap-4 hover:border-teal-200 border-soil-100">
                  <div className="w-12 h-12 rounded-xl bg-teal-50 flex items-center justify-center shrink-0 text-teal-600">
                    <CheckCircle size={20} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-soil-900 text-sm truncate">{task.item_description || `Scrap Run #${task.id}`}</p>
                    <p className="text-xs text-soil-400 mt-1">{task.pickup_address} → {task.dropoff_address}</p>
                  </div>
                  <div className="text-right shrink-0">
                    <p className="font-bold text-teal-700">{task.actual_weight_kg || task.weight_kg || task.estimated_weight_kg || 0} kg</p>
                    <p className="text-[10px] flex items-center justify-end gap-1 text-forest-600 font-bold mt-1"><Leaf size={10} /> +{task.green_coins_reward}</p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

    </DashboardLayout>
  );
};

export default HelperDashboard;
