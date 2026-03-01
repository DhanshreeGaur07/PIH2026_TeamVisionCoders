// ============================================================
//  index.js  — Application entry point
//  Mounts the React application into the DOM root element.
// ============================================================
import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";

/**
 * Create the React root and render the App component.
 * StrictMode is enabled to surface potential issues during development.
 */
const root = ReactDOM.createRoot(document.getElementById("root"));

root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
