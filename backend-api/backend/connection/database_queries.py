from backend.connection.mapping import *
from google.cloud.firestore_v1 import FieldFilter


def get_workers(user_id: str, tags_list, db):
    try:
        docs = db.collection("Markets").where(filter=FieldFilter("createdBy", "==", user_id)).limit(1).get()
        if not docs:
            print("No Market found for this user.")
            return []

        market_doc = docs[0]
        market_id = market_doc.id

        members_ref = db.collection("Markets").document(market_id).collection("members")
        member_docs = members_ref.get()

        workers = []
        for member_doc in member_docs:
            worker_data = member_doc.to_dict()
            try:
                worker = map_worker(worker_data, tags_list)
                workers.append(worker)
            except Exception as e:
                print(f"Error creating Worker from member {worker_data}: {e}")

        return workers

    except Exception as e:
        print(f"An error occurred while fetching workers: {e}")
        return []


def get_tags(user_id: str, db):
    try:
        docs = db.collection("Markets").where(filter=FieldFilter("createdBy", "==", user_id)).limit(1).get()

        if not docs:
            print("No Market found for this user.")
            return []

        market_doc = docs[0]
        market_id = market_doc.id

        tag_docs = db.collection("Markets").document(market_id).collection("Tags").get()

        tags = []
        for tag_doc in tag_docs:
            tag_data = tag_doc.to_dict()
            try:
                tag = map_tag(tag_data)
                tags.append(tag)
            except Exception as e:
                print(f"Error creating Tag from tag data {tag_data}: {e}")

        default = Tags("default", "no special tags")
        tags.append(default)
        return tags

    except Exception as e:
        print(f"An error occurred while fetching tags: {e}")
        return []

# if __name__ == "__main__":
#     cred = credentials.Certificate("../ServiceAccountKey.json")
#     app = firebase_admin.initialize_app(cred)
#
#     db = firestore.client(app)
#     user_id = "HvVnzo4Z4pafStpPbzMsmoPSa7t1"
#     workers_list = get_workers(user_id)
#     print(f"Retrieved {len(workers_list)} workers.")
#     tags_list = get_tags(user_id)
#     print(f"Retrieved {len(tags_list)} tags.")
