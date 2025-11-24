from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
import joblib
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity, linear_kernel
import difflib

app = FastAPI(title="AIO Recommender")

# ================= CORS =================
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ===== Base Directory =====
base_path = "models"

# ===== Load Small, Lightweight Data =====
art = joblib.load(f"{base_path}/meta_records.joblib")
meta_df = art["meta_df"]
title_to_idx = art["title_to_idx"]

tfidf = joblib.load(f"{base_path}/tfidf_vectorizer.joblib")
X_tfidf = joblib.load(f"{base_path}/X_tfidf.joblib")

title_vec = joblib.load(f"{base_path}/count_vectorizer.joblib")
X_title = joblib.load(f"{base_path}/X_count.joblib")

# ===== Optional Genre Matrix =====
try:
    genre_vec = joblib.load(f"{base_path}/genre_vectorizer.joblib")
    X_genre = joblib.load(f"{base_path}/X_genre.joblib")
except:
    genre_vec, X_genre = None, None

# ===== Load SBERT embeddings ONCE & NO MODEL LOAD =====
embeddings = None

def get_embeddings():
    global embeddings
    if embeddings is None:
        print("🔄 Loading SBERT embeddings...")
        embeddings = joblib.load(f"{base_path}/sbert_embeddings.joblib")
    return embeddings


# ================= API MODELS =================
class RecommendQuery(BaseModel):
    title: str
    type: Optional[str] = None
    model: Optional[str] = "hybrid"
    topn: Optional[int] = 10


# ================= HEALTH CHECK =================
@app.get("/health")
def health():
    return {"status": "ok"}


# ================= TITLE MATCHING =================
def resolve_title(user_title: str):
    t = user_title.lower().strip()

    # 1️⃣ Exact match
    if t in title_to_idx:
        return t

    # 2️⃣ Fuzzy match
    close = difflib.get_close_matches(t, list(title_to_idx.keys()), n=1, cutoff=0.6)
    if close:
        return close[0]

    # 3️⃣ SBERT semantic search WITHOUT loading model
    embs = get_embeddings()
    vec = embs.mean(axis=0)  # fallback baseline vector
    sims = cosine_similarity(embs, vec.reshape(1, -1)).flatten()
    best_idx = np.argmax(sims)
    return meta_df.iloc[best_idx]["name"].lower()


# ================= MAIN RECOMMEND ENDPOINT =================
@app.post("/recommend")
def recommend(q: RecommendQuery):
    embs = get_embeddings()

    user_title = q.title.strip().lower()
    resolved_title = resolve_title(user_title)

    if resolved_title is None:
        raise HTTPException(status_code=404, detail=f"No similar title found for '{q.title}'")

    idx = title_to_idx[resolved_title]

    type_filter = q.type.lower() if q.type else None
    topn = int(q.topn)

    # ---- Compute Similarities ----
    sbert_sims = cosine_similarity(
        embs[idx].reshape(1, -1),
        embs
    ).flatten()

    tfidf_sims = linear_kernel(X_tfidf[idx], X_tfidf).flatten()
    title_sims = linear_kernel(X_title[idx], X_title).flatten()

    if X_genre is not None:
        genre_sims = cosine_similarity(X_genre[idx], X_genre).flatten()
    else:
        genre_sims = np.zeros(len(meta_df))

    base_sims = (
        0.55 * sbert_sims +
        0.25 * tfidf_sims +
        0.15 * genre_sims +
        0.05 * title_sims
    )

    base_sims[idx] = -1.0  # avoid recommending itself

    # ---- TYPE FILTERING ----
    query_type = str(meta_df.iloc[idx]["clean_type"]).lower()

    if type_filter in ("movie", "anime", "webseries"):
        allowed_mask = (meta_df["clean_type"].str.lower() == type_filter)
    else:
        allowed_mask = np.ones(len(meta_df), dtype=bool)
        mismatch_mask = (meta_df["clean_type"].str.lower() != query_type)
        base_sims[mismatch_mask] *= 0.35

    allowed_indices = np.where(allowed_mask)[0]

    # ---- Candidate Set ----
    K = min(200, len(allowed_indices))
    candidates = allowed_indices[np.argsort(base_sims[allowed_indices])[::-1]][:K]

    # ---- Stage 2 Runtime Ranking ----
    final_scores = []
    query_runtime = meta_df.iloc[idx].get("runtime", np.nan)
    max_runtime = np.nanmax(meta_df["runtime"].values)

    for i in candidates:
        score = base_sims[i]

        rt = meta_df.iloc[i]["runtime"]
        if not np.isnan(rt) and not np.isnan(query_runtime):
            diff = abs(rt - query_runtime)
            rt_sim = 1 - min(diff / max_runtime, 1)
            score = 0.9 * score + 0.1 * rt_sim

        final_scores.append((i, score))

    final_scores.sort(key=lambda x: x[1], reverse=True)

    # ---- Remove duplicates ----
    results = []
    seen = set()

    for i, _ in final_scores:
        row = meta_df.iloc[i]

        if row["id"] in seen:
            continue
        seen.add(row["id"])

        results.append({
            "id": int(row["id"]),
            "name": row["name"],
            "type": row.get("clean_type", row.get("type", "")),
            "genres": row.get("genres", ""),
            "overview": row.get("overview", ""),
            "poster_url": row.get("poster_url", ""),
            "runtime": None if row["runtime"] < 0 else float(row["runtime"])
        })

        if len(results) >= topn:
            break

    return {
        "query": q.title,
        "resolved_title": resolved_title,
        "results": results
    }
