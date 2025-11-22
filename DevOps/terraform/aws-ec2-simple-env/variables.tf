variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "app-db-infra"
}

variable "key_name" {
  description = "Name for the AWS key pair"
  type        = string
  default     = "app-db-key"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones (default: Singapore)"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

# EC2 Configuration
variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "EC2 instance type. For cost optimization, use t3.micro or t3a.micro"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "app_port" {
  description = "Port on which the application runs"
  type        = number
  default     = 3000
}

variable "health_check_path" {
  description = "Health check path for the load balancer"
  type        = string
  default     = "/"
}

# Database Configuration
variable "db_engine" {
  description = "Database engine (mysql, postgres, etc.)"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "RDS instance class. For cost optimization, use db.t3.micro or db.t4g.micro"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Maximum allocated storage for autoscaling in GB"
  type        = number
  default     = 100
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 3306
}

variable "db_skip_final_snapshot" {
  description = "Skip final snapshot when destroying (for cost optimization in dev/test)"
  type        = bool
  default     = true
}

