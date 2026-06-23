# Deploy Runbook

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.7 installed
- Docker installed (for local image builds)
- Bootstrap completed (`make bootstrap`)

## First-Time Setup

```bash
# 1. Bootstrap remote state (once per AWS account)
make bootstrap

# 2. Configure backend for dev
cd infrastructure/terraform/environments/dev
cp backend.hcl.example backend.hcl
# Edit backend.hcl with your account ID

terraform init -backend-config=backend.hcl

# 3. Configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with github_org, state ARNs, etc.

# 4. Deploy
cd ../../../..
make deploy ENV=dev
```

## Verify Deployment

```bash
# Get ALB URL
cd infrastructure/terraform/environments/dev
terraform output api_url

# Health check
curl "$(terraform output -raw api_url)/health"
curl "$(terraform output -raw api_url)/ready"
curl "$(terraform output -raw api_url)/api/v1/info"
```

## GitHub Actions Setup

1. Create GitHub Environments: `dev`, `prod`
2. Add secrets to repository:
   - `AWS_ROLE_ARN` — from `terraform output github_actions_role_arn`
   - `TF_STATE_BUCKET` — bootstrap bucket name
   - `TF_LOCK_TABLE` — `cloudforge-terraform-locks`
   - `AWS_ACCOUNT_ID` — your AWS account ID
3. Add prod environment protection rule (required reviewers)

## Teardown

```bash
make destroy ENV=dev
```
