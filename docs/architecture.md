# Architecture

The platform uses a classic three-tier AWS architecture:

- Public tier: Internet Gateway, public subnets, and Application Load Balancer.
- Application tier: EC2 web server in private app subnets.
- Database tier: RDS MySQL in private database subnets.

The ALB is the only public entry point. The EC2 security group accepts traffic only from the ALB security group on port `5000`. The RDS security group accepts MySQL traffic only from the EC2 web tier.

The private app tier uses a NAT Gateway for package installation and outbound updates without exposing the instance directly to the internet.
