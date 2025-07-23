output "apigw_url" {
  description = "Base URL to call the API (CloudFront if public, direct API Gateway if private)"
  value       = var.is_public_api ? module.cloudfront_api[0].distribution_url : module.api_gateway.api_endpoint
}

