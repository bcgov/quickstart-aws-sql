variable "api_cpu" {
  type     = number
  nullable = false
}

variable "api_image" {
  description = "The image for the API container"
  type        = string
  nullable    = false
}

variable "api_memory" {
  type     = number
  nullable = false
}

variable "app_env" {
  description = "The environment for the app, since multiple instances can be deployed to same dev environment of AWS, this represents whether it is PR or dev or test"
  type        = string
  nullable    = false
}

variable "app_name" {
  description = " The APP name with environment (app_env)"
  type        = string
  nullable    = false
}

variable "app_port" {
  description = "The port of the API container"
  type        = number
  nullable    = false
}

variable "aws_region" {
  type     = string
  nullable = false
}

variable "common_tags" {
  description = "Common tags to be applied to resources"
  type        = map(string)
  nullable    = false
}

variable "db_cluster_name" {
  description = "Name of the database cluster"
  type        = string
  nullable    = false
}

variable "db_name" {
  description = "The default schema for Flyway"
  type        = string
  nullable    = false
}

variable "db_schema" {
  description = "The default schema for Flyway"
  type        = string
  nullable    = false
}


variable "flyway_image" {
  description = "The image for the Flyway container"
  type        = string
  nullable    = false
}

variable "health_check_path" {
  description = "The path for the health check"
  type        = string
  nullable    = false
}

variable "is_public_api" {
  description = "Flag to indicate if the API is public or private"
  type        = bool
  nullable    = false
}

variable "max_capacity" {
  type        = number
  nullable    = false
  description = <<EOT
    The maximum number of tasks to run, please consider,
    connection pooling and other factors when setting this value, 
    also depends on aurora v2 scaling params
    follow this link, 
    https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.setting-capacity.html#aurora-serverless-v2.parameter-groups
    The max_connections value for Aurora Serverless v2DB instances is based on the memory size
    derived from the maximum ACUs. 
    However, when you specify a minimum capacity of 0 or 0.5 ACUs on PostgreSQL-compatible DB instances,
    the maximum value of max_connections is capped at 2,000.

    In most cases, 0.5 min and 1 max ACU does the work, which means scaling can be upto 189 max connections,
    API contianer has 5 connections per task, so 189/5 = 37 tasks.
    if going beyond 37 tasks, consider increasing the max acu from 1 to 2.
  EOT
}

variable "min_capacity" {
  type     = number
  nullable = false
}

variable "postgres_pool_size" {
  description = "The size of the connection pool for the API"
  type        = string
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

