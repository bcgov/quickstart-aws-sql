# Common Variables Module
# This module provides standardized variable definitions and locals that can be shared across infrastructure modules

locals {
  # Standard environment mapping
  env_map = {
    dev     = "Dev"
    test    = "Test"
    prod    = "Prod"
    tools   = "Tools"
    unclass = "UnClass"
  }

  # Common naming patterns
  environment = local.env_map[lower(var.target_env)]
  
  # Common tags that should be applied to all resources
  common_tags = merge(
    var.common_tags,
    {
      Environment = var.target_env
      AppEnv      = var.app_env
      AppName     = var.app_name
      ManagedBy   = "Terraform"
      Repository  = var.repo_name
    }
  )

  # Production environment identification for conditional resource configurations
  is_production = contains(["prod"], lower(var.target_env))
  
  # Development environments for cost optimization settings
  is_development = contains(["dev", "test"], lower(var.target_env))
}
