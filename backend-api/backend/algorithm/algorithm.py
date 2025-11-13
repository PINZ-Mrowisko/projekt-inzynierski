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
                    print(f"shift: {worker} | {day} | {shift} | {role}")
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

# def LEGACY_alg(workers, constraints, tags):
#     model = cp_model.CpModel()
#     tag_groups = divide_workers_by_tags(workers, tags)
#
#     all_shifts = generate_all_shifts(model, constraints.days, constraints.shifts, workers)
#
#     for worker in workers:
#         for day in range(constraints.days):
#             for shift in range(constraints.shifts):
#                 for role in worker.tags:
#                     all_shifts[(worker, day, shift, role)] = model.new_bool_var(f"shift: {worker} | {day} | {shift} | {role}")
#
#     for day in range(constraints.days):
#         for shift in range(constraints.shifts):
#
#             RULE_working_tags_number(model, all_shifts, tag_groups, day, shift, tags[0], 3, 3)
#             RULE_working_tags_number(model, all_shifts, tag_groups, day, shift, tags[1], 1, constraints.max_num_workers)
#             RULE_working_tags_number(model, all_shifts, tag_groups, day, shift, tags[2], 1, 1)
#             RULE_working_tags_number(model, all_shifts, tag_groups, day, shift, tags[3], 1, 1)
#
#             worker_assigned = []
#             male_assigned = []
#             female_assigned = []
#
#             for worker in workers:
#                 group_b = [role for role in worker.tags if role.name != "Kierownik"]
#
#                 if not group_b:
#                     continue
#
#                 non_kierownik_assignments = [
#                     all_shifts[(worker, day, shift, role)]
#                     for role in group_b
#                 ]
#                 is_non_kierownik_assigned = model.NewBoolVar(f"{worker}_{day}_{shift}_assigned_non_kierownik")
#                 model.AddMaxEquality(is_non_kierownik_assigned, non_kierownik_assignments)
#
#                 worker_assigned.append(is_non_kierownik_assigned)
#
#                 if worker.sex == 'male':
#                     male_assigned.append(is_non_kierownik_assigned)
#                 else:
#                     female_assigned.append(is_non_kierownik_assigned)
#
#             model.Add(sum(worker_assigned) >= constraints.min_num_workers)
#             model.Add(sum(worker_assigned) <= constraints.max_num_workers)
#             model.Add(sum(male_assigned) >= constraints.male_number[0])
#             model.Add(sum(female_assigned) >= constraints.female_number[0])
#             model.Add(sum(female_assigned) <= constraints.female_number[1])
#             model.Add(sum(male_assigned) <= constraints.male_number[1])
#
#     for worker in workers:
#         shifts_assigned = [
#             all_shifts[(worker, day, shift, role)]
#             for day in range(constraints.days)
#             for shift in range(constraints.shifts)
#             for role in worker.tags
#         ]
#         model.add(sum(shifts_assigned) < 10)
#
#     for worker in workers:
#         for day in range(constraints.days):
#             shift_presence = []
#             for shift in range(constraints.shifts):
#                 role_assignments = [
#                     all_shifts[(worker, day, shift, role)]
#                     for role in worker.tags
#                 ]
#                 model.Add(sum(role_assignments) <= 1)
#                 works_this_shift = model.NewBoolVar(f"{worker}_{day}_{shift}_works")
#                 model.AddMaxEquality(works_this_shift, role_assignments)
#                 shift_presence.append(works_this_shift)
#
#             model.Add(sum(shift_presence) <= 1)
#
#     solver = cp_model.CpSolver()
#     printer = ShiftPrinter(all_shifts, workers, constraints)
#
#     status = solver.Solve(model, printer)
#
#     if status == cp_model.OPTIMAL or status == cp_model.FEASIBLE:
#         printer.on_solution_callback()
#         print("\nFinal Solution:")
#         printer.print_best_solution()
#         return printer.results_json()
#     else:
#         print("No solution found.")
#         return {"status": "No solution found."}

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
    # print("in main function")
    # for worker in workers:
    #     for day in range(template.days):
    #         day_name = days_dict[day]
    #         shifts_that_day = template.shifts_number[day_name] if day_name in template.shifts_number else 0
    #
    #         for shift in range(shifts_that_day):
    #             for role in worker.tags:
    #                 all_shifts[(worker, day, shift, role)] = model.new_bool_var(f"shift: {worker} | {day} | {shift} | {role}")
    #                 print(f"shift: {worker} | {day} | {shift} | {role}")

    for day in range(template.days):
        day_name = days_dict[day]
        shifts_that_day = template.shifts_number[day_name] if day_name in template.shifts_number else 0
        shifts_objects = [s for s in template.shifts if s.day == day_name]
        print(shifts_objects)

        for shift in range(shifts_that_day):

            current_shift = shifts_objects[shift]
            current_role_id = current_shift.tagId
            tag = next((t for t in tags if t.id == current_role_id), None)

            RULE_working_tags_number(model, all_shifts, tag_groups, day, shift, tag, current_shift.count, current_shift.count)

            male_assigned = []
            female_assigned = []

            model.Add(sum(male_assigned) >= template.minMen)
            model.Add(sum(female_assigned) >= template.minWomen)
            model.Add(sum(female_assigned) <= template.maxWomen)
            model.Add(sum(male_assigned) <= template.minMen)

    solver = cp_model.CpSolver()
    printer = ShiftPrinter(all_shifts, workers, template)

    status = solver.Solve(model, printer)

    if status == cp_model.OPTIMAL or status == cp_model.FEASIBLE:
        # print('DDDDDDDDDDDDDDDDDDDDDDDD')
        # printer.on_solution_callback()
        print("\nFinal Solution:")
        printer.print_best_solution()
        return printer.results_json()
    else:
        print("No solution found.")
        return {"status": "No solution found."}
