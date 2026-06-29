# Monitoring Module

Creates CloudWatch dashboard, SNS topic, and alarms for ALB, ECS, and RDS.

## Key Inputs

- `alert_email`, `log_group_name`
- `alb_arn_suffix`, `target_group_arn_suffix`
- `ecs_cluster_name`, `ecs_service_name`, `rds_instance_id`

## Key Outputs

- `sns_topic_arn`, `dashboard_name`
