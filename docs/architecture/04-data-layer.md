# Data Layer

## Services

### AWS Secrets Manager

Stores and rotates sensitive values (database credentials, Redis auth tokens). ECS task definitions reference secrets by ARN — values never appear in plaintext.

**Tradeoff:** Secrets Manager (~$0.40/secret/mo) vs SSM Parameter Store (cheaper, no native RDS rotation integration).

### Amazon RDS (PostgreSQL)

Managed relational database with automated backups, patching, and Multi-AZ failover (prod).

**Tradeoff:** RDS vs Aurora — RDS PostgreSQL is simpler and cheaper at portfolio scale; Aurora adds serverless scaling at higher cost.

### Amazon ElastiCache (Redis)

Managed in-memory cache for sessions, rate limiting, or response caching.

**Tradeoff:** ElastiCache vs containerized Redis — managed service provides patching, snapshots, and subnet isolation.

## Network Isolation

RDS and Redis live in **private subnets** with security groups allowing only ECS ingress. No public accessibility.

## Credential Flow

```
Terraform → random_password → Secrets Manager
ECS Task Definition → secrets block → container env vars
FastAPI → reads DATABASE_URL, REDIS_URL from environment
```
