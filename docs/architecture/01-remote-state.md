# Remote State Bootstrap

## Services

### Amazon S3

Stores Terraform state files remotely so teams can collaborate and state survives local machine loss.

**Why S3 for CloudForge:**
- Versioning enables state recovery after bad applies
- Server-side encryption protects sensitive resource metadata
- Public access block prevents accidental exposure

**Tradeoffs:**
| Option | Pros | Cons |
|--------|------|------|
| S3 + DynamoDB | Full control, in-repo, no vendor lock | One-time chicken-and-egg bootstrap |
| Terraform Cloud | No bootstrap, built-in locking | External dependency, less demonstrable |
| Local state | Simple for solo dev | Not reproducible, not team-safe |

### Amazon DynamoDB

Provides distributed locking so concurrent `terraform apply` operations cannot corrupt state.

**Tradeoffs:**
| Option | Pros | Cons |
|--------|------|------|
| DynamoDB PAY_PER_REQUEST | Near-zero cost at low usage | Separate table per project |
| S3 native locking (TF 1.10+) | No DynamoDB needed | Newer, less battle-tested in portfolios |

## CloudForge Implementation

- Bucket: `cloudforge-terraform-state-{account_id}`
- Lock table: `cloudforge-terraform-locks`
- State keys: `cloudforge/dev/terraform.tfstate`, `cloudforge/prod/terraform.tfstate`
