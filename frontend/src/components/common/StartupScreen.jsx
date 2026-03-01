import React, { useEffect, useState, useRef, useCallback } from "react";

const TOTAL_DURATION = 15000;

const ACTS = [
    {
        bg: ["#060a06", "#0a1208"],
        textMain: "Every discarded thing",
        textSub: "carries a life before this moment",
        subColor: "rgba(120,140,120,0.7)",
        shapeColor: "#1a1a18",
        shapeStroke: "rgba(80,80,70,0.5)",
        glowColor: "rgba(40,50,35,0.0)",
        emoji: "🗑️",
    },
    {
        bg: ["#07100a", "#0b180d"],
        textMain: "Waiting in the forgotten",
        textSub: "pile after pile  ·  street after street",
        subColor: "rgba(140,120,80,0.72)",
        shapeColor: "#2a1f12",
        shapeStroke: "rgba(120,90,50,0.6)",
        glowColor: "rgba(90,60,20,0.14)",
        emoji: "📦",
    },
    {
        bg: ["#091208", "#0e1f0c"],
        textMain: "Until a hand reaches in",
        textSub: "sorted  ·  cleaned  ·  reimagined",
        subColor: "rgba(170,150,70,0.78)",
        shapeColor: "#3b3010",
        shapeStroke: "rgba(190,155,50,0.6)",
        glowColor: "rgba(160,115,30,0.2)",
        emoji: "♻️",
    },
    {
        bg: ["#091a0c", "#0f2a12"],
        textMain: "And sees possibility",
        textSub: "artists  ·  makers  ·  dreamers",
        subColor: "rgba(80,190,115,0.78)",
        shapeColor: "#174d28",
        shapeStroke: "rgba(50,190,105,0.65)",
        glowColor: "rgba(28,155,72,0.26)",
        emoji: "🌱",
    },
    {
        bg: ["#071a0a", "#0d2e10"],
        textMain: "Into something extraordinary",
        textSub: "art  ·  life  ·  purpose  ·  wonder",
        subColor: "rgba(100,218,145,0.82)",
        shapeColor: "#1a6635",
        shapeStroke: "rgba(75,225,130,0.72)",
        glowColor: "rgba(20,185,82,0.3)",
        emoji: "🎨",
    },
    {
        bg: ["#061608", "#0b2410"],
        textMain: "SCRAP·CRAFTERS",
        textSub: "where waste becomes wonder",
        subColor: "rgba(130,238,165,0.88)",
        shapeColor: "#178040",
        shapeStroke: "rgba(95,245,162,0.82)",
        glowColor: "rgba(23,128,64,0.42)",
        emoji: "✨",
    },
];

/* ── Morph paths — one per act ── */
const PATHS = [
    "M200,95 C228,68 268,72 285,102 C308,140 298,185 275,210 C248,238 205,242 178,222 C146,200 138,165 145,132 C151,105 172,122 200,95 Z",
    "M195,88 C228,58 275,65 294,100 C320,145 308,196 280,222 C250,250 202,254 172,232 C136,206 130,165 140,128 C149,97 162,118 195,88 Z",
    "M198,80 C235,52 282,60 300,98 C322,144 310,200 280,226 C248,254 198,256 168,232 C132,204 128,160 140,122 C152,88 162,108 198,80 Z",
    "M200,74 C240,48 290,58 308,98 C330,146 316,206 284,232 C252,258 200,260 168,234 C130,206 126,158 140,118 C154,82 162,100 200,74 Z",
    "M200,68 C244,44 296,58 314,100 C336,150 320,212 286,238 C254,264 200,264 166,238 C126,208 122,156 138,114 C154,76 158,92 200,68 Z",
    "M200,62 C248,40 302,58 320,104 C342,156 324,218 288,244 C256,268 200,268 164,242 C122,210 118,154 136,110 C154,70 154,84 200,62 Z",
];

/* ── Particles ── */
const PARTICLES = Array.from({ length: 26 }, (_, i) => ({
    id: i,
    x: 4 + (i * 14.3) % 92,
    y: 4 + (i * 18.1) % 90,
    r: 1.2 + (i % 5) * 1.1,
    dur: 9 + (i % 6) * 3.6,
    delay: (i % 7) * 2.9,
    color: ["#4ade80", "#c8831f", "#a3e635", "#86efac", "#fbbf24"][i % 6],
    opacity: 0.07 + (i % 5) * 0.055,
}));

const easeInOutSine = t => -(Math.cos(Math.PI * t) - 1) / 2;

// Persist start time across React StrictMode remounts so the intro doesn't restart
let globalStartTime = null;

function lerpPath(pA, pB, t) {
    const nA = pA.match(/-?\d+(\.\d+)?/g).map(Number);
    const nB = pB.match(/-?\d+(\.\d+)?/g).map(Number);
    let i = 0;
    return pA.replace(/-?\d+(\.\d+)?/g, () => {
        const v = nA[i] + (nB[i] - nA[i]) * t;
        i++;
        return Math.round(v * 10) / 10;
    });
}

export default function StartupScreen({ onComplete }) {
    const [progress, setProgress] = useState(0);
    const [morphPath, setMorphPath] = useState(PATHS[0]);
    const [actIndex, setActIndex] = useState(0);
    const [textVisible, setTextVisible] = useState(false);
    const [exiting, setExiting] = useState(false);
    const [showSkip, setShowSkip] = useState(false);

    const startRef = useRef(null);
    const rafRef = useRef(null);
    const exitingRef = useRef(false);
    const actRef = useRef(0);
    const onCompleteRef = useRef(onComplete);
    onCompleteRef.current = onComplete;

    const finish = useCallback(() => {
        if (exitingRef.current) return;
        exitingRef.current = true;
        globalStartTime = null; // allow fresh start if component mounts again
        setExiting(true);
        cancelAnimationFrame(rafRef.current);
        setTimeout(() => onCompleteRef.current?.(), 1100);
    }, []);

    useEffect(() => {
        if (globalStartTime === null) globalStartTime = performance.now();
        startRef.current = globalStartTime;
        setTimeout(() => setTextVisible(true), 500);
        setTimeout(() => setShowSkip(true), 2500);

        const tick = (now) => {
            const elapsed = now - startRef.current;
            const p = Math.min(elapsed / TOTAL_DURATION, 1);
            setProgress(p);

            const rawAct = p * (ACTS.length - 1);
            const ai = Math.min(Math.floor(rawAct), ACTS.length - 2);
            const frac = easeInOutSine(rawAct - ai);

            if (ai !== actRef.current) {
                actRef.current = ai;
                setActIndex(ai);
                setTextVisible(false);
                setTimeout(() => setTextVisible(true), 350);
            }

            setMorphPath(lerpPath(PATHS[ai], PATHS[ai + 1], frac));

            if (p >= 1) {
                setActIndex(ACTS.length - 1);
                setTimeout(finish, 1400);
                return;
            }
            rafRef.current = requestAnimationFrame(tick);
        };
        rafRef.current = requestAnimationFrame(tick);
        return () => cancelAnimationFrame(rafRef.current);
    }, [finish]);

    useEffect(() => {
        const h = () => finish();
        window.addEventListener("keydown", h);
        window.addEventListener("mousedown", h);
        window.addEventListener("touchstart", h);
        return () => {
            window.removeEventListener("keydown", h);
            window.removeEventListener("mousedown", h);
            window.removeEventListener("touchstart", h);
        };
    }, [finish]);

    const act = ACTS[Math.min(actIndex, ACTS.length - 1)];
    const isFinal = actIndex >= ACTS.length - 1;

    return (
        <div style={{
            position: "fixed", inset: 0, zIndex: 9999,
            display: "flex", flexDirection: "column",
            alignItems: "center", justifyContent: "center",
            overflow: "hidden",
            background: `linear-gradient(160deg, ${act.bg[0]} 0%, ${act.bg[1]} 100%)`,
            opacity: exiting ? 0 : 1,
            transition: exiting
                ? "opacity 1.0s cubic-bezier(0.4,0,0.2,1)"
                : "background 2.8s ease",
        }}>

            {/* Film grain */}
            <div style={{
                position: "absolute", inset: 0, pointerEvents: "none", opacity: 0.032,
                backgroundImage: `url("data:image/svg+xml,%3Csvg viewBox='0 0 512 512' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='g'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.72' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23g)'/%3E%3C/svg%3E")`,
                backgroundSize: "256px 256px",
            }} />

            {/* Atmospheric radial glow */}
            <div style={{
                position: "absolute", inset: 0, pointerEvents: "none",
                background: `radial-gradient(ellipse 52% 52% at 50% 46%, ${act.glowColor} 0%, transparent 75%)`,
                transition: "background 3.2s ease",
            }} />

            {/* Scanlines */}
            <div style={{
                position: "absolute", inset: 0, pointerEvents: "none",
                backgroundImage: "repeating-linear-gradient(0deg,transparent,transparent 2px,rgba(255,255,255,0.01) 2px,rgba(255,255,255,0.01) 4px)",
            }} />

            {/* Particle field */}
            <svg style={{ position: "absolute", inset: 0, width: "100%", height: "100%", pointerEvents: "none", overflow: "visible" }}>
                {PARTICLES.map(p => (
                    <circle key={p.id}
                        cx={`${p.x}%`} cy={`${p.y}%`}
                        r={p.r * (0.5 + progress * 0.7)}
                        fill={p.color}
                        opacity={p.opacity * (0.3 + progress * 0.9)}
                        style={{ animation: `pdrift${p.id % 6} ${p.dur}s ${p.delay}s ease-in-out infinite alternate` }}
                    />
                ))}
            </svg>

            {/* Top wordmark — fades in gently */}
            <div style={{
                position: "absolute", top: 34, left: 0, right: 0,
                display: "flex", justifyContent: "center",
                opacity: progress > 0.06 ? Math.min((progress - 0.06) * 6, 0.55) : 0,
                transition: "opacity 2s ease",
                pointerEvents: "none",
            }}>
                <div style={{
                    display: "flex", alignItems: "center", gap: 10,
                    paddingBottom: 10,
                    borderBottom: "1px solid rgba(255,255,255,0.05)",
                }}>
                    <span style={{ fontSize: 14 }}>♻️</span>
                    <span style={{
                        fontFamily: "'Playfair Display', serif",
                        fontSize: 12, fontWeight: 600,
                        letterSpacing: "0.28em",
                        color: "rgba(215,210,200,0.55)",
                        textTransform: "uppercase",
                    }}>
                        Scrap · Crafters
                    </span>
                </div>
            </div>

            {/* ════════════════════════════
          CENTRAL STAGE
      ════════════════════════════ */}
            <div style={{
                position: "relative", zIndex: 10,
                display: "flex", flexDirection: "column",
                alignItems: "center", gap: 0,
                transform: exiting ? "scale(0.97)" : "scale(1)",
                transition: exiting ? "transform 1s ease" : "none",
            }}>

                {/* Shape container */}
                <div style={{
                    position: "relative",
                    width: 360, height: 340,
                    display: "flex", alignItems: "center", justifyContent: "center",
                }}>

                    {/* Outer halo */}
                    <div style={{
                        position: "absolute",
                        width: 400, height: 400, borderRadius: "50%",
                        background: `radial-gradient(circle, ${act.glowColor} 0%, transparent 70%)`,
                        transition: "background 3s ease",
                        animation: "haloBreath 7s ease-in-out infinite",
                    }} />

                    {/* Slow orbit ring 1 */}
                    <div style={{
                        position: "absolute",
                        width: 295, height: 295, borderRadius: "50%",
                        border: `1px solid ${act.shapeStroke}`,
                        opacity: 0.25,
                        transition: "border-color 2.8s ease",
                        animation: "ringA 50s linear infinite",
                    }} />

                    {/* Slow orbit ring 2 — dashed */}
                    <div style={{
                        position: "absolute",
                        width: 245, height: 245, borderRadius: "50%",
                        border: "1px dashed rgba(255,255,255,0.05)",
                        animation: "ringB 80s linear infinite reverse",
                    }} />

                    {/* The SVG morphing form */}
                    <svg
                        viewBox="118 48 204 244"
                        width="310" height="310"
                        style={{
                            overflow: "visible",
                            filter: `drop-shadow(0 0 28px ${act.glowColor}) drop-shadow(0 0 56px ${act.glowColor})`,
                            transition: "filter 3s ease",
                        }}
                    >
                        <defs>
                            <linearGradient id="sg" x1="0" y1="0" x2="0.4" y2="1">
                                <stop offset="0%" stopColor={act.shapeStroke} stopOpacity="0.88" />
                                <stop offset="100%" stopColor={act.shapeColor} stopOpacity="1" />
                            </linearGradient>
                            <filter id="gblur"><feGaussianBlur stdDeviation="9" /></filter>
                            <filter id="sblur"><feGaussianBlur stdDeviation="2.5" /></filter>
                        </defs>

                        {/* Deep glow */}
                        <path d={morphPath}
                            fill={act.shapeColor} opacity="0.22"
                            filter="url(#gblur)"
                            transform="translate(220,170) scale(1.22) translate(-220,-170)"
                            style={{ transition: "fill 2.8s ease" }}
                        />
                        {/* Mid glow */}
                        <path d={morphPath}
                            fill={act.shapeStroke} opacity="0.1"
                            filter="url(#sblur)"
                            transform="translate(220,170) scale(1.06) translate(-220,-170)"
                            style={{ transition: "fill 2.8s ease" }}
                        />
                        {/* Main body */}
                        <path d={morphPath}
                            fill="url(#sg)"
                            opacity="0.9"
                        />
                        {/* Inner edge shimmer */}
                        <path d={morphPath}
                            fill="none"
                            stroke="rgba(255,255,255,0.07)"
                            strokeWidth="1.2"
                            transform="translate(220,170) scale(0.92) translate(-220,-170)"
                        />
                        {/* Emoji */}
                        <text x="220" y="175"
                            textAnchor="middle" dominantBaseline="middle"
                            fontSize="58"
                            style={{
                                userSelect: "none",
                                filter: "drop-shadow(0 2px 14px rgba(0,0,0,0.55))",
                                transition: "all 2s ease",
                            }}
                        >
                            {act.emoji}
                        </text>
                    </svg>

                    {/* 3 orbiting micro-dots */}
                    {[0, 1, 2].map(i => {
                        const angle = (i * 120 + progress * 360) * (Math.PI / 180);
                        const r = 148;
                        const cx = 180 + Math.cos(angle) * r;
                        const cy = 170 + Math.sin(angle) * r;
                        return (
                            <div key={i} style={{
                                position: "absolute",
                                left: cx, top: cy,
                                width: 4, height: 4, borderRadius: "50%",
                                background: act.shapeStroke,
                                boxShadow: `0 0 8px ${act.shapeStroke}`,
                                opacity: 0.45 + progress * 0.45,
                                transition: "background 2.5s ease, box-shadow 2.5s ease",
                                transform: "translate(-50%,-50%)",
                            }} />
                        );
                    })}
                </div>

                {/* ── Text block ── */}
                <div style={{
                    textAlign: "center",
                    maxWidth: 560,
                    padding: "0 36px",
                    marginTop: -12,
                    opacity: textVisible ? 1 : 0,
                    transform: textVisible ? "translateY(0px)" : "translateY(18px)",
                    transition: "opacity 1.6s cubic-bezier(0.4,0,0.2,1), transform 1.6s cubic-bezier(0.4,0,0.2,1)",
                }}>

                    {/* Chapter counter */}
                    <p style={{
                        fontFamily: "'Plus Jakarta Sans', sans-serif",
                        fontSize: 9, fontWeight: 500,
                        color: "rgba(255,255,255,0.18)",
                        letterSpacing: "0.38em",
                        textTransform: "uppercase",
                        marginBottom: 18,
                    }}>
                        {String(Math.min(actIndex + 1, ACTS.length)).padStart(2, "0")}&nbsp;&nbsp;
                        <span style={{ opacity: 0.4 }}>—</span>
                        &nbsp;&nbsp;{String(ACTS.length).padStart(2, "0")}
                    </p>

                    {/* Headline */}
                    <h1 style={{
                        fontFamily: "'Playfair Display', serif",
                        fontSize: "clamp(28px, 4.2vw, 46px)",
                        fontWeight: isFinal ? 900 : 700,
                        color: "rgba(245,240,230,0.94)",
                        letterSpacing: isFinal ? "0.15em" : "-0.01em",
                        lineHeight: 1.16,
                        marginBottom: 18,
                        textShadow: `0 0 70px ${act.glowColor}`,
                        transition: "text-shadow 2.5s ease, letter-spacing 1.8s ease, font-weight 1s ease",
                    }}>
                        {act.textMain}
                    </h1>

                    {/* Hair-line divider */}
                    <div style={{
                        width: 32, height: 1,
                        background: act.subColor,
                        margin: "0 auto 16px",
                        transition: "background 2.5s ease",
                        opacity: 0.7,
                    }} />

                    {/* Subtitle */}
                    <p style={{
                        fontFamily: "'Plus Jakarta Sans', sans-serif",
                        fontSize: "clamp(10px, 1.4vw, 12.5px)",
                        fontWeight: 400,
                        color: act.subColor,
                        letterSpacing: "0.28em",
                        textTransform: "uppercase",
                        lineHeight: 2,
                        transition: "color 2.5s ease",
                    }}>
                        {act.textSub}
                    </p>
                </div>
            </div>

            {/* ── Bottom progress line ── */}
            <div style={{
                position: "absolute", bottom: 0, left: 0, right: 0,
                height: 1,
                background: "rgba(255,255,255,0.04)",
            }}>
                <div style={{
                    height: "100%",
                    width: `${progress * 100}%`,
                    background: `linear-gradient(90deg, rgba(23,128,64,0.5), ${act.shapeStroke})`,
                    transition: "background 2.5s ease",
                    boxShadow: `0 0 6px ${act.glowColor}`,
                }} />
            </div>

            {/* ── Skip: button + whisper ── */}
            {showSkip && !exiting && (
                <div style={{
                    position: "absolute", bottom: 18, right: 24,
                    display: "flex", alignItems: "center", gap: 12,
                }}>
                    <button
                        type="button"
                        onClick={finish}
                        style={{
                            fontFamily: "'Plus Jakarta Sans', sans-serif",
                            fontSize: 10,
                            letterSpacing: "0.2em",
                            textTransform: "uppercase",
                            color: "rgba(255,255,255,0.5)",
                            background: "rgba(255,255,255,0.08)",
                            border: "1px solid rgba(255,255,255,0.15)",
                            borderRadius: 6,
                            padding: "8px 14px",
                            cursor: "pointer",
                            userSelect: "none",
                        }}
                    >
                        Skip
                    </button>
                    <span style={{
                        fontFamily: "'Plus Jakarta Sans', sans-serif",
                        fontSize: 9,
                        color: "rgba(255,255,255,0.16)",
                        letterSpacing: "0.22em",
                        textTransform: "uppercase",
                        animation: "whisperFade 5s ease-in-out infinite",
                    }}>
                        or any key
                    </span>
                </div>
            )}

            {/* ── Act dots — bottom left ── */}
            <div style={{
                position: "absolute", bottom: 16, left: 24,
                display: "flex", gap: 6, alignItems: "center",
            }}>
                {ACTS.map((_, i) => (
                    <div key={i} style={{
                        height: 2, borderRadius: 1,
                        width: i < actIndex ? 18 : i === actIndex ? 28 : 8,
                        background: i <= actIndex ? act.shapeStroke : "rgba(255,255,255,0.1)",
                        opacity: i <= actIndex ? 0.65 : 0.25,
                        transition: "all 1.4s ease",
                    }} />
                ))}
            </div>

            {/* Keyframes */}
            <style>{`
        @keyframes haloBreath {
          0%,100%{opacity:0.55;transform:scale(1);}
          50%{opacity:0.9;transform:scale(1.05);}
        }
        @keyframes ringA { from{transform:rotate(0deg)} to{transform:rotate(360deg)} }
        @keyframes ringB { from{transform:rotate(0deg)} to{transform:rotate(-360deg)} }
        @keyframes whisperFade {
          0%,100%{opacity:0.16;}
          50%{opacity:0.35;}
        }
        ${PARTICLES.map(p => `
          @keyframes pdrift${p.id % 6}{
            from{transform:translate(0,0);}
            to{transform:translate(${(p.id % 3 - 1) * 16}px,${(p.id % 4 - 1.5) * 13}px);}
          }
        `).join("")}
      `}</style>
        </div>
    );
}
