terraform {
  required_version = ">= 1.7"

  backend "s3" {
    # Configured via backend.hcl or -backend-config flags
    # bucket         = "cloudforge-terraform-state-ACCOUNT_ID"
    # key            = "cloudforge/dev/terraform.tfstate"
    # region         = "us-east-1"
    # dynamodb_table = "cloudforge-terraform-locks"
    # encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name_prefix = "cloudforge-${var.environment}"
  azs         = slice(data.aws_availability_zones.available.names, 0, 2)

  common_tags = {
    Project     = "CloudForge"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
