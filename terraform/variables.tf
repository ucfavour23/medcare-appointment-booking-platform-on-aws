variable "aws_region" {
  description = "AWS region for the multi-tier platform."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix for AWS resources."
  type        = string
  default     = "medcare-appointments"
}

variable "vpc_cidr" {
  description = "CIDR block for the application VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "allowed_http_cidr" {
  description = "CIDR allowed to reach the public ALB."
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_https_cidr" {
  description = "CIDR allowed to reach the HTTPS listener on the public ALB."
  type        = string
  default     = "0.0.0.0/0"
}

variable "acm_certificate_arn" {
  description = "Optional ACM certificate ARN for enabling HTTPS on the ALB. Leave empty for HTTP-only demo deployments."
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type for the private web server."
  type        = string
  default     = "t3.micro"
}

variable "db_name" {
  description = "RDS database name."
  type        = string
  default     = "medcare"
}

variable "db_username" {
  description = "RDS application username."
  type        = string
  default     = "medcare_app"
}

variable "db_password" {
  description = "RDS application password."
  type        = string
  sensitive   = true
}
