# IAM Module

Creates ECS task execution/task roles and optional GitHub Actions OIDC deploy role.

## Key Inputs

- `secrets_arns`, `ecr_repository_arn`, `log_group_arn`
- `enable_github_oidc`, `github_org`, `github_repo`
- `ssm_parameter_arns`, `s3_bucket_arn` (optional)

## Key Outputs

- `ecs_task_execution_role_arn`, `ecs_task_role_arn`, `github_actions_role_arn`
