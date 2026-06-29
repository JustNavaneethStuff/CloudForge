output "parameter_arns" {
  description = "Map of parameter keys to ARNs"
  value       = { for k, p in aws_ssm_parameter.config : k => p.arn }
}

output "parameter_names" {
  description = "Map of parameter keys to full SSM names"
  value       = { for k, p in aws_ssm_parameter.config : k => p.name }
}

output "parameter_arn_list" {
  description = "List of all parameter ARNs (for IAM policies)"
  value       = [for p in aws_ssm_parameter.config : p.arn]
}
