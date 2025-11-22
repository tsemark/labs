variable "github_app_id" {
  description = "GitHub App ID for authentication"
  type        = string
  sensitive   = true
}

variable "github_app_key_base64" {
  description = "Base64 encoded GitHub App private key"
  type        = string
  sensitive   = true
}

variable "github_webhook_secret" {
  description = "GitHub webhook secret for webhook validation"
  type        = string
  sensitive   = true
  default     = null
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "github-runner"
}

# VPC Configuration
variable "vpc_id" {
  description = "VPC ID where runners will be launched"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where runners will be launched"
  type        = list(string)
}

# Instance Configuration
variable "instance_type" {
  description = "EC2 instance type for dynamic runners"
  type        = string
  default     = "t4g.xlarge"
}

variable "instance_types" {
  description = "List of EC2 instance types for dynamic runners (for mixed instance policy)"
  type        = list(string)
  default     = ["t4g.xlarge"]
}

variable "standby_instance_type" {
  description = "EC2 instance type for standby runners"
  type        = string
  default     = "t4g.xlarge"
}

variable "standby_instance_types" {
  description = "List of EC2 instance types for standby runners"
  type        = list(string)
  default     = ["t4g.xlarge"]
}

variable "capacity_type" {
  description = "Capacity type for dynamic runners (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.capacity_type)
    error_message = "Capacity type must be either ON_DEMAND or SPOT."
  }
}

variable "standby_capacity_type" {
  description = "Capacity type for standby runners (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.standby_capacity_type)
    error_message = "Standby capacity type must be either ON_DEMAND or SPOT."
  }
}

# Scaling Configuration
variable "min_runners" {
  description = "Minimum number of dynamic runners"
  type        = number
  default     = 0
}

variable "max_runners" {
  description = "Maximum number of dynamic runners (can scale up to this)"
  type        = number
  default     = 10
}

variable "standby_min_runners" {
  description = "Minimum number of standby runners"
  type        = number
  default     = 1
}

variable "standby_max_runners" {
  description = "Maximum number of standby runners"
  type        = number
  default     = 3
}

# Scheduled Scaling
variable "enable_scheduled_scaling" {
  description = "Enable scheduled scaling for 9-5 HKT weekdays"
  type        = bool
  default     = true
}

# Custom AMI Configuration
variable "use_custom_ami" {
  description = "Whether to use a custom AMI built with Packer"
  type        = bool
  default     = false
}

# Storage Configuration
variable "volume_size" {
  description = "EBS volume size in GB"
  type        = number
  default     = 30
}

variable "volume_type" {
  description = "EBS volume type"
  type        = string
  default     = "gp3"
}

# Runner Configuration
variable "runner_extra_labels" {
  description = "Extra labels to add to runners"
  type        = list(string)
  default     = ["self-hosted", "linux", "arm64"]
}

variable "user_data_template" {
  description = "User data template for runner configuration (if not using custom AMI)"
  type        = string
  default     = null
}

# Security Configuration
variable "enable_runner_ssm_access" {
  description = "Enable SSM access for runners"
  type        = bool
  default     = true
}

# Webhook Configuration
variable "enable_webhook" {
  description = "Enable webhook for runner management"
  type        = bool
  default     = false
}

variable "webhook_lambda_zip" {
  description = "Path to webhook lambda zip file"
  type        = string
  default     = null
}

# Logging
variable "log_level" {
  description = "Log level for runner lambdas"
  type        = string
  default     = "info"
  validation {
    condition     = contains(["debug", "info", "warn", "error"], var.log_level)
    error_message = "Log level must be one of: debug, info, warn, error."
  }
}

# Manual Scaling Alarm
variable "enable_manual_scaling_alarm" {
  description = "Enable CloudWatch alarm for manual scaling"
  type        = bool
  default     = false
}

variable "manual_scale_threshold" {
  description = "Threshold for manual scaling alarm"
  type        = number
  default     = 0
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

