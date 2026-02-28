import React, { useState } from "react";
import {
  Truck, Award, Recycle, MapPin, Clock, CheckCircle,
  AlertCircle, Leaf, RefreshCw, TrendingUp, Package, Navigation,
  User, Calendar, Users, ExternalLink, Star
} from "lucide-react";
import DashboardLayout from "../components/layout/DashboardLayout";
import StatCard        from "../components/common/StatCard";
import LoadingSpinner  from "../components/common/LoadingSpinner";
import ErrorBanner     from "../components/common/ErrorBanner";
import { tasksAPI, usersAPI } from "../services/api";
import { getGreeting, statusClasses } from "../utils/helpers";
import useFetch from "../hooks/useFetch";

const TASK_STATUS_CFG = {
  pending:   { label:"Pending",   cls:"bg-amber-100 text-amber-800 border-amber-200",   icon:Clock        },
  assigned:  { label:"Assigned",  cls:"bg-blue-100  text-blue-800  border-blue-200",    icon:Truck        },
  collected: { label:"Collected", cls:"bg-teal-100  text-teal-800  border-teal-200",    icon:Package      },
  delivered: { label:"Delivered", cls:"bg-forest-100 text-forest-800 border-forest-200",icon:CheckCircle  },
  cancelled: { label:"Cancelled", cls:"bg-red-100   text-red-800   border-red-200",     icon:AlertCircle  },
};

/* ── Helper profile card (personalised) ── */
const HelperProfile = ({ profile, stats }) => (
  <div className="card bg-gradient-to-br from-teal-50 to-cyan-50 border-teal-200 p-6 mb-8 relative overflow-hidden">
    <div className="absolute top-0 right-0 w-48 h-48 bg-teal-100 rounded-full -translate-y-20 translate-x-20 opacity-30 pointer-events-none"/>
    <div className="relative flex items-start gap-5 flex-wrap">
      <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-teal-500 to-cyan-600 flex items-center justify-center text-white text-2xl font-display font-black shadow-lg shrink-0 overflow-hidden">
        {profile.avatar_url ? <img src={profile.avatar_url} alt="" className="w-full h-full object-cover"/> : profile.name?.[0]?.toUpperCase()}
      </div>
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2 mb-1 flex-wrap">
          <h2 className="font-display font-black text-xl text-soil-900">{profile.name}</h2>
          <span className="pill bg-teal-100 text-teal-800 border border-teal-200 text-[10px] font-bold">♻️ HELPER</span>
          {profile.is_available && <span className="pill bg-forest-100 text-forest-700 border border-forest-200 text-[10px]">🟢 Available</span>}
          {!profile.is_available && <span className="pill bg-red-100 text-red-700 border border-red-200 text-[10px]">⭕ Unavailable</span>}
        </div>
        <div className="flex items-center gap-3 mt-1 flex-wrap text-[11px] text-soil-400">
          {profile.city && <span className="flex items-center gap-1"><MapPin size={10}/>{profile.city}, {profile.state}</span>}
          {profile.vehicle_type && <span className="flex items-center gap-1">🚲 {profile.vehicle_type}</span>}
          {profile.created_at && <span className="flex items-center gap-1"><Calendar size={10}/>Joined {new Date(profile.created_at).toLocaleDateString("en-IN",{month:"short",year:"numeric"})}</span>}
        </div>
        {/* Personal impact summary */}
        <div className="flex items-center gap-4 mt-3 flex-wrap">
          <div className="flex items-center gap-1.5 bg-white border border-teal-200 rounded-xl px-3 py-1.5">
            <Recycle size={13} className="text-teal-600"/>
            <span className="text-xs font-semibold text-teal-700">{profile.total_waste_kg || 0} kg waste handled</span>
          </div>
          <div className="flex items-center gap-1.5 bg-white border border-teal-200 rounded-xl px-3 py-1.5">
            <CheckCircle size={13} className="text-forest-600"/>
            <span className="text-xs font-semibold text-forest-700">{profile.total_deliveries || 0} deliveries done</span>
          </div>
        </div>
      </div>
      <div className="shrink-0">
        <div className="inline-flex items-center gap-2 bg-teal-700 text-white rounded-2xl px-4 py-2.5 shadow-md">
          <Leaf size={16}/>
          <div>
            <p className="font-display font-black text-xl leading-none">{profile.green_coins ?? 0}</p>
            <p className="text-teal-200 text-[10px]">Green Coins</p>
          </div>
        </div>
      </div>
    </div>
  </div>
);

/* ── Task card ── */
const TaskCard = ({ task, onProgress, onCancel, progressLoading }) => {
  const cfg = TASK_STATUS_CFG[task.status] || TASK_STATUS_CFG.pending;
  const StatusIcon = cfg.icon;
  const canAdvance = task.status === "assigned" || task.status === "collected";
  const canAssign  = task.status === "pending"  && !task.assigned_helper;
  const nextLabel  = { assigned:"Mark Collected", collected:"Mark Delivered" }[task.status];

  return (
    <div className={`card p-5 border-2 ${task.is_urgent ? "border-amber-300 bg-amber-50/30" : "border-soil-100"} hover:shadow-md transition-all`}>
      <div className="flex items-start justify-between gap-3 mb-4">
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-1 flex-wrap">
            {task.is_urgent && <span className="pill bg-amber-500 text-white text-[10px] font-bold">🔥 URGENT</span>}
            <span className={`pill border text-xs ${cfg.cls}`}><StatusIcon size={10} className="inline mr-1"/>{cfg.label}</span>
            <span className="text-xs text-soil-400 font-mono">#{task.id}</span>
          </div>
          <p className="font-semibold text-soil-900 text-sm">{task.item_description || "Scrap pickup"}</p>
          <p className="text-xs text-soil-400 mt-0.5">Requested by <span className="font-medium text-soil-600">{task.requester_name}</span></p>
        </div>
        <div className="text-right shrink-0">
          <p className="font-display font-bold text-teal-700 text-xl">+{task.green_coins_reward}</p>
          <p className="text-xs text-teal-600 flex items-center gap-0.5 justify-end"><Leaf size={10}/>coins</p>
        </div>
      </div>

      {/* Route */}
      <div className="space-y-2 mb-4 bg-soil-50 rounded-2xl p-3 border border-soil-100">
        <div className="flex items-start gap-2.5">
          <div className="w-5 h-5 rounded-full bg-forest-100 border-2 border-forest-400 flex items-center justify-center shrink-0 mt-0.5">
            <div className="w-2 h-2 rounded-full bg-forest-600"/>
          </div>
          <div>
            <p className="text-[10px] font-bold text-soil-400 uppercase tracking-wider">Pickup</p>
            <p className="text-sm font-medium text-soil-800">{task.pickup_address}</p>
            {task.pickup_city && <p className="text-xs text-soil-400">{task.pickup_city}{task.pickup_state ? `, ${task.pickup_state}` : ""}</p>}
          </div>
        </div>
        <div className="w-px h-3 bg-soil-200 ml-[9px]"/>
        <div className="flex items-start gap-2.5">
          <div className="w-5 h-5 rounded-full bg-craft-100 border-2 border-craft-400 flex items-center justify-center shrink-0 mt-0.5">
            <MapPin size={10} className="text-craft-600"/>
          </div>
          <div>
            <p className="text-[10px] font-bold text-soil-400 uppercase tracking-wider">Drop-off</p>
            <p className="text-sm font-medium text-soil-800">{task.dropoff_address}</p>
            {task.dropoff_city && <p className="text-xs text-soil-400">{task.dropoff_city}{task.dropoff_state ? `, ${task.dropoff_state}` : ""}</p>}
          </div>
        </div>
      </div>

      {/* Meta pills */}
      <div className="flex items-center gap-2 text-xs text-soil-400 mb-4 flex-wrap">
        {task.distance_km && <span className="flex items-center gap-1 bg-soil-50 border border-soil-200 rounded-full px-2 py-0.5"><Navigation size={10}/>{task.distance_km} km</span>}
        {task.estimated_weight_kg > 0 && <span className="flex items-center gap-1 bg-soil-50 border border-soil-200 rounded-full px-2 py-0.5"><Recycle size={10}/>{task.estimated_weight_kg} kg</span>}
        {task.scheduled_at && <span className="flex items-center gap-1 bg-soil-50 border border-soil-200 rounded-full px-2 py-0.5"><Clock size={10}/>{new Date(task.scheduled_at).toLocaleString("en-IN",{dateStyle:"short",timeStyle:"short"})}</span>}
      </div>

      {/* Linked items */}
      {task.items?.length > 0 && (
        <div className="flex flex-wrap gap-1.5 mb-4">
          {task.items.map(item => (
            <span key={item.id} className="pill bg-soil-100 text-soil-600 border border-soil-200 text-[10px] capitalize">
              {item.category} · {item.title?.slice(0,20)}
            </span>
          ))}
        </div>
      )}

      {/* Actions */}
      <div className="flex gap-2">
        {canAssign && (
          <button onClick={() => onProgress(task.id, "assign")} disabled={progressLoading===task.id}
            className="flex-1 btn-primary text-xs py-2 justify-center disabled:opacity-60">
            {progressLoading===task.id ? "…" : "✓ Accept Task"}
          </button>
        )}
        {canAdvance && (
          <button onClick={() => onProgress(task.id, "progress")} disabled={progressLoading===task.id}
            className="flex-1 btn-primary text-xs py-2 justify-center disabled:opacity-60">
            {progressLoading===task.id ? "Updating…" : nextLabel}
          </button>
        )}
        {(task.status==="pending"||task.status==="assigned") && (
          <button onClick={() => onCancel(task.id)} className="btn-outline text-xs py-2 px-3 text-red-600 border-red-200 hover:bg-red-50">
            Cancel
          </button>
        )}
        {task.status === "delivered" && (
          <div className="flex-1 flex items-center justify-center gap-1.5 bg-forest-50 border border-forest-200 rounded-xl py-2 text-xs text-forest-700 font-semibold">
            <CheckCircle size={13}/> Completed{task.reward_paid ? " · Coins Paid ✓" : ""}
          </div>
        )}
      </div>
    </div>
  );
};

/* ── Main ── */
const HelperDashboard = ({ user, onNavigate, onLogout }) => {
  const [activeTab,       setActiveTab]       = useState("tasks");
  const [progressLoading, setProgressLoading] = useState(null);

  // Only this helper's profile
  const { data: profileData, loading: profileLoading } =
    useFetch(() => usersAPI.getById(user.id), [user.id]);

  // Only this helper's stats
  const { data: statsData, loading: statsLoading, refetch: refetchStats } =
    useFetch(() => usersAPI.getStats(user.id), [user.id]);

  // This helper's own assigned tasks (backend enforces auth)
  const { data: myTasksData, loading: myTasksLoading, error: myTasksError, refetch: refetchMyTasks } =
    useFetch(() => tasksAPI.getAll("mine"), [user.id]);

  // Open tasks available platform-wide
  const { data: openTasksData, loading: openLoading, error: openError, refetch: refetchOpen } =
    useFetch(() => tasksAPI.getAll("open"), [user.id]);

  const profile     = profileData?.user || user;
  const stats       = statsData?.stats;
  const myTasks     = myTasksData?.tasks  || [];
  const openTasks   = openTasksData?.tasks || [];

  const activeTasks    = myTasks.filter(t => ["assigned","collected"].includes(t.status));
  const completedTasks = myTasks.filter(t => t.status === "delivered");
  const cancelledTasks = myTasks.filter(t => t.status === "cancelled");

  const totalCoinsEarned = completedTasks.reduce((s, t) => s + (t.green_coins_reward || 0), 0);

  const handleProgress = async (taskId, action) => {
    setProgressLoading(taskId);
    try {
      if (action === "assign")   await tasksAPI.assign(taskId);
      if (action === "progress") await tasksAPI.progress(taskId);
      await Promise.all([refetchMyTasks(), refetchOpen(), refetchStats()]);
    } catch (err) {
      console.error("Task action failed:", err.message);
    } finally {
      setProgressLoading(null);
    }
  };

  const handleCancel = async (taskId) => {
    if (!window.confirm("Cancel this task?")) return;
    setProgressLoading(taskId);
    try {
      await tasksAPI.cancel(taskId, "Cancelled by helper");
      await Promise.all([refetchMyTasks(), refetchOpen(), refetchStats()]);
    } catch {}
    finally { setProgressLoading(null); }
  };

  const taskProps = { onProgress: handleProgress, onCancel: handleCancel, progressLoading };

  return (
    <DashboardLayout role="helper" user={user} activeTab={activeTab}
      onTabChange={setActiveTab} onLogout={onLogout} onNavigate={onNavigate}>

      {/* Welcome */}
      <div className="mb-6 flex items-start justify-between flex-wrap gap-4">
        <div>
          <p className="text-soil-400 text-sm font-medium mb-0.5">{getGreeting()}, {user.name?.split(" ")[0]} ♻️</p>
          <h1 className="font-display font-black text-3xl text-soil-900">Helper Hub</h1>
          <p className="text-soil-500 text-sm mt-1">Pick up scrap, earn Green Coins, build a greener city.</p>
        </div>
        <div className="flex gap-2 flex-wrap">
          <button onClick={() => onNavigate("collaborations")} className="btn-outline text-sm py-2 px-4 flex items-center gap-1.5">
            <Users size={14}/> Collaborations
          </button>
          <button onClick={() => { refetchOpen(); refetchMyTasks(); }} className="btn-outline text-sm py-2 px-4 flex items-center gap-1.5">
            <RefreshCw size={14}/> Refresh
          </button>
        </div>
      </div>

      {/* Profile banner (personalised) */}
      {profileLoading
        ? <div className="card h-28 animate-pulse bg-teal-50 mb-8"/>
        : <HelperProfile profile={profile} stats={stats}/>
      }

      {/* Stats */}
      {statsLoading
        ? <div className="grid grid-cols-2 xl:grid-cols-4 gap-4 mb-8">{[...Array(4)].map((_,i) => <div key={i} className="card h-28 animate-pulse bg-soil-50"/>)}</div>
        : <div className="grid grid-cols-2 xl:grid-cols-4 gap-4 mb-8">
            <StatCard icon={Leaf}       label="Green Coins"   value={stats?.green_coins ?? profile.green_coins ?? 0}              sub="Balance"   accent="teal"/>
            <StatCard icon={Truck}      label="Deliveries"    value={stats?.role_stats?.total_deliveries || completedTasks.length} sub="Completed" accent="green"/>
            <StatCard icon={Recycle}    label="Waste Handled" value={`${stats?.role_stats?.total_waste_kg || 0} kg`}               sub="All Time"  accent="amber"/>
            <StatCard icon={TrendingUp} label="Coins Earned"  value={totalCoinsEarned}                                             sub="From tasks" accent="forest"/>
          </div>
      }

      {/* Tabs */}
      <div className="flex gap-1 bg-soil-50 border border-soil-200 rounded-2xl p-1 w-fit mb-6">
        {[{id:"tasks",label:"🚚 My Tasks"},{id:"open",label:"📋 Open Tasks"},{id:"history",label:"📊 History"}].map(t => (
          <button key={t.id} onClick={() => setActiveTab(t.id)}
            className={`px-4 py-2 rounded-xl text-sm font-semibold transition-all ${activeTab===t.id?"bg-teal-600 text-white shadow":"text-soil-500 hover:text-soil-800"}`}>
            {t.label}
          </button>
        ))}
      </div>

      {/* MY TASKS */}
      {activeTab === "tasks" && (
        myTasksLoading ? <LoadingSpinner message="Loading your tasks…"/>
          : myTasksError ? <ErrorBanner message={myTasksError} onRetry={refetchMyTasks}/>
          : activeTasks.length === 0
          ? <div className="card p-16 text-center">
              <Truck size={40} className="mx-auto mb-4 text-soil-300" strokeWidth={1.5}/>
              <p className="font-display font-bold text-soil-700 text-xl">No active tasks</p>
              <p className="text-soil-400 text-sm mt-2 mb-5">Browse open tasks and accept one to get started!</p>
              <button onClick={() => setActiveTab("open")} className="btn-primary mx-auto">Browse Open Tasks</button>
            </div>
          : <div className="space-y-4">
              {activeTasks.map(task => <TaskCard key={task.id} task={task} {...taskProps}/>)}
            </div>
      )}

      {/* OPEN TASKS */}
      {activeTab === "open" && (
        openLoading ? <LoadingSpinner message="Finding available tasks…"/>
          : openError ? <ErrorBanner message={openError} onRetry={refetchOpen}/>
          : openTasks.length === 0
          ? <div className="card p-16 text-center">
              <Package size={40} className="mx-auto mb-4 text-soil-300" strokeWidth={1.5}/>
              <p className="font-display font-bold text-soil-700 text-xl">No open tasks right now</p>
              <p className="text-soil-400 text-sm mt-2">Check back soon — new pickups get posted daily.</p>
            </div>
          : <>
              <p className="text-xs text-soil-400 mb-4">
                <span className="text-soil-700 font-semibold">{openTasks.length}</span> task{openTasks.length!==1?"s":""} available — urgent tasks listed first
              </p>
              <div className="space-y-4">
                {openTasks.map(task => <TaskCard key={task.id} task={task} {...taskProps}/>)}
              </div>
            </>
      )}

      {/* HISTORY */}
      {activeTab === "history" && (
        <div className="space-y-6">
          <div>
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-display font-bold text-xl text-soil-900">Completed Deliveries ({completedTasks.length})</h2>
              {completedTasks.length > 0 && (
                <div className="flex items-center gap-1 text-teal-700 font-display font-bold">
                  <Leaf size={14}/>+{totalCoinsEarned} total coins earned
                </div>
              )}
            </div>
            {completedTasks.length === 0
              ? <ErrorBanner variant="empty" message="No completed deliveries yet. Complete tasks to build your history."/>
              : <div className="space-y-3">
                  {completedTasks.map(task => (
                    <div key={task.id} className="card p-4 flex items-center justify-between gap-4 hover:border-teal-200">
                      <div className="flex items-center gap-3 min-w-0 flex-1">
                        <div className="w-11 h-11 rounded-xl bg-teal-50 border border-teal-100 flex items-center justify-center shrink-0">
                          <CheckCircle size={20} className="text-teal-600"/>
                        </div>
                        <div className="min-w-0">
                          <p className="font-semibold text-soil-900 text-sm truncate">{task.item_description || `Task #${task.id}`}</p>
                          <p className="text-xs text-soil-400 mt-0.5">
                            {task.pickup_city} → {task.dropoff_city}
                            {task.delivered_at && ` · ${new Date(task.delivered_at).toLocaleDateString("en-IN",{day:"numeric",month:"short",year:"numeric"})}`}
                          </p>
                        </div>
                      </div>
                      <div className="shrink-0 text-right">
                        <div className="flex items-center gap-1 text-teal-700 font-display font-bold"><Leaf size={14}/>+{task.green_coins_reward}</div>
                        <p className="text-[10px] text-soil-400">{task.actual_weight_kg||task.estimated_weight_kg||0} kg</p>
                      </div>
                    </div>
                  ))}
                </div>
            }
          </div>

          {/* Cancelled tasks */}
          {cancelledTasks.length > 0 && (
            <div>
              <h2 className="font-display font-bold text-lg text-soil-700 mb-3">Cancelled ({cancelledTasks.length})</h2>
              <div className="space-y-2">
                {cancelledTasks.map(task => (
                  <div key={task.id} className="card p-4 flex items-center justify-between gap-4 opacity-60">
                    <p className="text-sm text-soil-700">{task.item_description || `Task #${task.id}`}</p>
                    <span className={`pill border text-[10px] ${statusClasses("cancelled")}`}>cancelled</span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Quick links */}
          <div className="grid grid-cols-2 gap-3">
            {[
              { label:"View Sold & Donated Board", page:"sold-donated",   icon:Package, cls:"from-amber-50 to-orange-50 border-amber-200 text-amber-700" },
              { label:"Our Eco Collaborations",    page:"collaborations", icon:Users,    cls:"from-teal-50 to-cyan-50 border-teal-200 text-teal-700" },
            ].map(({ label, page, icon:Icon, cls }) => (
              <button key={page} onClick={() => onNavigate(page)}
                className={`card p-5 bg-gradient-to-br ${cls} border flex items-center justify-between hover:shadow-md transition-all group`}>
                <span className="font-semibold text-sm flex items-center gap-2"><Icon size={16}/>{label}</span>
                <ExternalLink size={16} className="opacity-50 group-hover:opacity-100 shrink-0"/>
              </button>
            ))}
          </div>
        </div>
      )}
    </DashboardLayout>
  );
};

export default HelperDashboard;
