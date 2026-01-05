import unittest
import sys
from unittest.mock import MagicMock, patch

sys.modules["firebase_admin"] = MagicMock()
sys.modules["firebase_admin.firestore"] = MagicMock()
sys.modules["firebase_admin.auth"] = MagicMock()
sys.modules["google.cloud"] = MagicMock()

from fastapi.testclient import TestClient
from api import app


class TestApiSimple(unittest.TestCase):

    def setUp(self):
        self.client = TestClient(app)
        self.headers = {"Authorization": "Bearer mega_super_tajny_token"}

    @patch('api.auth.verify_id_token')
    @patch('api.get_tags')
    @patch('api.get_workers')
    @patch('api.get_leave_requests')
    @patch('api.get_templates')
    @patch('api.main') # algorytm
    @patch('api.map_result_to_json')
    @patch('api.post_schedule')
    def test_run_algorithm_success(self, mock_post, mock_map, mock_algo,
                                   mock_tmpl, mock_leave, mock_workers, mock_tags, mock_auth):

        mock_auth.return_value = {"uid": "user_123"}

        fake_template = MagicMock()
        fake_template.id = "szablon_1"
        mock_tmpl.return_value = [fake_template]

        mock_algo.return_value = ("SolverFake", {"zmienne": 1})

        oczekiwany_wynik = {"status": "Udało się!", "grafik": []}
        mock_map.return_value = oczekiwany_wynik

        response = self.client.get("/run-algorithmv2/szablon_1", headers=self.headers)

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), oczekiwany_wynik)

        mock_post.assert_called_once()

    @patch('api.auth.verify_id_token')
    @patch('api.get_tags')
    @patch('api.get_workers')
    @patch('api.get_leave_requests')
    @patch('api.get_templates')
    @patch('api.main')
    def test_run_algorithm_no_solution(self, mock_algo, mock_tmpl, *args):

        fake_template = MagicMock()
        fake_template.id = "szablon_1"
        mock_tmpl.return_value = [fake_template]

        blad = {"status": "No solution found."}
        mock_algo.return_value = (blad, None)

        response = self.client.get("/run-algorithmv2/szablon_1", headers=self.headers)

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), blad)


if __name__ == '__main__':
    unittest.main()