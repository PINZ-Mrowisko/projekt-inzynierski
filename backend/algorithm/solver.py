from ortools.sat.python import cp_model


class ShiftPrinter(cp_model.CpSolverSolutionCallback):
    def __init__(self, all_shifts, workers, constraints):
        cp_model.CpSolverSolutionCallback.__init__(self)
        self._all_shifts = all_shifts
        self._workers = workers
        self._days = constraints.days
        self._shifts = constraints.shifts
        self._solution_count = 0
        self._best_solution = None
        self._best_score = -1

    def on_solution_callback(self):
        current_score = 0
        current_solution = []

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
                            if shift + 1 == worker.work_time_preference:
                                current_score += 1
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
            for shift in range(self._shifts):
                print(f"  Shift {shift + 1}:")
                for (d, s, worker, role) in self._best_solution:
                    if d == day and s == shift:
                        print(f"    {worker.firstname} {worker.lastname} as {role.name}")
            print()
