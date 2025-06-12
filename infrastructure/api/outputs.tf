output "apigw_url" {
  description = "Base URL to call the API (CloudFront if public, direct API Gateway if private)"
  value       = var.is_public_api ? "https://${aws_cloudfront_distribution.api.domain_name}" : aws_apigatewayv2_stage.api.invoke_url
}