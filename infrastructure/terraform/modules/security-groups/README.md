# Security Groups Module

Creates tiered security groups for ALB, ECS, RDS, and Redis with least-privilege ingress rules.

## Key Inputs

- `vpc_id`, `app_port`, `enable_https`

## Key Outputs

- `alb_security_group_id`, `ecs_security_group_id`, `rds_security_group_id`, `redis_security_group_id`
