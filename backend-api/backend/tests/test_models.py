import unittest
from unittest.mock import MagicMock

from ..models.Worker import Worker
from ..models.Tags import Tags
from ..models.Template import Template

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