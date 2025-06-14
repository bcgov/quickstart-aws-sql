variable "target_env" {
  description = "AWS workload account env"
  type        = string
}
variable "app_env" {
  description = "The environment for the app, since multiple instances can be deployed to same dev environment of AWS, this represents whether it is PR or dev or test"
  type        = string
}

variable "app_name" {
  description  = " The APP name with environment (app_env)"
  type        = string
  validation {
    condition     = lower(var.app_name) == var.app_name
    error_message = "The app_name must be in lowercase."
  }
}

variable "aws_region" {
  type = string
  default = "ca-central-1"
}