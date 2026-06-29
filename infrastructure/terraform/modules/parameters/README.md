# Parameters Module

Creates AWS Systems Manager Parameter Store entries for non-secret application configuration.

## Design

- **Secrets Manager**: passwords, tokens, API keys
- **Parameter Store**: environment flags, feature toggles, non-sensitive endpoints

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `name_prefix` | SSM path prefix | required |
| `parameters` | Map of key → value | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `parameter_arns` | Map of key → ARN |
| `parameter_names` | Map of key → full path |
| `parameter_arn_list` | List of ARNs for IAM |

## Usage

```hcl
module "parameters" {
  source = "../../modules/parameters"

  name_prefix = "cloudforge-dev"
  parameters = {
    app_env      = "dev"
    log_level    = "INFO"
    feature_flag = "false"
  }
  tags = local.common_tags
}
```
