import unittest
from unittest.mock import MagicMock, patch

from ..connection.database_queries import *
class TestDatabaseQueries(unittest.TestCase):

    def setUp(self):

        self.mock_db = MagicMock()
        self.user_id = '1'

        tag1 = MagicMock()
        tag2 = MagicMock()

        self.tags_list = [tag1, tag2]

    @patch('backend.connection.database_queries.FieldFilter')
    @patch('backend.connection.database_queries.map_worker')
    def test_get_workers(self, mock_map_worker, mock_map_field_filter):

        mock_market_doc = MagicMock()
        mock_market_doc.id = "market_123"

        (self.mock_db.collection.return_value
         .where.return_value
         .limit.return_value
         .get.return_value) = [mock_market_doc]

        mock_member_doc1 = MagicMock()
        mock_member_doc1.to_dict.return_value = {"name": "John"}

        mock_member_doc2 = MagicMock()
        mock_member_doc2.to_dict.return_value = {"name": "Jane"}

        (self.mock_db.collection.return_value
         .document.return_value
         .collection.return_value
         .get.return_value) = [mock_member_doc1, mock_member_doc2]

        member1 = MagicMock()
        member1.id = "2"
        member1.firstName = "John"

        member2 = MagicMock()
        member2.id = "3"
        member2.firstName = "Jane"

        mock_map_worker.side_effect = [member1, member2]

        workers = get_workers(self.user_id, self.tags_list, self.mock_db)

        self.assertEqual(workers, [member1, member2])

    @patch('backend.connection.database_queries.FieldFilter')
    @patch('backend.connection.database_queries.map_worker')
    def test_get_workers_no_workers(self, mock_map_worker, mock_map_field_filter):

        mock_market_doc = MagicMock()
        mock_market_doc.id = "market_123"

        (self.mock_db.collection.return_value
         .where.return_value
         .limit.return_value
         .get.return_value) = [mock_market_doc]

        (self.mock_db.collection.return_value
         .document.return_value
         .collection.return_value
         .get.return_value) = []

        mock_map_worker.side_effect = []

        workers = get_workers(self.user_id, self.tags_list, self.mock_db)

        self.assertEqual(workers, [])

    @patch('builtins.print')
    @patch('backend.connection.database_queries.FieldFilter')
    @patch('backend.connection.database_queries.map_worker')
    def test_get_workers_no_market(self, mock_map_worker, mock_map_field_filter, mock_print):

        (self.mock_db.collection.return_value
         .where.return_value
         .limit.return_value
         .get.return_value) = None

        mock_member_doc1 = MagicMock()
        mock_member_doc1.to_dict.return_value = {"name": "John"}

        mock_member_doc2 = MagicMock()
        mock_member_doc2.to_dict.return_value = {"name": "Jane"}

        (self.mock_db.collection.return_value
         .document.return_value
         .collection.return_value
         .get.return_value) = [mock_member_doc1, mock_member_doc2]

        member1 = MagicMock()
        member1.id = "2"
        member1.firstName = "John"

        member2 = MagicMock()
        member2.id = "3"
        member2.firstName = "Jane"

        mock_map_worker.side_effect = [member1, member2]

        workers = get_workers(self.user_id, self.tags_list, self.mock_db)

        self.assertEqual(workers, [])

    @patch('backend.connection.database_queries.FieldFilter')
    @patch('backend.connection.database_queries.map_tag')
    def test_get_tags(self, mock_map_tag, mock_map_field_filter):

        mock_market_doc = MagicMock()
        mock_market_doc.id = "market_123"

        (self.mock_db.collection.return_value
         .where.return_value
         .limit.return_value
         .get.return_value) = [mock_market_doc]

        tag1 = MagicMock()
        tag1.id = "123"

        tag2 = MagicMock()
        tag2.id = "456"

        (self.mock_db.collection.return_value
         .document.return_value
         .collection.return_value
         .get.return_value) = [tag1, tag2]

        mock_map_tag.side_effect = [tag1, tag2]

        tags = get_tags(self.user_id, self.mock_db)

        self.assertEqual(tags, [tag1, tag2])

    @patch('builtins.print')
    @patch('backend.connection.database_queries.FieldFilter')
    @patch('backend.connection.database_queries.map_tag')
    def test_get_tags_no_market(self, mock_map_tag, mock_map_field_filter, mock_print):

        (self.mock_db.collection.return_value
         .where.return_value
         .limit.return_value
         .get.return_value) = None

        tag1 = MagicMock()
        tag1.id = "123"

        tag2 = MagicMock()
        tag2.id = "456"

        (self.mock_db.collection.return_value
         .document.return_value
         .collection.return_value
         .get.return_value) = [tag1, tag2]

        mock_map_tag.side_effect = [tag1, tag2]

        tags = get_tags(self.user_id, self.mock_db)

        self.assertEqual(tags, [])

    @patch('backend.connection.database_queries.FieldFilter')
    @patch('backend.connection.database_queries.map_tag')
    def test_get_tags_no_tags(self, mock_map_tag, mock_map_field_filter):

        mock_market_doc = MagicMock()
        mock_market_doc.id = "market_123"

        (self.mock_db.collection.return_value
         .where.return_value
         .limit.return_value
         .get.return_value) = [mock_market_doc]


        (self.mock_db.collection.return_value
         .document.return_value
         .collection.return_value
         .get.return_value) = []

        mock_map_tag.side_effect = []

        tags = get_tags(self.user_id, self.mock_db)

        self.assertEqual(tags, [])

    @patch('backend.connection.database_queries.FieldFilter')
    @patch('backend.connection.database_queries.map_template')
    def test_get_templates(self, mock_map_template, mock_map_field_filter):
        mock_market_doc = MagicMock()
        mock_market_doc.id = "market_123"

        (self.mock_db.collection.return_value
         .where.return_value
         .limit.return_value
         .get.return_value) = [mock_market_doc]

        template1 = MagicMock()
        template1.id = "template1"

        template2 = MagicMock()
        template2.id = "template2"

        (self.mock_db.collection.return_value
         .document.return_value
         .collection.return_value
         .get.return_value) = [template1, template2]


        mock_map_template.side_effect = [template1, template2]

        templates = get_templates(self.user_id, self.mock_db)

        self.assertEqual(templates, [template1, template2])

    @patch('builtins.print')
    @patch('backend.connection.database_queries.FieldFilter')
    @patch('backend.connection.database_queries.map_template')
    def test_get_templates_no_market(self, mock_map_template, mock_map_field_filter, mock_print):

        (self.mock_db.collection.return_value
         .where.return_value
         .limit.return_value
         .get.return_value) = []

        template1 = MagicMock()
        template1.id = "template1"

        template2 = MagicMock()
        template2.id = "template2"

        (self.mock_db.collection.return_value
         .document.return_value
         .collection.return_value
         .get.return_value) = [template1, template2]

        mock_map_template.side_effect = [template1, template2]

        templates = get_templates(self.user_id, self.mock_db)

        self.assertEqual(templates, [])

    def test_get_next_month_year(self):

        now = MagicMock()
        now.year = 2025
        now.month = 9

        next_year, next_month = get_next_month_year(now)

        self.assertEqual(next_year, 2025)
        self.assertEqual(next_month, 10)

    def test_get_next_month_year_change_year(self):

        now = MagicMock()
        now.year = 2025
        now.month = 12

        next_year, next_month = get_next_month_year(now)

        self.assertEqual(next_year, 2026)
        self.assertEqual(next_month, 1)

    def test_is_on_leave(self):

        worker = MagicMock()
        worker.id = "123"

        leave_req1 = MagicMock()
        leave_req1.employee_id = "123"
        leave_req1.status = "zaakceptowany"
        leave_req1.start_date = "2005-01-02"
        leave_req1.end_date = "2005-01-15"

        leave_req2 = MagicMock()
        leave_req2.employee_id = "123"
        leave_req2.status = "Mój urlop"
        leave_req2.start_date = "2005-01-15"
        leave_req2.end_date = "2005-01-16"

        leave_req3 = MagicMock()
        leave_req3.employee_id = "123"
        leave_req3.status = "odrzucony"
        leave_req3.start_date = "2005-01-16"
        leave_req3.end_date = "2005-01-20"

        mock_leaves_req = [leave_req1, leave_req2, leave_req3]

        check_date_str1 = "2005-01-10"
        check_date_str2 = "2005-01-20"

        res1 = is_on_leave(worker.id, check_date_str1, mock_leaves_req)
        res2 = is_on_leave(worker.id, check_date_str2, mock_leaves_req)

        self.assertEqual(res1, True)
        self.assertEqual(res2, False)

        #second scenario

        mock_leaves_req = []
        res3 = is_on_leave(worker.id, check_date_str1, mock_leaves_req)

        self.assertEqual(res3, False)

    @patch('backend.connection.database_queries.FieldFilter')
    @patch('backend.connection.database_queries.map_leave_request')
    def test_get_leaves_requests(self, mock_map_leave_request, mock_map_field_filter):

        mock_market_doc = MagicMock()
        mock_market_doc.id = "market_123"

        (self.mock_db.collection.return_value
         .where.return_value
         .limit.return_value
         .get.return_value) = [mock_market_doc]

        leave_req1 = MagicMock()
        leave_req1.to_dict.return_value = {}

        leave_req2 = MagicMock()
        leave_req2.to_dict.return_value = {}

        leave_req3 = MagicMock()
        leave_req3.to_dict.return_value = {}

        (self.mock_db.collection.return_value
         .document.return_value
         .collection.return_value
         .get.return_value) = [leave_req1, leave_req2, leave_req3]

        mock_map_leave_request.side_effect = [leave_req1, None,leave_req3]

        leaves = get_leave_requests(self.user_id, self.mock_db)

        self.assertEqual(leaves, [leave_req1, leave_req3])

    @patch('builtins.print')
    @patch('backend.connection.database_queries.FieldFilter')
    @patch('backend.connection.database_queries.map_leave_request')
    def test_get_leaves_requests_no_market(self, mock_map_leave_request, mock_map_field_filter, mock_print):


        (self.mock_db.collection.return_value
         .where.return_value
         .limit.return_value
         .get.return_value) = []

        leave_req1 = MagicMock()
        leave_req1.to_dict.return_value = {}

        leave_req2 = MagicMock()
        leave_req2.to_dict.return_value = {}

        leave_req3 = MagicMock()
        leave_req3.to_dict.return_value = {}

        (self.mock_db.collection.return_value
         .document.return_value
         .collection.return_value
         .get.return_value) = [leave_req1, leave_req2, leave_req3]

        mock_map_leave_request.side_effect = [leave_req1, None, leave_req3]

        leaves = get_leave_requests(self.user_id, self.mock_db)

        self.assertEqual(leaves, [])





