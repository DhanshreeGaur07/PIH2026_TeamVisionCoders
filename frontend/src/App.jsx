import React, { useState, useCallback, useEffect, useRef } from "react";

import LandingPage from "./pages/LandingPage";
import AuthPage from "./pages/AuthPage";
import ArtworksPage from "./pages/ArtworksPage";
import ArtworkDetailPage from "./pages/ArtworkDetailPage";
import CartPage from "./pages/CartPage";
import OrderSummaryPage from "./pages/OrderSummaryPage";
import ArtistDashboard from "./pages/ArtistDashboard";
import UserDashboard from "./pages/UserDashboard";
import HelperDashboard from "./pages/HelperDashboard";
import OrganisationDashboard from "./pages/OrganisationDashboard";
import SoldDonatedPage from "./pages/SoldDonatedPage";
import CollabsPage from "./pages/CollabsPage";
import useAuth from "./hooks/useAuth";

import "./styles/index.css";

const App = () => {
  const [currentPage, setCurrentPage] = useState("landing");
  const [pageParam, setPageParam] = useState({});
  const historyRef = useRef([]);
  const [cart, setCart] = useState([]);

  const auth = useAuth();

  const navigate = useCallback((page, param) => {
    if (page === "back") {
      const prev = historyRef.current.pop();
      if (prev) {
        setCurrentPage(prev.page);
        setPageParam(prev.param || {});
      }
      window.scrollTo({ top: 0, behavior: "instant" });
      return;
    }
    historyRef.current.push({ page: currentPage, param: pageParam });
    setCurrentPage(page);
    setPageParam(param || {});
    window.scrollTo({ top: 0, behavior: "instant" });
  }, [currentPage, pageParam]);

  const navigateBack = useCallback(() => navigate("back"), [navigate]);

  const handleAuthSuccess = useCallback((user) => navigate("artworks"), [navigate]);

  const handleLogout = useCallback(() => {
    auth.logout();
    navigate("landing");
  }, [auth, navigate]);

  // Removed automatic redirect to artworks page on load so the Landing page always shows.
  // useEffect(() => {
  //   if (auth.user && currentPage === "landing") {
  //     const t = setTimeout(() => navigate("artworks"), 0);
  //     return () => clearTimeout(t);
  //   }
  // }, [auth.user, currentPage, startupComplete, navigate]);

  const addToCart = useCallback((item) => {
    setCart((c) => {
      const existing = c.find((x) => x.id === item.id);
      if (existing) return c.map((x) => x.id === item.id ? { ...x, quantity: (x.quantity || 1) + 1 } : x);
      return [...c, { ...item, quantity: 1 }];
    });
  }, []);

  const removeFromCart = useCallback((id) => {
    setCart((c) => c.filter((x) => x.id !== id));
  }, []);

  const dashProps = {
    user: auth.user,
    onNavigate: navigate,
    onLogout: handleLogout,
  };

  const navProps = { onNavigate: navigate, onNavigateBack: navigateBack };

  const pages = {
    landing: <LandingPage {...navProps} />,
    auth: <AuthPage {...navProps} onAuthSuccess={handleAuthSuccess} auth={auth} />,
    artworks: <ArtworksPage {...navProps} user={auth.user} />,
    "artwork-detail": (
      <ArtworkDetailPage
        artworkId={pageParam.artworkId}
        user={auth.user}
        onNavigate={navigate}
        onNavigateBack={navigateBack}
        onAddToCart={addToCart}
      />
    ),
    cart: <CartPage cart={cart} onRemoveFromCart={removeFromCart} {...navProps} />,
    "order-summary": <OrderSummaryPage cart={cart} onNavigateBack={navigateBack} onNavigate={navigate} user={auth.user} />,
    artist: auth.user ? <ArtistDashboard {...dashProps} onNavigateBack={navigateBack} /> : null,
    user: auth.user ? <UserDashboard {...dashProps} onNavigateBack={navigateBack} /> : null,
    helper: auth.user ? <HelperDashboard {...dashProps} onNavigateBack={navigateBack} /> : null,
    organisation: auth.user ? <OrganisationDashboard {...dashProps} onNavigateBack={navigateBack} /> : null,
    "sold-donated": auth.user ? <SoldDonatedPage {...dashProps} onNavigateBack={navigateBack} /> : null,
    collaborations: <CollabsPage {...navProps} onLogout={handleLogout} user={auth.user} />,
  };

  const rendered = pages[currentPage];
  if (rendered === null && (currentPage === "artist" || currentPage === "user" || currentPage === "helper" || currentPage === "sold-donated" || currentPage === "organisation")) {
    return pages.auth;
  }

  return rendered ?? <LandingPage {...navProps} />;
};

export default App;
