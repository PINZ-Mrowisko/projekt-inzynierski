from ortools.sat.python import cp_model


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