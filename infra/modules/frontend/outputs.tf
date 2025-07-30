output "cloudfront" {
  description = "CloudFront distribution."
  value = {
    domain_name     = module.cloudfront_distribution.distribution_domain_name
    distribution_id = module.cloudfront_distribution.distribution_id
    url             = module.cloudfront_distribution.distribution_url
  }
}

output "s3_bucket" {
  description = "S3 bucket for static assets."
  value = {
    arn  = module.frontend_bucket.bucket_arn
    name = module.frontend_bucket.bucket_name
  }
}