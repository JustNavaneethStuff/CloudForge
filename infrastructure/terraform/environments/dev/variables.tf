variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "nat_gateway_count" {
  description = "Number of NAT gateways"
  type        = number
  default     = 1
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints"
  type        = bool
  default     = false
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 8000
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "cloudforge"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "cloudforge"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "rds_multi_az" {
  description = "RDS Multi-AZ"
  type        = bool
  default     = false
}

variable "rds_backup_retention" {
  description = "RDS backup retention days"
  type        = number
  default     = 7
}

variable "rds_deletion_protection" {
  description = "RDS deletion protection"
  type        = bool
  default     = false
}

variable "rds_skip_final_snapshot" {
  description = "Skip RDS final snapshot"
  type        = bool
  default     = true
}

variable "redis_node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t4g.micro"
}

variable "redis_num_nodes" {
  description = "Number of Redis nodes"
  type        = number
  default     = 1
}

variable "ecs_cpu" {
  description = "ECS task CPU"
  type        = number
  default     = 256
}

variable "ecs_memory" {
  description = "ECS task memory MB"
  type        = number
  default     = 512
}

variable "ecs_desired_count" {
  description = "Desired ECS task count"
  type        = number
  default     = 1
}

variable "ecs_enable_autoscaling" {
  description = "Enable ECS autoscaling"
  type        = bool
  default     = false
}

variable "ecs_min_capacity" {
  description = "ECS min capacity"
  type        = number
  default     = 1
}

variable "ecs_max_capacity" {
  description = "ECS max capacity"
  type        = number
  default     = 4
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "log_level" {
  description = "Application log level"
  type        = string
  default     = "INFO"
}

variable "log_retention_days" {
  description = "CloudWatch log retention"
  type        = number
  default     = 7
}

variable "alert_email" {
  description = "Email for CloudWatch alarms"
  type        = string
  default     = ""
}

variable "enable_https" {
  description = "Enable HTTPS with Route53 and ACM"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Domain name for HTTPS"
  type        = string
  default     = ""
}

variable "api_subdomain" {
  description = "API subdomain"
  type        = string
  default     = "api"
}

variable "github_org" {
  description = "GitHub organization for OIDC"
  type        = string
  default     = ""
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "CloudForge"
}

variable "enable_github_oidc" {
  description = "Enable GitHub OIDC IAM role"
  type        = bool
  default     = false
}

variable "state_bucket_arn" {
  description = "Terraform state bucket ARN"
  type        = string
  default     = ""
}

variable "lock_table_arn" {
  description = "Terraform lock table ARN"
  type        = string
  default     = ""
}
