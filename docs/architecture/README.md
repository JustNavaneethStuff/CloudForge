# CloudForge Architecture Documentation

This directory contains per-service explanations, design decisions, and tradeoffs for each implementation phase.

## Index

| Document | Phase | Services |
|----------|-------|----------|
| [01-remote-state.md](01-remote-state.md) | 1 | S3, DynamoDB |
| [02-networking.md](02-networking.md) | 2 | VPC, Subnets, NAT, IGW |
| [03-security-iam.md](03-security-iam.md) | 3 | Security Groups, IAM, OIDC |
| [04-data-layer.md](04-data-layer.md) | 4 | Secrets Manager, RDS, ElastiCache |
| [05-compute.md](05-compute.md) | 5 | ECR, ECS Fargate, ALB |
| [06-application.md](06-application.md) | 6 | FastAPI, Docker |
| [07-monitoring.md](07-monitoring.md) | 7 | CloudWatch |
| [08-cicd.md](08-cicd.md) | 8 | GitHub Actions |
| [09-https.md](09-https.md) | 9 | Route53, ACM |
