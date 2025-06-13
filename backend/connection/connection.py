import firebase_admin
from firebase_admin import firestore, credentials

cred = credentials.Certificate("../ServiceAccountKey.json")
app = firebase_admin.initialize_app(cred)

db = firestore.client(app)
# doc_ref = db.collection("Markets")
#
# try:
#     docs = doc_ref.get()
#     for doc in docs:
#         print(f"{doc.id} => {doc.to_dict()}")
# except Exception as e:
#     print(f"An error occurred: {e}")

