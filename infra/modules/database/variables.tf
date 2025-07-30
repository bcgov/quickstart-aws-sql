variable "app_env" {
  description = "The environment for the app, since multiple instances can be deployed to same dev environment of AWS, this represents whether it is PR or dev or test"
  type        = string
  nullable    = false
}

variable "backup_retention_period" {
  description = "The number of days to retain automated backups"
  type        = number
  nullable    = false
}

variable "common_tags" {
  description = "Common tags to be applied to resources"
  type        = map(string)
  nullable    = false
}

variable "db_cluster_name" {
  description = "Name for the database cluster -- must be unique"
  type        = string
  nullable    = false
}

variable "db_database_name" {
  description = "The name of the database"
  type        = string
  nullable    = false
}

variable "db_master_username" {
  description = "The username for the DB master user"
  type        = string
  sensitive   = true
  nullable    = false
}

variable "ha_enabled" {
  description = "Whether to enable high availability mode of Aurora RDS cluster by adding a replica."
  type        = bool
  nullable    = false
}

variable "max_capacity" {
  description = "Maximum capacity for Aurora Serverless v2"
  type        = number
  nullable    = false
}

variable "min_capacity" {
  description = "Minimum capacity for Aurora Serverless v2"
  type        = number
  nullable    = false
}

variable "repo_name" {
  description = "Name of the repository for resource descriptions and tags"
  type        = string
  nullable    = false
}

variable "target_env" {
  description = "AWS workload account env"
  type        = string
  nullable    = false
}