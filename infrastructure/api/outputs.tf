output "apigw_url" {
  description = "Base URL to call the API (CloudFront if public, direct API Gateway if private)"
  value       = var.is_public_api ? module.cloudfront_api[0].distribution_url : module.api_gateway.api_endpoint
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (if public API)"
  value       = var.is_public_api ? module.cloudfront_api[0].distribution_id : null
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name (if public API)"
  value       = var.is_public_api ? module.cloudfront_api[0].distribution_domain_name : null
}