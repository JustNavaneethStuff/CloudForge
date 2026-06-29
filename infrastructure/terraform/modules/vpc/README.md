# VPC Module

Creates a multi-AZ VPC with public/private subnets, Internet Gateway, NAT Gateway(s), and optional VPC endpoints.

## Key Inputs

- `vpc_cidr`, `availability_zones`, `public_subnet_cidrs`, `private_subnet_cidrs`
- `nat_gateway_count` — 1 for dev, 2+ for prod HA
- `enable_vpc_endpoints` — S3/ECR/Secrets Manager endpoints

## Key Outputs

- `vpc_id`, `public_subnet_ids`, `private_subnet_ids`
