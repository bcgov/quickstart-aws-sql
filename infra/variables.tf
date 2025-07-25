variable "api_cpu" {
  description = "CPU units for the API service."
  type        = string
  nullable    = false
  default     = "256"
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
  default     = "512"
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
  default     = 3000
}

variable "aws_region" {
  description = "AWS region to deploy resources."
  type        = string
  nullable    = false
  default     = "ca-central-1"
}

variable "backup_retention_period" {
  description = "Backup retention period for the database."
  type        = number
  nullable    = false
  default     = 7
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
  default = ""
}

variable "db_database_name" {
  description = "Name of the database."
  type        = string
  nullable    = false
  default     = "app"
}

variable "db_master_username" {
  description = "Master username for the database."
  type        = string
  nullable    = false
  default     = "sysadmin"
}

variable "db_schema" {
  description = "Database schema name."
  type        = string
  nullable    = false
  default     = "app"
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
  default     = false
}

variable "health_check_path" {
  description = "Health check path for the API."
  type        = string
  nullable    = false
  default     = "/api/health"
}


variable "is_public_api" {
  description = "Whether the API is public."
  type        = bool
  nullable    = false
  default     = true
}
variable "api_max_capacity" {
  description = "Maximum capacity for the API service."
  type        = number
  nullable    = false
  default     = 3
}
variable "api_min_capacity" {
  description = "Minimum capacity for the API service."
  type        = number
  nullable    = false
  default     = 1
}
variable "aurora_max_capacity" {
  description = "Maximum capacity for scaling."
  type        = number
  nullable    = false
  default     = 1
}

variable "aurora_min_capacity" {
  description = "Minimum capacity for scaling."
  type        = number
  nullable    = false
  default     = 0
}

variable "postgres_pool_size" {
  description = "PostgreSQL connection pool size."
  type        = number
  nullable    = false
  default     = 1
}


variable "repo_name" {
  description = "Repository name."
  type        = string
  nullable    = false
}


variable "target_env" {
  description = "Target environment."
  type        = string
  nullable    = false
}

