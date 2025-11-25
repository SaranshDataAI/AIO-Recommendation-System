# 🎬 AIO Recommendation System  
### **AI-Powered Movies + Anime + Web Series Hybrid Recommendation Engine (FastAPI + Flutter + SBERT)**

This project is a complete **end-to-end AI recommendation system** built using **Python, FastAPI, SBERT embeddings, TF-IDF vectors, and a modern Flutter mobile app**.  
It fetches real-time data from **TMDB API**, cleans and merges it, performs **feature engineering**, builds multiple vectorizers + embeddings, and exposes a **FastAPI recommendation endpoint deployed on Render**.  
The mobile UI is built using **Flutter**, packaged as a clean modern APK.

---

## 🚀 Features

### 🔹 **Data & ML**
- Fetches Movies + Anime + Webseries using **TMDB API**
- Cleans raw data and builds **one unified dataset**
- Combines metadata into **single meta text** (overview + genres + cast + keywords + tagline)
- Generates:
  - **TF-IDF vectors**
  - **Count vectors**
  - **Genre vectors**
  - **Sentence-BERT embeddings**
- Builds a **Hybrid Recommendation System** using:
  - Cosine similarity on TF-IDF  
  - Cosine similarity on SBERT embeddings  
- Stores all models in `joblib` for production

---

## 🧠 ML Pipeline Overview

TMDB API → Raw Data → Cleaning → Meta Text Creation
→ TF-IDF Vectorizer → X_tfidf.joblib
→ Count Vectorizer → X_count.joblib
→ Genre Vectorizer → X_genre.joblib
→ SBERT Embeddings → sbert_embeddings.joblib
→ FastAPI Inference → Flutter App → User Recommendations


---

## 🏗 Project Architecture



root
│── backend
│ ├── main.py (FastAPI)
│ ├── models/
│ │ ├── tfidf_vectorizer.joblib
│ │ ├── count_vectorizer.joblib
│ │ ├── genre_vectorizer.joblib
│ │ ├── sbert_embeddings.joblib
│ │ ├── X_tfidf.joblib
│ │ ├── X_count.joblib
│ │ └── X_genre.joblib
│ └── utils/
│ ├── clean.py
│ ├── vectorizer.py
│ └── recommender.py
│
│── data
│ └── final_dataset.csv
│
│── flutter_app/
│ ├── lib/
│ ├── assets/
│ └── apk-release/
│
└── README.md


---

## 💾 Dataset Details

The dataset is created by merging multiple datasets fetched through TMDB API:

- Movies  
- Anime  
- TV/Web Series  

Features include:

- Title  
- Overview  
- Genres  
- Cast  
- Keywords  
- Tagline  
- Popularity, Rating, Vote Count  
- Release Date  
- Poster URL  

Final cleaned dataset saved as:



data/final_dataset.csv


---

## 🔧 Feature Engineering

### ✔ **1. Meta Text Creation**
You combine everything into one string:



title + overview + genres + cast + keywords + tagline


This improves semantic understanding.

---

### ✔ **2. Vectorizers Used**

#### **TF-IDF → `tfidf_vectorizer.joblib`**
- Extracts keyword importance  
- Great for similarity based on text focus  

#### **Count Vectorizer → `count_vectorizer.joblib`**
- Useful for raw frequency patterns  

#### **Genre Vectorizer → `genre_vectorizer.joblib`**
- Multi-hot encoding of genres  

#### **SBERT Embeddings → `sbert_embeddings.joblib`**
- Captures semantic relationships  
- Better recommendations for similar meaning  

---

## 🧩 Hybrid Recommendation Logic

Your API uses:

### **TF-IDF similarity**


score_tfidf = cosine_similarity(query_tfidf, X_tfidf)


### **SBERT embedding similarity**


score_sbert = cosine_similarity(query_embedding, sbert_embeddings)


### **Hybrid weighted score**


final_score = (0.6 * score_sbert) + (0.4 * score_tfidf)


---

## ⚡ FastAPI Backend

### 🔹 Start server locally:
bash
uvicorn main:app --reload

🔹 API Endpoint
POST /recommend
{
  "title": "Interstellar"
}

🔹 Response Example
{
  "recommendations": [
    "Gravity",
    "The Martian",
    "Ad Astra",
    "Arrival",
    "Passengers"
  ]
}


Backend deployed on Render.com for public access.

📱 Flutter Mobile App

Built fully in Flutter

Clean UI with search functionality

App calls FastAPI endpoint and displays results beautifully

APK is included inside flutter_app/apk-release/

Screenshots section placeholder

![1](https://github.com/user-attachments/assets/c7d02678-9967-45bd-b9f9-16128ba2f137) 
![2](https://github.com/user-attachments/assets/9fe032f0-3156-4e19-b050-8e7ed5c7387e)
![3](https://github.com/user-attachments/assets/b6c414a7-3442-44e1-b4b1-8badedb1b137)
![4](https://github.com/user-attachments/assets/049dbc26-f3df-461e-8e29-c6a900edcd67)


☁ Deployment
Backend Deployment: Render

Upload FastAPI project

Add requirements.txt

Add environment variables:

TMDB_API_KEY = your_key

Flutter App Release:

Run:

flutter build apk --release


## 📲 Download Mobile App (APK)

Click the button below to download and install the Android app:

[![Download APK](https://img.shields.io/badge/Download-APK-green?style=for-the-badge&logo=android)](https://drive.google.com/file/d/14OmqwcCT33V3JEF3yUAK_DVMpCysuQI0/view?usp=drive_link)
  ## OR See On Web
### 🚀 Live Demo  
[![Netlify Status](https://img.shields.io/badge/Live%20Demo-Visit%20Site-blue?style=for-the-badge)](https://unique-heliotrope-d00057.netlify.app)


🛠 How to Run Everything Locally
Backend:
cd backend
pip install -r requirements.txt
uvicorn main:app --reload

Flutter App:
cd flutter_app
flutter pub get
flutter run

🤝 Problems Faced & Solutions
1. TMDB data duplication & inconsistencies

✔ Solved by merging datasets and dropping duplicates.

2. Cold-start for anime titles

✔ SBERT embeddings solved this by understanding semantic meaning.

3. API latency due to large vector matrices

✔ Pre-loaded vector matrices (X_tfidf, X_count) and embeddings in memory.

4. Flutter CORS issues during development

✔ Added FastAPI middleware:

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

🗺 Future Improvements

Add user ratings + collaborative filtering

Create personalized profiles

Add trending recommendations using TMDB live data

Add caching layer (Redis)

Add UI animations & dark theme in Flutter

📜 License

MIT License

⭐ Show some love

If you liked this project, please star the repo ⭐ — it helps this project grow!


---
