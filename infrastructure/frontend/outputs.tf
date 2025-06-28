output "cloudfront" {
  description = "CloudFront distribution."
  value = {
    domain_name     = module.cloudfront_distribution.distribution_domain_name
    distribution_id = module.cloudfront_distribution.distribution_id
    url             = module.cloudfront_distribution.distribution_url
  }
}

output "s3_bucket_arn" {
  description = "ARN of S3 bucket for storing static assets."
  value       = module.frontend_bucket.bucket_arn
}

output "s3_bucket_name" {
  description = "Name of S3 bucket for storing static assets."
  value       = module.frontend_bucket.bucket_name
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL."
  value       = module.waf_cloudfront.web_acl_arn
}