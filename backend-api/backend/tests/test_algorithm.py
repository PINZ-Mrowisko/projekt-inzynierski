import unittest
from unittest.mock import MagicMock, patch
from ortools.sat.python import cp_model

from ..algorithm.algorithm import main, generate_all_variables

class MockTag:
    def __init__(self, tag_id):
        self.id = tag_id

class MockRule:
    def __init__(self, tags, count=1, attach_default=True):
        self.tags = tags
        self.count = count
        self.attach_default_rules = attach_default

class MockShift:
    def __init__(self, shift_id, day, start, end, rules, duration=480, type_="Poranne"):
        self.id = shift_id
        self.day = day
        self.start = start
        self.end = end
        self.rules = rules
        self.duration = duration
        self.type = type_
        self.attach_default_rules = True

class MockWorker:
    def __init__(self, w_id, name, sex, tags, max_hours=160, pref="Poranne"):
        self.id = w_id
        self.firstname = name
        self.sex = sex
        self.tags = [MockTag(t) for t in tags]
        self.max_working_hours = max_hours
        self.work_time_preference = pref

class MockTemplate:
    def __init__(self, shifts, min_m=0, min_w=0, max_m=10, max_w=10):
        self.shifts = shifts
        self.minMen = min_m
        self.minWomen = min_w
        self.maxMen = max_m
        self.maxWomen = max_w

        shift1 = MagicMock()
        shift1.rules = []


class TestSchedulerAlgorithm(unittest.TestCase):

    def setUp(self):
        self.model = cp_model.CpModel()

    def test_generate_vars_matching_tags(self):

        rule = MockRule(tags=["T1"])
        shift = MockShift("s1", "Mon", 480, 960, [rule])
        worker = MockWorker(1, "Jan", "Mężczyzna", tags=["T1"])

        vars_dict = generate_all_variables(self.model, [shift], [worker])

        key = (1, "s1", 0)
        self.assertIn(key, vars_dict)

    def test_generate_vars_missing_tags(self):

        rule = MockRule(tags=["WymaganyTag"])
        shift = MockShift("s1", "Mon", 480, 960, [rule])
        worker = MockWorker(1, "Jan", "Mężczyzna", tags=["InnyTag"])

        vars_dict = generate_all_variables(self.model, [shift], [worker])

        self.assertEqual(len(vars_dict), 0)

    def test_generate_vars_worker_no_tags_logic(self):

        rule = MockRule(tags=["T1"])
        shift = MockShift("s1", "Mon", 480, 960, [rule])
        worker = MockWorker(1, "Jan", "Mężczyzna", tags=[])  # Pusta lista tagów

        vars_dict = generate_all_variables(self.model, [shift], [worker])

        key = (1, "s1", 0)
        self.assertIn(key, vars_dict)

    @patch('builtins.print')
    def test_main_basic_assignment(self, mock_print):

        rule = MockRule(tags=[], count=1)
        shift = MockShift("s1", "Mon", 480, 960, [rule], duration=480)  # 8h
        worker = MockWorker(1, "Jan", "Mężczyzna", tags=[], max_hours=10)

        template = MockTemplate([shift])

        solver, vars_dict = main([worker], template)

        self.assertIsNotNone(vars_dict, "Nie znaleziono rozwiązania")

        key = (1, "s1", 0)
        self.assertEqual(solver.Value(vars_dict[key]), 1)

    @patch('builtins.print')
    def test_max_hours_constraint(self, mock_print):

        rule = MockRule(tags=[], count=1)
        shift = MockShift("s1", "Mon", 480, 960, [rule], duration=480)  # 480 min = 8h

        worker = MockWorker(1, "Jan", "Mężczyzna", tags=[], max_hours=1)

        template = MockTemplate([shift])

        result, vars_dict = main([worker], template)

        if isinstance(result, dict):
            self.assertEqual(result["status"], "No solution found.")
        else:
            self.assertIsNone(vars_dict)

    @patch('builtins.print')
    def test_gender_constraint(self, mock_print):

        rule = MockRule(tags=[], count=2)
        shift = MockShift("s1", "Mon", 480, 960, [rule])

        w1 = MockWorker(1, "Adam", "Mężczyzna", tags=[])
        w2 = MockWorker(2, "Bartek", "Mężczyzna", tags=[])

        template = MockTemplate([shift], min_w=2, min_m=0)

        result, vars_dict = main([w1, w2], template)

        self.assertIsNone(vars_dict)

    @patch('builtins.print')
    def test_one_shift_per_day(self, mock_print):

        rule1 = MockRule(tags=[], count=1)
        rule2 = MockRule(tags=[], count=1)

        # Dwie zmiany w poniedziałek
        s1 = MockShift("s1", "Mon", 480, 600, [rule1], duration=120)
        s2 = MockShift("s2", "Mon", 600, 720, [rule2], duration=120)

        # Tylko jeden pracownik
        worker = MockWorker(1, "Jan", "Mężczyzna", tags=[])

        template = MockTemplate([s1, s2])

        result, vars_dict = main([worker], template)

        self.assertIsNone(vars_dict)

    @patch('builtins.print')
    def test_two_workers_two_shifts(self, mock_print):

        r1 = MockRule(tags=[], count=1)
        s1 = MockShift("s1", "Mon", 480, 600, [r1], duration=120)

        r2 = MockRule(tags=[], count=1)
        s2 = MockShift("s2", "Tue", 480, 600, [r2], duration=120)

        w1 = MockWorker(1, "Jan", "Mężczyzna", tags=[])
        w2 = MockWorker(2, "Anna", "Kobieta", tags=[])

        template = MockTemplate([s1, s2])

        solver, vars_dict = main([w1, w2], template)

        self.assertIsNotNone(vars_dict)

        assigned_count = 0
        for val in vars_dict.values():
            if solver.Value(val) == 1:
                assigned_count += 1

        self.assertEqual(assigned_count, 2)