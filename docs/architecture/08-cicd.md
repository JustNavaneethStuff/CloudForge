# CI/CD Pipelines

## GitHub Actions

### CI (`ci.yml`)

Triggered on pull requests and pushes to `main`:

1. **Lint** — `ruff` + `mypy`
2. **Test** — `pytest` with mocked dependencies
3. **Build** — Docker image build
4. **Scan** — Trivy vulnerability scan
5. **Push** — On `main` only, push to ECR with `git-sha` and `latest` tags

### CD (`cd.yml`)

Triggered via `workflow_dispatch` with environment selection:

1. Assume AWS role via **OIDC** (no long-lived keys)
2. `terraform init` + `terraform apply` for selected environment
3. Force ECS service deployment with new image
4. Wait for service stability

Prod deployments use GitHub Environment protection rules for manual approval.

## Rollback Strategy

| Layer | Method |
|-------|--------|
| Application | `scripts/rollback.sh <env> <image-tag>` |
| Failed deploy | ECS deployment circuit breaker (automatic) |
| Infrastructure | `git revert` + `terraform apply` |

## Tradeoffs

| OIDC | IAM Access Keys |
|------|-----------------|
| No key rotation | Simple setup |
| Scoped to repo/branch | Long-lived credentials |
| Industry best practice | Security risk if leaked |
