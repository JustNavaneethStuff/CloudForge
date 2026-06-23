variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "cloudforge"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "cloudforge"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
