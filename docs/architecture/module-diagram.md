# Terraform Module Dependency Diagram

```mermaid
flowchart TD
    subgraph bootstrap [Bootstrap - once per account]
        S3State[S3 State Bucket]
        DDBLock[DynamoDB Lock Table]
    end

    subgraph env [Environment dev/prod]
        VPC[vpc]
        SG[security-groups]
        ECR[ecr]
        Secrets[secrets]
        Storage[storage]
        Params[parameters]
        Logs[CloudWatch Log Group]
        IAM[iam]
        RDS[rds]
        Cache[elasticache]
        R53[route53 optional]
        ALB[alb]
        ECS[ecs]
        Mon[monitoring]
    end

    VPC --> SG
    VPC --> RDS
    VPC --> Cache
    VPC --> ALB
    VPC --> ECS

    ECR --> IAM
    Secrets --> IAM
    Params --> IAM
    Storage --> IAM
    Logs --> IAM

    SG --> RDS
    SG --> Cache
    SG --> ALB
    SG --> ECS

    Secrets --> RDS
    Secrets --> Cache
    Secrets --> ECS

    ECR --> ECS
    IAM --> ECS
    ALB --> ECS
    RDS --> ECS
    Cache --> ECS

    ALB --> Mon
    ECS --> Mon
    RDS --> Mon

    R53 -.-> ALB
```

## Module Responsibilities

| Category | Modules |
|----------|---------|
| Networking | `vpc`, `security-groups` |
| Compute | `ecs`, `alb` |
| Storage | `storage`, `ecr` |
| IAM | `iam` |
| Security | `secrets`, `parameters` |
| Databases | `rds`, `elasticache` |
| Monitoring | `monitoring` |
| DNS/TLS | `route53` |
| Remote State | `bootstrap` |

## State Separation

- **Bootstrap state:** Local or separate backend (S3 bucket it creates)
- **Environment state:** `cloudforge/{env}/terraform.tfstate` in remote S3

This prevents environment destroys from affecting the state backend itself.
