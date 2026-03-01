# StartupScreen & App — Code Review & Fixes

**Open this file in Cursor** (e.g. Ctrl+P → `REVIEW.md`) for a quick overview of why the startup screen wasn’t working and what was changed.

---

## What was going wrong

1. **Unstable `onComplete` callback (App.js)**  
   The prop was passed as an inline function: `onComplete={() => setStartupComplete(true)}`.  
   That creates a new function on every render. StartupScreen’s animation runs in a `useEffect` that depended on `finish`, and `finish` depended on `onComplete`. So every time App re-rendered (e.g. when `useAuth` updated `user` after `/auth/me`), the effect re-ran, **cancelled the animation**, and **restarted from 0**. The intro could loop or never finish.

2. **React StrictMode double-mount (dev)**  
   In development, React mounts components twice to detect side effects. So the startup effect ran, then was cleaned up (animation cancelled), then ran again with a **new** start time. The intro kept restarting from the beginning.

3. **No guaranteed way to skip**  
   Skip was only “any key / click”. If key/click didn’t fire (focus, touch, or event quirks), there was no visible control to dismiss the screen.

---

## Fixes applied

### 1. App.js — stable callback

- Added: `const handleStartupComplete = useCallback(() => setStartupComplete(true), []);`
- Replaced `onComplete={() => setStartupComplete(true)}` with `onComplete={handleStartupComplete}`  
- So the same function reference is passed every time and the animation effect doesn’t re-run on parent re-renders.

### 2. StartupScreen.js — resilient to parent and StrictMode

- **Ref for `onComplete`**  
  `onComplete` is stored in a ref and `finish` calls `onCompleteRef.current?.()`.  
  So the effect can depend on a stable `finish` and still call the latest `onComplete`.

- **Global start time**  
  A module-level `globalStartTime` is set once when the animation starts and reused on the next run (e.g. after StrictMode remount). So the 12s timer doesn’t restart when the effect runs again. It’s reset to `null` when `finish()` runs so a future mount can start fresh.

### 3. Visible Skip control

- A **“Skip” button** was added next to the “or any key” text so you can always dismiss the startup screen even if key/click don’t work.

---

## How to verify

1. **Refresh the app** — you should see the startup intro once (~12s or until skip).
2. **Click “Skip” or press any key / click** — the screen should fade out and show the main app (Landing or dashboard if already logged in).
3. If something still doesn’t work, open DevTools (F12) → Console and note any errors, then share what you see.

---

## Files touched

| File | Changes |
|------|--------|
| `src/App.js` | `handleStartupComplete` with `useCallback`, pass it to `StartupScreen` |
| `src/pages/StartupScreen.js` | `onCompleteRef`, `globalStartTime`, stable `finish`, visible Skip button |

---

*You can close or delete this file after reading; it’s for review only.*
