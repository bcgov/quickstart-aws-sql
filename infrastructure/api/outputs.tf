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

output "database_status" {
  description = "Status of database connection configuration"
  value = {
    cluster_name_provided = var.db_cluster_name != ""
    using_fallback_creds  = !local.db_resources_available
    db_endpoint          = local.db_endpoint
    warning = !local.db_resources_available ? "Using fallback database credentials. Ensure database cluster exists before deploying." : null
  }
}