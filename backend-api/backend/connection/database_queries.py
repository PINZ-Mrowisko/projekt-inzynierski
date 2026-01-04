import copy
from datetime import datetime

from firebase_admin import firestore

from backend.connection.mapping import *
from google.cloud.firestore_v1 import FieldFilter
from backend.connection.holidays_creation import *


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
                template = map_template(template_data)

                if template is not None:
                    templates.append(template)

            except Exception as e:
                print(f"Error creating Template from template {template_doc.id}: {e}")

        return templates

    except Exception as e:
        print(f"An error occurred while fetching templates: {e}")
        return []

from datetime import datetime
from google.cloud import firestore
from google.cloud.firestore_v1.base_query import FieldFilter


def get_next_month_year(now = datetime.now()):
    year = now.year + (1 if now.month == 12 else 0)
    month = 1 if now.month == 12 else now.month + 1
    return year, month


from collections import defaultdict
from datetime import date
import calendar

def is_on_leave(worker_id, check_date_str, leaves_req):

    if len(leaves_req) == 0:
        return False

    for leave in leaves_req:

        if leave.employee_id == worker_id and (leave.status == "zaakceptowany" or leave.status == "Mój urlop"):
            if leave.start_date <= check_date_str <= leave.end_date:
                return True
    return False

def expand_schedule_to_month(schedule_dict, year, month, leaves_req):
    grouped_template = defaultdict(list)
    iterator = schedule_dict.values() if isinstance(schedule_dict, dict) else schedule_dict

    for entry in iterator:
        if isinstance(entry, dict) and "day" in entry:
            grouped_template[entry["day"]].append(entry)

    WEEKDAYS_MAP = {
        0: "Poniedziałek", 1: "Wtorek", 2: "Środa", 3: "Czwartek",
        4: "Piątek", 5: "Sobota", 6: "Niedziela"
    }

    full_month_schedule = defaultdict(list)
    days_in_month = calendar.monthrange(year, month)[1]

    for day_num in range(1, days_in_month + 1):
        current_date = date(year, month, day_num)
        date_str = current_date.strftime("%Y-%m-%d")

        day_of_week_index = current_date.weekday()
        day_name_pl = WEEKDAYS_MAP[day_of_week_index]

        shifts_for_day = grouped_template.get(day_name_pl, [])

        for shift in shifts_for_day:
            new_entry = copy.deepcopy(shift)
            new_entry["date"] = date_str

            if "assignments" in new_entry:
                for assignment in new_entry["assignments"]:
                    worker_id = assignment.get("workerId", "")
                    if is_on_leave(worker_id, date_str, leaves_req):
                        assignment["firstName"] = "Unknown"
                        assignment["lastName"] = "Unknown"
                        assignment["workerId"] = "Unknown"
                        assignment["onLeave"] = True

            full_month_schedule[date_str].append(new_entry)

    return full_month_schedule


def post_schedule(user_id: str, template_id, year, month, schedule_data: dict, leaves_req ,db):
    try:
        docs = db.collection("Markets") \
            .where(filter=FieldFilter("createdBy", "==", user_id)) \
            .limit(1).get()

        if not docs:
            print("No Market found for this user.")
            return None

        market_id = docs[0].id

        days_in_month = calendar.monthrange(year, month)[1]

        full_month_data = expand_schedule_to_month(schedule_data, year, month, leaves_req)
        schedules_ref = db.collection("Markets").document(market_id).collection("Schedules")
        new_schedule_ref = schedules_ref.document()

        new_schedule_ref.set({
            "createdBy": user_id,
            "createdAt": firestore.SERVER_TIMESTAMP,
            "templateUsed": template_id,
            "month_of_usage": month,
            "year_of_usage": year,
            "days_in_month": days_in_month,
            "generated_schedule": full_month_data,
            "weekly_template_snapshot": schedule_data
        })

        print(f"Schedule created with ID: {new_schedule_ref.id}")
        return new_schedule_ref.id

    except Exception as e:
        print(f"An error occurred while posting schedule: {e}")
        return None

def get_previous_schedule(user_id, schedule_id, db):
    try:
        docs = db.collection("Markets") \
            .where(filter=FieldFilter("createdBy", "==", user_id)) \
            .limit(1).get()

        if not docs:
            print("No Market found for this user.")
            return []

        market_id = docs[0].id

        schedule_doc = db.collection("Markets") \
            .document(market_id) \
            .collection("Schedules") \
            .document(schedule_id) \
            .get()

        if not schedule_doc.exists:
            print("Schedule not found.")
            return []

        schedule_data = schedule_doc.to_dict().get("weekly_template_snapshot", [])
        template_id = schedule_doc.to_dict().get("templateUsed", "")

        return schedule_data, template_id

    except Exception as e:
        print(f"An error occurred while fetching previous schedule: {e}")
        return []

def get_leave_requests(user_id: str, db):
    try:
        docs = db.collection("Markets") \
            .where(filter=FieldFilter("createdBy", "==", user_id)) \
            .limit(1).get()

        if not docs:
            print("No Market found for this user.")
            return []

        market_id = docs[0].id

        leave_req_docs = db.collection("Markets") \
            .document(market_id) \
            .collection("LeaveReq") \
            .get()

        leave_requests = []
        for leave_req_doc in leave_req_docs:
            leave_req_data = leave_req_doc.to_dict()
            try:
                leave_request = map_leave_request(leave_req_data)
                if leave_request is not None:
                    leave_requests.append(leave_request)
            except Exception as e:
                print(f"Error creating LeaveReq from data {leave_req_data}: {e}")

        return leave_requests

    except Exception as e:
        print(f"An error occurred while fetching leave requests: {e}")
        return []

def post_holidays(db):
    try:
        pl_holidays = get_holidays()

        for holiday in pl_holidays:

            name = holiday["name"]
            date = holiday["date"]

            doc_ref = db.collection("Holidays").document(date)
            doc_data = {
                "name": name,
                "date": date,
                "last_updated": firestore.SERVER_TIMESTAMP
            }

            doc_ref.set(doc_data)

        return "success"
    except Exception as e:
        print(f"An error occurred while posting holidays: {e}")



