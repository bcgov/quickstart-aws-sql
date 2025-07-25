output "apigw_url" {
  description = "Base URL to call the API (CloudFront if public, direct API Gateway if private)"
  value       = module.api.apigw_url
}
output "cloudfront" {
  description = "CloudFront distribution."
  value       = module.frontend.cloudfront
}
output "frontend_bucket" {
  description = "S3 bucket for frontend static assets."
  value = {
    arn  = module.frontend_bucket.bucket_arn
    name = module.frontend_bucket.bucket_name
  }
}