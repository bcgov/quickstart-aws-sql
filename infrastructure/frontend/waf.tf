# Create WAF for CloudFront using the WAF module
module "waf_cloudfront" {
  source = "../modules/waf"
  
  name                    = "${var.app_name}-waf-cloudfront"
  description             = "CloudFront WAF Rules"
  scope                   = "CLOUDFRONT"
  enable_rate_limiting    = false  # Disabled for frontend static content
  enable_ip_reputation    = true
  enable_common_rules     = true
  enable_bad_inputs       = true
  enable_linux_rules      = true
  enable_sqli_rules       = true
  tags                    = module.common.common_tags
  
  providers = {
    aws = aws.east  # CloudFront WAF must be in us-east-1
  }
}
