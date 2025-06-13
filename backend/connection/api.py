from backend.connection.connection import db
from backend.models import Worker
from backend.connection.mapping import map_worker

def get_workers(user_id: str):
    try:
        # Get the Market document created by the user
        doc_ref = db.collection("Markets")
        docs = doc_ref.where("createdBy", "==", user_id).limit(1).get()

        if not docs:
            print("No Market found for this user.")
            return []

        market_doc = docs[0]
        market_id = market_doc.id  # Get the document ID of the Market

        # Query the 'members' subcollection under this Market
        members_ref = db.collection("Markets").document(market_id).collection("members")
        member_docs = members_ref.get()

        workers = []
        for member_doc in member_docs:
            worker_data = member_doc.to_dict()
            try:
                worker = map_worker(worker_data)
                workers.append(worker)
            except Exception as e:
                print(f"Error creating Worker from member {worker_data}: {e}")

        return workers

    except Exception as e:
        print(f"An error occurred while fetching workers: {e}")
        return []

# Test call
user_id = "HvVnzo4Z4pafStpPbzMsmoPSa7t1"
workers_list = get_workers(user_id)
print(f"Retrieved {len(workers_list)} workers.")
