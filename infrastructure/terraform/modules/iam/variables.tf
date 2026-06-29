variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "ecr_repository_arn" {
  description = "ECR repository ARN"
  type        = string
}

variable "secrets_arns" {
  description = "ARNs of secrets the ECS task execution role can read"
  type        = list(string)
  default     = []
}

variable "enable_secrets_access" {
  description = "Grant ECS task execution role access to secrets_arns"
  type        = bool
  default     = false
}

variable "ssm_parameter_arns" {
  description = "ARNs of SSM parameters the ECS task execution role can read"
  type        = list(string)
  default     = []
}

variable "enable_ssm_access" {
  description = "Grant ECS task execution role access to SSM parameters under name_prefix"
  type        = bool
  default     = false
}

variable "s3_bucket_name" {
  description = "S3 bucket name the ECS task role can access"
  type        = string
  default     = ""
}

variable "enable_s3_access" {
  description = "Grant ECS task role access to the app S3 bucket"
  type        = bool
  default     = false
}

variable "log_group_arn" {
  description = "CloudWatch log group ARN"
  type        = string
}

variable "github_org" {
  description = "GitHub organization or user name"
  type        = string
  default     = ""
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "CloudForge"
}

variable "enable_github_oidc" {
  description = "Create GitHub OIDC provider and deploy role"
  type        = bool
  default     = false
}

variable "state_bucket_arn" {
  description = "Terraform state S3 bucket ARN"
  type        = string
  default     = ""
}

variable "lock_table_arn" {
  description = "Terraform lock DynamoDB table ARN"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
