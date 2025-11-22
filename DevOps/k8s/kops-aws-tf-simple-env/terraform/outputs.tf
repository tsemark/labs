output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.k8s.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.k8s.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "control_plane_iam_role_arn" {
  description = "Control plane IAM role ARN"
  value       = aws_iam_role.control_plane.arn
}

output "control_plane_iam_instance_profile" {
  description = "Control plane IAM instance profile name"
  value       = aws_iam_instance_profile.control_plane.name
}

output "worker_node_iam_role_arn" {
  description = "Worker node IAM role ARN"
  value       = aws_iam_role.worker_nodes.arn
}

output "worker_node_iam_instance_profile" {
  description = "Worker node IAM instance profile name"
  value       = aws_iam_instance_profile.worker_nodes.name
}

output "control_plane_security_group_id" {
  description = "Control plane security group ID"
  value       = aws_security_group.control_plane.id
}

output "worker_node_security_group_id" {
  description = "Worker node security group ID"
  value       = aws_security_group.worker_nodes.id
}

output "kms_key_id" {
  description = "KMS key ID for EBS encryption"
  value       = var.enable_encryption ? aws_kms_key.ebs[0].id : null
}

output "kms_key_arn" {
  description = "KMS key ARN for EBS encryption"
  value       = var.enable_encryption ? aws_kms_key.ebs[0].arn : null
}

output "nat_gateway_ips" {
  description = "NAT Gateway Elastic IPs"
  value       = aws_eip.nat[*].public_ip
}

