# Security Posture

## Network Security

| Control | Implementation |
|---------|---------------|
| Network isolation | 3-tier VPC with public/private subnets |
| No public IPs on workloads | ECS tasks in private subnets |
| Stateful firewall | Security groups: ALB→ECS→RDS/Redis only |
| Data layer isolation | RDS and Redis not publicly accessible |

## Identity and Access

| Control | Implementation |
|---------|---------------|
| Least privilege IAM | Separate ECS execution/task roles |
| No long-lived CI keys | GitHub OIDC federation |
| Scoped trust policy | Repository and branch conditions |
| No admin on deploy role | Targeted ECR, ECS, S3, DynamoDB permissions |

## Data Protection

| Control | Implementation |
|---------|---------------|
| Encryption at rest | RDS, ElastiCache, S3 state, ECR |
| Secrets management | AWS Secrets Manager (not env files) |
| TLS in transit | Redis transit encryption; HTTPS when enabled |
| State file encryption | S3 SSE + versioning |

## Application Security

| Control | Implementation |
|---------|---------------|
| Non-root container | `appuser` in Dockerfile |
| Image scanning | ECR scan on push + Trivy in CI |
| Health check isolation | Liveness vs readiness separation |
| Structured logging | JSON logs, no credential leakage |

## Operational Security

| Control | Implementation |
|---------|---------------|
| Deletion protection | RDS prod |
| Backup retention | 7d dev / 30d prod |
| Alarm on 5xx | CloudWatch → SNS |
| Auto rollback | ECS deployment circuit breaker |

## Compliance Matrix

| Requirement | Status |
|-------------|--------|
| Encryption at rest | Implemented |
| Encryption in transit | Partial (HTTPS phased) |
| Least privilege IAM | Implemented |
| Audit logging | CloudWatch Logs |
| Secret rotation ready | Secrets Manager (manual rotation) |
| Network segmentation | Implemented |

## Future Enhancements

- AWS WAF on ALB
- Secrets auto-rotation for RDS
- VPC Flow Logs
- GuardDuty enablement
- HSTS header on HTTPS
