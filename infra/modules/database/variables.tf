variable "app_env" {
  description = "The environment for the app, since multiple instances can be deployed to same dev environment of AWS, this represents whether it is PR or dev or test"
  type        = string
}

variable "backup_retention_period" {
  description = "The number of days to retain automated backups"
  type        = number
  default     = 7
}

variable "common_tags" {
  description = "Common tags to be applied to resources"
  type        = map(string)
  default     = {}
}

variable "db_cluster_name" {
  description = "Name for the database cluster -- must be unique"
  type        = string
}

variable "db_database_name" {
  description = "The name of the database"
  type        = string
  default     = "app"
}

variable "db_master_username" {
  description = "The username for the DB master user"
  type        = string
  default     = "sysadmin"
  sensitive   = true
}

variable "ha_enabled" {
  description = "Whether to enable high availability mode of Aurora RDS cluster by adding a replica."
  type        = bool
  default     = true
}
variable "helpers_module_version" {
  description = "Version of the quickstart aws helpers module."
  type        = string
  nullable    = false
}
variable "max_capacity" {
  description = "Maximum capacity for Aurora Serverless v2"
  type        = number
  default     = 1.0
}

variable "min_capacity" {
  description = "Minimum capacity for Aurora Serverless v2"
  type        = number
  default     = 0
}

variable "repo_name" {
  description = "Name of the repository for resource descriptions and tags"
  type        = string
}

variable "target_env" {
  description = "AWS workload account env"
  type        = string
}