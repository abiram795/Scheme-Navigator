# Government Scheme Navigator AI

An intelligent web portal enabling students and citizens to navigate the ecosystem of Indian government welfare programs. It includes a conversational AI chatbot supporting English and Tamil, an interactive schemes catalog, a personal onboarding recommendations wizard, and a comprehensive database administration dashboard.

## Folder Structure

The project has been initialized using this clean vanilla architecture:

```text
government-scheme-ai/
│
├── index.html        # Homepage (Hero, Popular Categories, Stats, Features)
├── chatbot.html      # AI Chatbot Interface (Profile Wizard sidebar & Chat box)
├── schemes.html      # Schemes Directory (Active Search, Filter tags, collapsible details)
├── about.html        # About Page (Mission statement, Technology stack, Future roadmap)
├── admin.html        # Admin Control Dashboard (Supabase CRUD: Add, Edit, Delete)
│
├── css/
│   ├── style.css     # Global stylesheets (Dark/Light variables, animations, components)
│   └── chatbot.css   # Chat-specific styles (bubbles, indicators, wizard layouts)
│
├── js/
│   ├── app.js        # Global scripts (Theme switcher, mobile navbar toggle, localStorage)
│   ├── supabase.js   # Supabase client SDK operations (CRUD, filtering, history saving)
│   ├── gemini.js     # Frontend agent communicating with secure serverless API
│   └── chatbot.js    # Chatbot manager (State, onboard profile logic, Intent classifier)
│
├── assets/
│   ├── logo.png      # Portal Logo asset
│   └── hero-image.png# Modern high-tech dashboard hero illustration
│
└── sql/
    └── schema.sql    # Complete PostgreSQL schema definitions & 30+ sample insertions
```

At the root directory (`c:\Users\abira\OneDrive\Desktop\goverment\`), Firebase hosting configuration files are defined:
- `firebase.json` (Hosting configuration & rewrites redirecting `/api/gemini` to Cloud Functions)
- `.firebaserc` (Default project bindings)
- `functions/` (Serverless backend cloud function using Node.js 18)

---

## Technical Stack & Configuration

1. **Frontend:** Plain HTML5, Vanilla CSS3 (Custom Glassmorphism), and Vanilla ES6 JavaScript (No frameworks used).
2. **Database:** Supabase (PostgreSQL) hosting scheme tables, chat logs, and user profiles.
3. **AI Proxy:** Google Gemini API proxied via Node.js **Firebase Cloud Functions**.
4. **Icons & Fonts:** Font Awesome 6.4.0 (CDN) & Google Fonts (Poppins, Outfit).

---

## Setup & Local Installation

Follow these steps to run the application locally or deploy it in production:

### 1. Database Setup (Supabase)
1. Create a free account at [Supabase](https://supabase.com/).
2. Create a new PostgreSQL project.
3. Open the **SQL Editor** in the Supabase Dashboard and click **New Query**.
4. Copy the entire contents of [`sql/schema.sql`](file:///c:/Users/abira/OneDrive/Desktop/goverment/government-scheme-ai/sql/schema.sql) and paste it into the editor.
5. Click **Run** to create the tables (`schemes`, `chat_history`, `user_profiles`), configure indexes, and insert the 31 seed records.

### 2. Connect Frontend to Supabase
1. On your Supabase dashboard, navigate to **Project Settings** > **API**.
2. Copy your **Project URL** and **anon public key**.
3. Open the local file [`js/supabase.js`](file:///c:/Users/abira/OneDrive/Desktop/goverment/government-scheme-ai/js/supabase.js) and replace the placeholders:
   ```javascript
   const SUPABASE_URL = "YOUR_SUPABASE_PROJECT_URL";
   const SUPABASE_ANON_KEY = "YOUR_SUPABASE_ANON_PUBLIC_KEY";
   ```

### 3. Setup Gemini API Key
1. Obtain an API Key from the Google AI Studio at [aistudio.google.com](https://aistudio.google.com/).
2. Keep this key safe. Do **not** commit it or place it in public frontend files.

---

## Running Locally (Firebase Emulator Suite)

To test the frontend together with the secure Cloud Function locally:

1. Install the Firebase CLI globally:
   ```bash
   npm install -g firebase-tools
   ```
2. Log in to your Firebase account:
   ```bash
   firebase login
   ```
3. Set your Gemini API Key in the environment variable and run the Firebase Emulator:
   ```bash
   # On Windows (PowerShell)
   $env:GEMINI_API_KEY="YOUR_ACTUAL_GEMINI_API_KEY"
   firebase emulators:start
   
   # On macOS/Linux/Git Bash
   GEMINI_API_KEY="YOUR_ACTUAL_GEMINI_API_KEY" firebase emulators:start
   ```
4. Open the emulator hosting URL (typically `http://localhost:5000`) in your browser. All requests to `/api/gemini` will be automatically rewritten to the local Firebase Function running on port `5001`.

---

## Firebase Deployment Guide

### 1. Upgrade Firebase Project to Blaze Plan
* Note: Firebase Cloud Functions require your project to be on the **Blaze (Pay-as-you-go) plan**. There is a massive free tier of 2 million requests per month, but Cloud Functions cannot run on the free Spark plan.

### 2. Add Environment Configuration
Deploy your Gemini API key securely to Google Cloud Secret Manager so the function can read it:
```bash
firebase functions:secrets:set GEMINI_API_KEY="YOUR_ACTUAL_GEMINI_API_KEY"
```

### 3. Deploy
To deploy both Hosting assets and Cloud Functions:
```bash
firebase deploy
```

---

## Future Roadmap: AI Semantic Search via pgvector

The platform's database schema is pre-configured to easily support semantic search. When you are ready to transition from traditional keyword queries to Vector-based embeddings search:

1. **Enable pgvector extension** in your Supabase SQL editor:
   ```sql
   CREATE EXTENSION IF NOT EXISTS vector;
   ```
2. **Uncomment the embedding column** inside the `schemes` table definition in `sql/schema.sql`:
   ```sql
   ALTER TABLE schemes ADD COLUMN embedding vector(1536);
   ```
3. **Generate embeddings** for all scheme details using Gemini's text-embedding model (`text-embedding-004`), and write them into the `embedding` column.
4. **Create a similarity matching function** in PostgreSQL:
   ```sql
   CREATE OR REPLACE FUNCTION match_schemes (
     query_embedding vector(1536),
     match_threshold float,
     match_count int
   )
   RETURNS TABLE (
     id bigint,
     scheme_name text,
     category text,
     description text,
     eligibility text,
     benefits text,
     official_link text,
     state text,
     similarity float
   )
   LANGUAGE plpgsql AS $$
   BEGIN
     RETURN QUERY
     SELECT
       schemes.id,
       schemes.scheme_name,
       schemes.category,
       schemes.description,
       schemes.eligibility,
       schemes.benefits,
       schemes.official_link,
       schemes.state,
       1 - (schemes.embedding <=> query_embedding) AS similarity
     FROM schemes
     WHERE 1 - (schemes.embedding <=> query_embedding) > match_threshold
     ORDER BY schemes.embedding <=> query_embedding
     LIMIT match_count;
   END;
   $$;
   ```
5. Call this function from your client-side JavaScript via Supabase RPC:
   ```javascript
   const { data, error } = await supabase.rpc('match_schemes', {
     query_embedding: embedVector, // generated from query text
     match_threshold: 0.7,
     match_count: 5
   });
   ```

---

## Security & Performance Safeguards

- **API Secret Masking:** The Google Gemini API key resides strictly inside Google Cloud Secrets/Firebase Env configuration. Client browsers never see or transmit it.
- **Intent Boundary Guard:** Simple greetings are answered immediately on the client-side to eliminate latency and avoid wasting API tokens.
- **Optimized Context Injection:** Only the top 5-8 matching schemes are sent to the AI prompt context rather than dumping the whole database, ensuring lightning-fast responses and minimal costs.
- **Input Sanitization:** User messages are HTML-escaped before rendering in bubbles to prevent Cross-Site Scripting (XSS) injections.
