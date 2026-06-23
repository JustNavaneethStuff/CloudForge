terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project    = "CloudForge"
      ManagedBy  = "Terraform"
      Component  = "bootstrap"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
