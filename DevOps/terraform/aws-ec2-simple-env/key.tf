resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.ec2_key.private_key_pem
  filename        = "${path.module}/ec2_key.pem"
  file_permission = "0600"
}

resource "local_file" "public_key" {
  content         = tls_private_key.ec2_key.public_key_openssh
  filename        = "${path.module}/ec2_key.pub"
  file_permission = "0644"
}

resource "aws_key_pair" "ec2_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2_key.public_key_openssh

  tags = {
    Name = "${var.project_name}-ssh-key"
  }
}

