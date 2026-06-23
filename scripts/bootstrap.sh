#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BOOTSTRAP_DIR="$ROOT_DIR/infrastructure/terraform/bootstrap"

AWS_REGION="${AWS_REGION:-us-east-1}"
export AWS_REGION

echo "==> CloudForge Bootstrap"
echo "    Region: $AWS_REGION"
echo ""

if ! command -v aws &> /dev/null; then
    echo "ERROR: AWS CLI is not installed."
    exit 1
fi

if ! command -v terraform &> /dev/null; then
    echo "ERROR: Terraform is not installed."
    exit 1
fi

if ! aws sts get-caller-identity &> /dev/null; then
    echo "ERROR: AWS credentials not configured."
    exit 1
fi

echo "==> Applying bootstrap Terraform (S3 state bucket + DynamoDB lock table)..."
cd "$BOOTSTRAP_DIR"
terraform init -upgrade
terraform apply

echo ""
echo "==> Bootstrap complete!"
echo "    Copy the outputs above into your environment backend config."
echo "    Next: make deploy ENV=dev"
