output "db_credentials_secret_arn" {
  description = "ARN of the database credentials secret"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "redis_auth_secret_arn" {
  description = "ARN of the Redis auth secret"
  value       = aws_secretsmanager_secret.redis_auth.arn
}

output "app_config_secret_arn" {
  description = "ARN of the app config secret"
  value       = aws_secretsmanager_secret.app_config.arn
}

output "db_password" {
  description = "Generated database password (sensitive)"
  value       = random_password.db_password.result
  sensitive   = true
}

output "db_username" {
  description = "Database username"
  value       = var.db_username
}

output "db_name" {
  description = "Database name"
  value       = var.db_name
}

output "redis_auth_token" {
  description = "Redis auth token (sensitive)"
  value       = random_password.redis_auth_token.result
  sensitive   = true
}

output "all_secret_arns" {
  description = "All secret ARNs for IAM policies"
  value = [
    aws_secretsmanager_secret.db_credentials.arn,
    aws_secretsmanager_secret.redis_auth.arn,
    aws_secretsmanager_secret.app_config.arn,
  ]
}
