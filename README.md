# MedCare Appointment Booking Platform on AWS

[![CI](https://github.com/ucfavour23/medcare-appointment-booking-platform-on-aws/actions/workflows/ci.yml/badge.svg)](https://github.com/ucfavour23/medcare-appointment-booking-platform-on-aws/actions/workflows/ci.yml)
![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4)
![AWS](https://img.shields.io/badge/AWS-ALB%20%7C%20EC2%20%7C%20RDS-232F3E)
![Python](https://img.shields.io/badge/Python-Flask-3776AB)

MedCare Appointment Booking Platform is a production-style AWS project for a healthcare scheduling workload. It combines a working Flask appointment app with a multi-tier AWS architecture, private compute, private database storage, load balancing, optional HTTPS, CI validation, and deployment evidence.

The project deploys a Flask appointment booking app behind an Application Load Balancer, runs the web tier on EC2 in private subnets, and stores appointments in an RDS MySQL database isolated in private database subnets.

![Local appointment dashboard](docs/screenshots/app-local.png)

## Business Problem

MedCare needs a repeatable way to host an internal appointment booking system with:

- Public web access through a controlled load balancer
- Private application servers
- Private managed database storage
- Segmented network tiers
- Infrastructure-as-code deployment
- Clear operational evidence for recruiters and interview discussions

## What This Demonstrates

| Area | Evidence |
| --- | --- |
| Cloud architecture | Public ALB, private EC2 app tier, private RDS database tier |
| Network design | VPC segmentation, subnet tiers, NAT egress, route tables |
| Security | Tiered security groups, private database, optional ALB HTTPS, Flask security headers |
| Automation | Terraform provisioning, EC2 bootstrap, Docker build, GitHub Actions CI |
| Application delivery | Flask booking workflow, MySQL/RDS mode, SQLite local mode, tests |
| Operations | Health endpoint, deployment outputs, screenshots, evidence docs |

## Architecture

```mermaid
flowchart TD
    users["Patients and Staff"]
    alb["Public Application Load Balancer"]
    https["Optional HTTPS Listener<br/>ACM Certificate"]
    ec2["EC2 Web Server<br/>Private App Subnet"]
    rds["RDS MySQL<br/>Private DB Subnets"]
    nat["NAT Gateway"]
    internet["Internet Gateway"]

    users --> https
    https --> alb
    alb --> ec2
    ec2 --> rds
    ec2 --> nat
    alb --> internet
```

## AWS Services

| Layer | Services |
| --- | --- |
| Network | VPC, public subnets, private app subnets, private database subnets, route tables, Internet Gateway, NAT Gateway |
| Compute | EC2 Ubuntu web server |
| Database | RDS MySQL, DB subnet group |
| Traffic | Application Load Balancer, target group, listener |
| Security | Security groups, optional ACM-backed HTTPS listener, IAM instance profile |
| Operations | CloudWatch-ready EC2 role and deployment outputs |

## Security Features

- Public traffic terminates at the Application Load Balancer.
- EC2 web server is private and only accepts app traffic from the ALB security group.
- RDS MySQL is private and only accepts database traffic from the web security group.
- Optional HTTPS listener uses an ACM certificate and redirects HTTP to HTTPS.
- Flask emits `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, `Permissions-Policy`, and HSTS when HTTPS is active.
- Terraform state, local database files, credentials, and generated caches are excluded from git.

## Repository Structure

```text
app/                    # Flask appointment booking application
docs/                   # Architecture, deployment guide, evidence checklist
scripts/                # Local evidence rendering helpers
terraform/              # AWS multi-tier infrastructure
tests/                  # Application tests
Dockerfile
docker-compose.yml
README.md
```

## Local Demo

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r app\requirements.txt
python app\app.py
```

Open:

```text
http://127.0.0.1:5000
```

Run tests:

```powershell
python -m pytest -q
```

## Terraform Workflow

```powershell
cd terraform
copy terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

After deployment, open the `alb_dns_name` output in a browser.

### Enable HTTPS

AWS does not issue trusted certificates for the default ALB DNS name. To enable HTTPS, point a domain you own to the ALB and request/validate an ACM certificate in the same AWS region as the load balancer. Then set:

```hcl
acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/your-certificate-id"
```

When `acm_certificate_arn` is set, Terraform creates a port 443 HTTPS listener, redirects HTTP to HTTPS, and enables HSTS for the deployed app.

## Evidence Screenshots

Save important screenshots in `docs/screenshots/`:

| Evidence | File |
| --- | --- |
| Local app running | `app-local.png` |
| Appointment submission | `appointment-created.png` |
| Tests passing | `tests-passing.png` |
| Terraform formatting | `terraform-fmt.png` |
| Terraform validation | `terraform-validate.png` |
| Terraform plan | `terraform-plan.png` |
| Terraform apply outputs | `terraform-apply.png` |
| VPC subnet layout | `vpc-subnets.png` |
| ALB target health | `alb-target-health.png` |
| RDS database details | `rds-database.png` |
| Live AWS app | `ec2-dashboard-live.png` |
| EC2 service status | `ec2-systemd-status.png` |

## Recruiter Value

This project shows practical AWS engineering skills across networking, security groups, private compute, managed databases, load balancing, Terraform, Python application delivery, and documentation.

## Current Verification Notes

Local Python tests, Terraform formatting, and Terraform validation pass. On this machine, the Windows AWS provider plugin can fail while loading its schema, so the reliable validation path is the persistent WSL workspace:

```powershell
wsl.exe bash -lc "cd ~/medcare-appointments-tf-validate && terraform validate"
```

`terraform plan` succeeds from the WSL Terraform workspace and currently plans 29 resources.

Live deployment:

```text
ALB URL: http://medcare-appointments-alb-534651057.us-east-1.elb.amazonaws.com
VPC: vpc-00d32856044ebdc9c
EC2 web instance: i-0db702092e7f31e63
RDS endpoint: medcare-appointments-mysql.cc5guq6y2nty.us-east-1.rds.amazonaws.com
```
