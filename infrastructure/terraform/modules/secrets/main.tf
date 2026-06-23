resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "redis_auth_token" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.name_prefix}/db-credentials"
  description             = "RDS PostgreSQL credentials for CloudForge"
  recovery_window_in_days = 7

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    dbname   = var.db_name
  })
}

resource "aws_secretsmanager_secret" "redis_auth" {
  name                    = "${var.name_prefix}/redis-auth"
  description             = "ElastiCache Redis auth token for CloudForge"
  recovery_window_in_days = 7

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "redis_auth" {
  secret_id = aws_secretsmanager_secret.redis_auth.id

  secret_string = jsonencode({
    auth_token = random_password.redis_auth_token.result
  })
}

resource "aws_secretsmanager_secret" "app_config" {
  name                    = "${var.name_prefix}/app-config"
  description             = "Application configuration secrets for CloudForge"
  recovery_window_in_days = 7

  tags = var.tags
}
