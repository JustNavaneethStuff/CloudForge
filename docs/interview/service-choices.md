# Why Each AWS Service Was Chosen

## VPC + Subnets

**Why:** Foundation for network isolation. Public subnets for internet-facing resources; private subnets for compute and data.

**Alternatives considered:** Default VPC (no isolation), shared VPC across teams (blast radius).

## NAT Gateway

**Why:** ECS tasks in private subnets need outbound internet for ECR image pulls and package updates without public IPs.

**Alternatives:** NAT Instance (cheaper but operational burden), VPC endpoints only (no general internet).

## Application Load Balancer

**Why:** Layer 7 load balancing with health checks, path-based routing, TLS termination, and integration with ECS target groups.

**Alternatives:** NLB (L4 only, no path routing), API Gateway (higher cost for simple API proxy).

## ECS Fargate

**Why:** Serverless containers — no EC2 fleet management. Pay per task, fast scaling, integrates with ALB and IAM roles.

**Alternatives:** EKS (Kubernetes complexity), EC2-backed ECS (node management), Lambda (cold starts, 15-min limit).

## RDS PostgreSQL

**Why:** Managed relational database with automated backups, Multi-AZ failover, and Performance Insights.

**Alternatives:** Aurora (higher cost, better for scale), self-managed Postgres on EC2 (ops burden).

## ElastiCache Redis

**Why:** Managed in-memory cache with encryption, auth, and automatic failover in multi-node mode.

**Alternatives:** DynamoDB DAX (different use case), self-managed Redis (ops burden).

## Secrets Manager

**Why:** Purpose-built for credentials with rotation support and fine-grained IAM access.

**Alternatives:** Parameter Store SecureString (cheaper but no automatic rotation UI).

## SSM Parameter Store

**Why:** Non-secret configuration at scale with hierarchical paths and no per-secret cost for standard parameters.

**Alternatives:** Environment variables only (no central management), Secrets Manager for everything (unnecessary cost).

## S3

**Why:** Durable object storage for Terraform state, app artifacts, and static assets. Versioning for state recovery.

**Alternatives:** Terraform Cloud remote state (vendor lock-in cost), local state (no team collaboration).

## CloudWatch

**Why:** Native AWS observability — logs, metrics, alarms, dashboards. Zero integration overhead.

**Alternatives:** Datadog/New Relic (richer features, per-host cost), Prometheus on ECS (self-managed).

## IAM + OIDC

**Why:** Least-privilege roles per service. GitHub OIDC eliminates long-lived AWS access keys in CI/CD.

**Alternatives:** IAM user with access keys (security risk), instance profiles (not applicable to Fargate CI).

## Route53 + ACM

**Why:** DNS management with alias records to ALB; free TLS certificates with automatic renewal.

**Alternatives:** External DNS (Cloudflare) + import cert to ACM, self-signed (not for production).
