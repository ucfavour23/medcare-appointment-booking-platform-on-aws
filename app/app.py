import os
import sqlite3
from contextlib import contextmanager
from datetime import datetime, timezone

from flask import Flask, g, redirect, render_template, request, url_for

try:
    import pymysql
except ImportError:  # pragma: no cover - optional for local sqlite-only tests
    pymysql = None


def create_app(test_config=None):
    app = Flask(__name__)
    app.config.update(
        SECRET_KEY=os.getenv("SECRET_KEY", "dev"),
        SQLITE_PATH=os.getenv("SQLITE_PATH", os.path.join(os.path.dirname(__file__), "appointments.db")),
        DB_HOST=os.getenv("DB_HOST"),
        DB_PORT=int(os.getenv("DB_PORT", "3306")),
        DB_NAME=os.getenv("DB_NAME", "medcare"),
        DB_USER=os.getenv("DB_USER", "medcare_app"),
        DB_PASSWORD=os.getenv("DB_PASSWORD", ""),
    )

    if test_config:
        app.config.update(test_config)

    @app.before_request
    def ensure_schema():
        initialize_database(app)

    @app.route("/", methods=["GET"])
    def index():
        appointments = list_appointments(app)
        return render_template("index.html", appointments=appointments)

    @app.route("/appointments", methods=["POST"])
    def create_appointment():
        appointment = {
            "patient_name": request.form["patient_name"].strip(),
            "email": request.form["email"].strip(),
            "department": request.form["department"],
            "appointment_date": request.form["appointment_date"],
            "notes": request.form.get("notes", "").strip(),
        }
        add_appointment(app, appointment)
        return redirect(url_for("index"))

    @app.route("/health", methods=["GET"])
    def health():
        return {"status": "ok", "service": "medcare-appointments"}, 200

    return app


def using_mysql(app):
    return bool(app.config["DB_HOST"])


@contextmanager
def database_connection(app):
    if using_mysql(app):
        if pymysql is None:
            raise RuntimeError("pymysql is required when DB_HOST is configured")
        connection = pymysql.connect(
            host=app.config["DB_HOST"],
            port=app.config["DB_PORT"],
            user=app.config["DB_USER"],
            password=app.config["DB_PASSWORD"],
            database=app.config["DB_NAME"],
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=True,
        )
    else:
        connection = sqlite3.connect(app.config["SQLITE_PATH"])
        connection.row_factory = sqlite3.Row

    try:
        yield connection
    finally:
        connection.close()


def initialize_database(app):
    if getattr(g, "_schema_ready", False):
        return

    sql = """
        CREATE TABLE IF NOT EXISTS appointments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            patient_name VARCHAR(120) NOT NULL,
            email VARCHAR(160) NOT NULL,
            department VARCHAR(80) NOT NULL,
            appointment_date VARCHAR(20) NOT NULL,
            notes TEXT,
            created_at VARCHAR(32) NOT NULL
        )
    """

    mysql_sql = """
        CREATE TABLE IF NOT EXISTS appointments (
            id INT AUTO_INCREMENT PRIMARY KEY,
            patient_name VARCHAR(120) NOT NULL,
            email VARCHAR(160) NOT NULL,
            department VARCHAR(80) NOT NULL,
            appointment_date VARCHAR(20) NOT NULL,
            notes TEXT,
            created_at VARCHAR(32) NOT NULL
        )
    """

    with database_connection(app) as connection:
        cursor = connection.cursor()
        cursor.execute(mysql_sql if using_mysql(app) else sql)
        if not using_mysql(app):
            connection.commit()

    g._schema_ready = True


def add_appointment(app, appointment):
    with database_connection(app) as connection:
        cursor = connection.cursor()
        cursor.execute(
            """
            INSERT INTO appointments
                (patient_name, email, department, appointment_date, notes, created_at)
            VALUES (%s, %s, %s, %s, %s, %s)
            """
            if using_mysql(app)
            else """
            INSERT INTO appointments
                (patient_name, email, department, appointment_date, notes, created_at)
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            (
                appointment["patient_name"],
                appointment["email"],
                appointment["department"],
                appointment["appointment_date"],
                appointment["notes"],
                datetime.now(timezone.utc).isoformat(timespec="seconds"),
            ),
        )
        if not using_mysql(app):
            connection.commit()


def list_appointments(app):
    with database_connection(app) as connection:
        cursor = connection.cursor()
        cursor.execute("SELECT * FROM appointments ORDER BY id DESC LIMIT 10")
        rows = cursor.fetchall()
        return [dict(row) for row in rows]


if __name__ == "__main__":
    create_app().run(host="0.0.0.0", port=int(os.getenv("PORT", "5000")))
