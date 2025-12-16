from backend.models.Rule import Rule
from backend.models.Worker import Worker
from backend.models.Tags import Tags
from backend.models.Template import Template
from backend.models.Shift import Shift

def map_tag(tag_data):
    if tag_data.get("isDeleted", False) == True:
        return None
    else:
        name = tag_data.get("tagName", "")
        description = tag_data.get("description", "")
        id = tag_data.get("id", "")

        tag = Tags(
            name=name,
            description=description,
            id = id
        )

        return tag

def work_time_preference_mapping(preference):
    try:
        if preference == "Poranne":
            return 1
        elif preference == "Popołudniowe":
            return 2
        else:
            return 0  # Default or unknown preference
    except Exception as e:
        print(f"Błąd podczas mapowania preferencji czasu pracy: {e}")
        return 0  # Default or unknown preference

def map_worker(worker_data, tags_list):
    if worker_data.get("isDeleted", False) == True:
        return None
    else:
        firstname = worker_data.get("firstName", "")
        lastname = worker_data.get("lastName", "")
        sex = worker_data.get("gender", "Nie określono")
        age = worker_data.get("age", 0)
        type_of_deal = worker_data.get("contractType", "")
        phone_number = worker_data.get("phoneNumber", "")
        email = worker_data.get("email", "")
        work_time_preference = worker_data.get("shiftPreference", "")
        id = worker_data.get("id", "")
        max_working_hours = worker_data.get("maxWeeklyHours", 0)
        tags_doc = worker_data.get("tags", [])

        worker = Worker(
            firstname=firstname,
            lastname=lastname,
            sex=sex,
            age=age,
            type_of_deal=type_of_deal,
            phone_number=phone_number,
            email=email,
            id=id,
            max_working_hours=max_working_hours
        )

        worker.work_time_preference = work_time_preference_mapping(work_time_preference)

        tags = [tag for tag in tags_list if tag.name in tags_doc]
        worker.tags = tags if len(tags)>0 else tags_list[-1:]  # Default tag if no tags match

        return worker

def normalize_hour(hour_str):
    try:
        parts = hour_str.split(":")
        hour = int(parts[0])
        minute = int(parts[1]) if len(parts) > 1 else 0

        return (hour, minute)

    except Exception as e:
        print(f"Error normalizing hour '{hour_str}': {e}")
        return hour_str

def map_shift(shift_data, shift_id):
    if shift_data.get == None:
        return None
    else:
        day = shift_data.get("day", "")
        start = shift_data.get("start", "")

        start = normalize_hour(start)
        end = shift_data.get("end", "")
        end = normalize_hour(end)

        requirements = shift_data.get("requirements", {})

        rules = []

        for req in requirements:
            tagId = req.get("tagId", "")
            count = req.get("count", 0)

            rule = Rule(tagId, count)
            rules.append(rule)


        shift = Shift(
            id=shift_id,
            day=day,
            start=start,
            end=end,
            rules=rules
        )
        return shift


def map_template(template_data):

    if template_data.get("isDeleted", False) == True:
        print("Template is deleted, skipping mapping.")
        return None
    elif template_data.get("isDataMissing", False) == True:
        print("Template data is missing, skipping mapping.")
        return None

    else:

        id = template_data.get("id", "")
        description = template_data.get("description", "")
        maxMen = template_data.get("maxMen", "")
        maxWomen = template_data.get("maxWomen", "")
        minMen = template_data.get("minMen", "")
        minWomen = template_data.get("minWomen", "")

        shifts_docs = template_data.get("shiftsMap", template_data.get("shifts_docs", []))
        shifts = [map_shift(shifts_docs[key], key) for key in shifts_docs if map_shift(shifts_docs[key], key) is not None]

        template = Template(
            id=id,
            description=description,
            maxMen=maxMen,
            maxWomen=maxWomen,
            minMen=minMen,
            minWomen=minWomen,
            shifts=shifts
        )

        return template




