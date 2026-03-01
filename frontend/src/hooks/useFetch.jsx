// ============================================================
//  hooks/useFetch.js  — Generic async data fetching hook
//
//  Usage:
//    const { data, loading, error, refetch } = useFetch(
//      () => itemsAPI.getMy(),
//      []   // deps — re-runs when any dep changes
//    );
// ============================================================
import { useState, useEffect, useCallback, useRef } from "react";

/**
 * @param {Function} fetchFn  - async function that returns data
 * @param {Array}    deps     - dependency array (like useEffect)
 * @param {object}   options  - { immediate: bool, initialData }
 */
const useFetch = (fetchFn, deps = [], options = {}) => {
  const { immediate = true, initialData = null } = options;

  const [data,    setData]    = useState(initialData);
  const [loading, setLoading] = useState(immediate);
  const [error,   setError]   = useState(null);

  // Stable ref so fetch function changes don't cause infinite loops
  const fetchRef = useRef(fetchFn);
  useEffect(() => { fetchRef.current = fetchFn; });

  const execute = useCallback(async (...args) => {
    setLoading(true);
    setError(null);
    try {
      const result = await fetchRef.current(...args);
      setData(result);
      return result;
    } catch (err) {
      setError(err.message || "An error occurred");
      return null;
    } finally {
      setLoading(false);
    }
  }, []); // eslint-disable-line

  useEffect(() => {
    if (immediate) execute();
  }, deps); // eslint-disable-line

  return { data, loading, error, refetch: execute };
};

export default useFetch;
