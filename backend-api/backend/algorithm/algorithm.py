from ortools.sat.python import cp_model
from backend.algorithm.solver import ShiftPrinter
from backend.connection.database_queries import *

def generate_all_shifts(model, days, shifts, all_workers):
    all_shifts = {}

    for worker in all_workers:
        for day in range(days):
            for shift in range(shifts):
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


def main(workers, constraints, tags):
    model = cp_model.CpModel()
    tag_groups = divide_workers_by_tags(workers, tags)

    if len(tag_groups) != 5:
        raise ValueError("Not matching scenario: Tags")

    all_workers = len(workers)

    if all_workers < 19:
        raise ValueError("Not enough workers for the scenario: at least 19 workers are required.")

    all_shifts = generate_all_shifts(model, constraints.days, constraints.shifts, workers)

    for worker in workers:
        for day in range(constraints.days):
            for shift in range(constraints.shifts):
                for role in worker.tags:
                    all_shifts[(worker, day, shift, role)] = model.new_bool_var(f"shift: {worker} | {day} | {shift} | {role}")

    for day in range(constraints.days):
        for shift in range(constraints.shifts):

            RULE_working_tags_number(model, all_shifts, tag_groups, day, shift, tags[0], 3, 3)
            RULE_working_tags_number(model, all_shifts, tag_groups, day, shift, tags[1], 1, constraints.max_num_workers)
            RULE_working_tags_number(model, all_shifts, tag_groups, day, shift, tags[2], 1, 1)
            RULE_working_tags_number(model, all_shifts, tag_groups, day, shift, tags[3], 1, 1)

            worker_assigned = []
            male_assigned = []
            female_assigned = []

            for worker in workers:
                group_b = [role for role in worker.tags if role.name != "Kierownik"]

                if not group_b:
                    continue

                non_kierownik_assignments = [
                    all_shifts[(worker, day, shift, role)]
                    for role in group_b
                ]
                is_non_kierownik_assigned = model.NewBoolVar(f"{worker}_{day}_{shift}_assigned_non_kierownik")
                model.AddMaxEquality(is_non_kierownik_assigned, non_kierownik_assignments)

                worker_assigned.append(is_non_kierownik_assigned)

                if worker.sex == 'male':
                    male_assigned.append(is_non_kierownik_assigned)
                else:
                    female_assigned.append(is_non_kierownik_assigned)

            model.Add(sum(worker_assigned) >= constraints.min_num_workers)
            model.Add(sum(worker_assigned) <= constraints.max_num_workers)
            model.Add(sum(male_assigned) >= constraints.male_number[0])
            model.Add(sum(female_assigned) >= constraints.female_number[0])
            model.Add(sum(female_assigned) <= constraints.female_number[1])
            model.Add(sum(male_assigned) <= constraints.male_number[1])

    for worker in workers:
        shifts_assigned = [
            all_shifts[(worker, day, shift, role)]
            for day in range(constraints.days)
            for shift in range(constraints.shifts)
            for role in worker.tags
        ]
        model.add(sum(shifts_assigned) < 10)

    for worker in workers:
        for day in range(constraints.days):
            shift_presence = []
            for shift in range(constraints.shifts):
                role_assignments = [
                    all_shifts[(worker, day, shift, role)]
                    for role in worker.tags
                ]
                model.Add(sum(role_assignments) <= 1)
                works_this_shift = model.NewBoolVar(f"{worker}_{day}_{shift}_works")
                model.AddMaxEquality(works_this_shift, role_assignments)
                shift_presence.append(works_this_shift)

            model.Add(sum(shift_presence) <= 1)

    solver = cp_model.CpSolver()
    printer = ShiftPrinter(all_shifts, workers, constraints)

    status = solver.Solve(model, printer)

    if status == cp_model.OPTIMAL or status == cp_model.FEASIBLE:
        printer.on_solution_callback()
        print("\nFinal Solution:")
        printer.print_best_solution()
        return printer.results_json()
    else:
        print("No solution found.")
        return {"status": "No solution found."}
