import firebase_admin
from fastapi import FastAPI, Header, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from firebase_admin import firestore, credentials, auth

from backend.connection.database_queries import get_tags, get_workers, get_templates, post_schedule, \
    get_previous_schedule
from backend.algorithm.algorithm import main

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
    allow_origin_regex=r"(http://localhost:\d+)|(https://p-inz-719da\.firebaseapp\.com)|(https://p-inz-719da\.web\.app)",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/run-algorithmv2/{template_id}")
def run_algorithm(authorization: str = Header(...), template_id: str = ""):
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

    templates = get_templates(user_id, db)
    template = [template for template in templates if template.id == template_id]
    try:
        template = template[0]
    except:
        raise HTTPException(status_code=404, detail="Template not found")


    result = main(workers, template)

    post_schedule(user_id, result, db)

    return result

@app.get("/generate_from_previous/{schedule_id}")
def generate_from_previous(authorization: str = Header(...), schedule_id: str = ""):
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=403, detail="Brak tokenu")

    id_token = authorization.split(" ")[1]

    try:
        decoded_token = auth.verify_id_token(id_token)
        user_id = decoded_token["uid"]
    except Exception as e:
        print("Błąd weryfikacji tokenu:", e)
        raise HTTPException(status_code=403, detail="Nieprawidłowy token")

    schedule = get_previous_schedule(user_id, schedule_id, db)

    post_schedule(user_id, schedule, db)

    return "Successfully generated new schedule from previous one."
