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
