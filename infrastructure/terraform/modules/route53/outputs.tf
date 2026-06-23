output "hosted_zone_id" {
  description = "Route 53 hosted zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = aws_acm_certificate_validation.main.certificate_arn
}

output "api_fqdn" {
  description = "API fully qualified domain name"
  value       = "${var.api_subdomain}.${var.domain_name}"
}

output "name_servers" {
  description = "Route 53 name servers for domain delegation"
  value       = aws_route53_zone.main.name_servers
}
