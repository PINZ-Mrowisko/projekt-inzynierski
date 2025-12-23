import unittest
from unittest.mock import MagicMock

from ..models.Worker import Worker
from ..models.Tags import Tags
from ..models.Template import Template
from ..models.Shift import Shift
from ..models.Rule import Rule

class TestWorker(unittest.TestCase):

    def test_working_hours(self):
        person1 = Worker("adam", "kowalski", "M", 21, "umowa o prace", 606547766, "ellele@wp.pl", 1)
        person2 = Worker("adam", "kowalski", "M", 21, "umowa zlecenie", 606547766, "ellele@wp.pl", 2)
        person3 = Worker("adam", "kowalski", "M", 21, "umowa zlecenie", 606547766, "ellele@wp.pl", 3, 20)

        self.assertEqual(person1.get_max_working_hours(), 40)
        self.assertIsNone(person2.get_max_working_hours())
        self.assertEqual(person3.get_max_working_hours(), 20)

    def test_worker_tags(self):
        person1 = Worker("adam", "kowalski", "M", 21, "umowa o prace", 606547766, "ellele@wp.pl", 4)
        tag1 = Tags(1,"kierownik", "osoba zarządzająca")
        tag2 = Tags(2,"wozek", "osoba z uprawnieniami na wozek")

        person1.add_tag(tag1)
        person1.add_tag(tag2)

        self.assertEqual(person1.tags, [tag1, tag2])

class TestTemplate(unittest.TestCase):

    def test_template_correct(self):

        shift1 = MagicMock()
        shift1.day = "Poniedziałek"
        shifts = [shift1]


        template = Template(1, 'dobry', 0, 1, 0, 1, shifts)

        self.assertEqual(template.__str__(),"Template(id=1, description=dobry, maxMen=0, maxWomen=1, minMen=0, minWomen=1, shifts=1, days=7, shifts_number={'Poniedziałek': 1})")

    def test_template_incorrect_no_shifts(self):

        shifts = []
        template = Template(1, 'niedobry', 0, 1, 0, 1, shifts)
        self.assertEqual(template.__str__(), "Template(id=1, description=niedobry, maxMen=0, maxWomen=1, minMen=0, minWomen=1, shifts=0, days=7, shifts_number={})")

class TestShift(unittest.TestCase):

    def test_shift_correct(self):

        rule1 = MagicMock()
        rule2 = MagicMock()

        rules = [rule1, rule2]

        shift = Shift(1, "Poniedziałek", (10,0), (18,10), rules)

        self.assertEqual(shift.duration, 8 * 60 + 10)
        self.assertEqual(shift.type, 1)
        self.assertTrue(shift.attach_default_rules)
        self.assertEqual(shift.__str__(), 'Shift(id=1, day=Poniedziałek, start=(10, 0), end=(18, 10), rules=2, type=1)')


        rules = []

        shift2 = Shift(2, "Poniedziałek", (12,0), (20,10), rules)

        self.assertEqual(shift2.determine_type(), 2)
        self.assertFalse(shift2.attach_default_rules)

        shift3 = Shift(3, "Poniedziałek", (6,0), (23,50), rules) # kto byłby tak okrutny??

        self.assertEqual(shift3.determine_type(), 0)

class TestRule(unittest.TestCase):

    def test_rule_single_tag(self):

        tag1 = MagicMock()
        tag1.id = '123'

        tags = tag1.id

        rule = Rule(tags, 1)

        self.assertEqual(rule.type, "single_tag")
        self.assertEqual(rule.__str__(), "Rule(tags=['123'], count=1, type=single_tag)")

    def test_rule_multi_tag(self):

        tag1 = MagicMock()
        tag1.id = '123'
        tag2 = MagicMock()
        tag2.id = '456'

        tags = tag1.id + ', ' + tag2.id

        rule = Rule(tags, 1)
        self.assertEqual(rule.type, "multiple_tags")
        self.assertEqual(rule.__str__(), "Rule(tags=['123', '456'], count=1, type=multiple_tags)")


