# GitHub App Configuration
# Get these from your GitHub App settings: https://github.com/organizations/YOUR_ORG/settings/apps
github_app_id         = "123456"
github_app_key_base64 = "LS0tLS1CRUdJTi..." # Base64 encoded private key
github_webhook_secret = "your-webhook-secret" # Optional, for webhook validation

# VPC Configuration
vpc_id     = "vpc-xxxxxxxxxxxxx"
subnet_ids = ["subnet-xxxxxxxxxxxxx", "subnet-yyyyyyyyyyyyy"]

# Instance Configuration - Dynamic Runners
instance_type  = "t4g.xlarge"
instance_types = ["t4g.xlarge"] # For mixed instance policy
capacity_type  = "ON_DEMAND"    # or "SPOT" for cost savings

# Instance Configuration - Standby Runners
standby_instance_type  = "t4g.xlarge"
standby_instance_types = ["t4g.xlarge"]
standby_capacity_type  = "ON_DEMAND"

# Scaling Configuration - Dynamic Runners
min_runners = 0  # Minimum (will be overridden by scheduled scaling)
max_runners = 10 # Maximum capacity (can scale up to this)

# Scaling Configuration - Standby Runners
standby_min_runners = 1  # Always keep at least 1 standby runner
standby_max_runners = 3  # Maximum standby runners

# Scheduled Scaling
enable_scheduled_scaling = true # Enable 9-5 HKT weekday scaling

# Custom AMI Configuration
use_custom_ami = true # Set to true if using Packer-built AMI

# Storage Configuration
volume_size = 30
volume_type = "gp3"

# Runner Labels
runner_extra_labels = ["self-hosted", "linux", "arm64", "custom"]

# Security
enable_runner_ssm_access = true

# Webhook Configuration
enable_webhook     = false
webhook_lambda_zip = null

# Logging
log_level = "info"

# Manual Scaling Alarm (optional)
enable_manual_scaling_alarm = false
manual_scale_threshold      = 0

# Tags
tags = {
  Environment = "production"
  Project     = "github-runners"
  ManagedBy   = "terraform"
}

