# Scaling Strategy (Interview Guide)

## Current Implementation

Three ECS autoscaling policies running concurrently:

1. **CPU target tracking** — 70% average CPU across service
2. **Memory target tracking** — 75% average memory
3. **ALB request count** — 1000 requests per target per minute

## How I'd Explain It in an Interview

> "We use horizontal scaling on ECS Fargate with target-tracking policies. CPU and memory policies handle compute-bound and memory-bound growth. The ALB request-count policy handles traffic spikes where per-request CPU is low — like a high-throughput API serving cached responses. Scale-out is aggressive (60s cooldown) to handle bursts; scale-in is conservative (300s) to prevent flapping."

## Scaling Decision Tree

```
Traffic increasing?
├── ALB request count high, CPU low → ALB scaling policy
├── CPU high across tasks → CPU policy or increase task size
├── Memory high / OOM → Memory policy or increase task memory
├── DB connections maxed → Scale RDS vertically or add RDS Proxy
└── Redis evictions → Increase Redis node type or add replicas
```

## Prod vs Dev

- **Dev:** Fixed 1 task, autoscaling off — minimizes cost
- **Prod:** 2+ tasks, autoscaling on, Multi-AZ data tier

## Metrics I'd Watch

| Metric | Alarm Threshold | Action |
|--------|----------------|--------|
| ALB TargetResponseTime | p95 > 2s | Scale ECS |
| ECS CPUUtilization | > 80% sustained | Scale ECS |
| RDS DatabaseConnections | > 80% max | RDS Proxy or larger instance |
| ElastiCache Evictions | > 0 sustained | Larger node |

## Advanced: Predictive Scaling

For known traffic patterns (e.g., business hours), add scheduled scaling actions:

```hcl
resource "aws_appautoscaling_scheduled_action" "scale_up" {
  schedule = "cron(0 8 * * MON-FRI)"
  scalable_target_action { min_capacity = 4, max_capacity = 20 }
}
```

Not implemented in CloudForge — documented as prod enhancement.
