# Project Completion Notes

## Current Status

The project has a complete end-to-end cloud portfolio slice:

- Flask appointment booking app
- Local SQLite development and test mode
- RDS MySQL deployment mode
- Docker runtime support
- Terraform-managed AWS infrastructure
- Public ALB entry point
- Private EC2 application tier
- Private RDS database tier
- Optional HTTPS support with ACM
- Security headers in Flask
- GitHub Actions CI workflow
- Screenshot evidence for local validation and AWS deployment

## Verified Evidence

| Area | Evidence |
| --- | --- |
| Local app | Dashboard screenshot captured |
| Booking workflow | Appointment creation screenshot captured |
| Python tests | Passing test screenshot captured |
| Terraform format | Format check screenshot captured |
| Terraform validate | Validation screenshot captured from working validation path |
| Terraform plan | Plan screenshot captured |
| Terraform apply | Apply output screenshot captured |
| ALB health | Target group healthy screenshot captured |
| Live app | Public ALB app screenshot captured |
| EC2 service | systemd status screenshot captured |

## Remaining Optional Evidence

These screenshots would make the repository even stronger if captured later:

- VPC subnet layout in the AWS console
- RDS database details page showing private subnet group
- GitHub Actions successful workflow run
- HTTPS browser lock after custom domain and ACM certificate setup

## Known Environment Note

On this Windows workstation, Terraform can fail while loading the AWS provider schema. The project documents the WSL validation workspace used as the reliable local path for Terraform validation and planning.

## Recommended Next Improvements

- Move database credentials to AWS Secrets Manager or SSM Parameter Store.
- Add CloudWatch alarms for ALB, EC2, and RDS.
- Enable RDS deletion protection for non-demo deployments.
- Add application logs to CloudWatch Logs.
- Add database migration tooling.
- Configure HTTPS with a custom domain and ACM certificate.
- Replace remaining generated evidence screenshots with AWS console screenshots where useful.
