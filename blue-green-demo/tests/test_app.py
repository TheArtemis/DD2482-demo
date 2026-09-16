import os
import sys
import unittest
from pathlib import Path
from unittest.mock import patch


sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "assets"))
import app as demo_app


class AppTests(unittest.TestCase):
    def setUp(self):
        self.client = demo_app.app.test_client()

    def test_home_page_shows_version_and_slot(self):
        with patch.dict(os.environ, {"SLOT": "BLUE"}), patch.object(
            demo_app, "VERSION", "test-version"
        ):
            response = self.client.get("/")

        self.assertEqual(response.status_code, 200)
        self.assertIn(b"Version: test-version", response.data)
        self.assertIn(b"Slot: BLUE", response.data)

    def test_healthy_release_passes_health_check(self):
        with patch.object(demo_app, "BROKEN", False):
            response = self.client.get("/health")

        self.assertEqual(response.status_code, 200)

    def test_broken_release_fails_health_check(self):
        with patch.object(demo_app, "BROKEN", True):
            response = self.client.get("/health")

        self.assertEqual(response.status_code, 500)


if __name__ == "__main__":
    unittest.main()
