variable "aws_region" {
  description = "AWS region for bootstrap resources"
  type        = string
  default     = "ap-south-2"
}

variable "state_bucket_name_prefix" {
  description = "Prefix for the Terraform state S3 bucket"
  type        = string
  default     = "cloudforge-terraform-state"
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "cloudforge-terraform-locks"
}
