output "cloudfront" {
  description = "CloudFront distribution."
  value = {
    domain_name     = module.cloudfront_distribution.distribution_domain_name
    distribution_id = module.cloudfront_distribution.distribution_id
    url             = module.cloudfront_distribution.distribution_url
  }
}