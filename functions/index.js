const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Firebase Cloud Function proxy for securing the Gemini API
exports.gemini = onRequest({ cors: true }, async (req, res) => {
  // Only allow POST requests
  if (req.method !== "POST") {
    res.status(405).json({ error: "Method Not Allowed. Use POST." });
    return;
  }

  try {
    const { userMessage, relevantSchemes, userProfile, chatHistory } = req.body;

    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      logger.error("GEMINI_API_KEY is not configured.");
      res.status(500).json({ error: "Gemini API key is not configured on the server." });
      return;
    }

    // Construct the prompt for Gemini
    const profileText = userProfile 
      ? `Name: ${userProfile.name || 'Citizen'}\nAge: ${userProfile.age || 'N/A'}\nGender: ${userProfile.gender || 'N/A'}\nState: ${userProfile.state || 'N/A'}\nOccupation: ${userProfile.occupation || 'N/A'}\nEducation: ${userProfile.education || 'N/A'}`
      : 'None provided';

    const schemesText = relevantSchemes && relevantSchemes.length > 0
      ? relevantSchemes.map((s, idx) => `
Scheme #${idx + 1}:
Name: ${s.scheme_name}
Category: ${s.category}
Description: ${s.description}
Eligibility: ${s.eligibility}
Benefits: ${s.benefits}
Application Process: ${s.application_process}
Official Link: ${s.official_link}
State: ${s.state}
Language: ${s.language}
Source: ${s.source_name} (${s.source_url})
`).join('\n')
      : 'No matching schemes found in database.';

    const historyText = chatHistory && chatHistory.length > 0
      ? chatHistory.map(h => `User: ${h.user_message}\nBot: ${h.bot_response}`).join('\n')
      : 'No previous history.';

    const systemPrompt = `You are Government Scheme Navigator AI. You help citizens find government schemes.

Rules:
1. Detect if the user is writing in English or Tamil. Reply in the same language. (If English, reply in English; if Tamil, reply in Tamil).
2. ONLY answer using scheme data provided. Do not invent schemes or mention schemes that are not listed in the "Relevant Schemes" below.
3. If no relevant scheme is found or if the user asks for a scheme that is not in the provided database context, politely say that information is unavailable.
4. Be concise and helpful. 
5. Explain eligibility clearly.
6. Explain benefits clearly.
7. Support English and Tamil.
8. Include the Official Link, Source Name, and Source URL of any schemes you recommend in your response. Always format them as clickable Markdown links (e.g. "[Official Link](URL)" and "[Source Name](URL)").
`;

    const fullPrompt = `${systemPrompt}

User Profile:
${profileText}

Relevant Schemes (from Database):
${schemesText}

Chat History:
${historyText}

User Query:
${userMessage}

Response (in the detected language - English or Tamil):`;

    // Call Gemini API using global fetch (Node 18+ native fetch)
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent?key=${apiKey}`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          contents: [
            {
              parts: [
                {
                  text: fullPrompt,
                },
              ],
            },
          ],
        }),
      }
    );

    if (!response.ok) {
      const errorData = await response.json();
      logger.error("Gemini API error:", errorData);
      res.status(response.status).json({ error: "Failed to generate response from Gemini API.", details: errorData });
      return;
    }

    const data = await response.json();
    const candidateText = data.candidates?.[0]?.content?.parts?.[0]?.text || "I apologize, but I could not formulate a response.";

    res.status(200).json({ response: candidateText });
  } catch (error) {
    logger.error("Error in Firebase function:", error);
    res.status(500).json({ error: "Internal Server Error", details: error.message });
  }
});
