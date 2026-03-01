import React, { useState, useCallback } from "react";
import LandingPage from "./pages/LandingPage";
import AuthPage from "./pages/AuthPage";
import ArtistDashboard from "./pages/ArtistDashboard";
import UserDashboard from "./pages/UserDashboard";
import HelperDashboard from "./pages/HelperDashboard";
import SoldDonatedPage from "./pages/SoldDonatedPage";
import CollabsPage from "./pages/CollabsPage";
import LoadingSpinner from "./components/common/LoadingSpinner";
import useAuth from "./hooks/useAuth";
import StartupScreen from "./pages/StartupScreen"; // ← new import
import "./styles/index.css";
import AIAssistant from './components/AIAssistant';

const App = () => {
  const [startupComplete, setStartupComplete] = useState(false);
  const [currentPage, setCurrentPage] = useState("landing");
  const auth = useAuth();

  const navigate = useCallback((page) => {
    setCurrentPage(page);
    window.scrollTo({ top: 0, behavior: "instant" });
  }, []);

  // After login, go to the role dashboard
  const handleAuthSuccess = useCallback((user) => {
    navigate(user.role); // "artist" | "user" | "helper"
  }, [navigate]);

  const handleLogout = useCallback(() => {
    auth.logout();
    navigate("landing");
  }, [auth, navigate]);

  const handleStartupComplete = useCallback(() => setStartupComplete(true), []);

  // Shared props for all dashboard pages
  const dashProps = { user: auth.user, onNavigate: navigate, onLogout: handleLogout };

  // If user already logged in and lands on root, go to their dashboard (after startup)
  // This effect runs after startupComplete becomes true
  React.useEffect(() => {
    if (auth.user && currentPage === "landing") {
      // Use setTimeout to avoid immediate state update during render
      const timer = setTimeout(() => navigate(auth.user.role), 0);
      return () => clearTimeout(timer);
    }
  }, [auth.user, currentPage, navigate]);

  const pages = {
    landing: <LandingPage onNavigate={navigate} />,
    auth: <AuthPage onNavigate={navigate} onAuthSuccess={handleAuthSuccess} auth={auth} />,

    // Role dashboards — each gets the authenticated user object
    artist: auth.user ? <ArtistDashboard  {...dashProps} /> : <AuthPage onNavigate={navigate} onAuthSuccess={handleAuthSuccess} auth={auth} />,
    user: auth.user ? <UserDashboard    {...dashProps} /> : <AuthPage onNavigate={navigate} onAuthSuccess={handleAuthSuccess} auth={auth} />,
    helper: auth.user ? <HelperDashboard  {...dashProps} /> : <AuthPage onNavigate={navigate} onAuthSuccess={handleAuthSuccess} auth={auth} />,

    // Shared pages — visible to all logged-in users
    "sold-donated": auth.user ? <SoldDonatedPage  {...dashProps} /> : <AuthPage onNavigate={navigate} onAuthSuccess={handleAuthSuccess} auth={auth} />,
    "collaborations": <CollabsPage onNavigate={navigate} onLogout={handleLogout} user={auth.user} />,
  };

  // ⭐ Show startup screen first
  if (!startupComplete) {
    return <StartupScreen onComplete={handleStartupComplete} />;
  }

  // Then normal app
  return (
    <div className="page-enter" key={currentPage}>
      {pages[currentPage] ?? <LandingPage onNavigate={navigate} />}
    </div>
  );
};

function App() {
  return (
    <div className="min-h-screen bg-slate-100 py-10">
      <h1 className="text-center text-4xl font-extrabold text-slate-900 mb-2">Scrap Crafters</h1>
      <p className="text-center text-slate-600 mb-10">Turn your waste into wonder with AI.</p>
      <AIAssistant />
    </div>
  );
}

export default App;