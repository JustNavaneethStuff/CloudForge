# Failure Scenarios

## Scenario 1: ECS Task Fails Health Check

**Detection:** ALB marks target unhealthy; CloudWatch alarm on unhealthy host count.

**Impact:** Reduced capacity; users may see 5xx if all tasks unhealthy.

**Response:**
1. Check ECS service events and CloudWatch logs
2. If bad deployment → ECS circuit breaker auto-rolls back
3. Manual rollback: `scripts/rollback.sh dev <previous-tag>`

**Prevention:** Smoke tests in CD pipeline; circuit breaker enabled.

## Scenario 2: RDS Instance Failure (Prod Multi-AZ)

**Detection:** CloudWatch RDS event; `/ready` returns 503.

**Impact:** ~60–120 second failover; brief connection errors.

**Response:**
1. Wait for automatic Multi-AZ failover
2. ECS tasks reconnect via SQLAlchemy connection pool
3. If failover fails → restore from latest snapshot

## Scenario 3: Redis Cache Unavailable

**Detection:** `/ready` shows redis check failed; elevated DB load.

**Impact:** Degraded performance (cache miss), not data loss.

**Response:**
1. Check ElastiCache events
2. For single-node dev: restart or recreate cluster
3. For prod multi-node: automatic failover should handle

## Scenario 4: NAT Gateway Failure (Dev)

**Detection:** ECS tasks cannot pull images or reach external APIs.

**Impact:** New task launches fail; existing tasks may work until restart.

**Response:**
1. Verify NAT Gateway status in VPC console
2. Short-term: temporarily enable public IP on ECS (not recommended)
3. Long-term: add NAT per AZ (prod pattern)

## Scenario 5: Terraform State Corruption

**Detection:** `terraform plan` errors; state file mismatch.

**Impact:** Cannot safely apply infrastructure changes.

**Response:**
1. Restore previous state version from S3 versioning
2. Run `terraform plan` to verify restored state
3. Never manually edit state without backup

## Scenario 6: Secrets Leaked

**Detection:** Security scan, audit, or accidental commit.

**Impact:** Unauthorized database/cache access.

**Response:**
1. Rotate credentials in Secrets Manager
2. Force ECS redeployment to pick up new secrets
3. Audit IAM access logs
4. Revoke and reissue any exposed tokens

## Scenario 7: Infrastructure Drift

**Detection:** Scheduled drift workflow or manual `terraform plan` shows changes.

**Impact:** Terraform state no longer matches reality.

**Response:**
1. Review drift in plan output
2. If intentional console change → import or revert manually
3. If unauthorized → investigate IAM access, revert changes

## Scenario 8: DDoS / Traffic Spike

**Detection:** ALB request count spike; autoscaling adds tasks.

**Impact:** Increased cost; potential service degradation if scaling limits hit.

**Response:**
1. ECS autoscaling handles moderate spikes
2. Enable AWS WAF on ALB for L7 protection
3. Set max capacity limits to cap cost exposure
