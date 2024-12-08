output "master_creds" {
  value = data.aws_secretsmanager_secret.db-master-creds.secret_string
}
