import os
import sys

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "app")))

from app import create_app


def test_health_endpoint(tmp_path):
    app = create_app({"TESTING": True, "SQLITE_PATH": str(tmp_path / "appointments.db")})

    response = app.test_client().get("/health")

    assert response.status_code == 200
    assert response.get_json()["status"] == "ok"


def test_create_appointment(tmp_path):
    app = create_app({"TESTING": True, "SQLITE_PATH": str(tmp_path / "appointments.db")})
    client = app.test_client()

    response = client.post(
        "/appointments",
        data={
            "patient_name": "Ada Johnson",
            "email": "ada@example.com",
            "department": "Cardiology",
            "appointment_date": "2026-07-01",
            "notes": "Referral follow-up",
        },
        follow_redirects=True,
    )

    assert response.status_code == 200
    assert b"Ada Johnson" in response.data
    assert b"Cardiology" in response.data
