# CloudForge Security Model

## Defense in Depth

CloudForge applies layered security controls across identity, network, data, and runtime.

## Identity and Access (IAM)

| Role | Purpose | Permissions |
|------|---------|-------------|
| ECS task execution | Pull images, write logs, read secrets/SSM | Scoped to specific ARNs |
| ECS task | Application runtime | S3 app bucket read/write only |
| GitHub Actions OIDC | CI/CD deploy | ECR push, ECS update, Terraform state — no static keys |

**Least privilege:** GitHub OIDC role uses `Condition` blocks on ECS cluster ARN prefix. Secrets and SSM parameters are enumerated by ARN, not `*`.

## Secrets vs Configuration

| Store | Use Case | Examples |
|-------|----------|----------|
| **Secrets Manager** | Rotating credentials, sensitive values | DB password, Redis auth token |
| **Parameter Store** | Non-secret config | `log_level`, `metrics_enabled`, bucket name |

## Encryption

| Resource | At Rest | In Transit |
|----------|---------|------------|
| RDS PostgreSQL | AES-256 (`storage_encrypted`) | TLS within VPC |
| ElastiCache Redis | Enabled | TLS + auth token |
| S3 (state + app) | SSE-S3 (AES256) | HTTPS via AWS APIs |
| ALB | N/A | TLS 1.2+ when HTTPS enabled (ACM) |

### KMS CMK (optional upgrade)

Default encryption uses AWS-managed keys (SSE-S3, RDS default). For compliance requirements, upgrade to customer-managed KMS keys:

- S3 bucket: `aws:kms` with dedicated CMK
- RDS: `kms_key_id` parameter
- Secrets Manager: `kms_key_id` on secrets

Tradeoff: CMKs add ~$1/key/month and require IAM key policies; use when audit/compliance mandates customer key control.

## Network Isolation

```
Internet → ALB (public subnets) → ECS (private subnets) → RDS/Redis (private subnets)
```

- Security groups enforce tier-to-tier access only (ALB→ECS→data)
- No public IPs on ECS tasks
- RDS and Redis are not publicly accessible

## Container Security

- Multi-stage Docker builds with non-root `appuser`
- Trivy scans on every CI build (CRITICAL/HIGH fail the pipeline)
- `pip-audit` for Python dependency vulnerabilities
- ECR image scanning on push

## TLS

- HTTP by default in dev (ALB port 80)
- HTTPS via ACM + Route53 when `enable_https = true`
- Redis transit encryption enabled in AWS

## Monitoring and Audit

- CloudWatch logs for ECS tasks
- CloudWatch alarms on ALB 5xx, ECS CPU, RDS connections
- Scheduled drift detection workflow opens GitHub issues on configuration drift

## Compliance Posture Summary

| Control | Status |
|---------|--------|
| Encryption at rest | Enabled |
| Encryption in transit | ALB HTTPS optional; Redis TLS |
| Least privilege IAM | Scoped policies |
| Secret management | Secrets Manager |
| Vulnerability scanning | Trivy + pip-audit + Dependabot |
| Network segmentation | VPC + security groups |
