// ============================================================
//  DashboardLayout.js  —  Navbar + Sidebar + main content
// ============================================================
import React from "react";
import Navbar  from "./Navbar";
import Sidebar from "./Sidebar";

const DashboardLayout = ({ role, user, activeTab, onTabChange, onLogout, onNavigate, onNavigateBack, children }) => (
  <div className="min-h-screen bg-[var(--clr-bg)] flex flex-col">
    <Navbar role={role} user={user} onLogout={onLogout} onNavigate={onNavigate} onNavigateBack={onNavigateBack} />
    <div className="flex flex-1 max-w-7xl mx-auto w-full">
      <Sidebar role={role} activeTab={activeTab} onTabChange={onTabChange} onNavigate={onNavigate} />
      <main className="flex-1 px-4 sm:px-6 py-8 min-w-0">
        {children}
      </main>
    </div>
  </div>
);

export default DashboardLayout;
