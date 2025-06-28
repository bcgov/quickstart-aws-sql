variable "target_env" {
  description = "Target environment (dev, test, prod, tools, unclass)"
  type        = string
  
  validation {
    condition     = contains(["dev", "test", "prod", "tools", "unclass"], var.target_env)
    error_message = "Target environment must be one of: dev, test, prod, tools, unclass."
  }
}

variable "availability_zones" {
  description = "List of availability zone suffixes (e.g., ['a', 'b'])"
  type        = list(string)
  default     = ["a", "b"]
}

variable "security_group_name_suffix" {
  description = "Suffix for security group names"
  type        = string
  default     = "_sg"
}
