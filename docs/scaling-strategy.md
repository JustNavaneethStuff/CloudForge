# Scaling Strategy

## Horizontal Scaling (ECS)

Primary scaling mechanism. ECS Application Auto Scaling adjusts task count based on:

| Policy | Metric | Target | When to Tune |
|--------|--------|--------|--------------|
| CPU | `ECSServiceAverageCPUUtilization` | 70% | CPU-bound workloads (serialization, crypto) |
| Memory | `ECSServiceAverageMemoryUtilization` | 75% | Memory-bound (caching in-process) |
| Requests | `ALBRequestCountPerTarget` | 1000/min | API-heavy, low CPU per request |

**Cooldowns:** Scale-out 60s, scale-in 300s — prevents thrashing during traffic spikes.

### Capacity Limits

| Environment | Min | Max | Desired |
|-------------|-----|-----|---------|
| dev | 1 | 4 | 1 |
| prod | 2 | 10 | 2 |

## Vertical Scaling

### ECS Task Size

Increase `ecs_cpu` and `ecs_memory` in Terraform variables when:
- Tasks consistently hit CPU/memory limits before autoscaling kicks in
- Latency increases despite low request count

### RDS

- Change `rds_instance_class` (e.g., `db.t4g.micro` → `db.t4g.small`)
- Storage auto-scales via `max_allocated_storage`

### Redis

- Increase `redis_node_type` for more memory
- Add `redis_num_nodes` for read replicas and HA

## When to Scale What

| Symptom | Scale |
|---------|-------|
| High ALB 5xx, healthy tasks low | ECS tasks (horizontal) |
| High ECS CPU across all tasks | ECS tasks or task size |
| High ECS memory, OOM kills | Task memory or horizontal |
| High RDS connections/CPU | RDS instance class |
| Redis evictions | Redis node type or nodes |

## Cost-Aware Scaling

- Dev: autoscaling disabled by default (`ecs_enable_autoscaling = false`)
- Prod: enable autoscaling with conservative max capacity
- Use CloudWatch alarms as early warning before auto scaling limits

## Future: Queue-Based Scaling

For async workloads, add SQS + scale on `ApproximateNumberOfMessagesVisible` instead of ALB request count.
