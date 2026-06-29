variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "bucket_name_suffix" {
  description = "Optional suffix for the S3 bucket name (defaults to name_prefix)"
  type        = string
  default     = ""
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "noncurrent_version_expiration_days" {
  description = "Days before noncurrent object versions expire"
  type        = number
  default     = 90
}

variable "force_destroy" {
  description = "Allow bucket deletion when objects exist (use false in production)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
