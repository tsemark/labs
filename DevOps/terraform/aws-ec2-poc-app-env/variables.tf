variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "ec2-sample"
}

variable "key_name" {
  description = "Name for the AWS key pair"
  type        = string
  default     = "ec2-sample-key"
}

variable "instance_type" {
  description = "EC2 instance type. Recommended for 4-8 GB RAM and 2-4 CPU: t3.medium, t3.large, t3a.medium, t3a.large, m5.large, m5a.large"
  type        = string
  default     = "t3a.large"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance. Leave empty to use latest Amazon Linux 2"
  type        = string
  default     = ""
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}
