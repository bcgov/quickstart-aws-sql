# CloudFront Module Variables
variable "app_name" {
  description = "Application name for resource naming"
  type        = string
}

variable "repo_name" {
  description = "Repository name for resource descriptions"
  type        = string
}

variable "distribution_type" {
  description = "Type of CloudFront distribution (s3 or api)"
  type        = string
  default     = "s3"
  
  validation {
    condition     = contains(["s3", "api"], var.distribution_type)
    error_message = "Distribution type must be either 's3' or 'api'."
  }
}

variable "enabled" {
  description = "Enable the CloudFront distribution"
  type        = bool
  default     = true
}

variable "is_ipv6_enabled" {
  description = "Enable IPv6 for the CloudFront distribution"
  type        = bool
  default     = true
}

variable "default_root_object" {
  description = "Default root object for S3 distributions"
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "Price class for the CloudFront distribution"
  type        = string
  default     = "PriceClass_100"
  
  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.price_class)
    error_message = "Price class must be PriceClass_All, PriceClass_200, or PriceClass_100."
  }
}

variable "web_acl_arn" {
  description = "ARN of the WAF Web ACL to associate with the distribution"
  type        = string
  default     = null
}

variable "enable_logging" {
  description = "Enable CloudFront access logging"
  type        = bool
  default     = true
}

variable "log_bucket_domain_name" {
  description = "Domain name of the S3 bucket for CloudFront logs"
  type        = string
  default     = null
}

variable "log_prefix" {
  description = "Prefix for CloudFront log files"
  type        = string
  default     = ""
}

variable "log_include_cookies" {
  description = "Include cookies in CloudFront logs"
  type        = bool
  default     = false
}

# S3 Origin Configuration
variable "s3_origin_domain_name" {
  description = "Domain name of the S3 bucket origin"
  type        = string
  default     = null
}

variable "s3_origin_id" {
  description = "Origin ID for S3 bucket"
  type        = string
  default     = null
}

variable "s3_origin_access_identity_path" {
  description = "CloudFront access identity path for S3 origin"
  type        = string
  default     = null
}

# API Origin Configuration
variable "api_origin_domain_name" {
  description = "Domain name of the API origin"
  type        = string
  default     = null
}

variable "api_origin_id" {
  description = "Origin ID for API"
  type        = string
  default     = "http-api-origin"
}

variable "api_origin_protocol_policy" {
  description = "Protocol policy for API origin"
  type        = string
  default     = "https-only"
}

variable "api_origin_http_port" {
  description = "HTTP port for API origin"
  type        = number
  default     = 80
}

variable "api_origin_https_port" {
  description = "HTTPS port for API origin"
  type        = number
  default     = 443
}

variable "api_origin_ssl_protocols" {
  description = "SSL protocols for API origin"
  type        = list(string)
  default     = ["TLSv1.2"]
}

# Cache Behavior Configuration
variable "cache_allowed_methods" {
  description = "HTTP methods allowed for caching"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cache_cached_methods" {
  description = "HTTP methods to cache"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cache_viewer_protocol_policy" {
  description = "Viewer protocol policy"
  type        = string
  default     = "redirect-to-https"
}

variable "cache_min_ttl" {
  description = "Minimum TTL for cached objects"
  type        = number
  default     = 0
}

variable "cache_default_ttl" {
  description = "Default TTL for cached objects"
  type        = number
  default     = 3600
}

variable "cache_max_ttl" {
  description = "Maximum TTL for cached objects"
  type        = number
  default     = 86400
}

variable "cache_forward_query_string" {
  description = "Forward query strings to origin"
  type        = bool
  default     = false
}

variable "cache_forward_cookies" {
  description = "Cookie forwarding policy (none, whitelist, all)"
  type        = string
  default     = "none"
  
  validation {
    condition     = contains(["none", "whitelist", "all"], var.cache_forward_cookies)
    error_message = "Cache forward cookies must be none, whitelist, or all."
  }
}

# Geo Restriction Configuration
variable "geo_restriction_type" {
  description = "Type of geo restriction (none, whitelist, blacklist)"
  type        = string
  default     = "none"
  
  validation {
    condition     = contains(["none", "whitelist", "blacklist"], var.geo_restriction_type)
    error_message = "Geo restriction type must be none, whitelist, or blacklist."
  }
}

variable "geo_restriction_locations" {
  description = "List of country codes for geo restriction"
  type        = list(string)
  default     = []
}

# SSL Configuration
variable "ssl_support_method" {
  description = "SSL support method (sni-only or vip)"
  type        = string
  default     = "sni-only"
}

variable "minimum_protocol_version" {
  description = "Minimum SSL protocol version"
  type        = string
  default     = "TLSv1.2_2021"
}

variable "use_cloudfront_default_certificate" {
  description = "Use CloudFront default certificate"
  type        = bool
  default     = true
}

variable "acm_certificate_arn" {
  description = "ARN of ACM certificate for custom domain"
  type        = string
  default     = null
}

variable "aliases" {
  description = "List of domain aliases for the distribution"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to the CloudFront distribution"
  type        = map(string)
  default     = {}
}
