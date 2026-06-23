# CloudForge Architecture

## System Context

```mermaid
flowchart TB
    Users[Users] --> ALB[Application Load Balancer]
    GHA[GitHub Actions] --> ECR[ECR]
    GHA --> ECS[ECS Fargate]
    GHA --> TF[Terraform State S3]

    subgraph vpc [VPC]
        subgraph public [Public Subnets]
            ALB
            NAT[NAT Gateway]
        end
        subgraph private [Private Subnets]
            ECS
            RDS[(RDS PostgreSQL)]
            Redis[(ElastiCache Redis)]
        end
    end

    ALB --> ECS
    ECS --> RDS
    ECS --> Redis
    ECS --> SM[Secrets Manager]
    ECS --> CW[CloudWatch Logs]
    NAT --> ECS
    ECR --> ECS
```

## CI/CD Flow

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant GHA as GitHub Actions
    participant ECR as ECR
    participant TF as Terraform
    participant ECS as ECS

    Dev->>GHA: Push to main
    GHA->>GHA: Lint test scan
    GHA->>ECR: Push image
    Dev->>GHA: Trigger CD workflow
    GHA->>TF: terraform apply
    GHA->>ECS: Force new deployment
    ECS->>ECS: Circuit breaker monitors health
```

## Portfolio Highlights

- **Infrastructure as Code:** 10+ reusable Terraform modules
- **Container orchestration:** ECS Fargate with auto-rollback
- **CI/CD:** GitHub Actions with OIDC, no static AWS keys
- **Observability:** CloudWatch dashboards, alarms, structured logging
- **Security:** Network isolation, Secrets Manager, least-privilege IAM
- **Multi-environment:** dev + prod with separate VPCs and state

See [design-decisions.md](design-decisions.md) for detailed rationale.
