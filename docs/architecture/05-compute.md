# Compute Layer

## Services

### Amazon ECR (Elastic Container Registry)

Private Docker image registry. Images are scanned on push and lifecycle policies prune old tags.

**Tradeoff:** ECR vs Docker Hub — ECR integrates natively with ECS and IAM, no rate limits.

### Amazon ECS Fargate

Runs containers without managing EC2 instances. Tasks run in `awsvpc` mode in private subnets.

**Tradeoff:**
| Fargate | EC2 launch type |
|---------|-----------------|
| Zero server ops | Lower cost at scale |
| Per-task pricing | You patch AMIs |

CloudForge uses Fargate with **deployment circuit breaker** for automatic rollback on failed deploys.

### Application Load Balancer

Layer 7 load balancer with health checks, path-based routing, and TLS termination (Phase 9).

**Tradeoff:** ALB vs NLB — ALB understands HTTP and supports health check paths like `/health`.

## Deployment Flow

```
ECR image → Task Definition → ECS Service → ALB Target Group → Users
```
