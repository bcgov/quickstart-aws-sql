output "apigw_url" {
  description = "Base URL to call the API (CloudFront if public, direct API Gateway if private)"
  value       = var.is_public_api ? "https://${aws_cloudfront_distribution.api[0].domain_name}" : aws_apigatewayv2_api.app.api_endpoint
}

output "cloudfront_secret_parameter" {
  description = "SSM Parameter name containing the CloudFront origin verification secret"
  value       = var.is_public_api ? aws_ssm_parameter.cloudfront_secret[0].name : null
}