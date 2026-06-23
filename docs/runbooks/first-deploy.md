# CloudForge — First Deploy Checklist

Complete these steps in order on your machine.

## 1. Install tools

| Tool | Install |
|------|---------|
| AWS CLI v2 | https://aws.amazon.com/cli/ |
| Terraform >= 1.7 | https://developer.hashicorp.com/terraform/install |
| Docker Desktop | https://www.docker.com/products/docker-desktop/ |
| Git | https://git-scm.com/ |

Verify:

```powershell
aws --version
terraform version
docker --version
gh --version
```

## 2. Configure AWS

```powershell
aws configure
aws sts get-caller-identity
```

## 3. Bootstrap remote state (once per AWS account)

```powershell
cd CloudForge
make bootstrap
```

Note the **state bucket name** from the output.

## 4. Configure Terraform backend

```powershell
cd infrastructure/terraform/environments/dev

# Edit backend.hcl — replace REPLACE_ACCOUNT_ID with your AWS account ID
copy backend.hcl.example backend.hcl

terraform init -backend-config=backend.hcl
```

`terraform.tfvars` is already configured with:
- Alert email: `navaneethprojects791@gmail.com`
- GitHub org: `JustNavaneethStuff`

After bootstrap, uncomment and fill in `state_bucket_arn` and `lock_table_arn` in `terraform.tfvars`.

## 5. Deploy dev environment

```powershell
cd ../../../..
make deploy ENV=dev
```

First deploy takes ~10–15 minutes (RDS and ElastiCache are slowest).

## 6. Configure GitHub secrets

```powershell
bash scripts/setup-github-secrets.sh dev
```

This sets: `AWS_ACCOUNT_ID`, `TF_STATE_BUCKET`, `TF_LOCK_TABLE`, `AWS_ROLE_ARN`

## 7. Confirm SNS email subscription

Check `navaneethprojects791@gmail.com` for an AWS SNS confirmation email and click **Confirm subscription**.

## 8. Verify deployment

```powershell
cd infrastructure/terraform/environments/dev
terraform output api_url
curl (terraform output -raw api_url)/health
```

## GitHub (already done)

- [x] Repository: https://github.com/JustNavaneethStuff/CloudForge
- [x] Environments: `dev`, `prod`
- [ ] Prod approval rule: add yourself as required reviewer in GitHub → Settings → Environments → prod

## Optional: HTTPS (when you have a domain)

In `terraform.tfvars`:

```hcl
enable_https = true
domain_name  = "yourdomain.com"
```

Then `make apply ENV=dev`.
