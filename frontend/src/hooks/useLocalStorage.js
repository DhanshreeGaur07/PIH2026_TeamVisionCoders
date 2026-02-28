import { useState } from "react";

/**
 * Works exactly like useState but persists the value to localStorage
 * @param {string} key   - localStorage key
 * @param {*}      init  - initial / default value
 */
export function useLocalStorage(key, init) {
  const [storedValue, setStoredValue] = useState(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : init;
    } catch {
      return init;
    }
  });

  const setValue = (value) => {
    try {
      const toStore = value instanceof Function ? value(storedValue) : value;
      setStoredValue(toStore);
      window.localStorage.setItem(key, JSON.stringify(toStore));
    } catch (err) {
      console.warn("useLocalStorage write error:", err);
    }
  };

  return [storedValue, setValue];
}
