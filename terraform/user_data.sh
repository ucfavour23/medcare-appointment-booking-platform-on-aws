#!/bin/bash
set -euo pipefail

apt-get update
apt-get install -y python3 python3-pip python3-venv

mkdir -p /opt/medcare-appointments
cat > /opt/medcare-appointments/app.py <<'PY'
import os
from datetime import datetime, timezone

from flask import Flask, redirect, request, url_for
import pymysql
from werkzeug.middleware.proxy_fix import ProxyFix

app = Flask(__name__)
app.wsgi_app = ProxyFix(app.wsgi_app, x_proto=1, x_host=1)

@app.after_request
def set_security_headers(response):
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    response.headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=()"
    if os.getenv("ENABLE_HSTS", "false").lower() == "true" or request.is_secure:
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
    return response

def conn():
    return pymysql.connect(
        host=os.environ["DB_HOST"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        database=os.environ["DB_NAME"],
        autocommit=True,
        cursorclass=pymysql.cursors.DictCursor,
    )

def ensure_schema():
    with conn() as database:
        with database.cursor() as cursor:
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS appointments (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    patient_name VARCHAR(120) NOT NULL,
                    email VARCHAR(160) NOT NULL,
                    department VARCHAR(80) NOT NULL,
                    appointment_date VARCHAR(20) NOT NULL,
                    notes TEXT,
                    created_at VARCHAR(32) NOT NULL
                )
            """)
            cursor.execute("SHOW COLUMNS FROM appointments")
            existing_columns = {row["Field"] for row in cursor.fetchall()}
            migrations = {
                "email": "ALTER TABLE appointments ADD COLUMN email VARCHAR(160) NOT NULL DEFAULT ''",
                "department": "ALTER TABLE appointments ADD COLUMN department VARCHAR(80) NOT NULL DEFAULT 'General Medicine'",
                "appointment_date": "ALTER TABLE appointments ADD COLUMN appointment_date VARCHAR(20) NOT NULL DEFAULT ''",
                "notes": "ALTER TABLE appointments ADD COLUMN notes TEXT",
                "created_at": "ALTER TABLE appointments ADD COLUMN created_at VARCHAR(32) NOT NULL DEFAULT ''",
            }
            for column, statement in migrations.items():
                if column not in existing_columns:
                    cursor.execute(statement)

@app.route("/health")
def health():
    return {"status": "ok"}, 200

@app.route("/", methods=["GET"])
def index():
    ensure_schema()
    with conn() as database:
        with database.cursor() as cursor:
            cursor.execute("SELECT * FROM appointments ORDER BY id DESC LIMIT 10")
            appointments = cursor.fetchall()

    rows = "".join(
        f"<article><strong>{item['patient_name']}</strong><span>{item['department']} &middot; {item['appointment_date']}</span><a href='mailto:{item['email']}'>{item['email']}</a></article>"
        for item in appointments
    ) or "<p>No appointments yet. Create the first booking to confirm the workflow.</p>"

    return f"""
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>MedCare Appointments</title>
  <style>
    body {{ margin: 0; background: #f6f8fb; color: #172033; font-family: Arial, sans-serif; }}
    main {{ width: min(1120px, calc(100% - 32px)); margin: 0 auto; padding: 38px 0; }}
    header {{ border-bottom: 1px solid #d9e0ea; padding-bottom: 24px; }}
    h1 {{ margin: 0 0 10px; font-size: 56px; line-height: 1; }}
    p {{ color: #5b667a; }}
    .tiers {{ display: flex; gap: 8px; flex-wrap: wrap; margin-top: 18px; }}
    .tiers span {{ border: 1px solid #d9e0ea; border-radius: 999px; background: white; padding: 8px 12px; color: #5b667a; }}
    .grid {{ display: grid; grid-template-columns: 0.9fr 1.1fr; gap: 24px; margin-top: 28px; }}
    section, form {{ border: 1px solid #d9e0ea; border-radius: 8px; background: white; padding: 22px; box-shadow: 0 16px 40px rgba(23, 32, 51, 0.07); }}
    label {{ display: grid; gap: 7px; margin-bottom: 14px; color: #5b667a; font-weight: 700; }}
    input, select, textarea {{ width: 100%; border: 1px solid #d9e0ea; border-radius: 6px; padding: 11px 12px; font: inherit; box-sizing: border-box; }}
    button {{ width: 100%; border: 0; border-radius: 6px; background: #0f766e; color: white; padding: 12px 14px; font: inherit; font-weight: 800; }}
    article {{ display: flex; justify-content: space-between; gap: 14px; border: 1px solid #d9e0ea; border-left: 4px solid #b45309; border-radius: 7px; padding: 14px; margin-bottom: 12px; }}
    article span {{ color: #5b667a; }}
    article a {{ color: #115e59; font-weight: 700; text-decoration: none; }}
    @media (max-width: 820px) {{ .grid {{ grid-template-columns: 1fr; }} h1 {{ font-size: 40px; }} article {{ flex-direction: column; }} }}
  </style>
</head>
<body>
  <main>
    <header>
      <strong style="color:#115e59;">MEDCARE CLINIC NETWORK</strong>
      <h1>Appointment Booking</h1>
      <p>Production-style healthcare booking platform running behind an AWS Application Load Balancer with private EC2 and RDS tiers.</p>
      <div class="tiers"><span>Public ALB</span><span>Private EC2</span><span>Private RDS MySQL</span></div>
    </header>
    <div class="grid">
      <form method="post" action="/appointments">
        <h2>New Appointment</h2>
        <label>Patient name<input name="patient_name" required placeholder="Ada Johnson"></label>
        <label>Email<input type="email" name="email" required placeholder="ada@example.com"></label>
        <label>Department<select name="department"><option>General Medicine</option><option>Pediatrics</option><option>Cardiology</option><option>Diagnostics</option></select></label>
        <label>Date<input type="date" name="appointment_date" required></label>
        <label>Notes<textarea name="notes" rows="4" placeholder="Symptoms, referral notes, or visit context"></textarea></label>
        <button type="submit">Book Appointment</button>
      </form>
      <section>
        <h2>Recent Appointments</h2>
        {rows}
      </section>
    </div>
  </main>
</body>
</html>
"""

@app.route("/appointments", methods=["POST"])
def create_appointment():
    ensure_schema()
    with conn() as database:
        with database.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO appointments
                    (patient_name, email, department, appointment_date, notes, created_at)
                VALUES (%s, %s, %s, %s, %s, %s)
                """,
                (
                    request.form["patient_name"].strip(),
                    request.form["email"].strip(),
                    request.form["department"],
                    request.form["appointment_date"],
                    request.form.get("notes", "").strip(),
                    datetime.now(timezone.utc).isoformat(timespec="seconds"),
                ),
            )
    return redirect(url_for("index"))

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
PY

python3 -m venv /opt/medcare-appointments/.venv
/opt/medcare-appointments/.venv/bin/pip install flask pymysql gunicorn

cat > /etc/systemd/system/medcare-appointments.service <<SERVICE
[Unit]
Description=MedCare appointment web app
After=network-online.target
Wants=network-online.target

[Service]
WorkingDirectory=/opt/medcare-appointments
Environment=DB_HOST=${db_host}
Environment=DB_NAME=${db_name}
Environment=DB_USER=${db_user}
Environment=DB_PASSWORD=${db_password}
Environment=ENABLE_HSTS=${enable_hsts}
ExecStart=/opt/medcare-appointments/.venv/bin/gunicorn --bind 0.0.0.0:5000 app:app
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable --now medcare-appointments
