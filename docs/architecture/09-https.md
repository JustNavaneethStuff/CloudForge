# HTTPS and DNS

## Services

### Amazon Route 53

DNS service for domain management and health-checked routing.

**CloudForge usage:**
- Hosted zone for your domain
- Alias A record pointing to ALB
- ACM DNS validation records

### AWS Certificate Manager (ACM)

Free TLS certificates with automatic renewal.

**Tradeoff:** ACM vs imported certs — ACM handles renewal; imported certs require manual rotation.

## Phased Rollout

HTTPS is **feature-flagged** via `enable_https = true` so Phases 0–8 deploy without a domain.

When enabled:
- HTTP :80 redirects to HTTPS :443
- TLS 1.2+ policy on ALB listener
- DNS alias `api.yourdomain.com` → ALB

## Prerequisites

1. Register a domain (or transfer to Route 53)
2. Set `domain_name` and `enable_https = true` in tfvars
3. Confirm ACM validation emails/DNS records
