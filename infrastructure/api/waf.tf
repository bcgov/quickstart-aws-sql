provider "aws" {
    alias  = "cloudfront_waf"
    region = "us-east-1" # WAF is only available in us-east-1 for CloudFront
}

# WAF for API (if public API)
module "waf_api" {
  count  = var.is_public_api ? 1 : 0
  source = "../modules/waf"
  
  name                    = "${var.app_name}-api-cf-waf"
  description             = "API CloudFront WAF Rules"
  scope                   = "CLOUDFRONT"
  enable_rate_limiting    = true
  rate_limit             = 50
  enable_ip_reputation    = true
  enable_common_rules     = true
  enable_bad_inputs       = true
  enable_linux_rules      = true
  enable_sqli_rules       = true
  tags                    = module.common.common_tags
  
  providers = {
    aws = aws.cloudfront_waf  # us-east-1 provider
  }
}

# CloudFront logs bucket for API (if public API)
module "cloudfront_api_logs" {
  count  = var.is_public_api ? 1 : 0
  source = "../modules/s3-cloudfront-logs"
  
  bucket_name = "cf-api-logs-${var.app_name}"
  log_prefix  = "cf/api/"
  tags        = module.common.common_tags
}

# CloudFront distribution for API (if public API)
module "cloudfront_api" {
  count  = var.is_public_api ? 1 : 0
  source = "../modules/cloudfront"
  
  app_name          = var.app_name
  repo_name         = var.repo_name
  distribution_type = "api"
  enabled          = true
  
  # API Origin Configuration
  api_origin_domain_name     = "${module.api_gateway.api_id}.execute-api.${var.aws_region}.amazonaws.com"
  api_origin_id             = "http-api-origin"
  api_origin_protocol_policy = "https-only"
  api_origin_ssl_protocols   = ["TLSv1.2"]
  
  # WAF Integration
  web_acl_arn = module.waf_api[0].web_acl_arn
  
  # Logging Configuration
  enable_logging             = true
  log_bucket_domain_name     = "${module.cloudfront_api_logs[0].bucket_name}.s3.amazonaws.com"
  log_prefix                = "cf/api/"
  log_include_cookies       = true
  
  # Cache Behavior (optimized for API)
  cache_allowed_methods          = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "DELETE", "PATCH"]
  cache_cached_methods           = ["GET", "HEAD"]
  cache_viewer_protocol_policy   = "https-only"
  cache_min_ttl                 = 0
  cache_default_ttl             = 60    # 1 minute for API responses
  cache_max_ttl                 = 60
  cache_forward_query_string     = true
  cache_forward_cookies         = "all"
  
  # Geo Restrictions
  geo_restriction_type = "none"
  
  # SSL Configuration
  use_cloudfront_default_certificate = true
  
  tags = module.common.common_tags
  
  providers = {
    aws = aws.cloudfront_waf
  }
}
