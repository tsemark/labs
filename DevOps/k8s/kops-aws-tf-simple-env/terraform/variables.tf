variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "kops-simple-env"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "kubernetes_version" {
  description = "Kubernetes version for kops cluster"
  type        = string
  default     = "1.28.0"
}

variable "control_plane_instance_type" {
  description = "Instance type for control plane nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_instance_type" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
  default     = "kops-simple-cluster.k8s.local"
}

variable "enable_encryption" {
  description = "Enable encryption at rest for EBS volumes"
  type        = bool
  default     = true
}

variable "enable_network_encryption" {
  description = "Enable encryption in transit"
  type        = bool
  default     = true
}

