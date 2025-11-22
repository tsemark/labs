# Terraform Infrastructure as Code

This directory contains Terraform configurations for deploying various AWS infrastructure patterns.

## Directory Structure

### [aws-ec2-poc-app-env](./aws-ec2-poc-app-env/)
Quick EC2 instance setup for POC/demo purposes. Creates a single EC2 instance with public IP, pre-installed Docker, and open SSH/HTTP ports. See [README](./aws-ec2-poc-app-env/README.md) for details.

### [aws-ec2-simple-env](./aws-ec2-simple-env/)
Production-ready application infrastructure with VPC, Application Load Balancer, multiple EC2 instances, and RDS database. Cost-optimized for small to medium applications. See [README](./aws-ec2-simple-env/README.md) for details.

### [aws-self-hosted-runner](./aws-self-hosted-runner/)
Scalable GitHub Actions self-hosted runners on AWS with auto-scaling based on job queue. Includes scheduled scaling and support for custom AMIs. See [README](./aws-self-hosted-runner/README.md) for details.


