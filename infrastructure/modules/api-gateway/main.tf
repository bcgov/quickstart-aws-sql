# API Gateway Module Main Configuration
resource "aws_apigatewayv2_vpc_link" "this" {
  name               = var.vpc_link_name != null ? var.vpc_link_name : var.api_name
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids
  tags               = var.tags
}

resource "aws_apigatewayv2_api" "this" {
  name          = var.api_name
  protocol_type = var.protocol_type
  tags          = var.tags

  dynamic "cors_configuration" {
    for_each = var.enable_cors ? [1] : []
    content {
      allow_credentials = var.cors_configuration.allow_credentials
      allow_headers     = var.cors_configuration.allow_headers
      allow_methods     = var.cors_configuration.allow_methods
      allow_origins     = var.cors_configuration.allow_origins
      expose_headers    = var.cors_configuration.expose_headers
      max_age          = var.cors_configuration.max_age
    }
  }
}

resource "aws_apigatewayv2_integration" "this" {
  api_id             = aws_apigatewayv2_api.this.id
  integration_type   = var.integration_type
  connection_id      = aws_apigatewayv2_vpc_link.this.id
  connection_type    = "VPC_LINK"
  integration_method = var.integration_method
  integration_uri    = var.integration_uri
}

resource "aws_apigatewayv2_route" "this" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = var.route_key
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.stage_name
  auto_deploy = var.auto_deploy
  tags        = var.tags
}
