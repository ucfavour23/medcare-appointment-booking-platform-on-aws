# Recruiter Brief

## Project Summary

MedCare Appointment Booking Platform is a cloud portfolio project that demonstrates how to deploy a healthcare scheduling web application on AWS using a production-style three-tier architecture.

The project includes a working Flask application, Terraform infrastructure, private network tiers, RDS MySQL storage, an Application Load Balancer, optional HTTPS support, Docker packaging, GitHub Actions CI, and deployment evidence screenshots.

## Why This Project Matters

This project shows more than a simple web app. It demonstrates that the application can be packaged, tested, deployed, secured, and documented as part of a realistic cloud workflow.

Key strengths:

- Built a functional appointment booking application with Python and Flask.
- Designed a segmented AWS VPC with public, private app, and private database tiers.
- Deployed private EC2 compute behind an Application Load Balancer.
- Deployed RDS MySQL in private database subnets.
- Used Terraform to make infrastructure repeatable.
- Added CI checks for tests, Terraform, and Docker build.
- Added optional HTTPS support through ACM and ALB listener configuration.
- Captured evidence screenshots showing local validation, Terraform workflow, live ALB access, and EC2 service health.

## Architecture Highlights

| Area | Implementation |
| --- | --- |
| Public access | Application Load Balancer |
| App tier | EC2 instance in private subnet |
| Database tier | RDS MySQL in private database subnets |
| Network security | Security groups scoped between ALB, EC2, and RDS |
| Deployment | Terraform infrastructure-as-code |
| Runtime | Flask app served by Gunicorn |
| Validation | Pytest, Terraform checks, Docker build, screenshot evidence |

## Skills Demonstrated

- AWS VPC and subnet design
- Load balancer configuration
- Private EC2 deployment
- RDS MySQL deployment
- Security group design
- Terraform infrastructure-as-code
- Python Flask backend development
- Docker packaging
- GitHub Actions CI
- HTTPS and security header hardening
- Technical documentation and deployment evidence

## Suggested Interview Talking Points

- Why the ALB is public while EC2 and RDS remain private.
- How security groups enforce traffic flow between tiers.
- How Terraform makes the deployment repeatable.
- Why local SQLite mode is useful for tests while RDS is used in AWS.
- How HTTPS is enabled through ACM and ALB listeners.
- What screenshots prove the system is working.
- What improvements would come next for a production environment.

## Production Improvements To Discuss

- Store database credentials in AWS Secrets Manager or SSM Parameter Store.
- Add CloudWatch dashboards and alarms.
- Add automated database backups and stricter deletion protection.
- Add HTTPS with a custom domain and validated ACM certificate.
- Add blue-green or rolling deployment automation.
- Add centralized logs and structured application logging.
- Add database migration tooling.
