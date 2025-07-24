# -------------------------------------------------------------------
# Database Module (First)
# -------------------------------------------------------------------
module "database" {
  source = "./modules/database"

  app_env                 = var.app_env
  backup_retention_period = var.backup_retention_period
  common_tags             = var.common_tags
  db_cluster_name         = var.db_cluster_name == "" ? "${var.repo_name}-aurora-${var.target_env}" : var.db_cluster_name
  db_database_name        = var.db_database_name
  db_master_username      = var.db_master_username
  ha_enabled              = var.ha_enabled
  max_capacity            = var.aurora_max_capacity
  min_capacity            = var.aurora_min_capacity
  repo_name               = var.repo_name
  target_env              = var.target_env
}

# -------------------------------------------------------------------
# API Module (Second)
# -------------------------------------------------------------------
module "api" {
  source = "./modules/api"

  api_cpu                   = var.api_cpu
  api_image                 = var.api_image
  api_memory                = var.api_memory
  app_env                   = var.app_env
  app_name                  = var.app_name
  app_port                  = var.app_port
  aws_region                = var.aws_region
  common_tags               = var.common_tags
  db_cluster_name           = var.db_cluster_name
  db_name                   = var.db_database_name
  db_schema                 = var.db_schema
  flyway_image              = var.flyway_image
  health_check_path         = var.health_check_path
  is_public_api             = var.is_public_api
  max_capacity              = var.api_max_capacity
  min_capacity              = var.api_min_capacity
  postgres_pool_size        = var.postgres_pool_size
  repo_name                 = var.repo_name
  target_env                = var.target_env

  depends_on = [module.database]
}

# -------------------------------------------------------------------
# Frontend Module (Third)
# -------------------------------------------------------------------
module "frontend" {
  source = "./modules/frontend"

  app_env                = var.app_env
  app_name               = var.app_name
  common_tags            = var.common_tags
  repo_name              = var.repo_name
  target_env             = var.target_env

  depends_on = [module.api]
}