variable "target_env" {
  description = "AWS workload account env"
  type        = string
}
variable "app_env" {
  description = "The environment for the app, since multiple instances can be deployed to same dev environment of AWS, this represents whether it is PR or dev or test"
  type        = string
}

variable "db_name" {
  description = "The default schema for Flyway"
  type        = string
  default     = "app"
}

variable "db_schema" {
  description = "The default schema for Flyway"
  type        = string
  default     = "app"
}

variable "subnet_app_a" {
  description = "Value of the name tag for a subnet in the APP security group"
  type = string
  default = "App_Dev_aza_net"
}

variable "subnet_app_b" {
  description = "Value of the name tag for a subnet in the APP security group"
  type = string
  default = "App_Dev_azb_net"
}
variable "subnet_web_a" {
  description = "Value of the name tag for a subnet in the APP security group"
  type = string
  default = "Web_Dev_aza_net"
}

variable "subnet_web_b" {
  description = "Value of the name tag for a subnet in the APP security group"
  type = string
  default = "Web_Dev_azb_net"
}


# Networking Variables
variable "subnet_data_a" {
  description = "Value of the name tag for a subnet in the DATA security group"
  type = string
  default = "Data_Dev_aza_net"
}

variable "subnet_data_b" {
  description = "Value of the name tag for a subnet in the DATA security group"
  type = string
  default = "Data_Dev_azb_net"
}

variable "app_port" {
  description = "The port of the API container"
  type        = number
  default     = 3000
}
variable "app_name" {
  description  = " The APP name with environment (app_env)"
  type        = string
}
variable "common_tags" {
  description = "Common tags to be applied to resources"
  type        = map(string)
  default     = {}
}
variable "flyway_image" {
  description = "The image for the Flyway container"
  type        = string
}
variable "api_image" {
  description = "The image for the API container"
  type        = string
}
variable "health_check_path" {
  description = "The path for the health check"
  type        = string
  default     = "/api/health"
  
}

variable "api_cpu" {
  type = number
  default     = "256"
}
variable "api_memory" {
  type = number
  default     = "512"
}
variable "aws_region" {
  type = string
  default = "ca-central-1"
}
variable "min_capacity" {
  type = number
  default = 1
}
variable "max_capacity" {
  type = number
  default = 5
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
## ECR Variables

variable "repository_names" {
  type        = list(string)
  default = [ "bcgov/quickstart-aws-containers" ]
  
}
variable "image_tag_mutability" {
  description = "Tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE."
  default     = "MUTABLE"
}

variable "image_scanning_enabled" {
  description = "Enable container image scanning for security issues."
  type        = bool
  default     = true
}

variable "read_principals" {
  description = "Defines which external principals are allowed to read from the ECR repository"
  type        = list(any)
  default     = []
}

variable "write_principals" {
  description = "Defines which external principals are allowed to write to the ECR repository"
  type        = list(any)
  default     = []
}

variable "tags" {
  description = "A set of of one or more tags to provide some metadata for the provisioned resources."
  type        = map(string)
  default     = {}
}