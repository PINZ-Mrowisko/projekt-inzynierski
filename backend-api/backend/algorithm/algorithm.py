from ortools.sat.python import cp_model
from backend.algorithm.solver import ShiftPrinter
from backend.connection.database_queries import *

def generate_all_shifts(model, days, shifts, all_workers):
    all_shifts = {}

    days_dict = {
        0: "Poniedziałek",
        1: "Wtorek",
        2: "Środa",
        3: "Czwartek",
        4: "Piątek",
        5: "Sobota",
        6: "Niedziela"
    }


    for worker in all_workers:
        for day in range(days):

            day_name = days_dict[day]
            shifts_that_day = shifts[day_name] if day_name in shifts else 0

            for shift in range(shifts_that_day):
                for role in worker.tags:
                    all_shifts[(worker, day, shift, role)] = model.new_bool_var(
                        f"shift: {worker} | {day} | {shift} | {role}")

    return all_shifts

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
    tag_groups = divide_workers_by_tags(workers, tags)

    all_shifts = generate_all_shifts(model, template.days, template.shifts_number, workers)

    days_dict = {
        0: "Poniedziałek",
        1: "Wtorek",
        2: "Środa",
        3: "Czwartek",
        4: "Piątek",
        5: "Sobota",
        6: "Niedziela"
    }

    preference_vars = []


    for day in range(template.days):
        day_name = days_dict[day]
        shifts_that_day = template.shifts_number.get(day_name, 0)
        shifts_objects = [s for s in template.shifts if s.day == day_name]

        for shift_index in range(shifts_that_day):
            current_shift = shifts_objects[shift_index]
            current_role_id = current_shift.tagId
            tag = next((t for t in tags if t.id == current_role_id), None)

            RULE_working_tags_number(model, all_shifts, tag_groups, day, shift_index, tag, current_shift.count,
                                     current_shift.count)

            male_assigned = []
            female_assigned = []

            for worker in workers:
                if (worker, day, shift_index, tag) in all_shifts:
                    assigned_var = all_shifts[(worker, day, shift_index, tag)]

                    if current_shift.type == worker.work_time_preference:
                        preference_vars.append(assigned_var)

                    if worker.sex == 'male':
                        male_assigned.append(assigned_var)
                    else:
                        female_assigned.append(assigned_var)

            model.Add(sum(male_assigned) >= template.minMen)
            model.Add(sum(female_assigned) >= template.minWomen)
            model.Add(sum(female_assigned) <= template.maxWomen)
            model.Add(sum(male_assigned) <= template.maxMen)

    model.Maximize(sum(preference_vars))

    solver = cp_model.CpSolver()
    printer = ShiftPrinter(all_shifts, workers, template)

    status = solver.Solve(model, printer)

    if status == cp_model.OPTIMAL:
        print("\nFinal Solution:")
        printer.print_best_solution()
        return printer.results_json()
    else:
        print("No solution found.")
        return {"status": "No solution found."}
