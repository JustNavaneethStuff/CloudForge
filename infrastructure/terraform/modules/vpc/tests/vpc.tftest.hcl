mock_provider "aws" {}

variables {
  name_prefix          = "test"
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["ap-south-2a", "ap-south-2b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
  nat_gateway_count    = 1
  enable_vpc_endpoints = false
  tags                 = { Environment = "test" }
}

run "vpc_cidr_block" {
  command = plan

  assert {
    condition     = aws_vpc.main.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR must match input variable"
  }
}

run "public_subnet_count" {
  command = plan

  assert {
    condition     = length(aws_subnet.public) == 2
    error_message = "Must create one public subnet per AZ"
  }
}

run "private_subnet_count" {
  command = plan

  assert {
    condition     = length(aws_subnet.private) == 2
    error_message = "Must create one private subnet per AZ"
  }
}
