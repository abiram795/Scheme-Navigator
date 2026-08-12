/* Chatbot Core Controller - UI, Intents, Database Context, AI Proxy */

document.addEventListener('DOMContentLoaded', () => {
  const profileForm = document.getElementById('profile-form');
  const profileStatus = document.getElementById('profile-status');
  const clearProfileBtn = document.getElementById('clear-profile-btn');
  
  const chatMessages = document.getElementById('chat-messages');
  const chatForm = document.getElementById('chat-form');
  const chatInput = document.getElementById('chat-input');
  const clearChatBtn = document.getElementById('clear-chat');
  const typingIndicator = document.getElementById('typing-indicator');
  const chips = document.querySelectorAll('.chip');

  // In-memory state
  let currentProfile = null;
  let chatHistoryMemory = []; // Tracks local conversation context: [{user_message, bot_response}, ...]

  // 1. Initialise State from localStorage
  loadSavedProfile();

  // 2. Profile Submission Event Handler
  if (profileForm) {
    profileForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      
      const profile = {
        name: document.getElementById('profile-name').value.trim(),
        age: parseInt(document.getElementById('profile-age').value),
        gender: document.getElementById('profile-gender').value,
        state: document.getElementById('profile-state').value,
        occupation: document.getElementById('profile-occupation').value,
        education: document.getElementById('profile-education').value,
      };

      currentProfile = profile;
      localStorage.setItem('userProfile', JSON.stringify(profile));

      // Save to Supabase User Profile table
      if (window.supabaseClientReady) {
        try {
          await saveUserProfile(profile);
        } catch (error) {
          console.warn("Could not save profile record to database:", error);
        }
      }

      showProfileStatus();
      
      // Trigger automated recommendations
      await generateSmartRecommendations(profile);
    });
  }

  // 3. Clear Profile
  if (clearProfileBtn) {
    clearProfileBtn.addEventListener('click', () => {
      localStorage.removeItem('userProfile');
      currentProfile = null;
      if (profileForm) profileForm.reset();
      profileStatus.classList.add('hidden');
      profileForm.classList.remove('hidden');
      
      appendBotMessage("Your profile has been cleared. You can fill it out again at any time.");
    });
  }

  // 4. Reset Chat Box
  if (clearChatBtn) {
    clearChatBtn.addEventListener('click', () => {
      chatMessages.innerHTML = `
        <div class="message bot-message">
          <div class="message-bubble">
            <p>Hello! I am Government Scheme Navigator AI. I can help you search and understand official government welfare schemes, including scholarships, agricultural support, startups, and pension plans in both English and Tamil.</p>
            <p>To get started, feel free to fill out the <strong>Personal Profile</strong> on the left, or ask a question directly below!</p>
          </div>
          <span class="message-time">Just now</span>
        </div>`;
      chatHistoryMemory = [];
    });
  }

  // 5. Suggestion Chips Handler
  chips.forEach(chip => {
    chip.addEventListener('click', () => {
      chatInput.value = chip.textContent;
      chatInput.focus();
    });
  });

  // 6. Chat Input Submission
  if (chatForm) {
    chatForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      
      const queryText = chatInput.value.trim();
      if (!queryText) return;

      // Reset input box
      chatInput.value = '';
      
      // Append user message
      appendUserMessage(queryText);
      
      // Process input
      await processUserQuery(queryText);
    });
  }

  // Helper: Load profile if existing
  async function loadSavedProfile() {
    const profileId = sessionStorage.getItem('user_profile_id');
    
    if (profileId && window.supabaseClientReady) {
      try {
        const { data, error } = await supabase
          .from('user_profiles')
          .select('*')
          .eq('id', profileId)
          .single();
          
        if (!error && data) {
          currentProfile = data;
          
          // Pre-fill form
          if (document.getElementById('profile-name')) document.getElementById('profile-name').value = currentProfile.name || '';
          if (document.getElementById('profile-age')) document.getElementById('profile-age').value = currentProfile.age || '';
          if (document.getElementById('profile-gender')) document.getElementById('profile-gender').value = currentProfile.gender || '';
          if (document.getElementById('profile-state')) document.getElementById('profile-state').value = currentProfile.state || '';
          if (document.getElementById('profile-occupation')) document.getElementById('profile-occupation').value = currentProfile.occupation || '';
          if (document.getElementById('profile-education')) document.getElementById('profile-education').value = currentProfile.education || '';
          
          showProfileStatus();
          
          // Automatically trigger recommendations based on the database profile
          setTimeout(() => {
            generateSmartRecommendations(currentProfile);
          }, 500);
          
          return;
        }
      } catch(err) {
        console.error("Error loading profile from DB:", err);
      }
    }

    // Fallback to local storage (legacy)
    const saved = localStorage.getItem('userProfile');
    if (saved) {
      currentProfile = JSON.parse(saved);
      
      // Pre-fill form
      if (document.getElementById('profile-name')) document.getElementById('profile-name').value = currentProfile.name || '';
      if (document.getElementById('profile-age')) document.getElementById('profile-age').value = currentProfile.age || '';
      if (document.getElementById('profile-gender')) document.getElementById('profile-gender').value = currentProfile.gender || '';
      if (document.getElementById('profile-state')) document.getElementById('profile-state').value = currentProfile.state || '';
      if (document.getElementById('profile-occupation')) document.getElementById('profile-occupation').value = currentProfile.occupation || '';
      if (document.getElementById('profile-education')) document.getElementById('profile-education').value = currentProfile.education || '';
      
      showProfileStatus();
    }
  }

  function showProfileStatus() {
    if (!profileForm || !profileStatus) return;
    profileForm.classList.add('hidden');
    profileStatus.classList.remove('hidden');
    
    // Customize greeting text in the status block
    const statusMsg = profileStatus.querySelector('i').nextSibling;
    if (statusMsg) {
      statusMsg.textContent = ` Profile saved for ${currentProfile.name}! Smart recommendations are active. `;
    }
  }

  // Smart recommendation generator
  async function generateSmartRecommendations(profile) {
    showLoading(true);
    
    appendBotMessage(`Hello **${profile.name}**! I am searching for schemes matching your profile:\n* State: **${profile.state}**\n* Occupation: **${profile.occupation}**\n* Education: **${profile.education}**...`);
    
    try {
      if (!window.supabaseClientReady) {
        setTimeout(() => {
          showLoading(false);
          appendBotMessage("Supabase database is not connected. I cannot fetch matching schemes for your profile. Please configure the Supabase URL and Key in `js/supabase.js`.");
        }, 1000);
        return;
      }

      // Fetch schemes related to occupation (category) and state
      let matchingSchemes = [];
      
      // Map occupation to database categories
      let lookupCategory = profile.occupation;
      if (profile.occupation === 'Retired') lookupCategory = 'Senior Citizen';
      if (profile.occupation === 'Self-Employed') lookupCategory = 'Startup';

      // 1. Get by category
      let categorySchemes = await getSchemeByCategory(lookupCategory);
      
      // 2. Filter schemes that match the user's state (or central schemes)
      matchingSchemes = categorySchemes.filter(s => 
        s.state.toLowerCase() === 'central' || 
        s.state.toLowerCase() === profile.state.toLowerCase()
      );

      // Limit results to top 5
      matchingSchemes = matchingSchemes.slice(0, 5);

      if (matchingSchemes.length === 0) {
        showLoading(false);
        appendBotMessage(`I searched the database but couldn't find any specific matches for a ${profile.occupation} in ${profile.state} at this time. Feel free to ask me questions about specific topics (e.g. "scholarships" or "loans") directly!`);
        return;
      }

      // Use Gemini to write a personalized onboarding recommendation response
      const autoQuery = `Suggest government schemes from the matching database records for my profile: ${profile.name}, Age ${profile.age}, ${profile.gender}, based in ${profile.state}. I am a ${profile.occupation}.`;
      
      let aiSettings = null;
      if (window.supabaseClientReady) {
        const { data } = await supabase.from('ai_settings').select('*').eq('id', 1).single();
        aiSettings = data;
      }

      const responseText = await askGemini(autoQuery, matchingSchemes, profile, [], aiSettings);
      
      showLoading(false);
      appendBotMessage(responseText);
      
      // Save interaction in Supabase
      saveChatHistory(autoQuery, responseText);
      chatHistoryMemory.push({ user_message: autoQuery, bot_response: responseText });
    } catch (err) {
      console.error("Onboard Error:", err);
      showLoading(false);
      let errMsg = "I encountered an issue retrieving recommendations.";
      if (err.message) {
        errMsg += " Error: " + err.message;
      }
      appendBotMessage(errMsg);
    }
  }

  // Core processor for user inputs
  async function processUserQuery(userQuery) {
    showLoading(true);

    // 1. Intent Detection
    const intent = detectIntent(userQuery);
    console.log(`Detected intent: ${intent}`);

    // Language detection check (Tamil greetings or characters)
    const isTamil = /[\u0B80-\u0BFF]/.test(userQuery);

    // 2. Greeting Handling (Intercepted immediately - no Supabase or Gemini call)
    if (intent === "Greeting") {
      setTimeout(() => {
        showLoading(false);
        let greetingResponse = "";
        if (isTamil) {
          greetingResponse = "வணக்கம்! நான் அரசு திட்ட வழிகாட்டி AI. உங்களுக்கு இன்று எவ்வாறு உதவ முடியும்?\n\nமாணவர்களுக்கான கல்வி உதவித்தொகை, விவசாயிகள் மானியம், பெண்கள் சுயதொழில் கடன்கள் அல்லது மூத்த குடிமக்கள் ஓய்வூதியத் திட்டங்கள் பற்றி என்னிடம் கேட்கலாம்.";
        } else {
          greetingResponse = `Hello ${currentProfile ? currentProfile.name : ''}! I am Government Scheme Navigator AI. How can I help you today?\n\nFeel free to ask me about scholarships, agricultural aids, startup support, health insurance, or old-age pensions.`;
        }
        appendBotMessage(greetingResponse);
      }, 500);
      return;
    }

    // 3. Scheme-Related Query Workflow
    try {
      let relevantSchemes = [];

      if (window.supabaseClientReady) {
        // Query Supabase for relevant schemes
        // We will perform a keyword search first
        relevantSchemes = await searchSchemes(userQuery);

        // If no keyword search yields results, look up by category determined from the intent
        if (relevantSchemes.length === 0) {
          const categoryMap = {
            "Student Scheme": "Student",
            "Farmer Scheme": "Farmer",
            "Women Scheme": "Women",
            "Startup Scheme": "Startup",
            "Employment Scheme": "Employment",
            "Senior Citizen Scheme": "Senior Citizen",
            "Health Scheme": "Health",
            "Disability Support": "Disability Support"
          };
          
          const mappedCategory = categoryMap[intent];
          if (mappedCategory) {
            relevantSchemes = await getSchemeByCategory(mappedCategory);
          }
        }

        // Apply profile filter locally (prioritize central + user state schemes if profile exists)
        if (currentProfile && currentProfile.state && relevantSchemes.length > 0) {
          const userState = currentProfile.state.toLowerCase();
          relevantSchemes = relevantSchemes.filter(s => 
            s.state.toLowerCase() === 'central' || 
            s.state.toLowerCase() === userState
          );
        }

        // Limit results to top 8 to reduce token usage and improve performance
        relevantSchemes = relevantSchemes.slice(0, 8);
      }

      // 4. Send query + limited schemes context + profile to secure serverless Gemini API
      // Only keep the last 5 interactions in memory to avoid prompt bloat
      const historyContext = chatHistoryMemory.slice(-5);
      
      let aiSettings = null;
      if (window.supabaseClientReady) {
        const { data } = await supabase.from('ai_settings').select('*').eq('id', 1).single();
        aiSettings = data;
      }

      const aiResponse = await askGemini(userQuery, relevantSchemes, currentProfile, historyContext, aiSettings);

      showLoading(false);
      appendBotMessage(aiResponse);

      // 5. Save logs to database
      if (window.supabaseClientReady) {
        await saveChatHistory(userQuery, aiResponse);
      }

      // Add to memory
      chatHistoryMemory.push({ user_message: userQuery, bot_response: aiResponse });

    } catch (error) {
      console.error("Chatbot Error:", error);
      showLoading(false);
      
      let errorMsg = "I apologize, but I encountered an error checking my database or communicating with the AI server. Please verify that your API Keys are set up correctly.";
      if (error.message) {
        errorMsg = "Error: " + error.message;
      }
      
      if (isTamil && !error.message) {
        errorMsg = "மன்னிக்கவும், தரவுத்தளத்தை சரிபார்க்கும் போது அல்லது AI சேவையகத்துடன் தொடர்பு கொள்ளும் போது பிழை ஏற்பட்டது. தயவுசெய்து உங்கள் API விசைகளை சரிபார்க்கவும்.";
      }
      appendBotMessage(errorMsg);
    }
  }

  // Detect query category / greeting intents
  function detectIntent(message) {
    const msg = message.toLowerCase().trim();
    
    const greetings = [
      "hi", "hello", "hey", "hola", "namaste", "vanakkam", "வணக்கம்", "ஹாய்", "ஹலோ",
      "good morning", "good afternoon", "good evening", "who are you", 
      "what is your name", "who built you"
    ];
    
    // Use word boundaries so "hi" doesn't match "chief"
    if (greetings.some(g => new RegExp(`\\b${g}\\b`, 'i').test(msg)) || greetings.includes(msg)) {
      return "Greeting";
    }

    if (msg.includes("student") || msg.includes("scholarship") || msg.includes("college") || msg.includes("school") || msg.includes("engineering") || msg.includes("post matric") || msg.includes("education loan") || msg.includes("படிப்பு") || msg.includes("மாணவி") || msg.includes("மாணவர்") || msg.includes("கல்வி") || msg.includes("மதிப்பெண்")) {
      return "Student Scheme";
    }
    if (msg.includes("farmer") || msg.includes("agriculture") || msg.includes("kisan") || msg.includes("land") || msg.includes("crop") || msg.includes("subsidy") || msg.includes("விவசாயி") || msg.includes("விவசாயம்") || msg.includes("நெல்") || msg.includes("பயிர்")) {
      return "Farmer Scheme";
    }
    if (msg.includes("women") || msg.includes("girl") || msg.includes("maternity") || msg.includes("pregnancy") || msg.includes("marriage assistance") || msg.includes("amiyar") || msg.includes("penkalvi") || msg.includes("பெண்") || msg.includes("மகளிர்") || msg.includes("கல்யாணம்") || msg.includes("திருமணம்") || msg.includes("கர்ப்பிணி")) {
      return "Women Scheme";
    }
    if (msg.includes("startup") || msg.includes("business") || msg.includes("entrepreneur") || msg.includes("mudra") || msg.includes("needs") || msg.includes("funding") || msg.includes("தொழில்") || msg.includes("வியாபாரம்")) {
      return "Startup Scheme";
    }
    if (msg.includes("employment") || msg.includes("job") || msg.includes("self employment") || msg.includes("pmegp") || msg.includes("வேலை") || msg.includes("வேலைவாய்ப்பு")) {
      return "Employment Scheme";
    }
    if (msg.includes("pension") || msg.includes("senior") || msg.includes("old age") || msg.includes("retirement") || msg.includes("முதியோர்") || msg.includes("ஓய்வூதியம்")) {
      return "Senior Citizen Scheme";
    }
    if (msg.includes("health") || msg.includes("medical") || msg.includes("insurance") || msg.includes("hospital") || msg.includes("cashless") || msg.includes("சுகாதாரம்") || msg.includes("மருத்துவம்") || msg.includes("சிகிச்சை")) {
      return "Health Scheme";
    }
    if (msg.includes("disable") || msg.includes("handicap") || msg.includes("udid") || msg.includes("blind") || msg.includes("deaf") || msg.includes("மாற்றுத்திறனாளி")) {
      return "Disability Support";
    }
    
    return "General Government Query";
  }

  // UI Render Helpers
  function appendUserMessage(text) {
    const msgDiv = document.createElement('div');
    msgDiv.className = 'message user-message';
    msgDiv.innerHTML = `
      <div class="message-bubble">
        <p>${escapeHTML(text)}</p>
      </div>
      <span class="message-time">Sent just now</span>
    `;
    chatMessages.appendChild(msgDiv);
    scrollToBottom();
  }

  function appendBotMessage(markdownText) {
    const msgDiv = document.createElement('div');
    msgDiv.className = 'message bot-message';
    
    // Parse markdown (bold, links, breaks)
    const formattedHTML = parseMarkdown(markdownText);
    
    msgDiv.innerHTML = `
      <div class="message-bubble">
        ${formattedHTML}
      </div>
      <span class="message-time">Just now</span>
    `;
    chatMessages.appendChild(msgDiv);
    scrollToBottom();
  }

  function showLoading(show) {
    if (!typingIndicator) return;
    if (show) {
      typingIndicator.classList.remove('hidden');
    } else {
      typingIndicator.classList.add('hidden');
    }
    scrollToBottom();
  }

  function scrollToBottom() {
    chatMessages.scrollTop = chatMessages.scrollHeight;
  }

  // Simple Clean HTML Sanitizer
  function escapeHTML(str) {
    return str
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;");
  }

  // Simple Markdown Parser (Strictly client-side format helper)
  function parseMarkdown(text) {
    if (!text) return "";
    
    let html = escapeHTML(text);
    
    // Bold: **text**
    html = html.replace(/\*\*(.*?)\*\*/g, "<strong>$1</strong>");
    
    // Inline code: `code`
    html = html.replace(/`(.*?)`/g, "<code>$1</code>");
    
    // Unordered lists: * item
    // First match newlines that start with asterisks and convert them to list tags
    html = html.replace(/^\*\s(.*)$/gm, "<li>$1</li>");
    // Also cover lists that start with dash - item
    html = html.replace(/^-\s(.*)$/gm, "<li>$1</li>");
    
    // Markdown Links: [anchor](url)
    html = html.replace(/\[(.*?)\]\((.*?)\)/g, '<a href="$2" target="_blank" rel="noopener">$1 <i class="fa-solid fa-arrow-up-right-from-square" style="font-size:0.7rem; margin-left:0.15rem;"></i></a>');

    // Convert newlines to breaks
    html = html.replace(/\n/g, "<br>");
    
    return html;
  }
});
