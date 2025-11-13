from ortools.sat.python import cp_model

days_dict = {
        0: "Poniedziałek",
        1: "Wtorek",
        2: "Środa",
        3: "Czwartek",
        4: "Piątek",
        5: "Sobota",
        6: "Niedziela"
    }


class ShiftPrinter(cp_model.CpSolverSolutionCallback):
    def __init__(self, all_shifts, workers, template):
        cp_model.CpSolverSolutionCallback.__init__(self)
        self._all_shifts = all_shifts
        self._workers = workers
        self._days = template.days
        self._shifts = template.shifts_number
        self._shift_objects = template.shifts
        self._solution_count = 0
        self._best_solution = None
        self._best_score = -1

    def on_solution_callback(self):
        current_score = 0
        current_solution = []

        #print(f"\nSolution {self._solution_count + 1}:\n")
        for day in range(self._days):
            #print(f"Day {day + 1}")

            day_name = days_dict[day]
            shifts_that_day = self._shifts.get(day_name, 0)
            shifts_objects_that_day = [s for s in self._shift_objects if s.day == day_name]

            for shift in range(shifts_that_day):
                current_shift = shifts_objects_that_day[shift]
                #print(f"  Shift {shift + 1}:")
                for worker in self._workers:
                    for role in worker.tags:
                        var = self._all_shifts.get((worker, day, shift, role))
                        if self.BooleanValue(var):
                            #print(f"    {worker.firstname} {worker.lastname} as {role.name}")
                            if current_shift.type == worker.work_time_preference:
                                current_score += 1
                                #print(f"        {worker.firstname} {worker.work_time_preference} matches shift type {current_shift.type}")
                            current_solution.append((day, shift, worker, role))

        if current_score > self._best_score:
            self._best_score = current_score
            self._best_solution = current_solution

        self._solution_count += 1

    def print_best_solution(self):
        print(f"\nBest solution with {self._best_score} preference matches:\n")
        if not self._best_solution:
            print("No solution found.")
            return

        for day in range(self._days):
            print(f"Day {day + 1}")

            day_name = days_dict[day]
            shifts_that_day = self._shifts.get(day_name, 0)

            for shift in range(shifts_that_day):
                print(f"  Shift {shift + 1}:")
                for (d, s, worker, role) in self._best_solution:
                    if d == day and s == shift:
                        print(f"    {worker.firstname} {worker.lastname} as {role.name}")
            print()

    def results_json(self):
        if not self._best_solution:
            return {"error": "No solution found"}

        results = []

        # Grupujemy dane: (day, shift) => list of workers
        shift_map = {}
        for day, shift, worker, role in self._best_solution:
            key = (day, shift)
            if key not in shift_map:
                shift_map[key] = []
            shift_map[key].append({
                "firstname": worker.firstname,
                "lastname": worker.lastname,
                "role": role.name
            })

        # Budujemy finalny wynik
        for day in range(self._days):
            day_entry = {
                "day": day + 1,
                "shifts": []
            }

            day_name = days_dict[day]
            shifts_that_day = self._shifts.get(day_name, 0)

            for shift in range(shifts_that_day):
                assigned_workers = shift_map.get((day, shift), [])

                day_entry["shifts"].append({
                    "shift": shift + 1,
                    "workers": assigned_workers
                })

            results.append(day_entry)

        return results

    @property
    def solution_count(self):
        return self._solution_count



