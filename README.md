# Government Scheme Navigator Chatbot

An AI-powered Tamil Government Scheme Navigator that helps citizens discover government welfare schemes, check eligibility, understand benefits, view required documents, and receive step-by-step application guidance through a simple chatbot interface.

---

## 📌 Project Overview

Many citizens are unaware of government welfare schemes due to scattered information, language barriers, and complex eligibility criteria.

This project provides a smart AI chatbot that enables users to:

* Search government schemes
* Check eligibility
* View scheme benefits
* Get required document lists
* Understand application procedures
* Interact in Tamil and English

---

## 🎯 Problem Statement

Citizens often struggle to find and understand government welfare schemes because information is distributed across multiple websites and is difficult to interpret.

The Government Scheme Navigator Chatbot solves this problem by providing a centralized AI-powered platform that delivers personalized scheme recommendations and guidance.

---

## 🚀 Features

### User Features

* AI Chatbot Interface
* Tamil Language Support
* Government Scheme Search
* Eligibility Checker
* Required Documents Assistant
* Application Guidance
* Personalized Recommendations
* Mobile Responsive Design

### Admin Features

* Add New Schemes
* Edit Scheme Details
* Delete Schemes
* Manage Categories
* Manage Eligibility Rules
* View User Queries
* Analytics Dashboard

---

## 🛠 Technology Stack

### Frontend

* HTML5
* CSS3
* JavaScript
* React.js

### Backend

* Node.js
* Express.js

### Database

* Firebase Firestore

### AI Integration

* Gemini API
* NLP Processing

### Deployment

* Firebase Hosting

---

## 📂 Project Structure

```bash
government-scheme-navigator/
│
├── public/
│   ├── index.html
│   ├── favicon.ico
│
├── src/
│   │
│   ├── assets/
│   │   ├── images/
│   │   ├── icons/
│   │
│   ├── components/
│   │   ├── Navbar.jsx
│   │   ├── Footer.jsx
│   │   ├── ChatBot.jsx
│   │   ├── EligibilityForm.jsx
│   │   ├── SchemeCard.jsx
│   │
│   ├── pages/
│   │   ├── Home.jsx
│   │   ├── Schemes.jsx
│   │   ├── Eligibility.jsx
│   │   ├── About.jsx
│   │
│   ├── services/
│   │   ├── firebase.js
│   │   ├── geminiAPI.js
│   │
│   ├── data/
│   │   ├── schemes.json
│   │
│   ├── utils/
│   │   ├── eligibilityChecker.js
│   │
│   ├── App.jsx
│   ├── main.jsx
│
├── server/
│   ├── routes/
│   ├── controllers/
│   ├── middleware/
│   ├── server.js
│
├── .env
├── package.json
├── firebase.json
├── README.md
```

---

## ⚙️ Installation

### Clone Repository

```bash
git clone https://github.com/your-username/government-scheme-navigator.git
```

### Navigate to Project

```bash
cd government-scheme-navigator
```

### Install Dependencies

```bash
npm install
```

### Start Development Server

```bash
npm run dev
```

---

## 🔐 Environment Variables

Create a `.env` file in the root directory.

```env
VITE_FIREBASE_API_KEY=YOUR_KEY
VITE_FIREBASE_AUTH_DOMAIN=YOUR_DOMAIN
VITE_FIREBASE_PROJECT_ID=YOUR_PROJECT_ID

GEMINI_API_KEY=YOUR_GEMINI_KEY
```

---

## 🧠 System Workflow

1. User enters a query.
2. Chatbot processes the query.
3. AI identifies user intent.
4. Eligibility rules are checked.
5. Relevant schemes are retrieved.
6. Results are displayed.
7. User receives application guidance.

---

## 📊 Data Flow

```text
User
 ↓
Chat Interface
 ↓
AI/NLP Engine
 ↓
Eligibility Checker
 ↓
Government Scheme Database
 ↓
Response Generator
 ↓
User
```

---

## 🎯 Expected Outcomes

* Increased awareness of government schemes
* Better accessibility for Tamil-speaking citizens
* Reduced confusion during applications
* Faster scheme discovery process
* Improved digital inclusion

---

## 👨‍💻 Team TECH X

### Team Members

* Abiram S
* Abdul Rahuman M
* Karthick T
* Bharath K

---

## 🔮 Future Enhancements

* Voice Assistant Support
* WhatsApp Integration
* Mobile Application
* Multi-language Support
* Government Portal Integration
* Personalized Notifications

---

## 📜 License

This project is developed for educational, research, and hackathon purposes.

---

### Built with ❤️ by Team TECH X
