# Import common configurations
module "common" {
  source = "git::https://github.com/bcgov/quickstart-aws-helpers.git//terraform/modules/common?ref=v0.0.5"
  
  target_env    = var.target_env
  app_env       = var.app_env
  app_name      = var.app_name
  repo_name     = var.repo_name
  common_tags   = var.common_tags
}

# Create the frontend S3 bucket using the secure bucket module
module "frontend_bucket" {
  source = "git::https://github.com/bcgov/quickstart-aws-helpers.git//terraform/modules/s3-secure-bucket?ref=v0.0.5"
  
  bucket_name                = "${var.app_name}-static-assets"
  force_destroy              = true
  encryption_algorithm       = "AES256"
  enable_public_access_block = true
  enable_versioning          = false
  tags                       = module.common.common_tags
}

# Create CloudFront Origin Access Identity
module "cloudfront_oai" {
  source = "git::https://github.com/bcgov/quickstart-aws-helpers.git//terraform/modules/cloudfront-oai?ref=v0.0.5"
  
  comment         = "OAI for ${var.app_name} site."
  s3_bucket_name  = module.frontend_bucket.bucket_name
  s3_bucket_arn   = module.frontend_bucket.bucket_arn
}

# Create CloudFront logs bucket
module "cloudfront_logs" {
  source = "git::https://github.com/bcgov/quickstart-aws-helpers.git//terraform/modules/s3-cloudfront-logs?ref=v0.0.5"
  
  bucket_name = "${var.app_name}-cf-logs"
  log_prefix  = "${var.app_name}/cloudfront-logs/"
  tags        = module.common.common_tags
}

# Create CloudFront distribution using the CloudFront module
module "cloudfront_distribution" {
  source = "git::https://github.com/bcgov/quickstart-aws-helpers.git//terraform/modules/cloudfront?ref=v0.0.5"
  
  app_name          = var.app_name
  repo_name         = var.repo_name
  distribution_type = "s3"
  enabled          = true
  is_ipv6_enabled  = true
  default_root_object = "index.html"
  price_class      = "PriceClass_100"
  
  # S3 Origin Configuration
  s3_origin_domain_name          = module.frontend_bucket.bucket_regional_domain_name
  s3_origin_id                   = module.frontend_bucket.bucket_name
  s3_origin_access_identity_path = module.cloudfront_oai.oai_cloudfront_access_identity_path
  
  # WAF Integration
  web_acl_arn = module.waf_cloudfront.web_acl_arn
  
  # Logging Configuration
  enable_logging             = true
  log_bucket_domain_name     = module.cloudfront_logs.bucket_regional_domain_name
  log_prefix                = "${var.app_name}/cloudfront-logs/"
  log_include_cookies       = false
  
  # Cache Behavior (optimized for static sites)
  cache_allowed_methods          = ["GET", "HEAD"]
  cache_cached_methods           = ["GET", "HEAD"]
  cache_viewer_protocol_policy   = "redirect-to-https"
  cache_min_ttl                 = 0
  cache_default_ttl             = 3600
  cache_max_ttl                 = 86400
  cache_forward_query_string     = false
  cache_forward_cookies         = "none"
  
  # Geo Restrictions
  geo_restriction_type = "none"
  
  # SSL Configuration
  use_cloudfront_default_certificate = true
  
  tags = module.common.common_tags
}
