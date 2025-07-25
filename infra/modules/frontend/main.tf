# Import common configurations
module "common" {
  source = "git::https://github.com/bcgov/quickstart-aws-helpers.git//terraform/modules/common?ref=v0.1.2"

  app_env     = var.app_env
  app_name    = var.app_name
  common_tags = var.common_tags
  repo_name   = var.repo_name
  target_env  = var.target_env
}

# Create CloudFront distribution using the CloudFront module
module "cloudfront_distribution" {
  source = "git::https://github.com/bcgov/quickstart-aws-helpers.git//terraform/modules/cloudfront?ref=v0.1.2"

  app_name                           = var.app_name
  cache_allowed_methods              = ["GET", "HEAD"]
  cache_cached_methods               = ["GET", "HEAD"]
  cache_default_ttl                  = 3600
  cache_forward_cookies              = "none"
  cache_forward_query_string         = false
  cache_max_ttl                      = 86400
  cache_min_ttl                      = 0
  cache_viewer_protocol_policy       = "redirect-to-https"
  default_root_object                = "index.html"
  distribution_type                  = "s3"
  enabled                            = true
  enable_logging                     = true
  geo_restriction_type               = "none"
  is_ipv6_enabled                    = true
  log_bucket_domain_name             = module.cloudfront_logs.bucket_regional_domain_name
  log_include_cookies                = false
  log_prefix                         = "${var.app_name}/cloudfront-logs/"
  price_class                        = "PriceClass_100"
  repo_name                          = var.repo_name
  s3_origin_access_identity_path     = module.cloudfront_oai.oai_cloudfront_access_identity_path
  s3_origin_domain_name              = module.frontend_bucket.bucket_regional_domain_name
  s3_origin_id                       = module.frontend_bucket.bucket_name
  tags                               = module.common.common_tags
  use_cloudfront_default_certificate = true
  web_acl_arn                        = module.waf_cloudfront.web_acl_arn
}

# Create CloudFront logs bucket
module "cloudfront_logs" {
  source = "git::https://github.com/bcgov/quickstart-aws-helpers.git//terraform/modules/s3-cloudfront-logs?ref=v0.1.2"

  bucket_name = "${var.app_name}-cf-logs"
  log_prefix  = "${var.app_name}/cloudfront-logs/"
  tags        = module.common.common_tags
}

# Create CloudFront Origin Access Identity
module "cloudfront_oai" {
  source = "git::https://github.com/bcgov/quickstart-aws-helpers.git//terraform/modules/cloudfront-oai?ref=v0.1.2"

  comment        = "OAI for ${var.app_name} site."
  s3_bucket_arn  = module.frontend_bucket.bucket_arn
  s3_bucket_name = module.frontend_bucket.bucket_name
}

# Create the frontend S3 bucket using the secure bucket module
module "frontend_bucket" {
  source = "git::https://github.com/bcgov/quickstart-aws-helpers.git//terraform/modules/s3-secure-bucket?ref=v0.1.2"

  bucket_name                = "${var.app_name}-static-assets"
  encryption_algorithm       = "AES256"
  enable_public_access_block = true
  enable_versioning          = false
  force_destroy              = true
  tags                       = module.common.common_tags
}
module "waf_cloudfront" {
  source = "git::https://github.com/bcgov/quickstart-aws-helpers.git//terraform/modules/waf?ref=v0.1.2"

  description          = "CloudFront WAF Rules"
  enable_bad_inputs    = true
  enable_common_rules  = true
  enable_ip_reputation = true
  enable_linux_rules   = true
  enable_rate_limiting = false # Disabled for frontend static content
  enable_sqli_rules    = true
  name                 = "${var.app_name}-waf-cloudfront"
  scope                = "CLOUDFRONT"
  tags                 = module.common.common_tags

}