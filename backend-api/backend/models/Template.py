class Template:

    def __init__(self, id, description, maxMen, maxWomen, minMen, minWomen, shifts):

        self.id = id
        self.description = description
        self.maxMen = maxMen
        self.maxWomen = maxWomen
        self.minMen = minMen
        self.minWomen = minWomen
        self.shifts = shifts

        # adapting from constraints

        self.days = 7  # assuming a week schedule
        self.shifts_number = {}

        for shift in shifts:
            day = shift.day
            if day not in self.shifts_number:
                self.shifts_number[day] = 0
            self.shifts_number[day] += 1

    def __str__(self):
        return f"Template(id={self.id}, description={self.description}, maxMen={self.maxMen}, maxWomen={self.maxWomen}, minMen={self.minMen}, minWomen={self.minWomen}, shifts={len(self.shifts)}, days={self.days}, shifts_number={self.shifts_number})"