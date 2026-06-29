# Architectural Tradeoffs

## ECS Fargate vs EKS

| | Fargate | EKS |
|---|---------|-----|
| Ops burden | Low | High (control plane, node groups) |
| Portability | AWS-locked | Kubernetes-portable |
| Cost at scale | Higher per-task | Lower with spot nodes |
| **Choice** | **Fargate** — portfolio/demo focus, minimal ops |

## Single NAT vs NAT per AZ

| | Single NAT | NAT per AZ |
|---|-----------|------------|
| Cost | ~$35/mo | ~$70/mo |
| HA | AZ failure breaks outbound | Resilient |
| **Choice** | **Single for dev**, **per-AZ for prod** |

## Secrets Manager vs Parameter Store for All Config

| | Secrets Manager | Parameter Store |
|---|----------------|-----------------|
| Rotation | Built-in | Manual |
| Cost | $0.40/secret/mo | Free (standard) |
| **Choice** | **Secrets for credentials**, **SSM for config** |

## HTTP vs HTTPS in Dev

| | HTTP | HTTPS |
|---|------|-------|
| Setup | Immediate (ALB DNS) | Requires domain + ACM validation |
| **Choice** | **HTTP dev**, **HTTPS prod** (feature-flagged) |

## CloudWatch vs Self-Hosted Prometheus

| | CloudWatch | Prometheus/Grafana |
|---|-----------|-------------------|
| AWS integration | Native | Requires ADOT sidecar or scraping |
| Cost | Per metric/log | Self-hosted compute |
| **Choice** | **CloudWatch in AWS**, **Prometheus locally** for dev observability |

## Monolith API vs Microservices

| | Monolith | Microservices |
|---|----------|---------------|
| Complexity | Low | Service mesh, inter-service auth |
| Deploy speed | Single image | Multiple pipelines |
| **Choice** | **Monolith** — appropriate for current scope |

## Terraform vs Pulumi/CDK

| | Terraform | CDK |
|---|-----------|-----|
| Industry adoption | Very high | Growing |
| State management | Built-in | CloudFormation |
| Language | HCL | TypeScript/Python |
| **Choice** | **Terraform** — IaC standard, module ecosystem |
