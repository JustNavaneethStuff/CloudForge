# Operational Procedures

## Daily Operations

- Monitor CloudWatch dashboard for ALB 5xx, ECS CPU, RDS connections
- Review GitHub Actions CI/CD status on active PRs

## Deployment Procedure

1. Merge PR to `main` (triggers CI: lint, test, build, scan, ECR push)
2. Run CD workflow with target environment and image tag
3. Verify smoke test passes in CD pipeline
4. Check CloudWatch logs for errors post-deploy

## Rollback Procedure

```bash
# Option 1: Script
bash scripts/rollback.sh prod <previous-image-tag>

# Option 2: Automatic
# ECS deployment circuit breaker rolls back on failed health checks
```

## Incident Response

1. **Detect** — CloudWatch alarm or user report
2. **Assess** — Check `/ready`, ECS events, RDS status
3. **Mitigate** — Rollback, scale up, or failover
4. **Resolve** — Root cause analysis, fix, redeploy
5. **Document** — Post-incident review

See [incident-response.md](../runbooks/incident-response.md).

## Infrastructure Changes

1. Create feature branch
2. `terraform plan` locally or via PR workflow
3. Review plan output in PR comment
4. Merge and apply via CD workflow

## Drift Remediation

1. Review drift detection GitHub issue
2. Run `terraform plan` locally to see changes
3. Either apply Terraform to reconcile or import manual changes
4. Close drift issue

## Secret Rotation

1. Update secret in Secrets Manager (or trigger rotation lambda)
2. Force ECS redeployment: `aws ecs update-service --force-new-deployment`
3. Verify `/ready` endpoint

## Backup Verification

- **RDS:** Confirm automated backups in AWS console
- **Terraform state:** S3 versioning provides state history
- **ECR:** Images tagged by git SHA; lifecycle retains last 10

## Teardown

```bash
make destroy ENV=dev
```

For bootstrap teardown, see [teardown.md](../runbooks/teardown.md).

## Local Development Operations

```bash
docker compose up -d                              # App stack
docker compose -f docker-compose.observability.yml up -d  # Metrics/tracing
make test && make lint                            # Quality checks
bash scripts/smoke-test.sh http://localhost:8000  # Local verification
```
