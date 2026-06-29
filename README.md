# CloudForge

A production-grade cloud infrastructure platform demonstrating AWS architecture, Infrastructure as Code, container orchestration, CI/CD, observability, and operational excellence.

## Architecture

Three-tier containerized API on AWS:

- **Edge:** Application Load Balancer (public subnets)
- **Compute:** ECS Fargate (private subnets)
- **Data:** RDS PostgreSQL + ElastiCache Redis (private subnets)
- **Config:** SSM Parameter Store + Secrets Manager
- **Storage:** S3 (app artifacts + Terraform state)

See [network diagram](docs/architecture/network-diagram.md) and [module diagram](docs/architecture/module-diagram.md).

## Tech Stack

| Layer | Technology |
|-------|------------|
| Infrastructure | Terraform (13 modules) |
| Container | Docker (multi-stage) |
| Orchestration | ECS Fargate |
| Application | Python FastAPI |
| CI/CD | GitHub Actions (OIDC) |
| Observability | CloudWatch + Prometheus/Grafana/Tempo (local) |
| Cloud | AWS (ap-south-2) |

## Prerequisites

1. AWS account with admin access
2. [AWS CLI v2](https://aws.amazon.com/cli/) configured
3. [Terraform](https://www.terraform.io/) >= 1.7
4. [Docker](https://www.docker.com/) Desktop
5. GitHub repository with `dev` and `prod` environments

**Default region:** `ap-south-2` (Asia Pacific — Hyderabad)

## Quick Start

```bash
# 1. Bootstrap remote state (once per AWS account)
make bootstrap

# 2. Deploy to dev
make deploy ENV=dev

# 3. Verify
bash scripts/smoke-test.sh $(cd infrastructure/terraform/environments/dev && terraform output -raw api_url)
```

## Local Development

```bash
# App + Postgres + Redis
docker compose up -d

# Observability (Prometheus, Grafana, Tempo)
docker compose -f docker-compose.observability.yml up -d

# Tests
make test
make lint
make validate
```

Grafana: http://localhost:3000 (admin/admin) | Prometheus: http://localhost:9090

## Project Structure

```
CloudForge/
├── app/                         # FastAPI application
├── observability/               # Prometheus, Grafana, Tempo configs
├── infrastructure/terraform/
│   ├── bootstrap/               # S3 + DynamoDB for remote state
│   ├── modules/                 # 13 reusable Terraform modules
│   └── environments/            # dev / prod configurations
├── .github/workflows/           # CI, CD, Terraform, drift detection
├── docs/                        # Architecture, security, interview prep
└── scripts/                     # Deploy, rollback, smoke-test
```

## Commands

| Command | Description |
|---------|-------------|
| `make bootstrap` | Create S3 state bucket + DynamoDB lock table |
| `make plan ENV=dev` | Preview infrastructure changes |
| `make apply ENV=dev` | Apply infrastructure changes |
| `make deploy ENV=dev` | Full deploy (infra + image + ECS) |
| `make destroy ENV=dev` | Tear down environment |
| `make validate` | Validate all Terraform modules |
| `make lint` | Lint Python code |
| `make test` | Run application tests |
| `make build-image` | Build Docker image locally |

## CI/CD Pipelines

| Workflow | Trigger | Actions |
|----------|---------|---------|
| **CI** | PR/push to main | lint, mypy, pytest, pip-audit, Docker build, Trivy |
| **Terraform** | PR/push (infra changes) | fmt, validate, tflint, tfsec, plan-on-PR, terraform test |
| **CD** | Manual dispatch | terraform apply, ECS deploy, smoke test |
| **Drift** | Weekly schedule | terraform plan drift detection, GitHub issue |

## Documentation

| Area | Path |
|------|------|
| Deployment | [docs/deployment-guide.md](docs/deployment-guide.md) |
| Security model | [docs/security-model.md](docs/security-model.md) |
| Scaling | [docs/scaling-strategy.md](docs/scaling-strategy.md) |
| Architecture | [docs/architecture/](docs/architecture/) |
| Runbooks | [docs/runbooks/](docs/runbooks/) |
| Interview prep | [docs/interview/](docs/interview/) |
| Portfolio | [docs/portfolio/](docs/portfolio/) |

## Security

- IAM least privilege with separate ECS execution/task roles
- GitHub Actions OIDC (no long-lived AWS keys)
- Secrets Manager for credentials; SSM Parameter Store for config
- Container scanning (Trivy) + dependency scanning (pip-audit)
- IaC scanning (tfsec) + Dependabot
- Private subnets, encryption at rest and in transit

## Cost Estimate

| Environment | Approximate monthly cost |
|-------------|-------------------------|
| dev | $80–120 |
| prod | $200–350 |

Run `make destroy ENV=dev` when not in use. See [cost analysis](docs/performance/optimization.md).

## License

MIT
