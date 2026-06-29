# Deployment Guide

## Prerequisites

1. AWS CLI configured for `ap-south-2`
2. Terraform >= 1.7
3. Docker Desktop running
4. GitHub repo with `dev`/`prod` environments and secrets configured

## First-Time Deployment

See [first-deploy.md](../runbooks/first-deploy.md) for the full checklist.

### Quick Path

```bash
# 1. Bootstrap remote state (once per AWS account)
make bootstrap

# 2. Configure backend
cd infrastructure/terraform/environments/dev
cp backend.hcl.example backend.hcl
# Fill in bucket/table from bootstrap outputs

# 3. Deploy infrastructure + application
make deploy ENV=dev

# 4. Verify
bash scripts/smoke-test.sh $(cd infrastructure/terraform/environments/dev && terraform output -raw api_url)
```

## Local Development

```bash
# App + Postgres + Redis
docker compose up -d

# Observability stack (separate terminal)
docker compose -f docker-compose.observability.yml up -d

# Run tests
make test
make lint
```

## CI/CD Deployment

### Automatic (CI)

On push to `main`:
1. Lint, type-check, pytest
2. pip-audit dependency scan
3. Docker build + Trivy scan
4. Push image to ECR

### Manual (CD)

GitHub Actions → **CD** workflow → Run workflow:
- Environment: `dev` or `prod`
- Image tag: `latest` or specific SHA

CD runs: Terraform apply → ECS force deploy → smoke test

## Terraform-Only Changes

```bash
make plan ENV=dev
make apply ENV=dev
```

## Rollback

```bash
bash scripts/rollback.sh dev <previous-image-tag>
```

Or rely on ECS deployment circuit breaker (automatic on failed health checks).

## Teardown

```bash
make destroy ENV=dev
```

For bootstrap teardown, temporarily remove `prevent_destroy` from [bootstrap/s3.tf](../../infrastructure/terraform/bootstrap/s3.tf) and set `force_destroy = true` on the state bucket. See [teardown.md](../runbooks/teardown.md).

## GitHub Secrets Required

| Secret | Description |
|--------|-------------|
| `AWS_ROLE_ARN` | GitHub OIDC deploy role |
| `TF_STATE_BUCKET` | Terraform state S3 bucket |
| `TF_LOCK_TABLE` | DynamoDB lock table |
| `AWS_ACCOUNT_ID` | AWS account ID |
