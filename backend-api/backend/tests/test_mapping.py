import unittest
from unittest.mock import MagicMock, patch

from ..connection.mapping import *
from ..models.Tags import Tags
from ..models.Worker import Worker
from ..models.Shift import Shift
from ..models.Template import Template
from ..models.LeaveReq import LeaveReq

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

    def test_hour_to_string(self):

        hour_tuple = (16,10)
        hour_tuple2 = (9,12)
        hour_tuple3 = (10,0)

        result = hour_to_string(hour_tuple)
        result2 = hour_to_string(hour_tuple2)
        result3 = hour_to_string(hour_tuple3)

        self.assertEqual(result, "16:10")
        self.assertEqual(result2, "09:12")
        self.assertEqual(result3, "10:00")

    def setUp(self):
        self.worker = MagicMock()
        self.worker.id = 101
        self.worker.firstname = "Jan"
        self.worker.lastname = "Kowalski"

        self.rule = MagicMock()
        self.rule.tags = ["tag1", "tag2"]

        self.shift = MagicMock()
        self.shift.id = "shift_1"
        self.shift.day = "Monday"
        self.shift.start = "08:00"
        self.shift.end = "16:00"
        self.shift.duration = 480
        self.shift.rules = [self.rule]

        self.template = MagicMock()
        self.template.shifts = [self.shift]

        self.solver = MagicMock()

    @patch('backend.connection.mapping.hour_to_string')
    def test_worker_assigned_success(self, mock_hour_to_string):

        mock_hour_to_string.side_effect = lambda x: f"{x}"

        mock_var = MagicMock()

        key = (101, "shift_1", 0)
        all_variables = {key: mock_var}

        self.solver.Value.return_value = 1

        result = map_result_to_json(self.solver, all_variables, [self.worker], self.template)

        self.assertIn("shift_1", result)
        entry = result["shift_1"]

        self.assertEqual(entry["start"], "08:00")
        self.assertEqual(entry["duration"], 8.0)  # 480 / 60

        self.assertEqual(len(entry["assignments"]), 1)
        assignment = entry["assignments"][0]

        self.assertEqual(assignment["workerId"], 101)
        self.assertEqual(assignment["firstName"], "Jan")
        self.assertEqual(assignment["tags"], ["tag1", "tag2"])

        self.solver.Value.assert_called_with(mock_var)

    @patch('backend.connection.mapping.hour_to_string')
    def test_worker_not_assigned(self, mock_hour_to_string):
        mock_hour_to_string.return_value = "00:00"

        mock_var = MagicMock()
        key = (101, "shift_1", 0)
        all_variables = {key: mock_var}

        self.solver.Value.return_value = 0

        result = map_result_to_json(self.solver, all_variables, [self.worker], self.template)

        self.assertEqual(len(result["shift_1"]["assignments"]), 0)

    @patch('backend.connection.mapping.hour_to_string')
    def test_variable_missing_in_map(self, mock_hour_to_string):
        mock_hour_to_string.return_value = "00:00"

        all_variables = {}

        result = map_result_to_json(self.solver, all_variables, [self.worker], self.template)

        self.assertEqual(len(result["shift_1"]["assignments"]), 0)

    @patch('backend.connection.mapping.hour_to_string')
    def test_multiple_workers_one_shift(self, mock_hour_to_string):
        mock_hour_to_string.return_value = "10:00"

        worker2 = MagicMock()
        worker2.id = 102
        worker2.firstname = "Adam"
        worker2.lastname = "Nowak"

        workers = [self.worker, worker2]

        var1 = MagicMock()
        var2 = MagicMock()

        all_variables = {
            (101, "shift_1", 0): var1,
            (102, "shift_1", 0): var2
        }

        self.solver.Value.return_value = 1

        result = map_result_to_json(self.solver, all_variables, workers, self.template)

        assignments = result["shift_1"]["assignments"]
        self.assertEqual(len(assignments), 2)

        ids = [a["workerId"] for a in assignments]
        self.assertIn(101, ids)
        self.assertIn(102, ids)

    def test_normalize_iso_date(self):

        iso_date = "2005-01-02T03:01:45+01:00"
        iso_date2 = "2005-01-02"

        res1 = normalize_iso_date(iso_date)
        res2 = normalize_iso_date(iso_date2)

        self.assertEqual(res1, "2005-01-02")
        self.assertEqual(res1, res2)

    @patch('builtins.print')
    def test_normalize_iso_date_wrong(self, mock_print):

        iso_date_fail = 2005
        res = normalize_iso_date(iso_date_fail)

        self.assertEqual(res, 2005)

    @patch('backend.connection.mapping.normalize_iso_date')
    def test_map_leave_request(self, mock_normalize_iso_date):

        mock_normalize_iso_date.side_effect = ["2005-01-02", "2005-01-15"]

        leave_data = {
            "id": 1,
            "userId": 123,
            "startDate": "2005-01-02T03:01:45+01:00",
            "endDate": "2005-01-15T03:01:45+01:00",
            "status": "zaakceptowany"
        }

        leave_result = map_leave_request(leave_data)
        leave_result_dict = leave_result.convert_to_dict()

        self.assertEqual(leave_result_dict["leave_id"], 1)
        self.assertEqual(leave_result_dict["employee_id"], 123)
        self.assertEqual(leave_result_dict["start_date"], "2005-01-02")
        self.assertEqual(leave_result_dict["end_date"], "2005-01-15")
        self.assertEqual(leave_result_dict["status"], "zaakceptowany")

