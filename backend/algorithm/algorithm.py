from ortools.sat.python import cp_model

from backend.models.Constraints import Constraints
from backend.models.Tags import Tags
from backend.models.Worker import Worker


def generate_all_shifts(days, shifts, workers):
    all_shifts = {}

    for worker in workers:
        for day in range(days):
            for shift in range(shifts):
                for role in worker.tags:
                    all_shifts[(worker, day, shift, role)] = model.new_bool_var(
                        f"shift: {worker} | {day} | {shift} | {role}")
    return all_shifts

def create_tag_group(workers, tag):
    return [worker for worker in workers if tag in worker.tags]

def divide_workers_by_tags(workers, tags):
    tag_groups = {}
    for tag in tags:
        tag_groups[tag] = create_tag_group(workers, tag)
    return tag_groups

def RULE_working_tags_number(all_shifts, tag_groups, day, shift, tag, minimum, maximum):
    role_assignments = [
        all_shifts[(cashier, day, shift, tag)]
        for cashier in tag_groups[tag]
    ]
    model.add(sum(role_assignments) >= minimum)
    model.add(sum(role_assignments) <= maximum)
    return


def main():

    kasjer = Tags("kasjer", "ten co sprzedaje")
    wozek_widlowy = Tags("wózek widłowy", "z uprawnieniami na wózek widłowy")
    kierownik = Tags("kierownik", "pan i władca")
    koordynator = Tags("koordynator", "logistyka tego typu")

    tags = [kasjer, wozek_widlowy, kierownik, koordynator]

    cashier1 = Worker("Adam", "Mada", 20, "umowa zlecenie", 222, "123@wp.pl")
    cashier2 = Worker("Bartek", "Ketrab", 20, "umowa zlecenie", 222, "123@wp.pl")
    cashier3 = Worker("Czesław", "Wałsecz", 20, "umowa zlecenie", 222, "123@wp.pl")
    cashier4 = Worker("Alan", "Nala", 20, "umowa zlecenie", 222, "123@wp.pl")
    cashier5 = Worker("Barbara", "Arabrab", 20, "umowa zlecenie", 222, "123@wp.pl")
    cashier6 = Worker("Cecylia", "Ailycec", 20, "umowa zlecenie", 222, "123@wp.pl")


    cashier1.add_tag(kasjer)
    cashier2.add_tag(kasjer)
    cashier3.add_tag(kasjer)
    cashier4.add_tag(kasjer)
    cashier5.add_tag(kasjer)
    cashier6.add_tag(kasjer)


    wozkowy1 = Worker("Damian", "Naimad", 20, "umowa zlecenie", 222, "123@wp.pl")
    wozkowy2 = Worker("Duda", "Adud", 20, "umowa zlecenie", 222, "123@wp.pl")
    wozkowy3 = Worker("Dagmara", "Aramgad", 20, "umowa zlecenie", 222, "123@wp.pl")

    wozkowy1.add_tag(wozek_widlowy)
    wozkowy2.add_tag(wozek_widlowy)
    wozkowy3.add_tag(wozek_widlowy)

    manager1 = Worker("Edyta", "Atyde", 20, "umowa zlecenie", 222, "123@wp.pl")
    vice_manager1 = Worker("Eliasz", "Zsaile", 20, "umowa zlecenie", 222, "123@wp.pl")
    vice_manager2 = Worker("Edward", "Drawde", 20, "umowa zlecenie", 222, "123@wp.pl")

    manager1.add_tag(kierownik)
    vice_manager1.add_tag(kierownik)
    vice_manager2.add_tag(kierownik)

    coordinator1 = Worker("Felix", "Xilef", 20, "umowa zlecenie", 222, "123@wp.pl")
    coordinator2 = Worker("Fiona", "Anoif", 20, "umowa zlecenie", 222, "123@wp.pl")

    coordinator1.add_tag(koordynator)
    coordinator2.add_tag(koordynator)

    workers = [cashier1, cashier2, cashier3, cashier4, cashier5, cashier6,
               wozkowy1, wozkowy2, wozkowy3,
               manager1, vice_manager1, vice_manager2,
               coordinator1, coordinator2
               ]

    tag_groups = divide_workers_by_tags(workers, tags)

    all_workers = len(workers)
    print("Number of workers: ", all_workers)

    all_shifts = generate_all_shifts(constraints.days, constraints.shifts, workers)

    for worker in workers:
        for day in range(constraints.days):
            for shift in range(constraints.shifts):
                for role in worker.tags:
                    all_shifts[(worker, day, shift, role)] = model.new_bool_var(f"shift: {worker} | {day} | {shift} | {role}")

    for day in range(constraints.days):
        for shift in range(constraints.shifts):

            RULE_working_tags_number(all_shifts, tag_groups, day, shift, kasjer, 3, 3)
            RULE_working_tags_number(all_shifts, tag_groups, day, shift, wozek_widlowy, 1, constraints.max_num_workers)
            RULE_working_tags_number(all_shifts, tag_groups, day, shift, koordynator, 1, 1)
            RULE_working_tags_number(all_shifts, tag_groups, day, shift, kierownik, 1, 1)

            worker_assigned = []
            for worker in workers:
                assigned_vars = [
                    all_shifts[(worker, day, shift, role)]
                    for role in worker.tags
                ]

                is_assigned = model.NewBoolVar(f"{worker}_{day}_{shift}_assigned")
                model.AddMaxEquality(is_assigned, assigned_vars)
                worker_assigned.append(is_assigned)

            model.Add(sum(worker_assigned) >= 6)
            model.Add(sum(worker_assigned) <= 7)

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

    ### Solver ###
    class ShiftPrinter(cp_model.CpSolverSolutionCallback):
        def __init__(self, all_shifts, workers, constraints):
            cp_model.CpSolverSolutionCallback.__init__(self)
            self._all_shifts = all_shifts
            self._workers = workers
            self._days = constraints.days
            self._shifts = constraints.shifts
            self._solution_count = 0

        def on_solution_callback(self):
            print(f"\nSolution {self._solution_count + 1}:\n")
            for day in range(self._days):
                print(f"Day {day + 1}")
                for shift in range(self._shifts):
                    print(f"  Shift {shift + 1}:")
                    for worker in self._workers:
                        for role in worker.tags:
                            var = self._all_shifts.get((worker, day, shift, role))
                            if self.BooleanValue(var):
                                print(f"    {worker.firstname} {worker.lastname} as {role.name}")
                print()
            self._solution_count += 1

    solver = cp_model.CpSolver()
    printer = ShiftPrinter(all_shifts, workers, constraints)

    status = solver.Solve(model, printer)

    if status == cp_model.OPTIMAL or status == cp_model.FEASIBLE:
        print("\nFinal Solution:")
        printer.on_solution_callback()
    else:
        print("No solution found.")

if __name__ == "__main__":
    model = cp_model.CpModel()
    constraints = Constraints()
    main()
