import React, { useState } from 'react';
import { getScrapSuggestions } from '../utils/aiService';

const AIAssistant = () => {
    const [image, setImage] = useState(null);
    const [description, setDescription] = useState("");
    const [skill, setSkill] = useState("beginner");
    const [loading, setLoading] = useState(false);
    const [result, setResult] = useState("");

    const handleProcess = async () => {
        if (!image) return alert("Please upload an image of your scrap!");
        setLoading(true);
        const aiResponse = await getScrapSuggestions(image, description, skill);
        setResult(aiResponse);
        setLoading(false);
    };

    return (
        <div className="max-w-3xl mx-auto p-6 bg-white rounded-xl shadow-lg mt-10">
            <h2 className="text-2xl font-bold text-green-700 mb-4">♻️ Scrap-Crafter AI</h2>

            <div className="space-y-4">
                {/* Image Upload */}
                <input
                    type="file"
                    accept="image/*"
                    onChange={(e) => setImage(e.target.files[0])}
                    className="block w-full text-sm text-slate-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:bg-green-50 file:text-green-700 hover:file:bg-green-100"
                />

                {/* Description Input */}
                <textarea
                    placeholder="What tools do you have? (e.g. glue gun, scissors, paint)"
                    className="w-full border p-3 rounded-lg focus:ring-2 focus:ring-green-500 outline-none"
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                />

                {/* Skill Selection */}
                <select
                    className="w-full border p-2 rounded-lg"
                    value={skill}
                    onChange={(e) => setSkill(e.target.value)}
                >
                    <option value="beginner">Beginner (Simple Tools)</option>
                    <option value="intermediate">Intermediate (Power Tools)</option>
                    <option value="advanced">Advanced (Complex Builds)</option>
                </select>

                <button
                    onClick={handleProcess}
                    disabled={loading}
                    className="w-full bg-green-600 text-white py-3 rounded-lg font-semibold hover:bg-green-700 transition"
                >
                    {loading ? "Analyzing Scrap..." : "Generate Creative Ideas"}
                </button>
            </div>

            {/* AI Result Display */}
            {result && (
                <div className="mt-8 p-6 bg-slate-50 border-l-4 border-green-500 rounded whitespace-pre-wrap text-slate-800">
                    {result}
                </div>
            )}
        </div>
    );
};

export default AIAssistant;