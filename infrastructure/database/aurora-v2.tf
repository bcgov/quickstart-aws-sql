# Import common configurations
module "common" {
  source = "../modules/common"
  
  target_env    = var.target_env
  app_env       = var.app_env
  app_name      = var.db_cluster_name
  repo_name     = var.repo_name
  common_tags   = var.common_tags
}

# Import networking configurations
module "networking" {
  source = "../modules/networking"
  target_env = var.target_env
}

data "aws_kms_alias" "rds_key" {
  name = "alias/aws/rds"
}
data "aws_caller_identity" "current" {}

resource "random_password" "db_master_password" {
  length           = 12
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_subnet_group" "db_subnet_group" {
  description = "For Aurora cluster ${var.db_cluster_name}"
  name        = "${var.db_cluster_name}-subnet-group"
  subnet_ids  = module.networking.subnets.data.ids
  tags = module.common.common_tags
}

data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "17.4"
}


resource "aws_secretsmanager_secret" "db_mastercreds_secret" {
  name = "${var.db_cluster_name}"
  tags = module.common.common_tags
}

resource "aws_secretsmanager_secret_version" "db_mastercreds_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_mastercreds_secret.id
  secret_string = <<EOF
   {
    "username": "${var.db_master_username}",
    "password": "${random_password.db_master_password.result}"
   }
EOF
}
module "aurora_postgresql_v2" {
  source = "terraform-aws-modules/rds-aurora/aws"
  version = "9.15.0"
  allow_major_version_upgrade = true
  name              = var.db_cluster_name
  engine            = data.aws_rds_engine_version.postgresql.engine
  engine_mode       = "provisioned"
  engine_version    = data.aws_rds_engine_version.postgresql.version
  storage_encrypted = true
  database_name     = var.db_database_name
  
  vpc_id                 = module.networking.vpc.id
  vpc_security_group_ids = [module.networking.security_groups.data.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  
  master_username = var.db_master_username
  master_password = random_password.db_master_password.result
  manage_master_user_password = false
  
  
  create_security_group  = false
  create_db_subnet_group = false
  create_monitoring_role = false
  
  apply_immediately   = true
  skip_final_snapshot = true
  auto_minor_version_upgrade = true

  deletion_protection = contains(["prod"], var.app_env) ? true : false
  serverlessv2_scaling_configuration = {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  instance_class = "db.serverless"
  instances = var.ha_enabled ? {
    one = {}
    two = {}
  }: {one = {}}
  
  tags = module.common.common_tags

  enabled_cloudwatch_logs_exports = ["postgresql"]
  backup_retention_period = "${var.backup_retention_period}"
}
output "ha_enabled" {
  value = var.ha_enabled
}


