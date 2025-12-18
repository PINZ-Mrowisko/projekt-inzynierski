from ortools.sat.python import cp_model
from backend.connection.database_queries import *


def generate_all_variables(model, all_shifts, all_workers):
    variables = {}

    for worker in all_workers:

        for shift in all_shifts:

            for rule_idx, rule in enumerate(shift.rules):

                worker_tags_ids = [t.id for t in worker.tags]
                required_tags = rule.tags

                if set(required_tags).issubset(set(worker_tags_ids)) or len(worker.tags) == 0:
                    variables[(worker.id, shift.id, rule_idx)] = model.new_bool_var(
                        f"W:{worker.id}_D:{shift.id}_R:{rule_idx}"
                    )
    return variables

def main(workers, template: Template):

    model = cp_model.CpModel()
    all_shifts = template.shifts

    all_variables = generate_all_variables(model, template.shifts, workers)

    preference_vars = []
    worker_hour_worked_on_shift = {w.id: [] for w in workers}
    assignments_for_worker_per_day = {}
    no_tag_worker_working_var = []

    for shift in all_shifts:

        worker_assignments_on_this_shift = {w.id: [] for w in workers}

        males_assigned_to_shift = []
        females_assigned_to_shift = []

        for rule_idx, rule in enumerate(shift.rules):

            assigned_vars_for_rule = []

            for worker in workers:

                key = (worker.id, shift.id, rule_idx)

                if key in all_variables:

                    var = all_variables[key]

                    assigned_vars_for_rule.append(var)
                    worker_assignments_on_this_shift[worker.id].append(var)
                    worker_hour_worked_on_shift[worker.id].append(var * shift.duration)

                    day_key = (worker.id, shift.day)
                    if day_key not in assignments_for_worker_per_day:
                        assignments_for_worker_per_day[day_key] = []
                    assignments_for_worker_per_day[day_key].append(var)

                    if rule.attach_default_rules:
                        if worker.sex == 'Mężczyzna':
                            males_assigned_to_shift.append(var)
                        else:
                            females_assigned_to_shift.append(var)

                    if len(rule.tags) > 0 and len(worker.tags) == 0:
                        no_tag_worker_working_var.append(var)

                    if shift.type == worker.work_time_preference:

                        preference_vars.append(var)

            model.Add(sum(assigned_vars_for_rule) == rule.count)

        if shift.attach_default_rules:
            model.Add(sum(males_assigned_to_shift) >= template.minMen)
            model.Add(sum(females_assigned_to_shift) >= template.minWomen)
            model.Add(sum(males_assigned_to_shift) <= template.maxMen)
            model.Add(sum(females_assigned_to_shift) <= template.maxWomen)


        for worker in workers:
            vars_in_shift = worker_assignments_on_this_shift[worker.id]
            if vars_in_shift:
                model.Add(sum(vars_in_shift) <= 1)

    for day_key, vars_in_day in assignments_for_worker_per_day.items():
        if vars_in_day:
            model.Add(sum(vars_in_day) <= 1)

    WEIGHT_PREFERENCE = 200  # Bonus za pracę w ulubionej porze
    WEIGHT_TIME = 1  # Bonus za każdą przepracowaną minutę
    WEIGHT_ACTIVATION_PENALTY = 1000  # Kara za aktywację pracownika
    WEIGHT_NO_TAG_WORKER_PENALTY = 2000  # Kara za przydzielenie zmiany pracownikowi bez wymaganych tagów

    total_time_working = []
    activation_vars = {}

    for worker in workers:
        actual_work_time = sum(worker_hour_worked_on_shift[worker.id])
        max_minutes = worker.max_working_hours * 60
        is_active = model.new_bool_var(f"active_{worker.id}")
        activation_vars[worker.id] = is_active

        model.Add(actual_work_time <= max_minutes * is_active)

        total_time_working.append(actual_work_time)



    model.Maximize(
        sum(preference_vars) * WEIGHT_PREFERENCE +
        sum(total_time_working) * WEIGHT_TIME -
        sum(activation_vars.values()) * WEIGHT_ACTIVATION_PENALTY -
        sum(no_tag_worker_working_var) * WEIGHT_NO_TAG_WORKER_PENALTY
    )


    solver = cp_model.CpSolver()

    status = solver.Solve(model)

    if status == cp_model.OPTIMAL:

        print("\n--- DIAGNOSTYKA SOLVERA ---")
        for worker in workers:
            is_active_val = solver.Value(activation_vars[worker.id])

            minutes_assigned = 0

            print(f"\nPracownik: {worker.firstname}")
            print(f"  -> Czy pracuje: {"tak" if is_active_val == 1 else "nie"}")
            print(f"  -> Limit godzin: {worker.max_working_hours}")

            for shift in all_shifts:
                for rule_idx, rule in enumerate(shift.rules):
                    key = (worker.id, shift.id, rule_idx)
                    if key in all_variables and solver.Value(all_variables[key]) == 1:
                       print(f"     - Dostał zmianę: {shift.day} {shift.start}-{shift.end} ({shift.duration} min)")
                       minutes_assigned += shift.duration

            print(f"  -> Łącznie przydzielono: {minutes_assigned / 60} h")

        return solver, all_variables
    else:
        print("No solution found.")
        return {"status": "No solution found."}, None