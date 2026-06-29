# ALB Module

Creates an Application Load Balancer with HTTP/HTTPS listeners and target group health checks.

## Key Inputs

- `subnet_ids`, `security_group_ids`, `app_port`
- `enable_https`, `certificate_arn`

## Key Outputs

- `alb_dns_name`, `target_group_arn`, `alb_arn_suffix`, `target_group_arn_suffix`
