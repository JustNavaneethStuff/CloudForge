# Alternative Designs

## 1. Lambda + API Gateway

**Design:** Serverless API with Lambda functions, API Gateway, DynamoDB.

**Pros:** Pay-per-request, zero idle cost, auto-scaling.

**Cons:** Cold starts, 15-minute timeout, vendor-specific patterns, harder local dev.

**Why not chosen:** ECS Fargate better demonstrates container orchestration skills expected in platform/DevOps roles.

## 2. Kubernetes (EKS)

**Design:** EKS cluster with Helm charts, ingress controller, HPA.

**Pros:** Industry standard for large-scale container orchestration, portable workloads.

**Cons:** Control plane cost (~$73/mo), node management, steep learning curve for a portfolio project.

**Why not chosen:** Operational overhead exceeds project scope; Fargate achieves similar outcomes with less complexity.

## 3. EC2 Auto Scaling Group

**Design:** EC2 instances behind ALB with Ansible/user-data bootstrap.

**Pros:** Full OS control, lower cost at steady high utilization.

**Cons:** Patching, AMI management, scaling slower than containers.

**Why not chosen:** Containers are the industry direction; ECS abstracts host management.

## 4. Serverless Database (Aurora Serverless v2)

**Design:** Aurora Serverless with auto-scaling capacity.

**Pros:** Scales to zero-ish, no instance sizing.

**Cons:** Higher cost at sustained load, cold start on scale-from-zero.

**Why not chosen:** RDS t4g.micro is cost-effective for demo/dev workloads.

## 5. Multi-Region Active-Active

**Design:** Deploy stacks in two regions with Route53 latency routing.

**Pros:** Regional failure tolerance, lower latency globally.

**Cons:** 2× infrastructure cost, data replication complexity.

**Why not chosen:** Single-region sufficient for portfolio; documented as DR upgrade path.

## 6. Terraform Cloud / Spacelift

**Design:** Managed Terraform runs with remote execution and policy-as-code.

**Pros:** No self-managed state, team collaboration, run history.

**Cons:** Cost, vendor dependency.

**Why not chosen:** Self-managed S3 state demonstrates bootstrap and state management skills.
