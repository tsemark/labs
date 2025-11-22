terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Generate SSH key pair
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key to local file
resource "local_file" "private_key" {
  content  = tls_private_key.ec2_key.private_key_pem
  filename = "${path.module}/ec2_key.pem"
  file_permission = "0600"
}

# Save public key to local file
resource "local_file" "public_key" {
  content  = tls_private_key.ec2_key.public_key_openssh
  filename = "${path.module}/ec2_key.pub"
  file_permission = "0644"
}

# Upload public key to AWS
resource "aws_key_pair" "ec2_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2_key.public_key_openssh
  
  tags = {
    Name = "ec2-ssh-key"
  }
}

# Security group for EC2 instance
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for EC2 instance with SSH, HTTP, and application ports access"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Port 3000"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Port 8000"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# User data script to install git, docker, and docker-compose
locals {
  user_data = file("${path.module}/user-data.sh")
}

# EC2 Instance
resource "aws_instance" "ec2" {
  ami           = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  
  key_name      = aws_key_pair.ec2_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  
  associate_public_ip_address = true
  
  user_data = local.user_data
  
  tags = {
    Name = var.project_name
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size
  }
}
