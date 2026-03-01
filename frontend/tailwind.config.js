/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{js,jsx}"],
  theme: {
    extend: {
      fontFamily: {
        display: ["'Playfair Display'", "serif"],
        body: ["'Plus Jakarta Sans'", "sans-serif"],
        mono: ["'JetBrains Mono'", "monospace"],
      },
      colors: {
        /* Primary eco-green palette */
        forest: {
          50:  "#f0faf2",
          100: "#d8f3de",
          200: "#b3e7bf",
          300: "#7ed49a",
          400: "#47bb72",
          500: "#259f52",
          600: "#178040",
          700: "#136535",
          800: "#12502c",
          900: "#0f4225",
        },
        /* Earthy amber / craft */
        craft: {
          50:  "#fdf8ef",
          100: "#f9efd6",
          200: "#f2dba8",
          300: "#e9c270",
          400: "#dea040",
          500: "#c8831f",
          600: "#a86516",
          700: "#864c14",
          800: "#6d3d15",
          900: "#5a3314",
        },
        /* Warm parchment / soil */
        soil: {
          50:  "#faf7f2",
          100: "#f2ece0",
          200: "#e5d8c2",
          300: "#d3be9a",
          400: "#be9f70",
          500: "#a88450",
          600: "#8e6b3e",
          700: "#745535",
          800: "#5f4530",
          900: "#4e3928",
        },
      },
      animation: {
        "float-slow": "floatY 6s ease-in-out infinite",
        "float-med":  "floatY 4s ease-in-out infinite",
        "spin-slow":  "spin 12s linear infinite",
        "pulse-soft": "pulseSoft 3s ease-in-out infinite",
        "slide-up":   "slideUp 0.5s ease-out forwards",
        "fade-in":    "fadeIn 0.4s ease-out forwards",
        "bounce-soft":"bounceSoft 2s ease-in-out infinite",
      },
      keyframes: {
        floatY: {
          "0%,100%": { transform: "translateY(0)" },
          "50%":     { transform: "translateY(-12px)" },
        },
        pulseSoft: {
          "0%,100%": { opacity: "1" },
          "50%":     { opacity: "0.6" },
        },
        slideUp: {
          from: { opacity: "0", transform: "translateY(20px)" },
          to:   { opacity: "1", transform: "translateY(0)" },
        },
        fadeIn: {
          from: { opacity: "0" },
          to:   { opacity: "1" },
        },
        bounceSoft: {
          "0%,100%": { transform: "translateY(0)" },
          "50%":     { transform: "translateY(-6px)" },
        },
      },
      backgroundImage: {
        "leaf-pattern":    "url(\"data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%2317803f' fill-opacity='0.05'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E\")",
        "dots-pattern":    "radial-gradient(circle, #17803f15 1px, transparent 1px)",
        "grain":           "url(\"data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='0.04'/%3E%3C/svg%3E\")",
      },
    },
  },
  plugins: [],
};
