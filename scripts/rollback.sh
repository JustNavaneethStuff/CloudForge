#!/usr/bin/env bash
set -euo pipefail

ENV="${1:-dev}"
IMAGE_TAG="${2:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TF_DIR="$ROOT_DIR/infrastructure/terraform/environments/$ENV"

AWS_REGION="${AWS_REGION:-us-east-1}"
export AWS_REGION

echo "==> CloudForge Rollback — environment: $ENV"

cd "$TF_DIR"
terraform init -upgrade > /dev/null 2>&1

CLUSTER=$(terraform output -raw ecs_cluster_name)
SERVICE=$(terraform output -raw ecs_service_name)
ECR_URL=$(terraform output -raw ecr_repository_url)

if [ -z "$IMAGE_TAG" ]; then
  echo "Available image tags in ECR:"
  aws ecr describe-images \
    --repository-name "$(echo "$ECR_URL" | cut -d'/' -f2)" \
    --region "$AWS_REGION" \
    --query 'sort_by(imageDetails,& imagePushedAt)[*].imageTags' \
    --output table
  echo ""
  read -r -p "Enter image tag to rollback to: " IMAGE_TAG
fi

if [ -z "$IMAGE_TAG" ]; then
  echo "ERROR: Image tag required."
  exit 1
fi

TASK_DEF_ARN=$(aws ecs describe-services \
  --cluster "$CLUSTER" \
  --services "$SERVICE" \
  --region "$AWS_REGION" \
  --query 'services[0].taskDefinition' \
  --output text)

TASK_DEF=$(aws ecs describe-task-definition \
  --task-definition "$TASK_DEF_ARN" \
  --region "$AWS_REGION" \
  --query 'taskDefinition')

NEW_TASK_DEF=$(echo "$TASK_DEF" | jq --arg IMAGE "${ECR_URL}:${IMAGE_TAG}" \
  '.containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities, .registeredAt, .registeredBy)')

NEW_TASK_ARN=$(aws ecs register-task-definition \
  --cli-input-json "$NEW_TASK_DEF" \
  --region "$AWS_REGION" \
  --query 'taskDefinition.taskDefinitionArn' \
  --output text)

aws ecs update-service \
  --cluster "$CLUSTER" \
  --service "$SERVICE" \
  --task-definition "$NEW_TASK_ARN" \
  --force-new-deployment \
  --region "$AWS_REGION" \
  --no-cli-pager

echo "==> Rolled back to ${ECR_URL}:${IMAGE_TAG}"
echo "    Waiting for service stability..."
aws ecs wait services-stable \
  --cluster "$CLUSTER" \
  --services "$SERVICE" \
  --region "$AWS_REGION"
echo "==> Rollback complete."
