mock_provider "aws" {}

variables {
  name_prefix  = "test"
  vpc_id       = "vpc-0123456789abcdef0"
  app_port     = 8000
  enable_https = false
  tags         = { Environment = "test" }
}

run "alb_security_group_created" {
  command = plan

  assert {
    condition     = aws_security_group.alb.vpc_id == "vpc-0123456789abcdef0"
    error_message = "ALB security group must attach to provided VPC"
  }
}

run "ecs_allows_alb_ingress" {
  command = plan

  assert {
    condition     = aws_security_group.ecs.name == "test-ecs-sg"
    error_message = "ECS security group name must use name prefix"
  }
}

run "rds_restricts_to_ecs" {
  command = plan

  assert {
    condition     = aws_security_group.rds.name == "test-rds-sg"
    error_message = "RDS security group name must use name prefix"
  }
}
