/* Supabase Database Integration Client */

// Configuration Variables
const SUPABASE_URL = window.SUPABASE_URL || "https://jcvhfzbunbievyielbvh.supabase.co";
const SUPABASE_ANON_KEY = window.SUPABASE_ANON_KEY || "sb_publishable_f1lqj7PkPzUtTtcVqPLYfg_P3F2YyUi";

// Check if credentials have been updated from placeholder text
const isConfigured = 
  SUPABASE_URL !== "" && 
  SUPABASE_URL !== "YOUR_SUPABASE_URL" && 
  SUPABASE_ANON_KEY !== "" && 
  SUPABASE_ANON_KEY !== "YOUR_SUPABASE_ANON_KEY";

let supabaseClient = null;
window.supabaseClientReady = false;

if (isConfigured) {
  try {
    if (typeof window.supabase === 'undefined') {
      throw new Error("Supabase CDN library was not loaded by the browser. Please check your internet connection.");
    }
    // Initialise Supabase Client using standard global library from CDN
    // Note: window.supabase is the CDN library, supabaseClient is our initialized instance
    supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
    window.supabase = supabaseClient; // Expose globally for other scripts
    window.supabaseClientReady = true;
    console.log("Supabase Client successfully initialized.");
  } catch (error) {
    console.error("Failed to initialize Supabase Client:", error);
    alert("Supabase Initialization Error: " + error.message);
  }
} else {
  console.warn("Supabase is not configured yet. Please supply SUPABASE_URL and SUPABASE_ANON_KEY.");
}

/**
 * Retrieves all government scheme records from the database.
 */
async function getAllSchemes() {
  if (!window.supabaseClientReady) return [];
  const { data, error } = await supabaseClient
    .from('schemes')
    .select('*')
    .order('id', { ascending: true });
    
  if (error) {
    console.error("Error fetching all schemes:", error);
    throw error;
  }
  return data;
}

/**
 * Searches schemes by matching keywords in the name or description.
 */
async function searchSchemes(query) {
  if (!window.supabaseClientReady || !query) return [];
  
  // Clean query and perform a case-insensitive sub-string match on scheme name or description
  const cleanQuery = `%${query.trim()}%`;
  const { data, error } = await supabaseClient
    .from('schemes')
    .select('*')
    .or(`scheme_name.ilike.${cleanQuery},description.ilike.${cleanQuery}`);
    
  if (error) {
    console.error("Error searching schemes:", error);
    throw error;
  }
  return data;
}

/**
 * Filters schemes by category.
 */
async function getSchemeByCategory(category) {
  if (!window.supabaseClientReady || !category) return [];
  const { data, error } = await supabaseClient
    .from('schemes')
    .select('*')
    .eq('category', category);
    
  if (error) {
    console.error(`Error fetching category ${category}:`, error);
    throw error;
  }
  return data;
}

/**
 * Filters schemes by state (e.g., 'Tamil Nadu' or 'Central').
 */
async function getSchemeByState(state) {
  if (!window.supabaseClientReady || !state) return [];
  const { data, error } = await supabaseClient
    .from('schemes')
    .select('*')
    .eq('state', state);
    
  if (error) {
    console.error(`Error fetching state ${state}:`, error);
    throw error;
  }
  return data;
}

/**
 * Queries schemes based on eligibility keyword checks.
 */
async function getSchemeByEligibility(criteria) {
  if (!window.supabaseClientReady || !criteria) return [];
  const cleanCriteria = `%${criteria.trim()}%`;
  const { data, error } = await supabaseClient
    .from('schemes')
    .select('*')
    .ilike('eligibility', cleanCriteria);
    
  if (error) {
    console.error("Error searching eligibility:", error);
    throw error;
  }
  return data;
}

/**
 * Saves a user and chatbot message interaction record to history logs.
 */
async function saveChatHistory(userMessage, botResponse) {
  if (!window.supabaseClientReady) return null;
  const { data, error } = await supabaseClient
    .from('chat_history')
    .insert([
      { user_message: userMessage, bot_response: botResponse }
    ])
    .select();
    
  if (error) {
    console.error("Error saving chat history:", error);
  }
  return data;
}

/**
 * Creates or saves a user profile in the database.
 */
async function saveUserProfile(profile) {
  if (!window.supabaseClientReady || !profile) return null;
  const { data, error } = await supabaseClient
    .from('user_profiles')
    .insert([
      {
        name: profile.name,
        age: parseInt(profile.age),
        gender: profile.gender,
        state: profile.state,
        occupation: profile.occupation,
        education: profile.education
      }
    ])
    .select();
    
  if (error) {
    console.error("Error saving user profile:", error);
    throw error;
  }
  return data?.[0] || null;
}
