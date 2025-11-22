output "dynamic_runners_autoscaling_group_name" {
  description = "Name of the Auto Scaling Group for dynamic runners"
  value       = try(module.github_runner_dynamic.runners.dynamic.autoscaling_group_name, null)
}

output "standby_runners_autoscaling_group_name" {
  description = "Name of the Auto Scaling Group for standby runners"
  value       = try(module.github_runner_standby.runners.standby.autoscaling_group_name, null)
}

output "dynamic_runners_autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group for dynamic runners"
  value       = try(module.github_runner_dynamic.runners.dynamic.autoscaling_group_arn, null)
}

output "standby_runners_autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group for standby runners"
  value       = try(module.github_runner_standby.runners.standby.autoscaling_group_arn, null)
}

output "dynamic_runner_queues" {
  description = "SQS queues for dynamic runner management"
  value       = module.github_runner_dynamic.queues
}

output "standby_runner_queues" {
  description = "SQS queues for standby runner management"
  value       = module.github_runner_standby.queues
}

output "webhook_url" {
  description = "Webhook URL for runner management (if enabled)"
  value       = try(module.github_runner_dynamic.webhook.url, null)
}

output "webhook_secret_arn" {
  description = "ARN of the webhook secret in Secrets Manager"
  value       = try(module.github_runner_dynamic.webhook.secret_arn, null)
}

output "dynamic_ssm_parameters" {
  description = "SSM parameters for dynamic runner configuration"
  value       = module.github_runner_dynamic.ssm_parameters
}

output "standby_ssm_parameters" {
  description = "SSM parameters for standby runner configuration"
  value       = module.github_runner_standby.ssm_parameters
}

output "dynamic_runner_iam_role_arn" {
  description = "IAM role ARN for dynamic runners"
  value       = try(module.github_runner_dynamic.runners.dynamic.iam_role_arn, null)
}

output "standby_runner_iam_role_arn" {
  description = "IAM role ARN for standby runners"
  value       = try(module.github_runner_standby.runners.standby.iam_role_arn, null)
}

output "dynamic_runner_security_group_id" {
  description = "Security group ID for dynamic runners"
  value       = try(module.github_runner_dynamic.runners.dynamic.security_group_id, null)
}

output "standby_runner_security_group_id" {
  description = "Security group ID for standby runners"
  value       = try(module.github_runner_standby.runners.standby.security_group_id, null)
}

