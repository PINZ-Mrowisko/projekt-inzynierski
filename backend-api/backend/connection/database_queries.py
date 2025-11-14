from firebase_admin import firestore

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
                if worker is not None:
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
                if tag is not None:
                    tags.append(tag)
            except Exception as e:
                print(f"Error creating Tag from tag data {tag_data}: {e}")

        default = Tags("None","default", "no special tags")
        tags.append(default)
        return tags

    except Exception as e:
        print(f"An error occurred while fetching tags: {e}")
        return []

def get_templates(user_id: str, db):
    try:
        # znajdź Market użytkownika
        docs = db.collection("Markets").where(filter=FieldFilter("createdBy", "==", user_id)).limit(1).get()

        if not docs:
            print("No Market found for this user.")
            return []

        market_doc = docs[0]
        market_id = market_doc.id

        # pobierz Templates
        template_docs = db.collection("Markets").document(market_id).collection("Templates").get()

        templates = []
        for template_doc in template_docs:
            try:
                template_data = template_doc.to_dict()

                shifts_ref = (
                    db.collection("Markets")
                    .document(market_id)
                    .collection("Templates")
                    .document(template_doc.id)
                    .collection("Shifts")
                )

                shift_docs = shifts_ref.get()
                shifts = [s.to_dict() for s in shift_docs]

                template_data["Shifts"] = shifts

                template = map_template(template_data)
                if template is not None:
                    templates.append(template)

            except Exception as e:
                print(f"Error creating Template from template {template_doc.id}: {e}")

        return templates

    except Exception as e:
        print(f"An error occurred while fetching templates: {e}")
        return []

def post_schedule(user_id: str, schedule_data: dict, db):
    try:
        # znajdź Market użytkownika
        docs = db.collection("Markets").where(filter=FieldFilter("createdBy", "==", user_id)).limit(1).get()

        if not docs:
            print("No Market found for this user.")
            return None

        market_doc = docs[0]
        market_id = market_doc.id

        # dodaj Schedule
        schedules_ref = db.collection("Markets").document(market_id).collection("Schedules")
        new_schedule_ref = schedules_ref.document()
        new_schedule_ref.set(
            {
                "createdBy": user_id,
                "createdAt": firestore.firestore.SERVER_TIMESTAMP,
            }
        )

        # dodaj ShiftAssignments
        assignments_ref = new_schedule_ref.collection("ShiftAssignments")
        for assignment in schedule_data:
            assignment_doc = assignments_ref.document()
            assignment_doc.set(assignment)

        print(f"Schedule added with ID: {new_schedule_ref.id}")
        return new_schedule_ref.id

    except Exception as e:
        print(f"An error occurred while posting schedule: {e}")
        return None


