terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Data source to get the latest custom AMI (optional - can use module's default)
data "aws_ami" "custom_runner_ami" {
  count       = var.use_custom_ami ? 1 : 0
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["gh_runners_*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Main GitHub Runner Module - Dynamic Runners
module "github_runner_dynamic" {
  source = "github.com/github-aws-runners/terraform-aws-github-runner?ref=v6.8.5"

  # GitHub Configuration
  github_app = {
    key_base64     = var.github_app_key_base64
    id             = var.github_app_id
    webhook_secret = var.github_webhook_secret
  }

  # Runner Configuration - Dynamic Runners
  runners = {
    dynamic = {
      name = "dynamic-runners"
      # Use custom AMI if provided, otherwise module will use default
      ami = var.use_custom_ami && length(data.aws_ami.custom_runner_ami) > 0 ? data.aws_ami.custom_runner_ami[0].id : null

      instance_types = var.instance_types
      instance_type  = var.instance_type

      # Auto Scaling Configuration
      min_size = var.min_runners
      max_size = var.max_runners

      # Schedule-based scaling will be handled by ASG scheduled actions
      # This sets the base capacity
      capacity_type = var.capacity_type

      # Runner labels
      runner_extra_labels = var.runner_extra_labels

      # Subnet and security group
      subnet_ids = var.subnet_ids
      vpc_id     = var.vpc_id

      # IAM role for runners
      enable_runner_ssm_access = var.enable_runner_ssm_access

      # User data for runner configuration (if not using custom AMI)
      user_data_template = var.use_custom_ami ? null : var.user_data_template

      # Block device mappings
      block_device_mappings = [
        {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = var.volume_size
            volume_type           = var.volume_type
            delete_on_termination = true
            encrypted             = true
          }
        }
      ]

      # Tags
      tags = merge(
        var.tags,
        {
          Name        = "github-runner-dynamic"
          RunnerType  = "dynamic"
          ManagedBy   = "terraform"
        }
      )
    }
  }

  # Webhook configuration (optional)
  enable_webhook = var.enable_webhook
  webhook_lambda_zip = var.webhook_lambda_zip

  # Logging
  log_level = var.log_level

  # Tags
  tags = var.tags
}

# Standby Runners Module - Always Running
module "github_runner_standby" {
  source = "github.com/github-aws-runners/terraform-aws-github-runner?ref=v6.8.5"

  # GitHub Configuration
  github_app = {
    key_base64     = var.github_app_key_base64
    id             = var.github_app_id
    webhook_secret = var.github_webhook_secret
  }

  # Runner Configuration - Standby Runners
  runners = {
    standby = {
      name = "standby-runners"
      # Use custom AMI if provided
      ami = var.use_custom_ami && length(data.aws_ami.custom_runner_ami) > 0 ? data.aws_ami.custom_runner_ami[0].id : null

      instance_types = var.standby_instance_types
      instance_type  = var.standby_instance_type

      # Standby runners have fixed capacity
      min_size = var.standby_min_runners
      max_size = var.standby_max_runners

      capacity_type = var.standby_capacity_type

      # Runner labels
      runner_extra_labels = concat(var.runner_extra_labels, ["standby"])

      # Subnet and security group
      subnet_ids = var.subnet_ids
      vpc_id     = var.vpc_id

      # IAM role for runners
      enable_runner_ssm_access = var.enable_runner_ssm_access

      # User data for runner configuration (if not using custom AMI)
      user_data_template = var.use_custom_ami ? null : var.user_data_template

      # Block device mappings
      block_device_mappings = [
        {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = var.volume_size
            volume_type           = var.volume_type
            delete_on_termination = true
            encrypted             = true
          }
        }
      ]

      # Tags
      tags = merge(
        var.tags,
        {
          Name       = "github-runner-standby"
          RunnerType = "standby"
          ManagedBy  = "terraform"
        }
      )
    }
  }

  # Webhook configuration (optional) - reuse same webhook
  enable_webhook = false # Only enable on one module instance

  # Logging
  log_level = var.log_level

  # Tags
  tags = var.tags
}

# Scheduled Scaling Actions for Dynamic Runners (9 AM - 5 PM HKT, Weekdays Only)
# HKT is UTC+8, so:
# 9 AM HKT = 1 AM UTC
# 5 PM HKT = 9 AM UTC

# Scale up to 1 runner at 9 AM HKT (1 AM UTC) on weekdays
resource "aws_autoscaling_schedule" "scale_up_weekdays" {
  count                  = var.enable_scheduled_scaling ? 1 : 0
  scheduled_action_name  = "scale-up-9am-hkt-weekdays"
  autoscaling_group_name = module.github_runner_dynamic.runners.dynamic.autoscaling_group_name
  min_size               = 1
  max_size               = var.max_runners
  desired_capacity       = 1
  recurrence             = "0 1 * * MON-FRI" # 1 AM UTC = 9 AM HKT, Monday to Friday
  time_zone              = "Asia/Hong_Kong"
}

# Scale down to 0 runners at 5 PM HKT (9 AM UTC) on weekdays
resource "aws_autoscaling_schedule" "scale_down_weekdays" {
  count                  = var.enable_scheduled_scaling ? 1 : 0
  scheduled_action_name  = "scale-down-5pm-hkt-weekdays"
  autoscaling_group_name = module.github_runner_dynamic.runners.dynamic.autoscaling_group_name
  min_size               = 0
  max_size               = var.max_runners
  desired_capacity       = 0
  recurrence             = "0 9 * * MON-FRI" # 9 AM UTC = 5 PM HKT, Monday to Friday
  time_zone              = "Asia/Hong_Kong"
}

# Scale down to 0 on weekends (Saturday 00:00 HKT = Friday 16:00 UTC)
resource "aws_autoscaling_schedule" "scale_down_weekend_start" {
  count                  = var.enable_scheduled_scaling ? 1 : 0
  scheduled_action_name  = "scale-down-weekend-start"
  autoscaling_group_name = module.github_runner_dynamic.runners.dynamic.autoscaling_group_name
  min_size               = 0
  max_size               = var.max_runners
  desired_capacity       = 0
  recurrence             = "0 16 * * FRI" # Friday 4 PM UTC = Saturday 12 AM HKT
  time_zone              = "Asia/Hong_Kong"
}

# Scale up to 1 on Monday morning (Monday 9 AM HKT = Monday 1 AM UTC)
resource "aws_autoscaling_schedule" "scale_up_monday" {
  count                  = var.enable_scheduled_scaling ? 1 : 0
  scheduled_action_name  = "scale-up-monday-morning"
  autoscaling_group_name = module.github_runner_dynamic.runners.dynamic.autoscaling_group_name
  min_size               = 1
  max_size               = var.max_runners
  desired_capacity       = 1
  recurrence             = "0 1 * * MON" # Monday 1 AM UTC = Monday 9 AM HKT
  time_zone              = "Asia/Hong_Kong"
}

# CloudWatch Alarm for manual scaling trigger (optional)
# This allows easy scaling via AWS Console or CLI
resource "aws_cloudwatch_metric_alarm" "manual_scale_up" {
  count               = var.enable_manual_scaling_alarm ? 1 : 0
  alarm_name          = "${var.name_prefix}-manual-scale-up"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DesiredCapacity"
  namespace           = "AWS/AutoScaling"
  period              = 60
  statistic           = "Average"
  threshold           = var.manual_scale_threshold
  alarm_description   = "Trigger for manual scaling of GitHub runners"
  alarm_actions       = []

  dimensions = {
    AutoScalingGroupName = module.github_runner_dynamic.runners.dynamic.autoscaling_group_name
  }

  tags = var.tags
}

