# Import common configurations
module "common" {
  source = "../modules/common"
  
  target_env    = var.target_env
  app_env       = var.app_env
  app_name      = var.app_name
  repo_name     = var.repo_name
  common_tags   = var.common_tags
}

# Import networking configurations
module "networking" {
  source = "../modules/networking"
  
  target_env = var.target_env
}

# API Gateway with VPC Link using the API Gateway module
module "api_gateway" {
  source = "../modules/api-gateway"
  
  api_name           = var.app_name
  protocol_type      = "HTTP"
  subnet_ids         = module.networking.subnets.web.ids
  security_group_ids = [module.networking.security_groups.web.id]
  integration_uri    = aws_alb_listener.internal.arn
  route_key         = "ANY /{proxy+}"
  stage_name        = "$default"
  auto_deploy       = true
  tags              = module.common.common_tags
}

# Compatibility data sources for existing resource references
# These allow existing code to still reference aws_apigatewayv2_api.app.id etc.
data "aws_apigatewayv2_api" "app" {
  api_id = module.api_gateway.api_id
}

data "aws_apigatewayv2_vpc_link" "app" {
  vpc_link_id = module.api_gateway.vpc_link.id
}

# For resources that need the integration and route IDs, use module outputs
locals {
  api_integration_id = module.api_gateway.integration.id
  api_stage_name     = module.api_gateway.stage.name
}
