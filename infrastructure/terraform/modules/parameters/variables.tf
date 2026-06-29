variable "name_prefix" {
  description = "Prefix for SSM parameter paths"
  type        = string
}

variable "parameters" {
  description = "Map of SSM parameter name suffix to value (non-secret config only)"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
