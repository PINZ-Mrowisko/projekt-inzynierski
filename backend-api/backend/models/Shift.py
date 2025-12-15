class Shift:
    def __init__(self, id, day, start, end, rules):
        self.id = id
        self.day = day
        self.start = start
        self.end = end
        self.rules = rules
        self.type = self.determine_type()

    def determine_type(self):
        if self.start[0] < 12 and self.end[0] < 20:
            return 1 # poranna
        elif 12 <= self.start[0] < 16 and 20 <= self.end[0] < 24:
            return 2 # popołudniowa
        else:
            return 0 # default

    def __str__(self):
        return f"Shift(id={self.id}, day={self.day}, start={self.start}, end={self.end}, rules={len(self.rules)}, type={self.type})"

# shift = Shift(
#     id="shift1",
#     day="Poniedziałek",
#     start=(8, 0),
#     end=(12, 0),
#     tagId="tag1",
#     count=3
# )
# print(shift)
# print(shift.type)