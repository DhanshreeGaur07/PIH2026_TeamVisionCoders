// ============================================================
//  UploadForm.js  — Sell / Donate item upload form
// ============================================================
import React, { useState, useRef } from "react";
import { Camera, Upload, CheckCircle, X } from "lucide-react";

const CATEGORIES = ["metal", "plastic", "e-waste", "wood", "glass", "paper", "textile", "other"];

/**
 * @param {string}   mode       - "sell" | "donate"
 * @param {function} onCancel   - close handler
 * @param {function} onSubmit   - submit handler (receives form data)
 */
const UploadForm = ({ mode, onCancel, onSubmit }) => {
  const [form, setForm]         = useState({ title: "", category: "metal", description: "", price: "" });
  const [preview, setPreview]   = useState(null);
  const [submitted, setSubmitted] = useState(false);
  const fileRef                 = useRef(null);

  const handleFile = (e) => {
    const file = e.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (ev) => setPreview(ev.target.result);
    reader.readAsDataURL(file);
  };

  const handleSubmit = () => {
    if (!form.title) return;
    setSubmitted(true);
    setTimeout(() => {
      onSubmit && onSubmit({ ...form, preview });
      setSubmitted(false);
    }, 1200);
  };

  return (
    <div className="card p-6 bg-gradient-to-br from-forest-50 to-white border-forest-200 animate-grow-in">
      {/* Header */}
      <div className="flex items-center justify-between mb-5">
        <div>
          <h3 className="font-display font-bold text-soil-900 text-lg">
            {mode === "sell" ? "📦 List Item for Sale" : "🤝 Donate an Item"}
          </h3>
          <p className="text-xs text-soil-500 mt-0.5">
            {mode === "sell" ? "Earn money from your unused materials" : "Give freely, earn Green Coins"}
          </p>
        </div>
        <button onClick={onCancel} className="text-soil-400 hover:text-soil-700 transition-colors p-1" aria-label="Close form">
          <X size={18} />
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {/* Image upload zone */}
        <div
          onClick={() => fileRef.current?.click()}
          className={`md:col-span-2 h-36 rounded-2xl border-2 border-dashed flex flex-col items-center justify-center gap-2 cursor-pointer transition-all
            ${preview ? "border-forest-400 bg-forest-50" : "border-soil-200 bg-soil-50 hover:border-forest-400 hover:bg-forest-50"}`}
        >
          {preview
            ? <img src={preview} alt="preview" className="h-full w-full object-cover rounded-2xl" />
            : (
              <>
                <div className="w-10 h-10 rounded-xl bg-white border border-soil-200 flex items-center justify-center text-soil-400 shadow-sm">
                  <Camera size={20} />
                </div>
                <p className="text-sm font-medium text-soil-600">
                  <span className="text-forest-600 font-semibold">Click to upload</span> item photo
                </p>
                <p className="text-xs text-soil-400">PNG or JPG · up to 10 MB</p>
              </>
            )
          }
          <input ref={fileRef} type="file" accept="image/*" className="hidden" onChange={handleFile} />
        </div>

        {/* Title */}
        <div className="flex flex-col gap-1.5">
          <label className="text-xs font-semibold text-soil-600 uppercase tracking-wider">Item Title *</label>
          <input
            className="input-field"
            placeholder="Old bicycle frame…"
            value={form.title}
            onChange={(e) => setForm({ ...form, title: e.target.value })}
          />
        </div>

        {/* Category */}
        <div className="flex flex-col gap-1.5">
          <label className="text-xs font-semibold text-soil-600 uppercase tracking-wider">Category</label>
          <select
            className="input-field"
            value={form.category}
            onChange={(e) => setForm({ ...form, category: e.target.value })}
          >
            {CATEGORIES.map((c) => (
              <option key={c} value={c}>{c.charAt(0).toUpperCase() + c.slice(1)}</option>
            ))}
          </select>
        </div>

        {/* Description */}
        <div className="md:col-span-2 flex flex-col gap-1.5">
          <label className="text-xs font-semibold text-soil-600 uppercase tracking-wider">Description</label>
          <textarea
            rows={3}
            className="input-field resize-none"
            placeholder="Describe the item's condition, size, origin…"
            value={form.description}
            onChange={(e) => setForm({ ...form, description: e.target.value })}
          />
        </div>

        {/* Price (sell only) */}
        {mode === "sell" && (
          <div className="flex flex-col gap-1.5">
            <label className="text-xs font-semibold text-soil-600 uppercase tracking-wider">Expected Price (₹)</label>
            <input
              type="number"
              className="input-field"
              placeholder="250"
              value={form.price}
              onChange={(e) => setForm({ ...form, price: e.target.value })}
            />
          </div>
        )}
      </div>

      {/* Actions */}
      <div className="flex gap-3 mt-5 pt-4 border-t border-soil-100">
        <button onClick={onCancel} className="btn-outline text-sm py-2.5 px-5">
          Cancel
        </button>
        <button
          onClick={handleSubmit}
          disabled={!form.title || submitted}
          className={`flex items-center gap-2 text-sm font-semibold px-6 py-2.5 rounded-xl transition-all disabled:opacity-50
            ${mode === "sell" ? "btn-craft" : "btn-primary"}`}
        >
          {submitted ? (
            <><CheckCircle size={15} /> Submitted!</>
          ) : (
            <><Upload size={15} /> {mode === "sell" ? "List for Sale" : "Donate Item"}</>
          )}
        </button>
      </div>
    </div>
  );
};

export default UploadForm;
