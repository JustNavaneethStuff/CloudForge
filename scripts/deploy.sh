#!/usr/bin/env bash
set -euo pipefail

ENV="${1:-dev}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TF_DIR="$ROOT_DIR/infrastructure/terraform/environments/$ENV"

AWS_REGION="${AWS_REGION:-us-east-1}"
export AWS_REGION

echo "==> CloudForge Deploy — environment: $ENV"
echo "    Region: $AWS_REGION"
echo ""

if ! aws sts get-caller-identity &> /dev/null; then
    echo "ERROR: AWS credentials not configured."
    exit 1
fi

if [ ! -d "$TF_DIR" ]; then
    echo "ERROR: Environment '$ENV' not found at $TF_DIR"
    exit 1
fi

if [ "$ENV" = "prod" ]; then
    echo "WARNING: Deploying to PRODUCTION."
    read -r -p "Continue? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

echo "==> Step 1/3: Terraform apply..."
cd "$TF_DIR"
terraform init -upgrade

if [ "$ENV" = "prod" ]; then
    terraform apply
else
    terraform apply -auto-approve
fi

echo ""
echo "==> Step 2/3: Build and push Docker image..."
ECR_URL=$(terraform output -raw ecr_repository_url 2>/dev/null || echo "")

if [ -n "$ECR_URL" ] && command -v docker &> /dev/null; then
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    aws ecr get-login-password --region "$AWS_REGION" | \
        docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

    GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "local")
    IMAGE_TAG="${ECR_URL}:${GIT_SHA}"
    IMAGE_LATEST="${ECR_URL}:latest"

    docker build -t "$IMAGE_TAG" -t "$IMAGE_LATEST" "$ROOT_DIR/app/"
    docker push "$IMAGE_TAG"
    docker push "$IMAGE_LATEST"
    echo "    Pushed: $IMAGE_TAG"
else
    echo "    Skipping image push (ECR URL unavailable or Docker not installed)."
    echo "    Use GitHub Actions CI/CD to push images."
fi

echo ""
echo "==> Step 3/3: Force ECS service deployment..."
CLUSTER=$(terraform output -raw ecs_cluster_name 2>/dev/null || echo "")
SERVICE=$(terraform output -raw ecs_service_name 2>/dev/null || echo "")

if [ -n "$CLUSTER" ] && [ -n "$SERVICE" ]; then
    aws ecs update-service \
        --cluster "$CLUSTER" \
        --service "$SERVICE" \
        --force-new-deployment \
        --region "$AWS_REGION" \
        --no-cli-pager

    echo "    Waiting for service stability..."
    aws ecs wait services-stable \
        --cluster "$CLUSTER" \
        --services "$SERVICE" \
        --region "$AWS_REGION"

    ALB_DNS=$(terraform output -raw alb_dns_name 2>/dev/null || echo "")
    if [ -n "$ALB_DNS" ]; then
        echo ""
        echo "==> Deploy complete!"
        echo "    API URL: http://${ALB_DNS}/api/v1/info"
        echo "    Health:  http://${ALB_DNS}/health"
    fi
else
    echo "    ECS service not yet available. Run deploy again after first apply completes."
fi
