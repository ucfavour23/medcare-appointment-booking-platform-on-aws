output "alb_dns_name" {
  description = "Public URL for the appointment platform."
  value       = "http://${aws_lb.app.dns_name}"
}

output "vpc_id" {
  description = "Application VPC ID."
  value       = aws_vpc.main.id
}

output "web_instance_id" {
  description = "Private EC2 web server instance ID."
  value       = aws_instance.web.id
}

output "rds_endpoint" {
  description = "Private RDS endpoint."
  value       = aws_db_instance.main.address
}

output "private_app_subnet_ids" {
  description = "Private application subnet IDs."
  value       = aws_subnet.app_private[*].id
}

output "private_db_subnet_ids" {
  description = "Private database subnet IDs."
  value       = aws_subnet.db_private[*].id
}
