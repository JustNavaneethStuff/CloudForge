# Terraform Architecture

## Layered Structure

```
bootstrap/          → Remote state (S3 + DynamoDB), once per account
modules/            → Reusable, composable infrastructure components
environments/dev/   → Dev-specific variable values and wiring
environments/prod/  → Prod-specific sizing and HA settings
```

## Design Principles

1. **One module per concern** — vpc, security-groups, iam, ecs, etc.
2. **Environment = composition** — `modules.tf` wires modules together; no logic duplication
3. **Explicit dependencies** — `depends_on` only where Terraform cannot infer (e.g., certificate before HTTPS listener)
4. **Outputs as contracts** — each module exposes only what consumers need

## State Management

- Bootstrap creates the state bucket with versioning, encryption, and `prevent_destroy`
- Each environment has isolated state: `cloudforge/{env}/terraform.tfstate`
- DynamoDB provides pessimistic locking for concurrent applies

## Variable Flow

```
terraform.tfvars → environment variables.tf → module variables → resources
```

Sensitive values (passwords) are generated inside the `secrets` module via `random_password`, never passed via tfvars.

## Module Wiring Pattern

```hcl
module "vpc" { ... }
module "security_groups" { vpc_id = module.vpc.vpc_id }
module "rds" { subnet_ids = module.vpc.private_subnet_ids, ... }
module "ecs" { depends_on = [module.rds, module.alb] }
```

## Version Constraints

Every module has `versions.tf` pinning:
- Terraform >= 1.7
- AWS provider ~> 5.0
- Random provider ~> 3.6 (secrets module only)

## Testing

Native Terraform tests (`.tftest.hcl`) validate module plans with `mock_provider "aws"`.

## CI Integration

- `terraform fmt -check -recursive`
- `terraform validate` on all modules and environments
- `tflint` with AWS ruleset
- `tfsec` IaC security scan
- `terraform plan` on PRs with comment output
- `terraform test` on vpc and security-groups modules
