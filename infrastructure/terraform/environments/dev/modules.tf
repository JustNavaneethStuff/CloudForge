module "vpc" {
  source = "../../modules/vpc"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  availability_zones   = local.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  nat_gateway_count    = var.nat_gateway_count
  enable_vpc_endpoints = var.enable_vpc_endpoints
  tags                 = local.common_tags
}

module "security_groups" {
  source = "../../modules/security-groups"

  name_prefix  = local.name_prefix
  vpc_id       = module.vpc.vpc_id
  app_port     = var.app_port
  enable_https = var.enable_https
  tags         = local.common_tags
}

module "ecr" {
  source = "../../modules/ecr"

  name_prefix = local.name_prefix
  tags        = local.common_tags
}

module "secrets" {
  source = "../../modules/secrets"

  name_prefix = local.name_prefix
  db_username = var.db_username
  db_name     = var.db_name
  tags        = local.common_tags
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${local.name_prefix}"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecs-logs"
  })
}

module "iam" {
  source = "../../modules/iam"

  name_prefix        = local.name_prefix
  aws_region         = var.aws_region
  ecr_repository_arn = module.ecr.repository_arn
  secrets_arns       = module.secrets.all_secret_arns
  log_group_arn      = aws_cloudwatch_log_group.ecs.arn
  github_org         = var.github_org
  github_repo        = var.github_repo
  enable_github_oidc = var.enable_github_oidc
  state_bucket_arn   = var.state_bucket_arn
  lock_table_arn     = var.lock_table_arn
  tags               = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  name_prefix             = local.name_prefix
  subnet_ids              = module.vpc.private_subnet_ids
  security_group_ids      = [module.security_groups.rds_security_group_id]
  db_name                 = module.secrets.db_name
  db_username             = module.secrets.db_username
  db_password             = module.secrets.db_password
  instance_class          = var.rds_instance_class
  multi_az                = var.rds_multi_az
  backup_retention_period = var.rds_backup_retention
  deletion_protection     = var.rds_deletion_protection
  skip_final_snapshot     = var.rds_skip_final_snapshot
  tags                    = local.common_tags
}

module "elasticache" {
  source = "../../modules/elasticache"

  name_prefix        = local.name_prefix
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security_groups.redis_security_group_id]
  auth_token         = module.secrets.redis_auth_token
  node_type          = var.redis_node_type
  num_cache_nodes    = var.redis_num_nodes
  tags               = local.common_tags
}

module "route53" {
  count  = var.enable_https ? 1 : 0
  source = "../../modules/route53"

  domain_name   = var.domain_name
  api_subdomain = var.api_subdomain
  tags          = local.common_tags
}

module "alb" {
  source = "../../modules/alb"

  name_prefix        = local.name_prefix
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [module.security_groups.alb_security_group_id]
  app_port           = var.app_port
  enable_https       = var.enable_https
  certificate_arn    = var.enable_https ? module.route53[0].certificate_arn : ""
  tags               = local.common_tags

  depends_on = [module.route53]
}

module "ecs" {
  source = "../../modules/ecs"

  name_prefix             = local.name_prefix
  aws_region              = var.aws_region
  subnet_ids              = module.vpc.private_subnet_ids
  security_group_ids      = [module.security_groups.ecs_security_group_id]
  task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn           = module.iam.ecs_task_role_arn
  image_uri               = "${module.ecr.repository_url}:${var.image_tag}"
  app_port                = var.app_port
  cpu                     = var.ecs_cpu
  memory                  = var.ecs_memory
  desired_count           = var.ecs_desired_count
  target_group_arn        = module.alb.target_group_arn
  log_group_name          = aws_cloudwatch_log_group.ecs.name
  enable_autoscaling      = var.ecs_enable_autoscaling
  min_capacity            = var.ecs_min_capacity
  max_capacity            = var.ecs_max_capacity

  environment_variables = [
    { name = "APP_ENV", value = var.environment },
    { name = "LOG_LEVEL", value = var.log_level },
    { name = "DB_HOST", value = module.rds.db_endpoint },
    { name = "DB_PORT", value = tostring(module.rds.db_port) },
    { name = "DB_NAME", value = module.secrets.db_name },
    { name = "DB_USER", value = module.secrets.db_username },
    { name = "REDIS_HOST", value = module.elasticache.redis_endpoint },
    { name = "REDIS_PORT", value = tostring(module.elasticache.redis_port) },
    { name = "REDIS_SSL", value = "true" },
  ]

  secrets = [
    { name = "DB_PASSWORD", valueFrom = "${module.secrets.db_credentials_secret_arn}:password::" },
    { name = "REDIS_AUTH_TOKEN", valueFrom = "${module.secrets.redis_auth_secret_arn}:auth_token::" },
  ]

  tags = local.common_tags

  depends_on = [module.rds, module.elasticache, module.alb]
}

module "monitoring" {
  source = "../../modules/monitoring"

  name_prefix             = local.name_prefix
  environment             = var.environment
  log_group_name          = aws_cloudwatch_log_group.ecs.name
  log_retention_days      = var.log_retention_days
  alert_email             = var.alert_email
  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  ecs_cluster_name        = module.ecs.cluster_name
  ecs_service_name        = module.ecs.service_name
  rds_instance_id         = module.rds.db_instance_id
  desired_task_count      = var.ecs_desired_count
  tags                    = local.common_tags
}

resource "aws_route53_record" "api" {
  count = var.enable_https ? 1 : 0

  zone_id = module.route53[0].hosted_zone_id
  name    = "${var.api_subdomain}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_secretsmanager_secret_version" "app_config" {
  secret_id = module.secrets.app_config_secret_arn

  secret_string = jsonencode({
    db_host    = module.rds.db_endpoint
    db_port    = module.rds.db_port
    redis_host = module.elasticache.redis_endpoint
    redis_port = module.elasticache.redis_port
    app_env    = var.environment
  })
}
