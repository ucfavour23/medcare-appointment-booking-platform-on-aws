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

## HTTPS

The default ALB DNS name cannot receive a trusted AWS-issued certificate directly. For HTTPS, use a domain you control:

1. Request an ACM certificate for the domain in the same AWS region as the ALB.
2. Validate the certificate with DNS.
3. Point the domain to the ALB using a Route 53 alias record or a CNAME.
4. Set `acm_certificate_arn` in `terraform.tfvars`.
5. Run `terraform apply`.

When `acm_certificate_arn` is set, Terraform creates a port 443 listener, redirects HTTP to HTTPS, and enables HSTS in the deployed Flask service.

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
