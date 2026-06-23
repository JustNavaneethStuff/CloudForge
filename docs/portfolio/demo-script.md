# Demo Script — Fresh AWS Account

Deploy CloudForge from a new AWS account in ~30 minutes.

## Step 1: Prerequisites (5 min)

```bash
# Install tools
# - AWS CLI v2
# - Terraform >= 1.7
# - Docker
# - Git

aws configure
aws sts get-caller-identity  # verify credentials
```

## Step 2: Clone and Bootstrap (5 min)

```bash
git clone https://github.com/YOUR_ORG/CloudForge.git
cd CloudForge

make bootstrap
# Note the state bucket name and lock table from output
```

## Step 3: Configure Dev Environment (5 min)

```bash
cd infrastructure/terraform/environments/dev

# Backend config
cp backend.hcl.example backend.hcl
# Replace REPLACE_ACCOUNT_ID with your account ID

terraform init -backend-config=backend.hcl

# Variables
cp terraform.tfvars.example terraform.tfvars
# Set github_org, state_bucket_arn, lock_table_arn
```

## Step 4: Deploy Infrastructure (10 min)

```bash
cd ../../../..
make deploy ENV=dev
```

RDS and ElastiCache take the longest (~8-10 min).

## Step 5: Verify (2 min)

```bash
cd infrastructure/terraform/environments/dev
API_URL=$(terraform output -raw api_url)

curl "$API_URL/health"
curl "$API_URL/ready"
curl "$API_URL/api/v1/info"
```

Expected `/health` response: `{"status":"ok"}`

## Step 6: GitHub Actions (5 min)

1. Push repo to GitHub
2. Create `dev` and `prod` environments
3. Add secrets from Terraform outputs
4. Trigger CD workflow for `dev`

## Step 7: Teardown (when done)

```bash
make destroy ENV=dev
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| ECS tasks not starting | Push Docker image: `make deploy ENV=dev` |
| `/ready` returns 503 | Wait for RDS/ElastiCache; check security groups |
| Terraform state lock | `terraform force-unlock LOCK_ID` |
| ECR login failed | Verify AWS credentials and region |
