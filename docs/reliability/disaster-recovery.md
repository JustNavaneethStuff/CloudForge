# Disaster Recovery Strategy

## Recovery Objectives

| Metric | Dev | Prod |
|--------|-----|------|
| RPO (Recovery Point Objective) | 24 hours | 1 hour |
| RTO (Recovery Time Objective) | 4 hours | 1 hour |

## Data Protection

### RDS PostgreSQL

- Automated daily backups with configurable retention (dev: 1 day, prod: 7+ days)
- Point-in-time recovery (PITR) within backup retention window
- Final snapshot on deletion when `skip_final_snapshot = false` (prod)

**Recovery procedure:**
1. Identify recovery timestamp from CloudWatch/monitoring
2. Restore RDS from snapshot or PITR to new instance
3. Update ECS task environment (`DB_HOST`) via Terraform or SSM
4. Force ECS redeployment

### ElastiCache Redis

- Daily snapshots (`snapshot_retention_limit = 1` dev, increase for prod)
- Redis is a cache — application must tolerate cache loss; rebuild from DB

### Terraform State

- S3 versioning enabled on state bucket
- DynamoDB locking prevents concurrent corruption
- State bucket has `prevent_destroy` lifecycle guard

### Application Artifacts

- Docker images in ECR with lifecycle policy (keep last 10)
- S3 app bucket versioning for uploaded artifacts

## Regional Failure

CloudForge is single-region (`ap-south-2`). For multi-region DR:

1. Replicate Terraform state to secondary region S3 (CRR)
2. Maintain ECR image replication or rebuild from CI
3. Deploy prod stack to secondary region with Route53 failover routing
4. RDS cross-region read replica or snapshot copy

**Tradeoff:** Multi-region DR doubles infrastructure cost; justified for strict SLA requirements.

## Runbook Reference

See [incident-response.md](../runbooks/incident-response.md) and [rollback.md](../runbooks/rollback.md).
