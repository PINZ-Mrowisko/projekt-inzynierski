import unittest
from unittest.mock import MagicMock, patch

from ..connection.mapping import *
from ..models.Tags import Tags
from ..models.Worker import Worker
from ..models.Shift import Shift
from ..models.Template import Template

class TestMapping(unittest.TestCase):

    def test_map_tag(self):

        tag_data = {
            "name": "kasjer",
            "description": "zna kod na kajzerke",
            "id": 1,
            "isDeleted": False
        }

        tag = map_tag(tag_data)

        self.assertIsInstance(tag, Tags)

    def test_map_tag_deleted(self):

        tag_data = {
            "name": "kasjer",
            "description": "zna kod na kajzerke",
            "id": 1,
            "isDeleted": True
        }

        tag = map_tag(tag_data)

        self.assertIsNone(tag)

    def test_work_time_preference_mapping(self):

        preference1 = "Poranne"
        preference2 = "Popołudniowe"
        preference3 = "Brak preferencji"
        preference4 = True
        preference5 = None

        self.assertEqual(work_time_preference_mapping(preference1), 1)
        self.assertEqual(work_time_preference_mapping(preference2), 2)
        self.assertEqual(work_time_preference_mapping(preference3), 0)
        self.assertEqual(work_time_preference_mapping(preference4), 0)
        self.assertEqual(work_time_preference_mapping(preference5), 0)

    def test_map_worker(self):

        tag1 = MagicMock()
        tag1.name = "kasjer"
        tag2 = MagicMock()
        tag2.name = "logistyk"

        tags = [tag1, tag2]

        worker_data = {
            "firstname": "pan",
            "lastname": "maruda",
            "sex": "Mężczyzna",
            "age": 18,
            "type_of_deal": "Umowa zlecenie",
            "phone_number": "+1 555 555 555",
            "email": "email@wp.pl",
            "work_time_preference": "Poranne",
            "id": 1,
            "max_working_hours": 20,
            "tags_doc": [tag1]
        }

        worker = map_worker(worker_data, tags)

        self.assertIsInstance(worker, Worker)

    def test_map_worker_no_tags(self):

        tag1 = MagicMock()
        tag1.name = "kasjer"
        tag2 = MagicMock()
        tag2.name = "logistyk"

        tags = [tag1, tag2]

        worker_data = {
            "firstname": "pan",
            "lastname": "maruda",
            "sex": "Mężczyzna",
            "age": 18,
            "type_of_deal": "Umowa zlecenie",
            "phone_number": "+1 555 555 555",
            "email": "email@wp.pl",
            "work_time_preference": "Poranne",
            "id": 1,
            "max_working_hours": 20,
            "tags_doc": []
        }

        worker = map_worker(worker_data, tags)

        self.assertIsInstance(worker, Worker)

    def test_map_worker_deleted(self):

        tag1 = MagicMock()
        tag1.name = "kasjer"
        tag2 = MagicMock()
        tag2.name = "logistyk"

        tags = [tag1, tag2]

        worker_data = {
            "firstname": "pan",
            "lastname": "maruda",
            "sex": "Mężczyzna",
            "age": 18,
            "type_of_deal": "Umowa zlecenie",
            "phone_number": "+1 555 555 555",
            "email": "email@wp.pl",
            "work_time_preference": "Poranne",
            "id": 1,
            "max_working_hours": 20,
            "tags_doc": [tag1],
            "isDeleted": True
        }

        worker = map_worker(worker_data, tags)

        self.assertIsNone(worker)

    def test_normalize_hour(self):

        hour_string1 = "16:34"
        hour_string2 = "9:12"
        hour_string3 = "10"

        self.assertEqual(normalize_hour(hour_string1), (16,34))
        self.assertEqual(normalize_hour(hour_string2), (9,12))
        self.assertEqual(normalize_hour(hour_string3), (10,0))

    @patch('builtins.print')
    def test_normalize_hour_no_hour(self, mock_print):

        hour_string1 = "Unknown"
        normalize_hour(hour_string1)

        self.assertEqual(normalize_hour(hour_string1), "Unknown")

    def test_map_shift(self):

        shift_id = 4

        shift_data = {
            "day": "Poniedziałek",
            "start": "10:00",
            "end": "14:00",
            "requirements": [
                {
                    "tagId": '1',
                    "count": 3,
                    "obeyGeneralRules": True,
                }
            ]
        }

        shift = map_shift(shift_data, shift_id)

        self.assertIsInstance(shift, Shift)

    def test_map_shift_no_requirements(self):

        shift_id = 4

        shift_data = {
            "day": "Poniedziałek",
            "start": "10:00",
            "end": "14:00",
            "requirements": []
        }

        shift = map_shift(shift_data, shift_id)

        self.assertIsInstance(shift, Shift)

    def test_map_shift_wrong(self):

        shift_id = 4

        shift_data = None
        shift_data2 = {}

        shift = map_shift(shift_data, shift_id)
        shift2 = map_shift(shift_data2, shift_id)

        self.assertIsNone(shift)
        self.assertIsNone(shift2)

    @patch('backend.connection.mapping.map_shift')
    def test_map_template(self, mock_map_shift):


        template_data = {
            "id": 1,
            "description": "moj",
            "maxMen": 3,
            "maxWoman": 3,
            "minMen": 1,
            "minWoman": 1,
            "shifts_map": {}
        }

        shift = MagicMock()
        mock_map_shift.return_value = shift

        template = map_template(template_data)
        self.assertIsInstance(template, Template)

    @patch('backend.connection.mapping.map_shift')
    def test_map_template_wrong_or_missing(self, mock_map_shift):

        template_data = {
            "id": 1,
            "description": "moj",
            "maxMen": 3,
            "maxWoman": 3,
            "minMen": 1,
            "minWoman": 1,
            "shifts_map": {},
            "isDeleted": True
        }

        shift = MagicMock()
        mock_map_shift.return_value = shift

        template = map_template(template_data)
        self.assertEqual(template, None)

        template_data = {
            "id": 1,
            "description": "moj",
            "maxMen": 3,
            "maxWoman": 3,
            "minMen": 1,
            "minWoman": 1,
            "shifts_map": {},
            "isDataMissing": True
        }

        template = map_template(template_data)
        self.assertEqual(template, None)

