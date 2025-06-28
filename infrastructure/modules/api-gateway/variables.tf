# API Gateway Module Variables
variable "api_name" {
  description = "Name for the API Gateway"
  type        = string
}

variable "protocol_type" {
  description = "Protocol type for the API Gateway (HTTP or WEBSOCKET)"
  type        = string
  default     = "HTTP"
  
  validation {
    condition     = contains(["HTTP", "WEBSOCKET"], var.protocol_type)
    error_message = "Protocol type must be HTTP or WEBSOCKET."
  }
}

variable "vpc_link_name" {
  description = "Name for the VPC Link"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs for the VPC Link"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the VPC Link"
  type        = list(string)
}

variable "integration_type" {
  description = "Integration type (HTTP_PROXY, AWS_PROXY, etc.)"
  type        = string
  default     = "HTTP_PROXY"
}

variable "integration_method" {
  description = "Integration method (ANY, GET, POST, etc.)"
  type        = string
  default     = "ANY"
}

variable "integration_uri" {
  description = "Integration URI (ALB listener ARN or other target)"
  type        = string
}

variable "route_key" {
  description = "Route key for the API Gateway route"
  type        = string
  default     = "ANY /{proxy+}"
}

variable "stage_name" {
  description = "Name for the API Gateway stage"
  type        = string
  default     = "$default"
}

variable "auto_deploy" {
  description = "Enable auto-deploy for the stage"
  type        = bool
  default     = true
}

variable "enable_cors" {
  description = "Enable CORS for the API"
  type        = bool
  default     = false
}

variable "cors_configuration" {
  description = "CORS configuration for the API"
  type = object({
    allow_credentials = optional(bool, false)
    allow_headers     = optional(list(string), [])
    allow_methods     = optional(list(string), ["*"])
    allow_origins     = optional(list(string), ["*"])
    expose_headers    = optional(list(string), [])
    max_age          = optional(number, 0)
  })
  default = {
    allow_credentials = false
    allow_headers     = []
    allow_methods     = ["*"]
    allow_origins     = ["*"]
    expose_headers    = []
    max_age          = 0
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
