import React, { useState, useCallback, useEffect } from "react";

import LandingPage     from "./pages/LandingPage";
import AuthPage        from "./pages/AuthPage";
import ArtistDashboard from "./pages/ArtistDashboard";
import UserDashboard   from "./pages/UserDashboard";
import HelperDashboard from "./pages/HelperDashboard";
import SoldDonatedPage from "./pages/SoldDonatedPage";
import CollabsPage     from "./pages/CollabsPage";
import StartupScreen   from "./pages/StartupScreen";

import AIAssistant     from "./components/AIAssistant";
import LoadingSpinner  from "./components/common/LoadingSpinner";
import useAuth         from "./hooks/useAuth";

import "./styles/index.css";

const App = () => {
  const [startupComplete, setStartupComplete] = useState(false);
  const [currentPage, setCurrentPage] = useState("landing");

  const auth = useAuth();

  /* ───────── Navigation ───────── */
  const navigate = useCallback((page) => {
    setCurrentPage(page);
    window.scrollTo({ top: 0, behavior: "instant" });
  }, []);

  /* ───────── Auth flow ───────── */
  const handleAuthSuccess = useCallback(
    (user) => navigate(user.role), // artist | user | helper
    [navigate]
  );

  const handleLogout = useCallback(() => {
    auth.logout();
    navigate("landing");
  }, [auth, navigate]);

  /* ───────── Startup screen ───────── */
  const handleStartupComplete = useCallback(
    () => setStartupComplete(true),
    []
  );

  /* ───────── Auto-redirect if logged in ───────── */
  useEffect(() => {
    if (auth.user && currentPage === "landing" && startupComplete) {
      const t = setTimeout(() => navigate(auth.user.role), 0);
      return () => clearTimeout(t);
    }
  }, [auth.user, currentPage, startupComplete, navigate]);

  /* ───────── Shared dashboard props ───────── */
  const dashProps = {
    user: auth.user,
    onNavigate: navigate,
    onLogout: handleLogout,
  };

  /* ───────── Page registry ───────── */
  const pages = {
    landing: <LandingPage onNavigate={navigate} />,

    auth: (
      <AuthPage
        onNavigate={navigate}
        onAuthSuccess={handleAuthSuccess}
        auth={auth}
      />
    ),

    artist: auth.user
      ? <ArtistDashboard {...dashProps} />
      : pages?.auth,

    user: auth.user
      ? <UserDashboard {...dashProps} />
      : pages?.auth,

    helper: auth.user
      ? <HelperDashboard {...dashProps} />
      : pages?.auth,

    "sold-donated": auth.user
      ? <SoldDonatedPage {...dashProps} />
      : pages?.auth,

    collaborations: (
      <CollabsPage
        onNavigate={navigate}
        onLogout={handleLogout}
        user={auth.user}
      />
    ),
  };

  /* ───────── Startup screen first ───────── */
  if (!startupComplete) {
    return <StartupScreen onComplete={handleStartupComplete} />;
  }

  /* ───────── Main render ───────── */
  return (
    <>
      <div className="page-enter" key={currentPage}>
        {pages[currentPage] ?? pages.landing}
      </div>

      {/* Global AI assistant overlay */}
      <AIAssistant />
    </>
  );
};

export default App;