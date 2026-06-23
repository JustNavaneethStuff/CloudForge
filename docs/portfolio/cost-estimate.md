# Cost Estimate

Monthly AWS costs for CloudForge at minimal sizing (us-east-1). Actual costs vary by usage.

## Development Environment

| Service | Configuration | Est. Monthly |
|---------|--------------|-------------|
| NAT Gateway | 1 × $0.045/hr + data | ~$35 |
| ECS Fargate | 1 task, 0.25 vCPU, 512 MB | ~$10 |
| ALB | 1 load balancer | ~$18 |
| RDS PostgreSQL | db.t4g.micro, 20 GB | ~$15 |
| ElastiCache Redis | cache.t4g.micro | ~$12 |
| CloudWatch | Logs + alarms | ~$5 |
| Secrets Manager | 3 secrets | ~$1.20 |
| ECR | Image storage | ~$1 |
| S3 (state) | Minimal | ~$1 |
| **Total** | | **~$98/month** |

## Production Environment

| Service | Configuration | Est. Monthly |
|---------|--------------|-------------|
| NAT Gateway | 2 × $0.045/hr + data | ~$70 |
| ECS Fargate | 2 tasks, 0.5 vCPU, 1 GB | ~$40 |
| ALB | 1 load balancer | ~$18 |
| RDS PostgreSQL | db.t4g.small, Multi-AZ, 20 GB | ~$55 |
| ElastiCache Redis | cache.t4g.small | ~$25 |
| CloudWatch | Logs + alarms | ~$10 |
| Secrets Manager | 3 secrets | ~$1.20 |
| Route53 | 1 hosted zone (if HTTPS) | ~$0.50 |
| VPC Endpoints | S3 + ECR (interface) | ~$15 |
| **Total** | | **~$235/month** |

## Cost Controls

- Run `make destroy ENV=dev` when not actively developing
- Use Fargate Spot for dev (future enhancement)
- Set CloudWatch log retention to 7 days in dev
- Review AWS Cost Explorer with `Project=CloudForge` tag filter
