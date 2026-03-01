import React, { useState } from "react";
import {
    BarChart2, HelpCircle, Package, Truck, Award, Leaf, Search, Calendar, MapPin, Recycle
} from "lucide-react";
import DashboardLayout from "../components/layout/DashboardLayout";
import StatCard from "../components/common/StatCard";
import LoadingSpinner from "../components/common/LoadingSpinner";
import ErrorBanner from "../components/common/ErrorBanner";
import useFetch from "../hooks/useFetch";
import { usersAPI, itemsAPI } from "../services/api";

const OrgProfile = ({ profile, stats }) => (
    <div className="card bg-gradient-to-br from-indigo-50 to-blue-50 border-indigo-200 p-6 mb-8 relative overflow-hidden">
        <div className="absolute top-0 right-0 w-48 h-48 bg-indigo-100 rounded-full -translate-y-20 translate-x-20 opacity-30 pointer-events-none" />
        <div className="relative flex flex-wrap items-start gap-5">
            <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-indigo-500 to-blue-600 flex items-center justify-center text-white text-2xl font-display font-black shadow-lg shrink-0">
                {profile.name?.[0]?.toUpperCase()}
            </div>
            <div className="flex-1 min-w-0">
                <div className="flex flex-wrap items-center gap-2 mb-1">
                    <h2 className="font-display font-black text-xl text-soil-900">{profile.name}</h2>
                    <span className="pill bg-indigo-100 text-indigo-800 border-indigo-200 text-[10px] font-bold">🏢 ORGANISATION</span>
                </div>
                <p className="text-xs text-soil-500 max-w-lg mb-2">{profile.email}</p>
                <div className="flex flex-wrap items-center gap-4 text-xs font-semibold text-soil-600">
                    <span className="flex items-center gap-1"><BarChart2 size={13} className="text-indigo-600" /> {stats?.role_stats?.total_waste_kg || 0} kg Utilised</span>
                    <span className="flex items-center gap-1"><HelpCircle size={13} className="text-indigo-600" /> {stats?.role_stats?.active_requests || 0} Requests</span>
                </div>
            </div>
            <div className="shrink-0">
                <div className="inline-flex items-center gap-2 bg-indigo-700 text-white rounded-2xl px-4 py-2.5 shadow-md">
                    <Leaf size={16} />
                    <div>
                        <p className="font-display font-black text-xl leading-none">{profile.green_coins ?? 0}</p>
                        <p className="text-indigo-200 text-[10px]">Green Coins</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
);

const OrganisationDashboard = ({ user, onNavigate, onLogout, onNavigateBack }) => {
    const [activeTab, setActiveTab] = useState("waste-utilised");

    const { data: profileData, loading: profileLoading } = useFetch(() => usersAPI.getById(user.id), [user.id]);
    const { data: statsData, loading: statsLoading } = useFetch(() => usersAPI.getStats(user.id), [user.id]);
    const { data: myItemsData, loading: itemsLoading, error: itemsError } = useFetch(() => itemsAPI.getMy(), [user.id]);

    const profile = profileData?.user || user;
    const stats = statsData?.stats || {};
    const myItems = myItemsData?.items || [];

    const utilisedItems = myItems.filter(i => i.status === "utilised" || i.status === "completed" || i.status === "sold");
    const requests = myItems.filter(i => i.status === "pending" || i.status === "active");

    const totalWaste = utilisedItems.reduce((acc, item) => acc + (item.waste_used_kg || item.weight_kg || 5), 0);
    const activeRequestsCount = requests.length;

    return (
        <DashboardLayout role="organisation" user={user} activeTab={activeTab} onTabChange={setActiveTab} onLogout={onLogout} onNavigate={onNavigate} onNavigateBack={onNavigateBack}>
            <div className="mb-6 flex flex-wrap items-center justify-between gap-3">
                <div>
                    <p className="text-soil-400 text-sm font-medium mb-0.5">Welcome, {user.name?.split(" ")[0]} 🏢</p>
                    <h1 className="font-display font-black text-3xl text-soil-900">Organisation Panel</h1>
                </div>
            </div>

            {profileLoading ? <div className="card h-28 animate-pulse bg-indigo-50 mb-8" /> : <OrgProfile profile={profile} stats={{ ...stats, role_stats: { total_waste_kg: totalWaste, active_requests: activeRequestsCount } }} />}

            {statsLoading ? (
                <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">{[...Array(4)].map((_, i) => <div key={i} className="card h-28 animate-pulse bg-soil-50" />)}</div>
            ) : (
                <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
                    <StatCard icon={BarChart2} label="Waste Utilised" value={`${totalWaste} kg`} sub="All time" accent="indigo" />
                    <StatCard icon={HelpCircle} label="Active Requests" value={activeRequestsCount} sub="Awaiting fulfilment" accent="blue" />
                    <StatCard icon={Package} label="Completed Projects" value={utilisedItems.length} sub="Successfully built" accent="green" />
                    <StatCard icon={Leaf} label="Green Coins" value={profile.green_coins || 0} sub="Balance" accent="teal" />
                </div>
            )}

            <div className="flex gap-1 bg-soil-50 border border-soil-200 rounded-2xl p-1 w-fit mb-6">
                {[{ id: "waste-utilised", label: "📊 Waste Utilised" }, { id: "requests-status", label: "📋 Requests Status" }].map(t => (
                    <button key={t.id} onClick={() => setActiveTab(t.id)} className={`px-4 py-2 rounded-xl text-sm font-semibold transition-all ${activeTab === t.id ? "bg-indigo-600 text-white shadow" : "text-soil-500 hover:text-soil-800"}`}>
                        {t.label}
                    </button>
                ))}
            </div>

            {activeTab === "waste-utilised" && (
                <div className="space-y-4">
                    <h2 className="font-display font-bold text-xl text-soil-900 mb-4">Amount of Waste Utilised</h2>
                    {itemsLoading ? <LoadingSpinner /> : itemsError ? <ErrorBanner message={itemsError} /> : utilisedItems.length === 0 ? (
                        <div className="card p-16 text-center text-soil-400">
                            <BarChart2 size={36} className="mx-auto mb-3 opacity-40" />
                            <p className="font-semibold text-lg">No waste utilised records yet.</p>
                        </div>
                    ) : (
                        <div className="grid gap-3">
                            {utilisedItems.map(item => (
                                <div key={item.id} className="card p-4 flex items-center gap-4 border-indigo-100">
                                    <div className="w-12 h-12 rounded-xl bg-indigo-50 border border-indigo-100 flex items-center justify-center text-indigo-600 shrink-0">
                                        <Recycle size={20} />
                                    </div>
                                    <div className="flex-1">
                                        <p className="font-semibold text-soil-900 text-sm">{item.title}</p>
                                        <p className="text-xs text-soil-500">{item.category} • Completed on {new Date(item.updated_at).toLocaleDateString()}</p>
                                    </div>
                                    <div className="text-right">
                                        <p className="font-bold text-indigo-700">{item.waste_used_kg || item.weight_kg || 5} kg</p>
                                        <p className="text-[10px] text-soil-400">Utilised</p>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                </div>
            )}

            {activeTab === "requests-status" && (
                <div className="space-y-4">
                    <h2 className="font-display font-bold text-xl text-soil-900 mb-4">Requests of Waste Required</h2>
                    {itemsLoading ? <LoadingSpinner /> : itemsError ? <ErrorBanner message={itemsError} /> : requests.length === 0 ? (
                        <div className="card p-16 text-center text-soil-400">
                            <HelpCircle size={36} className="mx-auto mb-3 opacity-40" />
                            <p className="font-semibold text-lg">No active requests.</p>
                        </div>
                    ) : (
                        <div className="grid gap-3">
                            {requests.map(req => (
                                <div key={req.id} className="card p-4 flex items-center gap-4 border-blue-100">
                                    <div className="w-12 h-12 rounded-xl bg-blue-50 border border-blue-100 flex items-center justify-center text-blue-600 shrink-0">
                                        <Package size={20} />
                                    </div>
                                    <div className="flex-1">
                                        <p className="font-semibold text-soil-900 text-sm">{req.title}</p>
                                        <p className="text-xs text-soil-500">{req.category} • Needed for upcoming project</p>
                                    </div>
                                    <div className="text-right">
                                        <span className="pill bg-blue-100 text-blue-800 border-blue-200 text-xs font-bold px-2 py-1">Pending</span>
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

export default OrganisationDashboard;
