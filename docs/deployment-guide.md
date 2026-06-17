# Deployment Guide

## Prerequisites

- AWS account
- AWS CLI credentials configured
- Terraform installed
- Budget awareness: NAT Gateway and RDS can create hourly charges

## Deploy

```powershell
cd terraform
copy terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Open the `alb_dns_name` output after the target group reports healthy.

If local Windows Terraform fails while loading the AWS provider schema, validate through WSL from a clean workspace:

```powershell
wsl.exe bash -lc "cd ~/medcare-appointments-tf-validate && terraform validate"
```

If `terraform plan` fails with `InvalidClientTokenId`, refresh AWS credentials before planning or applying:

```powershell
aws configure
aws sts get-caller-identity
```

## Validate

Capture evidence for:

- VPC with public, private app, and private database subnets
- NAT Gateway route from private app subnets
- ALB listener and target group health
- RDS MySQL instance in private database subnets
- Browser access through the ALB DNS name

## Cleanup

```powershell
terraform destroy
```
