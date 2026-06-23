# Incident Response

## ALB 5xx Errors

**Alarm:** `cloudforge-{env}-alb-5xx`

1. Check CloudWatch dashboard for error spike timing
2. Review ECS service events for failed deployments
3. Check application logs: `/ecs/cloudforge-{env}`
4. Verify RDS and Redis connectivity via `/ready` endpoint
5. Roll back if correlated with recent deployment

## Unhealthy Targets

**Alarm:** `cloudforge-{env}-unhealthy-hosts`

1. Check target group health in EC2 → Target Groups
2. Verify security group rules (ALB → ECS on port 8000)
3. Check ECS task logs for startup errors
4. Confirm Secrets Manager values are accessible

## ECS Task Count Low

**Alarm:** `cloudforge-{env}-ecs-task-count`

1. Check ECS service events for placement failures
2. Verify subnet IP capacity
3. Check Fargate service quotas
4. Review recent task definition changes

## RDS Free Storage Low

**Alarm:** `cloudforge-{env}-rds-free-storage`

1. Check RDS storage autoscaling settings
2. Review large table growth or log bloat
3. Increase `allocated_storage` via Terraform if needed

## Escalation

| Severity | Response Time | Action |
|----------|--------------|--------|
| dev down | Best effort | Rollback or restart service |
| prod degraded | 30 min | Rollback, investigate root cause |
| prod down | 15 min | Rollback immediately, postmortem |
