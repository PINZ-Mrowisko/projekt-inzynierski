from datetime import datetime

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

from datetime import datetime, timedelta
import calendar
from collections import defaultdict
from google.cloud import firestore
from google.cloud.firestore_v1.base_query import FieldFilter


def get_next_month_year():
    now = datetime.now()
    year = now.year + (1 if now.month == 12 else 0)
    month = 1 if now.month == 12 else now.month + 1
    return year, month


def group_schedule_by_day(schedule_data):
    grouped = defaultdict(list)
    for entry in schedule_data:
        grouped[entry["day"]].append(entry)
    return grouped


def post_schedule(user_id: str, schedule_data: dict, db):
    try:
        docs = db.collection("Markets") \
            .where(filter=FieldFilter("createdBy", "==", user_id)) \
            .limit(1).get()

        if not docs:
            print("No Market found for this user.")
            return None

        market_id = docs[0].id

        year, month = get_next_month_year()
        days_in_month = calendar.monthrange(year, month)[1]

        schedules_ref = db.collection("Markets").document(market_id).collection("Schedules")
        new_schedule_ref = schedules_ref.document()

        new_schedule_ref.set({
            "createdBy": user_id,
            "createdAt": firestore.SERVER_TIMESTAMP,
            "month_of_usage": month,
            "year_of_usage": year,
            "days_in_month": days_in_month
        })

        grouped = group_schedule_by_day(schedule_data)

        days_ref = new_schedule_ref.collection("DayAssignments")

        for day_number in range(1, days_in_month + 1):

            date = datetime(year, month, day_number)

            day_index = ((day_number - 1) % 7) + 1

            assignments = grouped.get(day_index, [])

            day_doc_ref = days_ref.document()
            day_doc_ref.set({
                "date": date,
                "day": day_number,
                "weekday": date.isoweekday(),
                "day_index": day_index
            })

            shifts_ref = day_doc_ref.collection("ShiftAssignments")

            for assignment in assignments:
                shifts_ref.document().set(assignment)

        print(f"Schedule created with ID: {new_schedule_ref.id}")
        return new_schedule_ref.id

    except Exception as e:
        print(f"An error occurred while posting schedule: {e}")
        return None




