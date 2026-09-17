import sys
from pathlib import Path

import pytest


sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "assets"))
import app as demo_app


@pytest.fixture
def client():
    return demo_app.app.test_client()


@pytest.mark.parametrize("slot", ["BLUE", "GREEN"])
def test_home_page_shows_slot_and_version(client, monkeypatch, slot):
    monkeypatch.setenv("SLOT", slot)
    monkeypatch.setattr(demo_app, "VERSION", "test-version")
    monkeypatch.setattr(demo_app, "BROKEN", False)
    response = client.get("/")

    assert response.status_code == 200
    assert b"Version: test-version" in response.data
    assert f'class="slot-{slot.lower()}"'.encode() in response.data
    assert f'class="slot">{slot}</p>'.encode() in response.data


@pytest.mark.parametrize("broken, expected_status", [(False, 200), (True, 500)])
def test_health_reflects_release_state(client, monkeypatch, broken, expected_status):
    monkeypatch.setattr(demo_app, "BROKEN", broken)
    assert client.get("/health").status_code == expected_status


def test_broken_release_fails_home_page(client, monkeypatch):
    monkeypatch.setattr(demo_app, "BROKEN", True)
    assert client.get("/").status_code == 500
