# ECS Module

Creates an ECS Fargate cluster, task definition, service, and optional autoscaling policies.

## Key Inputs

- `image_uri`, `cpu`, `memory`, `desired_count`
- `enable_autoscaling`, `min_capacity`, `max_capacity`
- `alb_arn_suffix`, `target_group_arn_suffix` (for request-count scaling)

## Key Outputs

- `cluster_name`, `service_name`, `task_definition_arn`

## Features

- Deployment circuit breaker with automatic rollback
- CPU, memory, and ALB request-count autoscaling
