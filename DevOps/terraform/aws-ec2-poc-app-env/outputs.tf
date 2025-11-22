output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ec2.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.ec2.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.ec2.public_dns
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${path.module}/ec2_key.pem ec2-user@${aws_instance.ec2.public_ip}"
}

output "private_key_path" {
  description = "Path to the downloaded private key"
  value       = "${path.module}/ec2_key.pem"
}

output "public_key_path" {
  description = "Path to the downloaded public key"
  value       = "${path.module}/ec2_key.pem"
}
