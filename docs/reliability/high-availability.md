# High Availability

## Architecture HA Features

| Component | Dev | Prod |
|-----------|-----|------|
| VPC | 2 AZs | 2 AZs |
| NAT Gateway | 1 (single AZ risk) | 2 (one per AZ) |
| ALB | Multi-AZ by default | Multi-AZ |
| ECS Fargate | 1 task | 2+ tasks across AZs |
| RDS | Single-AZ | Multi-AZ failover |
| Redis | Single node | Multi-node with failover |

## Automatic Recovery

- **ECS:** Deployment circuit breaker rolls back failed deployments
- **ALB health checks:** Unhealthy tasks removed from target group
- **ECS container health check:** `/health` endpoint every 30s
- **RDS Multi-AZ (prod):** Automatic failover to standby (~60–120s)

## Health Check Layers

1. **Liveness** (`/health`) — process is running; used by Docker and ECS
2. **Readiness** (`/ready`) — DB and Redis connectivity; returns 503 if degraded
3. **ALB target group** — HTTP health check on `/health`

## Autoscaling

ECS Application Auto Scaling with three policies:

- CPU utilization target: 70%
- Memory utilization target: 75%
- ALB requests per target: 1000 req/min

Scale-out cooldown: 60s. Scale-in cooldown: 300s (prevents flapping).

## Failure Scenarios

| Failure | Impact | Mitigation |
|---------|--------|------------|
| Single ECS task crash | Brief 5xx | ALB routes to healthy tasks; ECS replaces task |
| AZ outage (dev) | Partial outage if NAT in affected AZ | Prod uses NAT per AZ |
| RDS failure (prod) | ~60s failover | Multi-AZ automatic failover |
| Redis node failure | Cache miss spike | Multi-node with automatic failover (prod) |

## Drift Detection

Weekly scheduled `terraform plan` detects infrastructure drift. Drift issues are opened automatically in GitHub.
