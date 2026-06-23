variable "domain_name" {
  description = "Root domain name (e.g., example.com)"
  type        = string
}

variable "api_subdomain" {
  description = "API subdomain (e.g., api)"
  type        = string
  default     = "api"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
