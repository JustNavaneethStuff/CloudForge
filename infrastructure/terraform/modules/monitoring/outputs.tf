output "log_group_name" {
  description = "ECS CloudWatch log group name (provided as input)"
  value       = var.log_group_name
}

output "sns_topic_arn" {
  description = "SNS alerts topic ARN"
  value       = try(aws_sns_topic.alerts[0].arn, "")
}

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}
