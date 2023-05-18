from fastapi.testclient import TestClient

from dashboard.app import app


client = TestClient(app)


def test_index():
    response = client.get("/")
    assert response.status_code == 200
