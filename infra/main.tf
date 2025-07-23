# -------------------------------------------------------------------
# Database Module (First)
# -------------------------------------------------------------------
module "database" {
  source = "./modules/database"

  app_env                 = var.app_env
  backup_retention_period = var.backup_retention_period
  common_tags             = var.common_tags
  db_cluster_name         = var.db_cluster_name
  db_database_name        = var.db_database_name
  db_master_username      = var.db_master_username
  ha_enabled              = var.ha_enabled
  helpers_module_version  = var.helpers_module_version
  max_capacity            = var.max_capacity
  min_capacity            = var.min_capacity
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
  db_cluster_name           = var.db_cluster_name != null ? var.db_cluster_name : ""
  db_name                   = var.db_database_name
  db_schema                 = var.db_schema
  ecr_image_retention_count = var.ecr_image_retention_count
  flyway_image              = var.flyway_image
  health_check_path         = var.health_check_path
  helpers_module_version    = var.helpers_module_version
  image_scanning_enabled    = var.image_scanning_enabled
  image_tag_mutability      = var.image_tag_mutability
  is_public_api             = var.is_public_api
  max_capacity              = var.max_capacity
  min_capacity              = var.min_capacity
  postgres_pool_size        = var.postgres_pool_size
  read_principals           = var.read_principals
  repo_name                 = var.repo_name
  repository_names          = var.repository_names
  subnet_app_a              = var.subnet_app_a
  subnet_app_b              = var.subnet_app_b
  subnet_data_a             = var.subnet_data_a
  subnet_data_b             = var.subnet_data_b
  subnet_web_a              = var.subnet_web_a
  subnet_web_b              = var.subnet_web_b
  tags                      = var.tags
  target_env                = var.target_env
  write_principals          = var.write_principals

  depends_on = [module.database]
}

# -------------------------------------------------------------------
# Frontend Module (Third)
# -------------------------------------------------------------------
module "frontend" {
  source = "./modules/frontend"

  app_env                = var.app_env
  app_name               = var.app_name
  aws_region             = var.aws_region
  common_tags            = var.common_tags
  helpers_module_version = var.helpers_module_version
  repo_name              = var.repo_name
  target_env             = var.target_env

  depends_on = [module.api]
}