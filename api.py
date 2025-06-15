import firebase_admin
from fastapi import FastAPI
from firebase_admin import firestore, credentials

from backend.connection.database_queries import get_tags, get_workers
from backend.algorithm.algorithm import main
from backend.algorithm.use_scenario import setup_scenario

app = FastAPI()

@app.get("/run-algorithm")
def run_algorithm():
    cred = credentials.Certificate("backend/ServiceAccountKey.json")
    app = firebase_admin.initialize_app(cred)

    db = firestore.client(app)
    user_id = "HvVnzo4Z4pafStpPbzMsmoPSa7t1"
    tags = get_tags(user_id, db)
    workers = get_workers(user_id, tags, db)

    constraints, _, _ = setup_scenario()
    result = main(workers, constraints, tags)
    return result
