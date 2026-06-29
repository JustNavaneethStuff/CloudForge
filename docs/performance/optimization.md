# Performance and Cost Analysis

## Infrastructure Costs (ap-south-2)

| Service | Dev (monthly) | Prod (monthly) | Optimization |
|---------|---------------|----------------|--------------|
| NAT Gateway | ~$35 | ~$70 (×2) | VPC endpoints reduce data processing |
| ECS Fargate | ~$15 | ~$60 | Right-size CPU/memory; Fargate Spot for non-critical |
| RDS | ~$15 | ~$50 | Graviton (t4g) instances; reserved instances |
| ElastiCache | ~$12 | ~$25 | Right-size node type |
| ALB | ~$20 | ~$25 | Shared ALB for multiple services |
| CloudWatch | ~$5 | ~$15 | Log retention tuning |
| **Total** | **~$80–120** | **~$200–350** | |

## Resource Utilization

| Resource | Dev Setting | Prod Setting | Scaling Trigger |
|----------|-------------|--------------|-----------------|
| ECS CPU | 256 units | 512 units | CPU > 70% |
| ECS Memory | 512 MB | 1024 MB | Memory > 75% |
| RDS | db.t4g.micro | db.t4g.small | Connections, CPU alarms |
| Redis | cache.t4g.micro | cache.t4g.small | Evictions, memory |

## Scaling Behavior

1. **Horizontal (ECS):** Auto Scaling adds tasks based on CPU, memory, or request count
2. **Vertical (RDS):** Manual instance class change via Terraform; storage auto-scales (gp3)
3. **Cache (Redis):** Add nodes for read scaling; increase node type for memory

## Deployment Speed

| Stage | Typical Duration |
|-------|-----------------|
| Docker build + Trivy | 2–3 min |
| ECR push | 1–2 min |
| Terraform apply (no changes) | 30s |
| ECS rolling deploy | 3–5 min |
| **Total** | **~7–10 min** |

Optimizations: layer caching in Docker, `terraform plan` only on changed modules, parallel CI jobs.

## Optimization Opportunities

1. **Fargate Spot** — up to 70% savings for fault-tolerant workloads
2. **Graviton (ARM)** — already using t4g instances; ensure Docker multi-arch builds
3. **Image slimming** — multi-stage builds, pinned slim base images (~150MB vs ~900MB)
4. **VPC endpoints** — eliminate NAT data processing for ECR/S3/Secrets Manager
5. **Log retention** — dev: 7 days, prod: 30 days (already configured)
6. **ECR lifecycle** — keep last 10 images (configured)
7. **RDS backup retention** — dev: 1 day minimum for Free Tier compatibility

## Local Observability (zero AWS cost)

Prometheus + Grafana + Tempo run via `docker-compose.observability.yml` for development metrics and tracing without managed observability charges.
