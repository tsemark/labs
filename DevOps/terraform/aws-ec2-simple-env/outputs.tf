output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_url" {
  description = "URL to access the application via Load Balancer"
  value       = "http://${aws_lb.main.dns_name}"
}

output "app_instance_ids" {
  description = "IDs of all EC2 instances"
  value       = aws_instance.app[*].id
}

output "app_instance_public_ips" {
  description = "Public IP addresses of all EC2 instances"
  value       = aws_instance.app[*].public_ip
}

output "ssh_commands" {
  description = "SSH commands to connect to all app instances"
  value       = [for instance in aws_instance.app : "ssh -i ${path.module}/ec2_key.pem ec2-user@${instance.public_ip}"]
}

output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_address" {
  description = "RDS instance address"
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "app_security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.db.id
}

output "alb_security_group_id" {
  description = "ID of the load balancer security group"
  value       = aws_security_group.alb.id
}

output "private_key_path" {
  description = "Path to the downloaded private key"
  value       = "${path.module}/ec2_key.pem"
}

output "public_key_path" {
  description = "Path to the downloaded public key"
  value       = "${path.module}/ec2_key.pub"
}

