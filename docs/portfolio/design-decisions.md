# CloudForge — Design Decisions

## Architecture

CloudForge implements a **three-tier AWS architecture**:

```
Internet → ALB (public) → ECS Fargate (private) → RDS + Redis (private)
```

This pattern is the industry standard for containerized APIs requiring network isolation and horizontal scaling.

## Key Decisions

### ECS Fargate over EC2

**Decision:** Use Fargate launch type.

**Rationale:** Eliminates EC2 patching, AMI management, and capacity planning. The per-task cost premium is acceptable for a portfolio project demonstrating modern container operations.

**Alternative considered:** EC2 with managed node groups — lower cost at scale but higher operational burden.

### RDS PostgreSQL over Aurora

**Decision:** Standard RDS PostgreSQL 16.

**Rationale:** Simpler, cheaper at small scale, sufficient for demonstrating managed database patterns. Aurora adds value at high throughput — not needed here.

### ElastiCache over containerized Redis

**Decision:** Managed ElastiCache Redis 7.

**Rationale:** Demonstrates proper separation of stateful services. Container Redis would couple cache lifecycle to app deployments.

### Single NAT in dev, dual NAT in prod

**Decision:** Cost-optimize dev; HA in prod.

**Rationale:** NAT Gateways are ~$32/month each. Dev tolerates single-AZ NAT failure; prod requires AZ fault tolerance.

### GitHub OIDC over IAM access keys

**Decision:** Federated identity for CI/CD.

**Rationale:** No long-lived credentials in GitHub Secrets. Trust policy scoped to repository. Industry best practice since 2022.

### HTTP first, HTTPS phased

**Decision:** Deploy with ALB HTTP; add Route53/ACM when domain is available.

**Rationale:** ACM requires domain validation. Phased approach allows full infrastructure demo without domain purchase.

### ECS circuit breaker over CodeDeploy blue/green

**Decision:** Rolling deploy with circuit breaker.

**Rationale:** Simpler, built into ECS, sufficient for portfolio. Blue/green adds complexity (second target group, CodeDeploy app) for marginal benefit at this scale.

## Environment Separation

| Aspect | Implementation |
|--------|---------------|
| Network | Separate VPCs (`10.0.0.0/16` dev, `10.1.0.0/16` prod) |
| State | Separate S3 keys per environment |
| Compute | Scaled-down dev, HA prod |
| CI/CD | GitHub Environments with prod approval gate |

## Tagging Strategy

All resources tagged: `Project=CloudForge`, `Environment={env}`, `ManagedBy=Terraform`.

Enables cost allocation, automation, and compliance reporting.
