# ============================================================================
# API Gateway Origin Restriction Configuration
# ============================================================================
# This configuration ensures that the API Gateway only accepts traffic from 
# CloudFront and rejects direct access attempts. This is achieved through:
#
# 1. A random secret stored in AWS Systems Manager Parameter Store
# 2. CloudFront adds this secret as a custom header (x-origin-verify) to all requests
# 3. A WAF Web ACL on API Gateway that only allows requests with the correct header
# 4. All direct requests to API Gateway without the header are blocked
#
# This provides an additional security layer beyond network-level restrictions.
# ============================================================================

resource "aws_apigatewayv2_vpc_link" "app" {
  name               = var.app_name
  subnet_ids         = data.aws_subnets.web.ids
  security_group_ids = [data.aws_security_group.web.id]
}

resource "aws_apigatewayv2_api" "app" {
  name          = var.app_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "app" {
  api_id             = aws_apigatewayv2_api.app.id
  integration_type   = "HTTP_PROXY"
  connection_id      = aws_apigatewayv2_vpc_link.app.id
  connection_type    = "VPC_LINK"
  integration_method = "ANY"
  integration_uri    = aws_alb_listener.internal.arn
}

resource "aws_apigatewayv2_route" "app" {
  api_id    = aws_apigatewayv2_api.app.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.app.id}"
}

resource "aws_apigatewayv2_stage" "app" {
  api_id      = aws_apigatewayv2_api.app.id
  name        = "$default"
  auto_deploy = true
}

# Generate a random secret for CloudFront origin verification
resource "random_password" "cloudfront_secret" {
  count   = var.is_public_api ? 1 : 0
  length  = 32
  special = true
}

# Store the secret in AWS Systems Manager Parameter Store
resource "aws_ssm_parameter" "cloudfront_secret" {
  count = var.is_public_api ? 1 : 0
  name  = "/${var.app_name}/cloudfront-origin-secret"
  type  = "SecureString"
  value = random_password.cloudfront_secret[0].result

  tags = var.common_tags
}

# WAF Web ACL for API Gateway to restrict access to CloudFront only
resource "aws_wafv2_web_acl" "api_gateway_acl" {
  count = var.is_public_api ? 1 : 0
  name  = "api-gateway-acl-${var.app_name}"
  scope = "REGIONAL"

  default_action {
    block {}
  }

  # Rule to allow requests with the CloudFront origin header
  rule {
    name     = "AllowCloudFrontOnly"
    priority = 1

    action {
      allow {}
    }

    statement {
      byte_match_statement {
        search_string = random_password.cloudfront_secret[0].result
        field_to_match {
          single_header {
            name = "x-origin-verify"
          }
        }
        text_transformation {
          priority = 0
          type     = "NONE"
        }
        positional_constraint = "EXACTLY"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowCloudFrontOnly"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "APIGatewayWebACL"
    sampled_requests_enabled   = true
  }

  tags = var.common_tags
}

# Associate WAF with API Gateway
resource "aws_wafv2_web_acl_association" "api_gateway" {
  count        = var.is_public_api ? 1 : 0
  resource_arn = aws_apigatewayv2_stage.app.arn
  web_acl_arn  = aws_wafv2_web_acl.api_gateway_acl[0].arn
}
