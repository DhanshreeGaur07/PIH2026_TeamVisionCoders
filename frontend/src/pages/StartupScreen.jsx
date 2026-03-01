import React, { useEffect } from "react";
import { Recycle } from "lucide-react";

export default function StartupScreen({ onComplete }) {

    useEffect(() => {
        const handleKeyDown = (e) => {
            if (e.key === "Enter") {
                onComplete?.();
            }
        };
        window.addEventListener("keydown", handleKeyDown);
        return () => window.removeEventListener("keydown", handleKeyDown);
    }, [onComplete]);

    return (
        <div className="fixed inset-0 z-[9999] bg-soil-900 flex flex-col items-center justify-center overflow-hidden cursor-pointer" onClick={onComplete}>

            {/* Background elements */}
            <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-forest-600/10 rounded-full blur-[100px] animate-pulse"></div>

            <div className="relative z-10 flex flex-col items-center justify-center">
                {/* Logo Animation */}
                <div className="relative mb-8">
                    <div className="absolute inset-0 bg-forest-500 rounded-3xl blur-xl opacity-50 animate-pulse"></div>
                    <div className="w-32 h-32 rounded-3xl bg-gradient-to-br from-forest-400 to-forest-700 flex items-center justify-center shadow-2xl relative border border-forest-300/30 transform transition-transform animate-[spin_5s_linear_infinite]">
                        <Recycle size={64} className="text-white drop-shadow-lg" />
                    </div>
                </div>

                {/* Text Animation */}
                <h1 className="font-display font-black text-white text-5xl md:text-7xl mb-4 tracking-tight drop-shadow-xl text-center">
                    SCRAP<span className="text-forest-500">·</span>CRAFTERS
                </h1>

                <p className="text-soil-300 text-lg md:text-xl tracking-widest uppercase font-semibold mb-12 animate-pulse text-center max-w-sm">
                    Turn Waste into Worth
                </p>

                <p className="text-xs text-soil-500 tracking-[0.3em] font-medium opacity-50 hover:opacity-100 transition-opacity">
                    PRESS ENTER OR CLICK TO START
                </p>
            </div>

            {/* Auto skip after 3.5 seconds */}
            <AutoSkip placeholderDelay={3500} onFinish={onComplete} />
        </div>
    );
}

function AutoSkip({ placeholderDelay, onFinish }) {
    useEffect(() => {
        const timer = setTimeout(onFinish, placeholderDelay);
        return () => clearTimeout(timer);
    }, [placeholderDelay, onFinish]);
    return null;
}
