/* Gemini AI Direct Client */

/**
 * Sends a message and context data directly to the Google Gemini API.
 * 
 * @param {string} userMessage - The raw message input by the user.
 * @param {Array} relevantSchemes - List of relevant schemes retrieved from Supabase.
 * @param {Object|null} userProfile - The user's onboarding profile details.
 * @param {Array|null} chatHistory - Previous chat logs for context memory.
 * @param {Object|null} aiSettings - Settings from the Admin Panel.
 * @returns {Promise<string>} The generated markdown text response from Gemini.
 */
async function askGemini(userMessage, relevantSchemes = [], userProfile = null, chatHistory = [], aiSettings = null) {
  try {
    let GEMINI_API_KEY = localStorage.getItem('GEMINI_API_KEY');
    if (!GEMINI_API_KEY && aiSettings && aiSettings.gemini_api_key) {
      GEMINI_API_KEY = aiSettings.gemini_api_key;
    }
    
    if (!GEMINI_API_KEY) {
      throw new Error("Gemini API Key is missing. Please add it in the Admin Panel -> AI Settings.");
    }

    // 1. Determine Model & Settings
    let model = (aiSettings && aiSettings.gemini_model) ? aiSettings.gemini_model : 'gemini-flash-latest';
    
    // Auto-fix any deprecated models from the database
    // Force downgrade Pro models to Flash because free-tier keys have a limit of 0 for Pro models.
    if (model.includes('gemini-1.5') || model.includes('pro')) {
      model = 'gemini-flash-latest';
    }

    const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${GEMINI_API_KEY}`;

    // 2. Build System Instructions (System Prompt)
    let systemInstruction = "You are a helpful assistant for Government Schemes.";

    if (aiSettings) {
      systemInstruction += `\nResponse Length: ${aiSettings.response_length}.`;
      // We don't know the user's language here reliably, so we provide both instructions
      systemInstruction += `\nIf answering in English: ${aiSettings.english_prompt_mode}`;
      systemInstruction += `\nIf answering in Tamil: ${aiSettings.tamil_prompt_mode}`;
    }

    if (userProfile) {
      systemInstruction += `\n\nUser Profile Context:\nName: ${userProfile.name}, Age: ${userProfile.age}, Gender: ${userProfile.gender}, State: ${userProfile.state}, Occupation: ${userProfile.occupation}.`;
    }

    if (relevantSchemes.length > 0) {
      systemInstruction += `\n\nRelevant Database Schemes Context (JSON):\n${JSON.stringify(relevantSchemes)}`;
    }

    // 3. Build Chat History (Convert to Gemini format)
    const contents = [];
    if (chatHistory && chatHistory.length > 0) {
      chatHistory.forEach(msg => {
        if (msg.user_message) contents.push({ role: "user", parts: [{ text: msg.user_message }] });
        if (msg.bot_response) contents.push({ role: "model", parts: [{ text: msg.bot_response }] });
      });
    }

    // 4. Append Current Message
    contents.push({ role: "user", parts: [{ text: userMessage }] });

    // 5. Execute Fetch
    const response = await fetch(endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        system_instruction: { parts: { text: systemInstruction } },
        contents: contents
      })
    });

    const data = await response.json();

    if (!response.ok) {
      console.error("Gemini API Error:", data);
      throw new Error(data.error?.message || "Failed to retrieve response from Gemini API.");
    }

    // 6. Extract Response
    return data.candidates[0].content.parts[0].text || "No response text was generated.";

  } catch (error) {
    console.error("Error communicating with Gemini API:", error);
    throw error;
  }
}
