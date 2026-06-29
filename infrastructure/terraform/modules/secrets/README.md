# Secrets Module

Creates AWS Secrets Manager secrets for database credentials, Redis auth token, and app config.

## Key Inputs

- `db_username`, `db_name`

## Key Outputs

- `db_credentials_secret_arn`, `redis_auth_secret_arn`, `app_config_secret_arn`, `all_secret_arns`

## Note

Passwords and tokens belong in Secrets Manager, not Parameter Store.
