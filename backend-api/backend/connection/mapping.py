from backend.models.Worker import Worker
from backend.models.Tags import Tags
from backend.models.Template import Template

def map_tag(tag_data):
    if tag_data.get("isDeleted", "false") == "true":
        print("Tag is deleted, skipping mapping.")
        return None
    else:
        name = tag_data.get("tagName", "")
        description = tag_data.get("description", "")

        tag = Tags(
            name=name,
            description=description
        )

        return tag

def temporary_sex_mapping(worker_data, worker_firstname):
    try:
        sex = worker_data.get("sex", "")
        if sex:
            return sex
        if worker_firstname:
            last_letter = worker_firstname.strip()[-1].lower()
            # Prosta heurystyka: imiona kończące się na 'a' to kobiety (np. Maria), reszta to mężczyźni
            if last_letter == "a":
                return "female"
            else:
                return "male"
        return "unknown"
    except Exception as e:
        print(f"Błąd podczas mapowania płci: {e}")
        return "unknown"

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
    if worker_data.get("isDeleted", "false") == "true":
        print("Worker is deleted, skipping mapping.")
        return None
    else:
        firstname = worker_data.get("firstName", "")
        lastname = worker_data.get("lastName", "")
        sex = temporary_sex_mapping(worker_data, firstname)
        age = worker_data.get("age", 0)
        type_of_deal = worker_data.get("contractType", "")
        phone_number = worker_data.get("phoneNumber", "")
        email = worker_data.get("email", "")
        work_time_preference = worker_data.get("shiftPreference", "")
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
            max_working_hours=max_working_hours
        )

        worker.work_time_preference = work_time_preference_mapping(work_time_preference)

        tags = [tag for tag in tags_list if tag.name in tags_doc]
        worker.tags = tags if len(tags)>0 else tags_list[-1:]  # Default tag if no tags match

        return worker

def map_template(template_data):

    if template_data.get("isDeleted", "false") == "true":
        print("Template is deleted, skipping mapping.")
        return None
    elif template_data.get("isDataMissing", "false") == "true":
        print("Template data is missing, skipping mapping.")
        return None

    else:

        id = template_data.get("id", "")
        description = template_data.get("description", "")
        maxMen = template_data.get("maxMen", "")
        maxWomen = template_data.get("maxWomen", "")
        minMen = template_data.get("minMen", "")
        minWomen = template_data.get("minWomen", "")

        template = Template(
            id=id,
            description=description,
            maxMen=maxMen,
            maxWomen=maxWomen,
            minMen=minMen,
            minWomen=minWomen
        )


        return template




