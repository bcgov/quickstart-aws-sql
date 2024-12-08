data "aws_secretsmanager_secret" "db_master_creds" {
  name = "db-master-creds-${var.target_env}"
}



data "aws_rds_cluster" "rds_cluster" {
  cluster_identifier = "qsawsc-aurora-cluster-${var.target_env}"
}

output "db_master_creds" {
  value = data.aws_secretsmanager_secret.db_master_creds.secret_string
}
output "database_endpoint" {
  value = data.aws_rds_cluster.rds_cluster.endpoint
}