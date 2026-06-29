# Cost Considerations

## Monthly Estimates (ap-south-2)

| Environment | Estimated Cost | Primary Drivers |
|-------------|---------------|-----------------|
| dev | $80–120 | NAT Gateway, ALB, RDS, ElastiCache |
| prod | $200–350 | 2× NAT, Multi-AZ RDS, 2+ ECS tasks |

## Cost Breakdown by Service

### Always-On Costs (even when idle)

- **NAT Gateway:** ~$0.045/hr + data processing (~$35/mo per gateway)
- **ALB:** ~$0.0225/hr + LCU charges (~$20/mo)
- **RDS:** Instance hours (~$12–50/mo depending on class)
- **ElastiCache:** Node hours (~$12–25/mo)

### Usage-Based Costs

- **ECS Fargate:** vCPU + memory per task-hour
- **CloudWatch:** Log ingestion and storage
- **S3:** Storage + requests (minimal for state)
- **Data transfer:** NAT processing, cross-AZ traffic

## Cost Optimization Applied

1. **Graviton instances** (t4g) — 20% cheaper than t3
2. **Dev sizing** — single NAT, single ECS task, micro instances
3. **Log retention** — 7 days dev, 30 days prod
4. **ECR lifecycle** — expire images beyond last 10
5. **Destroy when idle** — `make destroy ENV=dev`

## Free Tier Considerations

- RDS backup retention limited to 1 day on Free Tier accounts
- t4g.micro eligible for Free Tier (750 hrs/mo)
- NAT Gateway and ALB are NOT Free Tier — largest dev costs

## Cost vs Reliability Tradeoffs

| Decision | Cost Impact | Reliability Impact |
|----------|-------------|-------------------|
| Single NAT (dev) | -$35/mo | AZ outage breaks outbound |
| Multi-AZ RDS (prod) | +$12–25/mo | Automatic DB failover |
| Autoscaling max=4 (dev) | Caps spike cost | May throttle under extreme load |
| VPC endpoints | +$7/endpoint/mo | Reduces NAT data processing |

## How I'd Answer in an Interview

> "I sized dev for cost — single NAT, one Fargate task, micro instances — because it's a demo environment destroyed when not in use. Prod adds Multi-AZ RDS, NAT per AZ, and autoscaling with conservative limits. The biggest fixed cost is NAT Gateway; VPC endpoints for ECR and S3 would be my first optimization at scale."
