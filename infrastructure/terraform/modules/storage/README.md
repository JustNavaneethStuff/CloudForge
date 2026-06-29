# Storage Module

Creates an application S3 bucket for artifacts and static assets.

## Resources

- S3 bucket with SSE-S3 encryption
- Versioning (optional)
- Public access block
- Lifecycle rule for noncurrent version expiration

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `name_prefix` | Resource name prefix | required |
| `bucket_name_suffix` | Bucket name suffix | `""` |
| `enable_versioning` | Enable versioning | `true` |
| `force_destroy` | Allow deletion with objects | `false` |

## Outputs

| Name | Description |
|------|-------------|
| `bucket_arn` | S3 bucket ARN |
| `bucket_name` | S3 bucket name |

## Usage

```hcl
module "storage" {
  source = "../../modules/storage"

  name_prefix    = "cloudforge-dev"
  force_destroy  = true
  tags           = local.common_tags
}
```
