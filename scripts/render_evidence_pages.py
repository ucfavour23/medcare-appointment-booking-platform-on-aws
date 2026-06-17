from html import escape
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "screenshots"


def run(command):
    completed = subprocess.run(
        command,
        cwd=ROOT,
        capture_output=True,
        text=True,
        shell=True,
        timeout=900,
    )
    output = completed.stdout + completed.stderr
    return completed.returncode, output.strip()


def write_page(name, title, command, returncode, output):
    status = "PASSED" if returncode == 0 else "BLOCKED"
    html = f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>{escape(title)}</title>
  <style>
    body {{
      margin: 0;
      background: #101827;
      color: #e5edf7;
      font-family: Consolas, "Courier New", monospace;
    }}
    main {{
      max-width: 1120px;
      margin: 0 auto;
      padding: 48px;
    }}
    h1 {{
      margin: 0 0 12px;
      font-family: "Segoe UI", Arial, sans-serif;
      font-size: 42px;
    }}
    .status {{
      display: inline-block;
      margin-bottom: 24px;
      border-radius: 4px;
      background: {"#0f766e" if returncode == 0 else "#b45309"};
      padding: 8px 12px;
      font-family: "Segoe UI", Arial, sans-serif;
      font-weight: 700;
    }}
    pre {{
      overflow-wrap: anywhere;
      white-space: pre-wrap;
      border: 1px solid #314158;
      border-radius: 8px;
      background: #0b1220;
      padding: 24px;
      font-size: 18px;
      line-height: 1.45;
    }}
  </style>
</head>
<body>
  <main>
    <h1>{escape(title)}</h1>
    <div class="status">{status}</div>
    <pre>$ {escape(command)}

{escape(output)}</pre>
  </main>
</body>
</html>
"""
    (OUT / name).write_text(html, encoding="utf-8")


def main():
    OUT.mkdir(parents=True, exist_ok=True)

    checks = [
        (
            "tests-passing.html",
            "Python Tests",
            "python -m pytest -q -p no:cacheprovider --basetemp C:\\Users\\LENOVO\\AppData\\Local\\Temp\\medcare-appointments-pytest",
        ),
        (
            "terraform-fmt.html",
            "Terraform Format Check",
            "terraform -chdir=terraform fmt -check",
        ),
        (
            "terraform-validate.html",
            "Terraform Validate",
            "wsl.exe bash -lc \"cd ~/medcare-appointments-tf-validate && terraform validate\"",
        ),
        (
            "terraform-plan.html",
            "Terraform Plan",
            "wsl.exe bash -lc \"cd ~/medcare-appointments-tf-validate && terraform show -no-color tfplan | tail -90\"",
        ),
        (
            "terraform-apply.html",
            "Terraform Apply Outputs",
            "wsl.exe bash -lc \"cd ~/medcare-appointments-tf-validate && echo 'Apply complete. Current Terraform outputs:' && terraform output && echo && echo 'Managed state resources:' && terraform state list\"",
        ),
        (
            "alb-target-health.html",
            "ALB Target Health",
            "wsl.exe bash -lc \"aws elbv2 describe-target-health --target-group-arn arn:aws:elasticloadbalancing:us-east-1:755431180020:targetgroup/medcare-appointments-tg/06e1d2233569eb62 --output table\"",
        ),
        (
            "ec2-systemd-status.html",
            "EC2 App Service Status",
            "wsl.exe bash -lc \"bash '/mnt/c/Users/LENOVO/OneDrive/Desktop/MedCare Appointment Booking Platform on AWS/scripts/check_ec2_app.sh' i-0db702092e7f31e63 | tail -90\"",
        ),
    ]

    for filename, title, command in checks:
        returncode, output = run(command)
        write_page(filename, title, command, returncode, output)


if __name__ == "__main__":
    main()
