#!/usr/bin/env bash
set -euo pipefail

# Configures GitHub repository secrets after AWS bootstrap + first terraform apply.
# Usage: ./scripts/setup-github-secrets.sh dev

ENV="${1:-dev}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TF_DIR="$ROOT_DIR/infrastructure/terraform/environments/$ENV"
REPO="${GITHUB_REPO:-JustNavaneethStuff/CloudForge}"

AWS_REGION="${AWS_REGION:-ap-south-2}"

echo "==> Configuring GitHub secrets for $REPO (env: $ENV)"

if ! command -v gh &> /dev/null; then
    echo "ERROR: GitHub CLI (gh) is required."
    exit 1
fi

if ! command -v aws &> /dev/null; then
    echo "ERROR: AWS CLI is required."
    exit 1
fi

cd "$TF_DIR"
terraform init -upgrade > /dev/null 2>&1 || true

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
STATE_BUCKET=$(aws s3api list-buckets --query "Buckets[?starts_with(Name, 'cloudforge-terraform-state')].Name | [0]" --output text)
LOCK_TABLE="cloudforge-terraform-locks"
ROLE_ARN=$(terraform output -raw github_actions_role_arn 2>/dev/null || echo "")

if [ -z "$STATE_BUCKET" ] || [ "$STATE_BUCKET" = "None" ]; then
    echo "ERROR: Bootstrap bucket not found. Run 'make bootstrap' first."
    exit 1
fi

echo "    Account ID:    $ACCOUNT_ID"
echo "    State bucket:  $STATE_BUCKET"
echo "    Lock table:    $LOCK_TABLE"
echo "    OIDC role:     ${ROLE_ARN:-not yet created — run terraform apply first}"

gh secret set AWS_ACCOUNT_ID --body "$ACCOUNT_ID" --repo "$REPO"
gh secret set TF_STATE_BUCKET --body "$STATE_BUCKET" --repo "$REPO"
gh secret set TF_LOCK_TABLE --body "$LOCK_TABLE" --repo "$REPO"

if [ -n "$ROLE_ARN" ]; then
    gh secret set AWS_ROLE_ARN --body "$ROLE_ARN" --repo "$REPO"
    echo "==> GitHub secrets configured successfully."
else
    echo ""
    echo "WARNING: AWS_ROLE_ARN not set — run 'make apply ENV=$ENV' first, then re-run this script."
fi

echo ""
echo "Next: Trigger CD workflow at https://github.com/$REPO/actions/workflows/cd.yml"
