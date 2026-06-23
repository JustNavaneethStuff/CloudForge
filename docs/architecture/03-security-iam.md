# Security Groups and IAM

## Services

### Security Groups

Stateful virtual firewalls attached to ENIs. CloudForge uses a tiered model:

```
Internet → ALB SG (80/443) → ECS SG (8000) → RDS SG (5432) / Redis SG (6379)
```

**Tradeoff:** Security groups vs NACLs — SGs are stateful and easier to manage; NACLs add subnet-level defense-in-depth at the cost of complexity.

### IAM (Identity and Access Management)

Controls who can do what in AWS.

**CloudForge roles:**
| Role | Purpose |
|------|---------|
| `ecsTaskExecutionRole` | Pull ECR images, read Secrets Manager, write CloudWatch Logs |
| `ecsTaskRole` | Application-level AWS API access (minimal) |
| `githubActionsRole` | OIDC-authenticated CI/CD deploy |

**Tradeoff:** GitHub OIDC vs IAM access keys — OIDC eliminates long-lived credentials and rotation burden.

## Least Privilege Principles

- Trust policies scoped to specific GitHub repo and branch
- Task role has no permissions by default (extend only when needed)
- No `AdministratorAccess` on deploy role
