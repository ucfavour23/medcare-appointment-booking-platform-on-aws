from pathlib import Path
import sys
from tempfile import TemporaryDirectory

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "app"))

from app import create_app  # noqa: E402


def rewrite_asset_paths(html):
    return html.replace('/static/css/styles.css', '../../app/static/css/styles.css')


def write_snapshot(path, html):
    path.write_text(rewrite_asset_paths(html), encoding="utf-8")


def main():
    output_dir = ROOT / "docs" / "screenshots"
    output_dir.mkdir(parents=True, exist_ok=True)

    with TemporaryDirectory() as tmpdir:
        app = create_app({"TESTING": True, "SQLITE_PATH": str(Path(tmpdir) / "appointments.db")})
        client = app.test_client()

        write_snapshot(output_dir / "app-local.html", client.get("/").get_data(as_text=True))

        client.post(
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
        write_snapshot(output_dir / "appointment-created.html", client.get("/").get_data(as_text=True))


if __name__ == "__main__":
    main()
