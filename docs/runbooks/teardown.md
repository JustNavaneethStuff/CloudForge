# Teardown Procedure

## Destroy Application Environment

```bash
make destroy ENV=dev
```

This removes all resources in the dev/prod environment except bootstrap (state bucket + lock table).

## Destroy Bootstrap (State Backend)

Bootstrap resources have `prevent_destroy` lifecycle guards. To tear down:

1. Edit `infrastructure/terraform/bootstrap/s3.tf`:
   - Remove or comment out `lifecycle { prevent_destroy = true }` on S3 bucket and DynamoDB table
   - Add `force_destroy = true` to `aws_s3_bucket.terraform_state`

2. Apply and destroy:

```bash
cd infrastructure/terraform/bootstrap
terraform init
terraform apply    # apply force_destroy change
terraform destroy
```

3. Restore `prevent_destroy` guards before next bootstrap.

## Cost Reminder

NAT Gateway, RDS, and ElastiCache incur charges even when idle. Always destroy dev when not actively testing.
