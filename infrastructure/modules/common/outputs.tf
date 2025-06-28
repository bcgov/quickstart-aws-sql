# Common Module Outputs
output "environment" {
  description = "Processed environment name (capitalized)"
  value       = local.environment
}

output "common_tags" {
  description = "Standardized tags for all resources"
  value       = local.common_tags
}

output "is_production" {
  description = "Boolean indicating if this is a production environment"
  value       = local.is_production
}

output "is_development" {
  description = "Boolean indicating if this is a development environment"
  value       = local.is_development
}

output "env_map" {
  description = "Environment mapping for reference"
  value       = local.env_map
}
