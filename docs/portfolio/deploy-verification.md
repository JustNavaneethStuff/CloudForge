# Deploy Verification — 2026-06-29

End-to-end dev deployment verification after production upgrade.

## Bootstrap

| Output | Value |
|--------|-------|
| State bucket | `cloudforge-terraform-state-195987551186` |
| Lock table | `cloudforge-terraform-locks` |
| Region | `ap-south-2` |
| Account | `195987551186` |

## Dev Environment

| Output | Value |
|--------|-------|
| VPC ID | `vpc-07b55dab2bb375981` |
| ALB DNS | `cloudforge-dev-alb-692504719.ap-south-2.elb.amazonaws.com` |
| API URL | `http://cloudforge-dev-alb-692504719.ap-south-2.elb.amazonaws.com` |
| ECR URL | `195987551186.dkr.ecr.ap-south-2.amazonaws.com/cloudforge-dev` |
| ECS Cluster | `cloudforge-dev-cluster` |
| ECS Service | `cloudforge-dev-service` |
| S3 App Bucket | `cloudforge-dev-app-195987551186` |
| SSM Prefix | `/cloudforge-dev` |
| GitHub OIDC Role | `arn:aws:iam::195987551186:role/cloudforge-dev-github-actions` |
| CloudWatch Dashboard | `cloudforge-dev-dashboard` |

## New Modules Verified

- `modules/storage` — S3 app bucket created with SSE, versioning, lifecycle
- `modules/parameters` — 4 SSM parameters created under `/cloudforge-dev/`
- ECS autoscaling policies (CPU, memory, ALB request count) configured
- IAM SSM path-scoped and S3 bucket-scoped policies applied

## Smoke Test

Docker image built and pushed to ECR after Docker Desktop was unpaused. ECS was force-redeployed and reached stable state.

| Endpoint | Status |
|----------|--------|
| `/health` | 200 |
| `/api/v1/info` | 200 |
| `/metrics` | 200 |
| `/ready` | 200 |

## Teardown

Dev environment and bootstrap destroyed after verification to avoid ongoing AWS charges.

Teardown verification:

- ECS cluster `cloudforge-dev-cluster`: `INACTIVE`
- State bucket `cloudforge-terraform-state-195987551186`: not found (404)
