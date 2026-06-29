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
| VPC ID | `vpc-0945b0897c9da79b4` |
| ALB DNS | `cloudforge-dev-alb-1036393328.ap-south-2.elb.amazonaws.com` |
| API URL | `http://cloudforge-dev-alb-1036393328.ap-south-2.elb.amazonaws.com` |
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

Blocked: Docker Desktop was paused during image build/push. ECS reported `CannotPullContainerError` (no image in ECR).

To complete smoke test locally:
```bash
# Unpause Docker Desktop, then:
aws ecr get-login-password --region ap-south-2 | docker login --username AWS --password-stdin 195987551186.dkr.ecr.ap-south-2.amazonaws.com
docker build -t 195987551186.dkr.ecr.ap-south-2.amazonaws.com/cloudforge-dev:latest app/
docker push 195987551186.dkr.ecr.ap-south-2.amazonaws.com/cloudforge-dev:latest
aws ecs update-service --cluster cloudforge-dev-cluster --service cloudforge-dev-service --force-new-deployment --region ap-south-2
bash scripts/smoke-test.sh http://cloudforge-dev-alb-1036393328.ap-south-2.elb.amazonaws.com
```

## Teardown

Dev environment and bootstrap destroyed after verification to avoid ongoing AWS charges.
