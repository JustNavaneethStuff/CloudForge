# Rollback Runbook

## Application Rollback

### Option 1: Script (recommended)

```bash
# List available image tags
./scripts/rollback.sh dev

# Rollback to specific tag
./scripts/rollback.sh dev abc1234
```

### Option 2: ECS Console

1. Open ECS → Clusters → `cloudforge-dev-cluster`
2. Select service → Update → Revision → select previous task definition
3. Check "Force new deployment"

### Option 3: GitHub Actions

Re-run CD workflow with a known-good `image_tag`.

## Automatic Rollback

ECS deployment circuit breaker is enabled. If new tasks fail health checks, ECS automatically rolls back to the previous task definition.

## Infrastructure Rollback

```bash
# Revert Terraform changes
git revert <commit-sha>
cd infrastructure/terraform/environments/dev
terraform apply
```

For state corruption, restore from S3 versioning:

```bash
aws s3api list-object-versions \
  --bucket cloudforge-terraform-state-ACCOUNT_ID \
  --prefix cloudforge/dev/terraform.tfstate
```
