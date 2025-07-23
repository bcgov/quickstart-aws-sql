variable "api_cpu" {
  description = "CPU units for the API service."
  type        = string
  nullable    = false
}

variable "api_image" {
  description = "Docker image for the API service."
  type        = string
  nullable    = false
}

variable "api_memory" {
  description = "Memory for the API service."
  type        = string
  nullable    = false
}

variable "app_env" {
  description = "Application environment (e.g., dev, prod)."
  type        = string
  nullable    = false
}

variable "app_name" {
  description = "Name of the application."
  type        = string
  nullable    = false
}

variable "app_port" {
  description = "Port for the application."
  type        = number
  nullable    = false
}

variable "aws_region" {
  description = "AWS region to deploy resources."
  type        = string
  nullable    = false
}

variable "backup_retention_period" {
  description = "Backup retention period for the database."
  type        = number
  nullable    = false
}

variable "common_tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
  nullable    = false
}

variable "db_cluster_name" {
  description = "Name of the database cluster."
  type        = string
  nullable    = false
}

variable "db_database_name" {
  description = "Name of the database."
  type        = string
  nullable    = false
}

variable "db_master_username" {
  description = "Master username for the database."
  type        = string
  nullable    = false
}

variable "db_schema" {
  description = "Database schema name."
  type        = string
  nullable    = false
}

variable "ecr_image_retention_count" {
  description = "ECR image retention count."
  type        = number
  nullable    = false
}

variable "flyway_image" {
  description = "Flyway image for database migrations."
  type        = string
  nullable    = false
}

variable "ha_enabled" {
  description = "Enable high availability for the database."
  type        = bool
  nullable    = false
}

variable "health_check_path" {
  description = "Health check path for the API."
  type        = string
  nullable    = false
}

variable "image_scanning_enabled" {
  description = "Enable image scanning for ECR."
  type        = bool
  nullable    = false
}

variable "image_tag_mutability" {
  description = "Image tag mutability for ECR."
  type        = string
  nullable    = false
}

variable "is_public_api" {
  description = "Whether the API is public."
  type        = bool
  nullable    = false
}

variable "max_capacity" {
  description = "Maximum capacity for scaling."
  type        = number
  nullable    = false
}

variable "min_capacity" {
  description = "Minimum capacity for scaling."
  type        = number
  nullable    = false
}

variable "postgres_pool_size" {
  description = "PostgreSQL connection pool size."
  type        = number
  nullable    = false
}

variable "read_principals" {
  description = "Principals allowed read access."
  type        = list(string)
  nullable    = false
}

variable "repo_name" {
  description = "Repository name."
  type        = string
  nullable    = false
}

variable "repository_names" {
  description = "List of repository names."
  type        = list(string)
  nullable    = false
}

variable "subnet_app_a" {
  description = "Subnet for app A."
  type        = string
  nullable    = false
}

variable "subnet_app_b" {
  description = "Subnet for app B."
  type        = string
  nullable    = false
}

variable "subnet_data_a" {
  description = "Subnet for data A."
  type        = string
  nullable    = false
}

variable "subnet_data_b" {
  description = "Subnet for data B."
  type        = string
  nullable    = false
}

variable "subnet_web_a" {
  description = "Subnet for web A."
  type        = string
  nullable    = false
}

variable "subnet_web_b" {
  description = "Subnet for web B."
  type        = string
  nullable    = false
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  nullable    = false
}

variable "target_env" {
  description = "Target environment."
  type        = string
  nullable    = false
}

variable "write_principals" {
  description = "Principals allowed write access."
  type        = list(string)
  nullable    = false
}
