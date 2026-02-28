import { GoogleGenerativeAI } from "@google/generative-ai";

// Initialize the API (You'll need an API Key from Google AI Studio)
const genAI = new GoogleGenerativeAI("YOUR_GEMINI_API_KEY");

export const getScrapSuggestions = async (imageFile, description, skillLevel) => {
    try {
        const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

        // The Role & Behavior Prompt
        const systemPrompt = `You are a highly creative, eco-friendly innovation assistant specializing in transforming household scrap into useful items.
        TASK: Analyze the image and description to generate real-time, practical, and innovative ideas.
        USER SKILL LEVEL: ${skillLevel}

        OUTPUT FORMAT (Strictly Follow This):
        1. Identified Scrap Items: List detected materials.
        2. Creative Ideas (3–7 ideas): Item name, use case, why it works.
        3. How to Make: Step-by-step instructions for the best idea.
        4. Innovation Boost: Smarter/multifunctional variations.
        5. Safety & Tips: Handling sharp edges/tools.
    `;

        // Convert file to Generative Part
        const imageData = await fileToGenerativePart(imageFile);

        const result = await model.generateContent([
            systemPrompt,
            description,
            imageData
        ]);

        const response = await result.response;
        return response.text();
    } catch (error) {
        console.error("AI Assistant Error:", error);
        return "Sorry, I couldn't process the scrap materials. Please try again!";
    }
};

// Helper function to process the image for the API
async function fileToGenerativePart(file) {
    const base64EncodedDataPromise = new Promise((resolve) => {
        const reader = new FileReader();
        reader.onloadend = () => resolve(reader.result.split(',')[1]);
        reader.readAsDataURL(file);
    });
    return {
        inlineData: { data: await base64EncodedDataPromise, mimeType: file.type },
    };
}