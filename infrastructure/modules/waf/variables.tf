# WAF Module Variables
variable "name" {
  description = "Name for the WAF ACL"
  type        = string
}

variable "scope" {
  description = "Scope of the WAF ACL (CLOUDFRONT or REGIONAL)"
  type        = string
  default     = "CLOUDFRONT"
  
  validation {
    condition     = contains(["CLOUDFRONT", "REGIONAL"], var.scope)
    error_message = "Scope must be either CLOUDFRONT or REGIONAL."
  }
}

variable "description" {
  description = "Description for the WAF ACL"
  type        = string
  default     = "WAF ACL with AWS managed rules"
}

variable "default_action" {
  description = "Default action for the WAF ACL (allow or block)"
  type        = string
  default     = "allow"
  
  validation {
    condition     = contains(["allow", "block"], var.default_action)
    error_message = "Default action must be either allow or block."
  }
}

variable "enable_rate_limiting" {
  description = "Enable rate limiting rule"
  type        = bool
  default     = true
}

variable "rate_limit" {
  description = "Rate limit per IP address (requests per 5 minutes)"
  type        = number
  default     = 50
}

variable "enable_ip_reputation" {
  description = "Enable IP reputation list rule"
  type        = bool
  default     = true
}

variable "enable_common_rules" {
  description = "Enable common rule set"
  type        = bool
  default     = true
}

variable "enable_bad_inputs" {
  description = "Enable known bad inputs rule set"
  type        = bool
  default     = true
}

variable "enable_linux_rules" {
  description = "Enable Linux-specific rule set"
  type        = bool
  default     = true
}

variable "enable_sqli_rules" {
  description = "Enable SQL injection rule set"
  type        = bool
  default     = true
}

variable "cloudwatch_metrics_enabled" {
  description = "Enable CloudWatch metrics"
  type        = bool
  default     = true
}

variable "sampled_requests_enabled" {
  description = "Enable sampled requests"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
