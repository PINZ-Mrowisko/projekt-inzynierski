from ortools.sat.python import cp_model
from backend.algorithm.solver import ShiftPrinter
from backend.connection.database_queries import *


def generate_all_variables(model, all_shifts, all_workers):
    variables = {}

    # print(all_shifts)
    # print(all_workers)

    for worker in all_workers:
        for shift in all_shifts:
            # print(shift.rules)

            for rule_idx, rule in enumerate(shift.rules):

                worker_tags_ids = [t.id for t in worker.tags]
                required_tags = rule.tags

                if set(required_tags).issubset(set(worker_tags_ids)):
                    variables[(worker.id, shift.id, rule_idx)] = model.new_bool_var(
                        f"W:{worker.firstname}_D:{shift.id}_R:{rule_idx}"
                    )
                    print(f"DEBUG: Var created for Shift ID: {shift.id} | Worker: {worker.firstname} | Rule: {rule_idx}")

    return variables

def create_tag_group(all_workers, tag):
    return [worker for worker in all_workers if tag in worker.tags]


def divide_workers_by_tags(all_workers, all_tags):
    tag_groups = {}
    for tag in all_tags:
        tag_groups[tag] = create_tag_group(all_workers, tag)
    return tag_groups

def RULE_working_tags_number(model, all_shifts, tag_groups, day, shift, tag, minimum, maximum):
    role_assignments = [
        all_shifts[(worker, day, shift, tag)]
        for worker in tag_groups[tag]
    ]
    model.add(sum(role_assignments) >= minimum)
    model.add(sum(role_assignments) <= maximum)
    return


def main(workers, template: Template, tags):
    model = cp_model.CpModel()
    print("starting main")
    tag_groups = divide_workers_by_tags(workers, tags)
    print("group tags")
    all_shifts = template.shifts
    print("All shifts:")

    all_variables = generate_all_variables(model, template.shifts, workers)

    preference_vars = []
    worker_hour_worked_on_shift = {w.firstname: [] for w in workers}

    for shift in all_shifts:

        worker_assignments_on_shift = {w.id: [] for w in workers}

        for rule_idx, rule in enumerate(shift.rules):

            assigned_vars_for_rule = []

            for worker in workers:
                key = (worker.id, shift.id, rule_idx)

                if key in all_variables:
                    var = all_variables[key]
                    assigned_vars_for_rule.append(var)
                    print(var)

                    worker_assignments_on_shift[worker.id].append(var)
                    worker_hour_worked_on_shift[worker.firstname].append(var * shift.duration)

                    if shift.type == worker.work_time_preference:
                        preference_vars.append(var)

            model.Add(sum(assigned_vars_for_rule) == rule.count)

    WEIGHT_PREFERENCE = 200  # Bonus za pracę w ulubionej porze
    WEIGHT_TIME = 1  # Bonus za każdą przepracowaną minutę

    total_time_working = []

    for worker in workers:
        actual_work_time = sum(worker_hour_worked_on_shift[worker.firstname])
        max_minutes = worker.get_max_working_hours() * 60
        model.Add(actual_work_time <= max_minutes)

        total_time_working.append(actual_work_time)



    model.Maximize(
        sum(preference_vars) * WEIGHT_PREFERENCE +
        sum(total_time_working) * WEIGHT_TIME
    )

    solver = cp_model.CpSolver()
    #printer = ShiftPrinter(all_variables, workers, template)

    status = solver.Solve(model)

    if status == cp_model.OPTIMAL:
        print("\nFinal Solution:")
        #printer.print_best_solution()
        for v in all_variables.values():
            if solver.Value(v) == 1:
                print(f"{v} = 1")

        return "success"#printer.results_json()
    else:
        print("No solution found.")
        return {"status": "No solution found."}