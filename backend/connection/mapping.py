from backend.models.Worker import Worker


def map_worker(worker_data):
    if worker_data.get("isDeleted", "false") == "true":
        print("Worker is deleted, skipping mapping.")
        return None
    else:
        firstname = worker_data.get("firstName", "")
        lastname = worker_data.get("lastName", "")
        sex = worker_data.get("sex", "")
        age = worker_data.get("age", 0)
        type_of_deal = worker_data.get("contractType", "")
        phone_number = worker_data.get("phoneNumber", "")
        email = worker_data.get("email", "")
        work_time_preference = worker_data.get("shiftPreference", "")
        max_working_hours = worker_data.get("maxWeeklyHours", 0)
        tags = worker_data.get("tags", [])

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

        worker.work_time_preference = work_time_preference
        worker.tags = tags

        return worker


