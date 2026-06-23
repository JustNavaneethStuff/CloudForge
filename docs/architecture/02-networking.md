# Networking Foundation

## Services

### Amazon VPC (Virtual Private Cloud)

An isolated virtual network where all CloudForge resources live. Provides control over IP ranges, subnets, routing, and network gateways.

**Tradeoffs:**
| Option | Pros | Cons |
|--------|------|------|
| Dedicated VPC per environment | Full isolation, blast-radius containment | More NAT gateway cost |
| Shared VPC | Lower cost | Environments can interfere |

CloudForge uses **separate VPCs** per environment (`10.0.0.0/16` dev, `10.1.0.0/16` prod).

### Subnets

Divide the VPC into segments across Availability Zones.

- **Public subnets:** ALB, NAT Gateway — route `0.0.0.0/0` to Internet Gateway
- **Private subnets:** ECS, RDS, Redis — route `0.0.0.0/0` to NAT Gateway

**Tradeoff:** 2 AZs minimum for ALB and RDS subnet groups (AWS requirement for HA).

### NAT Gateway

Allows private subnet resources to reach the internet (ECR image pulls, package updates) without inbound exposure.

**Tradeoff:**
| dev | prod |
|-----|------|
| 1 NAT (~$32/mo) | 2 NATs (~$64/mo) for AZ fault tolerance |

### Internet Gateway

Enables bidirectional internet access for public subnets.

## CloudForge Layout

```
VPC 10.x.0.0/16
├── Public  10.x.1.0/24  (AZ-a) — ALB, NAT
├── Public  10.x.2.0/24  (AZ-b) — ALB
├── Private 10.x.10.0/24 (AZ-a) — ECS, RDS, Redis
└── Private 10.x.20.0/24 (AZ-b) — ECS, RDS, Redis
```
