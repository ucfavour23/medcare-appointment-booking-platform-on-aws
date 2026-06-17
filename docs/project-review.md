# Project Review

## Current Status

The project now has the first complete multi-tier slice:

- Flask appointment booking workflow
- Local SQLite mode for development and tests
- MySQL environment configuration for RDS
- Docker runtime files
- Terraform VPC with public, private app, and private database subnets
- NAT Gateway for private app outbound access
- Application Load Balancer
- Private EC2 web server
- Private RDS MySQL database
- Security groups scoped between tiers
- Documentation and screenshot checklist

## Next Evidence To Capture

1. Capture AWS console screenshots for VPC subnets and RDS details.
2. Replace CLI evidence screenshots with console screenshots where useful.
3. Add a final recruiter-facing summary after cost cleanup decision.

## Local Verification

- Python tests pass locally.
- Terraform formatting passes locally.
- Terraform validation passes from a persistent WSL workspace at `~/medcare-appointments-tf-validate`. The Windows AWS provider plugin fails while loading schema in this environment, so WSL is the reliable local validation path for this machine.
- Terraform plan succeeds from WSL and creates a saved `tfplan`.
- Terraform apply completed successfully.
- Live ALB URL: `http://medcare-appointments-alb-534651057.us-east-1.elb.amazonaws.com`
- Current web instance: `i-0db702092e7f31e63`
- VPC: `vpc-00d32856044ebdc9c`
- RDS endpoint: `medcare-appointments-mysql.cc5guq6y2nty.us-east-1.rds.amazonaws.com`
- ALB target health is healthy and the live booking workflow stores/retrieves an appointment from RDS.
- Final Terraform plan check reports no drift.
