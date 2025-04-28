import unittest
from ..models.Worker import Worker

class TestWorker(unittest.TestCase):

    def test_working_hours(self):
        person1 = Worker("adam", "kowalski", 21, "umowa o prace", 606547766, "ellele@wp.pl")
        person2 = Worker("adam", "kowalski", 21, "umowa zlecenie", 606547766, "ellele@wp.pl")
        person3 = Worker("adam", "kowalski", 21, "umowa zlecenie", 606547766, "ellele@wp.pl", 20)

        assert person1.get_max_working_hours() == 40
        assert person2.get_max_working_hours() == None
        assert person3.get_max_working_hours() == 20