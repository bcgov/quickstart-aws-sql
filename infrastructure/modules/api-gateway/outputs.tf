# API Gateway Module Outputs
output "api" {
  description = "API Gateway information"
  value = {
    id           = aws_apigatewayv2_api.this.id
    arn          = aws_apigatewayv2_api.this.arn
    name         = aws_apigatewayv2_api.this.name
    endpoint     = aws_apigatewayv2_api.this.api_endpoint
    execution_arn = aws_apigatewayv2_api.this.execution_arn
  }
}

output "api_id" {
  description = "API Gateway ID"
  value       = aws_apigatewayv2_api.this.id
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "vpc_link" {
  description = "VPC Link information"
  value = {
    id   = aws_apigatewayv2_vpc_link.this.id
    arn  = aws_apigatewayv2_vpc_link.this.arn
    name = aws_apigatewayv2_vpc_link.this.name
  }
}

output "stage" {
  description = "API Gateway stage information"
  value = {
    id           = aws_apigatewayv2_stage.this.id
    arn          = aws_apigatewayv2_stage.this.arn
    name         = aws_apigatewayv2_stage.this.name
    invoke_url   = aws_apigatewayv2_stage.this.invoke_url
  }
}

output "integration" {
  description = "API Gateway integration information"
  value = {
    id   = aws_apigatewayv2_integration.this.id
    type = aws_apigatewayv2_integration.this.integration_type
  }
}
