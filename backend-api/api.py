import firebase_admin
from fastapi import FastAPI, Header, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from firebase_admin import firestore, credentials, auth

from backend.connection.database_queries import get_tags, get_workers
from backend.algorithm.algorithm import main
from backend.models.Constraints import Constraints

# === Inicjalizacja Firebase Admin SDK dla Cloud Run ===
if not firebase_admin._apps:
    firebase_admin.initialize_app(
        credentials.ApplicationDefault(),
        {'projectId': 'p-inz-719da'}
    )

# Firestore client
db = firestore.client()

# FastAPI init
app = FastAPI()

# === CORS CONFIGURATION ===
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://localhost:\d+",  #tylko na development!!!
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/run-algorithm")
def run_algorithm(authorization: str = Header(...)):
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=403, detail="Brak tokenu")

    id_token = authorization.split(" ")[1]

    try:
        decoded_token = auth.verify_id_token(id_token)
        user_id = decoded_token["uid"]
    except Exception as e:
        print("Błąd weryfikacji tokenu:", e)
        raise HTTPException(status_code=403, detail="Nieprawidłowy token")

    tags = get_tags(user_id, db)
    workers = get_workers(user_id, tags, db)
    constraints = Constraints()
    result = main(workers, constraints, tags)
    return result
