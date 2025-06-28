variable "target_env" {
  description = "AWS workload account environment (dev, test, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "test", "prod"], var.target_env)
    error_message = "Target environment must be one of: dev, test, prod, tools, unclass."
  }
}

variable "app_env" {
  description = "The environment for the app (since multiple instances can be deployed to same AWS env, this represents whether it is PR, dev, or test)"
  type        = string
}

variable "app_name" {
  description = "The APP name with environment (app_env)"
  type        = string
  
  validation {
    condition     = lower(var.app_name) == var.app_name
    error_message = "The app_name must be in lowercase."
  }
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "repo_name" {
  description = "Name of the repository for resource descriptions and tags"
  type        = string
}

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "ca-central-1"
}

# Optional variables with sensible defaults
variable "force_destroy" {
  description = "Default force destroy setting for development resources"
  type        = bool
  default     = true
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for production resources"
  type        = bool
  default     = false
}

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery for production databases"
  type        = bool
  default     = false
}
