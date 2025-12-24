class Shift:
    def __init__(self, id, day, start, end, rules):
        self.id = id
        self.day = day
        self.start = start
        self.end = end
        self.duration = (end[0] - start[0]) * 60 + (end[1] - start[1])
        self.rules = rules
        self.type = self.determine_type()
        self.attach_default_rules = self.check_if_at_least_one_rule_attaches_default(rules)

    def determine_type(self):
        if self.start[0] < 12 and self.end[0] < 20:
            return 1 # poranna
        elif 12 <= self.start[0] < 16 and 20 <= self.end[0] < 24:
            return 2 # popołudniowa
        else:
            return 0 # default

    @staticmethod
    def check_if_at_least_one_rule_attaches_default(rules):
        for rule in rules:
            if rule.attach_default_rules:
                return True
        return False

    def __str__(self):
        return f"Shift(id={self.id}, day={self.day}, start={self.start}, end={self.end}, rules={len(self.rules)}, type={self.type})"